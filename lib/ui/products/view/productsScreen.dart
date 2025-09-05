import 'package:bellissemo_ecom/ui/products/view/productDetailsScreen.dart';
import 'package:bellissemo_ecom/utils/colors.dart';
import 'package:bellissemo_ecom/utils/customBottombar.dart';
import 'package:bellissemo_ecom/utils/emptyWidget.dart';
import 'package:bellissemo_ecom/utils/fontFamily.dart';
import 'package:bellissemo_ecom/utils/searchFields.dart';
import 'package:bellissemo_ecom/utils/snackBars.dart';
import 'package:bellissemo_ecom/utils/titlebarWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/cachedNetworkImage.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int itemsPerPage = 4;
  int currentPage = 0;

  final List<int> itemsPerPageOptions = [4, 8, 12, 16];
  List<Product> filteredProducts = [];

  String selectedSort = "Low to High";
  final List<String> sortOptions = ["Low to High", "High to Low", "Latest"];

  final List<Product> products = [
    Product(
      name: "L'Oreal Paris Lipstick",
      imageUrl:
          'https://static.beautytocare.com/media/catalog/product/l/-/l-oreal-paris-color-riche-intense-volume-matte-lipstick-480.jpg',
      packSize: "Pack of 3",
      pricePerUnit: 29.0,
      inStock: true,
    ),
    Product(
      name: "Maybelline Foundation",
      imageUrl:
          'https://m.media-amazon.com/images/I/51uTj0beKCL._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 2",
      pricePerUnit: 35.0,
      inStock: true,
    ),
    Product(
      name: "Revlon Nail Polish",
      imageUrl: 'https://m.media-amazon.com/images/I/41qteOLxDHL.jpg',
      packSize: "Pack of 5",
      pricePerUnit: 25.0,
      inStock: true,
    ),
    Product(
      name: "Nykaa Kajal",
      imageUrl:
          'https://m.media-amazon.com/images/I/719eSwDuU7L._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 4",
      pricePerUnit: 15.0,
      inStock: true,
    ),
    Product(
      name: "Lakme Blush",
      imageUrl:
          'https://m.media-amazon.com/images/I/71+yE3132GL._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 4",
      pricePerUnit: 35.0,
      inStock: true,
    ),
    Product(
      name: "Huda Beauty Eyeshadow Palette",
      imageUrl:
          'https://cdn.fynd.com/v2/falling-surf-7c8bb8/fyprod/wrkr/products/pictures/item/free/original/000000000493860578/gAgZSjYsd2-000000000493860578_1.png',
      packSize: "Pack of 1",
      pricePerUnit: 49.0,
      inStock: true,
    ),
    Product(
      name: "MAC Lip Gloss",
      imageUrl:
          'https://m.media-amazon.com/images/I/418ynFWAe4L._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 2",
      pricePerUnit: 32.0,
      inStock: false,
    ),
    Product(
      name: "Nykaa Matte Lipstick",
      imageUrl:
          'https://m.media-amazon.com/images/I/71hUeZd546L._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 3",
      pricePerUnit: 27.0,
      inStock: true,
    ),
    Product(
      name: "Lakme Eyeliner",
      imageUrl:
          'https://www.lakmeindia.com/cdn/shop/files/24894_S1-8901030979552_1000x.jpg?v=1709807079',
      packSize: "Pack of 2",
      pricePerUnit: 18.0,
      inStock: true,
    ),
    Product(
      name: "Maybelline Lip Liner",
      imageUrl:
          'https://m.media-amazon.com/images/I/71Y+L4lMHWL._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 3",
      pricePerUnit: 22.0,
      inStock: true,
    ),
    Product(
      name: "Revlon Face Powder",
      imageUrl:
          'https://m.media-amazon.com/images/I/71JgzO1Pp5L._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 2",
      pricePerUnit: 30.0,
      inStock: false,
    ),
    Product(
      name: "L'Oreal Mascara",
      imageUrl:
          'https://m.media-amazon.com/images/I/61vuiK6d7RL._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 1",
      pricePerUnit: 28.0,
      inStock: true,
    ),
    Product(
      name: "Himalaya Lip Balm",
      imageUrl:
          'https://www.jiomart.com/images/product/original/491061263/himalaya-lip-care-balm-strawberry-shine-4-5-g-product-images-o491061263-p590087371-0-202203150923.jpg',
      packSize: "Pack of 3",
      pricePerUnit: 10.0,
      inStock: true,
    ),
    Product(
      name: "Nykaa Compact Powder",
      imageUrl:
          'https://m.media-amazon.com/images/I/41B-IgO4X2L._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 1",
      pricePerUnit: 24.0,
      inStock: true,
    ),
    Product(
      name: "Colorbar Lipstick",
      imageUrl:
          'https://m.media-amazon.com/images/I/61btigSPLML._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 2",
      pricePerUnit: 26.0,
      inStock: true,
    ),
    Product(
      name: "Forest Essentials Face Cream",
      imageUrl:
          'https://m.media-amazon.com/images/I/61mNSEOhpuL._UF1000,1000_QL80_.jpg',
      packSize: "Pack of 1",
      pricePerUnit: 40.0,
      inStock: true,
    ),
  ];
  bool isSearchEnabled = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredProducts = List.from(products);

    searchController.addListener(() {
      _filterProducts(searchController.text);
    });
  }

  void _filterProducts([String query = ""]) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = List.from(products);
      } else {
        filteredProducts =
            products
                .where(
                  (p) =>
                      p.name.toLowerCase().contains(query.toLowerCase()) ||
                      p.packSize.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }

      if (selectedSort == "Low to High") {
        filteredProducts.sort(
          (a, b) => a.pricePerUnit.compareTo(b.pricePerUnit),
        );
      } else if (selectedSort == "High to Low") {
        filteredProducts.sort(
          (a, b) => b.pricePerUnit.compareTo(a.pricePerUnit),
        );
      }
      // else if (selectedSort == "Latest") {
      //   filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // }

      currentPage = 0; // reset to first page on search
    });
  }

  @override
  Widget build(BuildContext context) {
    int startIndex = currentPage * itemsPerPage;
    int endIndex = (startIndex + itemsPerPage).clamp(
      0,
      filteredProducts.length,
    );
    List<Product> currentPageProducts = filteredProducts.sublist(
      startIndex,
      endIndex,
    );
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          TitleBar(
            title: 'Products',
            isDrawerEnabled: true,
            isSearchEnabled: true,
            onSearch: () {
              setState(() {
                isSearchEnabled = !isSearchEnabled;
              });
            },
          ),
          isSearchEnabled
              ? SearchField(controller: searchController)
              : SizedBox.shrink(),
          SizedBox(height: 1.h),
          Expanded(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                children: [
                  if (filteredProducts.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Sort by",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontFamily: FontFamily.semiBold,
                                  color: AppColors.blackColor,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedSort,
                                  borderRadius: BorderRadius.circular(12),
                                  dropdownColor: Colors.white,
                                  icon: Icon(
                                    Icons.sort,
                                    color: AppColors.mainColor,
                                  ),
                                  items:
                                      sortOptions.map((e) {
                                        return DropdownMenuItem(
                                          value: e,
                                          child: Text(
                                            e,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontFamily: FontFamily.semiBold,
                                              color: AppColors.mainColor,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedSort = value;
                                        _filterProducts();
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Items per page",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontFamily: FontFamily.semiBold,
                                  color: AppColors.blackColor,
                                ),
                              ),
                              SizedBox(width: 3.w),

                              // Modern Dropdown
                              DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: itemsPerPage,
                                  borderRadius: BorderRadius.circular(12),
                                  dropdownColor: Colors.white,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontFamily: FontFamily.regular,
                                    color: AppColors.blackColor,
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.mainColor,
                                  ),
                                  items:
                                      itemsPerPageOptions.map((e) {
                                        return DropdownMenuItem(
                                          value: e,
                                          child: Text(
                                            e.toString(),
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontFamily: FontFamily.semiBold,
                                              color: AppColors.mainColor,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        itemsPerPage = value;
                                        currentPage = 0;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 1.h),
                  filteredProducts.isEmpty
                      ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        child: emptyWidget(
                          icon: Icons.production_quantity_limits,
                          text: 'Products',
                        ),
                      )
                      : Column(
                        children: [
                          GridView.count(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: ClampingScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            mainAxisSpacing: 1.h,
                            crossAxisSpacing: 2.w,
                            children:
                                currentPageProducts
                                    .map((p) => _buildGridItem(p))
                                    .toList(),
                          ),
                          SizedBox(height: 2.h),
                          // Pagination Section
                          if (filteredProducts.length > itemsPerPage)
                            Padding(
                              padding: EdgeInsets.only(bottom: 2.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Previous Button
                                  InkWell(
                                    onTap:
                                        currentPage > 0
                                            ? () {
                                              setState(() => currentPage--);
                                              scrollController.animateTo(
                                                0,
                                                duration: Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeOut,
                                              );
                                            }
                                            : null,
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      padding: EdgeInsets.all(1.5.w),
                                      decoration: BoxDecoration(
                                        color:
                                            currentPage > 0
                                                ? AppColors.mainColor
                                                : Colors.grey.shade300,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        size: 18.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 4.w),

                                  // Page Indicator
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 0.8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      "Page ${currentPage + 1}",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: FontFamily.semiBold,
                                        color: AppColors.blackColor,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 4.w),

                                  // Next Button
                                  InkWell(
                                    onTap:
                                        endIndex < filteredProducts.length
                                            ? () {
                                              setState(() => currentPage++);
                                              scrollController.animateTo(
                                                0,
                                                duration: Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeOut,
                                              );
                                            }
                                            : null,
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      padding: EdgeInsets.all(1.5.w),
                                      decoration: BoxDecoration(
                                        color:
                                            endIndex < filteredProducts.length
                                                ? AppColors.mainColor
                                                : Colors.grey.shade300,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                ],
              ),
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 3.w, vertical: 0.5.h),
      bottomNavigationBar: SizedBox(
        height: 10.h,
        child: CustomBar(selected: 1),
      ),
    );
  }

  Widget _buildGridItem(Product product) {
    return InkWell(
      onTap: () {
        if (product.inStock) {
          Get.to(
            () => ProductDetailsScreen(),
            transition: Transition.leftToRightWithFade,
            duration: const Duration(milliseconds: 450),
          );
        } else {
          showCustomErrorSnackbar(
            title: "Out of Stock",
            message: "${product.name} is not available right now!",
          );
        }
      },
      child: Opacity(
        opacity: product.inStock ? 1.0 : 0.4,
        child: Card(
          color: AppColors.cardBgColor2,
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    children: [
                      CustomNetworkImage(
                        imageUrl: product.imageUrl,
                        height: double.infinity,
                        width: double.infinity,
                        isFit: true,
                        radius: 20,
                      ),
                      if (!product.inStock)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.4),
                            child: Center(
                              child: Text(
                                "Out of Stock",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: FontFamily.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Details
              Padding(
                padding: EdgeInsets.all(2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      product.name,
                      style: TextStyle(
                        fontFamily: FontFamily.bold,
                        fontSize: 15.sp,
                        color: AppColors.blackColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),

                    // Pack Size
                    Text(
                      product.packSize,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: FontFamily.regular,
                        color: AppColors.gray,
                      ),
                    ),
                    SizedBox(height: 0.5.h),

                    // Price
                    Text(
                      "£${product.pricePerUnit.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: FontFamily.semiBold,
                        color: AppColors.mainColor,
                      ),
                    ),
                    SizedBox(height: 1.h),

                    // Quantity + Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Modern Quantity Selector
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.containerColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap:
                                    product.inStock && product.quantity > 0
                                        ? () =>
                                            setState(() => product.quantity--)
                                        : null,
                                child: Container(
                                  padding: EdgeInsets.all(1.5.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: 16.sp,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                product.quantity.toString(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: FontFamily.semiBold,
                                  color: AppColors.blackColor,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              GestureDetector(
                                onTap:
                                    product.inStock
                                        ? () =>
                                            setState(() => product.quantity++)
                                        : null,
                                child: Container(
                                  padding: EdgeInsets.all(1.5.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 16.sp,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Add to Cart Button
                        InkWell(
                          onTap:
                              product.inStock
                                  ? () {
                                    // handle add to cart
                                  }
                                  : null,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: EdgeInsets.all(1.5.w),
                            decoration: BoxDecoration(
                              color:
                                  product.inStock
                                      ? AppColors.mainColor
                                      : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final String imageUrl;
  final String packSize;
  var pricePerUnit;
  bool inStock;
  int quantity;

  Product({
    required this.name,
    required this.imageUrl,
    required this.packSize,
    required this.pricePerUnit,
    this.inStock = true,
    this.quantity = 0,
  });
}
