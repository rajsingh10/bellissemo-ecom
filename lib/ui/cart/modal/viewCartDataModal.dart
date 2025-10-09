class ViewCartDataModal {
  List<Items>? items;
  List<Coupons>? coupons;
  Totals? totals;
  ShippingAddress? shippingAddress;
  BillingAddress? billingAddress;
  bool? needsPayment;
  bool? needsShipping;
  List<String>? paymentRequirements;
  bool? hasCalculatedShipping;
  int? itemsCount;
  int? itemsWeight;

  ViewCartDataModal({
    this.items,
    this.coupons,
    this.totals,
    this.shippingAddress,
    this.billingAddress,
    this.needsPayment,
    this.needsShipping,
    this.paymentRequirements,
    this.hasCalculatedShipping,
    this.itemsCount,
    this.itemsWeight,
  });

  ViewCartDataModal.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    if (json['coupons'] != null) {
      coupons = <Coupons>[];
      json['coupons'].forEach((v) {
        coupons!.add(Coupons.fromJson(v));
      });
    }
    totals = json['totals'] != null ? Totals.fromJson(json['totals']) : null;
    shippingAddress =
        json['shipping_address'] != null
            ? ShippingAddress.fromJson(json['shipping_address'])
            : null;
    billingAddress =
        json['billing_address'] != null
            ? BillingAddress.fromJson(json['billing_address'])
            : null;
    needsPayment = json['needs_payment'];
    needsShipping = json['needs_shipping'];
    paymentRequirements = json['payment_requirements'].cast<String>();
    hasCalculatedShipping = json['has_calculated_shipping'];
    itemsCount = json['items_count'];
    itemsWeight = json['items_weight'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (coupons != null) {
      data['coupons'] = coupons!.map((v) => v.toJson()).toList();
    }
    if (totals != null) {
      data['totals'] = totals!.toJson();
    }
    if (shippingAddress != null) {
      data['shipping_address'] = shippingAddress!.toJson();
    }
    if (billingAddress != null) {
      data['billing_address'] = billingAddress!.toJson();
    }
    data['needs_payment'] = needsPayment;
    data['needs_shipping'] = needsShipping;
    data['payment_requirements'] = paymentRequirements;
    data['has_calculated_shipping'] = hasCalculatedShipping;
    data['items_count'] = itemsCount;
    data['items_weight'] = itemsWeight;
    return data;
  }
}

class Items {
  String? key;
  int? id;
  String? type;
  int? quantity;
  QuantityLimits? quantityLimits;
  String? name;
  String? shortDescription;
  String? description;
  String? sku;
  bool? backordersAllowed;
  bool? showBackorderBadge;
  bool? soldIndividually;
  String? permalink;
  List<Images>? images;
  Prices? prices;
  String? catalogVisibility;

  Items({
    this.key,
    this.id,
    this.type,
    this.quantity,
    this.quantityLimits,
    this.name,
    this.shortDescription,
    this.description,
    this.sku,
    this.backordersAllowed,
    this.showBackorderBadge,
    this.soldIndividually,
    this.permalink,
    this.images,
    this.prices,
    this.catalogVisibility,
  });

  Items.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    id = json['id'];
    type = json['type'];
    quantity = json['quantity'];
    quantityLimits =
        json['quantity_limits'] != null
            ? QuantityLimits.fromJson(json['quantity_limits'])
            : null;
    name = json['name'];
    shortDescription = json['short_description'];
    description = json['description'];
    sku = json['sku'];
    backordersAllowed = json['backorders_allowed'];
    showBackorderBadge = json['show_backorder_badge'];
    soldIndividually = json['sold_individually'];
    permalink = json['permalink'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
    prices = json['prices'] != null ? Prices.fromJson(json['prices']) : null;
    catalogVisibility = json['catalog_visibility'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['id'] = id;
    data['type'] = type;
    data['quantity'] = quantity;
    if (quantityLimits != null) {
      data['quantity_limits'] = quantityLimits!.toJson();
    }
    data['name'] = name;
    data['short_description'] = shortDescription;
    data['description'] = description;
    data['sku'] = sku;
    data['backorders_allowed'] = backordersAllowed;
    data['show_backorder_badge'] = showBackorderBadge;
    data['sold_individually'] = soldIndividually;
    data['permalink'] = permalink;
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    if (prices != null) {
      data['prices'] = prices!.toJson();
    }
    data['catalog_visibility'] = catalogVisibility;
    return data;
  }
}

class QuantityLimits {
  int? minimum;
  int? maximum;
  int? multipleOf;
  bool? editable;

