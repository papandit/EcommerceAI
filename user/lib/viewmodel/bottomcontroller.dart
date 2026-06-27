import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomController extends GetxController {
  int listdata = 0;
  String cartdata = "";
  List<dynamic> cartdataList = [];

  Future cartidchecker() async {
    final SharedPreferences perfs = await SharedPreferences.getInstance();
    cartdata = perfs.getString("CartItems") ?? "";

    if (cartdata != '') {
      cartdataList = json.decode(cartdata);

      listdata = cartdataList.length;
    }
  }
}
