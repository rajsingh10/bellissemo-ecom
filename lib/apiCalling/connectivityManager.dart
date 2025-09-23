import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../ui/cart/service/cartServices.dart';
import 'checkInternetModule.dart';

class ConnectivityManager {
  static final ConnectivityManager _instance = ConnectivityManager._internal();

  factory ConnectivityManager() => _instance;

  ConnectivityManager._internal();

  void startListening() {
    Timer? debounce;
    Connectivity().onConnectivityChanged.listen((status) async {
      if (debounce?.isActive ?? false) debounce!.cancel();
      debounce = Timer(Duration(seconds: 2), () async {
        if (await checkInternet()) {
          await CartService().syncOfflineCart();
          await CartService().syncOfflineActions();
        }
      });
    });
  }
}
