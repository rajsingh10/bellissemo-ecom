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
    final box = HiveService().getAddCartBox();

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

    if (!await checkInternet()) {
      await box.put(
        "offline_cart_${DateTime.now().millisecondsSinceEpoch}",
        body,
      );
      print("📦 Added offline because no internet");
      return null;
    }

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
    final box = HiveService().getAddCartBox();
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

  // ----------------- Sync Offline Actions -----------------
  Future<void> syncOfflineActions() async {
    final box = HiveService().getAddCartBox();
    final keys =
        box.keys.where((key) => key.toString().startsWith("offline_")).toList();

    if (keys.isEmpty) return;

    for (var key in keys) {
      final actionData = box.get(key);

      try {
        if (actionData["action"] == "clear_cart") {
          // Clear cart action
          final response = await clearCart();
          if (response != null &&
              (response.statusCode == 200 || response.statusCode == 204)) {
            await box.delete(key);
            print("✅ Offline clear cart synced");
          }
        } else if (actionData.containsKey("product_id")) {
          final productId = actionData["product_id"];
          final quantity = actionData["quantity"] ?? 1;
          final variationId = actionData["variation_id"];
          final variation = actionData["variation"];
          final itemNote = actionData["item_note"];

          // Handle queued ADD actions
          if (key.toString().startsWith("offline_cart_")) {
            final resp = await addToCart(
              productId: productId,
              quantity: quantity,
              itemNote: itemNote,
              variationId: variationId,
              variation:
                  variation != null
                      ? Map<String, dynamic>.from(variation)
                      : null,
            );

            if (resp != null) {
              await box.delete(key);
              print("✅ Offline add cart item synced: $productId");
            }
          }
          // Handle queued DECREASE/REMOVE actions
          else if (key.toString().startsWith("offline_remove_cart_")) {
            // Call decreaseCartItem **exactly quantity times**
            for (int i = 0; i < quantity; i++) {
              final resp = await decreaseCartItem(productId: productId);
              if (resp == null) {
                // Offline still? Keep key for next sync
                print("⚠️ Still offline, will retry later: $productId");
                break;
              }
            }

            // Delete key if fully processed
            await box.delete(key);
            print("✅ Offline remove cart item synced: $productId");
          }
        }
      } catch (e) {
        print("⚠️ Failed to sync offline action $key: $e");
      }
    }
  }

  // // ----------------- Sync Offline Actions -----------------
  // Future<void> syncOfflineActions() async {
  //   final box = HiveService().getAddCartBox();
  //   final keys =
  //       box.keys.where((key) => key.toString().startsWith("offline_")).toList();
  //
  //   if (keys.isEmpty) return;
  //
  //   for (var key in keys) {
  //     final actionData = box.get(key);
  //
  //     try {
  //       if (actionData["action"] == "clear_cart") {
  //         final response = await clearCart();
  //         if (response != null &&
  //             (response.statusCode == 200 || response.statusCode == 204)) {
  //           await box.delete(key);
  //           print("✅ Offline clear cart synced");
  //         }
  //       } else if (actionData.containsKey("product_id")) {
  //         final productId = actionData["product_id"];
  //         final quantity = actionData["quantity"];
  //         final variationId = actionData["variation_id"];
  //         final variation = actionData["variation"];
  //         final itemNote = actionData["item_note"];
  //
  //         if (key.toString().startsWith("offline_cart_")) {
  //           final resp = await addToCart(
  //             productId: productId,
  //             quantity: quantity,
  //             itemNote: itemNote,
  //             variationId: variationId,
  //             variation:
  //                 variation != null
  //                     ? Map<String, dynamic>.from(variation)
  //                     : null,
  //           );
  //           if (resp != null) await box.delete(key);
  //         } else if (key.toString().startsWith("offline_remove_cart_")) {
  //           final resp = await decreaseCartItem(productId: productId,);
  //           if (resp != null) await box.delete(key);
  //         }
  //       }
  //     } catch (e) {
  //       print("⚠️ Failed to sync offline action $key: $e");
  //     }
  //   }
  // }

  // ----------------- Get Product Cart Data -----------------
  Future<Map<String, dynamic>> getProductCartData({
    required int productId,
  }) async {
    num totalQuantity = 0;
    String? cartItemKey;

    var box = HiveService().getAddCartBox();
    var cacheBox = HiveService().getProductCartDataBox();

    if (!cacheBox.isOpen) await HiveService().init();

    // Offline check
    final offlineKeys =
        box.keys
            .where((key) => key.toString().startsWith("offline_cart_"))
            .toList();

    for (var key in offlineKeys) {
      final body = box.get(key);
      if (body != null && body["product_id"] == productId) {
        totalQuantity += body["quantity"] ?? 0;
      }
    }

    // Online check
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

    await cacheBox.put("cartData_$productId", {
      "totalQuantity": totalQuantity,
      "cartItemKey": cartItemKey,
    });

    return {"totalQuantity": totalQuantity, "cartItemKey": cartItemKey};
  }

  // ----------------- Get Cached Cart Data -----------------
  Map<String, dynamic>? getCachedProductCartData(int productId) {
    var cacheBox = HiveService().getProductCartDataBox();
    if (!cacheBox.isOpen) return null; // <-- this is safe
    return cacheBox.get("cartData_$productId"); // <-- may return null
  }

  // ----------------- Decrease / Remove from Cart -----------------
  Future<Response?> decreaseCartItem({required int productId}) async {
    final box = HiveService().getAddCartBox();
    final cacheBox = HiveService().getProductCartDataBox();
    if (!cacheBox.isOpen) await HiveService().init();

    // Get cached total quantity (UI + offline queued)
    final cachedData = cacheBox.get("cartData_$productId");
    int totalQuantity = (cachedData?["totalQuantity"] ?? 0).toInt();

    if (totalQuantity <= 0) {
      final hasInternet = await checkInternet();
      if (hasInternet) {
        print("⚠️ No items in cart to remove.");
      } else {
        print("🗑️ Offline cart removal skipped, quantity already 0.");
      }
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 204,
        data: null,
      );
    }

    int newQuantity = totalQuantity - 1;

    final hasInternet = await checkInternet();

    // ---------------- OFFLINE ----------------
    if (!hasInternet) {
      await box
          .put("offline_remove_cart_${DateTime.now().millisecondsSinceEpoch}", {
            "action": "decrease",
            "product_id": productId,
            "quantity": 1,
            "timestamp": DateTime.now().toIso8601String(),
          });

      await cacheBox.put("cartData_$productId", {"totalQuantity": newQuantity});

      print("🗑️ Offline cart decreased by 1. New quantity: $newQuantity");
      return null;
    }

    // ---------------- ONLINE ----------------
    try {
      final loginData = await SaveDataLocal.getDataFromLocal();
      final token = loginData?.token ?? '';
      if (token.isEmpty) throw Exception("Token not found");

      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      // Get **only online quantity** to avoid double-counting offline decreases
      final cartData = await getProductCartData(productId: productId);
      final cartItemKey = cartData["cartItemKey"];
      int onlineQuantity = cartData["totalQuantity"] ?? totalQuantity;

      if (cartItemKey == null) {
        // Queue offline decrease if key not found
        await box.put(
          "offline_remove_cart_${DateTime.now().millisecondsSinceEpoch}",
          {
            "action": "decrease",
            "product_id": productId,
            "quantity": 1,
            "timestamp": DateTime.now().toIso8601String(),
          },
        );
        print("⚠️ No cartItemKey found online, queued offline removal.");
        return null;
      }

      final body = {
        "cart_item_key": cartItemKey,
        "quantity": onlineQuantity - 1, // only decrease 1 online
      };

      final response = await _dio.post(
        apiEndpoints.removeFromCart,
        data: jsonEncode(body),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update cache: combine new online quantity with queued offline decreases
        int offlineQueuedQty = 0;

        final offlineKeys =
            box.keys
                .where(
                  (key) => key.toString().startsWith("offline_remove_cart_"),
                )
                .toList();

        for (var key in offlineKeys) {
          final item = box.get(key);
          if (item["product_id"] == productId) {
            offlineQueuedQty += int.parse(item["quantity"].toString());
          }
        }

        await cacheBox.put("cartData_$productId", {
          "totalQuantity": (onlineQuantity - 1) + offlineQueuedQty,
          "cartItemKey": cartItemKey,
        });

        print(
          "✅ Cart item decreased online. Online: ${onlineQuantity - 1}, Total with offline queued: ${(onlineQuantity - 1) + offlineQueuedQty}",
        );
      }

      return response;
    } catch (e) {
      // Queue offline decrease if online fails
      await box
          .put("offline_remove_cart_${DateTime.now().millisecondsSinceEpoch}", {
            "action": "decrease",
            "product_id": productId,
            "quantity": 1,
            "timestamp": DateTime.now().toIso8601String(),
          });

      await cacheBox.put("cartData_$productId", {"totalQuantity": newQuantity});

      print("⚠️ Failed online, saved offline & updated cache: $e");
      return null;
    }
  }

  // ----------------- Increase / Add to Cart -----------------
  Future<Response?> increaseCartItem({
    required int productId,
    String? itemNote,
    int? variationId,
    Map<String, dynamic>? variation,
  }) async {
    final cartData = await getProductCartData(productId: productId);

    num totalQuantity = cartData["totalQuantity"] ?? 0;
    String? cartItemKey = cartData["cartItemKey"];
    int quantityToSend = (totalQuantity + 1).toInt();

    Map<String, dynamic> body =
        cartItemKey != null
            ? {"cart_item_key": cartItemKey, "quantity": quantityToSend}
            : variationId != null && variation != null
            ? {
              "product_id": productId,
              "variation_id": variationId,
              "variation": variation,
              "quantity": 1,
              "item_note": itemNote ?? "",
            }
            : {
              "product_id": productId,
              "quantity": 1,
              "item_note": itemNote ?? "",
            };

    final box = HiveService().getAddCartBox();
    final cacheBox = HiveService().getProductCartDataBox();
    if (!cacheBox.isOpen) await HiveService().init();

    // Offline handling
    if (!await checkInternet()) {
      if (cartItemKey != null) {
        final offlineKeys =
            box.keys
                .where((key) => key.toString().startsWith("offline_cart_"))
                .toList();

        for (var key in offlineKeys) {
          final offlineItem = box.get(key);
          if (offlineItem != null && offlineItem["product_id"] == productId) {
            offlineItem["quantity"] = (offlineItem["quantity"] ?? 0) + 1;
            await box.put(key, offlineItem);
            break;
          }
        }
      } else {
        await box.put(
          "offline_cart_${DateTime.now().millisecondsSinceEpoch}",
          body,
        );
      }

      await cacheBox.put("cartData_$productId", {
        "totalQuantity": quantityToSend,
        "cartItemKey": cartItemKey,
      });

      print("🛒 Offline cart updated & cache refreshed");
      return null;
    }

    // Online handling
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
        cartItemKey != null
            ? apiEndpoints.removeFromCart
            : apiEndpoints.addToCart,
        data: jsonEncode(body),
        options: Options(headers: headers),
      );

      log(
        'Add Url : ${cartItemKey != null ? apiEndpoints.removeFromCart : apiEndpoints.addToCart}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await cacheBox.put("cartData_$productId", {
          "totalQuantity": quantityToSend,
          "cartItemKey": cartItemKey ?? response.data["cart_item_key"],
        });
      }

      return response;
    } catch (e) {
      await box.put(
        "offline_cart_${DateTime.now().millisecondsSinceEpoch}",
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

  // ----------------- Clear Cart -----------------
  Future<Response?> clearCart() async {
    final box = HiveService().getAddCartBox();
    final cacheBox = HiveService().getProductCartDataBox();
    if (!cacheBox.isOpen) await HiveService().init();

    if (!await checkInternet()) {
      await box.clear();
      await cacheBox.clear();
      await box.put(
        "offline_clear_cart_${DateTime.now().millisecondsSinceEpoch}",
        {"action": "clear_cart", "timestamp": DateTime.now().toIso8601String()},
      );
      print("🗑️ Cart cleared offline and queued for sync!");
      return null;
    }

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
        apiEndpoints.clearCart,
        options: Options(
          headers: headers,
          validateStatus:
              (status) => status == 200 || status == 204 || status == 404,
        ),
      );

      await box.clear();
      await cacheBox.clear();

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("🗑️ Cart cleared online!");
      } else if (response.statusCode == 404) {
        print("⚠️ Cart already empty on server, cleared locally.");
      }

      return response;
    } catch (e) {
      await box.clear();
      await cacheBox.clear();
      await box.put(
        "offline_clear_cart_${DateTime.now().millisecondsSinceEpoch}",
        {"action": "clear_cart", "timestamp": DateTime.now().toIso8601String()},
      );
      print("⚠️ Failed online, cart cleared offline & queued: $e");
      return null;
    }
  }
}
