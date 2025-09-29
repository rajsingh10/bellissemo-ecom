import 'package:bellissemo_ecom/ui/login/modal/loginModal.dart';

import '../ui/cart/modal/copunsApplyModal.dart';
import '../ui/cart/modal/copunsListModal.dart';
import '../ui/cart/modal/orderCheckOutModal.dart';
import '../ui/cart/modal/removeCouponsModal.dart';
import '../ui/cart/modal/updateQtyModal.dart';
import '../ui/cart/modal/viewCartDataModal.dart';
import '../ui/category/modal/fetchCategoriesModal.dart';
import '../ui/category/modal/fetchSubCategoriesModal.dart';
import '../ui/customers/modal/fetchCustomersModal.dart';
import '../ui/home/modal/bannersModal.dart';
import '../ui/orderHistory/modal/customerOrderWiseModal.dart';
import '../ui/orderHistory/modal/reorderModal.dart';
import '../ui/products/modal/categoryWiseProductsModal.dart';
import '../ui/products/modal/fetchPdfFileModal.dart';
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
FetchSubCategoriesModal? subCategories;
CustomerOrderWiseModal? customerOrders;
ViewCartDataModal? viewCartData;
FetchPdfFileModal? fetchPdfFile;
UpdateQtyModal? updateQtyModal;
OrderCheckOutModal? orderCheckOutModal;
CouponListModal? couponListModal;
CopunsApplyModal? copunsApplyModal;
RemoveCouponsModal? removeCouponsModal;
ReorderModal? reorderModal;
