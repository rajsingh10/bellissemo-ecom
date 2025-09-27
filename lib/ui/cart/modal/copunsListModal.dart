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

  CouponListModal(
      {this.id,
        this.code,
        this.amount,
        this.discountType,
        this.dateExpires,
        this.usageLimit,
        this.usageCount,
        this.individualUse,
        this.minimumAmount,
        this.maximumAmount});

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['amount'] = this.amount;
    data['discount_type'] = this.discountType;
    data['date_expires'] = this.dateExpires;
    data['usage_limit'] = this.usageLimit;
    data['usage_count'] = this.usageCount;
    data['individual_use'] = this.individualUse;
    data['minimum_amount'] = this.minimumAmount;
    data['maximum_amount'] = this.maximumAmount;
    return data;
  }
}
