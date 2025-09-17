import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  // Singleton pattern (optional, useful for global access)
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
  }

  // Helper getters
  Box getCategoriesBox() => categoriesBox;
  Box getBannerBox() => bannerBox;
  Box getProfileBox() => profileBox;
  Box getCustomerBox() => customerBox;
  Box getProductsBox() => productsBox;
  Box getCategoryProductsBox() => categoryProductsBox;
  Box getVariationsBox() => variationsBox;
}
