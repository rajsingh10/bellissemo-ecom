class CustomerReportModal {
  String? mode;
  var customerId;
  DateRange? dateRange;
  List<YearlyOverview>? yearlyOverview;
  String? currency;
  String? currencySymbol;
  List<Leaderboard>? leaderboard;
  List<CustomerOrders>? customerOrders;

  CustomerReportModal({
    this.mode,
    this.customerId,
    this.dateRange,
    this.yearlyOverview,
    this.currency,
    this.currencySymbol,
    this.leaderboard,
    this.customerOrders,
  });

  CustomerReportModal.fromJson(Map<String, dynamic> json) {
    mode = json['mode'];
    customerId = json['customer_id'];
    dateRange =
        json['date_range'] != null
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
    if (json['customer_orders'] != null) {
      customerOrders = <CustomerOrders>[];
      json['customer_orders'].forEach((v) {
        customerOrders!.add(new CustomerOrders.fromJson(v));
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
    if (this.customerOrders != null) {
      data['customer_orders'] =
          this.customerOrders!.map((v) => v.toJson()).toList();
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
  var totalSales;
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
  var total;

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
  String? customerId;
  String? orderCount;
  String? spent;
  String? avgOrder;

  Leaderboard({
    this.name,
    this.email,
    this.customerId,
    this.orderCount,
    this.spent,
    this.avgOrder,
  });

  Leaderboard.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    customerId = json['customer_id'];
    orderCount = json['order_count'];
    spent = json['spent'];
    avgOrder = json['avg_order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['customer_id'] = this.customerId;
    data['order_count'] = this.orderCount;
    data['spent'] = this.spent;
    data['avg_order'] = this.avgOrder;
    return data;
  }
}

class CustomerOrders {
  String? orderId;
  String? orderDate;
  String? customerId;
  String? customerName;
  var customerEmail;
  String? status;
  String? totalAmount;
  String? currency;
  List<Items>? items;
  String? formattedDate;

  CustomerOrders({
    this.orderId,
    this.orderDate,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.status,
    this.totalAmount,
    this.currency,
    this.items,
    this.formattedDate,
  });

  CustomerOrders.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    orderDate = json['order_date'];
    customerId = json['customer_id'];
    customerName = json['customer_name'];
    customerEmail = json['customer_email'];
    status = json['status'];
    totalAmount = json['total_amount'];
    currency = json['currency'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    formattedDate = json['formatted_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['order_date'] = this.orderDate;
    data['customer_id'] = this.customerId;
    data['customer_name'] = this.customerName;
    data['customer_email'] = this.customerEmail;
    data['status'] = this.status;
    data['total_amount'] = this.totalAmount;
    data['currency'] = this.currency;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    data['formatted_date'] = this.formattedDate;
    return data;
  }
}

class Items {
  String? productId;
  String? postTitle;
  String? productQty;
  String? productNetRevenue;
  String? image;

  Items({
    this.productId,
    this.postTitle,
    this.productQty,
    this.productNetRevenue,
    this.image,
  });

  Items.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    postTitle = json['post_title'];
    productQty = json['product_qty'];
    productNetRevenue = json['product_net_revenue'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['post_title'] = this.postTitle;
    data['product_qty'] = this.productQty;
    data['product_net_revenue'] = this.productNetRevenue;
    data['image'] = this.image;
    return data;
  }
}
