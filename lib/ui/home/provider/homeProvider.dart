import 'dart:convert';
import 'dart:io';

import 'package:bellissemo_ecom/ui/login/modal/loginModal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../ApiCalling/response.dart';
import '../../../apiCalling/apiEndpoints.dart';
import '../../../apiCalling/sharedpreferance.dart';

class HomeProvider extends ChangeNotifier {
  Future<String?> getSavedLoginToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_token');
  }
  Future<http.Response> fetchBanners() async {
    String url = apiEndpoints.banners;
    LoginModal? loginData = await SaveDataLocal.getDataFromLocal();
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
  Future<http.Response> refreshToken(

      Map<String, String> bodyData,
      ) async {
    String url = apiEndpoints.refreshToken;
    print("📡 POST URL: $url");
    print("📦 Body Data: $bodyData");




    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http
          .post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(bodyData),
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw const SocketException('Request timed out');
        },
      );

      print("✅ Response Status: ${response.statusCode}");
      print("📩 Response Body: ${response.body}");

      return response;
    } catch (e, s) {
      print("🔥 Exception: $e");
      print("📌 Stacktrace: $s");
      rethrow;
    }
  }

}
