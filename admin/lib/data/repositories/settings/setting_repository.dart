import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../features/personalization/models/setting_model.dart';
import '../../services/api/api_client.dart';

/// Repository for global app settings (singleton on the backend).
class SettingsRepository extends GetxController {
  static SettingsRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  /// Save settings (PUT upserts the singleton).
  Future<void> registerSettings(SettingsModel setting) async {
    try {
      await _api.put('/settings', setting.toJson());
    } catch (e) {
      throw e.toString();
    }
  }

  /// Fetch global settings.
  Future<SettingsModel> getSettings() async {
    try {
      final data = await _api.getOne('/settings');
      return SettingsModel.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Something Went Wrong: $e');
      throw 'Something Went Wrong: $e';
    }
  }

  /// Update settings.
  Future<void> updateSettingDetails(SettingsModel updatedSetting) async {
    try {
      await _api.put('/settings', updatedSetting.toJson());
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update single field(s).
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _api.put('/settings', json);
    } catch (e) {
      throw e.toString();
    }
  }
}
