class RemoveCouponsModal {
  bool? success;
  bool? removed;
  String? couponCode;
  String? cartTotal;
  String? cartSubtotal;
  String? message;

  RemoveCouponsModal({
    this.success,
    this.removed,
    this.couponCode,
    this.cartTotal,
    this.cartSubtotal,
    this.message,
  });

  RemoveCouponsModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    removed = json['removed'];
    couponCode = json['coupon_code'];
    cartTotal = json['cart_total'];
    cartSubtotal = json['cart_subtotal'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['removed'] = removed;
    data['coupon_code'] = couponCode;
    data['cart_total'] = cartTotal;
    data['cart_subtotal'] = cartSubtotal;
    data['message'] = message;
    return data;
  }
}
