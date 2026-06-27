// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_import, sized_box_for_whitespace, non_constant_identifier_names, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, must_be_immutable, unnecessary_brace_in_string_interps, avoid_print, avoid_web_libraries_in_flutter, unused_import
import 'dart:math';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/addressmodel.dart';
import 'package:EcommerceApp/view/loginpage.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/api/user_data_api.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/addresscontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:universal_html/html.dart' as html;

class DeliveryAdress extends StatefulWidget {
  DeliveryAdress(
      {super.key, this.index, this.addresslist, this.addaddress, this.onBack});
  int? index;
  List<Addresslist>? addresslist;
  int? addressuniqeid;
  bool? addaddress;
  VoidCallback? onBack;
  @override
  State<DeliveryAdress> createState() => _DeliveryAdressState();
}

class _DeliveryAdressState extends State<DeliveryAdress> {
  DeliveryAddress deliveryAddress = Get.put(DeliveryAddress());
  final _fullnamefromKey = GlobalKey<FormState>();
  final _addressfromKey = GlobalKey<FormState>();
  final _phonefromKey = GlobalKey<FormState>();
  final _alternativephonefromKey = GlobalKey<FormState>();
  final _pincodefromKey = GlobalKey<FormState>();
  bool isSubmit = false;
  @override
  void initState() {
    deliveryAddress.addresslist.clear();
    customerid().then(
      (value) {
        Addressget().then(
          (value) {
            if (widget.addaddress == true) {
              deliveryAddress.addersscontoller.clear();
              deliveryAddress.phonecontroller.clear();
              deliveryAddress.fullnamecontroller.clear();
              deliveryAddress.citycontroller.clear();
              deliveryAddress.statecontroller.clear();
              deliveryAddress.pintcodecontroller.clear();
            } else {
              if (widget.index != null && widget.addresslist != null) {
                deliveryAddress.addersscontoller.text =
                    widget.addresslist![widget.index!].street ?? '';
                deliveryAddress.phonecontroller.text =
                    widget.addresslist![widget.index!].phoneNumber ?? '';
                deliveryAddress.fullnamecontroller.text =
                    widget.addresslist![widget.index!].name ?? '';
                deliveryAddress.citycontroller.text =
                    widget.addresslist![widget.index!].city ?? '';
                deliveryAddress.statecontroller.text =
                    widget.addresslist![widget.index!].state ?? '';
                deliveryAddress.pintcodecontroller.text =
                    widget.addresslist![widget.index!].postalCode ?? '';
              } else {
              }
            }
          },
        );
        // }
      },
    );

    super.initState();
  }

  int custmerID = 0;
  Future customerid() async {
    final SharedPreferences perfs = await SharedPreferences.getInstance();
    custmerID = perfs.getInt("customerid") ?? 0;
    deliveryAddress.userid = perfs.getString(prefrenceKey.userid) ?? '';
    setState(() {});
    setState(() {
      deliveryAddress.userid = perfs.getString(prefrenceKey.userid) ?? '';
    });
    return custmerID;
  }

