// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_new, sized_box_for_whitespace, unnecessary_import, avoid_print, deprecated_member_use, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, prefer_typing_uninitialized_variables

import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/api/user_data_api.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/dailogclass.dart';
import 'package:EcommerceApp/helper/loginshow.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/productmodel.dart';
import 'package:EcommerceApp/view/product_filter_view.dart';
import 'package:EcommerceApp/view/product_grid_card.dart';
import 'package:EcommerceApp/model/userdataset.dart';
import 'package:EcommerceApp/model/wishlistmodel.dart';
import 'package:EcommerceApp/view/product_detail_page.dart';
import 'package:EcommerceApp/viewmodel/filtercontroller.dart';
import 'package:EcommerceApp/viewmodel/homecontroller.dart';
import 'package:EcommerceApp/viewmodel/mostInterestedcontoller.dart';
import 'package:EcommerceApp/viewmodel/searchcontroller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flexible_grid_view/flexible_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  SearcherController searcherController = Get.put(SearcherController());
  Homecontoller homecontoller = Get.put(Homecontoller());
  MostIntrestedController mostIntrestedController =
      Get.put(MostIntrestedController());
  FilterController filterController = Get.put(FilterController());
  bool NodataFound = false;
  bool searchicon = false;
  bool GridViewTwo = false;

  List<Wishitems> firebaseWishlsit = [];
  List<bool> firebaseWishlsitfevorite = [];
  List<Wishitems> firebasewishlistModelvaluestorelsit = [];
  bool textfield = false;
  String sortingvalue = "Sort by";
  TextEditingController searchcontroller = TextEditingController();
  List<ProductModel> AllData = [];
  List<ProductModel> FilterdAllData = [];
  Future<FirebasewishlistModel> ProductsDataGet({user}) async {
    final items = await UserDataApi.getWishlist();
    return FirebasewishlistModel(
        userid: homecontoller.userid, wishitems: items);
  }

