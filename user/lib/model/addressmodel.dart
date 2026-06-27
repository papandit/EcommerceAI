// ignore_for_file: unnecessary_new, prefer_collection_literals

class FirebaseAddressModel {
  String? addresslistid;
  String? userid;
  List<Addresslist>? addresslist;

  FirebaseAddressModel({this.addresslistid, this.userid, this.addresslist});

  FirebaseAddressModel.fromJson(Map<String, dynamic> json) {
    addresslistid = json['Addresslistid'];
    userid = json['Userid'];
    if (json['Addresslist'] != null) {
      addresslist = <Addresslist>[];
      json['Addresslist'].forEach((v) {
        addresslist!.add(new Addresslist.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Addresslistid'] = addresslistid;
    data['Userid'] = userid;
    if (addresslist != null) {
      data['Addresslist'] = addresslist!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Addresslist {
  String? Id;
  String? name;
  String? street;
  String? phoneNumber;
  String? city;
  String? state;
  String? postalCode;
  String? country;
  bool? selectedAddress;
  DateTime? dateTime;

  Addresslist(
      {this.Id,
      this.name,
      this.street,
      this.city,
      this.state,
      this.phoneNumber,
      this.postalCode,
      this.country,
      this.selectedAddress,
      this.dateTime});

  Addresslist.fromJson(Map<String, dynamic> json) {

    Id = json['Id'];
    name = json['Name'];
    street = json['Street'];
    city = json['City'];
    state = json['State'];
    phoneNumber = json['PhoneNumber'];
    postalCode = json['PostalCode'];
    country = json['Country'];
    selectedAddress = json['SelectedAddress'];
    dateTime = json['DateTime'] is String
        ? DateTime.tryParse(json['DateTime'])
        : (json['DateTime'] is DateTime ? json['DateTime'] : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = Id;
    data['Name'] = name;
    data['PhoneNumber'] = phoneNumber;
    data['Street'] = street;
    data['City'] = city;
    data['State'] = state;
    data['PostalCode'] = postalCode;
    data['Country'] = country;
    data['SelectedAddress'] = selectedAddress;
    // Null-safe: backend addresses often have no DateTime; force-unwrapping here
    // threw during order serialization and silently aborted Place Order.
    data['DateTime'] = dateTime?.toIso8601String();

    return data;
  }
}
