import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();

  factory HiveService() => _instance;

  HiveService._internal();

  // Boxes
  late Box categoriesBox;
  late Box bannerBox;
  late Box profileBox;
  late Box customerBox;
  late Box productsBox;
  late Box variationsBox;
  late Box categoryProductsBox;
  late Box productDetailsBox;
  late Box loginBox;
  late Box addCartBox;
  late Box productCartDataBox;
  late Box subCategoriesBox;
  late Box ordersBox;
  late Box viewCartBox;
  late Box pdfFileBox;
  late Box submitOrderBox;
  late Box addressBox;
  late Box couponListBox;

  // Initialize Hive and open all boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Open all required boxes here
    categoriesBox = await Hive.openBox('categoriesBox');
    bannerBox = await Hive.openBox('bannerBox');
    profileBox = await Hive.openBox('profileBox');
    customerBox = await Hive.openBox('customerBox');
    productsBox = await Hive.openBox('productsBox');
    variationsBox = await Hive.openBox('variationsBox');
    categoryProductsBox = await Hive.openBox('categoryProductsBox');
    productDetailsBox = await Hive.openBox('productDetailsBox');
    loginBox = await Hive.openBox('loginBox');
    addCartBox = await Hive.openBox('addCartBox');
    productCartDataBox = await Hive.openBox('productCartDataBox');
    subCategoriesBox = await Hive.openBox('subCategoriesBox');
    ordersBox = await Hive.openBox('ordersBox');
    viewCartBox = await Hive.openBox('viewCartBox');
    pdfFileBox = await Hive.openBox('pdfFileBox');
    submitOrderBox = await Hive.openBox('submitOrderBox');
    addressBox = await Hive.openBox('addressBox');
    couponListBox = await Hive.openBox('couponListBox');
  }

  // Helper getters
  Box getCategoriesBox() => categoriesBox;

  Box getSubCategoriesBox() => subCategoriesBox;

  Box getBannerBox() => bannerBox;

  Box getProfileBox() => profileBox;

  Box getCustomerBox() => customerBox;

  Box getProductsBox() => productsBox;

  Box getCategoryProductsBox() => categoryProductsBox;

  Box getVariationsBox() => variationsBox;

  Box getProductDetailsBox() => productDetailsBox;

  Box getLoginBox() => loginBox;

  Box getAddCartBox() => addCartBox;

  Box getProductCartDataBox() => productCartDataBox;

  Box getOrdersBox() => ordersBox;

  Box getViewCartBox() => viewCartBox;

  Box getPdfFileBox() => viewCartBox;

  Box getSubmitOrderBox() => submitOrderBox;

  Box getAddressBox() => addressBox;

  Box getCouponListBox() => couponListBox;
}
