import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/cachedNetworkImage.dart';
import '../../../utils/colors.dart';
import '../../../utils/customBottombar.dart';
import '../../../utils/emptyWidget.dart';
import '../../../utils/fontFamily.dart';
import '../../../utils/searchFields.dart';
import '../../../utils/titlebarWidget.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Customer> filteredCustomers = [];
  String selectedSort = "A-Z";
  final List<String> sortOptions = ["A-Z", "Z-A"];

  final List<Customer> customers = [
    Customer(
      name: "John Doe",
      imageUrl: "https://randomuser.me/api/portraits/men/1.jpg",
      email: "john.doe@example.com",
      phone: "+1 555 123 4567",
    ),
    Customer(
      name: "Jane Smith",
      imageUrl: "https://randomuser.me/api/portraits/women/2.jpg",
      email: "jane.smith@example.com",
      phone: "+1 555 987 6543",
    ),
    Customer(
      name: "Michael Johnson",
      imageUrl: "https://randomuser.me/api/portraits/men/3.jpg",
      email: "michael.johnson@example.com",
      phone: "+1 555 654 3210",
    ),
    Customer(
      name: "Emily Davis",
      imageUrl: "https://randomuser.me/api/portraits/women/4.jpg",
      email: "emily.davis@example.com",
      phone: "+1 555 789 1234",
    ),
    Customer(
      name: "David Wilson",
      imageUrl: "https://randomuser.me/api/portraits/men/5.jpg",
      email: "david.wilson@example.com",
      phone: "+1 555 432 9876",
    ),
    Customer(
      name: "Sophia Martinez",
      imageUrl: "https://randomuser.me/api/portraits/women/6.jpg",
      email: "sophia.martinez@example.com",
      phone: "+1 555 876 5432",
    ),
    Customer(
      name: "James Anderson",
      imageUrl: "https://randomuser.me/api/portraits/men/7.jpg",
      email: "james.anderson@example.com",
      phone: "+1 555 111 2222",
    ),
    Customer(
      name: "Olivia Taylor",
      imageUrl: "https://randomuser.me/api/portraits/women/8.jpg",
      email: "olivia.taylor@example.com",
      phone: "+1 555 333 4444",
    ),
    Customer(
      name: "Daniel Thomas",
      imageUrl: "https://randomuser.me/api/portraits/men/9.jpg",
      email: "daniel.thomas@example.com",
      phone: "+1 555 555 6666",
    ),
    Customer(
      name: "Ava Jackson",
      imageUrl: "https://randomuser.me/api/portraits/women/10.jpg",
      email: "ava.jackson@example.com",
      phone: "+1 555 777 8888",
    ),
    Customer(
      name: "Matthew White",
      imageUrl: "https://randomuser.me/api/portraits/men/11.jpg",
      email: "matthew.white@example.com",
      phone: "+1 555 999 0000",
    ),
    Customer(
      name: "Isabella Harris",
      imageUrl: "https://randomuser.me/api/portraits/women/12.jpg",
      email: "isabella.harris@example.com",
      phone: "+1 555 246 1357",
    ),
    Customer(
      name: "Christopher Lewis",
      imageUrl: "https://randomuser.me/api/portraits/men/13.jpg",
      email: "chris.lewis@example.com",
      phone: "+1 555 975 8642",
    ),
    Customer(
      name: "Mia Walker",
      imageUrl: "https://randomuser.me/api/portraits/women/14.jpg",
      email: "mia.walker@example.com",
      phone: "+1 555 753 1597",
    ),
    Customer(
      name: "Anthony Hall",
      imageUrl: "https://randomuser.me/api/portraits/men/15.jpg",
      email: "anthony.hall@example.com",
      phone: "+1 555 951 3579",
    ),
    Customer(
      name: "Charlotte Allen",
      imageUrl: "https://randomuser.me/api/portraits/women/16.jpg",
      email: "charlotte.allen@example.com",
      phone: "+1 555 852 4563",
    ),
    Customer(
      name: "Andrew Young",
      imageUrl: "https://randomuser.me/api/portraits/men/17.jpg",
      email: "andrew.young@example.com",
      phone: "+1 555 654 8523",
    ),
    Customer(
      name: "Amelia King",
      imageUrl: "https://randomuser.me/api/portraits/women/18.jpg",
      email: "amelia.king@example.com",
      phone: "+1 555 321 1479",
    ),
    Customer(
      name: "Joshua Wright",
      imageUrl: "https://randomuser.me/api/portraits/men/19.jpg",
      email: "joshua.wright@example.com",
      phone: "+1 555 159 3578",
    ),
    Customer(
      name: "Harper Scott",
      imageUrl: "https://randomuser.me/api/portraits/women/20.jpg",
      email: "harper.scott@example.com",
      phone: "+1 555 741 2589",
    ),
  ];

  bool isSearchEnabled = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCustomers = List.from(customers);

    searchController.addListener(() {
      _filterCustomers(searchController.text);
    });
    _filterCustomers();
  }

  void _filterCustomers([String query = ""]) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = List.from(customers);
      } else {
        filteredCustomers =
            customers
                .where(
                  (c) =>
                      c.name.toLowerCase().contains(query.toLowerCase()) ||
                      c.email.toLowerCase().contains(query.toLowerCase()) ||
                      c.phone.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }

      // Sorting
      if (selectedSort == "A-Z") {
        filteredCustomers.sort((a, b) => a.name.compareTo(b.name));
      } else if (selectedSort == "Z-A") {
        filteredCustomers.sort((a, b) => b.name.compareTo(a.name));
      }
    });
  }

  bool isIpad = 100.w >= 800;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          TitleBar(
            title: 'Customers',
            isDrawerEnabled: true,
            isSearchEnabled: true,
            onSearch: () {
              setState(() {
                isSearchEnabled = !isSearchEnabled;
              });
            },
          ),
          if (isSearchEnabled) SearchField(controller: searchController),
          SizedBox(height: 1.h),

          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  if (filteredCustomers.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Sort Dropdown
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
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
                                      sortOptions
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(
                                                e,
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontFamily:
                                                      FontFamily.semiBold,
                                                  color: AppColors.mainColor,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => selectedSort = value);
                                      _filterCustomers();
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

                  filteredCustomers.isEmpty
                      ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        child: emptyWidget(
                          icon: Icons.people,
                          text: 'Customers',
                        ),
                      )
                      : Column(
                        children: [
                          for (int i = 0; i < filteredCustomers.length; i++)
                            _buildGridItem(filteredCustomers[i]),
                        ],
                      ),
                ],
              ),
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 3.w, vertical: 0.5.h),
      bottomNavigationBar: SizedBox(
        height: isIpad ? 14.h : 10.h,
        child: CustomBar(selected: 8),
      ),
    );
  }

  Widget _buildGridItem(Customer customer) {
    return InkWell(
      onTap: () {},
      child: Card(
        color: AppColors.cardBgColor2,
        elevation: 3,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: CustomNetworkImage(
                imageUrl: customer.imageUrl,
                height: isIpad ? 10.w : 20.w,
                width: isIpad ? 10.w : 20.w,
                isFit: true,
                radius: 15,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: TextStyle(
                      fontFamily: FontFamily.bold,
                      fontSize: 16.sp,
                      color: AppColors.blackColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    customer.email,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: FontFamily.regular,
                      color: AppColors.gray,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    customer.phone,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: FontFamily.regular,
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).paddingSymmetric(horizontal: 1.w, vertical: 0.5.h),
      ),
    );
  }
}

class Customer {
  final String name;
  final String imageUrl;
  final String email;
  final String phone;

  Customer({
    required this.name,
    required this.imageUrl,
    required this.email,
    required this.phone,
  });
}
