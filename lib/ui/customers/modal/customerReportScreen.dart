class CustomerReportModal {
  String? mode;
  Null? customerId;
  DateRange? dateRange;
  List<YearlyOverview>? yearlyOverview;
  String? currency;
  String? currencySymbol;
  List<Leaderboard>? leaderboard;
  List<TopProducts>? topProducts;

  CustomerReportModal(
      {this.mode,
        this.customerId,
        this.dateRange,
        this.yearlyOverview,
        this.currency,
        this.currencySymbol,
        this.leaderboard,
        this.topProducts});

  CustomerReportModal.fromJson(Map<String, dynamic> json) {
    mode = json['mode'];
    customerId = json['customer_id'];
    dateRange = json['date_range'] != null
        ? new DateRange.fromJson(json['date_range'])
        : null;
    if (json['yearly_overview'] != null) {
      yearlyOverview = <YearlyOverview>[];
      json['yearly_overview'].forEach((v) {
        yearlyOverview!.add(new YearlyOverview.fromJson(v));
      });
    }
    currency = json['currency'];
    currencySymbol = json['currency_symbol'];
    if (json['leaderboard'] != null) {
      leaderboard = <Leaderboard>[];
      json['leaderboard'].forEach((v) {
        leaderboard!.add(new Leaderboard.fromJson(v));
      });
    }
    if (json['top_products'] != null) {
      topProducts = <TopProducts>[];
      json['top_products'].forEach((v) {
        topProducts!.add(new TopProducts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mode'] = this.mode;
    data['customer_id'] = this.customerId;
    if (this.dateRange != null) {
      data['date_range'] = this.dateRange!.toJson();
    }
    if (this.yearlyOverview != null) {
      data['yearly_overview'] =
          this.yearlyOverview!.map((v) => v.toJson()).toList();
    }
    data['currency'] = this.currency;
    data['currency_symbol'] = this.currencySymbol;
    if (this.leaderboard != null) {
      data['leaderboard'] = this.leaderboard!.map((v) => v.toJson()).toList();
    }
    if (this.topProducts != null) {
      data['top_products'] = this.topProducts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DateRange {
  String? from;
  String? to;

  DateRange({this.from, this.to});

  DateRange.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['to'] = this.to;
    return data;
  }
}

class YearlyOverview {
  String? year;
  double? totalSales;
  List<Monthly>? monthly;

  YearlyOverview({this.year, this.totalSales, this.monthly});

  YearlyOverview.fromJson(Map<String, dynamic> json) {
    year = json['year'];
    totalSales = json['total_sales'];
    if (json['monthly'] != null) {
      monthly = <Monthly>[];
      json['monthly'].forEach((v) {
        monthly!.add(new Monthly.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['year'] = this.year;
    data['total_sales'] = this.totalSales;
    if (this.monthly != null) {
      data['monthly'] = this.monthly!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Monthly {
  String? month;
  double? total;

  Monthly({this.month, this.total});

  Monthly.fromJson(Map<String, dynamic> json) {
    month = json['month'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['month'] = this.month;
    data['total'] = this.total;
    return data;
  }
}

class Leaderboard {
  String? name;
  String? email;
  String? orderCount;
  String? spent;
  String? avgOrder;

  Leaderboard(
      {this.name, this.email, this.orderCount, this.spent, this.avgOrder});

  Leaderboard.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    orderCount = json['order_count'];
    spent = json['spent'];
    avgOrder = json['avg_order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['order_count'] = this.orderCount;
    data['spent'] = this.spent;
    data['avg_order'] = this.avgOrder;
    return data;
  }
}

class TopProducts {
  String? iD;
  String? postTitle;
  String? totalQty;
  String? totalSpent;
  String? image;
  String? permalink;

  TopProducts(
      {this.iD,
        this.postTitle,
        this.totalQty,
        this.totalSpent,
        this.image,
        this.permalink});

  TopProducts.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    postTitle = json['post_title'];
    totalQty = json['total_qty'];
    totalSpent = json['total_spent'];
    image = json['image'];
    permalink = json['permalink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['post_title'] = this.postTitle;
    data['total_qty'] = this.totalQty;
    data['total_spent'] = this.totalSpent;
    data['image'] = this.image;
    data['permalink'] = this.permalink;
    return data;
  }
}
