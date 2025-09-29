class CouponListModal {
  int? id;
  String? code;
  String? amount;
  String? discountType;
  var dateExpires;
  int? usageLimit;
  int? usageCount;
  bool? individualUse;
  String? minimumAmount;
  String? maximumAmount;

  CouponListModal({
    this.id,
    this.code,
    this.amount,
    this.discountType,
    this.dateExpires,
    this.usageLimit,
    this.usageCount,
    this.individualUse,
    this.minimumAmount,
    this.maximumAmount,
  });

  CouponListModal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    amount = json['amount'];
    discountType = json['discount_type'];
    dateExpires = json['date_expires'];
    usageLimit = json['usage_limit'];
    usageCount = json['usage_count'];
    individualUse = json['individual_use'];
    minimumAmount = json['minimum_amount'];
    maximumAmount = json['maximum_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['amount'] = amount;
    data['discount_type'] = discountType;
    data['date_expires'] = dateExpires;
    data['usage_limit'] = usageLimit;
    data['usage_count'] = usageCount;
    data['individual_use'] = individualUse;
    data['minimum_amount'] = minimumAmount;
    data['maximum_amount'] = maximumAmount;
    return data;
  }
}
