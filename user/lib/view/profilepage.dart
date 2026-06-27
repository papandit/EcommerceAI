// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_interpolation_to_compose_strings, non_constant_identifier_names, unnecessary_import, sized_box_for_whitespace, unnecessary_string_interpolations

import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/userdataset.dart';
import 'package:EcommerceApp/view/addressadd.dart';
import 'package:EcommerceApp/view/ligalpolicy.dart';
import 'package:EcommerceApp/view/myorder.dart';
import 'package:EcommerceApp/view/profileupdate.dart';
import 'package:EcommerceApp/view/tryon_history_page.dart';
import 'package:EcommerceApp/viewmodel/homecontroller.dart';
import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/view/loginpage.dart';
import 'package:EcommerceApp/viewmodel/profilecontoller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoader = false;
  bool removesection = false;
  bool intro = false;
  ProfileController profileController = Get.put(ProfileController());
  Homecontoller homecontroller = Get.put(Homecontoller());

  getuserdata() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    homecontroller.userid = prefs.getString(prefrenceKey.userid) ?? '';
    setState(() {});
    if (homecontroller.userid.isNotEmpty) {
      try {
        final map = await ApiClient.instance.getOne('/auth/me');
        CommonWidget.userModel = UserModel.fromJson(map);
      } catch (e) {
        debugPrint("getuserdata error: $e");
      }
    }

    intro = prefs.getBool(
          "Intro",
        ) ??
        false;
    setState(() {});

    isLoader = false;
    setState(() {});
  }

  @override
  void initState() {
    isLoader = true;
    getuserdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.BgColor,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Profile",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          backgroundColor: AppColor.BgColor,
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: isLoader
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColor.BlackColor,
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          ProfilePicWidget(),
                          Profilenameidget(),
                          Profileemailidget(),
                          ProfileEventWidget(
                              image: AppImage.appIcon + "profileimage.png",
                              name: "Profile",
                              ontap: () {
                                WebAPPNavigation.navigateToroute(
                                    context: context,
                                    routename: '/UpdateProfile',
                                    screen: UpdateProfile());
                              }),
                          ProfileEventWidget(
                              image: AppImage.appIcon + "history.png",
                              name: "Order History",
                              ontap: () {
                                WebAPPNavigation.navigateToroute(
                                    context: context,
                                    routename: '/MyOrderPage',
                                    screen: MyOrderPage());
                              }),
                          ProfileEventIconWidget(
                              icon: Icons.auto_awesome,
                              name: "My Try-Ons",
                              ontap: () {
                                WebAPPNavigation.navigateToroute(
                                    context: context,
                                    routename: '/TryOnHistory',
                                    screen: const TryOnHistoryPage());
                              }),
                          ProfileEventWidget(
                              image: AppImage.appIcon + "addressicon.png",
                              name: "Delivery Address",
                              ontap: () {
                                WebAPPNavigation.navigateToroute(
                                    context: context,
                                    routename: '/DeliveryAdressadd',
                                    screen: DeliveryAdressadd());
                              }),
                          ProfileEventWidget(
                              image: AppImage.appIcon + "legal.png",
                              name: "Legal Policy",
                              ontap: () {
                                WebAPPNavigation.navigateToroute(
                                    context: context,
                                    routename: '/LegalPolicy',
                                    screen: LegalPolicy());
                              }),
                          homecontroller.userid.isEmpty
                              ? LoginWidget()
                              : LogOutWidget()
                        ],
                      ),
                    ),
                  )));
  }

  ProfilePicWidget_old() {
    return Container(
      color: AppColor.redcolor,
      width: 200,
      height: 100,
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.13,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: AppColor.btnColorblack),
          ),
          Align(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColor.activeusercolor),
            ),
          ),
        ],
      ),
    );
  }

  ProfilePicWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 3, color: AppColor.whiteColor),
                color: AppColor.whiteColor),
            child: ProfilePicture(
              name: homecontroller.userid.isEmpty
                  ? "Guest"
                  : CommonWidget.userModel.firstName,
              radius: 31,
              fontsize: 21,
            ),
          ),
          Container(
            height: 15,
            width: 15,
            margin: EdgeInsets.only(right: 8, top: 27),
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: AppColor.whiteColor),
                shape: BoxShape.circle,
                color: AppColor.activeusercolor),
          ),
        ],
      ),
    );
  }

  Profilenameidget() {
    return Container(
        margin: EdgeInsets.only(
          top: 18,
        ),
        child: Text(
          homecontroller.userid.isEmpty
              ? "Guest"
              : CommonWidget.userModel.firstName,
          style: TextStyle(
              color: AppColor.btnColorblack,
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ));
  }

  Profileemailidget() {
    return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Text(
          homecontroller.userid.isEmpty ? "" : CommonWidget.userModel.email,
          style: TextStyle(
            color: AppColor.fontColorgrey,
            fontSize: 14,
          ),
        ));
  }

  ProfileEventWidget({image, name, ontap}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: ontap,
      child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(bottom: 10, top: 10),
          decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(15)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage(image),
                )),
              ),
              Text(
                name,
                style: TextStyle(
                  color: AppColor.btnColorblack,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          )),
    );
  }

  ProfileEventIconWidget({required IconData icon, name, ontap}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: ontap,
      child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(bottom: 10, top: 10),
          decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(15)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                height: 30,
                width: 30,
                alignment: Alignment.center,
                child: Icon(icon, color: AppColor.primary, size: 26),
              ),
              Text(
                name,
                style: TextStyle(
                  color: AppColor.btnColorblack,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          )),
    );
  }

  LogOutWidget() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () async {
        CommonWidget().LogoutPopup(context, tap: () async {
          Navigator.pop(context);
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.clear().then((value) {
            preferences.setBool("Intro", intro);
            // Get.offAll(LoginPage());
            WebAPPNavigation.navigateToroute(
                context: context, routename: '/LoginPage', screen: LoginPage());
          });
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: 50, bottom: 80),
        child: Text(
          "Log Out",
          style: TextStyle(
              color: AppColor.redcolor,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  LoginWidget() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () async {
        WebAPPNavigation.navigateToroute(
            context: context, routename: '/LoginPage', screen: LoginPage());
      },
      child: Container(
        margin: EdgeInsets.only(top: 50, bottom: 80),
        child: Text(
          "Log In",
          style: TextStyle(
              color: AppColor.redcolor,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
