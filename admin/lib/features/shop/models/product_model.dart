// ignore_for_file: prefer_null_aware_operators

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/formatters/formatter.dart';
import 'brand_model.dart';
import 'product_attribute_model.dart';
import 'product_variation_model.dart';

class ProductModel {
  String id;
  int stock;
  String? stockvalue;
  String? sku;
  double price;
  String title;
  DateTime? date;
  double salePrice;
  String thumbnail;
  bool? isFeatured;
  BrandModel? brand;
  String? categoryId;
  String? categoryName;
  String productType;
  String? description;
  String? link;
  List<String>? images;
  List<ProductAttributeModel>? productAttributes;
  List<ProductVariationModel>? productVariations;
  String? subCategoryName;
  String? subCategoryId;
  String? departmentname;
  String? timestamp;
  // BrandShoot AI model photos published to this product. Managed server-side
  // (the publish endpoint $pushes to it), so it is intentionally NOT sent in
  // toJson — a product edit must never overwrite the gallery.
  List<AiImage>? aiGallery;

  ProductModel(
      {required this.id,
      required this.title,
      required this.stock,
      required this.price,
      required this.thumbnail,
      required this.productType,
      required this.sku,
      this.brand,
      this.date,
      this.images,
      this.salePrice = 0.0,
      this.isFeatured,
      this.categoryId,
      this.stockvalue,
      this.categoryName,
      this.description,
      this.link,
      this.productAttributes,
      this.productVariations,
      this.subCategoryName,
      this.subCategoryId,
      this.departmentname,
      this.timestamp,
      this.aiGallery});

  String get formattedDate => TFormatter.formatDate(date);

  /// Create Empty func for clean code
  static ProductModel empty() => ProductModel(
      id: '',
      title: '',
      sku: '',
      stock: 0,
      price: 0,
      thumbnail: '',
      productType: '');

  /// Json Format
  toJson() {
    return {
      'SKU': sku,
      'Title': title,
      'Stock': stock,
      'Stockvalue': stockvalue,
      'Price': price,
      'Images': images ?? [],
      'Thumbnail': thumbnail,
      'SalePrice': salePrice,
      'IsFeatured': isFeatured,
      'CategoryId': categoryId,
      'CategoryName': categoryName,
      'Brand': brand != null ? brand!.toJson() : null,
      'Description': description,
      'Link': link,
      'ProductType': productType,
      'SubCategoryName': subCategoryName,
      'SubCategoryId': subCategoryId,
      'Departmentname': departmentname,
      'timestamp': timestamp ?? Timestamp.now().toString(),
      'ProductAttributes': productAttributes != null
          ? productAttributes!.map((e) => e.toJson()).toList()
          : [],
      'ProductVariations': productVariations != null
          ? productVariations!.map((e) => e.toJson()).toList()
          : [],
    };
  }

