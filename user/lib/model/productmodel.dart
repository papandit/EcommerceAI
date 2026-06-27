// ignore_for_file: prefer_null_aware_operators

import 'package:get/get.dart';

class ProductModel {
  String id;
  int stock;
  String? sku;
  int price;
  String title;
  double salePrice;
  String thumbnail;
  bool? isFeatured;
  BrandModel? brand;
  String? categoryId;
  String? link;
  String productType;
  String? description;
  String? Stockvalue;

  List<String>? images;
  List<ProductAttributeModel>? productAttributes;
  List<ProductVariationModel>? productVariations;
  String? subCategoryName;
  String? departmentname;

  // BrandShoot AI: whether "Try it on" shows for this product, and the model
  // photos the admin generated + published (rendered in the detail carousel).
  bool? aiTryOnEnabled;
  List<AiImage>? aiGallery;

  ProductModel({
    required this.id,
    required this.title,
    required this.stock,
    required this.price,
    required this.thumbnail,
    required this.productType,
    this.sku,
    this.Stockvalue,
    this.brand,
    this.images,
    this.link,
    this.salePrice = 0.0,
    this.isFeatured,
    this.categoryId,
    this.description,
    this.productAttributes,
    this.productVariations,
    this.subCategoryName,
    this.departmentname,
    this.aiTryOnEnabled,
    this.aiGallery,
  });

  // String get formattedDate => TFormatter.formatDate(date);

  /// Create Empty func for clean code
  static ProductModel empty() => ProductModel(
      id: '', title: '', stock: 0, price: 0, thumbnail: '', productType: '');

  /// Json Format
  toJson() {
    // print("value 0 :: ${brand!.createdAt}");
    // print("value 1 :: ${brand!.updatedAt}");
    return {
      'Id': id,
      'SKU': sku,
      'Title': title,
      'Stock': stock,
      'Link': link,
      'Price': price,
      'Images': images ?? [],
      'Thumbnail': thumbnail,
      'SalePrice': salePrice,
      'Stockvalue': Stockvalue,
      'IsFeatured': isFeatured,
      'CategoryId': categoryId,
      'Brand': brand != null ? brand!.toJson() : null,
      'Description': description,
      'ProductType': productType,
      'SubCategoryName': subCategoryName,
      'Departmentname': departmentname,
      'ProductAttributes': productAttributes != null
          ? productAttributes!.map((e) => e.toJson()).toList()
          : [],
      'ProductVariations': productVariations != null
          ? productVariations!.map((e) => e.toJson()).toList()
          : [],
      'aiTryOnEnabled': aiTryOnEnabled,
      'aiGallery':
          aiGallery != null ? aiGallery!.map((e) => e.toJson()).toList() : [],
    };
  }

