import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'fontFamily.dart';

Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    if (await _isAndroid13orAbove()) {
      // Request permissions for Android 13 and above
      var imageResult = await Permission.photos.request();
      var videoResult = await Permission.videos.request();
      var audioResult = await Permission.audio.request();

      return imageResult.isGranted &&
          videoResult.isGranted &&
          audioResult.isGranted;
    } else {
      // For Android 12 and below
      var status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        // Handle "Don't ask again" scenario
        openAppSettings();
      }
    }
  } else if (Platform.isIOS) {
    // iOS does not require explicit storage permissions
    return true;
  }
  return false;
}

// Check if the device is Android 13 or above
Future<bool> _isAndroid13orAbove() async {
  return (await DeviceInfoPlugin().androidInfo).version.sdkInt >= 33;
}

// Get the appropriate download directory
Future<Directory?> getDownloadDirectory() async {
  if (Platform.isAndroid) {
    return Directory(
      '/storage/emulated/0/Download',
    ); // Android Downloads folder
  } else if (Platform.isIOS) {
    return await getApplicationDocumentsDirectory(); // iOS Documents directory
  }
  return null;
}

Future<void> downloadFile(
  String url,
  BuildContext context,
  String filename,
  String extension,
) async {
  try {
    print('Download requested. URL: $url');
    print('File: $filename.$extension');

    bool permissionGranted = await requestStoragePermission();

    if (!permissionGranted && !Platform.isIOS) {
      Fluttertoast.showToast(
        msg: "Storage permission denied",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      log('Storage permission not granted');
      return;
    }

    Dio dio = Dio(BaseOptions(headers: {
      "User-Agent": "Mozilla/5.0",
      "Accept": "*/*",
    }));
    Directory? downloadDir = await getDownloadDirectory();

    if (downloadDir == null) {
      throw Exception("Download directory is null");
    }

    Directory appDir = Directory('${downloadDir.path}/Advice Center');
    if (!appDir.existsSync()) {
      appDir.createSync(recursive: true);
      log('Created directory: ${appDir.path}');
    }

    String formattedTime =
        DateFormat('yyyy-MM-dd-hh-mm-ss-a').format(DateTime.now());
    String filePath = '${appDir.path}/$filename-$formattedTime.$extension';

    ValueNotifier<double> downloadProgress = ValueNotifier(0.0);

    bool dialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return ValueListenableBuilder<double>(
          valueListenable: downloadProgress,
          builder: (context, value, child) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor: const Color(0xff232323),
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff232323),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Downloading File",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontFamily: FontFamily.regular,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            color: Colors.grey.shade200,
                            strokeWidth: 6.0,
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: value,
                            color: Colors.green,
                            strokeWidth: 6.0,
                          ),
                        ),
                        Text(
                          "${(value * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    String cleanedUrl = url.trim().replaceAll('%20', '');

    final encodedUrl = Uri.parse(cleanedUrl).toString();
    log("encodedUrl = $encodedUrl");
    await dio.download(
      encodedUrl,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          downloadProgress.value = received / total;
          log('Download progress: ${(received / total * 100).toStringAsFixed(2)}%');
        }
      },
    );
    if (dialogOpen) Navigator.of(context).pop();

    Fluttertoast.showToast(
      msg: "File downloaded successfully: $filePath",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    log("✅ File successfully downloaded at: $filePath");
  } catch (e, stackTrace) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop(); // Only pop if dialog is shown
    }

    Fluttertoast.showToast(
      msg: "Error occurred: $e",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    log("❌ Download error: $e", stackTrace: stackTrace);
  }
}

