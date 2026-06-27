// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_import, avoid_print, sized_box_for_whitespace

import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/view/addaddress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/showaddresscontoller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Myaddresses extends StatefulWidget {
  const Myaddresses({super.key});

  @override
  State<Myaddresses> createState() => _MyaddressesState();
}

class _MyaddressesState extends State<Myaddresses> {
  MyAddressController myAddressController = Get.put(MyAddressController());
  @override
  void initState() {
    setState(() {
      myAddressController.isloader = true;
    });

    getuserdata();
    super.initState();
  }

  getuserdata() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      myAddressController.accesstoken = prefs.getString('Accesstoken') ?? "";
      myAddressController.custmerid = prefs.getInt('customerid') ?? 0;
    });
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
          "Delivery Address",
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
        child: myAddressController.isloader == true
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColor.BlackColor,
                ),
              )
            : myAddressController.myaddressModel == null ||
                    myAddressController.myaddressModel!.customer == null
                ? myAddressController.custmerid == 0
                    ? Center(
                        child: Text(
                          "No Data Found",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      )
                    : addadress()
                : Column(
                    children: [
                      addadress(),
                      SizedBox(
                        height: 25,
                      ),
                      addresslistview()
                    ],
                  ),
      ),
    );
  }

  addadress() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: myAddressController.myaddressModel!.customer == null
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          myAddressController.myaddressModel!.customer == null
              ? SizedBox()
              : Text(
                  '${myAddressController.myaddressModel!.customer!.addresses!.edges!.length} Saved Address',
                  style: TextStyle(color: AppColor.fontColorgrey),
                ),
          InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.white),
            onTap: () {
              WebAPPNavigation.navigateToroute(
                  context: context,
                  routename: '/DeliveryAdressadds',
                  screen: DeliveryAdress(
                    addaddress: true,
                  ));
            },
            child: Container(
              height: 50,
              width: myAddressController.myaddressModel!.customer == null
                  ? MediaQuery.of(context).size.width * 0.90
                  : MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                  color: AppColor.lightbluecolor,
                  borderRadius: BorderRadius.circular(15)),
              child: Center(
                child: Text(
                  '+ Add New Address',
                  style: TextStyle(
                      color: AppColor.whiteColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  addresslistview() {
    return Flexible(
        flex: 1,
        fit: FlexFit.tight,
        child: Container(
          color: AppColor.BgColor,
          child: ListView.builder(
            itemCount: myAddressController
                .myaddressModel!.customer!.addresses!.edges!.length,
            itemBuilder: (context, index) {
              return Container(
                // height: 200,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 20),
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  color: Color(0xffA8A8A8),
                ))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${myAddressController.myaddressModel!.customer!.addresses!.edges![index].node!.name}',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        InkWell(
                          overlayColor: WidgetStatePropertyAll(Colors.white),
                          onTap: () {
                            WebAPPNavigation.navigateToroute(
                                context: context,
                                routename: '/DeliveryAdress',
                                data: {'index': index},
                                screen: DeliveryAdress(
                                  index: index,
                                ));
                          },
                          child: Image.asset(
                            'assets/image/details.png',
                            height: 18,
                            width: 18,
                            color: AppColor.BlackColor,
                          ),
                        )
                      ],
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        textAlign: TextAlign.left,
                        '${myAddressController.myaddressModel!.customer!.addresses!.edges![index].node!.address1}, ${myAddressController.myaddressModel!.customer!.addresses!.edges![index].node!.city}, ${myAddressController.myaddressModel!.customer!.addresses!.edges![index].node!.province}, ${myAddressController.myaddressModel!.customer!.addresses!.edges![index].node!.country}, Pin :${myAddressController.myaddressModel!.customer!.addresses!.edges![index].node!.zip},',
                        style: TextStyle(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(top: 10, bottom: 30),
                        child: Text(
                          textAlign: TextAlign.left,
                          '${myAddressController.myaddressModel!.customer!.addresses!.edges![index].node!.phone}',
                          style: TextStyle(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ));
  }
}
