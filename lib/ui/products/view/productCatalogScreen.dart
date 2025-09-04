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

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  int itemsPerPage = 4;
  int currentPage = 0;

  final List<int> itemsPerPageOptions = [4, 8, 12, 16];
  List<Product> filteredProducts = [];
  final List<Product> products = [
    Product(
      name: "Apple iPhone 15 Pro",
      imageUrl:
          'https://m.media-amazon.com/images/I/81SigpJN1KL._UF1000,1000_QL80_.jpg',
      packSize: "128GB",
      pricePerUnit: 699.0,
      inStock: true,
    ),
    Product(
      name: "Samsung Galaxy Pro",
      imageUrl: 'https://m.media-amazon.com/images/I/61KVX-MbIUL.jpg',
      packSize: "1 Pair",
      pricePerUnit: 69.0,
      inStock: true,
    ),
    Product(
      name: "Iphone 12",
      imageUrl:
          'https://www.apple.com/newsroom/images/product/iphone/geo/apple_iphone-12_2-up_geo_10132020_inline.jpg.large.jpg',
      packSize: "500ml",
      pricePerUnit: 12.5,
      inStock: false,
    ),
    Product(
      name: "Apple iPad Air",
      imageUrl:
          'https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/ipad-air-storage-select-202405-13inch-space-gray-wifi_FMT_WHH?wid=1280&hei=720&fmt=p-jpg&qlt=80&.v=TENLTVRoeFdHUUI5ZE1ZZmxpQUlNMm5pQUoxb0NIVEJFSjRVRzZ4dzV5VE52YTlHWkltOWpNQVF4Y3VwTzdmWGl1WEttbFlFejZ0L0VqVlhGc0pKT3BmbTBuZmdjbmVyUEN6U1pnb2VjUDh3Qjhvd1BnZkhnUFFYU1JJMGh5alFTUzBLNXZ0QTA0SmlDNU1IU2czNjMzNXFNVzc5YkZmK2I4YzJ4ZndkZUdj&traceId=1',
      packSize: "256GB",
      pricePerUnit: 599.0,
      inStock: true,
    ),
    Product(
      name: "Sony WH-1000XM5",
      imageUrl:
          'https://computermania.co.za/cdn/shop/files/wh1000xm53.jpg?v=1694697686',
      packSize: "1 Unit",
      pricePerUnit: 329.0,
      inStock: true,
    ),
    Product(
      name: "Google Pixel 8",
      imageUrl:
          'https://media.tatacroma.com/Croma%20Assets/Communication/Mobiles/Images/309134_0_cv9vxa.png',
      packSize: "128GB",
      pricePerUnit: 649.0,
      inStock: true,
    ),
    Product(
      name: "Dell XPS Laptop",
      imageUrl:
          'https://dellstatic.luroconnect.com/media/catalog/product/cache/74ae05ef3745aec30d7f5a287debd7f5/i/n/indhs-xps-9530-co_2.jpg',
      packSize: "512GB SSD",
      pricePerUnit: 1099.0,
      inStock: true,
    ),
    Product(
      name: "Apple Watch Series 9",
      imageUrl:
          'https://m.media-amazon.com/images/I/81mHRsWENaL._UF1000,1000_QL80_.jpg',
      packSize: "45mm",
      pricePerUnit: 399.0,
      inStock: false,
    ),
    Product(
      name: "Logitech MX Master 3S",
      imageUrl: 'https://m.media-amazon.com/images/I/61ni3t1ryQL.jpg',
      packSize: "1 Unit",
      pricePerUnit: 99.0,
      inStock: true,
    ),
    Product(
      name: "Samsung 4K Monitor",
      imageUrl:
          'https://computerspace.in/cdn/shop/products/NewProject-2021-06-10T163019.378.jpg?v=1629056157',
      packSize: "32 inch",
      pricePerUnit: 299.0,
      inStock: true,
    ),
    Product(
      name: "Bose QuietComfort Earbuds II",
      imageUrl:
          'https://m.media-amazon.com/images/I/51DOzlkiBTL._UF1000,1000_QL80_.jpg',
      packSize: "1 Pair",
      pricePerUnit: 249.0,
      inStock: true,
    ),
    Product(
      name: "Nintendo Switch OLED",
      imageUrl:
          'https://www.designinfo.in/wp-content/uploads/2023/05/Nintendo-Switch-OLED-Model-The-Legend-of-Zelda.webp',
      packSize: "64GB",
      pricePerUnit: 349.0,
      inStock: false,
    ),
    Product(
      name: "HP Envy Printer",
      imageUrl:
          'https://5.imimg.com/data5/SELLER/Default/2022/11/PX/RJ/PP/65193524/hp-envy-wifi-printer-4500.jpg',
      packSize: "1 Unit",
      pricePerUnit: 149.0,
      inStock: true,
    ),
    Product(
      name: "Apple AirPods Pro 2",
      imageUrl:
          'https://idestiny.in/wp-content/uploads/2024/10/Airpods-pro2-6.jpg',
      packSize: "1 Pair",
      pricePerUnit: 249.0,
      inStock: true,
    ),
    Product(
      name: "Samsung Galaxy Tab S9",
      imageUrl:
          'https://m.media-amazon.com/images/I/618Acjb5AhL._UF1000,1000_QL80_.jpg',
      packSize: "256GB",
      pricePerUnit: 799.0,
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

  void _filterProducts(String query) {
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
                      mainAxisAlignment: MainAxisAlignment.end,
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

                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 3.w, vertical: 0.5.h),
      bottomNavigationBar: SizedBox(
        height: 12.h,
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
            transition: Transition.fade,
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
                            color: Colors.black.withOpacity(0.4),
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
                            color: AppColors.bgColor,
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
                                child: Icon(
                                  Icons.remove_circle,
                                  size: 22.sp,
                                  color: AppColors.mainColor,
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
                                child: Icon(
                                  Icons.add_circle,
                                  size: 22.sp,
                                  color: AppColors.mainColor,
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
  final double pricePerUnit;
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
