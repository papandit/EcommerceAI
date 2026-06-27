// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors, avoid_print, unnecessary_import, unnecessary_brace_in_string_interps

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class MyOrderscontroller extends GetxController {
  TextEditingController searchcontoller = TextEditingController();

  int customerId = 0;
  String accessToken = '';
  String userid = '';
  bool isLoader = false;
}
