// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_new, sized_box_for_whitespace, non_constant_identifier_names, unnecessary_import, must_be_immutable, unnecessary_string_interpolations, avoid_print, curly_braces_in_flow_control_structures, deprecated_member_use

import 'package:EcommerceApp/helper/dailogclass.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/productmodel.dart';
import 'package:EcommerceApp/model/wishlistmodel.dart';
import 'package:EcommerceApp/view/categorypage.dart';
import 'package:EcommerceApp/view/filterpage.dart';
import 'package:EcommerceApp/viewmodel/filtercontroller.dart';
import 'package:EcommerceApp/viewmodel/homecontroller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flexible_grid_view/flexible_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/api/user_data_api.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/mostInterestedcontoller.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class CategoryViewallPage extends StatefulWidget {
  CategoryViewallPage({super.key, this.visitlist});
  List<CategoryModel>? visitlist;

  @override
  State<CategoryViewallPage> createState() => _CategoryViewallPageState();
}

class _CategoryViewallPageState extends State<CategoryViewallPage> {
  MostIntrestedController mostIntrestedController =
      Get.put(MostIntrestedController());
  FilterController filterController = Get.put(FilterController());
  Homecontoller homecontoller = Get.put(Homecontoller());

  String sortingvalue = "Sort by";

  List<CategoryModel> viewall = [];
  List<bool> fevorite_viewall = [];
  List<CategoryModel> viewallsearch = [];
  bool textfield = false;
  TextEditingController searchcontroller = TextEditingController();
  @override
  void initState() {
    setState(() {
      viewall = widget.visitlist!;
      // mostIntrestedController.Reserve = widget.visitlist!;
    });
    viewallsearch = viewall;

    super.initState();
  }

