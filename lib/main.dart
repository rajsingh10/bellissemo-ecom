import 'dart:math';

import 'package:bellissemo_ecom/ui/login/view/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Start the app; orientation will be set after the first frame
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
    // Initial default orientation
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

    print("Display diagonal is: $diagonal");

    final isTablet = diagonal >= 1100;
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
          home: const LoginScreen(),
        );
      },
    );
  }
}
