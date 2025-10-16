class ProductDetailsModal {
  int? id;
  String? name;
  String? slug;
  String? permalink;
  String? dateCreated;
  String? dateCreatedGmt;
  String? dateModified;
  String? dateModifiedGmt;
  String? type;
  String? status;
  String? catalogVisibility;
  String? description;
  String? shortDescription;
  String? sku;
  var price;
  String? regularPrice;
  String? salePrice;
  bool? onSale;
  bool? purchasable;
  String? externalUrl;
  String? buttonText;
  String? taxStatus;
  String? taxClass;
  String? packsize;
  String? currencySymbol;
  bool? manageStock;
  var stockQuantity;
  String? backorders;
  bool? backordersAllowed;
  bool? backordered;
  var lowStockAmount;
  bool? soldIndividually;
  String? weight;
  Dimensions? dimensions;
  String? averageRating;
  int? ratingCount;
  List<Categories>? categories;
  List<Images>? images;
  List<int>? variations;
  String? stockStatus;
  bool? hasOptions;
  List<AllVariations>? allVariations;

  ProductDetailsModal({
    this.id,
    this.name,
    this.slug,
    this.permalink,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.type,
    this.status,
    this.packsize,
    this.catalogVisibility,
    this.description,
    this.shortDescription,
    this.sku,
    this.price,
    this.regularPrice,
    this.salePrice,
    this.onSale,
    this.purchasable,
    this.externalUrl,
    this.buttonText,
    this.taxStatus,
    this.taxClass,
    this.currencySymbol,
    this.manageStock,
    this.stockQuantity,
    this.backorders,
    this.backordersAllowed,
    this.backordered,
    this.lowStockAmount,
    this.soldIndividually,
    this.weight,
    this.dimensions,
    this.averageRating,
    this.ratingCount,
    this.categories,
    this.images,
    this.variations,
    this.stockStatus,
    this.hasOptions,
    this.allVariations,
  });

  ProductDetailsModal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    permalink = json['permalink'];
    dateCreated = json['date_created'];
    dateCreatedGmt = json['date_created_gmt'];
    dateModified = json['date_modified'];
    packsize = json['pack_size'];
    dateModifiedGmt = json['date_modified_gmt'];
    type = json['type'];
    status = json['status'];
    currencySymbol = json['currency_symbol'];
    catalogVisibility = json['catalog_visibility'];
    description = json['description'];
    shortDescription = json['short_description'];
    sku = json['sku'];
    price = json['price'];
    regularPrice = json['regular_price'];
    salePrice = json['sale_price'];
    onSale = json['on_sale'];
    purchasable = json['purchasable'];
    externalUrl = json['external_url'];
    buttonText = json['button_text'];
    taxStatus = json['tax_status'];
    taxClass = json['tax_class'];
    manageStock = json['manage_stock'];
    stockQuantity = json['stock_quantity'];
    backorders = json['backorders'];
    backordersAllowed = json['backorders_allowed'];
    backordered = json['backordered'];
    lowStockAmount = json['low_stock_amount'];
    soldIndividually = json['sold_individually'];
    weight = json['weight'];
    dimensions =
        json['dimensions'] != null
            ? Dimensions.fromJson(json['dimensions'])
            : null;
    averageRating = json['average_rating'];
    ratingCount = json['rating_count'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
    variations = json['variations'].cast<int>();
    stockStatus = json['stock_status'];
    hasOptions = json['has_options'];
    if (json['all_variations'] != null) {
      allVariations = <AllVariations>[];
      json['all_variations'].forEach((v) {
        allVariations!.add(AllVariations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['permalink'] = permalink;
    data['date_created'] = dateCreated;
    data['date_created_gmt'] = dateCreatedGmt;
    data['date_modified'] = dateModified;
    data['pack_size'] = packsize;
    data['date_modified_gmt'] = dateModifiedGmt;
    data['type'] = type;
    data['status'] = status;
    data['catalog_visibility'] = catalogVisibility;
    data['description'] = description;
    data['short_description'] = shortDescription;
    data['sku'] = sku;
    data['price'] = price;
    data['regular_price'] = regularPrice;
    data['sale_price'] = salePrice;
    data['on_sale'] = onSale;
    data['currency_symbol'] = currencySymbol;
    data['purchasable'] = purchasable;
    data['external_url'] = externalUrl;
    data['button_text'] = buttonText;
    data['tax_status'] = taxStatus;
    data['tax_class'] = taxClass;
    data['manage_stock'] = manageStock;
    data['stock_quantity'] = stockQuantity;
    data['backorders'] = backorders;
    data['backorders_allowed'] = backordersAllowed;
    data['backordered'] = backordered;
    data['low_stock_amount'] = lowStockAmount;
    data['sold_individually'] = soldIndividually;
    data['weight'] = weight;
    if (dimensions != null) {
      data['dimensions'] = dimensions!.toJson();
    }
    data['average_rating'] = averageRating;
    data['rating_count'] = ratingCount;
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    data['variations'] = variations;
    data['stock_status'] = stockStatus;
    data['has_options'] = hasOptions;
    if (allVariations != null) {
      data['all_variations'] = allVariations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Dimensions {
  String? length;
  String? width;
  String? height;

  Dimensions({this.length, this.width, this.height});

  Dimensions.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    width = json['width'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['length'] = length;
    data['width'] = width;
    data['height'] = height;
    return data;
  }
}

class Categories {
  int? id;
  String? name;
  String? slug;

  Categories({this.id, this.name, this.slug});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    return data;
  }
}

class Images {
  int? id;
  String? dateCreated;
  String? dateCreatedGmt;
  String? dateModified;
  String? dateModifiedGmt;
  String? src;
  String? name;
  String? alt;

  Images({
    this.id,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.src,
    this.name,
    this.alt,
  });

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dateCreated = json['date_created'];
    dateCreatedGmt = json['date_created_gmt'];
    dateModified = json['date_modified'];
    dateModifiedGmt = json['date_modified_gmt'];
    src = json['src'];
    name = json['name'];
    alt = json['alt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['date_created'] = dateCreated;
    data['date_created_gmt'] = dateCreatedGmt;
    data['date_modified'] = dateModified;
    data['date_modified_gmt'] = dateModifiedGmt;
    data['src'] = src;
    data['name'] = name;
    data['alt'] = alt;
    return data;
  }
}

class AllVariations {
  int? id;
  String? price;
  String? regularPrice;
  String? salePrice;
  Attributes? attributes;
  String? stockStatus;
  var stockQuantity;
  String? sku;
  String? weight;
  Dimensions? dimensions;
  String? packSize;
  List<VariantImages>? images;

  AllVariations({
    this.id,
    this.price,
    this.regularPrice,
    this.salePrice,
    this.attributes,
    this.stockStatus,
    this.stockQuantity,
    this.sku,
    this.weight,
    this.dimensions,
    this.packSize,
    this.images,
  });

  AllVariations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    price = json['price'];
    regularPrice = json['regular_price'];
    salePrice = json['sale_price'];
    attributes =
        json['attributes'] != null
            ? Attributes.fromJson(json['attributes'])
            : null;
    stockStatus = json['stock_status'];
    stockQuantity = json['stock_quantity'];
    sku = json['sku'];
    weight = json['weight'];
    dimensions =
        json['dimensions'] != null
            ? Dimensions.fromJson(json['dimensions'])
            : null;
    packSize = json['pack_size'];
    if (json['images'] != null) {
      images = <VariantImages>[];
      json['images'].forEach((v) {
        images!.add(VariantImages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['price'] = price;
    data['regular_price'] = regularPrice;
    data['sale_price'] = salePrice;
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    data['stock_status'] = stockStatus;
    data['stock_quantity'] = stockQuantity;
    data['sku'] = sku;
    data['weight'] = weight;
    if (dimensions != null) {
      data['dimensions'] = dimensions!.toJson();
    }
    data['pack_size'] = packSize;
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Attributes {
  Map<String, String>? values;

  Attributes({this.values});

  Attributes.fromJson(Map<String, dynamic> json) {
    values = json.map((key, value) => MapEntry(key, value.toString()));
  }

  Map<String, dynamic> toJson() {
    return values ?? {};
  }

  /// Returns the first attribute key dynamically
  String? getKey() {
    if (values != null && values!.isNotEmpty) {
      return values!.keys.first;
    }
    return null;
  }

  /// Returns the first attribute value dynamically
  String? getValue() {
    if (values != null && values!.isNotEmpty) {
      return values!.values.first;
    }
    return null;
  }
}

class VariantImages {
  int? id;
  String? src;
  String? name;
  String? alt;
  int? position;

  VariantImages({this.id, this.src, this.name, this.alt, this.position});

  VariantImages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    src = json['src'];
    name = json['name'];
    alt = json['alt'];
    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['src'] = src;
    data['name'] = name;
    data['alt'] = alt;
    data['position'] = position;
    return data;
  }
}
