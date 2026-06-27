class MyaddressModel {
  String? sTypename;
  Customer? customer;

  MyaddressModel({this.sTypename, this.customer});

  MyaddressModel.fromJson(Map<String, dynamic> json) {
    sTypename = json['__typename'];
    customer = json['customer'] != null
        ? Customer.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['__typename'] = sTypename;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    return data;
  }
}

class Customer {
  String? sTypename;
  String? id;
  DefaultAddress? defaultAddress;
  Addresses? addresses;

  Customer({this.sTypename, this.id, this.defaultAddress, this.addresses});

  Customer.fromJson(Map<String, dynamic> json) {
    sTypename = json['__typename'];
    id = json['id'];
    defaultAddress = json['defaultAddress'] != null
        ? DefaultAddress.fromJson(json['defaultAddress'])
        : null;
    addresses = json['addresses'] != null
        ? Addresses.fromJson(json['addresses'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['__typename'] = sTypename;
    data['id'] = id;
    if (defaultAddress != null) {
      data['defaultAddress'] = defaultAddress!.toJson();
    }
    if (addresses != null) {
      data['addresses'] = addresses!.toJson();
    }
    return data;
  }
}

class DefaultAddress {
  String? sTypename;
  String? formattedArea;
  String? name;
  String? address1;
  String? address2;
  String? city;
  String? company;
  String? province;
  String? country;
  String? zip;
  String? phone;

  DefaultAddress(
      {this.sTypename,
      this.formattedArea,
      this.name,
      this.address1,
      this.address2,
      this.city,
      this.company,
      this.province,
      this.country,
      this.zip,
      this.phone});

  DefaultAddress.fromJson(Map<String, dynamic> json) {
    sTypename = json['__typename'];
    formattedArea = json['formattedArea'];
    name = json['name'];
    address1 = json['address1'];
    address2 = json['address2'];
    city = json['city'];
    company = json['company'];
    province = json['province'];
    country = json['country'];
    zip = json['zip'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['__typename'] = sTypename;
    data['formattedArea'] = formattedArea;
    data['name'] = name;
    data['address1'] = address1;
    data['address2'] = address2;
    data['city'] = city;
    data['company'] = company;
    data['province'] = province;
    data['country'] = country;
    data['zip'] = zip;
    data['phone'] = phone;
    return data;
  }
}

class Addresses {
  String? sTypename;
  List<Edges>? edges;

  Addresses({this.sTypename, this.edges});

  Addresses.fromJson(Map<String, dynamic> json) {
    sTypename = json['__typename'];
    if (json['edges'] != null) {
      edges = <Edges>[];
      json['edges'].forEach((v) {
        edges!.add(Edges.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['__typename'] = sTypename;
    if (edges != null) {
      data['edges'] = edges!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Edges {
  String? sTypename;
  Node? node;

  Edges({this.sTypename, this.node});

  Edges.fromJson(Map<String, dynamic> json) {
    sTypename = json['__typename'];
    node = json['node'] != null ? Node.fromJson(json['node']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['__typename'] = sTypename;
    if (node != null) {
      data['node'] = node!.toJson();
    }
    return data;
  }
}

class Node {
  String? sTypename;
  String? id;
  String? name;
  String? address1;
  String? address2;
  String? city;
  String? company;
  String? province;
  String? country;
  String? zip;
  String? phone;

  Node(
      {this.sTypename,
      this.id,
      this.name,
      this.address1,
      this.address2,
      this.city,
      this.company,
      this.province,
      this.country,
      this.zip,
      this.phone});

  Node.fromJson(Map<String, dynamic> json) {
    sTypename = json['__typename'];
    id = json['id'];
    name = json['name'];
    address1 = json['address1'];
    address2 = json['address2'];
    city = json['city'];
    company = json['company'];
    province = json['province'];
    country = json['country'];
    zip = json['zip'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['__typename'] = sTypename;
    data['id'] = id;
    data['name'] = name;
    data['address1'] = address1;
    data['address2'] = address2;
    data['city'] = city;
    data['company'] = company;
    data['province'] = province;
    data['country'] = country;
    data['zip'] = zip;
    data['phone'] = phone;
    return data;
  }
}
