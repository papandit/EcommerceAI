// ignore_for_file: prefer_const_constructors, unnecessary_import, prefer_interpolation_to_compose_strings, avoid_unnecessary_containers

import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/view/loginpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/model/intromodel.dart';
import 'package:EcommerceApp/viewmodel/introcontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({
    super.key,
  });
  @override
  State<IntroPage> createState() => _IntroPageOneState();
}

class _IntroPageOneState extends State<IntroPage> {
  IntroController introController = Get.put(IntroController());
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        CommonWidget().showExitPopup(context);
      },
      child: Scaffold(
        backgroundColor: AppColor.BgColor,
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              pageviewwidget(),
              indicatorwidget(),
              Spacer(),
              introController.scrollcontoller != 2
                  ? bottomintroonewidget()
                  : bottomwidget()
              // Positioned(
              //     bottom: 0,
              //     child: introController.scrollcontoller != 2
              //         ?),
            ],
          ),
        ),
      ),
    );
  }

  pageviewwidget() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      // constraints: BoxConstraints(maxWidth: 500, maxHeight: 450),
      child: PageView(
        onPageChanged: (value) {
          introController.scrollcontoller = value;
          setState(() {});
        },
        pageSnapping: true,
        controller: introController.controller,
        children: [
          pagewidget(index: 0),
          pagewidget(index: 1),
          pagewidget(index: 2),
        ],
      ),
    );
  }

  indicatorwidget() {
    return SmoothPageIndicator(
      controller: introController.controller,
      count: 3,
      effect: WormEffect(
        activeDotColor: AppColor.btnColorblack,
        dotColor: AppColor.fontColorgrey,
        spacing: 10,
        dotHeight: 8,
        dotWidth: 8,
        type: WormType.thinUnderground,
      ),
    );
  }

  Widget bottomwidget() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () async {
        final SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setBool('Intro', true);

        WebAPPNavigation.navigateToroute(
            context: context, routename: '/LoginPage', screen: LoginPage());
      },
      child: Container(
          height: 70,
          width: MediaQuery.of(context).size.width,
          constraints: BoxConstraints(maxWidth: 450),
          decoration: BoxDecoration(
              color: AppColor.fontblack,
              borderRadius: BorderRadius.circular(15)),
          margin: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: Text(
              "Get Started",
              style: TextStyle(
                  color: AppColor.whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          )),
    );
  }

  Widget bottomintroonewidget() {
    return Container(
      height: 100,
      margin: EdgeInsets.symmetric(horizontal: 24),
      constraints: BoxConstraints(
        maxWidth: 550,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.white),
            onTap: () async {
              final SharedPreferences pref =
                  await SharedPreferences.getInstance();
              pref.setBool('Intro', true);
              WebAPPNavigation.navigateToroute(
                  context: context,
                  routename: '/LoginPage',
                  screen: LoginPage());
            },
            child: Text(
              "Skip",
              style: TextStyle(color: AppColor.fontColorgrey, fontSize: 17),
            ),
          ),
          InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.white),
            onTap: () {
              introController.controller.nextPage(
                  duration: Duration(milliseconds: 500), curve: Curves.linear);
            },
            child: Container(
              padding: EdgeInsets.all(13),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.btnColorblack,
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColor.BgColor,
                  size: 25,
                ),
                // Image.asset(
                //       "assets/image/right_arrow.png",
                //       fit: BoxFit.cover,
                //       height: 25,
                //     )
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget pagewidget({index}) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxWidth: 450),
              // height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: AssetImage(IntroList[index].image),
                      fit: BoxFit.cover)),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0),
            child: Text(
              textAlign: TextAlign.center,
              IntroList[index].text,
              style: TextStyle(
                  color: AppColor.BlackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 22),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
