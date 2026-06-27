import 'package:EcommerceApp/model/cartmodels.dart';
import 'package:EcommerceApp/model/wishlistmodel.dart';

import 'api_client.dart';

/// Per-user cart / wishlist / address access against the Node/MongoDB backend
/// (`/api/me/*`). All methods are safe to call when logged out (they no-op /
/// return empty). The backend keeps a single doc per user, so we always send
/// the full list.
class UserDataApi {
  static final ApiClient _api = ApiClient.instance;

  // ----------------------------- Wishlist --------------------------------
  static Future<List<Wishitems>> getWishlist() async {
    if (!_api.hasToken) return [];
    try {
      final data = await _api.getOne('/me/wishlist');
      final items = (data['Wishlistitems'] as List?) ?? [];
      return items
          .map((e) => Wishitems.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveWishlist(List<Wishitems> items) async {
    if (!_api.hasToken) return;
    try {
      await _api.put('/me/wishlist',
          {'Wishlistitems': items.map((e) => e.toJson()).toList()});
    } catch (_) {}
  }

  // ------------------------------- Cart ----------------------------------
  static Future<List<Cartitems>> getCart() async {
    if (!_api.hasToken) return [];
    try {
      final data = await _api.getOne('/me/cart');
      final items = (data['Cartitems'] as List?) ?? [];
      return items
          .map((e) => Cartitems.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCart(List<Cartitems> items) async {
    if (!_api.hasToken) return;
    try {
      await _api
          .put('/me/cart', {'Cartitems': items.map((e) => e.toJson()).toList()});
    } catch (_) {}
  }

  // ----------------------------- Addresses -------------------------------
  static Future<List<Map<String, dynamic>>> getAddresses() async {
    if (!_api.hasToken) return [];
    try {
      final data = await _api.getOne('/me/addresses');
      final list = (data['Addresslist'] as List?) ?? [];
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAddresses(List<Map<String, dynamic>> list) async {
    if (!_api.hasToken) return;
    try {
      await _api.put('/me/addresses', {'Addresslist': list});
    } catch (_) {}
  }
}
