// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, deprecated_member_use

import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/itemprovioder.dart';
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/model/bottombarmodel.dart';
import 'package:EcommerceApp/view/fevorite.dart';
import 'package:EcommerceApp/view/homepage.dart';
import 'package:EcommerceApp/view/profilepage.dart';
import 'package:EcommerceApp/view/shopping.dart';
import 'package:EcommerceApp/viewmodel/bottomcontroller.dart';

class BottomBar extends StatefulWidget {
  BottomBar({super.key, this.pageindex});
  int? pageindex;
  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  BottomController bottomController = Get.put(BottomController());
  int _bottomNavIndex = 0;

  Future changepage() async {
    _bottomNavIndex = widget.pageindex!;
    setState(() {});
  }

  void refersh() {
    bottomController.cartidchecker().then((value) {
      // refersh();
      setState(() {});
      if (widget.pageindex != null) {
        changepage().then(
          (value) {
            widget.pageindex = null;
          },
        );
      }
      context.read<CartModel>().clearallItem();
      setState(() {});
      context.read<CartModel>().addallItem(bottomController.cartdataList);
    });
    setState(() {});
  }

  @override
  void initState() {
    if (widget.pageindex != null) {
      changepage().then(
        (value) {
          widget.pageindex = null;
        },
      );
    }
    bottomController.cartidchecker().then((value) {
      setState(() {});
      refersh();
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_bottomNavIndex == 2) {
          if (Get.previousRoute == "/BottomBar" || Get.previousRoute == "/") {
            CommonWidget().showExitPopup(context);
            return Future(() => false);
          } else {
            WebAPPNavigation.navigateTo(context: context);
          }
          return Future(() => false);
        } else {
          CommonWidget().showExitPopup(context);
          return Future(() => false);
        }
      },
      child: Scaffold(
        body: _bottomNavIndex == 0
            ?
            //  HomePage(this.refersh)
            HomePage()
            : _bottomNavIndex == 1
                ? FavoritePage()
                : _bottomNavIndex == 2
                    ? ShoppingPage(
                        refersh: refersh,
                      )
                    : _bottomNavIndex == 3
                        ? ProfilePage()
                        : HomePage(),
        extendBody: true,
        bottomNavigationBar: !Responsive.isMobile(context)
            ? null
            : AnimatedBottomNavigationBar.builder(
                itemCount: 4,
                activeIndex: _bottomNavIndex,
                gapLocation: GapLocation.none,
                notchSmoothness: NotchSmoothness.defaultEdge,
                backgroundColor: AppColor.whiteColor,
                onTap: (index) {
                  setState(() => _bottomNavIndex = index);
                  bottomController.cartidchecker().then((value) {
                    Future.delayed(
                      Duration(seconds: 1),
                      () {
                        refersh();
                        setState(() {});
                      },
                    );
                  });
                },
                // onTap: (index) => setState(() => _bottomNavIndex = index),
                tabBuilder: (int index, bool isActive) {
                  return Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 25,
                            width: 25,
                            margin: EdgeInsets.only(top: 5, right: 5, left: 5),
                            child: Image(
                                image: AssetImage(
                                  bottombarList[index].image,
                                ),
                                color: _bottomNavIndex == index
                                    ? AppColor.fontblack
                                    : AppColor.fontColorgrey),
                          ),
                          index == 2
                              ? Positioned(
                                  right: 0,
                                  child: CommonWidget.cartitems == 0
                                      ? SizedBox()
                                      : Container(
                                          height: 18,
                                          width: 18,
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle),
                                          child: Center(
                                            child: Text(
                                              '${CommonWidget.cartitems}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColor.whiteColor),
                                            ),
                                          ),
                                        ),
                                )
                              : SizedBox(),
                        ],
                      ),
                      Text(
                        bottombarList[index].text,
                        style: TextStyle(
                            color: _bottomNavIndex == index
                                ? AppColor.fontblack
                                : AppColor.fontColorgrey),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
