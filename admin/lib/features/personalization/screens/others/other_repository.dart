import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/Models/about_us_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/Models/career_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/Models/contact_us_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/Models/free_shipping_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/Models/secure_payment_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/Models/size_chart_model.dart';
import 'package:get/get.dart';

import '../../../../../data/services/api/api_client.dart';

/// Other repository (Node/MongoDB backend).
///
/// The backend exposes a single generic `/others` collection with no fixed doc
/// IDs, so each singleton is stored/looked-up by a stable `name` key
/// (e.g. 'FREE_SHIPPING', 'About_Us') via an upsert.
class OtherRepository extends GetxController {
  // static OtherRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  /// Find the `/others` doc tagged with [key] and update it, or create one.
  Future<void> _upsert(String key, Map<String, dynamic> json) async {
    try {
      final body = {...json, 'name': key};
      final list = await _api.getList('/others');
      Map<String, dynamic>? found;
      for (final e in list) {
        if ((e['name'] ?? e['Name'])?.toString() == key) {
          found = e;
          break;
        }
      }
      if (found != null) {
        await _api.put('/others/${found['id'] ?? found['_id']}', body);
      } else {
        await _api.post('/others', body);
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> addFreeShipping(ShippingModel freeShipping) async {
    await _upsert('FREE_SHIPPING', freeShipping.toJson());
  }

  Future<void> securepayment(SecurePaymentModel securepayment) async {
    await _upsert('SECURE_PAYMENT', securepayment.toJson());
  }

  Future<void> aboutus(AboutUsModel aboutus) async {
    await _upsert('About_Us', aboutus.toJson());
  }

  Future<void> contactus(ContactUsModel contactus) async {
    await _upsert('Contact_Us', contactus.toJson());
  }

  Future<void> sizechart(SizeChartModel sizechart) async {
    await _upsert('Size_chart', sizechart.toJson());
  }

  Future<void> career(CareerModel career) async {
    await _upsert('Career', career.toJson());
  }
}
