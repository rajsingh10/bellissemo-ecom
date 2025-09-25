import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bellissemo_ecom/utils/snackBars.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'colors.dart';

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
  String? url,
  BuildContext context,
  String filename,
  String extension, {
  Uint8List? fileBytes, // optional offline bytes
}) async {
  ValueNotifier<double> downloadProgress = ValueNotifier(0.0);

  try {
    Directory? downloadDir = await getDownloadDirectory();
    if (downloadDir == null) throw Exception("Download directory is null");

    Directory appDir = Directory('${downloadDir.path}/Bellissemo App');
    if (!appDir.existsSync()) appDir.createSync(recursive: true);

    String formattedTime = DateFormat(
      'yyyy-MM-dd-hh-mm-ss-a',
    ).format(DateTime.now());
    String filePath = '${appDir.path}/$filename - $formattedTime.$extension';

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ValueListenableBuilder<double>(
          valueListenable: downloadProgress,
          builder: (context, value, child) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text("Downloading File"),
              content: SizedBox(
                height: 160,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            color: Colors.grey.shade300,
                            strokeWidth: 10.0,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: value,
                            color: AppColors.mainColor,
                            strokeWidth: 10.0,
                          ),
                        ),
                        Text("${(value * 100).toStringAsFixed(0)}%"),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(filename, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (fileBytes != null) {
      // ✅ Offline: write bytes directly
      await File(filePath).writeAsBytes(fileBytes);
      downloadProgress.value = 1.0;
    } else {
      // ✅ Online: use Dio to download
      Dio dio = Dio(
        BaseOptions(headers: {"User-Agent": "Mozilla/5.0", "Accept": "*/*"}),
      );

      final cleanedUrl = url!.trim().replaceAll('%20', '');
      await dio.download(
        Uri.parse(cleanedUrl).toString(),
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) downloadProgress.value = received / total;
        },
      );
    }
    String cleanFilePath(String filePath) {
      return filePath.replaceFirst('/storage/emulated/0/', '');
    }

    if (Navigator.canPop(context)) Navigator.of(context).pop();
    showCustomSuccessSnackbar(
      title: 'File Downloaded',
      message: 'File Saved to ${cleanFilePath(filePath)}',
    );
    // print('file path : $filePath');
    // Fluttertoast.showToast(msg: "File downloaded: $filePath");
  } catch (e) {
    if (Navigator.canPop(context)) Navigator.of(context).pop();
    // Fluttertoast.showToast(msg: "Error occurred: $e");
    showCustomErrorSnackbar(
      title: 'Sorry',
      message:
          'There was an error while downloading the file please try again later...',
    );
  }
}

// Future<void> downloadFile(
//     String url,
//     BuildContext context,
//     String filename,
//     String extension,
//     ) async
// {
//   ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
//
//   try
//   {
//     // Request storage permissions
//     bool permissionGranted = await requestStoragePermission();
//     if (!permissionGranted && !Platform.isIOS) {
//       Fluttertoast.showToast(
//         msg: "Storage permission denied",
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//       log('Storage permission not granted');
//       return;
//     }
//
//     Dio dio = Dio(
//       BaseOptions(headers: {"User-Agent": "Mozilla/5.0", "Accept": "*/*"}),
//     );
//
//     Directory? downloadDir = await getDownloadDirectory();
//     if (downloadDir == null) throw Exception("Download directory is null");
//
//     Directory appDir = Directory('${downloadDir.path}/Bellissemo App');
//     if (!appDir.existsSync()) appDir.createSync(recursive: true);
//
//     String formattedTime = DateFormat('yyyy-MM-dd-hh-mm-ss-a').format(DateTime.now());
//     String filePath = '${appDir.path}/$filename-$formattedTime.$extension';
//
//     // Show polished circular progress dialog
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (context) {
//         return ValueListenableBuilder<double>(
//           valueListenable: downloadProgress,
//           builder: (context, value, child) {
//             return AlertDialog(
//               backgroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               title: Text(
//                 "Downloading File",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontFamily: FontFamily.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               content: SizedBox(
//                 height: 160,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         SizedBox(
//                           width: 80,
//                           height: 80,
//                           child: CircularProgressIndicator(
//                             value: 1.0,
//                             color: Colors.grey.shade300,
//                             strokeWidth: 10.0,
//                           ),
//                         ),
//                         SizedBox(
//                           width: 80,
//                           height: 80,
//                           child: CircularProgressIndicator(
//                             value: value,
//                             color: AppColors.mainColor,
//                             strokeWidth: 10.0,
//                           ),
//                         ),
//                         Text(
//                           "${(value * 100).toStringAsFixed(0)}%",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       filename,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.black87,
//                         fontFamily: FontFamily.regular,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//
//     // Clean and encode URL
//     String cleanedUrl = url.trim().replaceAll('%20', '');
//     final encodedUrl = Uri.parse(cleanedUrl).toString();
//
//     await dio.download(
//       encodedUrl,
//       filePath,
//       onReceiveProgress: (received, total) {
//         if (total != -1) {
//           downloadProgress.value = received / total;
//         }
//       },
//     );
//
//     if (Navigator.canPop(context)) Navigator.of(context).pop(); // Close dialog
//
//     Fluttertoast.showToast(
//       msg: "File downloaded successfully: $filePath",
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.green,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//     log("✅ File successfully downloaded at: $filePath");
//   } catch (e, stackTrace) {
//     if (Navigator.canPop(context)) Navigator.of(context).pop(); // Close dialog
//
//     Fluttertoast.showToast(
//       msg: "Error occurred: $e",
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.red,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//     log("❌ Download error: $e", stackTrace: stackTrace);
//   }
// }
