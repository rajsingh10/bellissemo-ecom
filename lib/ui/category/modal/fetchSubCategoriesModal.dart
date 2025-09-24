class FetchSubCategoriesModal {
  int? id;
  String? name;
  String? slug;
  int? parent;
  String? description;
  String? display;
  int? menuOrder;
  int? count;

  FetchSubCategoriesModal({
    this.id,
    this.name,
    this.slug,
    this.parent,
    this.description,
    this.display,
    this.menuOrder,
    this.count,
  });

  FetchSubCategoriesModal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    parent = json['parent'];
    description = json['description'];
    display = json['display'];
    menuOrder = json['menu_order'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['parent'] = parent;
    data['description'] = description;
    data['display'] = display;
    data['menu_order'] = menuOrder;
    data['count'] = count;
    return data;
  }
}
