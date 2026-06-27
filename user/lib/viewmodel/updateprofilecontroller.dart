import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class UpdateProfileContoller extends GetxController {
  TextEditingController namecontoller = TextEditingController();
  TextEditingController mailcontoller = TextEditingController();
  bool processloader = false;
  String? validatename(String? value) {
    const pattern = r'.{3,}';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid Name'
        : null;
  }

  String userid = '';
  int customerid = 0;
  String customerMail = '';
  String customername = '';
  String customernumber = '';
}