  QuantityLimits({this.minimum, this.maximum, this.multipleOf, this.editable});

  QuantityLimits.fromJson(Map<String, dynamic> json) {
    minimum = json['minimum'];
    maximum = json['maximum'];
    multipleOf = json['multiple_of'];
    editable = json['editable'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['minimum'] = minimum;
    data['maximum'] = maximum;
    data['multiple_of'] = multipleOf;
    data['editable'] = editable;
    return data;
  }
}

class Images {
  int? id;
  String? src;
  String? thumbnail;
  String? srcset;
  String? sizes;
  String? name;
  String? alt;

  Images({
    this.id,
    this.src,
    this.thumbnail,
    this.srcset,
    this.sizes,
    this.name,
    this.alt,
  });

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    src = json['src'];
    thumbnail = json['thumbnail'];
    srcset = json['srcset'];
    sizes = json['sizes'];
    name = json['name'];
    alt = json['alt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['src'] = src;
    data['thumbnail'] = thumbnail;
    data['srcset'] = srcset;
    data['sizes'] = sizes;
    data['name'] = name;
    data['alt'] = alt;
    return data;
  }
}

class Prices {
  String? price;
  String? regularPrice;
  String? salePrice;
  var priceRange;
  String? currencyCode;
  String? currencySymbol;
  int? currencyMinorUnit;
  String? currencyDecimalSeparator;
  String? currencyThousandSeparator;
  String? currencyPrefix;
  String? currencySuffix;
  RawPrices? rawPrices;

  Prices({
    this.price,
    this.regularPrice,
    this.salePrice,
    this.priceRange,
    this.currencyCode,
    this.currencySymbol,
    this.currencyMinorUnit,
    this.currencyDecimalSeparator,
    this.currencyThousandSeparator,
    this.currencyPrefix,
    this.currencySuffix,
    this.rawPrices,
  });

  Prices.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    regularPrice = json['regular_price'];
    salePrice = json['sale_price'];
    priceRange = json['price_range'];
    currencyCode = json['currency_code'];
    currencySymbol = json['currency_symbol'];
    currencyMinorUnit = json['currency_minor_unit'];
    currencyDecimalSeparator = json['currency_decimal_separator'];
    currencyThousandSeparator = json['currency_thousand_separator'];
    currencyPrefix = json['currency_prefix'];
    currencySuffix = json['currency_suffix'];
    rawPrices =
        json['raw_prices'] != null
            ? RawPrices.fromJson(json['raw_prices'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = price;
    data['regular_price'] = regularPrice;
    data['sale_price'] = salePrice;
    data['price_range'] = priceRange;
    data['currency_code'] = currencyCode;
    data['currency_symbol'] = currencySymbol;
    data['currency_minor_unit'] = currencyMinorUnit;
    data['currency_decimal_separator'] = currencyDecimalSeparator;
    data['currency_thousand_separator'] = currencyThousandSeparator;
    data['currency_prefix'] = currencyPrefix;
    data['currency_suffix'] = currencySuffix;
    if (rawPrices != null) {
      data['raw_prices'] = rawPrices!.toJson();
    }
    return data;
  }
}

class RawPrices {
  int? precision;
  String? price;
  String? regularPrice;
  String? salePrice;

