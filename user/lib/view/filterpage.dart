// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_interpolation_to_compose_strings, sized_box_for_whitespace, unnecessary_import, non_constant_identifier_names, unnecessary_string_interpolations

import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/filtercontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  FilterController filterController = Get.put(FilterController());

  double minimum = 0.0;
  double maximum = 100000.0;

  Future searchpref() async {
    // final SharedPreferences perfs = await SharedPreferences.getInstance();
    // minimum = perfs.getDouble(
    //       "minimum",
    //     ) ??
    //     0.0;
    // maximum = perfs.getDouble(
    //       "maximum",
    //     ) ??
    //     50000.0;
    setState(() {
      filterController.syncvalues = RangeValues(minimum, maximum);
    });
  }

  @override
  void initState() {
    searchpref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > CommonWidget.headerWidth
        ? Scaffold(
            backgroundColor: AppColor.BgColor,
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: StickyHeader(
                  header:
                      CommonWidget().StickyHeaders(context, Refresh: setState),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Colorfilter(),
                      Sizefilter(),
                      CommanDivider(),
                      Commantitle(
                        title: "Price Range",
                        viewall: false,
                      ),
                      Amountslider(),
                      CommannewDivider(),
                      // Commantitle(title: "Customer Review", viewall: false),
                      // Ratefilter(),
                      // Spacer(),
                      SizedBox(
                        height: 300,
                      ),
                      Wrap(
                        runAlignment: WrapAlignment.spaceAround,
                        runSpacing: 10,
                        children: [
                          ApplyBotton(),
                          ResetBotton(),
                        ],
                      ),
                      CommonWidget().Footer(context),
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
                "Filter",
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
              child: Column(
                children: [
                  Colorfilter(),
                  Sizefilter(),
                  CommanDivider(),
                  Commantitle(
                    title: "Price Range",
                    viewall: false,
                  ),
                  Amountslider(),
                  CommannewDivider(),
                  // Commantitle(title: "Customer Review", viewall: false),
                  // Ratefilter(),
                  Spacer(),
                  Wrap(
                    runAlignment: WrapAlignment.spaceAround,
                    runSpacing: 10,
                    children: [
                      ApplyBotton(),
                      ResetBotton(),
                    ],
                  ),
                ],
              ),
            ),
          );
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

  Widget Sizemanage({size, selcted}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        setState(() {
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

  Colorfilter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 15),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: 25.0,
            ),
            child: Text(
              "COLOR",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19.0),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Wrap(
              runSpacing: 10,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Colormanage(color: Colors.white, selcted: 1),
                Colormanage(color: Colors.black, selcted: 2),
                Colormanage(color: Colors.red, selcted: 3),
                Colormanage(color: Colors.blue, selcted: 4),
                Colormanage(color: Colors.green, selcted: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
  Widget Colormanage({color, selcted}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        setState(() {
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

  Widget ApplyBotton() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        // setState(() {
        //   filterController.isLoader = true;
        // });
        Filterprefset().then((value) {
          // tooltipController.hide();
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

  ResetBotton() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        // setState(() {
        //   filterController.isLoader = true;
        // });
        setState(() {
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
