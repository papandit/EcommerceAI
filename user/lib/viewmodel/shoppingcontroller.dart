import 'package:EcommerceApp/model/cartmodels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ShoppingDetailController extends GetxController {
  List<ImageProvider> imageList = <ImageProvider>[];
  TextEditingController discountCode = TextEditingController();
  int count = 1;
  bool isfavourite = false;
  var selected = false;
  double itemcost = 0.0;
  int shippingcost = 1000;
  double taxpayment = 10;
  String shiprocketid = "";
  String shiprocketpassword = "";
  double finaltotalpayment = 0.0;
  double discountedfinaltotalpayment = 0.0;
  double finaltotalpaymentold = 0.0;
  List<int> lister = [];
  List<double> amountadder = [];
  double subtotal = 0;
  double discountedsubtotal = 0.0;
  double finalsubtotalpaymentold = 0.0;
  List<Cartitems> cartitems = [];
  String cartids = '';
  String userid = "";
  bool isLoader = false;
  // TODO: load Cashfree keys from secure config — do not commit real keys.
  String Client_Secret = 'YOUR_CASHFREE_CLIENT_SECRET';
  String Client_ID = 'YOUR_CASHFREE_CLIENT_ID';
  FirebaseCartModel MyCart = FirebaseCartModel();
  String cartdata = "";
  bool progress_checkout = false;

  List<Map> cartstore = [];
}

class ManuList {
  int price;
  String name;
  String othername;
  String image;
  ManuList(
      {required this.price,
      required this.name,
      required this.othername,
      required this.image});
}

List<ManuList> ManumodelList = [
  ManuList(
      price: 240,
      name: 'Minimalist Chair',
      othername: "Regal Do Lobo",
      image: "assets/image/chairimg.png"),
  ManuList(
      price: 259,
      name: 'Hallingdal Chair',
      othername: "Hatil-Loren",
      image: "assets/image/chairimg.png"),
  ManuList(
      price: 299,
      name: 'Hiro Armchair',
      othername: "Hatil-Loren",
      image: 'assets/image/chairimg.png'),
];
