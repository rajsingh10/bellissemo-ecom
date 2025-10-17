import 'apiConfigs.dart';

class apiEndpoints {
  static String baseUrl = apiConfig.baseUrl;

  static String login = "$baseUrl/wp-json/jwt-auth/v1/token";
  static String fetchCategories =
      "$baseUrl/wp-json/wc/v3/products/categories?parent=0&per_page=100";
  static String profile = "$baseUrl/wp-json/wp/v2/users/me?context=edit";
  static String banners = "$baseUrl/wp-json/wp/v2/banner";
  static String fetchCustomers = "$baseUrl/wp-json/custom-wc/v1/all-customers";
  static String fetchProducts = "$baseUrl/wp-json/wc/v3/products";
  static String fetchCategoryWiseProducts =
      "$baseUrl/wp-json/custom-wc/v1/all-products?category=";
  static String addToCart = "$baseUrl/wp-json/bellissemo/v1/add-to-cart";
  static String removeFromCart =
      "$baseUrl/wp-json/bellissemo/v1/update-cart-item";
  static String updateCart = "$baseUrl/wp-json/bellissemo/v1/update-cart-item";
  static String checkCart = "$baseUrl/wp-json/bellissemo/v1/cart/contains/";
  static String clearCart = "$baseUrl/wp-json/bellissemo/v1/cart/clear";
  static String orderHistory = "$baseUrl/wp-json/wc/v3/orders?customer=";
  static String viewCart = "$baseUrl/wp-json/wc/store/v1/cart?customer_id=";
  static String submitOrder = "$baseUrl/wp-json/bellissemo/v1/orders";
  static String fetchSubCategories =
      "$baseUrl/wp-json/wc/v3/products/categories?parent=";
  static String fetchPdfFile =
      "$baseUrl/wp-json/bellissemo/v1/catalog/pdf/dompdf?taxonomy=product_cat&taxonomy_value=";
  static String updateAddress = "$baseUrl/wp-json/wc/v3/customers/";
  static String couponsList = "$baseUrl/wp-json/bellissemo/v1/coupons";
  static String applyCoupons = "$baseUrl/wp-json/bellissemo/v1/apply-coupon";
  static String removeCoupons = "$baseUrl/wp-json/bellissemo/v1/remove-coupon";
  static String reorderApi = "$baseUrl/wp-json/bellissemo/v1/reorder";
  static String updatediscount =
      "$baseUrl/wp-json/bellissemo/v1/update-discount";
  static String refreshToken =
      "$baseUrl/wp-json/jwt-auth/v1/token/refresh";
  static String setprice =
      "$baseUrl/wp-json/custom-pricing/v1/set";
  static String addcustomer =
      "$baseUrl/wp-json/wc/v3/customers";
}
