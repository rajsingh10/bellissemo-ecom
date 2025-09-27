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
            ? new CouponData.fromJson(json['coupon_data'])
            : null;
    discountTotal = json['discount_total'];
    discountTax = json['discount_tax'];
    cartTotal = json['cart_total'];
    cartSubtotal = json['cart_subtotal'];
    appliedCoupons = json['applied_coupons'].cast<String>();
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['applied'] = this.applied;
    data['coupon_code'] = this.couponCode;
    if (this.couponData != null) {
      data['coupon_data'] = this.couponData!.toJson();
    }
    data['discount_total'] = this.discountTotal;
    data['discount_tax'] = this.discountTax;
    data['cart_total'] = this.cartTotal;
    data['cart_subtotal'] = this.cartSubtotal;
    data['applied_coupons'] = this.appliedCoupons;
    data['message'] = this.message;
    return data;
  }
}

class CouponData {
  String? code;
  String? amount;
  String? discountType;
  String? description;
  Null? dateExpires;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['amount'] = this.amount;
    data['discount_type'] = this.discountType;
    data['description'] = this.description;
    data['date_expires'] = this.dateExpires;
    data['minimum_amount'] = this.minimumAmount;
    data['maximum_amount'] = this.maximumAmount;
    return data;
  }
}
