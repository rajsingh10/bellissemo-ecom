class FreshTokenModal {
  bool? success;
  String? accessToken;
  String? refreshToken;
  int? userId;
  String? userEmail;
  String? userNicename;
  String? userDisplayName;
  int? expiresIn;

  FreshTokenModal(
      {this.success,
        this.accessToken,
        this.refreshToken,
        this.userId,
        this.userEmail,
        this.userNicename,
        this.userDisplayName,
        this.expiresIn});

  FreshTokenModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
    userId = json['user_id'];
    userEmail = json['user_email'];
    userNicename = json['user_nicename'];
    userDisplayName = json['user_display_name'];
    expiresIn = json['expires_in'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['access_token'] = this.accessToken;
    data['refresh_token'] = this.refreshToken;
    data['user_id'] = this.userId;
    data['user_email'] = this.userEmail;
    data['user_nicename'] = this.userNicename;
    data['user_display_name'] = this.userDisplayName;
    data['expires_in'] = this.expiresIn;
    return data;
  }
}
