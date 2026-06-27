class Errormodel {
  Errors? errors;

  Errormodel({this.errors});

  Errormodel.fromJson(Map<String, dynamic> json) {
    errors =
        json['errors'] != null ? Errors.fromJson(json['errors']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (errors != null) {
      data['errors'] = errors!.toJson();
    }
    return data;
  }
}

class Errors {
  List<String>? email;
  List<String>? phone;

  Errors({this.email, this.phone});

  Errors.fromJson(Map<String, dynamic> json) {
    email = json['email'].cast<String>();
    phone = json['phone'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['phone'] = phone;
    return data;
  }
}
