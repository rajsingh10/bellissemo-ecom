import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../Apicalling/sharedpreferance.dart';
import '../../../apiCalling/apiEndpoints.dart';
import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';
import '../modal/checkCartDataModal.dart';

// Pretty print JSON helper
String prettyPrintJson(Map<String, dynamic> json) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(json);
}

class CartService {
  final Dio _dio = Dio();

  // ----------------- Add to Cart -----------------
  Future<Response?> addToCart({
    required int productId,
    required int quantity,
    required String? itemNote,
    int? variationId,
    Map<String, dynamic>? variation,
  }) async {
    var box = HiveService().getAddCartBox();

    Map<String, dynamic> body =
        variationId != null && variation != null
            ? {
              "product_id": productId,
              "variation_id": variationId,
              "variation": variation,
              "quantity": quantity,
              "item_note": itemNote ?? "",
            }
            : {
              "product_id": productId,
              "quantity": quantity,
              "item_note": itemNote ?? "",
            };

    print("📦 Cart Body:\n${prettyPrintJson(body)}");

    // ----------------- Offline Add -----------------
    if (!await checkInternet()) {
      await box.put(
        "offline_cart_${DateTime.now().millisecondsSinceEpoch}",
        body,
      );
      print("📦 Added offline because no internet");
      return null;
    }

    // ----------------- Online Add -----------------
    try {
      final loginData = await SaveDataLocal.getDataFromLocal();
      final token = loginData?.token ?? '';
      if (token.isEmpty) throw Exception("Token not found");

      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await _dio.post(
        apiEndpoints.addToCart,
        data: jsonEncode(body),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await box.put(
          "cart_${productId}_${variationId ?? 'simple'}",
          response.data,
        );
      }

      return response;
    } catch (e) {
      await box.put(
        "offline_cart_${DateTime.now().millisecondsSinceEpoch}",
        body,
      );
      print("📦 Saved offline due to network error: $e");
      return null;
    }
  }

