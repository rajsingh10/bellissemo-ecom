import 'package:connectivity_plus/connectivity_plus.dart';

import '../ui/cart/service/cartServices.dart';
import 'checkInternetModule.dart';

class ConnectivityManager {
  static final ConnectivityManager _instance = ConnectivityManager._internal();

  factory ConnectivityManager() => _instance;

  ConnectivityManager._internal();

  void startListening() {
    Connectivity().onConnectivityChanged.listen((status) async {
      if (await checkInternet()) {
        // Internet is back → sync offline cart
        await CartService().syncOfflineCart();
      }
    });
  }
}
