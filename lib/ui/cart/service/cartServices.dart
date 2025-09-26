import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../ApiCalling/response.dart';
import '../../../Apicalling/sharedpreferance.dart';
import '../../../apiCalling/apiEndpoints.dart';
import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';
import '../../login/modal/loginModal.dart';
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

  // ----------------- Sync Offline Queue -----------------
  Future<void> syncOfflineUpdate() async {
    final box = HiveService().getAddCartBox();
    if (!await checkInternet()) return; // only sync when online

    final keys =
        box.keys
            .where((k) => k.toString().startsWith("offline_update_cart_"))
            .toList();

    for (var key in keys) {
      final data = box.get(key);
      if (data == null) continue;

      try {
        await increaseCart(
          cartItemKey: data['cart_item_key'],
          currentQuantity: data['quantity'] - 1, // because increaseCart adds 1
          isSync: true, // important: prevent infinite loop
        );
        await box.delete(key); // remove from offline queue on success
        print(
          "✅ Synced offline cart → ${data['cart_item_key']} : ${data['quantity']}",
        );
      } catch (e) {
        print("⚠️ Failed to sync offline cart → ${data['cart_item_key']}: $e");
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
  Future<Map<String, dynamic>> getCachedProductCartDataSafe(
    int productId,
  ) async {
    var cacheBox = HiveService().getProductCartDataBox();

    if (!cacheBox.isOpen) {
      // Open the box properly if not open
      await HiveService().init();
      cacheBox = HiveService().getProductCartDataBox();
    }

    final data = cacheBox.get("cartData_$productId");

    if (data == null) return {}; // empty map if nothing

    // Convert any dynamic map to Map<String, dynamic>
    return Map<String, dynamic>.from(data);
  }

  // ----------------- Decrease / Remove from Cart -----------------
  Future<Response?> decreaseCartItem({
    required int productId,
    int decreaseBy = 1,
  }) async {
    final box = HiveService().getAddCartBox();
    final cacheBox = HiveService().getProductCartDataBox();
    if (!cacheBox.isOpen) await HiveService().init();

    // Get cached quantity safely
    final cachedData = cacheBox.get("cartData_$productId");
    int totalQuantity = (cachedData?["totalQuantity"] ?? 0).toInt();

    // Fallback if cache is empty
    if (totalQuantity <= 0) {
      totalQuantity = 0; // assume at least 1 to allow offline decrease
    }

    int newQuantity = (totalQuantity - decreaseBy).clamp(0, totalQuantity);

    final hasInternet = await checkInternet();

    // ---------------- OFFLINE ----------------
    if (!hasInternet) {
      // Queue offline decrease
      await box
          .put("offline_remove_cart_${DateTime.now().millisecondsSinceEpoch}", {
            "action": "decrease",
            "product_id": productId,
            "quantity": decreaseBy,
            "timestamp": DateTime.now().toIso8601String(),
          });

      // Update cache
      await cacheBox.put("cartData_$productId", {"totalQuantity": newQuantity});

      print(
        "🗑️ Offline cart decreased by $decreaseBy. New quantity: $newQuantity",
      );
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

      // Get online cart data
      final cartData = await getProductCartData(productId: productId);
      final cartItemKey = cartData["cartItemKey"];
      int onlineQuantity = cartData["totalQuantity"] ?? totalQuantity;

      if (cartItemKey == null) {
        // Queue offline if no key
        await box.put(
          "offline_remove_cart_${DateTime.now().millisecondsSinceEpoch}",
          {
            "action": "decrease",
            "product_id": productId,
            "quantity": decreaseBy,
            "timestamp": DateTime.now().toIso8601String(),
          },
        );
        print("⚠️ No cartItemKey found online, queued offline removal.");
        return null;
      }

      final body = {
        "cart_item_key": cartItemKey,
        "quantity": (onlineQuantity - decreaseBy).clamp(0, onlineQuantity),
      };

      final response = await _dio.post(
        apiEndpoints.removeFromCart,
        data: jsonEncode(body),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Count offline queued decreases
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
          "totalQuantity": (onlineQuantity - decreaseBy) + offlineQueuedQty,
          "cartItemKey": cartItemKey,
        });

        print(
          "✅ Cart item decreased online. Online: ${onlineQuantity - decreaseBy}, Total with offline queued: ${(onlineQuantity - decreaseBy) + offlineQueuedQty}",
        );
      }

      return response;
    } catch (e) {
      // Queue offline if online fails
      await box
          .put("offline_remove_cart_${DateTime.now().millisecondsSinceEpoch}", {
            "action": "decrease",
            "product_id": productId,
            "quantity": decreaseBy,
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

  // ----------------- Increase Cart Item -----------------
  Future<Response?> increaseCart({
    required String cartItemKey,
    required int currentQuantity,
    bool isSync = false, // prevent infinite loop during sync
  }) async {
    final newQuantity = currentQuantity + 1;

    final box = HiveService().getAddCartBox();
    final cacheBox = HiveService().getProductCartDataBox();
    if (!cacheBox.isOpen) await HiveService().init();

    // 🔹 Update local cache
    await cacheBox.put("cartData_$cartItemKey", {
      "totalQuantity": newQuantity,
      "cartItemKey": cartItemKey,
    });

    print("🛒 Local cache updated → $cartItemKey : $newQuantity");

    // ---------------- OFFLINE ----------------
    if (!await checkInternet()) {
      if (!isSync) {
        await box.put(
          "offline_update_cart_${DateTime.now().millisecondsSinceEpoch}",
          {
            "action": "update_qty",
            "cart_item_key": cartItemKey,
            "quantity": newQuantity,
            "timestamp": DateTime.now().toIso8601String(),
          },
        );
        print("⚠️ Offline: queued increase → $cartItemKey : $newQuantity");
      }
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

      final body = {"cart_item_key": cartItemKey, "quantity": newQuantity};

      final response = await _dio.post(
        apiEndpoints.updateCart,
        data: jsonEncode(body),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Cart updated online → $cartItemKey : $newQuantity");
      }

      return response;
    } catch (e) {
      if (!isSync) {
        await box.put(
          "offline_update_cart_${DateTime.now().millisecondsSinceEpoch}",
          {
            "action": "update_qty",
            "cart_item_key": cartItemKey,
            "quantity": newQuantity,
            "timestamp": DateTime.now().toIso8601String(),
          },
        );
        print("⚠️ Failed online, saved offline → $cartItemKey : $newQuantity");
      }
      return null;
    }
  }

  // ----------------- Decrease Cart Item -----------------
  Future<Response?> decreaseCart({
    required String cartItemKey,
    required int currentQuantity,
    bool isSync = false,
  }) async {
    if (currentQuantity <= 1) return null; // optional: prevent < 1

    final newQuantity = currentQuantity - 1;

    final box = HiveService().getAddCartBox();
    final cacheBox = HiveService().getProductCartDataBox();
    if (!cacheBox.isOpen) await HiveService().init();

    // 🔹 Update local cache
    await cacheBox.put("cartData_$cartItemKey", {
      "totalQuantity": newQuantity,
      "cartItemKey": cartItemKey,
    });

    print("🛒 Local cache updated → $cartItemKey : $newQuantity");

    // ---------------- OFFLINE ----------------
    if (!await checkInternet()) {
      if (!isSync) {
        await box.put(
          "offline_update_cart_${DateTime.now().millisecondsSinceEpoch}",
          {
            "action": "update_qty",
            "cart_item_key": cartItemKey,
            "quantity": newQuantity,
            "timestamp": DateTime.now().toIso8601String(),
          },
        );
        print("⚠️ Offline: queued decrease → $cartItemKey : $newQuantity");
      }
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

      final body = {"cart_item_key": cartItemKey, "quantity": newQuantity};

      final response = await _dio.post(
        apiEndpoints.updateCart,
        data: jsonEncode(body),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Cart updated online → $cartItemKey : $newQuantity");
      }

      return response;
    } catch (e) {
      if (!isSync) {
        await box.put(
          "offline_update_cart_${DateTime.now().millisecondsSinceEpoch}",
          {
            "action": "update_qty",
            "cart_item_key": cartItemKey,
            "quantity": newQuantity,
            "timestamp": DateTime.now().toIso8601String(),
          },
        );
        print("⚠️ Failed online, saved offline → $cartItemKey : $newQuantity");
      }
      return null;
    }
  }

  // ----------------- Decrease Cart Item -----------------
  Future<Response?> removeFromCart({
    required String cartItemKey,
    bool isSync = false,
  }) async {
    final newQuantity = 0;

    final box = HiveService().getAddCartBox();
    final cacheBox = HiveService().getProductCartDataBox();
    if (!cacheBox.isOpen) await HiveService().init();

    // 🔹 Update local cache
    await cacheBox.put("cartData_$cartItemKey", {
      "totalQuantity": newQuantity,
      "cartItemKey": cartItemKey,
    });

    print("🛒 Local cache updated → $cartItemKey : $newQuantity");

    // ---------------- OFFLINE ----------------
    if (!await checkInternet()) {
      if (!isSync) {
        await box.put(
          "offline_update_cart_${DateTime.now().millisecondsSinceEpoch}",
          {
            "action": "update_qty",
            "cart_item_key": cartItemKey,
            "quantity": newQuantity,
            "timestamp": DateTime.now().toIso8601String(),
          },
        );
        print("⚠️ Offline: queued decrease → $cartItemKey : $newQuantity");
      }
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

      final body = {"cart_item_key": cartItemKey, "quantity": newQuantity};

      final response = await _dio.post(
        apiEndpoints.updateCart,
        data: jsonEncode(body),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Cart updated online → $cartItemKey : $newQuantity");
      }

      return response;
    } catch (e) {
      if (!isSync) {
        await box.put(
          "offline_update_cart_${DateTime.now().millisecondsSinceEpoch}",
          {
            "action": "update_qty",
            "cart_item_key": cartItemKey,
            "quantity": newQuantity,
            "timestamp": DateTime.now().toIso8601String(),
          },
        );
        print("⚠️ Failed online, saved offline → $cartItemKey : $newQuantity");
      }
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

  // ----------------- Fetch Cart -----------------
  Future<http.Response> fetchCart(id) async {
    String url = "${apiEndpoints.viewCart}$id";
    LoginModal? loginData = await SaveDataLocal.getDataFromLocal();
    String token = loginData?.token ?? '';
    print("my token :: $token");
    if (token.isEmpty) {
      throw Exception('Token not found');
    }
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    print(url);
    var responseJson;
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw const SocketException('Something went wrong');
          },
        );
    responseJson = responses(response);

    return responseJson;
  }


  /// submit order ////
  Future<Response?> submitOrderApi({
    required String note,
    required String deliveryDate,
    required var shippingCharge,
    int? customerId,

  }) async {
    final box = HiveService().getSubmitOrderBox();

    // 🔹 Create Order Body
    Map<String, dynamic> body = {
      "customer_id": customerId,
      "shipping_lines": [
        {
          "method_id": "flat_rate",
          "method_title": "Delivery",
          "total": shippingCharge
        }
      ],
      "delivery_date": deliveryDate,
      "order_note": note,
      "hide_prices_by_default": false,
      "status": "completed"
    };

    print("📦 Cart Body:\n${prettyPrintJson(body)}");

    // 🔹 Check Internet
    if (!await checkInternet()) {
      await _saveOfflineOrder(box, body);
      print("📦 Saved offline (no internet)");
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
        apiEndpoints.submitOrder,
        data: jsonEncode(body),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 🔹 Save successful order response
        await box.put(
          "order_${DateTime.now().millisecondsSinceEpoch}",
          response.data,
        );
      }

      return response;
    } catch (e) {
      await _saveOfflineOrder(box, body);
      print("📦 Saved offline due to error: $e");
      return null;
    }
  }

  /// 🔹 Helper: Save offline order
  Future<void> _saveOfflineOrder(Box box, Map<String, dynamic> body) async {
    await box.put("offline_order_${DateTime.now().millisecondsSinceEpoch}", body);

  }

  /// 🔹 Sync Offline Orders when internet comes back
  Future<void> syncOfflineOrders() async {
    final box = HiveService().getSubmitOrderBox();
    final keys = box.keys.where((k) => k.toString().startsWith("offline_order_"));

    if (keys.isEmpty) return;

    final loginData = await SaveDataLocal.getDataFromLocal();
    final token = loginData?.token ?? '';
    if (token.isEmpty) return;

    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    for (var key in keys) {
      final body = box.get(key);

      try {
        final response = await _dio.post(
          apiEndpoints.submitOrder,
          data: jsonEncode(body),
          options: Options(headers: headers),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // 🔹 Delete offline order after successful sync
          await box.delete(key);
          print("✅ Synced offline order: $key");
        }
      } catch (e) {
        print("⚠️ Failed to sync $key: $e");
      }
    }
  }

}
