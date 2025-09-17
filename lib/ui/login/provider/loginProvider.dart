import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../ApiCalling/response.dart';
import '../../../apiCalling/apiEndpoints.dart';

class LoginProvider extends ChangeNotifier {
  Future<http.Response> loginapi(Map<String, String> bodyData) async {
    String url = apiEndpoints.login;
    print(url);
    var responseJson;
    final response = await http
        .post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode(bodyData),
        )
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
