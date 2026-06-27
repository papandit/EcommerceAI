// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers, prefer_interpolation_to_compose_strings, sized_box_for_whitespace, must_be_immutable, unnecessary_import, deprecated_member_use

import 'package:EcommerceApp/helper/bottom_bar.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';

class SuccessPage extends StatefulWidget {
  SuccessPage({super.key, required this.isSuccess});
  bool? isSuccess;
  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  void initState() {
    Future.delayed(
      Duration(milliseconds: 500),
      () {
        widget.isSuccess == true ? botttomsheetsucess() : botttomsheetfaild();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        WebAPPNavigation.navigateToroute(
            context: context,
            routename: '/HomePage',
            screen: BottomBar(
              pageindex: 0,
            ));
        return Future(() => false);
      },
      child: Scaffold(
        backgroundColor: AppColor.BgColor,
        appBar: AppBar(
          centerTitle: true,
          title: widget.isSuccess == true
              ? Text(
                  "Success",
                  style: TextStyle(fontWeight: FontWeight.w500),
                )
              : Text(
                  "Failed",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          backgroundColor: AppColor.BgColor,
          leading: InkWell(
              overlayColor: WidgetStatePropertyAll(Colors.white),
              onTap: () {
                WebAPPNavigation.navigateToroute(
                    context: context,
                    routename: '/HomePage',
                    screen: BottomBar(
                      pageindex: 0,
                    ));
              },
              child: CommonWidget().backicon()),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }

  botttomsheetsucess() {
    return Get.bottomSheet(
        isScrollControlled: true,
        useRootNavigator: true,
        WillPopScope(
          onWillPop: () {
            WebAPPNavigation.navigateToroute(
                context: context,
                routename: '/HomePage',
                screen: BottomBar(
                  pageindex: 0,
                ));
            return Future(() => false);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    color: AppColor.whiteColor),
                child: Column(
                  children: [
                    Container(
                      height: 84,
                      width: 84,
                      margin: EdgeInsets.only(top: 24),
                      child: Image(
                          image:
                              AssetImage(AppImage.appIcon + "successmark.png")),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 24, left: 24, right: 24),
                      child: Text(
                        "Thank You For \n Your Order",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 24, fontFamily: AppFont.lato),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 12, left: 40, right: 40),
                      child: Text(
                        "Your order been place successfully!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, color: AppColor.fontColorgrey),
                      ),
                    ),
                    InkWell(
                      overlayColor: WidgetStatePropertyAll(Colors.white),
                      onTap: () {
                        WebAPPNavigation.navigateToroute(
                            context: context,
                            routename: '/HomePage',
                            screen: BottomBar(
                              pageindex: 0,
                            ));
                      },
                      child: Container(
                        height: 52,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 24, left: 24, right: 24),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: AppColor.imagebg, width: 1),
                            borderRadius: BorderRadius.circular(15)),
                        child: Center(
                          child: Text(
                            "Back Home",
                            style: TextStyle(
                                color: AppColor.fontColorgrey,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 24, bottom: 24),
                      child: Text(
                        "You Can Order Somethings Also",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).whenComplete(() {
      WebAPPNavigation.navigateToroute(
          context: context,
          routename: '/HomePage',
          screen: BottomBar(
            pageindex: 0,
          ));
    });
  }

  botttomsheetfaild() {
    return Get.bottomSheet(
        isScrollControlled: true,
        useRootNavigator: true,
        WillPopScope(
          onWillPop: () {
            WebAPPNavigation.navigateToroute(
                context: context,
                routename: '/HomePage',
                screen: BottomBar(
                  pageindex: 0,
                ));

            return Future(() => false);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    color: AppColor.whiteColor),
                child: Column(
                  children: [
                    Container(
                      height: 84,
                      width: 84,
                      margin: EdgeInsets.only(top: 24),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: AppColor.redcolor),
                      child: Icon(
                        Icons.close,
                        size: 45,
                        color: AppColor.whiteColor,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 24, left: 24, right: 24),
                      child: Text(
                        "Sorry!",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 24, fontFamily: AppFont.lato),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 12, left: 40, right: 40),
                      child: Text(
                        "Something Went Wrong !!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, color: AppColor.fontColorgrey),
                      ),
                    ),
                    InkWell(
                      overlayColor: WidgetStatePropertyAll(Colors.white),
                      onTap: () {
                        WebAPPNavigation.navigateToroute(
                            context: context,
                            routename: '/HomePage',
                            screen: BottomBar(
                              pageindex: 0,
                            ));
                      },
                      child: Container(
                        height: 52,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 24, left: 24, right: 24),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: AppColor.imagebg, width: 1),
                            borderRadius: BorderRadius.circular(15)),
                        child: Center(
                          child: Text(
                            "Back Home",
                            style: TextStyle(
                                color: AppColor.fontColorgrey,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 24, bottom: 24),
                      child: Text(
                        "You Can Order Somethings Also",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).whenComplete(() {
      WebAPPNavigation.navigateToroute(
          context: context,
          routename: '/HomePage',
          screen: BottomBar(
            pageindex: 0,
          ));
    });
  }
}
