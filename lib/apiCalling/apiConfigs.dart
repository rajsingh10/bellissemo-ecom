import 'package:bellissemo_ecom/ui/login/modal/loginModal.dart';

import '../ui/category/modal/fetchCategoriesModal.dart';
import '../ui/customers/modal/fetchCustomersModal.dart';
import '../ui/home/modal/bannersModal.dart';
import '../ui/products/modal/categoryWiseProducts.dart';
import '../ui/products/modal/fetchProductsModal.dart';
import '../ui/products/modal/productDetailsModal.dart';
import '../ui/products/modal/productsVariationsModal.dart';
import '../ui/profile/modal/profileModal.dart';

class apiConfig {
  static String baseUrl = 'https://www.bellissemo.com';
}

/// all modal variables
LoginModal? loginData;
FetchCategoriesModal? categories;
ProfileModal? profile;
BannersModal? banners;
FetchCustomersModal? customers;
FetchProductsModal? allProducts;
ProductVariationsModal? productVariations;
ProductDetailsModal? productDetails;
CategoryWiseProductsModal? categoryWiseProducts;
