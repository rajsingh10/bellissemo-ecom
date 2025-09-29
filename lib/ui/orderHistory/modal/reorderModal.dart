class ReorderModal {
  bool? success;
  int? orderId;
  List<AddedItems>? addedItems;
  int? cartCount;
  String? cartTotal;
  String? cartSubtotal;
  List<Items>? items;
  String? message;

  ReorderModal({
    this.success,
    this.orderId,
    this.addedItems,
    this.cartCount,
    this.cartTotal,
    this.cartSubtotal,
    this.items,
    this.message,
  });

  ReorderModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    orderId = json['order_id'];
    if (json['added_items'] != null) {
      addedItems = <AddedItems>[];
      json['added_items'].forEach((v) {
        addedItems!.add(AddedItems.fromJson(v));
      });
    }
    cartCount = json['cart_count'];
    cartTotal = json['cart_total'];
    cartSubtotal = json['cart_subtotal'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['order_id'] = orderId;
    if (addedItems != null) {
      data['added_items'] = addedItems!.map((v) => v.toJson()).toList();
    }
    data['cart_count'] = cartCount;
    data['cart_total'] = cartTotal;
    data['cart_subtotal'] = cartSubtotal;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class AddedItems {
  int? orderItemId;
  String? cartItemKey;
  int? productId;
  int? variationId;
  int? quantity;

  AddedItems({
    this.orderItemId,
    this.cartItemKey,
    this.productId,
    this.variationId,
    this.quantity,
  });

  AddedItems.fromJson(Map<String, dynamic> json) {
    orderItemId = json['order_item_id'];
    cartItemKey = json['cart_item_key'];
    productId = json['product_id'];
    variationId = json['variation_id'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_item_id'] = orderItemId;
    data['cart_item_key'] = cartItemKey;
    data['product_id'] = productId;
    data['variation_id'] = variationId;
    data['quantity'] = quantity;
    return data;
  }
}

class Items {
  String? key;
  int? productId;
  int? variationId;
  int? quantity;
  String? productName;
  String? price;

  Items({
    this.key,
    this.productId,
    this.variationId,
    this.quantity,
    this.productName,
    this.price,
  });

  Items.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    productId = json['product_id'];
    variationId = json['variation_id'];
    quantity = json['quantity'];
    productName = json['product_name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['product_id'] = productId;
    data['variation_id'] = variationId;
    data['quantity'] = quantity;
    data['product_name'] = productName;
    data['price'] = price;
    return data;
  }
}
