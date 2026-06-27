// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers, non_constant_identifier_names, sized_box_for_whitespace, prefer_interpolation_to_compose_strings, unnecessary_import

import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/changepasswordcobntorller.dart';

class ChnagepasswordPage extends StatefulWidget {
  const ChnagepasswordPage({super.key});

  @override
  State<ChnagepasswordPage> createState() => _ChnagepasswordPageState();
}

class _ChnagepasswordPageState extends State<ChnagepasswordPage> {
  ChangepasswordController forgotController =
      Get.put(ChangepasswordController());
  final _currentformKey = GlobalKey<FormState>();
  final _newpasswordformKey = GlobalKey<FormState>();
  final _confirmnewpasswordformKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.BgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "ChnagePassword Password",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColor.BgColor,
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
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.88,
            child: Column(
              children: [
                currentpasswordTextfeild(),
                newpasswordTextfeildwidget(),
                confirmnewpasswordTextfeildwidget(),
                Spacer(),
                ForgotpasswordBtn(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  currentpasswordTextfeild() {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Current Password",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              key: _currentformKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                controller: forgotController.currentcontoller,
                validator: forgotController.currentPassword,
                cursorColor: AppColor.fontblack,
                decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: InputBorder.none,
                    hintText: "Enter your Password",
                    hintStyle: TextStyle(fontFamily: AppFont.lato)),
                style: TextStyle(
                    fontSize: 14,
                    color: AppColor.fontblack,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  newpasswordTextfeildwidget() {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 15, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "New Password",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              key: _newpasswordformKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                controller: forgotController.newpasswordcontoller,
                validator: forgotController.validateEmail,
                keyboardType: TextInputType.emailAddress,
                cursorColor: AppColor.fontblack,
                decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: InputBorder.none,
                    hintText: "Enter your Password",
                    hintStyle: TextStyle(fontFamily: AppFont.lato)),
                style: TextStyle(
                    fontSize: 14,
                    color: AppColor.fontblack,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  confirmnewpasswordTextfeildwidget() {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Confirm New Password",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              key: _confirmnewpasswordformKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                controller: forgotController.confirmcontoller,
                validator: forgotController.currentPassword,
                cursorColor: AppColor.fontblack,
                decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: InputBorder.none,
                    hintText: "Enter Your Password",
                    hintStyle: TextStyle(fontFamily: AppFont.lato)),
                style: TextStyle(
                    fontSize: 14,
                    color: AppColor.fontColorgrey,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ForgotpasswordBtn() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild!.unfocus();
        }
        if (forgotController.currentcontoller.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please Enter Current Password',
                style: TextStyle(color: AppColor.whiteColor),
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else if (forgotController.newpasswordcontoller.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please Enter New Password',
                style: TextStyle(color: AppColor.whiteColor),
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else if (forgotController.confirmcontoller.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please Enter Confirm Password',
                style: TextStyle(color: AppColor.whiteColor),
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else if (forgotController.newpasswordcontoller.text !=
            forgotController.confirmcontoller.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'New Password and Confirm Password Not Matched',
                style: TextStyle(color: AppColor.whiteColor),
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else if (!_currentformKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please Enter Valid Name',
                style: TextStyle(color: AppColor.whiteColor),
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else if (!_newpasswordformKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please Enter  Valid New Password',
                style: TextStyle(color: AppColor.whiteColor),
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else if (!_confirmnewpasswordformKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please Enter Valid Confirm Password',
                style: TextStyle(color: AppColor.whiteColor),
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // forgotController.Registerdata(
          //     context: context,
          //     email: forgotController.emailcontoller.text,
          //     fullname: forgotController.namecontoller.text,
          //     password: forgotController.passwordcontoller.text);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        margin: EdgeInsets.only(right: 24, left: 24, top: 14, bottom: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColor.btnColorblack),
        child: Text(
          "Change Password",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColor.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
