// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors, avoid_print, unnecessary_import, non_constant_identifier_names, unnecessary_brace_in_string_interps

import 'package:EcommerceApp/model/cartmodels.dart';
import 'package:EcommerceApp/model/wishlistmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class Homecontoller extends GetxController {
  PageController controller = PageController(keepPage: true);
  TabController? tabController;
  TextEditingController? emailLogincontoller;

  bool isLoader = false;
  bool isLoaderintrested = false;
  bool isLoaderpopuler = false;
  String cartid = "";
  String cartdata = "";
  FirebaseCartModel MyCart = FirebaseCartModel();

  String accesstoken = "";
  int customerid = 0;
  String customerMail = '';
  String customername = '';
  String customernumber = '';
  String userid = '';
  String wishlistid = '';
  List<Wishitems> wishlist = [];
  String? validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid email address'
        : null;
  }
}
