// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_interpolation_to_compose_strings, unnecessary_import, sized_box_for_whitespace, unnecessary_new, unnecessary_string_interpolations, non_constant_identifier_names, dead_code

import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/api/user_data_api.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/dailogclass.dart';
import 'package:EcommerceApp/helper/loginshow.dart';
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/productmodel.dart';
import 'package:EcommerceApp/view/product_filter_view.dart';
import 'package:EcommerceApp/view/product_grid_card.dart';
import 'package:EcommerceApp/model/wishlistmodel.dart';
import 'package:EcommerceApp/view/product_detail_page.dart';
import 'package:EcommerceApp/viewmodel/filtercontroller.dart';
import 'package:EcommerceApp/viewmodel/homecontroller.dart';
import 'package:EcommerceApp/viewmodel/mostInterestedcontoller.dart';
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
import 'package:EcommerceApp/view/filterpage.dart';
import 'package:EcommerceApp/viewmodel/searchcontroller.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
  });
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  SearcherController searcherController = Get.put(SearcherController());
  Homecontoller homecontoller = Get.put(Homecontoller());
  MostIntrestedController mostIntrestedController =
      Get.put(MostIntrestedController());
  FilterController filterController = Get.put(FilterController());
  bool NodataFound = false;
  bool searchicon = false;
  bool GridViewTwo = false;
  List<ProductModel> productList = [];
  List<bool> fevorite_productList = [];
  List<ProductModel> viewallsearch = [];
  bool textfield = false;
  String sortingvalue = "Sort by";
  TextEditingController searchcontroller = TextEditingController();

  Future<List<ProductModel>> ProductsDataGet() async {
    try {
      final list = await ApiClient.instance
          .getList('/products', query: {'sort': 'newest'});
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  void initState() {
    setState(() {
      searcherController.isloader = true;
      filterController.isInStock = false;
    });
    searcherController.searchlist = searcherController.widgetList;
    setState(() {});
    ProductsDataGet().then(
      (value) {
        setState(() {
          productList = value;
          viewallsearch = value;
          for (var element in value) {
              fevorite_productList.add(false);
            }
          searcherController.isloader = false;
        });
      },
    );

    super.initState();
  }

  double minimum = 0.0;
  double maximum = 50000.0;

  String _query = '';
  List<ProductModel> get _searched {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return productList;
    return productList
        .where((p) =>
            p.title.toLowerCase().contains(q) ||
            (p.brand?.name ?? '').toString().toLowerCase().contains(q))
        .toList();
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: TextField(
        controller: searchcontroller,
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Search products by name or brand...',
          prefixIcon: Icon(Icons.search, color: AppColor.primary),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: AppColor.fontColorgrey),
                  onPressed: () {
                    searchcontroller.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColor.blush.withValues(alpha: 0.4),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColor.blushDeep),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColor.primary, width: 1.4),
          ),
        ),
      ),
    );
  }

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
                                color: AppColor.BgColor,
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
                body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: AppColor.BgColor,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColor.BgColor,
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
                                _searchBox(),
                                productList.isEmpty
                                    ? Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        child: Center(
                                            child: Text(
                                          "No Data Found",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        )))
                                    : ProductFilterView(
                                        products: _searched,
                                        cardBuilder: (p, index, filtered) =>
                                            ProductGridCard(
                                                product: p,
                                                index: index,
                                                list: filtered),
                                      ),
                                CommonWidget().Footer(context)
                              ]))),
                ),
              )
            : Scaffold(
                appBar:
                    MediaQuery.of(context).size.width > CommonWidget.headerWidth
                        ? null
                        : CommonWidget().NewHeader(context: context),
                endDrawer:
                    MediaQuery.of(context).size.width > CommonWidget.headerWidth
                        ? null
                        : CommonWidget()
                            .Drowers(context, userid: homecontoller.userid),
                backgroundColor: AppColor.BgColor,
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        _searchBox(),
                        productList.isEmpty
                            ? Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                child: Center(
                                    child: Text(
                                  "No Data Found",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                )))
                            : ProductFilterView(
                                products: _searched,
                                cardBuilder: (p, index, filtered) =>
                                    ProductGridCard(
                                        product: p,
                                        index: index,
                                        list: filtered),
                              ),
                      ])),
                ),
              );

    // return searcherController.isloader
    //     ? MediaQuery.of(context).size.width > 800
    //         ? Scaffold(
    //             body: Container(
    //               height: MediaQuery.of(context).size.height,
    //               width: MediaQuery.of(context).size.width,
    //               color: AppColor.BgColor,
    //               child: SingleChildScrollView(
    //                 child: StickyHeader(
    //                   header: CommonWidget().StickyHeaders(context),
    //                   content: Column(
    //                     children: [
    //                       Container(
    //                         height: MediaQuery.of(context).size.height * 0.8,
    //                         width: MediaQuery.of(context).size.width,
    //                         child: Center(
    //                           child: CircularProgressIndicator(
    //                             color: Colors.black,
    //                           ),
    //                         ),
    //                       ),
    //                       CommonWidget().Footer(context)
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           )
    //         : Scaffold(
    //             // appBar: AppBar(),
    //             body: Container(
    //             height: MediaQuery.of(context).size.height,
    //             width: MediaQuery.of(context).size.width,
    //             color: AppColor.BgColor,
    //             child: Center(
    //               child: CircularProgressIndicator(
    //                 color: Colors.black,
    //               ),
    //             ),
    //           ))
    //     : Scaffold(
    //         backgroundColor: AppColor.BgColor,
    //         body: Container(
    //           height: MediaQuery.of(context).size.height,
    //           width: MediaQuery.of(context).size.width,
    //           child: SingleChildScrollView(
    //               child: StickyHeader(
    //                   header: CommonWidget().StickyHeaders(context),
    //                   content: Column(
    //                       mainAxisSize: MainAxisSize.min,
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         FilterView(),
    //                         productList.isEmpty
    //                             ? Container(
    //                                 height: MediaQuery.of(context).size.height *
    //                                     0.8,
    //                                 child: Center(
    //                                     child: Text(
    //                                   "No Data Found",
    //                                   style: TextStyle(
    //                                       fontSize: 18,
    //                                       fontWeight: FontWeight.w600),
    //                                 )))
    //                             : GridViewTwo == false
    //                                 ? NewPopularListview()
    //                                 : NewPopularListviewForTwo(),
    //                         CommonWidget().Footer(context)
    //                       ]))),

    //           //  Column(
    //           //   children: [
    //           //     searchfiled(),
    //           //     recentlysearch(),
    //           //     searchHistory(),
    //           //     Searchgridview()
    //           //   ],
    //           // ),
    //         ),
    //       );
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
    // viewallsearch = productList;
    setState(() {});
    if (filterController.isInStock) {
      productList = await CommonWidget().InStock(productList);
    } else {
      setState(() {
        productList = viewallsearch;
      });
    }

    productList = productList
        .where((item) =>
            double.parse((item.price - (item.price * (item.salePrice * 0.01)))
                    .toString()) >=
                filterController.syncvalues.start &&
            double.parse((item.price - (item.price * (item.salePrice * 0.01)))
                    .toString()) <=
                filterController.syncvalues.end)
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
          filterController.syncvalues = RangeValues(0.0, 100000.0);
          sizeselected = 1;

          colorselected = 1;
          productList = viewallsearch;
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
                        width: MediaQuery.of(context).size.width < 480
                            ? MediaQuery.of(context).size.width * 0.92
                            : 400,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: AppColor.dividercolor,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x22000000),
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
                              height: 24,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Center(
                                child: Text(
                                  'Filter & Sort',
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
                                "In Stock (${CommonWidget().InStock(productList).length})",
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
          //                   // Colorfilter()
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

          // textfield == false
          //     ? SizedBox()
          //     :
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.5,
            child: TextFormField(
              controller: searchcontroller,
              cursorColor: AppColor.fontblack,
              onChanged: (value) {
                String searchValue = value.toLowerCase();

                if (searchValue.isEmpty) {
                  productList =
                      viewallsearch; // Reset to full list if search is empty
                } else {
                  productList = viewallsearch
                      .where((e) =>
                          e.title.toLowerCase().contains(searchValue) ||
                          (e.brand?.name ?? '')
                              .toLowerCase()
                              .contains(searchValue) ||
                          (e.subCategoryName ?? '')
                              .toLowerCase()
                              .contains(searchValue) ||
                          (e.sku ?? '').toLowerCase().contains(searchValue))
                      .toList();
                }

                setState(() {});
                // productList = productList
                //     .where((e) =>
                //         e.title.toLowerCase().contains(value) &&
                //         e.title.toLowerCase().startsWith(value))
                //     .toList();
                // setState(() {});
                // if (searchcontroller.text.isEmpty) {
                //   productList = viewallsearch;
                //   setState(() {});
                // }
              },
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

                        if (sortingvalue == 'Price: High  to Low') {
                          // productList
                          //     .sort((a, b) => a.price.compareTo(b.price));
                          productList.sort((a, b) => double.parse(
                                  (a.price - (a.price * (a.salePrice * 0.01)))
                                      .toString())
                              .compareTo(double.parse(
                                  (b.price - (b.price * (b.salePrice * 0.01)))
                                      .toString())));
                          productList = productList.reversed.toList();
                          setState(() {});
                        } else if (sortingvalue == 'Price: Low  to High') {
                          // productList
                          //     .sort((a, b) => a.price.compareTo(b.price));
                          productList.sort((a, b) => double.parse(
                                  (a.price - (a.price * (a.salePrice * 0.01)))
                                      .toString())
                              .compareTo(double.parse(
                                  (b.price - (b.price * (b.salePrice * 0.01)))
                                      .toString())));
                          productList = productList.toList();
                          setState(() {});
                        } else if (sortingvalue == "A - Z") {
                          productList
                              .sort((a, b) => a.title.compareTo(b.title));
                          productList = productList.toList();
                          setState(() {});
                          // "Z - A",
                        } else if (sortingvalue == "Z - A") {
                          productList
                              .sort((a, b) => a.title.compareTo(b.title));
                          productList = productList.reversed.toList();
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
              // InkWell(
              //   overlayColor: WidgetStatePropertyAll(Colors.white),
              //   onTap: () {
              //     setState(() {
              //       textfield = !textfield;
              //     });
              //   },
              //   child: Container(
              //     margin: EdgeInsets.only(right: 12),
              //     child: Padding(
              //       padding: EdgeInsets.only(right: 8.0),
              //       child: SvgPicture.asset(
              //         "assets/image/Search Icon.svg",
              //         width: 23,
              //         height: 23,
              //       ),
              //     ),
              //   ),
              // ),
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
                        width: MediaQuery.of(context).size.width < 480
                            ? MediaQuery.of(context).size.width * 0.92
                            : 400,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: AppColor.dividercolor,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x22000000),
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
                              height: 24,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Center(
                                child: Text(
                                  'Filter & Sort',
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
                                "In Stock (${CommonWidget().InStock(productList).length})",
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
                        thickness: WidgetStateProperty.all(6),
                        thumbVisibility: WidgetStateProperty.all(true),
                      ),
                    ),
                    onChanged: (value) {
                      sortingvalue = value as String;
                      if (sortingvalue == 'Price: High  to Low') {
                        productList.sort((a, b) => int.parse(a.price.toString())
                            .compareTo(int.parse(b.price.toString())));
                        productList = productList.reversed.toList();
                        setState(() {});
                      } else if (sortingvalue == 'Price: Low  to High') {
                        productList.sort((a, b) => int.parse(a.price.toString())
                            .compareTo(int.parse(b.price.toString())));
                        productList = productList.toList();
                        setState(() {});
                      } else if (sortingvalue == "A - Z") {
                        productList.sort((a, b) => a.title.compareTo(b.title));
                        productList = productList.toList();
                        setState(() {});
                        // "Z - A",
                      } else if (sortingvalue == "Z - A") {
                        productList.sort((a, b) => a.title.compareTo(b.title));
                        productList = productList.reversed.toList();
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
              children: List.generate(productList.length, (index) {
                homecontoller.wishlist.asMap().forEach(
                  (listindex, element) {
                    if (element.productid == productList[index].id) {
                      fevorite_productList[index] = true;
                    }
                  },
                );
                return InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  onTap: () {
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        data: {
                          'productModel': productList[index],
                          'index': index,
                          'productModelList': productList,
                          'productName': productList[index].title
                        },
                        routename:
                            '/ProductDetailScreen/${productList[index].id}',
                        screen: ProductDetailScreen(
                          index: index,
                          productModel: productList[index],
                          productModelList: productList,
                          title: productList[index].title,
                        ));
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
                                    imageUrl: productList[index].thumbnail,
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
                                        if (fevorite_productList[index] ==
                                            true) {
                                          homecontoller.wishlist.removeWhere(
                                              (element) =>
                                                  element.productid ==
                                                  productList[index].id);
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
                                              fevorite_productList[index] =
                                                  false;
                                              cartitem();
                                            },
                                          );
                                        } else {
                                          print(
                                              'SPcheck ${homecontoller.wishlistid}');
                                          if (homecontoller.userid.isEmpty) {
                                          } else {
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
                                                          productList[index]
                                                              .brand!
                                                              .name,
                                                      image: productList[index]
                                                          .thumbnail,
                                                      price: productList[index]
                                                          .price
                                                          .toString(),
                                                      // saleprice:
                                                      //     productList[index]
                                                      //         .salePrice
                                                      //         .toString(),
                                                      saleprice: (productList[
                                                                      index]
                                                                  .price -
                                                              (productList[
                                                                          index]
                                                                      .price *
                                                                  (productList[
                                                                              index]
                                                                          .salePrice *
                                                                      0.01)))
                                                          .toString(),
                                                      productid:
                                                          productList[index].id,
                                                      productname:
                                                          productList[index]
                                                              .title,
                                                    )
                                                  ])).then(
                                                (value) {
                                                  cartitem();
                                                },
                                              );
                                            } else {
                                              homecontoller.wishlist
                                                  .add(Wishitems(
                                                brandname: productList[index]
                                                    .brand!
                                                    .name,
                                                image: productList[index]
                                                    .thumbnail,
                                                price: productList[index]
                                                    .price
                                                    .toString(),
                                                // saleprice: productList[index]
                                                //     .salePrice
                                                //     .toString(),
                                                saleprice: (productList[index]
                                                            .price -
                                                        (productList[index]
                                                                .price *
                                                            (productList[index]
                                                                    .salePrice *
                                                                0.01)))
                                                    .toString(),
                                                productid:
                                                    productList[index].id,
                                                productname:
                                                    productList[index].title,
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
                                          }
                                        }
                                      },
                                      child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: fevorite_productList[index]
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
                                              productList[index].title,
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
                                              productList[index].brand == null
                                                  ? "Brand"
                                                  : productList[index]
                                                      .brand!
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
                                          productList[index].salePrice == 0
                                              ? Container()
                                              : Container(
                                                  child: Text(
                                                    "₹ ${productList[index].price}.00",
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
                                              // "₹ ${Viwerlist[index].salePrice}.00",
                                              "₹ ${(productList[index].price - (productList[index].price * (productList[index].salePrice * 0.01))).toStringAsFixed(0)}",
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
                                      //     "₹ ${productList[index].price}.00",
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
            children: List.generate(productList.length, (index) {
              homecontoller.wishlist.asMap().forEach(
                (listindex, element) {
                  if (element.productid == productList[index].id) {
                    fevorite_productList[index] = true;
                  }
                },
              );
              return InkWell(
                overlayColor: WidgetStatePropertyAll(Colors.white),
                onTap: () {
                  WebAPPNavigation.navigateToroute(
                      context: context,
                      routename:
                          '/ProductDetailScreen/${productList[index].id}',
                      data: {
                        'productModel': productList[index],
                        'index': index,
                        'productModelList': productList,
                        'productName': productList[index].title
                      },
                      screen: ProductDetailScreen(
                        index: index,
                        productModel: productList[index],
                        productModelList: productList,
                        title: productList[index].title,
                      ));
                },
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
                                imageUrl: productList[index].thumbnail,
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
                                    if (fevorite_productList[index] == true) {
                                      homecontoller.wishlist.removeWhere(
                                          (element) =>
                                              element.productid ==
                                              productList[index].id);
                                      removetowishlist(FirebasewishlistModel(
                                              userid: homecontoller.userid,
                                              wishlistid:
                                                  homecontoller.wishlistid,
                                              wishitems:
                                                  homecontoller.wishlist))
                                          .then(
                                        (value) {
                                          fevorite_productList[index] = false;
                                          cartitem();
                                        },
                                      );
                                    } else {
                                      print(
                                          'SPcheck ${homecontoller.wishlistid}');
                                      if (homecontoller.userid.isEmpty) {
                                        LoginDialog.showLoginDialog(context,
                                            () {
                                          if (homecontoller.wishlistid == '' ||
                                              homecontoller
                                                  .wishlistid.isEmpty) {
                                            Addtowishlist(FirebasewishlistModel(
                                                userid: homecontoller.userid,
                                                wishitems: [
                                                  Wishitems(
                                                    brandname:
                                                        productList[index]
                                                            .brand!
                                                            .name,
                                                    image: productList[index]
                                                        .thumbnail,
                                                    price: productList[index]
                                                        .price
                                                        .toString(),
                                                    // saleprice: productList[index]
                                                    //     .salePrice
                                                    //     .toString(),
                                                    saleprice: (productList[
                                                                    index]
                                                                .price -
                                                            (productList[index]
                                                                    .price *
                                                                (productList[
                                                                            index]
                                                                        .salePrice *
                                                                    0.01)))
                                                        .toString(),
                                                    productid:
                                                        productList[index].id,
                                                    productname:
                                                        productList[index]
                                                            .title,
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
                                                  productList[index].brand ==
                                                          null
                                                      ? "Brand"
                                                      : productList[index]
                                                          .brand!
                                                          .name,
                                              image:
                                                  productList[index].thumbnail,
                                              price: productList[index]
                                                  .price
                                                  .toString(),
                                              // saleprice: productList[index]
                                              //     .salePrice
                                              //     .toString(),
                                              saleprice: (productList[index]
                                                          .price -
                                                      (productList[index]
                                                              .price *
                                                          (productList[index]
                                                                  .salePrice *
                                                              0.01)))
                                                  .toString(),
                                              productid: productList[index].id,
                                              productname:
                                                  productList[index].title,
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
                                        });
                                      } else {
                                        if (homecontoller.wishlistid == '' ||
                                            homecontoller.wishlistid.isEmpty) {
                                          Addtowishlist(FirebasewishlistModel(
                                              userid: homecontoller.userid,
                                              wishitems: [
                                                Wishitems(
                                                  brandname: productList[index]
                                                      .brand!
                                                      .name,
                                                  image: productList[index]
                                                      .thumbnail,
                                                  price: productList[index]
                                                      .price
                                                      .toString(),
                                                  // saleprice: productList[index]
                                                  //     .salePrice
                                                  //     .toString(),
                                                  saleprice: (productList[index]
                                                              .price -
                                                          (productList[index]
                                                                  .price *
                                                              (productList[
                                                                          index]
                                                                      .salePrice *
                                                                  0.01)))
                                                      .toString(),
                                                  productid:
                                                      productList[index].id,
                                                  productname:
                                                      productList[index].title,
                                                )
                                              ])).then(
                                            (value) {
                                              cartitem();
                                            },
                                          );
                                        } else {
                                          homecontoller.wishlist.add(Wishitems(
                                            brandname:
                                                productList[index].brand == null
                                                    ? "Brand"
                                                    : productList[index]
                                                        .brand!
                                                        .name,
                                            image: productList[index].thumbnail,
                                            price: productList[index]
                                                .price
                                                .toString(),
                                            // saleprice: productList[index]
                                            //     .salePrice
                                            //     .toString(),
                                            saleprice: (productList[index]
                                                        .price -
                                                    (productList[index].price *
                                                        (productList[index]
                                                                .salePrice *
                                                            0.01)))
                                                .toString(),
                                            productid: productList[index].id,
                                            productname:
                                                productList[index].title,
                                          ));
                                          setState(() {});
                                          updatetowishlist(
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
                                            },
                                          );
                                        }
                                      }
                                    }
                                  },
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: fevorite_productList[index]
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
                                          productList[index].title,
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
                                          productList[index].brand == null
                                              ? "Brand"
                                              : productList[index].brand!.name,
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
                                      productList[index].salePrice == 0
                                          ? Container()
                                          : Container(
                                              child: Text(
                                                "₹ ${productList[index].price}.00",
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
                                          // "₹ ${Viwerlist[index].salePrice}.00",
                                          "₹ ${(productList[index].price - (productList[index].price * (productList[index].salePrice * 0.01))).toStringAsFixed(0)}",
                                          style: TextStyle(
                                              color: AppColor.BlackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
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
            })));
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

  searchfiled() {
    return Padding(
      padding: EdgeInsets.only(top: 24),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: 55,
              // width: MediaQuery.of(context).size.width * 0.9,
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  padding: EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    controller: searcherController.searchcontoller,
                    onSaved: (newValue) {
                      setState(() {
                        searcherController.isloader = true;
                      });
                    },
                    onFieldSubmitted: (value) {
                      setState(() {
                        searchicon = true;
                        searcherController.isloader = true;
                        if (searcherController
                            .searchcontoller.text.isNotEmpty) {
                          searcherController.brandvalues
                              .add(searcherController.searchcontoller.text);
                        }
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          setState(() {
                            searchicon = false;
                          });
                        } else {
                          if (searchicon == true &&
                              searcherController
                                  .searchcontoller.text.isNotEmpty) {
                            searchicon = false;
                          }
                        }
                      });
                    },
                    decoration: InputDecoration(
                        suffixIcon: !searchicon
                            ? InkWell(
                                overlayColor:
                                    WidgetStatePropertyAll(Colors.white),
                                onTap: () {
                                  if (searcherController
                                      .searchcontoller.text.isNotEmpty) {
                                    setState(() {
                                      FocusScopeNode currentFocus =
                                          FocusScope.of(context);
                                      if (!currentFocus.hasPrimaryFocus &&
                                          currentFocus.focusedChild != null) {
                                        currentFocus.focusedChild!.unfocus();
                                      }
                                      searchicon = true;
                                      searcherController.isloader = true;
                                      if (searcherController
                                          .searchcontoller.text.isNotEmpty) {
                                        searcherController.brandvalues.add(
                                            searcherController
                                                .searchcontoller.text);
                                      }
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.arrow_circle_right_outlined,
                                  color: AppColor.fontColorgrey,
                                ),
                              )
                            : InkWell(
                                overlayColor:
                                    WidgetStatePropertyAll(Colors.white),
                                onTap: () {
                                  if (searcherController
                                      .searchcontoller.text.isNotEmpty) {
                                    searcherController.searchcontoller.clear();
                                    setState(() {
                                      searchicon = false;
                                      searcherController.isloader = true;
                                    });
                                  }
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Image(
                                        image: AssetImage(AppImage.appIcon +
                                            "searchremove.png")),
                                  ),
                                ),
                              ),
                        prefixIcon: Container(
                          height: 30,
                          width: 30,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Image(
                                image: AssetImage(
                                    AppImage.appIcon + "search.png")),
                          ),
                        ),
                        border: InputBorder.none,
                        hintText: "Search Furniture",
                        hintStyle: TextStyle(
                            color: AppColor.fontColorgrey,
                            fontFamily: AppFont.lato)),
                  )),
            ),
          ),
          InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.white),
            onTap: () {
              WebAPPNavigation.navigateToroute(
                  context: context,
                  routename: "/filterpage",
                  screen: FilterPage());
            },
            child: Container(
              margin: EdgeInsets.only(right: 24),
              height: 24,
              width: 24,
              child: Image.asset("assets/image/filter.png"),
            ),
          ),
        ],
      ),
    );
  }

  // filteradd() {
  //   return
  // }

  recentlysearch() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Recently searched",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.white),
            onTap: () {
              searcherController.brandvalues.clear();
              setState(() {});
            },
            child: Text(
              "Clear",
              style: TextStyle(
                  fontSize: 16,
                  color: AppColor.fontColorgrey,
                  fontWeight: FontWeight.w500),
            ),
          )
        ],
      ),
    );
  }

  Searchgridview() {
    return searcherController.isloader == true
        ? Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: AppColor.BlackColor,
              ),
            ),
          )
        : Expanded(
            child: Container(
              width: MediaQuery.of(context).size.height,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: false
                      ? Center(
                          child: Text(
                            "No Data Found",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        )
                      : FlexibleGridView(
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 10,
                          children: List.generate(
                              2,
                              (index) => InkWell(
                                    overlayColor:
                                        WidgetStatePropertyAll(Colors.white),
                                    onTap: () {
                                      WebAPPNavigation.navigateToroute(
                                          context: context,
                                          routename: '/ProductDetailScreen',
                                          screen: ProductDetailScreen());
                                    },
                                    child: Container(
                                      margin: new EdgeInsets.all(1.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: new Center(
                                          child: new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl:
                                                    "https://eatanytime.in/cdn/shop/products/AllinOneProteinBalls-ProteinHouse_a7ea0956-e0b2-4717-8768-4cd8c549b9fd-399401.png?v=1704714089&width=533https://eatanytime.in/cdn/shop/products/AllinOneProteinBalls-ProteinHouse_a7ea0956-e0b2-4717-8768-4cd8c549b9fd-399401.png?v=1704714089&width=533",
                                                imageBuilder:
                                                    (context, imageProvider) {
                                                  return Container(
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover),
                                                    ),
                                                  );
                                                },
                                                placeholder: (context, url) =>
                                                    Container(
                                                  height: 200,
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                    color: AppColor.BlackColor,
                                                  )),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                              Positioned(
                                                right: 10,
                                                top: 10,
                                                child: InkWell(
                                                  overlayColor:
                                                      WidgetStatePropertyAll(
                                                          Colors.white),
                                                  onTap: () {},
                                                  child: Image.asset(
                                                    AppImage.appIcon +
                                                        'health.png',
                                                    height: 30,
                                                    width: 30,
                                                    color: AppColor.BlackColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 8.0, left: 2),
                                            child: Text(
                                              "TITLE",
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 8.0, left: 2),
                                            child: Text(
                                              "₹ 100",
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: AppColor.viewallcolor,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ),
                                  )),
                        )),
            ),
          );
  }

  searchHistory() {
    return searcherController.brandvalues.isEmpty
        ? SizedBox()
        : Container(
            height: 35,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(bottom: 20),
            child: ListView.builder(
              // reverse: true,
              itemCount: searcherController.brandvalues.length < 10
                  ? searcherController.brandvalues.length
                  : 10,
              padding: EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                int itemCount = searcherController.brandvalues.length;
                int reversedIndex = itemCount - 1 - index;
                return InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  onTap: () {
                    setState(() {
                      searcherController.isloader = true;
                    });
                    searcherController.searchcontoller.text =
                        searcherController.brandvalues[index];
                    setState(() {});
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: index == 0 ? 0 : 5, right: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColor.whiteColor),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          Text(
                            "${searcherController.brandvalues[reversedIndex]}",
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColor.fontColorgrey,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }
}