  RawPrices({this.precision, this.price, this.regularPrice, this.salePrice});

  RawPrices.fromJson(Map<String, dynamic> json) {
    precision = json['precision'];
    price = json['price'];
    regularPrice = json['regular_price'];
    salePrice = json['sale_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['precision'] = precision;
    data['price'] = price;
    data['regular_price'] = regularPrice;
    data['sale_price'] = salePrice;
    return data;
  }
}

class Coupons {
  String? code;
  String? discountType;
  Couponstotal? couponstotal;

  Coupons({this.code, this.discountType, this.couponstotal});

  Coupons.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    discountType = json['discount_type'];
    couponstotal =
        json['couponstotal'] != null
            ? Couponstotal.fromJson(json['couponstotal'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['discount_type'] = discountType;
    if (couponstotal != null) {
      data['couponstotal'] = couponstotal!.toJson();
    }
    return data;
  }
}

class Couponstotal {
  String? totalDiscount;
  String? totalDiscountTax;
  String? currencyCode;
  String? currencySymbol;
  int? currencyMinorUnit;
  String? currencyDecimalSeparator;
  String? currencyThousandSeparator;
  String? currencyPrefix;
  String? currencySuffix;

  Couponstotal({
    this.totalDiscount,
    this.totalDiscountTax,
    this.currencyCode,
    this.currencySymbol,
    this.currencyMinorUnit,
    this.currencyDecimalSeparator,
    this.currencyThousandSeparator,
    this.currencyPrefix,
    this.currencySuffix,
  });

  Couponstotal.fromJson(Map<String, dynamic> json) {
    totalDiscount = json['total_discount'];
    totalDiscountTax = json['total_discount_tax'];
    currencyCode = json['currency_code'];
    currencySymbol = json['currency_symbol'];
    currencyMinorUnit = json['currency_minor_unit'];
    currencyDecimalSeparator = json['currency_decimal_separator'];
    currencyThousandSeparator = json['currency_thousand_separator'];
    currencyPrefix = json['currency_prefix'];
    currencySuffix = json['currency_suffix'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_discount'] = totalDiscount;
    data['total_discount_tax'] = totalDiscountTax;
    data['currency_code'] = currencyCode;
    data['currency_symbol'] = currencySymbol;
    data['currency_minor_unit'] = currencyMinorUnit;
    data['currency_decimal_separator'] = currencyDecimalSeparator;
    data['currency_thousand_separator'] = currencyThousandSeparator;
    data['currency_prefix'] = currencyPrefix;
    data['currency_suffix'] = currencySuffix;
    return data;
  }
}

class Totals {
  String? totalItems;
  String? totalItemsTax;
  String? totalFees;
  String? totalFeesTax;
  String? totalDiscount;
  String? totalDiscountTax;
  var totalShipping;
  var totalShippingTax;
  String? totalPrice;
  String? totalTax;

  // List<Null>? taxLines;
  String? currencyCode;
  String? currencySymbol;
  int? currencyMinorUnit;
  String? currencyDecimalSeparator;
  String? currencyThousandSeparator;
  String? currencyPrefix;
  String? currencySuffix;

  // CustomerDiscount? customerDiscount;
  var customerDiscountValue;

  Totals({
    this.totalItems,
    this.totalItemsTax,
    this.totalFees,
    this.totalFeesTax,
    this.totalDiscount,
    this.totalDiscountTax,
    this.totalShipping,
    this.totalShippingTax,
    this.totalPrice,
    this.totalTax,
    // this.taxLines,
    this.currencyCode,
    this.currencySymbol,
    this.currencyMinorUnit,
    this.currencyDecimalSeparator,
    this.currencyThousandSeparator,
    this.currencyPrefix,
    this.currencySuffix,
    // this.customerDiscount,
    this.customerDiscountValue,
  });