Future<void> downloadFileWithCookies(
  String url,
  BuildContext context,
  String filename,
  String extension,
  String? cookies,
) async {
  try {
    bool permissionGranted = await requestStoragePermission();
    if (!permissionGranted && !Platform.isIOS) return;

    Dio dio = Dio(BaseOptions(headers: {
      "User-Agent": "Mozilla/5.0",
      "Accept": "*/*",
      if (cookies != null) "Cookie": cookies,
    }));

    Directory? downloadDir = await getDownloadDirectory();
    if (downloadDir == null) throw Exception("Download directory is null");

    Directory appDir = Directory('${downloadDir.path}/Advice Center');
    if (!appDir.existsSync()) appDir.createSync(recursive: true);

    String formattedTime =
        DateFormat('yyyy-MM-dd-hh-mm-ss-a').format(DateTime.now());
    String filePath = '${appDir.path}/$filename-$formattedTime.$extension';

    ValueNotifier<double> downloadProgress = ValueNotifier(0.0);

    // Show Progress Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return ValueListenableBuilder<double>(
          valueListenable: downloadProgress,
          builder: (context, value, _) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor: const Color(0xff232323),
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff232323),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Downloading File",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Optional light background circle
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            color: Colors.grey.withOpacity(0.3),
                            strokeWidth: 6.0,
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: value,
                            color: Colors.green,
                            strokeWidth: 6.0,
                          ),
                        ),
                        Text(
                          "${(value * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    await dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          downloadProgress.value = received / total;
        }
      },
    );

    if (Navigator.canPop(context)) Navigator.pop(context);

    Fluttertoast.showToast(
      msg: "File Downloaded to: $filePath",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
    log("✅ File downloaded to: $filePath");
  } catch (e, s) {
    if (Navigator.canPop(context)) Navigator.pop(context);
    Fluttertoast.showToast(
      msg: "Download failed: $e",
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    log("❌ Download error: $e", stackTrace: s);
  }
}

// // Download file with progress dialog
// Future<void> downloadFile(
//   String url,
//   BuildContext context,
//   String filename,
//   String extension,
// ) async
// {
//   try {
//     print('Url is : $url');
//     print('File is : $filename.$extension');
//
//     bool permissionGranted = await requestStoragePermission();
//
//     if (permissionGranted || Platform.isIOS) {
//       Dio dio = Dio();
//       Directory? downloadDir = await getDownloadDirectory();
//
//       if (downloadDir == null) {
//         throw Exception("Downloads directory not found");
//       }
//
//       // Create a specific folder for your app inside the Downloads directory
//       Directory appDir = Directory('${downloadDir.path}/Advice Center');
//       if (!appDir.existsSync()) {
//         appDir.createSync(recursive: true);
//       }
//
//       // Generate a unique filename with timestamp
//       String formattedTime = DateFormat(
//         'yyyy-MM-dd-hh-mm-ss-a',
//       ).format(DateTime.now());
//       String filePath = '${appDir.path}/$filename-$formattedTime.$extension';
//
//       // Create a ValueNotifier to track download progress
//       ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
//
//       // Show the progress dialog with current file name and progress
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return ValueListenableBuilder<double>(
//             valueListenable: downloadProgress,
//             builder: (context, value, child) {
//               return Dialog(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 backgroundColor: Color(0xff232323),
//                 child: Container(
//                   width: 300,
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Color(0xff232323),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Downloading File",
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.white,
//                           fontFamily: FontFamily.regular,
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           SizedBox(
//                             width: 60,
//                             height: 60,
//                             child: CircularProgressIndicator(
//                               value: 1.0,
//                               // Full circle for background
//                               color: Colors.grey.shade200,
//                               strokeWidth: 6.0,
//                             ),
//                           ),
//                           SizedBox(
//                             width: 60,
//                             height: 60,
//                             child: CircularProgressIndicator(
//                               value: value,
//                               color: Colors.green,
//                               strokeWidth: 6.0,
//                             ),
//                           ),
//                           Text(
//                             "${(value * 100).toStringAsFixed(0)}%",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       );
//
//       // Download the file and track progress
//       await dio.download(
//         url,
//         filePath,
//         onReceiveProgress: (received, total) {
//           if (total != -1) {
//             downloadProgress.value = received / total;
//           }
//         },
//       );
//
//       // Close the progress dialog once download completes
//       Navigator.of(context).pop();
//
//       // Show success toast message
//       Fluttertoast.showToast(
//         msg: "File downloaded successfully: $filePath",
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.green,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//       log("File downloaded at : $filePath");
//     } else {
//       // Handle permission denial
//       Fluttertoast.showToast(
//         msg: "Storage permission denied",
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//     }
//   } catch (e) {
//     // Close the progress dialog if an error occurs
//     Navigator.of(context).pop();
//
//     // Show error toast message
//     Fluttertoast.showToast(
//       msg: "Error: $e",
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.red,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }
// }
