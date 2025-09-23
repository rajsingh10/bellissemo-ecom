import 'dart:async';

import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../utils/cachedNetworkImage.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  final double? height;
  final Duration autoScrollDuration;
  final bool autoScroll; // NEW: control auto-scroll

  const ImageSlider({
    super.key,
    required this.imageUrls,
    required this.height,
    this.autoScrollDuration = const Duration(seconds: 3),
    this.autoScroll = true, // default to true
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
        int nextPage = _pageController.page!.toInt() + 1;
        if (nextPage >= widget.imageUrls.length) nextPage = 0;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  /// Call this to stop auto-scroll
  void stopAutoScroll() {
    _timer?.cancel();
    _timer = null;
  }

  /// Call this to start auto-scroll
  void startAutoScroll() {
    stopAutoScroll(); // avoid multiple timers
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
                ? CustomNetworkImage(
                  imageUrl: widget.imageUrls.first,
                  height: double.infinity,
                  width: double.infinity,
                  isFit: true,
                  radius: 20,
                )
                : PageView.builder(
                  controller: _pageController,
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index) {
                    return CustomNetworkImage(
                      imageUrl: widget.imageUrls[index],
                      height: double.infinity,
                      width: double.infinity,
                      isFit: true,
                      radius: 20,
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