  Totals.fromJson(Map<String, dynamic> json) {
    totalItems = json['total_items'];
    totalItemsTax = json['total_items_tax'];
    totalFees = json['total_fees'];
    totalFeesTax = json['total_fees_tax'];
    totalDiscount = json['total_discount'];
    totalDiscountTax = json['total_discount_tax'];
    totalShipping = json['total_shipping'];
    totalShippingTax = json['total_shipping_tax'];
    totalPrice = json['total_price'];
    totalTax = json['total_tax'];
    // if (json['tax_lines'] != null) {
    //   taxLines = <Null>[];
    //   json['tax_lines'].forEach((v) {
    //     taxLines!.add(new Null.fromJson(v));
    //   });
    // }
    currencyCode = json['currency_code'];
    currencySymbol = json['currency_symbol'];
    currencyMinorUnit = json['currency_minor_unit'];
    currencyDecimalSeparator = json['currency_decimal_separator'];
    currencyThousandSeparator = json['currency_thousand_separator'];
    currencyPrefix = json['currency_prefix'];
    currencySuffix = json['currency_suffix'];
    // customerDiscount = json['customer_discount'] != null
    //     ? new CustomerDiscount.fromJson(json['customer_discount'])
    //     : null;
    customerDiscountValue = json['customer_discount_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_items'] = totalItems;
    data['total_items_tax'] = totalItemsTax;
    data['total_fees'] = totalFees;
    data['total_fees_tax'] = totalFeesTax;
    data['total_discount'] = totalDiscount;
    data['total_discount_tax'] = totalDiscountTax;
    data['total_shipping'] = totalShipping;
    data['total_shipping_tax'] = totalShippingTax;
    data['total_price'] = totalPrice;
    data['total_tax'] = totalTax;
    // if (this.taxLines != null) {
    //   data['tax_lines'] = this.taxLines!.map((v) => v.toJson()).toList();
    // }
    data['currency_code'] = currencyCode;
    data['currency_symbol'] = currencySymbol;
    data['currency_minor_unit'] = currencyMinorUnit;
    data['currency_decimal_separator'] = currencyDecimalSeparator;
    data['currency_thousand_separator'] = currencyThousandSeparator;
    data['currency_prefix'] = currencyPrefix;
    data['currency_suffix'] = currencySuffix;
    // if (this.customerDiscount != null) {
    //   data['customer_discount'] = this.customerDiscount!.toJson();
    // }
    data['customer_discount_value'] = customerDiscountValue;
    return data;
  }
}

class CustomerDiscount {
  bool? enabled;
  String? type;
  double? value;

  CustomerDiscount({this.enabled, this.type, this.value});

