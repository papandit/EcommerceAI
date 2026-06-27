class Forgetmodel {
  String? sTypename;
  CustomerRecover? customerRecover;

  Forgetmodel({this.sTypename, this.customerRecover});

  Forgetmodel.fromJson(Map<String, dynamic> json) {
    sTypename = json['__typename'];
    customerRecover = json['customerRecover'] != null
        ? CustomerRecover.fromJson(json['customerRecover'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['__typename'] = sTypename;
    if (customerRecover != null) {
      data['customerRecover'] = customerRecover!.toJson();
    }
    return data;
  }
}

class CustomerRecover {
  String? sTypename;
  List<CustomerUserErrors>? customerUserErrors;
  List<UserErrors>? userErrors;

  CustomerRecover({this.sTypename, this.customerUserErrors, this.userErrors});

  CustomerRecover.fromJson(Map<String, dynamic> json) {
    sTypename = json['__typename'];
    if (json['customerUserErrors'] != null) {
      customerUserErrors = <CustomerUserErrors>[];
      json['customerUserErrors'].forEach((v) {
        customerUserErrors!.add(CustomerUserErrors.fromJson(v));
      });
    }
    if (json['userErrors'] != null) {
      userErrors = <UserErrors>[];
      json['userErrors'].forEach((v) {
        userErrors!.add(UserErrors.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['__typename'] = sTypename;
    if (customerUserErrors != null) {
      data['customerUserErrors'] =
          customerUserErrors!.map((v) => v.toJson()).toList();
    }
    if (userErrors != null) {
      data['userErrors'] = userErrors!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Errors {
  String? message;
  List<String>? path;
  // List<Null>? locations;

  // Errors({this.message, this.path, this.locations});
  Errors({
    this.message,
    this.path,
  });

  Errors.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    path = json['path'].cast<String>();
    // if (json['locations'] != null) {
    //   locations = <Null>[];
    //   json['locations'].forEach((v) {
    //     locations!.add(new Null.fromJson(v));
    //   });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['path'] = path;
    // if (this.locations != null) {
    //   data['locations'] = this.locations!.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class CustomerUserErrors {
  String? sTypename;
  String? code;
  String? message;

  CustomerUserErrors({this.sTypename, this.code, this.message});

  CustomerUserErrors.fromJson(Map<String, dynamic> json) {
    sTypename = json['__typename'];
    code = json['code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['__typename'] = sTypename;
    data['code'] = code;
    data['message'] = message;
    return data;
  }
}

class UserErrors {
  String? sTypename;
  String? message;

  UserErrors({this.sTypename, this.message});

  UserErrors.fromJson(Map<String, dynamic> json) {
    sTypename = json['__typename'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['__typename'] = sTypename;
    data['message'] = message;
    return data;
  }
}
