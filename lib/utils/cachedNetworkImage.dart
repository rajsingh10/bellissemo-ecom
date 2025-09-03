import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'images.dart';

class CustomNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double width;
  final double radius;
  final bool isProfile;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.width,
    this.radius = 0,
    this.isProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl ?? '',
      imageBuilder: (context, imageProvider) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          shape: radius == 0 ? BoxShape.rectangle : BoxShape.circle,
          borderRadius:
          radius == 0 ? BorderRadius.circular(0) : BorderRadius.circular(radius),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => SizedBox(
        height: height,
        width: width,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Image.asset(
        isProfile ? Imgs.defaultprofile : Imgs.defaultimage,
        height: height,
        width: width,
        fit: BoxFit.cover,
      ),
    );
  }
}
