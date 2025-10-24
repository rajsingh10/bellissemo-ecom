import 'dart:io';

import 'package:bellissemo_ecom/ui/login/modal/loginModal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../ApiCalling/response.dart';
import '../../../apiCalling/apiEndpoints.dart';
import '../../../apiCalling/sharedpreferance.dart';

class CategoriesProvider extends ChangeNotifier {
  Future<String?> getSavedLoginToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_token');
  }

  Future<http.Response> fetchCategoriesApi() async {
    String url = apiEndpoints.fetchCategories;
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

  Future<http.Response> fetchSubCategoriesApi(id) async {
    String url = "${apiEndpoints.fetchSubCategories}$id&per_page=100";
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

  Future<http.Response> fetchPdfFileApi(slug) async {
    String url = "${apiEndpoints.fetchPdfFile}$slug";
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
}
