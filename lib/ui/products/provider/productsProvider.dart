import 'dart:developer';
import 'dart:io';

import 'package:bellissemo_ecom/ui/login/modal/loginModal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../ApiCalling/response.dart';
import '../../../apiCalling/apiEndpoints.dart';
import '../../../apiCalling/sharedpreferance.dart';

class ProductsProvider extends ChangeNotifier {
  Future<http.Response> fetchProducts() async {
    String url = apiEndpoints.fetchProducts;
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

  Future<http.Response> productDetailsApi(id) async {
    String url = "${apiEndpoints.fetchProducts}/$id";
    log('Variation Url :: $url');
    LoginModal? loginData = await SaveDataLocal.getDataFromLocal();
    String token = loginData?.token ?? '';
    log("my token :: $token");
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

  Future<http.Response> categoryWiseProductsApi(id) async {
    String url = apiEndpoints.fetchCategoryWiseProducts + id;
    log('Category Wise Products Url :: $url');
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
