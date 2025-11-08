// lib/main.dart
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:bellissemo_ecom/services/hiveServices.dart';
import 'package:bellissemo_ecom/ui/cart/service/cartServices.dart';
import 'package:bellissemo_ecom/ui/customers/services/addressService.dart';
import 'package:bellissemo_ecom/ui/greetingsScreen.dart';
import 'package:bellissemo_ecom/ui/orderHistory/provider/orderHistoryProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'apiCalling/checkInternetModule.dart';
import 'apiCalling/connectivityManager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Decide device class BEFORE runApp (iOS requires this to honor orientation) ---
  final view =
      ui.PlatformDispatcher.instance.implicitView ??
      ui.PlatformDispatcher.instance.views.first;
  final logicalSize = view.physicalSize / view.devicePixelRatio;
  final diagonal = math.sqrt(
    logicalSize.width * logicalSize.width +
        logicalSize.height * logicalSize.height,
  );

  // Adjust threshold if you prefer a different tablet cutoff.
  const tabletDiagonalThreshold = 1100.0;
  final isTablet = diagonal >= tabletDiagonalThreshold;

  // Set orientation ONCE before presenting any UI (avoids UISceneErrorDomain Code=101).
  await SystemChrome.setPreferredOrientations(
    isTablet
        ? <DeviceOrientation>[
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]
        : <DeviceOrientation>[
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
  );

  // Optional: keep status/nav bars as normal (no immersive mode changes).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // --- Your startup work ---
  await HiveService().init();
  ConnectivityManager().startListening();

  if (await checkInternet()) {
    await CartService().syncOfflineCart();
    await CartService().syncOfflineCart1();
    await CartService().syncOfflineActions();
    await CartService().syncOfflineActions1();
    await CartService().syncOfflineUpdate();
    await CartService().syncAppliedDiscounts();
    await CartService().syncOfflinePriceUpdate();
    await CartService().syncOfflineAddCustomers();
    await OrderHistoryProvider().syncReOrders();
    await UpdateAddressService().syncOfflineAddress();
    await CartService().syncOfflineOrders();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          title: 'Bellissemo App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            primarySwatch: Colors.blue,
            useMaterial3: false, // set true if your app is Material 3-ready
          ),
          home: const GreetingsScreen(),
        );
      },
    );
  }
}
