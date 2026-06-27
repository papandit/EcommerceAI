// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewPasswordController extends GetxController {
  TextEditingController currentcontoller = TextEditingController();
  TextEditingController newpasswordcontoller = TextEditingController();
  TextEditingController confirmcontoller = TextEditingController();
  bool rememberauth = false;

  String? currentPassword(String? value) {
    const pattern = r'.{8,}';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid Confirm Password (Must be 8 characters)'
        : null;
  }

  String? validatennewpassword(String? value) {
    const pattern = r'.{8,}';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid Password (Must be 8 characters)'
        : null;
  }

  String? validatenumber(String? value) {
    const pattern = r'.{10,}';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid Phone Number'
        : null;
  }
}
