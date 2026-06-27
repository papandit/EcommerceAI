// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterController extends GetxController {
  List brandvalues = ["Partex", "Regal Furniture", "Hatil"];
  List<Color> colorvalues = [
    Colors.green,
    Colors.yellow,
    Colors.black,
    Colors.grey
  ];
  bool isInStock = false;

  List<String> colorvaluestext = ["Green", "Yellow", "Black", "Grey"];
  int brandvalue = 0;
  int starvalue = 6;
  int colorvalue = 0;
  // Slider syncvalues = Slider(560.0, 11503.0);
  RangeValues syncvalues = RangeValues(0.0, 100000.0);
  bool isLoader = false;
  var datas;
}
