import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker_web/image_picker_web.dart';

import '../../../../data/repositories/ai/ai_repository.dart';
import '../../../../utils/popups/loaders.dart';
import 'product_images_controller.dart';

/// Drives the "Generate AI model photos" panel on the Edit Product screen.
/// Calls our backend (which holds the BrandShoot key), polls the job, and
/// publishes the chosen results to the product gallery.
class AiPhotoshootController extends GetxController {
  static AiPhotoshootController get instance => Get.find();

  final _repo = Get.put(AiRepository());

  // photoshoot (one product on one model) | catalog (product on many models)
  final feature = 'photoshoot'.obs;
  final modelId = ''.obs; // preset BrandShoot model id
  final modelImagesB64 = <String>[].obs; // uploaded model photos (base64)

  final isGenerating = false.obs;
  final status = ''.obs; // generating | done | error
  final jobImages = <Map<String, dynamic>>[].obs; // [{fullUrl, label, ...}]
  final picked = <String>[].obs; // selected fullUrls
  final categories = <dynamic>[].obs;

  // --- Create-Product guided flow ---
  final models = <Map<String, dynamic>>[].obs; // [{id, name, imageFullUrl}]
  final loadingModels = false.obs;
  final selectedModelId = ''.obs; // chosen preset model card
  final productImageB64 = Rx<String?>(null); // uploaded/captured product photo

  String? _jobId;
  Timer? _poll;

  @override
  void onClose() {
    _poll?.cancel();
    super.onClose();
  }

  Future<void> loadCategories() async {
    try {
      final data = await _repo.getCategories();
      if (data is List) categories.assignAll(data);
    } catch (_) {
      /* non-fatal — dropdown just stays empty */
    }
  }

  void togglePick(String url) {
    if (picked.contains(url)) {
      picked.remove(url);
    } else {
      picked.add(url);
    }
  }

  /// Pick one model photo (base64) for upload.
  Future<void> pickModelImage() async {
    try {
      final Uint8List? bytes = await ImagePickerWeb.getImageAsBytes();
      if (bytes == null) return;
      modelImagesB64.add(base64Encode(bytes));
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Could not read image', message: e.toString());
    }
  }

  void removeModelImage(int index) {
    if (index >= 0 && index < modelImagesB64.length) {
      modelImagesB64.removeAt(index);
    }
  }

  Future<void> start(String productId) async {
    if (isGenerating.value) return;
    if (feature.value == 'photoshoot' &&
        modelId.value.isEmpty &&
        modelImagesB64.isEmpty) {
      TLoaders.warningSnackBar(
          title: 'Pick a model',
          message: 'Choose a preset model or upload a model photo.');
      return;
    }
    if (feature.value == 'catalog' && modelImagesB64.isEmpty) {
      TLoaders.warningSnackBar(
          title: 'Add model photos',
          message: 'Upload at least one model photo for a catalog.');
      return;
    }

    try {
      isGenerating.value = true;
      status.value = 'generating';
      jobImages.clear();
      picked.clear();

      final Map<String, dynamic> res = feature.value == 'photoshoot'
          ? await _repo.startPhotoshoot(
              productId: productId,
              modelId: modelId.value.isNotEmpty ? modelId.value : null,
              modelImageB64:
                  modelImagesB64.isNotEmpty ? modelImagesB64.first : null,
            )
          : await _repo.startCatalog(
              productId: productId,
              modelImagesB64: modelImagesB64.toList(),
            );

      _jobId = (res['jobId'] ?? '').toString();
      if (_jobId!.isEmpty) {
        _stop('error');
        TLoaders.errorSnackBar(
            title: 'Failed', message: 'Could not start generation.');
        return;
      }
      _startPolling(_jobId!);
    } catch (e) {
      _stop('error');
      TLoaders.errorSnackBar(title: 'BrandShoot', message: e.toString());
    }
  }

