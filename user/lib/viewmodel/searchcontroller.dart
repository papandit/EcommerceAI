// ignore_for_file: prefer_const_constructors, unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearcherController extends GetxController {
  List brandvalues = [];
  TextEditingController searchcontoller = TextEditingController();
  List<String> widgetList = [
    'Amit Vaghani',
    'Chetan',
    'Elephant',
    'Ferry',
    'Girl',
    'Hardik',
    'Ice cream',
    'Jenis Navadiya',
    'Keval',
    'Kemish',
    'Janvi',
    'Naimish Varsani',
    'Nishant Diyora',
    'Nidhi Mangukiya',
    'Dhara Kakdiya',
    'Sagar Pithadiya',
    'Tarun Vaghasiya',
  ];
  List<String> searchlist = [];
  bool isloader = false;
  bool isFilter = false;
  var datas;
}
