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

  ViewCartDataModal(
      {this.items,
        this.coupons,
        this.totals,
        this.shippingAddress,
        this.billingAddress,
        this.needsPayment,
        this.needsShipping,
        this.paymentRequirements,
        this.hasCalculatedShipping,
        this.itemsCount,
        this.itemsWeight});

  ViewCartDataModal.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    if (json['coupons'] != null) {
      coupons = <Coupons>[];
      json['coupons'].forEach((v) {
        coupons!.add(new Coupons.fromJson(v));
      });
    }
    totals =
    json['totals'] != null ? new Totals.fromJson(json['totals']) : null;
    shippingAddress = json['shipping_address'] != null
        ? new ShippingAddress.fromJson(json['shipping_address'])
        : null;
    billingAddress = json['billing_address'] != null
        ? new BillingAddress.fromJson(json['billing_address'])
        : null;
    needsPayment = json['needs_payment'];
    needsShipping = json['needs_shipping'];
    paymentRequirements = json['payment_requirements'].cast<String>();
    hasCalculatedShipping = json['has_calculated_shipping'];
    itemsCount = json['items_count'];
    itemsWeight = json['items_weight'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    if (this.coupons != null) {
      data['coupons'] = this.coupons!.map((v) => v.toJson()).toList();
    }
    if (this.totals != null) {
      data['totals'] = this.totals!.toJson();
    }
    if (this.shippingAddress != null) {
      data['shipping_address'] = this.shippingAddress!.toJson();
    }
    if (this.billingAddress != null) {
      data['billing_address'] = this.billingAddress!.toJson();
    }
    data['needs_payment'] = this.needsPayment;
    data['needs_shipping'] = this.needsShipping;
    data['payment_requirements'] = this.paymentRequirements;
    data['has_calculated_shipping'] = this.hasCalculatedShipping;
    data['items_count'] = this.itemsCount;
    data['items_weight'] = this.itemsWeight;
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

  Items(
      {this.key,
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
        this.catalogVisibility});

  Items.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    id = json['id'];
    type = json['type'];
    quantity = json['quantity'];
    quantityLimits = json['quantity_limits'] != null
        ? new QuantityLimits.fromJson(json['quantity_limits'])
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
        images!.add(new Images.fromJson(v));
      });
    }
    prices =
    json['prices'] != null ? new Prices.fromJson(json['prices']) : null;
    catalogVisibility = json['catalog_visibility'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['id'] = this.id;
    data['type'] = this.type;
    data['quantity'] = this.quantity;
    if (this.quantityLimits != null) {
      data['quantity_limits'] = this.quantityLimits!.toJson();
    }
    data['name'] = this.name;
    data['short_description'] = this.shortDescription;
    data['description'] = this.description;
    data['sku'] = this.sku;
    data['backorders_allowed'] = this.backordersAllowed;
    data['show_backorder_badge'] = this.showBackorderBadge;
    data['sold_individually'] = this.soldIndividually;
    data['permalink'] = this.permalink;
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    if (this.prices != null) {
      data['prices'] = this.prices!.toJson();
    }
    data['catalog_visibility'] = this.catalogVisibility;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['minimum'] = this.minimum;
    data['maximum'] = this.maximum;
    data['multiple_of'] = this.multipleOf;
    data['editable'] = this.editable;
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

  Images(
      {this.id,
        this.src,
        this.thumbnail,
        this.srcset,
        this.sizes,
        this.name,
        this.alt});

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['src'] = this.src;
    data['thumbnail'] = this.thumbnail;
    data['srcset'] = this.srcset;
    data['sizes'] = this.sizes;
    data['name'] = this.name;
    data['alt'] = this.alt;
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

  Prices(
      {this.price,
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
        this.rawPrices});

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
    rawPrices = json['raw_prices'] != null
        ? new RawPrices.fromJson(json['raw_prices'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['price'] = this.price;
    data['regular_price'] = this.regularPrice;
    data['sale_price'] = this.salePrice;
    data['price_range'] = this.priceRange;
    data['currency_code'] = this.currencyCode;
    data['currency_symbol'] = this.currencySymbol;
    data['currency_minor_unit'] = this.currencyMinorUnit;
    data['currency_decimal_separator'] = this.currencyDecimalSeparator;
    data['currency_thousand_separator'] = this.currencyThousandSeparator;
    data['currency_prefix'] = this.currencyPrefix;
    data['currency_suffix'] = this.currencySuffix;
    if (this.rawPrices != null) {
      data['raw_prices'] = this.rawPrices!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['precision'] = this.precision;
    data['price'] = this.price;
    data['regular_price'] = this.regularPrice;
    data['sale_price'] = this.salePrice;
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
    couponstotal = json['couponstotal'] != null
        ? new Couponstotal.fromJson(json['couponstotal'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['discount_type'] = this.discountType;
    if (this.couponstotal != null) {
      data['couponstotal'] = this.couponstotal!.toJson();
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

  Couponstotal(
      {this.totalDiscount,
        this.totalDiscountTax,
        this.currencyCode,
        this.currencySymbol,
        this.currencyMinorUnit,
        this.currencyDecimalSeparator,
        this.currencyThousandSeparator,
        this.currencyPrefix,
        this.currencySuffix});

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_discount'] = this.totalDiscount;
    data['total_discount_tax'] = this.totalDiscountTax;
    data['currency_code'] = this.currencyCode;
    data['currency_symbol'] = this.currencySymbol;
    data['currency_minor_unit'] = this.currencyMinorUnit;
    data['currency_decimal_separator'] = this.currencyDecimalSeparator;
    data['currency_thousand_separator'] = this.currencyThousandSeparator;
    data['currency_prefix'] = this.currencyPrefix;
    data['currency_suffix'] = this.currencySuffix;
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

  Totals(
      {this.totalItems,
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
        this.currencySuffix});

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_items'] = this.totalItems;
    data['total_items_tax'] = this.totalItemsTax;
    data['total_fees'] = this.totalFees;
    data['total_fees_tax'] = this.totalFeesTax;
    data['total_discount'] = this.totalDiscount;
    data['total_discount_tax'] = this.totalDiscountTax;
    data['total_shipping'] = this.totalShipping;
    data['total_shipping_tax'] = this.totalShippingTax;
    data['total_price'] = this.totalPrice;
    data['total_tax'] = this.totalTax;
    data['currency_code'] = this.currencyCode;
    data['currency_symbol'] = this.currencySymbol;
    data['currency_minor_unit'] = this.currencyMinorUnit;
    data['currency_decimal_separator'] = this.currencyDecimalSeparator;
    data['currency_thousand_separator'] = this.currencyThousandSeparator;
    data['currency_prefix'] = this.currencyPrefix;
    data['currency_suffix'] = this.currencySuffix;
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
  String? postcode;
  String? country;
  String? state;
  String? phone;

  ShippingAddress(
      {this.firstName,
        this.lastName,
        this.company,
        this.address1,
        this.address2,
        this.city,
        this.postcode,
        this.country,
        this.state,
        this.phone});

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['company'] = this.company;
    data['address_1'] = this.address1;
    data['address_2'] = this.address2;
    data['city'] = this.city;
    data['postcode'] = this.postcode;
    data['country'] = this.country;
    data['state'] = this.state;
    data['phone'] = this.phone;
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

  BillingAddress(
      {this.firstName,
        this.lastName,
        this.company,
        this.address1,
        this.address2,
        this.city,
        this.postcode,
        this.country,
        this.state,
        this.email,
        this.phone});

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['company'] = this.company;
    data['address_1'] = this.address1;
    data['address_2'] = this.address2;
    data['city'] = this.city;
    data['postcode'] = this.postcode;
    data['country'] = this.country;
    data['state'] = this.state;
    data['email'] = this.email;
    data['phone'] = this.phone;
    return data;
  }
}