  @override
  void dispose() {
    setState(() {
      filterController.syncvalues = RangeValues(0.0, 100000.0);

      sizeselected = 1;
      colorselected = 1;
    });
    super.dispose();
  }

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
                      content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // FilterView(),
                            viewall.isEmpty
                                ? Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.8,
                                    child: Center(
                                        child: Text(
                                      "No Data Found",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    )))
                                : NewPopularListview(),

                            //  NewPopularListviewForTwo(),
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
                    // GridViewTwo == false
                    //     ?
                    NewPopularListview()
                    // : NewPopularListviewForTwo(),
                  ],
                ),
              ),
              //  PopularListview(),
            ),
          );
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
              viewall.length,
              (index) => InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  onTap: () {
                    // WebAPPNavigation.navigateToroute(
                    //     context: context,
                    //     routename:
                    //         '/ProductDetailScreen/${viewall[index].name.replaceAll(' ', '-')}',
                    //     data: {
                    //       'id': viewall[index].id,
                    //       'productName': viewall[index].name
                    //     },
                    //     screen: ProductDetailScreen(
                    //       title: viewall[index].name,
                    //     ));
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: InkWell(
                      overlayColor: WidgetStatePropertyAll(Colors.white),
                      onTap: () {
                        WebAPPNavigation.navigateToroute(
                            context: context,
                            routename:
                                '/CategoryPage/${viewall[index].name.replaceAll(' ', '-')}',
                            data: {
                              'id': viewall[index].id,
                            },
                            screen: CategoryPage(
                              id: viewall[index].id,
                              title: viewall[index].name,
                            ));
                      },
                      child: Container(
                        width: 200,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Flexible(
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageBuilder: (context, imageProvider) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: AppColor.whiteColor,
                                        border: Appborder.appborder,
                                        boxShadow: [Appshadow.shadow],
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover),
                                      ),
                                    );
                                  },
                                  imageUrl: viewall[index].image,
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                    color: AppColor.BlackColor,
                                  )),
                                  errorWidget: (context, url, error) =>
                                      Center(child: Icon(Icons.error)),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "${viewall[index].name}",
                                  maxLines: 1,
                                  style: TextStyle(
                                      height: 1.2,
                                      overflow: TextOverflow.ellipsis,
                                      color: AppColor.BlackColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
            )));
  }

  Widget NewPopularListview() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width,
      child: Padding(
          // padding: EdgeInsets.only(left: 24.0, right: 24, top: 15, bottom: 15),
          // child: Container(
          //
          //   margin: EdgeInsets.symmetric(
          //       horizontal: MediaQuery.of(context).size.width * 0.1),
          //
          //   child: FlexibleGridView(
          //       physics: ClampingScrollPhysics(),
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
                children: List.generate(viewall.length, (index) {
                  // List<bool> fevorite = List.generate(
                  //   viewall.length,
                  //   (index) => false,
                  // );
                  homecontoller.wishlist.asMap().forEach(
                    (listindex, element) {
                      if (element.productid == viewall[index].id) {
                        fevorite_viewall[index] = true;
                      }
                    },
                  );
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: InkWell(
                      overlayColor: WidgetStatePropertyAll(Colors.white),
                      onTap: () {
                        WebAPPNavigation.navigateToroute(
                            context: context,
                            routename:
                                '/CategoryPage/${viewall[index].name.replaceAll(' ', '-')}',
                            data: {
                              'id': viewall[index].id,
                            },
                            screen: CategoryPage(
                              id: viewall[index].id,
                              title: viewall[index].name,
                            ));
                      },
                      child: Center(
                        child: Container(
                          height: 250,
                          width: 250,
                          // color: AppColor.BlackColor,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Flexible(
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageBuilder: (context, imageProvider) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: AppColor.whiteColor,
                                          border: Appborder.appborder,
                                          boxShadow: [Appshadow.shadow],
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      );
                                    },
                                    imageUrl: viewall[index].image,
                                    placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                      color: AppColor.BlackColor,
                                    )),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                            decoration: BoxDecoration(
                                              color: AppColor.whiteColor,
                                              border: Appborder.appborder,
                                              boxShadow: [Appshadow.shadow],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                                child: Icon(Icons.error))),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "${viewall[index].name}",
                                    maxLines: 1,
                                    style: TextStyle(
                                        height: 1.2,
                                        overflow: TextOverflow.ellipsis,
                                        color: AppColor.BlackColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                })),
          )),
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
                                        InkWell(
                                            overlayColor:
                                                WidgetStatePropertyAll(
                                                    AppColor.BgColor),
                                            onTap: () {
                                              colorPickerDialog(context,
                                                      selcted: 6,
                                                      setStates: setState)
                                                  .then(
                                                (value) {
                                                  if (colorcode !=
                                                      Color(0xFFFFFFFF)) {
                                                    colorselected = 6;
                                                  } else {
                                                    colorselected = 1;
                                                  }
                                                  setState(() {});
                                                },
                                              );
                                            },
                                            child: Stack(
                                              children: [
                                                Icon(
                                                  Icons.color_lens,
                                                  size: 30,
                                                ),
                                                colorselected != 6 ||
                                                        colorpick == false
                                                    ? SizedBox()
                                                    : Positioned(
                                                        bottom: 0,
                                                        right: 0,
                                                        child: Container(
                                                          height: 12,
                                                          width: 12,
                                                          decoration: BoxDecoration(
                                                              color: colorcode,
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey)),
                                                        ),
                                                      )
                                              ],
                                            ))
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
              child: ButtonWidget(
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
          textfield == false
              ? SizedBox()
              : Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: TextFormField(
                    controller: searchcontroller,
                    cursorColor: AppColor.fontblack,
                    onChanged: (value) {
                      // viewall = viewall
                      //     .where((e) =>
                      //         e.title.toLowerCase().contains(value) &&
                      //         e.title.toLowerCase().startsWith(value))
                      //     .toList();
                      setState(() {});
                      if (searchcontroller.text.isEmpty) {
                        viewall = viewallsearch;
                        setState(() {});
                      }
                    },
                    decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            overlayColor: WidgetStatePropertyAll(Colors.white),
                            onTap: () {
                              setState(() {
                                textfield = false;
                              });
                            },
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                  color: AppColor.redcolor,
                                  shape: BoxShape.circle),
                              child: Icon(
                                Icons.close,
                                color: AppColor.whiteColor,
                              ),
                            ),
                          ),
                        ),
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
                        hintText: "Search Product",
                        hintStyle: TextStyle(fontFamily: AppFont.lato)),
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColor.fontblack,
                        fontWeight: FontWeight.w500),
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
                      dropdownStyleData: DropdownStyleData(
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        offset: const Offset(-20, 0),
                        scrollbarTheme: ScrollbarThemeData(
                          radius: const Radius.circular(40),
                          thickness: MaterialStateProperty.all(6),
                          thumbVisibility: MaterialStateProperty.all(true),
                        ),
                      ),
                      onChanged: (value) {
                        sortingvalue = value as String;
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
                            "${value.toString()}",
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
              InkWell(
                overlayColor: WidgetStatePropertyAll(Colors.white),
                onTap: () {
                  setState(() {
                    textfield = !textfield;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 12),
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: SvgPicture.asset(
                      "assets/image/Search Icon.svg",
                      width: 23,
                      height: 23,
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
                      onTap: () {
                        setState(() {
                          // GridViewTwo = true;
                        });
                        WebAPPNavigation.navigateToroute(
                            context: context,
                            routename: '/FilterPage',
                            screen: FilterPage());
                      },
                      child: Icon(Icons.grid_view)
                      // Icon(Icons.grid_on)
                      ),
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
                          // GridViewTwo = false;
                        });
                        WebAPPNavigation.navigateToroute(
                            context: context,
                            routename: '/FilterPage',
                            screen: FilterPage());
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

  bool colorpick = false;
  Color colorcode = Color(0xffFFFFFF);

  Future<bool> colorPickerDialog(context,
      {color, selcted, Function? setStates}) async {
    return ColorPicker(
      onColorChanged: (value) {
        String colorNameAndCode = ColorTools.materialNameAndCode(value);

        colorcode = value;
        setState(() {
          colorpick = true;
        });
        setStates;
      },
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        'Select color',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subheading: Text(
        'Select color shade',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      wheelSubheading: Text(
        'Selected color and its shades',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(
      context,
      transitionBuilder: (BuildContext context, Animation<double> a1,
          Animation<double> a2, Widget widget) {
        final double curvedValue =
            Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: widget,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      constraints:
          const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
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
                        thickness: MaterialStateProperty.all(6),
                        thumbVisibility: MaterialStateProperty.all(true),
                      ),
                    ),
                    onChanged: (value) {
                      sortingvalue = value as String;

                      // customers.sort((a, b) => a.age.compareTo(b.age));
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
                          "${value.toString()}",
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
    viewallsearch = viewall;
    setState(() {});
    // viewall = viewall
    //     .where((item) =>
    //         item.price >= filterController.syncvalues.start &&
    //         item.price <= filterController.syncvalues.end)
    //     .toList();
    setState(() {});
  }

  // Future ColorFilter() async {
  //   viewallsearch = viewall;
  //   setState(() {});
  //   print("viewallsearch $viewallsearch");

  //   List<ProductModel> colorlist = [];
  //   viewall.forEach(
  //     (element) {
  //       element.productAttributes!.forEach(
  //         (elementss) {
  //           if (elementss.name == "Colors") {
  //             elementss.values!.forEach(
  //               (elementcode) {
  //                 if (Color(int.parse(elementcode)) == colorcode) {
  //                   colorlist.add(element);
  //                 } else {}
  //               },
  //             );
  //           }
  //         },
  //       );
  //     },
  //   );
  //   viewall = colorlist;
  //   setState(() {});
  // }

  Widget ApplyBotton({Function? setStates}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        setStates!(() {});
        Filterprefset().then((value) {
          setState(() {
            tooltipController.hide();
          });
        });
        // ColorFilter().then((value) {
        //   setState(() {
        //     print("Colorfilter");
        //     tooltipController.hide();
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
          setState(() {
            viewallsearch = viewall;
          });
          colorselected = 1;
          // viewall = mostIntrestedController.Reserve;
        });


        tooltipController
            .hide(); // filterController.GetFilterApply().then((value) {
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

  var data;
  Future cartitem() async {
    homecontoller.wishlist.clear();
    if (homecontoller.userid.isEmpty) {
      if (mounted) setState(() {});
      return;
    }
    final items = await UserDataApi.getWishlist();
    homecontoller.wishlist.addAll(items);
    homecontoller.wishlistid = homecontoller.userid;
    if (mounted) setState(() {});
  }

  // Wishlist persistence via Node/MongoDB (/api/me/wishlist).
  Future<void> updatetowishlist(FirebasewishlistModel wishlist) async {
    await UserDataApi.saveWishlist(wishlist.wishitems ?? []);
  }

  Future<void> removetowishlist(FirebasewishlistModel wishlist) async {
    await UserDataApi.saveWishlist(wishlist.wishitems ?? []);
  }

  Future<void> Addtowishlist(FirebasewishlistModel wishlist) async {
    await UserDataApi.saveWishlist(wishlist.wishitems ?? []);
  }
}