  /// Build from a REST API JSON map (Node/MongoDB backend). Robust to nulls and
  /// to Price arriving as int or double.
  factory ProductModel.fromJson(Map<String, dynamic> data) {
    final attrs = data['ProductAttributes'];
    final vars = data['ProductVariations'];
    return ProductModel(
      id: (data['id'] ?? data['Id'] ?? data['_id'] ?? '').toString(),
      title: data['Title'] ?? '',
      price: (num.tryParse((data['Price'] ?? 0).toString()) ?? 0).toInt(),
      sku: data['SKU'] ?? '',
      stock: (num.tryParse((data['Stock'] ?? 0).toString()) ?? 0).toInt(),
      isFeatured: data['IsFeatured'] ?? false,
      salePrice: double.tryParse((data['SalePrice'] ?? 0).toString()) ?? 0,
      thumbnail: data['Thumbnail'] ?? '',
      categoryId: data['CategoryId'] ?? '',
      link: data['Link'] ?? '',
      Stockvalue: data['Stockvalue'] ?? '',
      description: data['Description'] ?? '',
      productType: data['ProductType'] ?? '',
      subCategoryName: data['SubCategoryName'] ?? '',
      departmentname: data['Departmentname'] ?? '',
      brand: (data['Brand'] is Map)
          ? BrandModel.fromJson(Map<String, dynamic>.from(data['Brand']))
          : null,
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      aiTryOnEnabled:
          data['aiTryOnEnabled'] is bool ? data['aiTryOnEnabled'] : true,
      aiGallery: (data['aiGallery'] is List)
          ? (data['aiGallery'] as List)
              .map((e) => AiImage.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      productAttributes: (attrs is List)
          ? attrs
              .map((e) =>
                  ProductAttributeModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      productVariations: (vars is List)
          ? vars
              .map((e) =>
                  ProductVariationModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }
}

/// A BrandShoot-generated model photo published to a product (rendered in the
/// detail carousel alongside the normal product images).
class AiImage {
  final String fullUrl;
  final String label;
  final String source; // photoshoot | catalog
  final String? modelId;
  final String? scenarioId;

  AiImage({
    required this.fullUrl,
    this.label = '',
    this.source = '',
    this.modelId,
    this.scenarioId,
  });

  Map<String, dynamic> toJson() => {
        'fullUrl': fullUrl,
        'label': label,
        'source': source,
        'modelId': modelId,
        'scenarioId': scenarioId,
      };

  factory AiImage.fromJson(Map<String, dynamic> data) => AiImage(
        fullUrl: (data['fullUrl'] ?? '').toString(),
        label: (data['label'] ?? '').toString(),
        source: (data['source'] ?? '').toString(),
        modelId: data['modelId']?.toString(),
        scenarioId: data['scenarioId']?.toString(),
      );
}

class ProductVariationModel {
  final String id;
  String sku;
  Rx<String> image;
  String? description;
  double price;
  double salePrice;
  int stock;
  Map<String, String> attributeValues;

  ProductVariationModel({
    required this.id,
    this.sku = '',
    String image = '',
    this.description = '',
    this.price = 0.0,
    this.salePrice = 0.0,
    this.stock = 0,
    required this.attributeValues,
  }) : image = image.obs;

  /// Create Empty func for clean code
  static ProductVariationModel empty() =>
      ProductVariationModel(id: '', attributeValues: {});

  /// Json Format
  toJson() {
    return {
      'Id': id,
      'Image': image.value,
      'Description': description,
      'Price': price,
      'SalePrice': salePrice,
      'SKU': sku,
      'Stock': stock,
      'AttributeValues': attributeValues,
    };
  }

  /// Map Json oriented document snapshot from Firebase to Model
  factory ProductVariationModel.fromJson(Map<String, dynamic> document) {
    final data = document;
    if (data.isEmpty) return ProductVariationModel.empty();
    return ProductVariationModel(
      id: data['Id'] ?? '',
      price: double.parse((data['Price'] ?? 0.0).toString()),
      sku: data['SKU'] ?? '',
      description: data['Description'] ?? '',
      stock: data['Stock'] ?? 0,
      salePrice: double.parse((data['SalePrice'] ?? 0.0).toString()),
      image: data['Image'] ?? '',
      attributeValues: Map<String, String>.from(data['AttributeValues']),
    );
  }
}

class ProductAttributeModel {
  String? name;
  final List<String>? values;

  ProductAttributeModel({this.name, this.values});

  /// Json Format
  toJson() {
    return {'Name': name, 'Values': values};
  }

  /// Map Json oriented document snapshot from Firebase to Model
  factory ProductAttributeModel.fromJson(Map<String, dynamic> document) {
    final data = document;

    if (data.isEmpty) return ProductAttributeModel();

    return ProductAttributeModel(
      name: data.containsKey('Name') ? data['Name'] : '',
      values: List<String>.from(data['Values']),
    );
  }
}

class BrandModel {
  String id;
  String name;
  String image;
  bool isFeatured;
  int? productsCount;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Not mapped
  List<CategoryModel>? brandCategories;

  BrandModel({
    required this.id,
    required this.image,
    required this.name,
    this.isFeatured = false,
    this.productsCount,
    this.createdAt,
    this.updatedAt,
    this.brandCategories,
  });

  /// Empty Helper Function
  static BrandModel empty() => BrandModel(id: '', image: '', name: '');

  // String get formattedDate => TFormatter.formatDate(createdAt);

  // String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);

  /// Convert model to Json structure so that you can store data in Firebase
  toJson() {
    return {
      'Id': id,
      'Name': name,
      'Image': image,
      'CreatedAt': (createdAt = DateTime.now())
          .toIso8601String(), // Convert DateTime to String
      'UpdatedAt': (updatedAt = DateTime.now()).toIso8601String(),
      // 'CreatedAt': createdAt,
      'IsFeatured': isFeatured,
      'ProductsCount': productsCount = 0,
      // 'UpdatedAt': updatedAt = DateTime.now(),
    };
  }

  /// Map Json oriented document snapshot from Firebase to UserModel
  factory BrandModel.fromJson(Map<String, dynamic> document) {
    final data = document;
    if (data.isEmpty) return BrandModel.empty();

    return BrandModel(
      id: data['Id'] ?? '',
      name: data['Name'] ?? '',
      image: data['Image'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      productsCount: int.parse((data['ProductsCount'] ?? 0).toString()),
      // createdAt:
      //     data.containsKey('CreatedAt') ? data['CreatedAt']?.toDate() : null,
      // updatedAt:
      //     data.containsKey('UpdatedAt') ? data['UpdatedAt']?.toDate() : null,
      createdAt: data.containsKey('CreatedAt')
          ? (data['CreatedAt'] is String
              ? DateTime.tryParse(data['CreatedAt'])
              : (data['CreatedAt'] is DateTime ? data['CreatedAt'] : null))
          : null,
      updatedAt: data.containsKey('UpdatedAt')
          ? (data['UpdatedAt'] is String
              ? DateTime.tryParse(data['UpdatedAt'])
              : (data['UpdatedAt'] is DateTime ? data['UpdatedAt'] : null))
          : null,
    );
  }
}

class CategoryModel {
  String id;
  String name;
  String image;
  List<Subcategory>? parentId;
  bool isFeatured;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Not Mapped
  List<CategoryModel>? childCategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.isFeatured = false,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.childCategories,
  });

  // String get formattedDate => TFormatter.formatDate(createdAt);

  // String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);

  /// Empty Helper Function
  static CategoryModel empty() =>
      CategoryModel(id: '', image: '', name: '', isFeatured: false);

  /// Convert model to Json structure so that you can store data in Firebase
  toJson() {
    return {
      'id': id,
      'Name': name,
      'Image': image,
      'ParentId': parentId?.map((e) => e.toJson()).toList(),
      'IsFeatured': isFeatured,
      'CreatedAt': (createdAt = DateTime.now()).toIso8601String(),
      'UpdatedAt': (updatedAt = DateTime.now()).toIso8601String(),
    };
  }

  /// Build from a REST API JSON map (Node/MongoDB backend).
  factory CategoryModel.fromJson(Map<String, dynamic> data) {
    DateTime? d(dynamic v) =>
        (v is String) ? DateTime.tryParse(v) : null;
    return CategoryModel(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      name: data['Name'] ?? '',
      image: data['Image'] ?? '',
      parentId: data['ParentId'] is List
          ? (data['ParentId'] as List)
              .map((e) => Subcategory.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
      isFeatured: data['IsFeatured'] ?? false,
      createdAt: d(data['CreatedAt'] ?? data['createdAt']),
      updatedAt: d(data['UpdatedAt'] ?? data['updatedAt']),
    );
  }

}

class Subcategory {
  String? id;
  String? name;

  Subcategory({this.id, this.name});

  Subcategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
  static Subcategory empty() => Subcategory(id: '', name: '');

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
