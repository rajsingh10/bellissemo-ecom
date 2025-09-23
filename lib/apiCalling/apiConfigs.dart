import 'package:bellissemo_ecom/ui/login/modal/loginModal.dart';

import '../ui/category/modal/fetchCategoriesModal.dart';
import '../ui/customers/modal/fetchCustomersModal.dart';
import '../ui/home/modal/bannersModal.dart';
import '../ui/products/modal/categoryWiseProductsModal.dart';
import '../ui/products/modal/fetchProductsModal.dart';
import '../ui/products/modal/productDetailsModal.dart';
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
ProductDetailsModal? productDetails;
CategoryWiseProductsModal? categoryWiseProducts;
