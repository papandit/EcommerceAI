// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_print

import 'package:EcommerceApp/model/addressmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryAddress extends GetxController {
  TextEditingController fullnamecontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController alternativephonenumber = TextEditingController();
  TextEditingController addersscontoller = TextEditingController();
  TextEditingController statecontroller = TextEditingController();
  TextEditingController citycontroller = TextEditingController();
  TextEditingController pintcodecontroller = TextEditingController();
  TextEditingController buildnamecontroller = TextEditingController();
  TextEditingController roadareacontroller = TextEditingController();
  TextEditingController nearbyfamusmallcontroller = TextEditingController();
  int AddressId = 0;
  bool isSubmit = false;
  bool alternativeaddress = false;
  bool nearbyfamusmall = false;
  int selectedValue = 1;
  String userid = '';
  String addresslistid = '';
  List<Addresslist> addresslist = [];
  String? validatename(String? value) {
    const pattern = r'.{5,}';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid name (Must be 5 characters)'
        : null;
  }

  String? validatepincode(String? value) {
    const pattern = r'.{6,}';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid Pincode (Must be 6 characters)'
        : null;
  }

  String? validateaddresse(String? value) {
    const pattern = r'.{10,}';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid Address (Must be 10 characters)'
        : null;
  }

  String? validatephone(String? value) {
    const pattern = r'.{10,}';
    final regex = RegExp(pattern);

    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid Phone Number (Must be 10 characters)'
        : null;
  }
  // String? validateEmail(String? value) {
  //   const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
  //       r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
  //       r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
  //       r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
  //       r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
  //       r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
  //       r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
  //   final regex = RegExp(pattern);

  //   return value!.isNotEmpty && !regex.hasMatch(value)
  //       ? 'Enter a valid email address'
  //       : null;
  // }

  // String? currentPassword(String? value) {
  //   const pattern = r'.{8,}';
  //   final regex = RegExp(pattern);

  //   return value!.isNotEmpty && !regex.hasMatch(value)
  //       ? 'Enter a valid Confirm Password (Must be 8 characters)'
  //       : null;
  // }

  // String? validatennewpassword(String? value) {
  //   const pattern = r'.{8,}';
  //   final regex = RegExp(pattern);

  //   return value!.isNotEmpty && !regex.hasMatch(value)
  //       ? 'Enter a valid Password (Must be 8 characters)'
  //       : null;
  // }

  // String? validatenumber(String? value) {
  //   const pattern = r'.{10,}';
  //   final regex = RegExp(pattern);

  //   return value!.isNotEmpty && !regex.hasMatch(value)
  //       ? 'Enter a valid Phone Number'
  //       : null;
  // }
}
