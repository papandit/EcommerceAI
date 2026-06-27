// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  List<ImageProvider> imageList = <ImageProvider>[];
  int count = 1;
  int oldcount = 0;
  int amount = 90;
  bool isfavourite = false;
  bool isloder = false;
  String glbfile = "";
  String cartdata = "";
  String redomlikedata = "";
  int seens = 100;
  int likes = 100;
  String cartid = "";
  String lineid = "";
  var datas;
  bool updatecart = false;
}
