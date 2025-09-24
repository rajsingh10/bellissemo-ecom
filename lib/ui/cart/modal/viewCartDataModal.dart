class ViewCartDataModal {
  List<Items>? items;
  Totals? totals;
  ShippingAddress? shippingAddress;
  BillingAddress? billingAddress;
  bool? needsPayment;
  bool? needsShipping;
  List<String>? paymentRequirements;
  bool? hasCalculatedShipping;

  ViewCartDataModal({
    this.items,
    this.totals,
    this.shippingAddress,
    this.billingAddress,
    this.needsPayment,
    this.needsShipping,
    this.paymentRequirements,
    this.hasCalculatedShipping,
  });

  ViewCartDataModal.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
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
  var lowStockRemaining;
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
    this.lowStockRemaining,
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
    lowStockRemaining = json['low_stock_remaining'];
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
    data['low_stock_remaining'] = lowStockRemaining;
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
  String? currencyCode;
  String? currencySymbol;
  int? currencyMinorUnit;
  String? currencyDecimalSeparator;
  String? currencyThousandSeparator;
  String? currencyPrefix;
  String? currencySuffix;

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
    this.currencyCode,
    this.currencySymbol,
    this.currencyMinorUnit,
    this.currencyDecimalSeparator,
    this.currencyThousandSeparator,
    this.currencyPrefix,
    this.currencySuffix,
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

class ShippingAddress {
  String? firstName;
  String? lastName;
  String? company;
  String? address1;
  String? address2;
  String? city;
  String? state;
  String? postcode;
  String? country;
  String? phone;

  ShippingAddress({
    this.firstName,
    this.lastName,
    this.company,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.postcode,
    this.country,
    this.phone,
  });

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    company = json['company'];
    address1 = json['address_1'];
    address2 = json['address_2'];
    city = json['city'];
    state = json['state'];
    postcode = json['postcode'];
    country = json['country'];
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
    data['state'] = state;
    data['postcode'] = postcode;
    data['country'] = country;
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
  String? state;
  String? postcode;
  String? country;
  String? email;
  String? phone;

  BillingAddress({
    this.firstName,
    this.lastName,
    this.company,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.postcode,
    this.country,
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
    state = json['state'];
    postcode = json['postcode'];
    country = json['country'];
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
    data['state'] = state;
    data['postcode'] = postcode;
    data['country'] = country;
    data['email'] = email;
    data['phone'] = phone;
    return data;
  }
}
