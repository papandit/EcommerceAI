// ignore_for_file: unnecessary_this, unnecessary_new, prefer_collection_literals

class HeaderFooterModel {
  String? about;
  String? category;
  String? createdAt;
  String? id;
  String? image;
  String? name;
  String? updatedAt;
  String? subcategory;

  HeaderFooterModel(
      {this.about,
      this.category,
      this.createdAt,
      this.id,
      this.image,
      this.name,
      this.updatedAt,
      this.subcategory});

  HeaderFooterModel.fromJson(Map<String, dynamic> json) {
    // Backend (MongoDB) returns lowercase keys; tolerate the old
    // capitalized Firestore-style keys too.
    about = (json['About'] ?? json['about'])?.toString();
    category = (json['Category'] ?? json['category'])?.toString();
    createdAt = (json['CreatedAt'] ?? json['createdAt'])?.toString();
    id = (json['Id'] ?? json['id'] ?? json['_id'])?.toString();
    image = (json['Image'] ?? json['image'])?.toString();
    name = (json['Name'] ?? json['name'])?.toString();
    updatedAt = (json['UpdatedAt'] ?? json['updatedAt'])?.toString();
    subcategory = (json['subcategory'] ?? json['Subcategory'])?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['About'] = this.about;
    data['Category'] = this.category;
    data['CreatedAt'] = this.createdAt;
    data['Id'] = this.id;
    data['Image'] = this.image;
    data['Name'] = this.name;
    data['UpdatedAt'] = this.updatedAt;
    data['subcategory'] = this.subcategory;
    return data;
  }
}
