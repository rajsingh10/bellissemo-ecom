class UpdateQtyModal {
  bool? success;
  bool? updated;
  String? cartItemKey;
  int? oldQuantity;
  int? newQuantity;
  String? productName;
  String? productPrice;
  int? lineTotal;
  int? lineSubtotal;
  int? cartCount;
  String? cartTotal;
  String? cartSubtotal;
  String? message;

  UpdateQtyModal(
      {this.success,
        this.updated,
        this.cartItemKey,
        this.oldQuantity,
        this.newQuantity,
        this.productName,
        this.productPrice,
        this.lineTotal,
        this.lineSubtotal,
        this.cartCount,
        this.cartTotal,
        this.cartSubtotal,
        this.message});

  UpdateQtyModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    updated = json['updated'];
    cartItemKey = json['cart_item_key'];
    oldQuantity = json['old_quantity'];
    newQuantity = json['new_quantity'];
    productName = json['product_name'];
    productPrice = json['product_price'];
    lineTotal = json['line_total'];
    lineSubtotal = json['line_subtotal'];
    cartCount = json['cart_count'];
    cartTotal = json['cart_total'];
    cartSubtotal = json['cart_subtotal'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['updated'] = this.updated;
    data['cart_item_key'] = this.cartItemKey;
    data['old_quantity'] = this.oldQuantity;
    data['new_quantity'] = this.newQuantity;
    data['product_name'] = this.productName;
    data['product_price'] = this.productPrice;
    data['line_total'] = this.lineTotal;
    data['line_subtotal'] = this.lineSubtotal;
    data['cart_count'] = this.cartCount;
    data['cart_total'] = this.cartTotal;
    data['cart_subtotal'] = this.cartSubtotal;
    data['message'] = this.message;
    return data;
  }
}
