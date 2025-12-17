class ProductReportOrderModal {
  Product? product;
  Summary? summary;
  List<Order>? orders;
  String? currency;
  String? currencySymbol;

  ProductReportOrderModal({
    this.product,
    this.summary,
    this.orders,
    this.currency,
    this.currencySymbol,
  });

  factory ProductReportOrderModal.fromJson(Map<String, dynamic> json) {
    return ProductReportOrderModal(
      product:
      json['product'] != null ? Product.fromJson(json['product']) : null,
      summary:
      json['summary'] != null ? Summary.fromJson(json['summary']) : null,
      orders: json['orders'] != null
          ? List<Order>.from(
        json['orders'].map((x) => Order.fromJson(x)),
      )
          : [],
      currency: json['currency'],
      currencySymbol: json['currency_symbol'],
    );
  }
}

/* ===================== PRODUCT ===================== */

class Product {
  String? productId;
  String? productName;
  String? postStatus;
  String? image;

  Product({
    this.productId,
    this.productName,
    this.postStatus,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id']?.toString(),
      productName: json['product_name'],
      postStatus: json['post_status'],
      image: json['image'],
    );
  }
}

/* ===================== SUMMARY ===================== */

class Summary {
  int? totalOrders;
  int? totalQuantity;
  num? totalRevenue;
  num? avgPrice;

  Summary({
    this.totalOrders,
    this.totalQuantity,
    this.totalRevenue,
    this.avgPrice,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalOrders: json['total_orders'],
      totalQuantity: json['total_quantity'],
      totalRevenue: json['total_revenue'],
      avgPrice: json['avg_price'],
    );
  }
}

/* ===================== ORDER ===================== */

class Order {
  String? orderId;
  String? orderDate;
  String? formattedDate;
  String? customerId;
  String? customerName;
  String? customerEmail;
  String? quantity;
  String? unitPrice;
  String? totalPrice;
  String? status;
  String? currency;

  Order({
    this.orderId,
    this.orderDate,
    this.formattedDate,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
    this.status,
    this.currency,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id']?.toString(),
      orderDate: json['order_date'],
      formattedDate: json['formatted_date'],
      customerId: json['customer_id']?.toString(),
      customerName: json['customer_name'],
      customerEmail: json['customer_email'],
      quantity: json['quantity']?.toString(),
      unitPrice: json['unit_price']?.toString(),
      totalPrice: json['total_price']?.toString(),
      status: json['status'],
      currency: json['currency'],
    );
  }
}