  void _startPolling(String jobId) {
    var ticks = 0;
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(milliseconds: 2500), (t) async {
      ticks++;
      if (ticks > 80) {
        // ~3.5 min ceiling
        _stop('error');
        TLoaders.warningSnackBar(title: 'Timed out', message: 'Please try again.');
        return;
      }
      try {
        final data = await _repo.getJob(jobId);
        final imgs = (data['images'] is List)
            ? List<Map<String, dynamic>>.from(
                (data['images'] as List).map((e) => Map<String, dynamic>.from(e)))
            : <Map<String, dynamic>>[];
        // Partial images may stream in before "done".
        jobImages.assignAll(imgs.where((m) => (m['fullUrl'] ?? '').toString().isNotEmpty));
        final s = (data['status'] ?? '').toString();
        if (s == 'done') {
          _stop('done');
        } else if (s == 'error') {
          _stop('error');
          TLoaders.errorSnackBar(
              title: 'Generation failed', message: 'Please try again.');
        }
      } catch (e) {
        if (kDebugMode) print('poll error: $e');
        // transient — keep polling
      }
    });
  }

  void _stop(String finalStatus) {
    _poll?.cancel();
    _poll = null;
    status.value = finalStatus;
    isGenerating.value = false;
  }

  /// Publish the selected images to the product gallery (re-hosted server-side).
  /// Returns true on success. [onPublished] runs to let the screen refresh.
  Future<bool> publish({VoidCallback? onPublished}) async {
    if (_jobId == null || picked.isEmpty) {
      TLoaders.warningSnackBar(
          title: 'Nothing selected',
          message: 'Tick the images you want to publish.');
      return false;
    }
    try {
      final res = await _repo.publish(_jobId!, picked.toList());
      final added = res['added'] ?? picked.length;
      TLoaders.successSnackBar(
          title: 'Published',
          message: 'Added $added image(s) to the product gallery.');
      onPublished?.call();
      reset();
      return true;
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Publish failed', message: e.toString());
      return false;
    }
  }

  void reset() {
    _poll?.cancel();
    _poll = null;
    _jobId = null;
    isGenerating.value = false;
    status.value = '';
    jobImages.clear();
    picked.clear();
    modelImagesB64.clear();
    modelId.value = '';
  }

  // ===========================================================================
  // Create-Product guided flow: pick a model -> add product photo -> generate
  // the model wearing it (several poses) -> add the chosen poses to the product.
  // ===========================================================================

  /// Load the selectable preset model cards.
  Future<void> loadModels() async {
    if (models.isNotEmpty || loadingModels.value) return;
    try {
      loadingModels.value = true;
      final data = await _repo.getModels(subType: 'photoshoot');
      if (data is List) {
        models.assignAll(data.map((e) => Map<String, dynamic>.from(e)));
      }
    } catch (_) {
      /* non-fatal — the grid just stays empty */
    } finally {
      loadingModels.value = false;
    }
  }

  void selectModel(String id) => selectedModelId.value = id;

  /// Set the product photo from raw bytes (camera capture or file upload).
  void setProductImageBytes(Uint8List bytes) {
    productImageB64.value = base64Encode(bytes);
  }

  void clearProductImage() => productImageB64.value = null;

  /// Pick the product photo from a file (browser upload).
  Future<void> pickProductImageFile() async {
    try {
      final Uint8List? bytes = await ImagePickerWeb.getImageAsBytes();
      if (bytes == null) return;
      setProductImageBytes(bytes);
    } catch (e) {
      TLoaders.errorSnackBar(
          title: 'Could not read image', message: e.toString());
    }
  }

  /// Generate a photoshoot for a NEW product (product photo + selected model).
  Future<void> generateForNewProduct() async {
    if (isGenerating.value) return;
    if ((productImageB64.value ?? '').isEmpty) {
      TLoaders.warningSnackBar(
          title: 'Add a product photo',
          message: 'Upload or take a photo of the product first.');
      return;
    }
    if (selectedModelId.value.isEmpty) {
      TLoaders.warningSnackBar(
          title: 'Pick a model', message: 'Select one of the models above.');
      return;
    }
    try {
      isGenerating.value = true;
      status.value = 'generating';
      jobImages.clear();
      picked.clear();

      final res = await _repo.startPhotoshoot(
        productImageB64: productImageB64.value,
        modelId: selectedModelId.value,
      );
      _jobId = (res['jobId'] ?? '').toString();
      if (_jobId!.isEmpty) {
        _stop('error');
        TLoaders.errorSnackBar(
            title: 'Failed', message: 'Could not start generation.');
        return;
      }
      _startPolling(_jobId!);
    } catch (e) {
      _stop('error');
      TLoaders.errorSnackBar(title: 'BrandShoot', message: e.toString());
    }
  }

  /// Re-host the picked results and attach them to the new product's images
  /// (sets the thumbnail if empty, then appends to the gallery list).
  Future<void> addToProduct() async {
    if (picked.isEmpty) {
      TLoaders.warningSnackBar(
          title: 'Nothing selected',
          message: 'Tick the photos you want to add.');
      return;
    }
    try {
      final res = await _repo.rehost(picked.toList());
      final urls = (res['urls'] is List)
          ? List<String>.from((res['urls'] as List).map((e) => e.toString()))
          : <String>[];
      if (urls.isEmpty) {
        TLoaders.errorSnackBar(
            title: 'Failed', message: 'Could not save the photos.');
        return;
      }
      final imgs = Get.put(ProductImagesController());
      if ((imgs.selectedThumbnailImageUrl.value ?? '').isEmpty) {
        imgs.selectedThumbnailImageUrl.value = urls.first;
      }
      for (final u in urls) {
        if (!imgs.additionalProductImagesUrls.contains(u)) {
          imgs.additionalProductImagesUrls.add(u);
        }
      }
      TLoaders.successSnackBar(
          title: 'Added',
          message: 'Added ${urls.length} photo(s) to the product.');
      picked.clear(); // keep results visible so admin can add more / generate more
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Failed', message: e.toString());
    }
  }
}
