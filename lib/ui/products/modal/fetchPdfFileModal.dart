class FetchPdfFileModal {
  bool? success;
  String? type;
  String? savedUrl;
  int? bytes;
  int? count;

  FetchPdfFileModal({
    this.success,
    this.type,
    this.savedUrl,
    this.bytes,
    this.count,
  });

  FetchPdfFileModal.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    type = json['type'];
    savedUrl = json['saved_url'];
    bytes = json['bytes'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['type'] = type;
    data['saved_url'] = savedUrl;
    data['bytes'] = bytes;
    data['count'] = count;
    return data;
  }
}
