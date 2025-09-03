import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'CustomExpection.dart';

responses(http.Response response) {
  print("Response Status: ${response.statusCode}");

  switch (response.statusCode) {
    case 200:
      {
        try {
          if (response.body.isNotEmpty) {
            final decoded = jsonDecode(response.body);
            if (decoded is Map && decoded['statusCode'] == 101) {
              // Optional: Clear user data
              // SaveDataLocal.clearUserData();
            }
            return response;
          } else {
            throw FetchDataException('Empty response body');
          }
        } catch (e) {
          throw FetchDataException('Invalid JSON response: $e');
        }
      }
    case 400:
    case 422:
    case 409:
    case 404:
      return response;

    case 401:
    case 403:
      throw UnauthorisedException(response.body.toString());

    case 429:
      Get.snackbar(
        "Server Unavailable",
        "Servers are unavailable. Please try again later.",
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      throw response;

    case 500:
    default:
      throw FetchDataException(
        'Server error. StatusCode: ${response.statusCode}',
      );
  }
}
