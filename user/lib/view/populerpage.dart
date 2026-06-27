// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_new, sized_box_for_whitespace, non_constant_identifier_names, unnecessary_import, must_be_immutable, prefer_const_constructors_in_immutables

import 'package:EcommerceApp/helper/dailogclass.dart';
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/productmodel.dart';
import 'package:EcommerceApp/view/product_detail_page.dart';
import 'package:EcommerceApp/viewmodel/filtercontroller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flexible_grid_view/flexible_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class PopularPage extends StatefulWidget {
  PopularPage({super.key, this.visitlist});
  List<ProductModel>? visitlist;
  @override
  State<PopularPage> createState() => _PopularPageState();
}

class _PopularPageState extends State<PopularPage> {
  FilterController filterController = Get.put(FilterController());

  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  String sortingvalue = "Sort by";
  bool GridViewTwo = false;
  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > CommonWidget.headerWidth
        ? Scaffold(
            backgroundColor: AppColor.BgColor,
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: AppColor.BgColor,
                  borderRadius: BorderRadius.circular(15)),
              child: SingleChildScrollView(
                  child: StickyHeader(
                      header: CommonWidget()
                          .StickyHeaders(context, Refresh: setState),
                      content:
                          Column(mainAxisSize: MainAxisSize.min, children: [
                        FilterView(),
                        GridViewTwo == false
                            ? NewPopularListview()
                            : NewPopularListviewForTwo(),
                        CommonWidget().Footer(context)
                      ]))),
            ))
        : Scaffold(
            backgroundColor: AppColor.BgColor,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Popular",
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
              actions: [
                InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  child: Container(
                      height: 45,
                      width: 45,
                      margin: EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                          color: AppColor.whiteColor, shape: BoxShape.circle),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Image.asset(
                          AppImage.appIcon + "health.png",
                          color: AppColor.BlackColor,
                        ),
                      )),
                )
              ],
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: AppColor.BgColor,
                  borderRadius: BorderRadius.circular(15)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilterViewApp(),
                    GridViewTwo == false
                        ? NewPopularListview()
                        : NewPopularListviewForTwo(),
                  ],
                ),
              ),
              //  PopularListview(),
            ),
          );
  }

  final OverlayPortalController tooltipController = OverlayPortalController();

  final LayerLink _link = LayerLink();
  void onTap() {
    setState(() {
      tooltipController.show();
    });
  }

  Widget FilterView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // InkWell(
          //   overlayColor: WidgetStatePropertyAll(Colors.white),
          //   onTap: () {
          //     showDialog(
          //         context: context,
          //         builder: (_) {
          //           return StatefulBuilder(
          //             builder: (context, setState) {
          //               return AlertDialog(
          //                 backgroundColor: AppColor.whiteColor,
          //                 actions: [
          //                   SizedBox(
          //                     height: 30,
          //                   ),
          //                   Padding(
          //                     padding: EdgeInsets.symmetric(horizontal: 8.0),
          //                     child: Row(
          //                       mainAxisAlignment:
          //                           MainAxisAlignment.spaceBetween,
          //                       children: [
          //                         SizedBox(
          //                           width: 10,
          //                         ),
          //                         Text(
          //                           'Filter Dailog',
          //                           style: TextStyle(
          //
          //                               fontWeight: FontWeight.w700,
          //                               fontSize: 24.0),
          //                         ),
          //                         InkWell(
          //                           onTap: () {
          //                             Beamer.of(context).beamBack();
          //                           },
          //                           child: Container(
          //                             height: 30,
          //                             width: 30,
          //                             decoration: BoxDecoration(
          //                               shape: BoxShape.circle,
          //                               color: AppColor.redcolor,
          //                             ),
          //                             child: Icon(
          //                               Icons.close,
          //                               color: AppColor.whiteColor,
          //                               size: 18,
          //                             ),
          //                           ),
          //                         )
          //                       ],
          //                     ),
          //                   ),
          //                   Padding(
          //                     padding: EdgeInsets.symmetric(
          //                         horizontal: 24.0, vertical: 20),
          //                     child: Row(
          //                       children: [
          //                         Padding(
          //                           padding: EdgeInsets.only(
          //                             right: 25.0,
          //                           ),
          //                           child: Text(
          //                             "COLOR",
          //                             style: TextStyle(
          //
          //                                 fontWeight: FontWeight.w700,
          //                                 fontSize: 19.0),
          //                           ),
          //                         ),
          //                         Flexible(
          //                           fit: FlexFit.tight,
          //                           child: Wrap(
          //                             runSpacing: 10,
          //                             verticalDirection: VerticalDirection.down,
          //                             children: <Widget>[
          //                               Colormanage(
          //                                   color: Colors.white,
          //                                   selcted: 1,
          //                                   setStates: setState),
          //                               Colormanage(
          //                                   color: Colors.black,
          //                                   selcted: 2,
          //                                   setStates: setState),
          //                               Colormanage(
          //                                   color: Colors.red,
          //                                   selcted: 3,
          //                                   setStates: setState),
          //                               Colormanage(
          //                                   color: Colors.blue,
          //                                   selcted: 4,
          //                                   setStates: setState),
          //                               Colormanage(
          //                                   color: Colors.green,
          //                                   selcted: 5,
          //                                   setStates: setState),
          //                             ],
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                   Padding(
          //                     padding: EdgeInsets.symmetric(
          //                         horizontal: 24.0, vertical: 15),
          //                     child: Row(
          //                       mainAxisSize: MainAxisSize.min,
          //                       children: [
          //                         Padding(
          //                           padding: EdgeInsets.only(
          //                             right: 25.0,
          //                           ),
          //                           child: Text(
          //                             "SIZE",
          //                             style: TextStyle(
          //
          //                                 fontWeight: FontWeight.w700,
          //                                 fontSize: 19.0),
          //                           ),
          //                         ),
          //                         Flexible(
          //                           fit: FlexFit.tight,
          //                           child: Wrap(
          //                             runSpacing: 10,
          //                             verticalDirection: VerticalDirection.down,
          //                             children: <Widget>[
          //                               Sizemanage(
          //                                   size: "XS",
          //                                   selcted: 1,
          //                                   setStates: setState),
          //                               Sizemanage(
          //                                   size: "S",
          //                                   selcted: 2,
          //                                   setStates: setState),
          //                               Sizemanage(
          //                                   size: "M",
          //                                   selcted: 3,
          //                                   setStates: setState),
          //                               Sizemanage(
          //                                   size: "L",
          //                                   selcted: 4,
          //                                   setStates: setState),
          //                               Sizemanage(
          //                                   size: "XL",
          //                                   selcted: 5,
          //                                   setStates: setState),
          //                               Sizemanage(
          //                                   size: "XXL",
          //                                   selcted: 6,
          //                                   setStates: setState),
          //                               Sizemanage(
          //                                   size: "XXXL",
          //                                   selcted: 7,
          //                                   setStates: setState),
          //                             ],
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),

          //                   //  Sizefilter(),
          //                   CommanDivider(),
          //                   Commantitle(
          //                     title: "Price Range",
          //                     viewall: false,
          //                   ),
          //                   Padding(
          //                     padding: EdgeInsets.symmetric(vertical: 10),
          //                     child: Column(
          //                       children: [
          //                         Padding(
          //                           padding: const EdgeInsets.symmetric(
          //                             horizontal: 24.0,
          //                           ),
          //                           child: Row(
          //                             mainAxisAlignment:
          //                                 MainAxisAlignment.spaceBetween,
          //                             children: [
          //                               Text(
          //                                 "₹ ${filterController.syncvalues.start.toStringAsFixed(1)}",
          //                                 style: TextStyle(
          //
          //                                     fontSize: 16,
          //                                     fontWeight: FontWeight.w500),
          //                               ),
          //                               Text(
          //                                 "₹ ${filterController.syncvalues.end.toStringAsFixed(1)}",
          //                                 style: TextStyle(
          //
          //                                     fontSize: 16,
          //                                     fontWeight: FontWeight.w500),
          //                               ),
          //                             ],
          //                           ),
          //                         ),
          //                         Padding(
          //                           padding: const EdgeInsets.symmetric(
          //                               horizontal: 8.0),
          //                           child: SliderTheme(
          //                             data: SliderTheme.of(context).copyWith(
          //                               trackShape:
          //                                   RectangularSliderTrackShape(),
          //                               trackHeight: 7.0,
          //                               thumbShape: RoundSliderThumbShape(
          //                                   enabledThumbRadius: 12.0),
          //                             ),
          //                             child: RangeSlider(
          //                               min: 0.0,
          //                               max: 100000.0,
          //                               labels: RangeLabels(
          //                                   filterController.syncvalues.start
          //                                       .toString(),
          //                                   filterController.syncvalues.end
          //                                       .toString()),
          //                               activeColor: AppColor.BlackColor,
          //                               inactiveColor: AppColor.imagebg,
          //                               onChanged: (values) {
          //                                 setState(() => filterController
          //                                     .syncvalues = values);
          //                               },
          //                               values: filterController.syncvalues,
          //                             ),
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                   // Amountslider(),
          //                   SizedBox(
          //                     height: 30,
          //                   ),
          //                   Wrap(
          //                     runAlignment: WrapAlignment.spaceAround,
          //                     runSpacing: 10,
          //                     children: [
          //                       ApplyBotton(setStates: setState),
          //                       ResetBotton(setStates: setState),
          //                     ],
          //                   ),
          //                 ],
          //               );
          //             },
          //           );
          //         });
          //   },
          //   child: Container(
          //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          //     decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(15),
          //         color: AppColor.imagebg),
          //     child: Row(
          //       children: [
          //         Container(
          //           margin: EdgeInsets.only(right: 20),
          //           child: Text(
          //             "Filter & Sort",
          //             style: TextStyle(
          //
          //                 fontSize: 20,
          //                 fontWeight: FontWeight.w600),
          //           ),
          //         ),
          //         Align(
          //           alignment: Alignment.bottomCenter,
          //           child: SvgPicture.asset(
          //             "assets/image/filter.svg",
          //             height: 20,
          //             width: 20,
          //           ),
          //         )
          //       ],
          //     ),
          //   ),
          // ),

          CompositedTransformTarget(
            link: _link,
            child: OverlayPortal(
              controller: tooltipController,
              overlayChildBuilder: (BuildContext context) {
                return CompositedTransformFollower(
                  link: _link,
                  targetAnchor: Alignment.bottomLeft,
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.975,
                        // height: MediaQuery.of(context).size.height * 0.5,
                        decoration: ShapeDecoration(
                          color: Colors.white60,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1.5,
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x11000000),
                              blurRadius: 32,
                              offset: Offset(0, 20),
                              spreadRadius: -8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Center(
                                child: Text(
                                  'Filter Dailog',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 24.0),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 20),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: 25.0,
                                    ),
                                    child: Text(
                                      "COLOR",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 19.0),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Wrap(
                                      runSpacing: 10,
                                      verticalDirection: VerticalDirection.down,
                                      children: <Widget>[
                                        Colormanage(
                                            color: Colors.white,
                                            selcted: 1,
                                            setStates: setState),
                                        Colormanage(
                                            color: Colors.black,
                                            selcted: 2,
                                            setStates: setState),
                                        Colormanage(
                                            color: Colors.red,
                                            selcted: 3,
                                            setStates: setState),
                                        Colormanage(
                                            color: Colors.blue,
                                            selcted: 4,
                                            setStates: setState),
                                        Colormanage(
                                            color: Colors.green,
                                            selcted: 5,
                                            setStates: setState),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Colorfilter()
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 15),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: 25.0,
                                    ),
                                    child: Text(
                                      "SIZE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 19.0),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Wrap(
                                      runSpacing: 10,
                                      verticalDirection: VerticalDirection.down,
                                      children: <Widget>[
                                        Sizemanage(
                                            size: "28",
                                            selcted: 1,
                                            setStates: setState),
                                        Sizemanage(
                                            size: "30",
                                            selcted: 2,
                                            setStates: setState),
                                        Sizemanage(
                                            size: "32",
                                            selcted: 3,
                                            setStates: setState),
                                        Sizemanage(
                                            size: "34",
                                            selcted: 4,
                                            setStates: setState),
                                        Sizemanage(
                                            size: "36",
                                            selcted: 5,
                                            setStates: setState),
                                        Sizemanage(
                                            size: "38",
                                            selcted: 6,
                                            setStates: setState),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //  Sizefilter(),
                            CommanDivider(),
                            Commantitle(
                              title: "Price Range",
                              viewall: false,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "₹ ${filterController.syncvalues.start.toStringAsFixed(1)}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "₹ ${filterController.syncvalues.end.toStringAsFixed(1)}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackShape:
                                            RectangularSliderTrackShape(),
                                        trackHeight: 7.0,
                                        thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: 12.0),
                                      ),
                                      child: RangeSlider(
                                        min: 0.0,
                                        max: 100000.0,
                                        labels: RangeLabels(
                                            filterController.syncvalues.start
                                                .toString(),
                                            filterController.syncvalues.end
                                                .toString()),
                                        activeColor: AppColor.BlackColor,
                                        inactiveColor: AppColor.imagebg,
                                        onChanged: (values) {
                                          setState(() => filterController
                                              .syncvalues = values);
                                        },
                                        values: filterController.syncvalues,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Amountslider(),
                            SizedBox(
                              height: 30,
                            ),
                            Wrap(
                              runAlignment: WrapAlignment.spaceAround,
                              runSpacing: 10,
                              children: [
                                ApplyBotton(setStates: setState),
                                ResetBotton(setStates: setState),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              child:

                  //  tooltipController.isShowing
                  //     ? InkWell(
                  //         onTap: () {
                  //           setState(() {
                  //             tooltipController.hide();
                  //           });
                  //         },
                  //         child: Container(
                  //           height: 30,
                  //           width: 30,
                  //           decoration: BoxDecoration(
                  //             shape: BoxShape.circle,
                  //             color: AppColor.redcolor,
                  //           ),
                  //           child: Icon(
                  //             Icons.close,
                  //             color: AppColor.whiteColor,
                  //             size: 18,
                  //           ),
                  //         ),
                  //       )
                  //     :
                  ButtonWidget(
                onTap: tooltipController.isShowing
                    ? () {
                        setState(() {
                          tooltipController.hide();
                        });
                      }
                    : onTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 20),
                        child: Text(
                          "Filter & Sort",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                      tooltipController.isShowing
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  tooltipController.hide();
                                });
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.redcolor,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: AppColor.whiteColor,
                                  size: 18,
                                ),
                              ),
                            )
                          : SvgPicture.asset(
                              "assets/image/filter.svg",
                              height: 20,
                              width: 20,
                            )
                    ],
                  ),
                ),
              ),
            ),
          ),

          Row(
            children: [
              Container(
                height: 50,
                width: 130,
                child: Padding(
                  padding: EdgeInsets.only(right: 12.0, top: 2),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      // focusColor: AppColor.BgColor,
                      // dropdownColor: AppColor.BgColor,
                      // onTap: () {},
                      dropdownStyleData: DropdownStyleData(
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        offset: const Offset(-20, 0),
                        scrollbarTheme: ScrollbarThemeData(
                          radius: const Radius.circular(40),
                          thickness: WidgetStateProperty.all(6),
                          thumbVisibility: WidgetStateProperty.all(true),
                        ),
                      ),
                      onChanged: (value) {
                        sortingvalue = value as String;
                        sortingvalue = sortingvalue;
                      },
                      // value: sortingvalue,
                      isExpanded: true,
                      alignment: Alignment.center,
                      hint: Text(
                        "SORT BY",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 550
                                ? 14
                                : 16,
                            color: AppColor.BlackColor,
                            fontWeight: FontWeight.w600),
                      ),
                      items: CommonWidget.sortinglist
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          alignment: Alignment.centerLeft,
                          value: value,
                          // enabled: false,
                          child: Text(
                            value.toString(),
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width < 550
                                        ? 14
                                        : 16,
                                color: AppColor.BlackColor,
                                fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 12),
                child: Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: InkWell(
                      overlayColor: WidgetStatePropertyAll(Colors.white),
                      onTap: () {},
                      child: SvgPicture.asset(
                        "assets/image/Search Icon.svg",
                        width: 23,
                        height: 23,
                      )),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 12),
                child: Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: InkWell(
                      overlayColor: WidgetStatePropertyAll(Colors.white),
                      onTap: () {
                        setState(() {
                          GridViewTwo = true;
                        });
                      },
                      child: Icon(Icons.grid_view)),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 12),
                child: Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: InkWell(
                      overlayColor: WidgetStatePropertyAll(Colors.white),
                      onTap: () {
                        setState(() {
                          GridViewTwo = false;
                        });
                      },
                      child: Icon(Icons.grid_on_outlined)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget FilterViewApp() {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CompositedTransformTarget(
            link: _link,
            child: OverlayPortal(
              controller: tooltipController,
              overlayChildBuilder: (BuildContext context) {
                return CompositedTransformFollower(
                  link: _link,
                  targetAnchor: Alignment.bottomLeft,
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.975,
                        // height: MediaQuery.of(context).size.height * 0.5,
                        decoration: ShapeDecoration(
                          color: Colors.white60,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1.5,
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x11000000),
                              blurRadius: 32,
                              offset: Offset(0, 20),
                              spreadRadius: -8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Center(
                                child: Text(
                                  'Filter Dailog',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 24.0),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 20),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: 25.0,
                                    ),
                                    child: Text(
                                      "COLOR",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 19.0),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Wrap(
                                      runSpacing: 10,
                                      verticalDirection: VerticalDirection.down,
                                      children: <Widget>[
                                        Colormanage(
                                            color: Colors.white,
                                            selcted: 1,
                                            setStates: setState),
                                        Colormanage(
                                            color: Colors.black,
                                            selcted: 2,
                                            setStates: setState),
                                        Colormanage(
                                            color: Colors.red,
                                            selcted: 3,
                                            setStates: setState),
                                        Colormanage(
                                            color: Colors.blue,
                                            selcted: 4,
                                            setStates: setState),
                                        Colormanage(
                                            color: Colors.green,
                                            selcted: 5,
                                            setStates: setState),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Colorfilter()
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 15),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: 25.0,
                                    ),
                                    child: Text(
                                      "SIZE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 19.0),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Wrap(
                                      runSpacing: 10,
                                      verticalDirection: VerticalDirection.down,
                                      children: <Widget>[
                                        Sizemanage(
                                            size: "XS",
                                            selcted: 1,
                                            setStates: setState),
                                        Sizemanage(
                                            size: "S",
                                            selcted: 2,
                                            setStates: setState),
                                        Sizemanage(
                                            size: "M",
                                            selcted: 3,
                                            setStates: setState),
                                        Sizemanage(
                                            size: "L",
                                            selcted: 4,
                                            setStates: setState),
                                        Sizemanage(
                                            size: "XL",
                                            selcted: 5,
                                            setStates: setState),
                                        Sizemanage(
                                            size: "XXL",
                                            selcted: 6,
                                            setStates: setState),
                                        Sizemanage(
                                            size: "XXXL",
                                            selcted: 7,
                                            setStates: setState),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //  Sizefilter(),
                            CommanDivider(),
                            Commantitle(
                              title: "Price Range",
                              viewall: false,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "₹ ${filterController.syncvalues.start.toStringAsFixed(1)}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "₹ ${filterController.syncvalues.end.toStringAsFixed(1)}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackShape:
                                            RectangularSliderTrackShape(),
                                        trackHeight: 7.0,
                                        thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: 12.0),
                                      ),
                                      child: RangeSlider(
                                        min: 0.0,
                                        max: 100000.0,
                                        labels: RangeLabels(
                                            filterController.syncvalues.start
                                                .toString(),
                                            filterController.syncvalues.end
                                                .toString()),
                                        activeColor: AppColor.BlackColor,
                                        inactiveColor: AppColor.imagebg,
                                        onChanged: (values) {
                                          setState(() => filterController
                                              .syncvalues = values);
                                        },
                                        values: filterController.syncvalues,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Amountslider(),
                            SizedBox(
                              height: 30,
                            ),
                            Wrap(
                              runAlignment: WrapAlignment.spaceAround,
                              runSpacing: 10,
                              children: [
                                ApplyBotton(setStates: setState),
                                ResetBotton(setStates: setState),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ButtonWidget(
                  width: MediaQuery.of(context).size.width * 0.5,
                  onTap: tooltipController.isShowing
                      ? () {
                          setState(() {
                            tooltipController.hide();
                          });
                        }
                      : onTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 20),
                          child: Text(
                            "Filter & Sort",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                        ),
                        tooltipController.isShowing
                            ? InkWell(
                                onTap: () {
                                  setState(() {
                                    tooltipController.hide();
                                  });
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColor.redcolor,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: AppColor.whiteColor,
                                    size: 18,
                                  ),
                                ),
                              )
                            : SvgPicture.asset(
                                "assets/image/filter.svg",
                                height: 20,
                                width: 20,
                              )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            child: Container(
              height: 50,
              child: Padding(
                padding: EdgeInsets.only(right: 1.0, top: 2),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    dropdownStyleData: DropdownStyleData(
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      offset: const Offset(-20, 0),
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: WidgetStateProperty.all(6),
                        thumbVisibility: WidgetStateProperty.all(true),
                      ),
                    ),
                    onChanged: (value) {
                      sortingvalue = value as String;

                      sortingvalue = sortingvalue;
                    },
                    // value: sortingvalue,
                    isExpanded: true,
                    alignment: Alignment.center,
                    hint: Text(
                      "SORT BY",
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width < 550 ? 14 : 16,
                          color: AppColor.BlackColor,
                          fontWeight: FontWeight.w600),
                    ),
                    items: CommonWidget.sortinglist
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        alignment: Alignment.centerLeft,
                        value: value,
                        // enabled: false,
                        child: Text(
                          value.toString(),
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 550
                                  ? 14
                                  : 16,
                              color: AppColor.BlackColor,
                              fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ]);
  }

  Widget NewPopularListview() {
    return Padding(
        // padding: EdgeInsets.only(left: 24.0, right: 24, top: 15, bottom: 15),
        // child: Container(
        //   margin: EdgeInsets.symmetric(
        //       horizontal: MediaQuery.of(context).size.width * 0.1),
        //   child: FlexibleGridView(
        //       axisCount: Responsive.isMobile(context) ||
        //               MediaQuery.of(context).size.width < 750
        //           ? GridLayoutEnum.twoElementsInRow
        //           : MediaQuery.of(context).size.width < 1200
        //               ? GridLayoutEnum.threeElementsInRow
        //               : GridLayoutEnum.fourElementsInRow,
        //       shrinkWrap: true,
        //       mainAxisSpacing: 30,
        //       crossAxisSpacing: MediaQuery.of(context).size.width < 1500
        //           ? MediaQuery.of(context).size.width < 1200
        //               ? MediaQuery.of(context).size.width < 800
        //                   ? MediaQuery.of(context).size.width < 600
        //                       ? 10
        //                       : 20
        //                   : 40
        //               : 60
        //           : 90,
        padding: MediaQuery.of(context).size.width < 600
            ? EdgeInsets.only(top: 15, bottom: 15)
            : EdgeInsets.only(left: 24.0, right: 24, top: 15, bottom: 15),
        child: Container(
          // width: MediaQuery.of(context).size.width * 0.8,
          margin: MediaQuery.of(context).size.width > 800
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.1)
              : EdgeInsets.symmetric(horizontal: 20),
          // color: AppColor.BlackColor,
          child: FlexibleGridView(
              physics: ClampingScrollPhysics(),
              axisCount: MediaQuery.of(context).size.width < 600 ||
                      MediaQuery.of(context).size.width < 1200
                  ? GridLayoutEnum.twoElementsInRow
                  : MediaQuery.of(context).size.width < 1800
                      ? GridLayoutEnum.threeElementsInRow
                      : GridLayoutEnum.fourElementsInRow,
              shrinkWrap: true,
              mainAxisSpacing: 30,
              crossAxisSpacing: MediaQuery.of(context).size.width < 1800
                  ? MediaQuery.of(context).size.width < 1500
                      ? MediaQuery.of(context).size.width < 1200
                          ? MediaQuery.of(context).size.width < 600
                              ? 10
                              : 20
                          : 40
                      : 60
                  : 90,
              children: List.generate(widget.visitlist!.length, (index) {
                return InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  onTap: () {
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        routename:
                            '/ProductDetailScreen/${widget.visitlist![index].id}',
                        data: {
                          'productModel': widget.visitlist![index],
                          'productName': widget.visitlist![index].title
                        },
                        screen: ProductDetailScreen(
                          productModel: widget.visitlist![index],
                          title: widget.visitlist![index].title,
                        ));
                  },
                  child: Center(
                    child: Container(
                      height: Responsive.isMobile(context) ? 260 : 430,
                      width: Responsive.isMobile(context) ? 211 : 400,
                      decoration: BoxDecoration(
                          color: AppColor.whiteColor,
                          border: Appborder.appborder,
                          boxShadow: [Appshadow.shadow],
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Flexible(
                              flex: 1,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageBuilder: (context, imageProvider) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      );
                                    },
                                    imageUrl:
                                        widget.visitlist![index].thumbnail,
                                    placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                      color: AppColor.BlackColor,
                                    )),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      overlayColor:
                                          WidgetStatePropertyAll(Colors.white),
                                      onTap: () {},
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Image.asset(
                                          AppImage.appIcon + 'health.png',
                                          color: Colors.black,
                                          height: 30,
                                          width: 30,
                                          // color: AppColor.redcolor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        fit: FlexFit.tight,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.visitlist![index].title,
                                              // replaceAll('RAJGARHWALA FURNITURE', '')
                                              maxLines: 1,
                                              style: TextStyle(
                                                  height: 1.2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: AppColor.BlackColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              widget.visitlist![index].brand!
                                                  .name,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: AppColor.fontColorgrey,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          widget.visitlist![index].salePrice ==
                                                  0
                                              ? Container()
                                              : Container(
                                                  child: Text(
                                                    "₹ ${widget.visitlist![index].price}.00",
                                                    style: TextStyle(
                                                        color: AppColor
                                                            .viewallcolor,
                                                        fontSize: 14,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                          Container(
                                            child: Text(
                                              // "₹ ${widget.visitlist![index].salePrice}.00",
                                              "₹ ${(widget.visitlist![index].price - (widget.visitlist![index].price * (widget.visitlist![index].salePrice * 0.01))).toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  color: AppColor.BlackColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Container(
                                      //   margin: EdgeInsets.only(top: 10),
                                      //   child: Text(
                                      //     "₹ ${widget.visitlist![index].price}.00",
                                      //     style: TextStyle(
                                      //         color: AppColor.viewallcolor,
                                      //         fontSize: 14,
                                      //         fontWeight: FontWeight.w600),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: AppColor.BlackColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    width: Responsive.isMobile(context)
                                        ? 200
                                        : 400,
                                    child: Center(
                                      child: Text(
                                        "View Details",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: AppColor.BgColor,
                                            fontFamily: AppFont.lato),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(top: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              })),
        ));
  }

  Widget NewPopularListviewForTwo() {
    return Padding(
        padding: EdgeInsets.only(left: 24.0, right: 24, top: 15, bottom: 15),
        child: FlexibleGridView(
            axisCount: GridLayoutEnum.twoElementsInRow,
            shrinkWrap: true,
            mainAxisSpacing: 30,
            crossAxisSpacing: MediaQuery.of(context).size.width < 1500
                ? MediaQuery.of(context).size.width < 1200
                    ? MediaQuery.of(context).size.width < 800
                        ? MediaQuery.of(context).size.width < 600
                            ? 10
                            : 20
                        : 40
                    : 60
                : 90,
            children: List.generate(
              widget.visitlist!.length,
              (index) => InkWell(
                overlayColor: WidgetStatePropertyAll(Colors.white),
                onTap: () {
                  WebAPPNavigation.navigateToroute(
                      context: context,
                      routename:
                          '/ProductDetailScreen/${widget.visitlist![index].id}',
                      data: {
                        'productModel': widget.visitlist![index],
                        'productName': widget.visitlist![index].title
                      },
                      screen: ProductDetailScreen(
                        productModel: widget.visitlist![index],
                        title: widget.visitlist![index].title,
                      ));
                },
                child: Container(
                  height: Responsive.isMobile(context)
                      ? 260
                      : GridViewTwo
                          ? 600
                          : 400,
                  width: Responsive.isMobile(context)
                      ? 211
                      : GridViewTwo
                          ? MediaQuery.of(context).size.width * 0.5
                          : 400,
                  decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      border: Appborder.appborder,
                      boxShadow: [Appshadow.shadow],
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                fit: BoxFit.contain,
                                imageBuilder: (context, imageProvider) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.contain),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  );
                                },
                                imageUrl: widget.visitlist![index].thumbnail,
                                placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                  color: AppColor.BlackColor,
                                )),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  overlayColor:
                                      WidgetStatePropertyAll(Colors.white),
                                  onTap: () {},
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      AppImage.appIcon + 'health.png',
                                      color: Colors.black,
                                      height: 30,
                                      width: 30,
                                      // color: AppColor.redcolor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.visitlist![index].title,
                                          // replaceAll('RAJGARHWALA FURNITURE', '')
                                          maxLines: 1,
                                          style: TextStyle(
                                              height: 1.2,
                                              overflow: TextOverflow.ellipsis,
                                              color: AppColor.BlackColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          widget.visitlist![index].brand!.name,
                                          maxLines: 1,
                                          style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              color: AppColor.fontColorgrey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      widget.visitlist![index].salePrice == 0
                                          ? Container()
                                          : Container(
                                              child: Text(
                                                "₹ ${widget.visitlist![index].price}.00",
                                                style: TextStyle(
                                                    color:
                                                        AppColor.viewallcolor,
                                                    fontSize: 14,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                      Container(
                                        child: Text(
                                          // "₹ ${widget.visitlist![index].salePrice}.00",
                                          "₹ ${(widget.visitlist![index].price - (widget.visitlist![index].price * (widget.visitlist![index].salePrice * 0.01))).toStringAsFixed(2)}",
                                          style: TextStyle(
                                              color: AppColor.BlackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Container(
                                  //   margin: EdgeInsets.only(top: 10),
                                  //   child: Text(
                                  //     "₹ ${widget.visitlist![index].price}.00",
                                  //     style: TextStyle(
                                  //         color: AppColor.viewallcolor,
                                  //         fontSize: 14,
                                  //         fontWeight: FontWeight.w600),
                                  //   ),
                                  // ),
                                ],
                              ),
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    color: AppColor.BlackColor,
                                    borderRadius: BorderRadius.circular(10)),
                                width: Responsive.isMobile(context)
                                    ? 200
                                    : GridViewTwo
                                        ? MediaQuery.of(context).size.width *
                                            0.46
                                        : 400,
                                child: Center(
                                  child: Text(
                                    "View Details",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: AppColor.BgColor,
                                        fontFamily: AppFont.lato),
                                  ),
                                ),
                                margin: EdgeInsets.only(top: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }

  CommanDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 15),
      child: Divider(
        color: AppColor.imagebg,
      ),
    );
  }

  Commantitle({title, viewall, viewalltap}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          viewall == true
              ? InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  onTap: viewalltap,
                  child: Text(
                    "View all",
                    style:
                        TextStyle(fontSize: 16, color: AppColor.viewallcolor),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

  Amountslider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "₹ ${filterController.syncvalues.start.toStringAsFixed(1)}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  "₹ ${filterController.syncvalues.end.toStringAsFixed(1)}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackShape: RectangularSliderTrackShape(),
                trackHeight: 7.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
              ),
              child: RangeSlider(
                min: 0.0,
                max: 100000.0,
                labels: RangeLabels(
                    filterController.syncvalues.start.toString(),
                    filterController.syncvalues.end.toString()),
                activeColor: AppColor.BlackColor,
                inactiveColor: AppColor.imagebg,
                onChanged: (values) {
                  setState(() => filterController.syncvalues = values);
                },
                values: filterController.syncvalues,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Brandfilter() {
    return Container(
      height: 35,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(
        top: 24,
      ),
      child: ListView.builder(
        itemCount: 3,
        padding: EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.white),
            onTap: () {
              filterController.brandvalue = index;
              setState(() {});
            },
            child: Container(
              margin: EdgeInsets.only(left: index == 0 ? 0 : 10, right: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: filterController.brandvalue == index
                      ? AppColor.BlackColor
                      : AppColor.whiteColor),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Text(
                      "${filterController.brandvalues[index]}",
                      style: TextStyle(
                          fontSize: 16,
                          color: filterController.brandvalue == index
                              ? AppColor.whiteColor
                              : AppColor.fontColorgrey,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                        overlayColor: WidgetStatePropertyAll(Colors.white),
                        child: Image.asset(
                          AppImage.appIcon + "arrow_right.png",
                          color: filterController.brandvalue == index
                              ? AppColor.whiteColor
                              : AppColor.fontColorgrey,
                          height: 10,
                        )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget Sizefilter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: 25.0,
            ),
            child: Text(
              "SIZE",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19.0),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Wrap(
              runSpacing: 10,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Sizemanage(size: "XS", selcted: 1),
                Sizemanage(size: "S", selcted: 2),
                Sizemanage(size: "M", selcted: 3),
                Sizemanage(size: "L", selcted: 4),
                Sizemanage(size: "XL", selcted: 5),
                Sizemanage(size: "XXL", selcted: 6),
                Sizemanage(size: "XXXL", selcted: 7),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget Sizemanage({size, selcted, Function? setStates}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        setStates!(() {
          sizeselected = selcted;
        });
      },
      child: Container(
        height: 33,
        width: 33,
        padding: EdgeInsets.all(4),
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
            color: sizeselected != selcted
                ? AppColor.BgColor
                : AppColor.BlackColor,
            border: Appborder.appborder,
            borderRadius: BorderRadius.circular(8)),
        child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              size,
              style: TextStyle(
                  fontSize: 18,
                  color: sizeselected == selcted
                      ? AppColor.BgColor
                      : AppColor.BlackColor,
                  fontWeight: FontWeight.w600),
            )),
      ),
    );
  }

  // Widget Colorfilter() {
  //   return
  // }

  Widget Reset() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.all(4),
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
            color: AppColor.imagebg,
            border: Appborder.appborder,
            borderRadius: BorderRadius.circular(8)),
        child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "Reset Filter",
              style: TextStyle(
                  fontSize: 18,
                  color: AppColor.BlackColor,
                  fontWeight: FontWeight.w600),
            )),
      ),
    );
  }

  int sizeselected = 1;
  int colorselected = 1;
  Widget Colormanage({color, selcted, Function? setStates}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        setStates!(() {
          colorselected = selcted;
        });
      },
      child: Container(
        height: 30,
        width: 30,
        padding: EdgeInsets.all(4),
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Appborder.appborder,
        ),
        child: colorselected == selcted
            ? Center(
                child: Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.grey,
                ),
              )
            : null,
      ),
    );
  }

  Ratefilter() {
    return Container(
      height: 30,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 24),
      child: ListView.builder(
        itemCount: 5,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          return InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.white),
            onTap: () {
              filterController.starvalue = index;
              setState(() {});
            },
            child: Container(
              margin: EdgeInsets.only(left: index == 0 ? 0 : 10, right: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: filterController.starvalue == index
                      ? AppColor.BlackColor
                      : AppColor.whiteColor),
              child: Padding(
                padding: EdgeInsets.only(left: 12.0, right: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${5 - index}",
                      style: TextStyle(
                          fontSize: 16,
                          color: filterController.starvalue == index
                              ? AppColor.whiteColor
                              : AppColor.fontColorgrey,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                        overlayColor: WidgetStatePropertyAll(Colors.white),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 3.0),
                          child: Image.asset(
                            AppImage.appIcon + "Star.png",
                            height: 12,
                            color: filterController.starvalue == index
                                ? AppColor.whiteColor
                                : AppColor.starcolor,
                          ),
                        )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  CommannewDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 24.0, right: 24, bottom: 15),
      child: Divider(
        color: AppColor.imagebg,
      ),
    );
  }

  Future Filterprefset() async {
    final SharedPreferences perfs = await SharedPreferences.getInstance();

    perfs.setDouble("minimum", filterController.syncvalues.start);
    perfs.setDouble("maximum", filterController.syncvalues.end);
  }

  Widget ApplyBotton({Function? setStates}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        // setState(() {
        //   filterController.isLoader = true;
        // });
        Filterprefset().then((value) {
          tooltipController.hide();
        });
        // filterController.GetFilterApply().then((value) {
        //   setState(() {
        //     filterController.isLoader = true;
        //   });
        // });
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: 450),
        padding: EdgeInsets.symmetric(
          vertical: 15,
        ),
        margin: EdgeInsets.only(left: 24, right: 24, bottom: 24),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColor.btnColorblack),
        child: Text(
          "Apply Filter",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColor.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget ResetBotton({Function? setStates}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        // setState(() {
        //   filterController.isLoader = true;
        // });
        setStates!(() {
          filterController.syncvalues = RangeValues(0.0, 100000.0);

          sizeselected = 1;
          colorselected = 1;
        });
        // filterController.GetFilterApply().then((value) {
        //   setState(() {
        //     filterController.isLoader = true;
        //   });
        // });
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: 450),
        padding: EdgeInsets.symmetric(
          vertical: 15,
        ),
        margin: EdgeInsets.only(left: 24, right: 24, bottom: 24),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColor.btnColorblack),
        child: Text(
          "Reset Filter",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColor.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
