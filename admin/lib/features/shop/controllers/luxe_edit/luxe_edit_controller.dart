import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/luxe_edit/luxe_edit_repository.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../media/controllers/media_controller.dart';
import '../../models/luxe_edit_model.dart';

class LuxeEditController extends GetxController {
  static LuxeEditController get instance => Get.find();

  final LuxeEditRepository _repo = Get.put(LuxeEditRepository());

  final RxBool loading = false.obs;
  final RxBool saving = false.obs;

  final RxString backgroundImage = ''.obs;
  final RxBool isActive = true.obs;

  final titleC = TextEditingController();
  final subtitleC = TextEditingController();
  final buttonTextC = TextEditingController();
  final buttonLinkC = TextEditingController();

  // Four tiles.
  final List<RxString> tileImages =
      List.generate(4, (_) => ''.obs, growable: false);
  final List<TextEditingController> tileLabelC =
      List.generate(4, (_) => TextEditingController(), growable: false);
  final List<TextEditingController> tileLinkC =
      List.generate(4, (_) => TextEditingController(), growable: false);

  @override
  void onInit() {
    load();
    super.onInit();
  }

  Future<void> load() async {
    try {
      loading.value = true;
      final m = await _repo.getConfig();
      backgroundImage.value = m.backgroundImage;
      isActive.value = m.active;
      titleC.text = m.title;
      subtitleC.text = m.subtitle;
      buttonTextC.text = m.buttonText;
      buttonLinkC.text = m.buttonLink;
      for (var i = 0; i < 4; i++) {
        final t = i < m.tiles.length ? m.tiles[i] : LuxeTile();
        tileImages[i].value = t.image;
        tileLabelC[i].text = t.label;
        tileLinkC[i].text = t.link;
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      loading.value = false;
    }
  }

  Future<void> _pick(void Function(String url) onPicked) async {
    final mc = Get.put(MediaController());
    final url = await mc.pickAndUploadImage(MediaCategory.banners);
    if (url != null && url.isNotEmpty) onPicked(url);
  }

  Future<void> pickBackground() async =>
      _pick((url) => backgroundImage.value = url);

  Future<void> pickTile(int i) async =>
      _pick((url) => tileImages[i].value = url);

  Future<void> save() async {
    try {
      saving.value = true;
      final model = LuxeEditModel(
        backgroundImage: backgroundImage.value,
        title: titleC.text.trim(),
        subtitle: subtitleC.text.trim(),
        buttonText: buttonTextC.text.trim(),
        buttonLink: buttonLinkC.text.trim(),
        active: isActive.value,
        tiles: List.generate(
          4,
          (i) => LuxeTile(
            image: tileImages[i].value,
            label: tileLabelC[i].text.trim(),
            link: tileLinkC[i].text.trim(),
          ),
        ),
      );
      await _repo.saveConfig(model);
      TLoaders.successSnackBar(
          title: 'Saved', message: 'Luxe Edit section updated.');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      saving.value = false;
    }
  }
}
