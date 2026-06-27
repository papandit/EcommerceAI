import 'package:get/get.dart';

import '../../../features/shop/models/luxe_edit_model.dart';
import '../../services/api/api_client.dart';

/// Reads / writes the single "Luxe Edit" home section config (singleton).
class LuxeEditRepository extends GetxController {
  static LuxeEditRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  Future<LuxeEditModel> getConfig() async {
    final data = await _api.getOne('/luxeedit');
    final model = LuxeEditModel.fromMap(data);
    // Always present 4 tile slots to the editor.
    while (model.tiles.length < 4) {
      model.tiles.add(LuxeTile());
    }
    return model;
  }

  Future<void> saveConfig(LuxeEditModel model) async {
    await _api.put('/luxeedit', model.toJson());
  }
}
