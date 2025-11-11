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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['username'] = username;
    data['password'] = password;
    return data;
  }
}
