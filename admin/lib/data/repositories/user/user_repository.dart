import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../features/personalization/models/user_model.dart';
import '../../../features/shop/models/order_model.dart';
import '../../services/api/api_client.dart';
import '../authentication/authentication_repository.dart';

/// Repository class for user-related operations (Node/MongoDB backend).
class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  /// Create a user record on the backend.
  Future<void> createUser(UserModel user) async {
    try {
      await _api.post('/users', user.toJson());
    } catch (e) {
      throw e.toString();
    }
  }

  /// Fetch all users (admin).
  Future<List<UserModel>> getAllUsers() async {
    try {
      final list = await _api.getList('/users');
      return list.map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) print('Something Went Wrong: $e');
      throw 'Something Went Wrong: $e';
    }
  }

  /// Fetch a single user by id.
  Future<UserModel> fetchUserDetails(String id) async {
    try {
      final data = await _api.getOne('/users/$id');
      if (data.isEmpty) return UserModel.empty();
      return UserModel.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Something Went Wrong: $e');
      throw 'Something Went Wrong: $e';
    }
  }

  /// Fetch the currently logged-in (admin) user via /auth/me.
  Future<UserModel> fetchAdminDetails() async {
    try {
      final data = await _api.getOne('/auth/me');
      if (data.isEmpty) return UserModel.empty();
      return UserModel.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Something Went Wrong: $e');
      throw 'Something Went Wrong: $e';
    }
  }

  /// Fetch orders for a user.
  Future<List<OrderModel>> fetchUserOrders(String userId) async {
    try {
      final list = await _api.getList('/users/$userId/orders');
      return list.map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) print('Something Went Wrong: $e');
      throw 'Something Went Wrong: $e';
    }
  }

  /// Update a user's full record.
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _api.put('/users/${updatedUser.id}', updatedUser.toJson());
    } catch (e) {
      throw e.toString();
    }
  }

  /// Update any field(s) on the current user.
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      final id = AuthenticationRepository.instance.currentUserId;
      await _api.put('/users/$id', json);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Delete a user.
  Future<void> deleteUser(String id) async {
    try {
      await _api.delete('/users/$id');
    } catch (e) {
      throw e.toString();
    }
  }
}