  // ----------------- Sync Offline Cart -----------------
  Future<void> syncOfflineCart() async {
    var box = HiveService().getAddCartBox();
    final keys =
        box.keys
            .where((key) => key.toString().startsWith("offline_cart_"))
            .toList();

    if (keys.isEmpty) return;

    for (var key in keys) {
      final body = box.get(key);
      final isVariableProduct =
          body["variation_id"] != null && body["variation"] != null;

      try {
        final response = await addToCart(
          productId: body["product_id"],
          quantity: body["quantity"],
          itemNote: isVariableProduct ? null : body["item_note"],
          variationId: isVariableProduct ? body["variation_id"] : null,
          variation:
              isVariableProduct
                  ? Map<String, dynamic>.from(body["variation"])
                  : null,
        );

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          log(
            "✅ Offline cart item synced: ${body["product_id"]} ${isVariableProduct ? "(variable)" : "(simple)"}",
          );
          await box.delete(key);
        }
      } catch (e) {
        log(
          "⚠️ Failed to sync offline cart item: ${body["product_id"]}, Error: $e",
        );
      }
    }
  }

  // ----------------- Get Product Cart Data -----------------
  Future<Map<String, dynamic>> getProductCartData({
    required int productId,
  }) async {
    num totalQuantity = 0;
    String? cartItemKey;

    var box = HiveService().getAddCartBox();
    var cacheBox = HiveService().getProductCartDataBox();

    if (!cacheBox.isOpen) {
      await HiveService().init();
      cacheBox = HiveService().getProductCartDataBox();
    }

    // ✅ Offline cart check
    final offlineKeys =
        box.keys
            .where((key) => key.toString().startsWith("offline_cart_"))
            .toList();

    for (var key in offlineKeys) {
      final body = box.get(key);
      if (body != null && body["product_id"] == productId) {
        totalQuantity += body["quantity"] ?? 0; // ✅ fixed
      }
    }

    // ✅ Online cart check
    if (await checkInternet()) {
      try {
        final loginData = await SaveDataLocal.getDataFromLocal();
        final token = loginData?.token ?? '';
        if (token.isNotEmpty) {
          final headers = {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          };

          final response = await _dio.get(
            "${apiEndpoints.checkCart}$productId",
            options: Options(headers: headers),
          );

          if (response.statusCode == 200) {
            final data = CheckCartDataModal.fromJson(response.data);

            if (data.inCart == true) {
              totalQuantity += data.totalQuantity ?? 0;

              if (data.matchingItems != null &&
                  data.matchingItems!.isNotEmpty) {
                final match = data.matchingItems!.firstWhere(
                  (item) => item.productId == productId,
                  orElse: () => MatchingItems(),
                );
                cartItemKey = match.cartItemKey;
              }
            }
          }
        }
      } catch (e) {
        print("⚠️ Failed to get online cart data: $e");
      }
    }

    // ✅ Update cache
    await cacheBox.put("cartData_$productId", {
      "totalQuantity": totalQuantity,
      "cartItemKey": cartItemKey,
    });

    return {"totalQuantity": totalQuantity, "cartItemKey": cartItemKey};
  }

  // ----------------- Get Cached Cart Data -----------------
  Map<String, dynamic>? getCachedProductCartData(int productId) {
    var cacheBox = HiveService().getProductCartDataBox();
    if (!cacheBox.isOpen) return null;
    return cacheBox.get("cartData_$productId");
  }

  // ----------------- Decrease / Remove from Cart (Offline-safe) -----------------
  Future<Response?> decreaseCartItem({required int productId}) async {
    final cartData = await getProductCartData(productId: productId);

    num totalQuantity = cartData["totalQuantity"] ?? 0;
    String? cartItemKey = cartData["cartItemKey"];

    if (totalQuantity <= 0) {
      print("⚠️ No items in cart to remove.");
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 204,
        data: null,
      );
    }

    int quantityToSend = totalQuantity > 1 ? (totalQuantity - 1).toInt() : 0;
    Map<String, dynamic> body = {
      "cart_item_key":
          cartItemKey ?? "offline_${DateTime.now().millisecondsSinceEpoch}",
      "quantity": quantityToSend,
    };

    var box = HiveService().getAddCartBox();
    var cacheBox = HiveService().getProductCartDataBox();

    if (!cacheBox.isOpen) {
      await HiveService().init();
      cacheBox = HiveService().getProductCartDataBox();
    }

    // ----------------- Offline removal -----------------
    if (!await checkInternet()) {
      final offlineKeys =
          box.keys
              .where((key) => key.toString().startsWith("offline_cart_"))
              .toList();

      for (var key in offlineKeys) {
        final offlineItem = box.get(key);
        if (offlineItem != null && offlineItem["product_id"] == productId) {
          int offlineQty = offlineItem["quantity"] ?? 0;

          if (offlineQty > 1) {
            offlineItem["quantity"] = offlineQty - 1;
            await box.put(key, offlineItem);
          } else {
            await box.delete(key);
          }

          break; // decrease only once
        }
      }

      await cacheBox.put("cartData_$productId", {
        "totalQuantity": quantityToSend,
        "cartItemKey": cartItemKey,
      });

      print("🗑️ Offline cart updated & cache refreshed");
      return null;
    }

    // ----------------- Online removal -----------------
    try {
      final loginData = await SaveDataLocal.getDataFromLocal();
      final token = loginData?.token ?? '';
      if (token.isEmpty) throw Exception("Token not found");

      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await _dio.post(
        apiEndpoints.removeFromCart,
        data: jsonEncode(body),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        await cacheBox.put("cartData_$productId", {
          "totalQuantity": quantityToSend,
          "cartItemKey": cartItemKey,
        });
      }

      return response;
    } catch (e) {
      // fallback offline if online fails
      await box.put(
        "offline_remove_cart_${DateTime.now().millisecondsSinceEpoch}",
        body,
      );

      await cacheBox.put("cartData_$productId", {
        "totalQuantity": quantityToSend,
        "cartItemKey": cartItemKey,
      });

      print("⚠️ Failed online, saved offline & updated cache: $e");
      return null;
    }
  }
}
