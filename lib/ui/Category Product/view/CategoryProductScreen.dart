import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../utils/colors.dart';
import '../../../utils/customBottombar.dart';
import '../../../utils/emptyWidget.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/searchFields.dart';
import '../../../utils/snackBars.dart';
import '../../../utils/titlebarWidget.dart';
import '../../../utils/cachedNetworkImage.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int itemsPerPage = 4;
  int currentPage = 0;
  final List<int> itemsPerPageOptions = [4, 8, 12, 16];

  List<Category> filteredCategories = [];
  String selectedSort = "A-Z";
  final List<String> sortOptions = ["A-Z", "Z-A"];

  final List<Category> categories = [
    Category(
      name: "Lipsticks",
      imageUrl: "https://m.media-amazon.com/images/I/71hUeZd546L._UF1000,1000_QL80_.jpg",
      productCount: 25,
    ),
    Category(
      name: "Foundations",
      imageUrl: "https://m.media-amazon.com/images/I/51uTj0beKCL._UF1000,1000_QL80_.jpg",
      productCount: 18,
    ),
    Category(
      name: "Nail Polish",
      imageUrl: "https://m.media-amazon.com/images/I/41qteOLxDHL.jpg",
      productCount: 10,
    ),
    Category(
      name: "Eye Makeup",
      imageUrl: "https://www.lakmeindia.com/cdn/shop/files/24894_S1-8901030979552_1000x.jpg?v=1709807079",
      productCount: 12,
    ),
    Category(
      name: "Blush & Highlighters",
      imageUrl: "https://m.media-amazon.com/images/I/71+yE3132GL._UF1000,1000_QL80_.jpg",
      productCount: 8,
    ),
    Category(
      name: "Compact & Powders",
      imageUrl: "https://m.media-amazon.com/images/I/41B-IgO4X2L._UF1000,1000_QL80_.jpg",
      productCount: 15,
    ),
    Category(
      name: "Mascaras",
      imageUrl: "https://m.media-amazon.com/images/I/61vuiK6d7RL._UF1000,1000_QL80_.jpg",
      productCount: 9,
    ),
    Category(
      name: "Lip Gloss & Balms",
      imageUrl: "https://www.jiomart.com/images/product/original/491061263/himalaya-lip-care-balm-strawberry-shine-4-5-g-product-images-o491061263-p590087371-0-202203150923.jpg",
      productCount: 14,
    ),
    Category(
      name: "Concealers",
      imageUrl: "https://www.nykaa.com/beauty-blog/wp-content/uploads/images/issue339/How-To-Use-Concealers-Different-Types-Of-Concealers-And-8-Best-Picks-From-Nykaa_OI.jpg",
      productCount: 11,
    ),
    Category(
      name: "Primers",
      imageUrl: "https://images-static.nykaa.com/media/catalog/product/f/1/f1810a0609332834019_06.jpg?tr=w-500",
      productCount: 6,
    ),
    Category(
      name: "Setting Sprays",
      imageUrl: "https://m.media-amazon.com/images/I/61n10t+vOkL._UF1000,1000_QL80_.jpg",
      productCount: 7,
    ),
    Category(
      name: "Lip Liners",
      imageUrl: "https://m.media-amazon.com/images/I/71Y+L4lMHWL._UF1000,1000_QL80_.jpg",
      productCount: 13,
    ),
    Category(
      name: "Eyebrow Products",
      imageUrl: "https://cdn.shopify.com/s/files/1/0612/3090/7642/files/PONI_BLOG_5BrowProducts_infographic_2_1.jpg",
      productCount: 5,
    ),
    Category(
      name: "Makeup Removers",
      imageUrl: "https://people.com/thmb/CGn_THipkTfhcIls-xK53dLwYOE=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc():focal(2999x0:3001x2)/best-eye-makeup-removers-PO-Tout-d983b233af25430eb7c84923546e114f.jpg",
      productCount: 9,
    ),
    Category(
      name: "BB & CC Creams",
      imageUrl: "https://m.media-amazon.com/images/I/41I28v0QBjL._UF1000,1000_QL80_.jpg",
      productCount: 10,
    ),
    // Category(
    //   name: "Contour & Bronzer",
    //   imageUrl: "https://images-static.nykaa.com/media/catalog/product/4/e/4ee18a6ELFCO00001391AB_AB7.jpg?tr=w-500",
    //   productCount: 8,
    // ),
  ];


  bool isSearchEnabled = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCategories = List.from(categories);

    searchController.addListener(() {
      _filterCategories(searchController.text);
    });
  }

  void _filterCategories([String query = ""]) {
    setState(() {
      if (query.isEmpty) {
        filteredCategories = List.from(categories);
      } else {
        filteredCategories = categories
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      // Sorting
      if (selectedSort == "A-Z") {
        filteredCategories.sort((a, b) => a.name.compareTo(b.name));
      } else if (selectedSort == "Z-A") {
        filteredCategories.sort((a, b) => b.name.compareTo(a.name));
      }

      currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    int startIndex = currentPage * itemsPerPage;
    int endIndex = (startIndex + itemsPerPage).clamp(0, filteredCategories.length);
    List<Category> currentPageCategories = filteredCategories.sublist(startIndex, endIndex);
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          TitleBar(
            title: 'Categories',
            isDrawerEnabled: true,
            isSearchEnabled: true,
            onSearch: () {
              setState(() {
                isSearchEnabled = !isSearchEnabled;
              });
            },
          ),
          isSearchEnabled ? SearchField(controller: searchController) : SizedBox.shrink(),
          SizedBox(height: 1.h),

          Expanded(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                children: [
                  if (filteredCategories.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sort Dropdown
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                          ),
                          child: Row(
                            children: [
                              Text("Sort by", style: TextStyle(fontSize: 15.sp, fontFamily: FontFamily.semiBold, color: AppColors.blackColor)),
                              SizedBox(width: 3.w),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedSort,
                                  borderRadius: BorderRadius.circular(12),
                                  dropdownColor: Colors.white,
                                  icon: Icon(Icons.sort, color: AppColors.mainColor),
                                  items: sortOptions.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 15.sp, fontFamily: FontFamily.semiBold, color: AppColors.mainColor)))).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => selectedSort = value);
                                      _filterCategories();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Items per Page Dropdown
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                          ),
                          child: Row(
                            children: [
                              Text("Items per page", style: TextStyle(fontSize: 15.sp, fontFamily: FontFamily.semiBold, color: AppColors.blackColor)),
                              SizedBox(width: 3.w),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: itemsPerPage,
                                  borderRadius: BorderRadius.circular(12),
                                  dropdownColor: Colors.white,
                                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.mainColor),
                                  items: itemsPerPageOptions.map((e) => DropdownMenuItem(value: e, child: Text(e.toString(), style: TextStyle(fontSize: 15.sp, fontFamily: FontFamily.semiBold, color: AppColors.mainColor)))).toList(),
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

                  filteredCategories.isEmpty
                      ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    child: emptyWidget(icon: Icons.category, text: 'Categories'),
                  )
                      : Column(
                    children: [
                      GridView.count(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        mainAxisSpacing: 1.h,
                        crossAxisSpacing: 2.w,
                        children: currentPageCategories.map((c) => _buildGridItem(c)).toList(),
                      ),

                      SizedBox(height: 2.h),

                      // Pagination
                      if (filteredCategories.length > itemsPerPage)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _pageButton(
                              icon: Icons.arrow_back_ios_new,
                              enabled: currentPage > 0,
                              onTap: () {
                                if (currentPage > 0) {
                                  setState(() => currentPage--);
                                  scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                                }
                              },
                            ),
                            SizedBox(width: 4.w),
                            Text("Page ${currentPage + 1}", style: TextStyle(fontSize: 14.sp, fontFamily: FontFamily.semiBold, color: AppColors.blackColor)),
                            SizedBox(width: 4.w),
                            _pageButton(
                              icon: Icons.arrow_forward_ios,
                              enabled: endIndex < filteredCategories.length,
                              onTap: () {
                                if (endIndex < filteredCategories.length) {
                                  setState(() => currentPage++);
                                  scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                                }
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 3.w, vertical: 0.5.h),
      bottomNavigationBar: SizedBox(height: 10.h, child: CustomBar(selected: 1)),
    );
  }

  Widget _buildGridItem(Category category) {
    return InkWell(
      onTap: () {
        // Navigate to category details or product list of that category
        showCustomSuccessSnackbar(title: "Category Selected", message: "You tapped on ${category.name}");
      },
      child: Card(
        color: AppColors.cardBgColor2,
        elevation: 3,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: CustomNetworkImage(
                  imageUrl: category.imageUrl,
                  height: double.infinity,
                  width: double.infinity,
                  isFit: true,
                  radius: 20,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: TextStyle(fontFamily: FontFamily.bold, fontSize: 15.sp, color: AppColors.blackColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 0.5.h),
                  Text("${category.productCount} products", style: TextStyle(fontSize: 13.sp, fontFamily: FontFamily.regular, color: AppColors.gray)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageButton({required IconData icon, required bool enabled, required VoidCallback onTap}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.all(1.5.w),
        decoration: BoxDecoration(color: enabled ? AppColors.mainColor : Colors.grey.shade300, shape: BoxShape.circle),
        child: Icon(icon, size: 18.sp, color: Colors.white),
      ),
    );
  }
}





class Category {
  final String name;
  final String imageUrl;
  int productCount;

  Category({
    required this.name,
    required this.imageUrl,
    this.productCount = 0,
  });
}