  int converter(String id) {
    int Addressid = 0;
    String transfer = id;
    transfer = transfer.split('?').first;

    setState(() {
      Addressid = int.parse(transfer.replaceAll('gid://shopi/', ''));
    });
    return Addressid;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > CommonWidget.headerWidth
        ? Scaffold(
            backgroundColor: AppColor.BgColor,
            body: Center(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: StickyHeader(
                    header: CommonWidget()
                        .StickyHeaders(context, Refresh: setState),
                    content: Column(
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: 600),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              FullnameTextfeild(),
                              PhonenumberTextfeild(),
                              AddressTextfeild(),
                              state(),
                              city(),
                              pincodefeild(),
                              SizedBox(
                                height: 20,
                              ),
                              submitbtn(),
                            ],
                          ),
                        ),
                        CommonWidget().Footer(context)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: AppColor.BgColor,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              surfaceTintColor: Colors.transparent,
              backgroundColor: AppColor.BgColor,
              centerTitle: true,
              title: Text(
                "Add Delivery Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              leading: InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  onTap: () {
                    WebAPPNavigation.navigateTo(context: context);
                  },
                  child: CommonWidget().backicon()),
              actions: [],
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FullnameTextfeild(),
                    PhonenumberTextfeild(),
                    AddressTextfeild(),
                    state(),
                    city(),
                    pincodefeild(),
                    SizedBox(
                      height: 20,
                    ),
                    submitbtn()
                  ],
                ),
              ),
            ),
          );
  }

  state() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "State",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              // key: _fullnamefromKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                controller: deliveryAddress.statecontroller,

                // validator: deliveryAddress.validateEmail,
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
                    fillColor: AppColor.imagebg,
                    border: InputBorder.none,
                    hintText: "Enter state",
                    hintStyle: TextStyle(fontWeight: FontWeight.w500)),
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

  city() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "City",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                controller: deliveryAddress.citycontroller,
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
                    fillColor: AppColor.imagebg,
                    border: InputBorder.none,
                    hintText: "Enter City",
                    hintStyle: TextStyle(fontWeight: FontWeight.w500)),
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

  FullnameTextfeild() {
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
            "Full Name",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              key: _fullnamefromKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                controller: deliveryAddress.fullnamecontroller,
                validator: deliveryAddress.validatename,
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
                    fillColor: AppColor.imagebg,
                    border: InputBorder.none,
                    hintText: "Enter Full Name",
                    hintStyle: TextStyle(
                        color: AppColor.fontColorgrey,
                        fontWeight: FontWeight.w500)),
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

  PhonenumberTextfeild() {
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
            "Phone Number",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              key: _phonefromKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                controller: deliveryAddress.phonecontroller,
                keyboardType: TextInputType.number,
                maxLength: 10,
                validator: deliveryAddress.validatephone,
                cursorColor: AppColor.fontblack,
                decoration: InputDecoration(
                    counterText: '',
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
                    fillColor: AppColor.imagebg,
                    border: InputBorder.none,
                    hintText: "Enter Phone Number",
                    hintStyle: TextStyle(
                        color: AppColor.fontColorgrey,
                        fontWeight: FontWeight.w500)),
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

  AddressTextfeild() {
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
            "Address",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              key: _addressfromKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                controller: deliveryAddress.addersscontoller,
                validator: deliveryAddress.validateaddresse,
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
                    fillColor: AppColor.imagebg,
                    border: InputBorder.none,
                    hintText: "Enter Your Address",
                    hintStyle: TextStyle(
                        color: AppColor.fontColorgrey,
                        fontWeight: FontWeight.w500)),
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

  alternativePhonenumberTextfeild() {
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
            "Alternative Phone Number",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              key: _alternativephonefromKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                keyboardType: TextInputType.number,
                maxLength: 10,
                // inputFormatters: [MaskedInputFormatter('###-###-####')],
                controller: deliveryAddress.alternativephonenumber,
                validator: deliveryAddress.validatephone,
                cursorColor: AppColor.fontblack,
                decoration: InputDecoration(
                    counterText: '',
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
                    fillColor: AppColor.imagebg,
                    border: InputBorder.none,
                    hintText: "Enter Alternative Phone Number",
                    hintStyle: TextStyle(
                        color: AppColor.fontColorgrey,
                        fontWeight: FontWeight.w500)),
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

  addphonenumber() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        deliveryAddress.alternativeaddress = true;
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            '+ Add Alternate Phone Number',
            style: TextStyle(
                color: AppColor.lightbluecolor,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  findlocation() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            children: [
              Image.asset(
                AppImage.appIcon + 'location_icon.png',
                height: 14,
                width: 14,
              ),
              Text(
                ' Find My Location on Map',
                style: TextStyle(
                    color: AppColor.lightbluecolor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Random rendom = Random();
  pincodefeild() {
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
            "Pincode",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              key: _pincodefromKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                controller: deliveryAddress.pintcodecontroller,
                keyboardType: TextInputType.number,
                validator: deliveryAddress.validatepincode,
                cursorColor: AppColor.fontblack,
                maxLength: 6,
                decoration: InputDecoration(
                    isDense: true,
                    counterText: '',
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
                    fillColor: AppColor.imagebg,
                    border: InputBorder.none,
                    hintText: "Enter Pincode",
                    hintStyle: TextStyle(
                        color: AppColor.fontColorgrey,
                        fontWeight: FontWeight.w500)),
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

  famousareamall() {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              // key: _fullnamefromKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                controller: deliveryAddress.roadareacontroller,
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
                    fillColor: AppColor.imagebg,
                    border: InputBorder.none,
                    hintText: "Enter Nearby Famous Shop/Mall/Landmark",
                    hintStyle: TextStyle(
                        color: AppColor.fontColorgrey,
                        fontWeight: FontWeight.w500)),
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

  typeofaddress() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 15),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Type of Address",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Radio(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: 1,
                groupValue: deliveryAddress.selectedValue,
                fillColor: WidgetStatePropertyAll(AppColor.BlackColor),
                onChanged: (value) {
                  deliveryAddress.selectedValue = value!;
                  setState(() {});
                },
              ),
              Text(
                'Home',
                style: TextStyle(),
              ),
              Radio(
                value: 2,
                groupValue: deliveryAddress.selectedValue,
                fillColor: WidgetStatePropertyAll(AppColor.BlackColor),
                onChanged: (value) {
                  deliveryAddress.selectedValue = value!;
                  setState(() {});
                },
              ),
              Text(
                'Office',
                style: TextStyle(),
              )
            ],
          ),
        ),
      ],
    );
  }

  submitbtn() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        if (isSubmit == false) {
          isSubmit = true;
          setState(() {});
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.focusedChild!.unfocus();
          }
          if (deliveryAddress.fullnamecontroller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Fullname',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            isSubmit = false;
            setState(() {});
          } else if (deliveryAddress.phonecontroller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Phone Number',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            isSubmit = false;
            setState(() {});
          } else if (deliveryAddress.addersscontoller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Address',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            isSubmit = false;
            setState(() {});
          } else if (deliveryAddress.statecontroller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter State Name',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            isSubmit = false;
            setState(() {});
          } else if (deliveryAddress.citycontroller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter City Name',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            isSubmit = false;
            setState(() {});
          } else if (deliveryAddress.pintcodecontroller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Pincode',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            isSubmit = false;
            setState(() {});
          } else if (!_fullnamefromKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Valid Full Name',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            isSubmit = false;
            setState(() {});
          } else if (!_phonefromKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Valid Phone Number',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            isSubmit = false;
            setState(() {});
          } else if (!_addressfromKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Valid Address',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            isSubmit = false;
            setState(() {});
          } else if (!_pincodefromKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Valid Pincode Number',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            isSubmit = false;
            setState(() {});
          } else if (deliveryAddress.userid.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Invalid User Id',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            WebAPPNavigation.navigateToroute(
                context: context, routename: '/LoginPage', screen: LoginPage());
            isSubmit = false;
            setState(() {});
          } else {
            if (widget.addresslist != null) {
              updateaddress().then(
                (value) {
                  isSubmit = false;
                  setState(() {});
                  success(true);
                  if (widget.onBack != null) {
                    widget.onBack!.call();
                  }

                  if (kIsWeb) {
                    html.window.history.back();
                  } else {
                    WebAPPNavigation.navigateTo(context: context);
                  }
                  // Beamer.of(context).popBeamLocation();
                },
              );
            } else {
              if (deliveryAddress.addresslistid.isNotEmpty ||
                  deliveryAddress.addresslistid != '') {
                deliveryAddress.addresslist.add(Addresslist(
                    street: deliveryAddress.addersscontoller.text,
                    city: deliveryAddress.citycontroller.text,
                    name: deliveryAddress.fullnamecontroller.text,
                    phoneNumber: deliveryAddress.phonecontroller.text,
                    postalCode: deliveryAddress.pintcodecontroller.text,
                    Id: rendom.nextInt(1000000).toString(),
                    dateTime: DateTime.now(),
                    country: '',
                    selectedAddress: true,
                    state: deliveryAddress.statecontroller.text));
                setState(() {});
                AddNewaddress(FirebaseAddressModel(
                        addresslist: deliveryAddress.addresslist,
                        addresslistid: deliveryAddress.addresslistid,
                        userid: deliveryAddress.userid))
                    .then(
                  (value) {
                    isSubmit = false;
                    setState(() {});
                    success(false);
                    if (widget.onBack != null) {
                      widget.onBack!.call();
                    }
                    WebAPPNavigation.navigateTo(context: context);
                    deliveryAddress.addersscontoller.clear();
                    deliveryAddress.phonecontroller.clear();
                    deliveryAddress.fullnamecontroller.clear();
                    deliveryAddress.citycontroller.clear();
                    deliveryAddress.statecontroller.clear();
                    deliveryAddress.pintcodecontroller.clear();
                  },
                );
              } else {
                Addtoaddress(FirebaseAddressModel(
                    userid: deliveryAddress.userid,
                    addresslist: [
                      Addresslist(
                          Id: rendom.nextInt(1000000).toString(),
                          street: deliveryAddress.addersscontoller.text,
                          city: deliveryAddress.citycontroller.text,
                          name: deliveryAddress.fullnamecontroller.text,
                          phoneNumber: deliveryAddress.phonecontroller.text,
                          postalCode: deliveryAddress.pintcodecontroller.text,
                          dateTime: DateTime.now(),
                          selectedAddress: true,
                          country: '',
                          state: deliveryAddress.statecontroller.text)
                    ])).then(
                  (value) {
                    isSubmit = false;

                    success(false);
                    if (widget.onBack != null) {
                      widget.onBack!.call();
                    }
                    WebAPPNavigation.navigateTo(context: context);
                    setState(() {});
                  },
                );
              }
            }
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        margin: EdgeInsets.only(right: 24, left: 24, top: 20, bottom: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColor.btnColorblack),
        child: isSubmit == true
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColor.whiteColor,
                ),
              )
            : Text(
                "Save Address",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColor.whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w400),
              ),
      ),
    );
  }

  Future success(bool value) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 500),
        content: Text(value
            ? 'Sucessfully Updated Address'
            : 'Sucessfully Added Address'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Address persistence via Node/MongoDB (/api/me/addresses) — one per-user doc
  // holding the full Addresslist.
  Future<void> Addtoaddress(FirebaseAddressModel address) async {
    await UserDataApi.saveAddresses(
        (address.addresslist ?? []).map((e) => e.toJson()).toList());
  }

  Future<void> AddNewaddress(FirebaseAddressModel address) async {
    await UserDataApi.saveAddresses(
        (address.addresslist ?? []).map((e) => e.toJson()).toList());
  }

  Future<void> updateaddress() async {
    deliveryAddress.addresslist[widget.index!].street =
        deliveryAddress.addersscontoller.text;
    deliveryAddress.addresslist[widget.index!].city =
        deliveryAddress.citycontroller.text;
    deliveryAddress.addresslist[widget.index!].name =
        deliveryAddress.fullnamecontroller.text;
    deliveryAddress.addresslist[widget.index!].phoneNumber =
        deliveryAddress.phonecontroller.text;
    deliveryAddress.addresslist[widget.index!].postalCode =
        deliveryAddress.pintcodecontroller.text;
    deliveryAddress.addresslist[widget.index!].state =
        deliveryAddress.statecontroller.text;

    setState(() {});

    UpdateToaddress(FirebaseAddressModel(
        addresslistid: deliveryAddress.addresslistid,
        userid: deliveryAddress.userid,
        addresslist: deliveryAddress.addresslist));
  }

  Future<void> UpdateToaddress(FirebaseAddressModel address) async {
    await UserDataApi.saveAddresses(
        (address.addresslist ?? []).map((e) => e.toJson()).toList());
  }

  var data;
  Future<void> Addressget() async {
    try {
      final list = await UserDataApi.getAddresses();
      deliveryAddress.addresslist.clear();
      for (final v in list) {
        deliveryAddress.addresslist.add(Addresslist.fromJson(v));
      }
      deliveryAddress.addresslistid = deliveryAddress.userid;
      if (mounted) setState(() {});
    } catch (_) {}
  }
}
