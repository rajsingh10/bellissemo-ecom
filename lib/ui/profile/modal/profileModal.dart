class ProfileModal {
  int? id;
  String? username;
  String? name;
  String? firstName;
  String? lastName;
  String? email;
  String? url;
  String? description;
  String? nickname;
  String? slug;
  AvatarUrls? avatarUrls;

  ProfileModal({
    this.id,
    this.username,
    this.name,
    this.firstName,
    this.lastName,
    this.email,
    this.url,
    this.description,
    this.nickname,
    this.slug,
    this.avatarUrls,
  });

  ProfileModal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    name = json['name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    url = json['url'];
    description = json['description'];
    nickname = json['nickname'];
    slug = json['slug'];
    avatarUrls =
        json['avatar_urls'] != null
            ? AvatarUrls.fromJson(json['avatar_urls'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['name'] = name;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['url'] = url;
    data['description'] = description;
    data['nickname'] = nickname;
    data['slug'] = slug;
    if (avatarUrls != null) {
      data['avatar_urls'] = avatarUrls!.toJson();
    }
    return data;
  }
}

class AvatarUrls {
  String? s24;
  String? s48;
  String? s96;

  AvatarUrls({this.s24, this.s48, this.s96});

  AvatarUrls.fromJson(Map<String, dynamic> json) {
    s24 = json['24'];
    s48 = json['48'];
    s96 = json['96'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['24'] = s24;
    data['48'] = s48;
    data['96'] = s96;
    return data;
  }
}
