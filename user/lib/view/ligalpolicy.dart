// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace

import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/ligalpolicycontroller.dart';

class LegalPolicy extends StatefulWidget {
  const LegalPolicy({super.key});

  @override
  State<LegalPolicy> createState() => _LegalPolicyState();
}

class _LegalPolicyState extends State<LegalPolicy> {
  LegalPolicyController legalPolicyController =
      Get.put(LegalPolicyController());

  @override
  void initState() {
    legalPolicyController.isLoader = true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.BgColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          backgroundColor: AppColor.BgColor,
          centerTitle: true,
          title: Text(
            "Legal Policy",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: InkWell(
              overlayColor: WidgetStatePropertyAll(Colors.white),
              onTap: () {
                WebAPPNavigation.navigateTo(context: context);
              },
              child: CommonWidget().backicon()),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
              child: HtmlWidget(legalPolicyController.getLegalPolicy)),
        ));
  }
}
