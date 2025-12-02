class ProductReportModal {
  String? groupBy;
  String? from;
  String? to;
  List<Data>? data;
  List<TopCategories>? topCategories;
  String? currency;
  String? currencySymbol;

  ProductReportModal({
    this.groupBy,
    this.from,
    this.to,
    this.data,
    this.topCategories,
    this.currency,
    this.currencySymbol,
  });

  ProductReportModal.fromJson(Map<String, dynamic> json) {
    groupBy = json['group_by'];
    from = json['from'];
    to = json['to'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    if (json['top_categories'] != null) {
      topCategories = <TopCategories>[];
      json['top_categories'].forEach((v) {
        topCategories!.add(new TopCategories.fromJson(v));
      });
    }
    currency = json['currency'];
    currencySymbol = json['currency_symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['group_by'] = this.groupBy;
    data['from'] = this.from;
    data['to'] = this.to;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.topCategories != null) {
      data['top_categories'] =
          this.topCategories!.map((v) => v.toJson()).toList();
    }
    data['currency'] = this.currency;
    data['currency_symbol'] = this.currencySymbol;
    return data;
  }
}

class Data {
  String? productId;
  String? year;
  String? period;
  String? totalQty;
  String? totalRevenue;
  String? productName;
  String? image;
  var permalink;
  String? monthName;

  Data({
    this.productId,
    this.year,
    this.period,
    this.totalQty,
    this.totalRevenue,
    this.productName,
    this.image,
    this.permalink,
    this.monthName,
  });

  Data.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    year = json['year'];
    period = json['period'];
    totalQty = json['total_qty'];
    totalRevenue = json['total_revenue'];
    productName = json['product_name'];
    image = json['image'];
    permalink = json['permalink'];
    monthName = json['month_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['year'] = this.year;
    data['period'] = this.period;
    data['total_qty'] = this.totalQty;
    data['total_revenue'] = this.totalRevenue;
    data['product_name'] = this.productName;
    data['image'] = this.image;
    data['permalink'] = this.permalink;
    data['month_name'] = this.monthName;
    return data;
  }
}

class TopCategories {
  String? category;
  String? qty;
  String? revenue;

  TopCategories({this.category, this.qty, this.revenue});

  TopCategories.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    qty = json['qty'];
    revenue = json['revenue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category'] = this.category;
    data['qty'] = this.qty;
    data['revenue'] = this.revenue;
    return data;
  }
}
