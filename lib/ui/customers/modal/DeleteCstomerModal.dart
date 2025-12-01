class DeleteCstomerModal {
  bool? deleted;
  int? id;

  DeleteCstomerModal({this.deleted, this.id});

  DeleteCstomerModal.fromJson(Map<String, dynamic> json) {
    deleted = json['deleted'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['deleted'] = this.deleted;
    data['id'] = this.id;
    return data;
  }
}
