// ignore_for_file: prefer_const_constructors, unnecessary_import
import 'package:get/get.dart';
import 'package:EcommerceApp/model/myaddressmodel.dart';

class MyAddressController extends GetxController {
  String accesstoken = "";
  int custmerid = 0;
  MyaddressModel? myaddressModel;
  bool isloader = false;
  var datas;
}
