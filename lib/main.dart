import 'dart:math';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService().init();
  ConnectivityManager().startListening();
  if (await checkInternet()) {
    await CartService().syncOfflineCart();
    await CartService().syncOfflineActions();
    await CartService().syncOfflineUpdate();
    await CartService().syncAppliedDiscounts();
    await CartService().syncOfflinePriceUpdate();
    await OrderHistoryProvider().syncReOrders();
    await UpdateAddressService().syncOfflineAddress();
    await CartService().syncOfflineOrders();
  }
  runApp(const OrientationHandler());
}

class OrientationHandler extends StatefulWidget {
  const OrientationHandler({super.key});

  @override
  State<OrientationHandler> createState() => _OrientationHandlerState();
}

class _OrientationHandlerState extends State<OrientationHandler> {
  bool _orientationSet = false;

  @override
  void initState() {
    super.initState();
    // Set initial orientation to portrait to avoid layout issues
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_orientationSet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setOrientation();
      });
    }
  }

  void _setOrientation() async {
    final size = MediaQuery.of(context).size;
    final diagonal = sqrt(size.width * size.width + size.height * size.height);

    print("Display diagonal: $diagonal");

    final isTablet = diagonal >= 1100; // Customize threshold as needed
    print("Is Tablet: $isTablet");

    if (isTablet) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    setState(() {
      _orientationSet = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_orientationSet) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return const MyApp();
  }
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
          ),
          home: const GreetingsScreen(),
        );
      },
    );
  }
}
