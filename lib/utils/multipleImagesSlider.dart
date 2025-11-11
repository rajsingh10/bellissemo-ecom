import 'dart:async';

import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../utils/cachedNetworkImage.dart';

// class ImageSlider extends StatefulWidget {
//   final List<String> imageUrls;
//   final double? height;
//   final Duration autoScrollDuration;
//   final bool autoScroll; // NEW: control auto-scroll
//
//   const ImageSlider({
//     super.key,
//     required this.imageUrls,
//     required this.height,
//     this.autoScrollDuration = const Duration(seconds: 3),
//     this.autoScroll = true, // default to true
//   });
//
//   @override
//   State<ImageSlider> createState() => _ImageSliderState();
// }

// class _ImageSliderState extends State<ImageSlider> {
//   final PageController _pageController = PageController();
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _setupAutoScroll();
//   }
//
//   void _setupAutoScroll() {
//     if (widget.autoScroll && widget.imageUrls.length > 1) {
//       _timer = Timer.periodic(widget.autoScrollDuration, (timer) {
//         int nextPage = _pageController.page!.toInt() + 1;
//         if (nextPage >= widget.imageUrls.length) nextPage = 0;
//         _pageController.animateToPage(
//           nextPage,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//         );
//       });
//     }
//   }
//
//   /// Call this to stop auto-scroll
//   void stopAutoScroll() {
//     _timer?.cancel();
//     _timer = null;
//   }
//
//   /// Call this to start auto-scroll
//   void startAutoScroll() {
//     stopAutoScroll(); // avoid multiple timers
//     _setupAutoScroll();
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: widget.height,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(24),
//         child: Stack(
//           alignment: Alignment.bottomCenter,
//           children: [
//             widget.imageUrls.length == 1
//                 ? CustomNetworkImage(
//                   imageUrl: widget.imageUrls.first,
//                   height: double.infinity,
//                   width: double.infinity,
//                   isFit: true,
//                   radius: 20,
//                 )
//                 : PageView.builder(
//                   controller: _pageController,
//                   itemCount: widget.imageUrls.length,
//                   itemBuilder: (context, index) {
//                     return CustomNetworkImage(
//                       imageUrl: widget.imageUrls[index],
//                       height: double.infinity,
//                       width: double.infinity,
//                       isFit: true,
//                       radius: 20,
//                     );
//                   },
//                 ),
//             if (widget.imageUrls.length > 1)
//               Positioned(
//                 bottom: 10,
//                 child: SmoothPageIndicator(
//                   controller: _pageController,
//                   count: widget.imageUrls.length,
//                   effect: ExpandingDotsEffect(
//                     dotHeight: 8,
//                     dotWidth: 8,
//                     activeDotColor: AppColors.mainColor,
//                     dotColor: Colors.black54,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class ImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  final double? height;
  final Duration autoScrollDuration;
  final bool autoScroll;
  final Function(int)? onImageTap; // ✅ Added this line

  const ImageSlider({
    super.key,
    required this.imageUrls,
    required this.height,
    this.autoScrollDuration = const Duration(seconds: 3),
    this.autoScroll = true,
    this.onImageTap, // ✅ Added this too
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupAutoScroll();
  }

  void _setupAutoScroll() {
    if (widget.autoScroll && widget.imageUrls.length > 1) {
      _timer = Timer.periodic(widget.autoScrollDuration, (timer) {
        int nextPage = _pageController.page?.toInt() ?? 0;
        nextPage++;
        if (nextPage >= widget.imageUrls.length) nextPage = 0;
        if (mounted) {
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void stopAutoScroll() {
    _timer?.cancel();
    _timer = null;
  }

  void startAutoScroll() {
    stopAutoScroll();
    _setupAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            widget.imageUrls.length == 1
                ? GestureDetector(
                  onTap: () => widget.onImageTap?.call(0), // ✅ Added
                  child: CustomNetworkImage(
                    imageUrl: widget.imageUrls.first,
                    height: double.infinity,
                    width: double.infinity,
                    isFit: true,
                    radius: 20,
                  ),
                )
                : PageView.builder(
                  controller: _pageController,
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => widget.onImageTap?.call(index), // ✅ Added
                      child: CustomNetworkImage(
                        imageUrl: widget.imageUrls[index],
                        height: double.infinity,
                        width: double.infinity,
                        isFit: true,
                        radius: 20,
                      ),
                    );
                  },
                ),
            if (widget.imageUrls.length > 1)
              Positioned(
                bottom: 10,
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.imageUrls.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: AppColors.mainColor,
                    dotColor: Colors.black54,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ImageSlider1 extends StatelessWidget {
  final List<String> imageUrls;
  final double height;
  final bool autoScroll;
  final Function(int)? onImageTap;

  const ImageSlider1({
    super.key,
    required this.imageUrls,
    required this.height,
    this.autoScroll = false,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onImageTap?.call(index),
            child: CachedNetworkImage(
              imageUrl: imageUrls[index],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          );
        },
      ),
    );
  }
}

class FullScreenImageDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageDialog({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageDialog> createState() => _FullScreenImageDialogState();
}

class _FullScreenImageDialogState extends State<FullScreenImageDialog> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: AppColors.blackColor.withValues(alpha: 0.2),
          child: PhotoViewGallery.builder(
            itemCount: widget.images.length,
            pageController: _pageController,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.images[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            backgroundDecoration: BoxDecoration(
              color: AppColors.blackColor.withValues(alpha: 0.2),
            ),
            onPageChanged: (index) => setState(() => currentIndex = index),
          ),
        ),

        // 🔹 Close button
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // 🔹 Optional bottom indicator
        if (widget.images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "${currentIndex + 1}/${widget.images.length}",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }
}
