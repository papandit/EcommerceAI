import 'package:get/get.dart';

import '../../../features/personalization/models/address_model.dart';
import '../../services/api/api_client.dart';
import '../authentication/authentication_repository.dart';

class AddressRepository extends GetxController {
  static AddressRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  // Fetch addresses for a user.
  Future<List<AddressModel>> fetchUserAddresses(String userId) async {
    try {
      final list = await _api.getList('/addresses', query: {'userId': userId});
      return list.map((e) => AddressModel.fromJson(e)).toList();
    } catch (e) {
      throw 'Something went wrong while fetching Address Information. Try again later';
    }
  }

  // Update the "SelectedAddress" field for a specific address.
  Future<void> updateSelectedField(String addressId, bool selected) async {
    try {
      await _api.put('/addresses/$addressId', {'SelectedAddress': selected});
    } catch (e) {
      throw 'Unable to update your address selection. Try again later';
    }
  }

  // Add a new address → returns new id.
  Future<String> addAddress(AddressModel address) async {
    try {
      final body = address.toJson();
      body['Userid'] = AuthenticationRepository.instance.currentUserId;
      final data = await _api.post('/addresses', body);
      return (data['id'] ?? data['_id'] ?? '').toString();
    } catch (e) {
      throw 'Something went wrong while saving Address Information. Try again later';
    }
  }
}
