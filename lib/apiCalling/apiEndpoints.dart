import 'apiConfigs.dart';

class apiEndpoints {
  static String baseUrl = apiConfig.baseUrl;

  static String login = "$baseUrl/wp-json/jwt-auth/v1/token";
  static String fetchCategories = "$baseUrl/wp-json/wc/v3/products/categories";
  static String profile = "$baseUrl/wp-json/wp/v2/users/me?context=edit";
  static String banners = "$baseUrl/wp-json/wp/v2/banner";
  static String fetchCustomers = "$baseUrl/wp-json/wc/v3/customers";
  static String fetchProducts = "$baseUrl/wp-json/wc/v3/products";
  static String fetchCategoryWiseProducts =
      "$baseUrl/wp-json/wc/v3/products?category=";
  static String addToCart = "$baseUrl/wp-json/bellissemo/v1/add-to-cart";
  static String removeFromCart =
      "$baseUrl/wp-json/bellissemo/v1/update-cart-item";
  static String checkCart = "$baseUrl/wp-json/bellissemo/v1/cart/contains/";
  static String viewCart = "$baseUrl/wp-json/wc/store/v1/cart";
}
