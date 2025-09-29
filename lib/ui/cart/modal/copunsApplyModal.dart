class CopunsApplyModal {
  bool? success;
  bool? applied;
  String? couponCode;
  CouponData? couponData;
  var discountTotal;
  var discountTax;
  String? cartTotal;
  String? cartSubtotal;
  List<String>? appliedCoupons;
  String? message;

  CopunsApplyModal({
    this.success,
    this.applied,
    this.couponCode,
    this.couponData,
    this.discountTotal,
    this.discountTax,
    this.cartTotal,
    this.cartSubtotal,
    this.appliedCoupons,
    this.message,
  });

  CopunsApplyModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    applied = json['applied'];
    couponCode = json['coupon_code'];
    couponData =
        json['coupon_data'] != null
            ? CouponData.fromJson(json['coupon_data'])
            : null;
    discountTotal = json['discount_total'];
    discountTax = json['discount_tax'];
    cartTotal = json['cart_total'];
    cartSubtotal = json['cart_subtotal'];
    appliedCoupons = json['applied_coupons'].cast<String>();
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['applied'] = applied;
    data['coupon_code'] = couponCode;
    if (couponData != null) {
      data['coupon_data'] = couponData!.toJson();
    }
    data['discount_total'] = discountTotal;
    data['discount_tax'] = discountTax;
    data['cart_total'] = cartTotal;
    data['cart_subtotal'] = cartSubtotal;
    data['applied_coupons'] = appliedCoupons;
    data['message'] = message;
    return data;
  }
}

class CouponData {
  String? code;
  String? amount;
  String? discountType;
  String? description;
  Null dateExpires;
  String? minimumAmount;
  String? maximumAmount;

  CouponData({
    this.code,
    this.amount,
    this.discountType,
    this.description,
    this.dateExpires,
    this.minimumAmount,
    this.maximumAmount,
  });

  CouponData.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    amount = json['amount'];
    discountType = json['discount_type'];
    description = json['description'];
    dateExpires = json['date_expires'];
    minimumAmount = json['minimum_amount'];
    maximumAmount = json['maximum_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['amount'] = amount;
    data['discount_type'] = discountType;
    data['description'] = description;
    data['date_expires'] = dateExpires;
    data['minimum_amount'] = minimumAmount;
    data['maximum_amount'] = maximumAmount;
    return data;
  }
}
