class ProductVariationsModal {
  int? id;
  String? type;
  String? price;
  String? regularPrice;
  String? salePrice;
  String? stockStatus;
  Image? image;
  String? name;
  int? parentId;
  String? packSize;

  ProductVariationsModal({
    this.id,
    this.type,
    this.price,
    this.regularPrice,
    this.salePrice,
    this.stockStatus,
    this.image,
    this.name,
    this.parentId,
    this.packSize,
  });

  ProductVariationsModal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    price = json['price'];
    regularPrice = json['regular_price'];
    salePrice = json['sale_price'];
    stockStatus = json['stock_status'];
    image = json['image'] != null ? Image.fromJson(json['image']) : null;
    name = json['name'];
    parentId = json['parent_id'];
    packSize = json['pack_size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['price'] = price;
    data['regular_price'] = regularPrice;
    data['sale_price'] = salePrice;
    data['stock_status'] = stockStatus;
    if (image != null) {
      data['image'] = image!.toJson();
    }
    data['name'] = name;
    data['parent_id'] = parentId;
    data['pack_size'] = packSize;
    return data;
  }
}

class Image {
  int? id;
  String? dateCreated;
  String? dateCreatedGmt;
  String? dateModified;
  String? dateModifiedGmt;
  String? src;
  String? name;
  String? alt;

  Image({
    this.id,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.src,
    this.name,
    this.alt,
  });

  Image.fromJson(Map<String, dynamic> json) {
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
