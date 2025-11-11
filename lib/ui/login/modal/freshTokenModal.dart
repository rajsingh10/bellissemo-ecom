class FreshTokenModal {
  bool? success;
  String? accessToken;
  String? refreshToken;
  int? userId;
  String? userEmail;
  String? userNicename;
  String? userDisplayName;
  int? expiresIn;

  FreshTokenModal({
    this.success,
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.userEmail,
    this.userNicename,
    this.userDisplayName,
    this.expiresIn,
  });

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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['access_token'] = accessToken;
    data['refresh_token'] = refreshToken;
    data['user_id'] = userId;
    data['user_email'] = userEmail;
    data['user_nicename'] = userNicename;
    data['user_display_name'] = userDisplayName;
    data['expires_in'] = expiresIn;
    return data;
  }
}
