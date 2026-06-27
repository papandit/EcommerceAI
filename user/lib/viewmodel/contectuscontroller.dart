// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_print, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/model/errorodel.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Contectuscontroller extends GetxController {
  TextEditingController emailcontoller = TextEditingController();
  TextEditingController passwordcontoller = TextEditingController();
  TextEditingController namecontoller = TextEditingController();
  TextEditingController messagecontoller = TextEditingController();
  TextEditingController numbercontoller = TextEditingController();
  late final SharedPreferences prefs;
  bool processloader = false;
  Errormodel? error;
  bool rememberauth = false;
  bool isLoggedIn = false;
  bool ispasswordvisible = false;
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

  String? validatePassword(String? value) {
    const pattern = r'.{8,}';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid Password (Must be 8 characters)'
        : null;
  }

  String? validatename(String? value) {
    const pattern = r'.{3,}';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value) ? 'Enter a Name' : null;
  }

  String? validatenumber(String? value) {
    const pattern = r'.{10,}';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid Phone Number'
        : null;
  }
}
