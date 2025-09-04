import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../utils/cachedNetworkImage.dart';

class ProductImageTile extends StatefulWidget {
  final List<String> imageUrls;

  const ProductImageTile({super.key, required this.imageUrls});

  @override
  State<ProductImageTile> createState() => _ProductImageTileState();
}

class _ProductImageTileState extends State<ProductImageTile> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28.h,
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

            /// Dots Indicator
            if (widget.imageUrls.length > 1)
              Positioned(
                bottom: 10,
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.imageUrls.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: Colors.white,
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
