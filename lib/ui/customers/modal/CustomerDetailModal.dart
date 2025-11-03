class Customerdetailmodal {
  int? id;
  String? dateCreated;
  String? dateCreatedGmt;
  String? dateModified;
  String? dateModifiedGmt;
  String? email;
  String? firstName;
  String? lastName;
  String? role;
  String? username;
  Billing? billing;
  Shipping? shipping;
  bool? isPayingCustomer;
  AllMetaData? allMetaData;

  Customerdetailmodal({
    this.id,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.email,
    this.firstName,
    this.lastName,
    this.role,
    this.username,
    this.billing,
    this.shipping,
    this.isPayingCustomer,
    this.allMetaData,
  });

  Customerdetailmodal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dateCreated = json['date_created'];
    dateCreatedGmt = json['date_created_gmt'];
    dateModified = json['date_modified'];
    dateModifiedGmt = json['date_modified_gmt'];
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    role = json['role'];
    username = json['username'];
    billing =
        json['billing'] != null ? new Billing.fromJson(json['billing']) : null;
    shipping =
        json['shipping'] != null
            ? new Shipping.fromJson(json['shipping'])
            : null;
    isPayingCustomer = json['is_paying_customer'];
    allMetaData =
        json['all_meta_data'] != null
            ? new AllMetaData.fromJson(json['all_meta_data'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date_created'] = this.dateCreated;
    data['date_created_gmt'] = this.dateCreatedGmt;
    data['date_modified'] = this.dateModified;
    data['date_modified_gmt'] = this.dateModifiedGmt;
    data['email'] = this.email;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['role'] = this.role;
    data['username'] = this.username;
    if (this.billing != null) {
      data['billing'] = this.billing!.toJson();
    }
    if (this.shipping != null) {
      data['shipping'] = this.shipping!.toJson();
    }
    data['is_paying_customer'] = this.isPayingCustomer;
    if (this.allMetaData != null) {
      data['all_meta_data'] = this.allMetaData!.toJson();
    }
    return data;
  }
}

class Billing {
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

  Billing({
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

  Billing.fromJson(Map<String, dynamic> json) {
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

class Shipping {
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

  Shipping({
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

  Shipping.fromJson(Map<String, dynamic> json) {
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

class AllMetaData {
  String? nickname;
  String? firstName;
  String? lastName;
  String? description;
  String? richEditing;
  String? syntaxHighlighting;
  String? commentShortcuts;
  String? adminColor;
  String? useSsl;
  String? showAdminBarFront;
  String? locale;
  String? wpUserLevel;
  String? lastUpdate;
  String? billingFirstName;
  String? billingLastName;
  String? billingCompany;
  String? billingAddress1;
  String? billingCity;
  String? billingState;
  String? billingPostcode;
  String? billingCountry;
  String? billingEmail;
  String? billingPhone;
  String? shippingFirstName;
  String? shippingLastName;
  String? shippingCompany;
  String? shippingAddress1;
  String? shippingCity;
  String? shippingState;
  String? shippingPostcode;
  String? shippingCountry;
  String? companyName;
  String? companyRegistrationNumber;
  String? vatNumber;
  String? contactName;
  String? mobileNumber;
  String? companyAddress;

  AllMetaData({
    this.nickname,
    this.firstName,
    this.lastName,
    this.description,
    this.richEditing,
    this.syntaxHighlighting,
    this.commentShortcuts,
    this.adminColor,
    this.useSsl,
    this.showAdminBarFront,
    this.locale,
    this.wpUserLevel,
    this.lastUpdate,
    this.billingFirstName,
    this.billingLastName,
    this.billingCompany,
    this.billingAddress1,
    this.billingCity,
    this.billingState,
    this.billingPostcode,
    this.billingCountry,
    this.billingEmail,
    this.billingPhone,
    this.shippingFirstName,
    this.shippingLastName,
    this.shippingCompany,
    this.shippingAddress1,
    this.shippingCity,
    this.shippingState,
    this.shippingPostcode,
    this.shippingCountry,
    this.companyName,
    this.companyRegistrationNumber,
    this.vatNumber,
    this.contactName,
    this.mobileNumber,
    this.companyAddress,
  });

  AllMetaData.fromJson(Map<String, dynamic> json) {
    nickname = json['nickname'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    description = json['description'];
    richEditing = json['rich_editing'];
    syntaxHighlighting = json['syntax_highlighting'];
    commentShortcuts = json['comment_shortcuts'];
    adminColor = json['admin_color'];
    useSsl = json['use_ssl'];
    showAdminBarFront = json['show_admin_bar_front'];
    locale = json['locale'];
    wpUserLevel = json['wp_user_level'];
    lastUpdate = json['last_update'];
    billingFirstName = json['billing_first_name'];
    billingLastName = json['billing_last_name'];
    billingCompany = json['billing_company'];
    billingAddress1 = json['billing_address_1'];
    billingCity = json['billing_city'];
    billingState = json['billing_state'];
    billingPostcode = json['billing_postcode'];
    billingCountry = json['billing_country'];
    billingEmail = json['billing_email'];
    billingPhone = json['billing_phone'];
    shippingFirstName = json['shipping_first_name'];
    shippingLastName = json['shipping_last_name'];
    shippingCompany = json['shipping_company'];
    shippingAddress1 = json['shipping_address_1'];
    shippingCity = json['shipping_city'];
    shippingState = json['shipping_state'];
    shippingPostcode = json['shipping_postcode'];
    shippingCountry = json['shipping_country'];
    companyName = json['company_name'];
    companyRegistrationNumber = json['company_registration_number'];
    vatNumber = json['vat_number'];
    contactName = json['contact_name'];
    mobileNumber = json['mobile_number'];
    companyAddress = json['company_address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nickname'] = this.nickname;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['description'] = this.description;
    data['rich_editing'] = this.richEditing;
    data['syntax_highlighting'] = this.syntaxHighlighting;
    data['comment_shortcuts'] = this.commentShortcuts;
    data['admin_color'] = this.adminColor;
    data['use_ssl'] = this.useSsl;
    data['show_admin_bar_front'] = this.showAdminBarFront;
    data['locale'] = this.locale;
    data['wp_user_level'] = this.wpUserLevel;
    data['last_update'] = this.lastUpdate;
    data['billing_first_name'] = this.billingFirstName;
    data['billing_last_name'] = this.billingLastName;
    data['billing_company'] = this.billingCompany;
    data['billing_address_1'] = this.billingAddress1;
    data['billing_city'] = this.billingCity;
    data['billing_state'] = this.billingState;
    data['billing_postcode'] = this.billingPostcode;
    data['billing_country'] = this.billingCountry;
    data['billing_email'] = this.billingEmail;
    data['billing_phone'] = this.billingPhone;
    data['shipping_first_name'] = this.shippingFirstName;
    data['shipping_last_name'] = this.shippingLastName;
    data['shipping_company'] = this.shippingCompany;
    data['shipping_address_1'] = this.shippingAddress1;
    data['shipping_city'] = this.shippingCity;
    data['shipping_state'] = this.shippingState;
    data['shipping_postcode'] = this.shippingPostcode;
    data['shipping_country'] = this.shippingCountry;
    data['company_name'] = this.companyName;
    data['company_registration_number'] = this.companyRegistrationNumber;
    data['vat_number'] = this.vatNumber;
    data['contact_name'] = this.contactName;
    data['mobile_number'] = this.mobileNumber;
    data['company_address'] = this.companyAddress;
    return data;
  }
}
