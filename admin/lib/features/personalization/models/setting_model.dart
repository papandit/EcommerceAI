import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing user data.
class SettingsModel {
  final String? id;
  double taxRate;
  double shippingCost;
  double? freeShippingThreshold;
  String appName;
  String razorpaykey;
  String razorpaysecret;
  String stripepublishable;
  String stripesecret;
  String stripewebhooksecret;
  String smtphost;
  String smtpport;
  String smtpuser;
  String smtppass;
  String smtpfrom;
  String shiprocket;
  String appLogo;
  // BrandShoot AI. The key is write-only from the panel — GET never returns it,
  // only `brandshootConfigured`.
  String brandshootBase;
  String brandshootKey;
  bool brandshootConfigured;
  int tryonDailyLimit;
  int tryonMaxUploadBytes;

  /// Constructor for SettingModel.
  SettingsModel({
    this.id,
    this.taxRate = 0.0,
    this.shippingCost = 0.0,
    this.freeShippingThreshold,
    this.appName = '',
    this.razorpaykey = '',
    this.razorpaysecret = '',
    this.stripepublishable = '',
    this.stripesecret = '',
    this.stripewebhooksecret = '',
    this.smtphost = '',
    this.smtpport = '',
    this.smtpuser = '',
    this.smtppass = '',
    this.smtpfrom = '',
    this.shiprocket = '',
    this.appLogo = '',
    this.brandshootBase = '',
    this.brandshootKey = '',
    this.brandshootConfigured = false,
    this.tryonDailyLimit = 5,
    this.tryonMaxUploadBytes = 6000000,
  });

  /// Convert model to JSON structure for storing data in Firebase.
  Map<String, dynamic> toJson() {
    return {
      'taxRate': taxRate,
      'shippingCost': shippingCost,
      'freeShippingThreshold': freeShippingThreshold,
      'appName': appName,
      'razorpaykey': razorpaykey,
      'razorpaysecret': razorpaysecret,
      'stripepublishable': stripepublishable,
      'stripesecret': stripesecret,
      'stripewebhooksecret': stripewebhooksecret,
      'smtphost': smtphost,
      'smtpport': smtpport,
      'smtpuser': smtpuser,
      'smtppass': smtppass,
      'smtpfrom': smtpfrom,
      'shiprocket': shiprocket,
      'appLogo': appLogo,
      'brandshootBase': brandshootBase,
      'brandshootKey': brandshootKey,
      'tryonDailyLimit': tryonDailyLimit,
      'tryonMaxUploadBytes': tryonMaxUploadBytes,
    };
  }

  /// Build from a REST API JSON map (Node/MongoDB backend).
  factory SettingsModel.fromJson(Map<String, dynamic> data) {
    return SettingsModel(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      taxRate: (data['taxRate'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (data['shippingCost'] as num?)?.toDouble() ?? 0.0,
      freeShippingThreshold:
          (data['freeShippingThreshold'] as num?)?.toDouble() ?? 0.0,
      appName: data['appName'] ?? '',
      razorpaykey: data['razorpaykey'] ?? '',
      razorpaysecret: data['razorpaysecret'] ?? '',
      stripepublishable: data['stripepublishable'] ?? '',
      stripesecret: data['stripesecret'] ?? '',
      stripewebhooksecret: data['stripewebhooksecret'] ?? '',
      smtphost: data['smtphost'] ?? '',
      smtpport: data['smtpport'] ?? '',
      smtpuser: data['smtpuser'] ?? '',
      smtppass: data['smtppass'] ?? '',
      smtpfrom: data['smtpfrom'] ?? '',
      shiprocket: data['shiprocket'] ?? '',
      appLogo: data['appLogo'] ?? '',
      brandshootBase: data['brandshootBase'] ?? '',
      brandshootKey: data['brandshootKey'] ?? '',
      brandshootConfigured: data['brandshootConfigured'] == true,
      tryonDailyLimit:
          (num.tryParse((data['tryonDailyLimit'] ?? 5).toString()) ?? 5).toInt(),
      tryonMaxUploadBytes:
          (num.tryParse((data['tryonMaxUploadBytes'] ?? 6000000).toString()) ??
                  6000000)
              .toInt(),
    );
  }

  /// Factory method to create a SettingModel from a Firebase document snapshot.
  factory SettingsModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return SettingsModel(
        id: document.id,
        taxRate: (data['taxRate'] as num?)?.toDouble() ?? 0.0,
        shippingCost: (data['shippingCost'] as num?)?.toDouble() ?? 0.0,
        freeShippingThreshold:
            (data['freeShippingThreshold'] as num?)?.toDouble() ?? 0.0,
        appName: data.containsKey('appName') ? data['appName'] ?? '' : '',
        razorpaykey:
            data.containsKey('razorpaykey') ? data['razorpaykey'] ?? '' : '',
        razorpaysecret: data.containsKey('razorpaysecret')
            ? data['razorpaysecret'] ?? ''
            : '',
        stripepublishable: data.containsKey('stripepublishable')
            ? data['stripepublishable'] ?? ''
            : '',
        stripesecret: data.containsKey('stripesecret')
            ? data['stripesecret'] ?? ''
            : '',
        stripewebhooksecret: data.containsKey('stripewebhooksecret')
            ? data['stripewebhooksecret'] ?? ''
            : '',
        smtphost: data.containsKey('smtphost') ? data['smtphost'] ?? '' : '',
        smtpport: data.containsKey('smtpport') ? data['smtpport'] ?? '' : '',
        smtpuser: data.containsKey('smtpuser') ? data['smtpuser'] ?? '' : '',
        smtppass: data.containsKey('smtppass') ? data['smtppass'] ?? '' : '',
        smtpfrom: data.containsKey('smtpfrom') ? data['smtpfrom'] ?? '' : '',
        shiprocket:
            data.containsKey('shiprocket') ? data['shiprocket'] ?? '' : '',
        appLogo: data.containsKey('appLogo') ? data['appLogo'] ?? '' : '',
      );
    } else {
      return SettingsModel();
    }
  }
}
