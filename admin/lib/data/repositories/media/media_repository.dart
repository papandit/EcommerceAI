import 'dart:async';
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;
import 'package:cwt_ecommerce_admin_panel/utils/constants/enums.dart';
import 'package:get/get.dart';

import '../../../features/media/models/image_model.dart';
import '../../services/api/api_client.dart';

/// Media repository — uploads to the Node backend (`POST /api/upload/:type`),
/// which stores the file on disk (Hostinger in production) and returns its URL.
/// Replaces Firebase Storage entirely.
class MediaRepository extends GetxController {
  static MediaRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  String _inferContentType(String filename) {
    final ext =
        filename.contains('.') ? filename.toLowerCase().split('.').last : '';
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/jpeg';
    }
  }

  /// Map a storage folder ("products", "banners", …) to the upload route type.
  String _typeForPath(String path) {
    final p = path.toLowerCase();
    if (p.contains('product')) return 'product';
    if (p.contains('banner')) return 'banner';
    if (p.contains('categor')) return 'category';
    if (p.contains('brand')) return 'brand';
    if (p.contains('user') || p.contains('profile')) return 'profile';
    return 'product';
  }

  /// Upload image bytes → returns an ImageModel carrying the public URL.
  Future<ImageModel> uploadImageBytesInStorage({
    required Uint8List data,
    required String path,
    required String imageName,
  }) async {
    try {
      final url = await _api.uploadImage(
        type: _typeForPath(path),
        bytes: data,
        filename: imageName,
      );
      return ImageModel(
        url: url,
        folder: path,
        filename: imageName,
        fullPath: url,
        sizeBytes: data.length,
        contentType: _inferContentType(imageName),
        createdAt: DateTime.now(),
        mediaCategory: path,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  /// Legacy file path — reads bytes from the html.File then uploads them.
  Future<ImageModel> uploadImageFileInStorage(
      {required html.File file,
      required String path,
      required String imageName}) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoadEnd.first;
    final result = reader.result;
    Uint8List bytes;
    if (result is Uint8List) {
      bytes = result;
    } else if (result is ByteBuffer) {
      bytes = result.asUint8List();
    } else if (result is List<int>) {
      bytes = Uint8List.fromList(result);
    } else {
      throw 'Could not read the selected file.';
    }
    return uploadImageBytesInStorage(
        data: bytes, path: path, imageName: imageName);
  }

  /// The upload endpoint already records the Image document, so this is a no-op
  /// kept for call-site compatibility.
  Future<String> uploadImageFileInDatabase(ImageModel image) async {
    return image.id;
  }

  // Fetch images for the media library (by category).
  Future<List<ImageModel>> fetchImagesFromDatabase(
      MediaCategory mediaCategory, int loadCount) async {
    try {
      final list = await _api.getList('/images', query: {
        'category': mediaCategory.name.toString(),
        'limit': loadCount,
      });
      return list.map((e) => ImageModel.fromJson(e)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // Pagination: fetch the next page using a skip = already-loaded count.
  Future<List<ImageModel>> loadMoreImagesFromDatabase(
      MediaCategory mediaCategory, int loadCount, DateTime lastFetchedDate,
      {int skip = 0}) async {
    try {
      final list = await _api.getList('/images', query: {
        'category': mediaCategory.name.toString(),
        'limit': loadCount,
        'skip': skip,
      });
      return list.map((e) => ImageModel.fromJson(e)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // Fetch all images.
  Future<List<ImageModel>> fetchAllImages() async {
    try {
      final list = await _api.getList('/images');
      return list.map((e) => ImageModel.fromJson(e)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete an image record.
  Future<void> deleteFileFromStorage(ImageModel image) async {
    try {
      if (image.id.isNotEmpty) await _api.delete('/images/${image.id}');
    } catch (e) {
      throw 'Something went wrong while deleting the image.';
    }
  }
}
