class AddCustomerModal {
  String? email;
  String? firstName;
  String? lastName;
  String? username;
  String? password;

  AddCustomerModal({
    this.email,
    this.firstName,
    this.lastName,
    this.username,
    this.password,
  });

  AddCustomerModal.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    username = json['username'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['username'] = this.username;
    data['password'] = this.password;
    return data;
  }
}
