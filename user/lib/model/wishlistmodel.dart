// ignore_for_file: unnecessary_this

class FirebasewishlistModel {
  String? wishlistid;
  String? userid;
  List<Wishitems>? wishitems;

  FirebasewishlistModel({this.wishlistid, this.userid, this.wishitems});

  FirebasewishlistModel.fromJson(Map<String, dynamic> json) {
    wishlistid = json['Wishlistid'];
    userid = json['Userid'];
    if (json['Wishlistitems'] != null) {
      wishitems = <Wishitems>[];
      json['Wishlistitems'].forEach((v) {
        wishitems!.add(Wishitems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Wishlistid'] = this.wishlistid;
    data['Userid'] = this.userid;
    if (this.wishitems != null) {
      data['Wishlistitems'] = this.wishitems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Wishitems {
  String? brandname;
  String? image;
  String? price;
  String? saleprice;
  String? productid;
  String? productname;
  String? quentity;

  Wishitems(
      {this.brandname,
      this.image,
      this.price,
      this.saleprice,
      this.productid,
      this.productname,
      this.quentity});

  Wishitems.fromJson(Map<String, dynamic> json) {
    brandname = json['brandname'];
    image = json['image'];
    price = json['price'];
    saleprice = json['saleprice'];
    productid = json['productid'];
    productname = json['productname'];
    quentity = json['quentity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['brandname'] = this.brandname;
    data['image'] = this.image;
    data['price'] = this.price;
    data['saleprice'] = this.saleprice;
    data['productid'] = this.productid;
    data['productname'] = this.productname;
    data['quentity'] = this.quentity;
    return data;
  }
}
