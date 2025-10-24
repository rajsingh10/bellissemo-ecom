import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Apicalling/sharedpreferance.dart';
import '../../../apiCalling/apiEndpoints.dart';
import '../../../apiCalling/checkInternetModule.dart';
import '../../../services/hiveServices.dart';

class UpdateAddressService {
  Future<String?> getSavedLoginToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_token');
  }

  final Dio _dio = Dio();

  // ----------------- Update Address -----------------
  Future<Response?> updateAddress({
    required Map<String, dynamic> billing,
    required Map<String, dynamic> shipping,
    required String id,
  }) async {
    final box = HiveService().getAddressBox();

    final Map<String, dynamic> body = {
      "billing": billing,
      "shipping": shipping,
      "id": id, // keep id in body too (helpful for offline sync)
    };

    print("📮 Address Body:\n${jsonEncode(body)}");

    // If no internet → save offline
    if (!await checkInternet()) {
      await box.put(
        "offline_address_${DateTime.now().millisecondsSinceEpoch}",
        body,
      );
      print("📮 Saved address offline (no internet)");
      return null;
    }

    try {
      final loginData = await SaveDataLocal.getDataFromLocal();
      String? token = await getSavedLoginToken();

      print("my token :: $token");
      if (token == null || token.isEmpty) {
        throw Exception('Token not found');
      }
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
      log('Hello : ${apiEndpoints.updateAddress}$id');
      final response = await _dio.put(
        "${apiEndpoints.updateAddress}$id", // id in URL
        data: jsonEncode({"billing": billing, "shipping": shipping}),
        options: Options(headers: headers),
      );
      log('Data : ${jsonEncode({"billing": billing, "shipping": shipping})}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        await box.put("address_latest", response.data);
      }

      return response;
    } catch (e) {
      await box.put(
        "offline_address_${DateTime.now().millisecondsSinceEpoch}",
        body,
      );
      print("📮 Saved offline due to error: $e");
      return null;
    }
  }

  // ----------------- Sync Offline Address -----------------
  Future<void> syncOfflineAddress() async {
    final box = HiveService().getAddressBox();
    final keys =
        box.keys
            .where((k) => k.toString().startsWith("offline_address_"))
            .toList();

    if (keys.isEmpty) return;

    for (var key in keys) {
      final body = box.get(key);

      try {
        final response = await updateAddress(
          billing: Map<String, dynamic>.from(body["billing"]),
          shipping: Map<String, dynamic>.from(body["shipping"]),
          id: body["id"].toString(), // <-- restore id from offline body
        );

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          print("✅ Offline address synced successfully");
          await box.delete(key);
        }
      } catch (e) {
        print("⚠️ Failed to sync address for id=${body["id"]}, Error: $e");
      }
    }
  }
}