  CustomerDiscount.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'];
    type = json['type'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['enabled'] = enabled;
    data['type'] = type;
    data['value'] = value;
    return data;
  }
}

// class Totals {
//   String? totalItems;
//   String? totalItemsTax;
//   String? totalFees;
//   String? totalFeesTax;
//   String? totalDiscount;
//   String? totalDiscountTax;
//   var totalShipping;
//   var totalShippingTax;
//   String? totalPrice;
//   String? totalTax;
//   String? currencyCode;
//   String? currencySymbol;
//   int? currencyMinorUnit;
//   String? currencyDecimalSeparator;
//   String? currencyThousandSeparator;
//   String? currencyPrefix;
//   String? currencySuffix;
//   String? customerdiscountvalue;
//
//   Totals({
//     this.totalItems,
//     this.totalItemsTax,
//     this.totalFees,
//     this.totalFeesTax,
//     this.totalDiscount,
//     this.totalDiscountTax,
//     this.totalShipping,
//     this.totalShippingTax,
//     this.totalPrice,
//     this.totalTax,
//     this.currencyCode,
//     this.currencySymbol,
//     this.currencyMinorUnit,
//     this.currencyDecimalSeparator,
//     this.currencyThousandSeparator,
//     this.currencyPrefix,
//     this.currencySuffix,
//     this.customerdiscountvalue,
//   });
//
//   Totals.fromJson(Map<String, dynamic> json) {
//     totalItems = json['total_items'];
//     totalItemsTax = json['total_items_tax'];
//     totalFees = json['total_fees'];
//     totalFeesTax = json['total_fees_tax'];
//     totalDiscount = json['total_discount'];
//     totalDiscountTax = json['total_discount_tax'];
//     totalShipping = json['total_shipping'];
//     totalShippingTax = json['total_shipping_tax'];
//     totalPrice = json['total_price'];
//     totalTax = json['total_tax'];
//     currencyCode = json['currency_code'];
//     currencySymbol = json['currency_symbol'];
//     currencyMinorUnit = json['currency_minor_unit'];
//     currencyDecimalSeparator = json['currency_decimal_separator'];
//     currencyThousandSeparator = json['currency_thousand_separator'];
//     currencyPrefix = json['currency_prefix'];
//     currencySuffix = json['currency_suffix'];
//     customerdiscountvalue = json['customer_discount_value'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['total_items'] = totalItems;
//     data['total_items_tax'] = totalItemsTax;
//     data['total_fees'] = totalFees;
//     data['total_fees_tax'] = totalFeesTax;
//     data['total_discount'] = totalDiscount;
//     data['total_discount_tax'] = totalDiscountTax;
//     data['total_shipping'] = totalShipping;
//     data['total_shipping_tax'] = totalShippingTax;
//     data['total_price'] = totalPrice;
//     data['total_tax'] = totalTax;
//     data['currency_code'] = currencyCode;
//     data['currency_symbol'] = currencySymbol;
//     data['currency_minor_unit'] = currencyMinorUnit;
//     data['currency_decimal_separator'] = currencyDecimalSeparator;
//     data['currency_thousand_separator'] = currencyThousandSeparator;
//     data['currency_prefix'] = currencyPrefix;
//     data['currency_suffix'] = currencySuffix;
//     data['customer_discount_value'] = customerdiscountvalue;
//     return data;
//   }
// }

class ShippingAddress {
  String? firstName;
  String? lastName;
  String? company;
  String? address1;
  String? address2;
  String? city;
  String? postcode;
  String? country;
  String? state;
  String? phone;

  ShippingAddress({
    this.firstName,
    this.lastName,
    this.company,
    this.address1,
    this.address2,
    this.city,
    this.postcode,
    this.country,
    this.state,
    this.phone,
  });

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    company = json['company'];
    address1 = json['address_1'];
    address2 = json['address_2'];
    city = json['city'];
    postcode = json['postcode'];
    country = json['country'];
    state = json['state'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['company'] = company;
    data['address_1'] = address1;
    data['address_2'] = address2;
    data['city'] = city;
    data['postcode'] = postcode;
    data['country'] = country;
    data['state'] = state;
    data['phone'] = phone;
    return data;
  }
}

class BillingAddress {
  String? firstName;
  String? lastName;
  String? company;
  String? address1;
  String? address2;
  String? city;
  String? postcode;
  String? country;
  String? state;
  String? email;
  String? phone;

  BillingAddress({
    this.firstName,
    this.lastName,
    this.company,
    this.address1,
    this.address2,
    this.city,
    this.postcode,
    this.country,
    this.state,
    this.email,
    this.phone,
  });

  BillingAddress.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    company = json['company'];
    address1 = json['address_1'];
    address2 = json['address_2'];
    city = json['city'];
    postcode = json['postcode'];
    country = json['country'];
    state = json['state'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['company'] = company;
    data['address_1'] = address1;
    data['address_2'] = address2;
    data['city'] = city;
    data['postcode'] = postcode;
    data['country'] = country;
    data['state'] = state;
    data['email'] = email;
    data['phone'] = phone;
    return data;
  }
}
