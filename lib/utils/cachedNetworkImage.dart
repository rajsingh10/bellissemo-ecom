import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'images.dart';

class CustomNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double width;
  final double radius;
  final bool isCircle; // ✅ Added separate flag for circle
  final bool isFit; // ✅ Added separate flag for circle
  final bool isProfile;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.width,
    this.radius = 0,
    this.isCircle = false, // default is rectangle with radius
    this.isFit = true, // default is rectangle with radius
    this.isProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl ?? '',
      imageBuilder:
          (context, imageProvider) => Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              // ✅ Use circle OR rectangle with dynamic radius
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCircle ? null : BorderRadius.circular(radius),
              image: DecorationImage(
                image: imageProvider,
                fit: isFit ? BoxFit.cover : BoxFit.contain,
              ),
            ),
          ),
      placeholder:
          (context, url) => SizedBox(
            height: height,
            width: width,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                backgroundColor: AppColors.mainColor,
              ),
            ),
          ),
      errorWidget: (context, url, error) {
        debugPrint("❌ Image load failed: $url, error: $error");
        return Image.asset(
          isProfile ? Imgs.defaultProfile : Imgs.defaultImage,
          height: height,
          width: width,
        );
      },
    );
  }
}
