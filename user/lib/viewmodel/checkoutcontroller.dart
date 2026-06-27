// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps

import 'package:EcommerceApp/model/addressmodel.dart';
import 'package:EcommerceApp/model/cartmodels.dart';
import 'package:EcommerceApp/model/cupancode.dart';
import 'package:get/get.dart';

class CheckoutController extends GetxController {
  int selectedOption = 1;
  int paymentselectedOption = 0;
  // OrderModel? orderModel;
  String email = '';
  String cartid = '';
  String Name = '';
  String Number = '';
  String accesstoken = '';
  List<Addresslist> addresslist = [];

  bool isloader = false;
  String userid = "";
  String devicetoken = "";
  int finalamount = 0;
  int shippingcost = 0;
  int deliveryfee = 0;
  List<Cartitems> cartitems = [];
  bool paymentisloader = false;
  CoupanModel copunmodel = CoupanModel.empty();

  var datas;
}