// firebaseWishlsit
  Future<UserModel> UsercheckDataGet({userid}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(prefrenceKey.userid) ?? '';
    if (mounted) setState(() {});
    // A logged-in user always has a wishlist on the backend, so expose a
    // non-empty wishlistid to let the favourites flow load it.
    return UserModel(id: uid, email: '', wishlistid: uid);
  }

  @override
  void initState() {
    setState(() {
      searcherController.isloader = true;
    });
    searcherController.searchlist = searcherController.widgetList;
    setState(() {});

    UsercheckDataGet(userid: homecontoller.userid).then(
      (value) {
        if (value.wishlistid == '') {
          setState(() {
            searcherController.isloader = false;
          });
        } else {
          ProductsDataGet(user: value.wishlistid).then(
            (value) {
              setState(() {
                Set<String> seenProductIds = {};
                if (value.wishitems != null) {
                  firebaseWishlsit = value.wishitems!.where((item) {
                    if (seenProductIds.contains(item.productid)) {
                      return false; // Remove duplicates
                    } else {
                      if (item.productid != null) {
                        seenProductIds.add(item.productid!);
                      }
                      return true; // Keep first occurrence
                    }
                  }).toList();
                }

                value.wishitems!.forEach(
                  (element) {
                    firebaseWishlsitfevorite.add(true);
                  },
                );
                cartitem();
                ProductsDataGets().then((value) {
                  setState(() {
                    value.forEach((element) {
                      AllData = value.where((item1) {
                        return firebaseWishlsit
                            .any((item2) => item1.id == item2.productid);
                      }).toList();
                    });
                    FilterdAllData.addAll(AllData);
                  });
                });
                firebasewishlistModelvaluestorelsit = value.wishitems!;
                searcherController.isloader = false;
              });
            },
          );
        }
      },
    ).onError(
      (error, stackTrace) {
        setState(() {
          searcherController.isloader = false;
        });
      },
    );

    super.initState();
  }

  double minimum = 0.0;
  double maximum = 50000.0;

  @override
  Widget build(BuildContext context) {
    return searcherController.isloader
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
                backgroundColor: AppColor.BgColor,
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                      child: StickyHeader(
                          header: CommonWidget()
                              .StickyHeaders(context, Refresh: setState),
                          content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AllData.isEmpty
                                    ? Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        child: Center(
                                            child: Text(
                                          "No Favourites Yet",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        )))
                                    : ProductFilterView(
                                        products: AllData,
                                        cardBuilder: (p, index, filtered) =>
                                            ProductGridCard(
                                                product: p,
                                                index: index,
                                                list: filtered),
                                      ),
                                CommonWidget().Footer(context)
                              ]))),

                  //  Column(
                  //   children: [
                  //     searchfiled(),
                  //     recentlysearch(),
                  //     searchHistory(),
                  //     Searchgridview()
                  //   ],
                  // ),
                ),
              )
            : Scaffold(
                appBar: CommonWidget().Header(
                    context: context,
                    title: "Favourite",
                    exit: true,
                    heart: false,
                    leading: false),
                backgroundColor: AppColor.BgColor,
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SafeArea(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AllData.isEmpty
                                  ? Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.8,
                                      child: Center(
                                          child: Text(
                                        "No Favourites Yet",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      )))
                                  : ProductFilterView(
                                      products: AllData,
                                      cardBuilder: (p, index, filtered) =>
                                          ProductGridCard(
                                              product: p,
                                              index: index,
                                              list: filtered),
                                    ),
                            ]),
                      )),

                  //  Column(
                  //   children: [
                  //     searchfiled(),
                  //     recentlysearch(),
                  //     searchHistory(),
                  //     Searchgridview()
                  //   ],
                  // ),
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
    if (filterController.isInStock) {
      AllData = CommonWidget().InStock(AllData);
      firebaseWishlsit = firebaseWishlsit.where((item1) {
        return AllData.any((item2) => item1.productid == item2.id);
      }).toList();
    } else {
      setState(() {
        firebaseWishlsit = firebasewishlistModelvaluestorelsit;
      });
    }

    firebaseWishlsit = firebaseWishlsit
        .where((item) =>
            double.parse(item.saleprice!) >=
                filterController.syncvalues.start &&
            double.parse(item.saleprice!) <= filterController.syncvalues.end)
        .toList();

    setState(() {});
  }

  Widget ApplyBotton({Function? setStates}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        setStates!(() {});
        Filterprefset().then((value) {
          tooltipController.hide();
        });
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
        setStates!(() {
          AllData = FilterdAllData;
          filterController.syncvalues = RangeValues(0.0, 100000.0);
          sizeselected = 1;

          setState(() {
            firebaseWishlsit = firebasewishlistModelvaluestorelsit;
          });
          colorselected = 1;
        });

        tooltipController.hide();
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
                            Row(children: [
                              Checkbox(
                                value: filterController.isInStock,
                                activeColor: AppColor.BlackColor,
                                onChanged: (value) {
                                  setState(() {
                                    filterController.isInStock = value!;
                                  });
                                },
                              ),
                              Text(
                                "In Stock (${CommonWidget().InStock(AllData).length})",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: AppColor.BlackColor,
                                    fontWeight: FontWeight.w500),
                              ),
                            ]),

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
          // textfield == false
          //     ? SizedBox()
          //     : Container(
          //         height: 50,
          //         width: MediaQuery.of(context).size.width * 0.5,
          //         child: TextFormField(
          //           controller: searchcontroller,
          //           cursorColor: AppColor.fontblack,
          //           onChanged: (value) {
          //             firebaseWishlsit = firebaseWishlsit
          //                 .where((e) =>
          //                     e.productname!.toLowerCase().contains(value) &&
          //                     e.productname!.toLowerCase().startsWith(value))
          //                 .toList();
          //             setState(() {});
          //             if (searchcontroller.text.isEmpty) {
          //               firebaseWishlsit = firebasewishlistModelvaluestorelsit;
          //               setState(() {});
          //             }
          //           },
          //           decoration: InputDecoration(
          //               suffixIcon: Padding(
          //                 padding: const EdgeInsets.all(8.0),
          //                 child: InkWell(
          //                   overlayColor: WidgetStatePropertyAll(Colors.white),
          //                   onTap: () {
          //                     setState(() {
          //                       textfield = false;
          //                     });
          //                   },
          //                   child: Container(
          //                     height: 25,
          //                     width: 25,
          //                     decoration: BoxDecoration(
          //                         color: AppColor.redcolor,
          //                         shape: BoxShape.circle),
          //                     child: Icon(
          //                       Icons.close,
          //                       color: AppColor.whiteColor,
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //               isDense: true,
          //               contentPadding:
          //                   EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          //               focusedBorder: OutlineInputBorder(
          //                 borderSide: BorderSide.none,
          //                 borderRadius: BorderRadius.circular(10),
          //               ),
          //               enabledBorder: OutlineInputBorder(
          //                 borderSide: BorderSide.none,
          //                 borderRadius: BorderRadius.circular(10),
          //               ),
          //               disabledBorder: OutlineInputBorder(
          //                 borderSide: BorderSide.none,
          //                 borderRadius: BorderRadius.circular(10),
          //               ),
          //               errorBorder: OutlineInputBorder(
          //                 borderSide: BorderSide.none,
          //                 borderRadius: BorderRadius.circular(10),
          //               ),
          //               focusedErrorBorder: OutlineInputBorder(
          //                 borderSide: BorderSide.none,
          //                 borderRadius: BorderRadius.circular(10),
          //               ),
          //               filled: true,
          //               fillColor: AppColor.imagebg,
          //               border: InputBorder.none,
          //               hintText: "Search Product",
          //               hintStyle: TextStyle(fontFamily: AppFont.lato)),
          //           style: TextStyle(
          //               fontSize: 14,
          //               color: AppColor.fontblack,
          //               fontWeight: FontWeight.w500),
          //         ),
          //       ),

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
                          thickness: MaterialStateProperty.all(6),
                          thumbVisibility: MaterialStateProperty.all(true),
                        ),
                      ),
                      onChanged: (value) {
                        sortingvalue = value as String;

                        if (sortingvalue == 'Price: High  to Low') {
                          firebaseWishlsit.sort((a, b) =>
                              double.parse(a.saleprice.toString()).compareTo(
                                  double.parse(b.saleprice.toString())));
                          firebaseWishlsit = firebaseWishlsit.reversed.toList();
                          setState(() {});
                        } else if (sortingvalue == 'Price: Low  to High') {
                          firebaseWishlsit.sort((a, b) =>
                              double.parse(a.saleprice.toString()).compareTo(
                                  double.parse(b.saleprice.toString())));
                          firebaseWishlsit = firebaseWishlsit.toList();
                          setState(() {});
                        } else if (sortingvalue == "A - Z") {
                          firebaseWishlsit.sort((a, b) =>
                              a.productname!.compareTo(b.productname!));
                          firebaseWishlsit = firebaseWishlsit.toList();
                          setState(() {});
                          // "Z - A",
                        } else if (sortingvalue == "Z - A") {
                          firebaseWishlsit.sort((a, b) =>
                              a.productname!.compareTo(b.productname!));
                          firebaseWishlsit = firebaseWishlsit.reversed.toList();
                          setState(() {});
                        }

                        // customers.sort((a, b) => a.age.compareTo(b.age));
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
                            Row(children: [
                              Checkbox(
                                value: filterController.isInStock,
                                activeColor: AppColor.BlackColor,
                                onChanged: (value) {
                                  setState(() {
                                    filterController.isInStock = value!;
                                  });
                                },
                              ),
                              Text(
                                "In Stock (${CommonWidget().InStock(AllData).length})",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: AppColor.BlackColor,
                                    fontWeight: FontWeight.w500),
                              ),
                            ]),
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
              // width: 130,
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

                      if (sortingvalue == 'Price: High  to Low') {
                        firebaseWishlsit.sort((a, b) =>
                            double.parse(a.saleprice!)
                                .compareTo(double.parse(b.saleprice!)));
                        firebaseWishlsit = firebaseWishlsit.reversed.toList();
                        setState(() {});
                      } else if (sortingvalue == 'Price: Low  to High') {
                        firebaseWishlsit.sort((a, b) =>
                            double.parse(a.saleprice!)
                                .compareTo(double.parse(b.saleprice!)));
                        firebaseWishlsit = firebaseWishlsit.toList();
                        setState(() {});
                      } else if (sortingvalue == "A - Z") {
                        firebaseWishlsit.sort(
                            (a, b) => a.productname!.compareTo(b.productname!));
                        firebaseWishlsit = firebaseWishlsit.toList();
                        setState(() {});
                        // "Z - A",
                      } else if (sortingvalue == "Z - A") {
                        firebaseWishlsit.sort(
                            (a, b) => a.productname!.compareTo(b.productname!));
                        firebaseWishlsit = firebaseWishlsit.reversed.toList();
                        setState(() {});
                      }

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
              children: List.generate(firebaseWishlsit.length, (index) {
                // List<bool> fevorite = List.generate(
                //   firebaseWishlsit.length,
                //   (index) => false,
                // );
                homecontoller.wishlist.asMap().forEach(
                  (listindex, element) {
                    if (element.productid ==
                        firebaseWishlsit[index].productid) {
                      firebaseWishlsitfevorite[index] = true;
                    }
                  },
                );
                return InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  onTap: () {
                    ProductsDataGets().then(
                      (value) {
                        // AllData = value;
                        value.asMap().forEach(
                          (indexs, element) {
                            if (element.id ==
                                firebaseWishlsit[index].productid) {
                              print(
                                  'element :: ${firebaseWishlsit[index].productid}');
                              WebAPPNavigation.navigateToroute(
                                  context: context,
                                  routename:
                                      '/ProductDetailScreen/${value[indexs].id}',
                                  data: {
                                    'index': index,
                                    'productModelList': value,
                                    'productModel': value[indexs],
                                    'productName': value[indexs].title
                                  },
                                  screen: ProductDetailScreen(
                                    index: index,
                                    productModelList: value,
                                    productModel: value[indexs],
                                    title: value[indexs].title,
                                  ));
                            }
                          },
                        );
                      },
                    );
                    // Beamer.of(context)
                    //     .beamToNamed('/ProductDetailScreen', data: {
                    //   data: {
                    //     'productModel': firebaseWishlsit[index],
                    //     'index': index,
                    //     'productModelList': []
                    //   }
                    // });
                  },
                  child: Center(
                    child: Container(
                      height: Responsive.isMobile(context) ? 260 : 430,
                      width: Responsive.isMobile(context) ? 211 : 300,
                      decoration: BoxDecoration(
                          color: AppColor.whiteColor,
                          border: Appborder.appborder,
                          boxShadow: [Appshadow.shadow],
                          borderRadius: BorderRadius.circular(15)),
                      clipBehavior: Clip.antiAlias,
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
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover)),
                                      );
                                    },
                                    imageUrl: firebaseWishlsit[index].image!,
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
                                      onTap: () {
                                        int removeindex = 0;
                                        if (firebaseWishlsitfevorite[index] ==
                                            true) {
                                          homecontoller.wishlist.removeWhere(
                                              (element) =>
                                                  element.productid ==
                                                  firebaseWishlsit[index]
                                                      .productid);
                                          removetowishlist(
                                                  FirebasewishlistModel(
                                                      userid:
                                                          homecontoller.userid,
                                                      wishlistid: homecontoller
                                                          .wishlistid,
                                                      wishitems: homecontoller
                                                          .wishlist))
                                              .then(
                                            (value) {
                                              cartitem();
                                              firebaseWishlsitfevorite[index] =
                                                  false;
                                            },
                                          );
                                        } else {
                                          print(
                                              'SPcheck ${homecontoller.wishlistid}');
                                          if (homecontoller.wishlistid == '' ||
                                              homecontoller
                                                  .wishlistid.isEmpty) {
                                            Addtowishlist(FirebasewishlistModel(
                                                userid: homecontoller.userid,
                                                wishitems: [
                                                  Wishitems(
                                                    brandname:
                                                        firebaseWishlsit[index]
                                                            .brandname,
                                                    image:
                                                        firebaseWishlsit[index]
                                                            .image,
                                                    price:
                                                        firebaseWishlsit[index]
                                                            .price
                                                            .toString(),
                                                    saleprice: (int.parse(
                                                                firebaseWishlsit[
                                                                        index]
                                                                    .price!) -
                                                            (int.parse(firebaseWishlsit[
                                                                        index]
                                                                    .price!) *
                                                                (int.parse(firebaseWishlsit[
                                                                            index]
                                                                        .saleprice!) *
                                                                    0.01)))
                                                        .toString(),
                                                    productid:
                                                        firebaseWishlsit[index]
                                                            .productid,
                                                    productname:
                                                        firebaseWishlsit[index]
                                                            .productname,
                                                  )
                                                ])).then(
                                              (value) {
                                                cartitem();
                                              },
                                            );
                                          } else {
                                            homecontoller.wishlist
                                                .add(Wishitems(
                                              brandname: firebaseWishlsit[index]
                                                  .brandname,
                                              image:
                                                  firebaseWishlsit[index].image,
                                              price: firebaseWishlsit[index]
                                                  .price
                                                  .toString(),
                                              saleprice: (int.parse(
                                                          firebaseWishlsit[
                                                                  index]
                                                              .price!) -
                                                      (int.parse(
                                                              firebaseWishlsit[
                                                                      index]
                                                                  .price!) *
                                                          (int.parse(firebaseWishlsit[
                                                                      index]
                                                                  .saleprice!) *
                                                              0.01)))
                                                  .toString(),
                                              productid: firebaseWishlsit[index]
                                                  .productid,
                                              productname:
                                                  firebaseWishlsit[index]
                                                      .productname,
                                            ));
                                            setState(() {});
                                            updatetowishlist(
                                                    FirebasewishlistModel(
                                                        userid: homecontoller
                                                            .userid,
                                                        wishlistid:
                                                            homecontoller
                                                                .wishlistid,
                                                        wishitems: homecontoller
                                                            .wishlist))
                                                .then(
                                              (value) {
                                                cartitem();
                                              },
                                            );
                                          }
                                        }
                                      },
                                      child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: firebaseWishlsitfevorite[index]
                                              ? Icon(
                                                  Icons.favorite,
                                                  size: 30,
                                                  color: Colors.white,
                                                  shadows: const [Shadow(color: Color(0x73000000), blurRadius: 6)],
                                                )
                                              : Icon(
                                                  Icons.favorite_border,
                                                  size: 30,
                                                  color: Colors.white,
                                                  shadows: const [Shadow(color: Color(0x73000000), blurRadius: 6)],
                                                )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        fit: FlexFit.tight,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              firebaseWishlsit[index]
                                                  .productname!,
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
                                              firebaseWishlsit[index]
                                                  .brandname!,
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
                                          double.parse(firebaseWishlsit[index]
                                                              .saleprice ??
                                                          "0") ==
                                                      0 ||
                                                  double.parse(firebaseWishlsit[
                                                                  index]
                                                              .saleprice ??
                                                          "0") ==
                                                      double.parse(
                                                          firebaseWishlsit[
                                                                      index]
                                                                  .price ??
                                                              "0")
                                              ? SizedBox()
                                              : Container(
                                                  child: Text(
                                                    "₹ ${firebaseWishlsit[index].price ?? 00}.00",
                                                    style: TextStyle(
                                                        color: AppColor
                                                            .viewallcolor,
                                                        fontSize: 16,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                          Container(
                                            child: Text(
                                              "₹ ${double.parse(firebaseWishlsit[index].saleprice!.toString()).toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  color: AppColor.BlackColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Container(
                                      //   margin: EdgeInsets.only(top: 10),
                                      //   child: Text(
                                      //     "₹ ${firebaseWishlsit[index].price}.00",
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
                );
              })),
        ));
  }

  List<ProductModel> defultdata = [];
  Future<List<ProductModel>> ProductsDataGets() async {
    try {
      final list = await ApiClient.instance.getList('/products');
      return list.map((map) => ProductModel.fromJson(map)).toList();
    } catch (e) {
      return [];
    }
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

  Widget NewPopularListviewForTwo() {
    return Padding(
        padding: EdgeInsets.only(left: 24.0, right: 24, top: 15, bottom: 15),
        child: FlexibleGridView(
            physics: ClampingScrollPhysics(),
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
              firebaseWishlsit.length,
              (index) {
                // List<bool> fevorite = List.generate(
                //   firebaseWishlsit.length,
                //   (index) => false,
                // );
                homecontoller.wishlist.asMap().forEach(
                  (listindex, element) {
                    if (element.productid ==
                        firebaseWishlsit[index].productid) {
                      firebaseWishlsitfevorite[index] = true;
                    }
                  },
                );
                return InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  onTap: () {},
                  child: Container(
                    height: Responsive.isMobile(context) ? 260 : 430,
                    width: Responsive.isMobile(context)
                        ? 211
                        : GridViewTwo
                            ? MediaQuery.of(context).size.width * 0.5
                            : 300,
                    decoration: BoxDecoration(
                        color: AppColor.whiteColor,
                        border: Appborder.appborder,
                        boxShadow: [Appshadow.shadow],
                        borderRadius: BorderRadius.circular(15)),
                    clipBehavior: Clip.antiAlias,
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
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover)),
                                    );
                                  },
                                  imageUrl: firebaseWishlsit[index].image!,
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
                                    onTap: () {
                                      int removeindex = 0;
                                      if (firebaseWishlsitfevorite[index] ==
                                          true) {
                                        homecontoller.wishlist.removeWhere(
                                            (element) =>
                                                element.productid ==
                                                firebaseWishlsit[index]
                                                    .productid);
                                        removetowishlist(FirebasewishlistModel(
                                                userid: homecontoller.userid,
                                                wishlistid:
                                                    homecontoller.wishlistid,
                                                wishitems:
                                                    homecontoller.wishlist))
                                            .then(
                                          (value) {
                                            cartitem();
                                            firebaseWishlsitfevorite[index] =
                                                false;
                                          },
                                        );
                                      } else {
                                        print(
                                            'SPcheck ${homecontoller.wishlistid}');
                                        if (homecontoller.userid.isEmpty) {
                                          LoginDialog.showLoginDialog(context,
                                              () {
                                            if (homecontoller.wishlistid ==
                                                    '' ||
                                                homecontoller
                                                    .wishlistid.isEmpty) {
                                              Addtowishlist(
                                                  FirebasewishlistModel(
                                                      userid:
                                                          homecontoller.userid,
                                                      wishitems: [
                                                    Wishitems(
                                                      brandname:
                                                          firebaseWishlsit[
                                                                  index]
                                                              .brandname,
                                                      image: firebaseWishlsit[
                                                              index]
                                                          .image,
                                                      price: firebaseWishlsit[
                                                              index]
                                                          .price
                                                          .toString(),
                                                      saleprice: (int.parse(
                                                                  firebaseWishlsit[
                                                                          index]
                                                                      .price!) -
                                                              (int.parse(firebaseWishlsit[
                                                                          index]
                                                                      .price!) *
                                                                  (int.parse(firebaseWishlsit[
                                                                              index]
                                                                          .saleprice!) *
                                                                      0.01)))
                                                          .toString(),
                                                      productid:
                                                          firebaseWishlsit[
                                                                  index]
                                                              .productid,
                                                      productname:
                                                          firebaseWishlsit[
                                                                  index]
                                                              .productname,
                                                    )
                                                  ])).then(
                                                (value) {
                                                  cartitem();
                                                },
                                              );
                                            } else {
                                              homecontoller.wishlist
                                                  .add(Wishitems(
                                                brandname:
                                                    firebaseWishlsit[index]
                                                        .brandname,
                                                image: firebaseWishlsit[index]
                                                    .image,
                                                price: firebaseWishlsit[index]
                                                    .price
                                                    .toString(),
                                                saleprice: (int.parse(
                                                            firebaseWishlsit[
                                                                    index]
                                                                .price!) -
                                                        (int.parse(
                                                                firebaseWishlsit[
                                                                        index]
                                                                    .price!) *
                                                            (int.parse(firebaseWishlsit[
                                                                        index]
                                                                    .saleprice!) *
                                                                0.01)))
                                                    .toString(),
                                                productid:
                                                    firebaseWishlsit[index]
                                                        .productid,
                                                productname:
                                                    firebaseWishlsit[index]
                                                        .productname,
                                              ));
                                              setState(() {});
                                              updatetowishlist(
                                                      FirebasewishlistModel(
                                                          userid: homecontoller
                                                              .userid,
                                                          wishlistid:
                                                              homecontoller
                                                                  .wishlistid,
                                                          wishitems:
                                                              homecontoller
                                                                  .wishlist))
                                                  .then(
                                                (value) {
                                                  cartitem();
                                                },
                                              );
                                            }
                                            setState(() {});
                                          });
                                        } else {
                                          if (homecontoller.wishlistid == '' ||
                                              homecontoller
                                                  .wishlistid.isEmpty) {
                                            Addtowishlist(FirebasewishlistModel(
                                                userid: homecontoller.userid,
                                                wishitems: [
                                                  Wishitems(
                                                    brandname:
                                                        firebaseWishlsit[index]
                                                            .brandname,
                                                    image:
                                                        firebaseWishlsit[index]
                                                            .image,
                                                    price:
                                                        firebaseWishlsit[index]
                                                            .price
                                                            .toString(),
                                                    saleprice: (int.parse(
                                                                firebaseWishlsit[
                                                                        index]
                                                                    .price!) -
                                                            (int.parse(firebaseWishlsit[
                                                                        index]
                                                                    .price!) *
                                                                (int.parse(firebaseWishlsit[
                                                                            index]
                                                                        .saleprice!) *
                                                                    0.01)))
                                                        .toString(),
                                                    productid:
                                                        firebaseWishlsit[index]
                                                            .productid,
                                                    productname:
                                                        firebaseWishlsit[index]
                                                            .productname,
                                                  )
                                                ])).then(
                                              (value) {
                                                cartitem();
                                              },
                                            );
                                          } else {
                                            homecontoller.wishlist
                                                .add(Wishitems(
                                              brandname: firebaseWishlsit[index]
                                                  .brandname,
                                              image:
                                                  firebaseWishlsit[index].image,
                                              price: firebaseWishlsit[index]
                                                  .price
                                                  .toString(),
                                              saleprice: (int.parse(
                                                          firebaseWishlsit[
                                                                  index]
                                                              .price!) -
                                                      (int.parse(
                                                              firebaseWishlsit[
                                                                      index]
                                                                  .price!) *
                                                          (int.parse(firebaseWishlsit[
                                                                      index]
                                                                  .saleprice!) *
                                                              0.01)))
                                                  .toString(),
                                              productid: firebaseWishlsit[index]
                                                  .productid,
                                              productname:
                                                  firebaseWishlsit[index]
                                                      .productname,
                                            ));
                                            setState(() {});
                                            updatetowishlist(
                                                    FirebasewishlistModel(
                                                        userid: homecontoller
                                                            .userid,
                                                        wishlistid:
                                                            homecontoller
                                                                .wishlistid,
                                                        wishitems: homecontoller
                                                            .wishlist))
                                                .then(
                                              (value) {
                                                cartitem();
                                              },
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: firebaseWishlsitfevorite[index]
                                            ? Icon(
                                                Icons.favorite,
                                                size: 30,
                                                color: Colors.white,
                                                shadows: const [Shadow(color: Color(0x73000000), blurRadius: 6)],
                                              )
                                            : Icon(
                                                Icons.favorite_border,
                                                size: 30,
                                                color: Colors.white,
                                                shadows: const [Shadow(color: Color(0x73000000), blurRadius: 6)],
                                              )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 12),
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
                                            firebaseWishlsit[index]
                                                .productname!,
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
                                            firebaseWishlsit[index].brandname!,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        double.parse(firebaseWishlsit[index]
                                                        .saleprice ??
                                                    "0") ==
                                                0
                                            ? SizedBox()
                                            : Container(
                                                child: Text(
                                                  "₹ ${firebaseWishlsit[index].price}.00",
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
                                            "₹ ${double.parse(firebaseWishlsit[index].saleprice.toString()).toStringAsFixed(2)}",
                                            // "₹ ${(int.parse(firebaseWishlsit[index].price!) - (int.parse(firebaseWishlsit[index].price!) * (int.parse(firebaseWishlsit[index].saleprice!) * 0.01))).toStringAsFixed(2)}",
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
                                    //     "₹ ${firebaseWishlsit[index].price}.00",
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
                                              0.5
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
                );
              },
            )));
  }

  var data;
  Future cartitem() async {
    setState(() {});
    homecontoller.wishlist.clear();
    try {
      final items = await UserDataApi.getWishlist();
      homecontoller.wishlist.addAll(items);
      homecontoller.wishlistid =
          homecontoller.userid.isEmpty ? '' : homecontoller.userid;
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() {});
    }
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