  /// Map Json oriented document snapshot from Firebase to Model
  factory ProductModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    print("fromSnapshot ");
    final data = document.data()!;
    print("fromSnapshot = ${data['Brand']} ");
    return ProductModel(
      id: document.id,
      title: data['Title'],
      price: double.parse((data['Price'] ?? 0.0).toString()),
      sku: data['SKU'] ?? '',
      stock: data['Stock'] ?? 0,
      stockvalue: data['Stockvalue'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      salePrice: double.parse((data['SalePrice'] ?? 0.0).toString()),
      thumbnail: data['Thumbnail'] ?? '',
      categoryId: data['CategoryId'] ?? '',
      categoryName: data['CategoryName'] ?? '',
      description: data['Description'] ?? '',
      link: data['Link'] ?? '',
      productType: data['ProductType'] ?? '',
      subCategoryName: data['SubCategoryName'] ?? '',
      subCategoryId: data['SubCategoryId'] ?? '',
      departmentname: data['Departmentname'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now().toString(),
      brand: data['Brand'] != null ? BrandModel.fromJson(data['Brand']) : null,
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      productAttributes: (data['ProductAttributes'] as List<dynamic>)
          .map((e) => ProductAttributeModel.fromJson(e))
          .toList(),
      productVariations: (data['ProductVariations'] as List<dynamic>)
          .map((e) => ProductVariationModel.fromJson(e))
          .toList(),
    );
  }

  /// Build from a REST API JSON map (Node/MongoDB backend). Defensive about
  /// nulls so a single odd field never throws away the whole product list.
  factory ProductModel.fromJson(Map<String, dynamic> data) {
    final attrs = data['ProductAttributes'];
    final vars = data['ProductVariations'];
    return ProductModel(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      title: data['Title'] ?? '',
      price: double.tryParse((data['Price'] ?? 0).toString()) ?? 0,
      sku: data['SKU'] ?? '',
      stock: (data['Stock'] is num) ? (data['Stock'] as num).toInt() : int.tryParse('${data['Stock'] ?? 0}') ?? 0,
      stockvalue: data['Stockvalue'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      salePrice: double.tryParse((data['SalePrice'] ?? 0).toString()) ?? 0,
      thumbnail: data['Thumbnail'] ?? '',
      categoryId: data['CategoryId'] ?? '',
      categoryName: data['CategoryName'] ?? '',
      description: data['Description'] ?? '',
      link: data['Link'] ?? '',
      productType: data['ProductType'] ?? '',
      subCategoryName: data['SubCategoryName'] ?? '',
      subCategoryId: data['SubCategoryId'] ?? '',
      departmentname: data['Departmentname'] ?? '',
      timestamp: (data['timestamp'] ?? '').toString(),
      brand: data['Brand'] != null ? BrandModel.fromJson(data['Brand']) : null,
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      aiGallery: (data['aiGallery'] is List)
          ? (data['aiGallery'] as List)
              .map((e) => AiImage.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      productAttributes: (attrs is List)
          ? attrs.map((e) => ProductAttributeModel.fromJson(e)).toList()
          : [],
      productVariations: (vars is List)
          ? vars.map((e) => ProductVariationModel.fromJson(e)).toList()
          : [],
    );
  }

  // Map Json-oriented document snapshot from Firebase to Model
  factory ProductModel.fromQuerySnapshot(
      QueryDocumentSnapshot<Object?> document) {
    final data = document.data() as Map<String, dynamic>;
    return ProductModel(
      id: document.id,
      title: data['Title'] ?? '',
      price: double.parse((data['Price'] ?? 0.0).toString()),
      sku: data['SKU'] ?? '',
      stock: data['Stock'] ?? 0,
      stockvalue: data['Stockvalue'] ?? '',
      isFeatured: data['IsFeatured'] ?? false,
      salePrice: double.parse((data['SalePrice'] ?? 0.0).toString()),
      thumbnail: data['Thumbnail'] ?? '',
      categoryId: data['CategoryId'] ?? '',
      categoryName: data['CategoryName'] ?? '',
      description: data['Description'] ?? '',
      subCategoryId: data['SubCategoryId'] ?? '',
      subCategoryName: data['SubCategoryName'] ?? '',
      departmentname: data['Departmentname'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now().toString(),
      link: data['Link'] ?? '',
      productType: data['ProductType'] ?? '',
      brand: BrandModel.fromJson(data['Brand']),
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      productAttributes: (data['ProductAttributes'] as List<dynamic>)
          .map((e) => ProductAttributeModel.fromJson(e))
          .toList(),
      productVariations: (data['ProductVariations'] as List<dynamic>)
          .map((e) => ProductVariationModel.fromJson(e))
          .toList(),
    );
  }
}

/// A BrandShoot-generated model photo published to a product.
class AiImage {
  final String fullUrl;
  final String label;
  final String source; // photoshoot | catalog
  final String? scenarioId;

  AiImage({
    required this.fullUrl,
    this.label = '',
    this.source = '',
    this.scenarioId,
  });

  Map<String, dynamic> toJson() => {
        'fullUrl': fullUrl,
        'label': label,
        'source': source,
        'scenarioId': scenarioId,
      };

  factory AiImage.fromJson(Map<String, dynamic> data) => AiImage(
        fullUrl: (data['fullUrl'] ?? '').toString(),
        label: (data['label'] ?? '').toString(),
        source: (data['source'] ?? '').toString(),
        scenarioId: data['scenarioId']?.toString(),
      );
}
