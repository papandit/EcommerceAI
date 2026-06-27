// ignore_for_file: non_constant_identifier_names, unnecessary_this, unnecessary_new, prefer_collection_literals

class FirebaseCartModel {
  String? cartid;
  String? userid;
  List<Cartitems>? cartitems;

  FirebaseCartModel({this.cartid, this.userid, this.cartitems});

  FirebaseCartModel.fromJson(Map<String, dynamic> json) {
    cartid = json['Cartid'];
    userid = json['Userid'];
    if (json['Cartitems'] != null) {
      cartitems = <Cartitems>[];
      json['Cartitems'].forEach((v) {
        cartitems!.add(new Cartitems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Cartid'] = this.cartid;
    data['Userid'] = this.userid;
    if (this.cartitems != null) {
      data['Cartitems'] = this.cartitems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cartitems {
  String? brandName;
  String? image;
  var price;
  String? productId;
  String? title;
  int? quantity;
  String? variationId;
  String? color;
  String? size;
  Map<String, String>? selectedVariation;

  Cartitems(
      {this.brandName,
      this.image,
      this.price,
      this.productId,
      this.variationId,
      this.title,
      this.quantity,
      this.color,
      this.size,
      this.selectedVariation});

  Cartitems.fromJson(Map<String, dynamic> json) {
    brandName = json['brandName'];
    image = json['image'];
    price = json['price'];
    productId = json['productId'];
    variationId = json['variationId'];
    title = json['title'];
    quantity = json['quantity'];
    color = json['color'];
    size = json['size'];
    selectedVariation = json['selectedVariation'] != null
        ? Map<String, String>.from(json['selectedVariation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['brandName'] = this.brandName;
    data['image'] = this.image;
    data['price'] = this.price;
    data['productId'] = this.productId;
    data['variationId'] = this.variationId;
    data['title'] = this.title;
    data['quantity'] = this.quantity;
    data['size'] = this.size;
    data['color'] = this.color;
    data['selectedVariation'] = this.selectedVariation;
    return data;
  }
}
