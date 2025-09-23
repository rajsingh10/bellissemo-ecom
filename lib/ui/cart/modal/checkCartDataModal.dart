class CheckCartDataModal {
  bool? success;
  String? productId;
  bool? inCart;
  List<MatchingItems>? matchingItems;
  int? totalQuantity;
  String? message;

  CheckCartDataModal({
    this.success,
    this.productId,
    this.inCart,
    this.matchingItems,
    this.totalQuantity,
    this.message,
  });

  CheckCartDataModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    productId = json['product_id'];
    inCart = json['in_cart'];
    if (json['matching_items'] != null) {
      matchingItems = <MatchingItems>[];
      json['matching_items'].forEach((v) {
        matchingItems!.add(MatchingItems.fromJson(v));
      });
    }
    totalQuantity = json['total_quantity'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['product_id'] = productId;
    data['in_cart'] = inCart;
    if (matchingItems != null) {
      data['matching_items'] = matchingItems!.map((v) => v.toJson()).toList();
    }
    data['total_quantity'] = totalQuantity;
    data['message'] = message;
    return data;
  }
}

class MatchingItems {
  String? cartItemKey;
  int? productId;
  int? variationId;
  int? quantity;
  String? itemNote;

  MatchingItems({
    this.cartItemKey,
    this.productId,
    this.variationId,
    this.quantity,
    this.itemNote,
  });

  MatchingItems.fromJson(Map<String, dynamic> json) {
    cartItemKey = json['cart_item_key'];
    productId = json['product_id'];
    variationId = json['variation_id'];
    quantity = json['quantity'];
    itemNote = json['item_note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cart_item_key'] = cartItemKey;
    data['product_id'] = productId;
    data['variation_id'] = variationId;
    data['quantity'] = quantity;
    data['item_note'] = itemNote;

    return data;
  }
}
