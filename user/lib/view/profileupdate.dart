// ignore_for_file: sized_box_for_whitespace, unnecessary_import, prefer_const_literals_to_create_immutables, prefer_const_constructors, must_be_immutable, non_constant_identifier_names

import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/view/loginpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/updateprofilecontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({
    super.key,
  });
  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _nameformKey = GlobalKey<FormState>();

  UpdateProfileContoller updateProfileContoller =
      Get.put(UpdateProfileContoller());
  @override
  void initState() {
    getuserdata();

    super.initState();
  }

  getuserdata() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      updateProfileContoller.userid =
          prefs.getString(prefrenceKey.userid) ?? "";
    });
    try {
      final me = await ApiClient.instance.getOne('/auth/me');
      updateProfileContoller.namecontoller.text =
          (me['FirstName'] ?? me['name'] ?? '').toString();
      setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > CommonWidget.headerWidth
        ? Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: AppColor.BgColor,
              child: SingleChildScrollView(
                child: StickyHeader(
                  header:
                      CommonWidget().StickyHeaders(context, Refresh: setState),
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width * 0.48,
                            child: Center(
                              child: SvgPicture.asset(
                                  "assets/image/Statusupdate.svg",
                                  semanticsLabel: 'Acme Logo'),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ProfilePicWidget(),
                              _profileHeading(),
                              nameTextfeildwidget(),
                              _detailRows(),
                              SizedBox(
                                height: 28,
                              ),
                              UpdateProfile(),
                              SizedBox(
                                height: 150,
                              ),
                            ],
                          )
                        ],
                      ),
                      CommonWidget().Footer(context)
                    ],
                  ),
                ),
              ),
            ),
          )
        : Scaffold(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ProfilePicWidget(),
                    _profileHeading(),
                    nameTextfeildwidget(),
                    _detailRows(),
                    SizedBox(
                      height: 28,
                    ),
                    UpdateProfile(),
                    SizedBox(
                      height: 150,
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _profileHeading() {
    return Container(
      constraints: BoxConstraints(maxWidth: 700),
      padding: EdgeInsets.fromLTRB(24, 18, 24, 2),
      child: Column(
        children: [
          Text(
            "Edit Profile",
            style: TextStyle(
                fontFamily: AppFont.heading,
                fontSize: 28,
                color: AppColor.ink,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            "Manage your personal details",
            style: TextStyle(fontSize: 14, color: AppColor.fontColorgrey),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.dividercolor),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColor.blush, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: AppColor.primary, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.6,
                        color: AppColor.fontColorgrey,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text(value.trim().isEmpty ? "Not added yet" : value,
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColor.ink,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRows() {
    final email = CommonWidget.userModel.email;
    final phone = CommonWidget.userModel.phoneNumber;
    return Container(
      constraints: BoxConstraints(maxWidth: 700),
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _infoRow(Icons.mail_outline, "EMAIL", email),
          _infoRow(Icons.call_outlined, "PHONE", phone),
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
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                shape: BoxShape.circle, gradient: AppColor.ctaGradient),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 3, color: AppColor.whiteColor),
                  color: AppColor.whiteColor),
              child: ProfilePicture(
                name: updateProfileContoller.namecontoller.text == '' ||
                        updateProfileContoller.namecontoller.text.isEmpty
                    ? "Guest"
                    : updateProfileContoller.namecontoller.text,
                radius: 31,
                fontsize: 21,
              ),
            ),
          ),
          // InkWell(
          //   overlayColor: WidgetStatePropertyAll(Colors.white),
          //   onTap: () {},
          //   child: Container(
          //     height: 24,
          //     width: 24,
          //     margin: EdgeInsets.only(right: 10, top: 25),
          //     decoration: BoxDecoration(
          //         border: Border.all(width: 2, color: AppColor.whiteColor),
          //         shape: BoxShape.circle,
          //         color: AppColor.BlackColor),
          //     child: Center(
          //       child: Icon(
          //         Icons.add,
          //         size: 18,
          //         color: AppColor.whiteColor,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  nameTextfeildwidget() {
    return Container(
      constraints: BoxConstraints(maxWidth: 700),
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Full Name",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              key: _nameformKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                controller: updateProfileContoller.namecontoller,
                validator: updateProfileContoller.validatename,
                cursorColor: AppColor.fontblack,
                decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: AppColor.imagebg,
                    border: InputBorder.none,
                    hintText: "Enter Your Name",
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

  UpdateProfile() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        if (updateProfileContoller.processloader == false) {
          updateProfileContoller.processloader = true;
          setState(() {});
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.focusedChild!.unfocus();
          }
          if (updateProfileContoller.namecontoller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Name',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            updateProfileContoller.processloader = false;
            setState(() {});
          }
          // else if (updateProfileContoller.numbercontoller.text.isEmpty) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       content: Text(
          //         'Please Enter Number',
          //         style: TextStyle(color: AppColor.whiteColor),
          //       ),
          //       backgroundColor: Colors.red,
          //     ),
          //   );
          //   updateProfileContoller.processloader = false;
          //   setState(() {});
          // }
          else if (!_nameformKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Valid Name',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            updateProfileContoller.processloader = false;
            setState(() {});
          } else if (updateProfileContoller.userid.isEmpty) {
            updateProfileContoller.processloader = false;
            updateProfileContoller.namecontoller.clear();
            setState(() {});
            WebAPPNavigation.navigateToroute(
                context: context, routename: '/LoginPage', screen: LoginPage());
          } else {
            ApiClient.instance.put('/auth/me', {
              'FirstName': updateProfileContoller.namecontoller.text,
            }).then(
              (value) {
                updateProfileContoller.processloader = false;
                setState(() {});
                AppToast.show(context, "Profile updated successfully");
                WebAPPNavigation.navigateTo(context: context);
              },
            );
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        margin: EdgeInsets.only(right: 24, left: 24, top: 14, bottom: 10),
        width: MediaQuery.of(context).size.width * 0.35,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColor.btnColorblack),
        child: updateProfileContoller.processloader == true
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColor.whiteColor,
                ),
              )
            : Text(
                "Update Profile",
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
