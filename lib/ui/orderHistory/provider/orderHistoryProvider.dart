import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../ApiCalling/response.dart';
import '../../../apiCalling/apiEndpoints.dart';
import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';

class OrderHistoryProvider extends ChangeNotifier {
  static final Dio _dio = Dio();

  Future<String?> getSavedLoginToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_token');
  }

  Future<http.Response> fetchOrders(id) async {
    String url = "${apiEndpoints.orderHistory}$id&per_page=100&page=1";
    // LoginModal? loginData = await SaveDataLocal.getDataFromLocal();
    String? token = await getSavedLoginToken();

    print("my token :: $token");
    if (token == null || token.isEmpty) {
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

  // 🔹 ReOrder Function
  static Future<Response?> reOrder({
    required int orderId,
    required int itemId,

    bool isSync = false,
  }) async {
    final box = HiveService().getreOrderBox(); // <-- ReOrder box
    if (!box.isOpen) await HiveService().init();

    // ---------------- OFFLINE ----------------
    if (!await checkInternet()) {
      if (!isSync) {
        await box
            .put("offline_reorder_${DateTime.now().millisecondsSinceEpoch}", {
              "action": "reorder",
              "order_id": orderId,
              "item_id": itemId,
              "timestamp": DateTime.now().toIso8601String(),
            });
        print("⚠️ Offline: queued reorder → order:$orderId item:$itemId");
      }
      return null;
    }

    // ---------------- ONLINE ----------------
    try {
      // final loginData = await SaveDataLocal.getDataFromLocal();
      String? token = await SaveDataLocal1.getSavedLoginToken();

      print("my token :: $token");
      if (token == null || token.isEmpty) {
        throw Exception('Token not found');
      }

      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final body = {"order_id": orderId, "item_id": itemId};

      final response = await _dio.post(
        apiEndpoints.reorderApi,
        data: jsonEncode(body),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ ReOrder success → order:$orderId item:$itemId");
      }

      return response;
    } catch (e) {
      if (!isSync) {
        await box
            .put("offline_reorder_${DateTime.now().millisecondsSinceEpoch}", {
              "action": "reorder",
              "order_id": orderId,
              "item_id": itemId,
              "timestamp": DateTime.now().toIso8601String(),
            });
        print(
          "⚠️ Failed online, saved reorder offline → order:$orderId item:$itemId",
        );
      }
      return null;
    }
  }

  // 🔹 Sync Offline ReOrders
  Future<void> syncReOrders() async {
    final box = HiveService().getreOrderBox();

    if (!await checkInternet()) {
      print("🚫 No internet, reorder sync skipped.");
      return;
    }

    final keys =
        box.keys
            .where((k) => k.toString().startsWith("offline_reorder_"))
            .toList();

    if (keys.isEmpty) {
      print("✅ No offline reorders to sync.");
      return;
    }

    print("🔄 Syncing ${keys.length} offline reorders...");

    for (final key in keys) {
      final data = box.get(key);

      if (data != null && data["order_id"] != null && data["item_id"] != null) {
        final orderId = data["order_id"];
        final itemId = data["item_id"];

        final response = await reOrder(
          orderId: orderId,
          itemId: itemId,
          isSync: true,
        );

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          await box.delete(key);
          print("☑️ ReOrder synced & removed → order:$orderId item:$itemId");
        } else {
          print("⚠️ ReOrder sync failed for → order:$orderId item:$itemId");
        }
      }
    }
  }
}

class SaveDataLocal1 {
  static Future<String?> getSavedLoginToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_token');
  }
}
