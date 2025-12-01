import 'dart:convert';
import 'dart:io';

import 'package:bellissemo_ecom/ui/login/modal/loginModal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../ApiCalling/response.dart';
import '../../../apiCalling/apiEndpoints.dart';
import '../../../apiCalling/sharedpreferance.dart';

class CustomerProvider extends ChangeNotifier {
  Future<String?> getSavedLoginToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_token');
  }

  Future<http.Response> fetchCustomers() async {
    String url = apiEndpoints.fetchCustomers;
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
  Future<http.Response> fetchCustomerReport({
    required int customerId,
    required String fromDate,
    required String toDate,
    required String groupBy, // monthly, yearly, quarterly
  }) async {
    String url = apiEndpoints.fetchCustomersreport;

    LoginModal? loginData = await SaveDataLocal.getDataFromLocal();
    String? token = await getSavedLoginToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token not found');
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    Map<String, dynamic> body = {
      "customer_id": customerId,
      "from_date": fromDate,
      "to_date": toDate,
      "group_by": groupBy
    };

    print("URL => $url");
    print("BODY => $body");

    final response = await http
        .post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    )
        .timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const SocketException('Request Timeout');
      },
    );

    return responses(response);
  }

  Future<http.Response> productReport({

    required String fromDate,
    required String toDate,
    required String groupBy, // monthly, yearly, quarterly
  }) async {
    String url = apiEndpoints.fetchProductreport;

    LoginModal? loginData = await SaveDataLocal.getDataFromLocal();
    String? token = await getSavedLoginToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token not found');
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    Map<String, dynamic> body = {
      "from_date": fromDate,
      "to_date": toDate,
      "group_by": "monthly" // monthly, yearly, quarterly
    };

    print("URL => $url");
    print("BODY => $body");

    final response = await http
        .post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    )
        .timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const SocketException('Request Timeout');
      },
    );

    return responses(response);
  }
  Future<http.Response> Customerdetailapi(cid) async {
    String url = "${apiEndpoints.customerdetailapi}$cid";
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

  Future<http.Response> deleteDailyData(String id) async {
    String url = "${apiEndpoints.deletecustmer}$id";
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
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Delete DailyData Status: ${response.statusCode}");
      print("Delete DailyData Body: ${response.body}");

      return response;
    } catch (e) {
      throw Exception("❌ Exception in deleteDailyData: $e");
    }
  }
}
