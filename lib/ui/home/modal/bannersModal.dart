class BannersModal {
  int? id;
  String? date;
  String? dateGmt;
  String? slug;
  String? status;
  String? type;
  Title? title;
  String? featuredImageUrl;

  BannersModal({
    this.id,
    this.date,
    this.dateGmt,
    this.slug,
    this.status,
    this.type,
    this.title,
    this.featuredImageUrl,
  });

  BannersModal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    dateGmt = json['date_gmt'];
    slug = json['slug'];
    status = json['status'];
    type = json['type'];
    title = json['title'] != null ? Title.fromJson(json['title']) : null;
    featuredImageUrl = json['featured_image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['date'] = date;
    data['date_gmt'] = dateGmt;
    data['slug'] = slug;
    data['status'] = status;
    data['type'] = type;
    if (title != null) {
      data['title'] = title!.toJson();
    }
    data['featured_image_url'] = featuredImageUrl;
    return data;
  }
}

class Title {
  String? rendered;

  Title({this.rendered});

  Title.fromJson(Map<String, dynamic> json) {
    rendered = json['rendered'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rendered'] = rendered;
    return data;
  }
}
