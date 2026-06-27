// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_new, sized_box_for_whitespace, non_constant_identifier_names, unnecessary_import

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/notificationcontroller.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  NotificationController notificationController =
      Get.put(NotificationController());
  bool isloader = false;

  @override
  void initState() {
    Future.delayed(
      Duration(seconds: 1),
      () {
        setState(() {
          isloader = true;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isloader == false
        ? MediaQuery.of(context).size.width > CommonWidget.headerWidth
            ? Scaffold(
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: AppColor.BgColor,
                  child: SingleChildScrollView(
                    child: StickyHeader(
                      header: CommonWidget()
                          .StickyHeaders(context, Refresh: setState),
                      content: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          CommonWidget().Footer(context)
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Scaffold(
                // appBar: AppBar(),
                body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: AppColor.BgColor,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
              ))
        : MediaQuery.of(context).size.width > CommonWidget.headerWidth
            ? Scaffold(
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: AppColor.BgColor,
                  child: SingleChildScrollView(
                    child: StickyHeader(
                      header: CommonWidget()
                          .StickyHeaders(context, Refresh: setState),
                      content: Column(
                        children: [
                          notificationController.items.isEmpty
                              ? SizedBox()
                              : Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      notificationController.items.clear();
                                      setState(() {});
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.only(right: 20.0),
                                        child: Text(
                                          "Clear All",
                                          style: TextStyle(
                                              color: AppColor.fontColorgrey,
                                              fontSize: 16),
                                        )),
                                  ),
                                ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(top: 20),
                            child: notificationController.items.isEmpty
                                ? ErrorWidget()
                                : PopularListview(),
                          ),
                          CommonWidget().Footer(context)
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Scaffold(
                appBar: CommonWidget().Header(context: context, heart: false),
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: AppColor.BgColor,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        notificationController.items.isEmpty
                            ? SizedBox()
                            : Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    notificationController.items.clear();
                                    setState(() {});
                                  },
                                  child: Padding(
                                      padding: EdgeInsets.only(right: 20.0),
                                      child: Text(
                                        "Clear All",
                                        style: TextStyle(
                                            color: AppColor.fontColorgrey,
                                            fontSize: 16),
                                      )),
                                ),
                              ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(top: 20),
                          child: notificationController.items.isEmpty
                              ? ErrorWidget()
                              : PopularListview(),
                        ),
                      ],
                    ),
                  ),
                ),
              );

    // Scaffold(
    //   backgroundColor: AppColor.BgColor,
    //   appBar: AppBar(
    //     centerTitle: true,
    //     title: Text(
    //       "Notifications",
    //       style:
    //           TextStyle( fontWeight: FontWeight.w500),
    //     ),
    //     automaticallyImplyLeading: false,
    //     surfaceTintColor: Colors.transparent,
    //     backgroundColor: AppColor.BgColor,
    //     leading: InkWell(
    //         overlayColor: WidgetStatePropertyAll(Colors.white),
    //         onTap: () {
    //           Beamer.of(context).beamBack();
    //         },
    //         child: CommonWidget().backicon()),
    //     actions: [
    //       InkWell(
    //         overlayColor: WidgetStatePropertyAll(Colors.white),
    //         onTap: () {
    //           notificationController.items.clear();
    //           setState(() {});
    //         },
    //         child: Padding(
    //             padding: EdgeInsets.only(right: 20.0),
    //             child: Text(
    //               "Clear All",
    //               style: TextStyle(
    //                   color: AppColor.fontColorgrey,
    //
    //                   fontSize: 16),
    //             )),
    //       )
    //     ],
    //   ),
    //   body: Container(
    //     height: MediaQuery.of(context).size.height,
    //     width: MediaQuery.of(context).size.width,
    //     padding: EdgeInsets.only(top: 20),
    //     child: notificationController.items.isEmpty
    //         ? ErrorWidget()
    //         : PopularListview(),
    //   ),
    // );
  }

  ErrorWidget() {
    return Center(
        child: Text(
      "No Data Found",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ));
  }

  PopularListview() {
    return ListView.builder(
      itemCount: notificationController.items.length,
      itemBuilder: (context, int index) {
        return Slidable(
          key: ValueKey(index),
          closeOnScroll: notificationController.isball,
          dragStartBehavior: DragStartBehavior.start,
          endActionPane: ActionPane(
              motion: ScrollMotion(),
              extentRatio: 0.20,
              // dismissible: DismissiblePane(
              //   onDismissed: () {},
              // ),
              // dragDismissible: true,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.imagebg,
                    ),
                    child: Builder(builder: (context) {
                      return InkWell(
                        overlayColor: WidgetStatePropertyAll(Colors.white),
                        onTap: () {
                          widgeter(index).then((value) {
                            Slidable.of(context)!.close().then((value) {});
                          });
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          child: Image.asset(
                            "assets/image/delete.png",
                            color: AppColor.redcolor,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ]),
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(15)),
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Padding(
              padding: EdgeInsets.only(top: 15, bottom: 15),
              child: Row(
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: AppColor.imagebg,
                    ),
                    child: Image(
                        image: AssetImage(AppImage.appIcon + 'sofachair.png')),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    child: Container(
                      padding: EdgeInsets.only(left: 16, top: 15, bottom: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              'Your Order Will Be Ship. Once We Get Confirl Address ${notificationController.items[index]}',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Text(
                            '16 minute ago',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColor.fontColorgrey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDeletion(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure you want to delete?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            )
          ],
        );
      },
    );
  }

  Future widgeter(index) {
    notificationController.items.removeAt(index);
    notificationController.isball = true;
    setState(() {});
    return Future(() => null);
  }
}
