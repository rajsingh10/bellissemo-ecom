class OrderCheckOutModal {
  int? id;
  String? number;
  String? status;
  String? total;
  int? subtotal;
  String? discountTotal;

  OrderCheckOutModal({
    this.id,
    this.number,
    this.status,
    this.total,
    this.subtotal,
    this.discountTotal,
  });

  OrderCheckOutModal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    status = json['status'];
    total = json['total'];
    subtotal = json['subtotal'];
    discountTotal = json['discount_total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['number'] = number;
    data['status'] = status;
    data['total'] = total;
    data['subtotal'] = subtotal;
    data['discount_total'] = discountTotal;
    return data;
  }
}
