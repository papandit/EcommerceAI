// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_new, sized_box_for_whitespace, non_constant_identifier_names, unnecessary_import, must_be_immutable, unused_local_variable, avoid_function_literals_in_foreach_calls, unnecessary_string_interpolations, deprecated_member_use, avoid_print

import 'package:EcommerceApp/helper/dailogclass.dart';
import 'package:EcommerceApp/helper/loginshow.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/productmodel.dart';
import 'package:EcommerceApp/model/userdataset.dart';
import 'package:EcommerceApp/helper/product_colors.dart';
import 'package:EcommerceApp/model/wishlistmodel.dart';
import 'package:EcommerceApp/view/product_detail_page.dart';
import 'package:EcommerceApp/view/product_filter_view.dart';
import 'package:EcommerceApp/viewmodel/filtercontroller.dart';
import 'package:EcommerceApp/viewmodel/mostInterestedcontoller.dart';
import 'package:EcommerceApp/viewmodel/searchcontroller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flexible_grid_view/flexible_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/api/user_data_api.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/homecontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({super.key, this.id, this.title, this.subname});
  String? id;
  String? title;
  String? subname;
  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  SearcherController searcherController = Get.put(SearcherController());
  Homecontoller homecontoller = Get.put(Homecontoller());
  MostIntrestedController mostIntrestedController =
      Get.put(MostIntrestedController());
  FilterController filterController = Get.put(FilterController());
  bool NodataFound = false;
  bool searchicon = false;
  bool GridViewTwo = false;
  List<ProductModel> AllData = [];
  List<ProductModel> Storedata = [];

  bool textfield = false;
  String sortingvalue = "Sort by";
  TextEditingController searchcontroller = TextEditingController();
  // Future<List<ProductModel>> ProductsDataGet() async {
  //   print("widget.id :: ${widget.id}");
  //   QuerySnapshot<Map<String, dynamic>>? snapshot = await firestore
  //       .collection("Products")
  //       .where('CategoryId', isEqualTo: widget.id)
  //       .get();

  //   print("data snapshort :: ${snapshot.docs.length}");
  //   return snapshot.docs
  //       .map((docSnapshot) => ProductModel.fromQuerySnapshot(docSnapshot))
  //       .toList();
  // }

  Future<List<ProductModel>> ProductsDataGet() async {
    // Products for this category (filtered server-side by CategoryId).
    final Map<String, ProductModel> products = {};
    try {
      final list = await ApiClient.instance
          .getList('/products', query: {'categoryId': widget.id, 'sort': 'newest'});
      for (final e in list) {
        final p = ProductModel.fromJson(e);
        products[p.id] = p;
      }
    } catch (_) {}
    if (mounted) setState(() {});
    return products.values.toList();
  }

  String userid = '';
  Future<UserModel?> UsercheckDataGet() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString(prefrenceKey.userid) ?? '';
    setState(() {});
    try {
      final map = await ApiClient.instance.getOne('/auth/me');
      return UserModel.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  List<bool> fevorite_categoryall = [];
  @override
  void initState() {
    homecontoller.wishlist.forEach((element) {
    });
    setState(() {
      cartitem();
      searcherController.isloader = true;
    });
    searcherController.searchlist = searcherController.widgetList;
    filterController.isInStock = false;
    setState(() {});

    ProductsDataGet().then(
      (value) {
        setState(() {
          AllData = value;
          Storedata = value;
          value.forEach(
            (element) {
              fevorite_categoryall.add(false);
            },
          );
          searcherController.isloader = false;

          if (userid != '') {
            UsercheckDataGet();
          }
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
                                _categoryHero(),
                                Storedata.isEmpty
                                    ? _noProducts()
                                    : ProductFilterView(
                                        products: Storedata,
                                        cardBuilder: _categoryCard,
                                      ),
                                CommonWidget()
                                    .Footer(context, Refresh: setState)
                              ]))),
                ),
              )
            : Scaffold(
                backgroundColor: AppColor.BgColor,
                appBar: CommonWidget().Header(context: context, heart: false),
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _categoryHero(),
                        Storedata.isEmpty
                            ? _noProducts()
                            : ProductFilterView(
                                products: Storedata,
                                cardBuilder: _categoryCard,
                              ),
                      ],
                    ),
                  ),
                ),
              );
  }

  bool _looksLikeCode(String s) {
    final t = s.trim();
    if (t.isEmpty || t.contains(' ')) return false;
    if (t.length >= 16 && RegExp(r'^[0-9a-fA-F-]+$').hasMatch(t)) return true;
    if (t.length >= 24) return true;
    return false;
  }

  String _categoryName() {
    // 1) Resolve the real category / sub-category name from the loaded list.
    for (final c in CommonWidget.categorylist) {
      if (c.id == widget.id) {
        if (widget.subname != null &&
            widget.subname!.isNotEmpty &&
            c.parentId != null) {
          for (final sub in c.parentId!) {
            if (sub.id == widget.subname) return sub.name ?? c.name;
          }
        }
        return c.name;
      }
    }
    // 2) Use the passed title if it isn't empty / unknown / a raw id.
    final raw = (widget.title ?? '').trim();
    final low = raw.toLowerCase();
    if (raw.isNotEmpty &&
        low != 'unknown' &&
        low != 'null' &&
        !_looksLikeCode(raw)) {
      return raw;
    }
    // 3) Derive from a readable URL slug.
    try {
      final segs = Uri.base.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segs.isNotEmpty && !_looksLikeCode(segs.last)) {
        final last = Uri.decodeComponent(segs.last)
            .replaceAll('-', ' ')
            .replaceAll('_', ' ')
            .trim();
        final lastLow = last.toLowerCase();
        if (last.isNotEmpty &&
            lastLow != 'categorypage' &&
            lastLow != 'categorypages') {
          return last
              .split(' ')
              .where((w) => w.isNotEmpty)
              .map((w) => w[0].toUpperCase() + w.substring(1))
              .join(' ');
        }
      }
    } catch (_) {}
    return "The Women's Edit";
  }

  Widget _categoryHero() {
    final String label = _categoryName();
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(gradient: AppColor.roseGradient),
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          margin: EdgeInsets.only(bottom: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "CURATED FOR HER",
                style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 2,
                    color: AppColor.primary,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: AppFont.heading,
                    fontSize: 34,
                    color: AppColor.ink,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                AllData.isEmpty
                    ? "Discover the collection"
                    : "${AllData.length} ${AllData.length == 1 ? 'style' : 'styles'} to explore",
                style: TextStyle(
                    fontSize: 14,
                    color: AppColor.fontColorgrey,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: CommonWidget().heroBackArrow(context),
        ),
      ],
    );
  }

  Widget _noProducts() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
                color: AppColor.blush, shape: BoxShape.circle),
            child: Icon(Icons.checkroom_outlined,
                size: 40, color: AppColor.primary),
          ),
          SizedBox(height: 20),
          Text(
            "No styles here yet",
            style: TextStyle(
                fontFamily: AppFont.heading,
                fontSize: 24,
                color: AppColor.ink,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            "We're adding new pieces all the time —\ncheck back soon or explore another category.",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, height: 1.5, color: AppColor.fontColorgrey),
          ),
        ],
      ),
    );
  }

  // ── Grid-friendly category card (used by ProductFilterView) ──────────────
  // Same visual as before (brand → title → price + wishlist heart); favourite
  // state is keyed by product id so it stays correct after filtering.
  Widget _categoryCard(ProductModel p, int index, List<ProductModel> list) {
    final bool fav = homecontoller.wishlist.any((e) => e.productid == p.id);
    final offer = p.price - (p.price * (p.salePrice * 0.01));
    return HoverLift(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        WebAPPNavigation.navigateToroute(
          context: context,
          routename:
              '/ProductDetailScreen/${p.id}',
          data: {
            'productModel': p,
            'index': index,
            'productModelList': list,
            'productName': p.title,
          },
          screen: ProductDetailScreen(
            index: index,
            productModel: p,
            productModelList: list,
            title: p.title,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color: AppColor.whiteColor,
            border: Appborder.appborder,
            boxShadow: [Appshadow.shadow],
            borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppColor.blush,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: p.thumbnail,
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColor.primary)),
                      errorWidget: (context, url, error) => Center(
                          child: Icon(Icons.checkroom_outlined,
                              color: AppColor.primary)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      overlayColor: WidgetStatePropertyAll(Colors.white),
                      onTap: () => _toggleWishlist(p),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                          height: 34,
                          width: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: AppColor.whiteColor,
                              shape: BoxShape.circle,
                              boxShadow: Appshadow.soft),
                          child: Icon(
                            fav ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: fav ? AppColor.primary : AppColor.ink,
                          ),
                        ),
                      ),
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
                  Text(
                    (p.brand?.name ?? '').toString().toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColor.fontColorgrey,
                        fontSize: 11,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 3),
                  Text(
                    p.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        height: 1.25,
                        color: AppColor.ink,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 7,
                    children: [
                      Text(
                        "₹${offer.toStringAsFixed(0)}",
                        style: TextStyle(
                            color: AppColor.ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                      ),
                      if (p.salePrice != 0)
                        Text(
                          "₹${p.price}",
                          style: TextStyle(
                              color: AppColor.fontColorgrey,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough),
                        ),
                      if (p.salePrice != 0)
                        Text(
                          "(${p.salePrice.toStringAsFixed(0)}% OFF)",
                          style: TextStyle(
                              color: Color(0xff2E8B57),
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                    ],
                  ),
                  productColorSwatches(p),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleWishlist(ProductModel p) {
    final bool fav = homecontoller.wishlist.any((e) => e.productid == p.id);
    if (fav) {
      homecontoller.wishlist.removeWhere((e) => e.productid == p.id);
      setState(() {});
      removetowishlist(FirebasewishlistModel(
              userid: homecontoller.userid,
              wishlistid: homecontoller.wishlistid,
              wishitems: homecontoller.wishlist))
          .then((value) => cartitem());
    } else {
      if (homecontoller.userid.isEmpty) {
        LoginDialog.showLoginDialog(context, () => _addWish(p));
      } else {
        _addWish(p);
      }
    }
  }

  void _addWish(ProductModel p) {
    final item = Wishitems(
      brandname: p.brand?.name ?? '',
      image: p.thumbnail,
      price: p.price.toString(),
      saleprice: (p.price - (p.price * (p.salePrice * 0.01))).toString(),
      productid: p.id,
      productname: p.title,
    );
    if (homecontoller.wishlistid == '' || homecontoller.wishlistid.isEmpty) {
      Addtowishlist(FirebasewishlistModel(
              userid: homecontoller.userid, wishitems: [item]))
          .then((value) => cartitem());
    } else {
      homecontoller.wishlist.add(item);
      updatetowishlist(FirebasewishlistModel(
              userid: homecontoller.userid,
              wishlistid: homecontoller.wishlistid,
              wishitems: homecontoller.wishlist))
          .then((value) => cartitem());
    }
    setState(() {});
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
    AllData = Storedata;
    setState(() {});
    if (filterController.isInStock) {
      AllData = await CommonWidget().InStock(AllData);
    } else {
      // print("viewallsearch 123  ${Storedata.length}");
      // setState(() {
      //   // AllData = Storedata;
      //   if (Storedata.isNotEmpty) {
      //     AllData.assignAll(Storedata);
      //   }
      // });
    }

    // AllData = AllData.where((item) =>
    //     double.parse(item.price.toString()) >=
    //         filterController.syncvalues.start &&
    //     double.parse(item.price.toString()) <=
    //         filterController.syncvalues.end).toList();
    AllData = AllData.where((item) =>
        double.parse((item.price - (item.price * (item.salePrice * 0.01)))
                .toString()) >=
            filterController.syncvalues.start &&
        double.parse((item.price - (item.price * (item.salePrice * 0.01)))
                .toString()) <=
            filterController.syncvalues.end).toList();
    setState(() {});
  }

  // List<bool> fevorite_categoryall = [];

  Future ColorFilter() async {
    AllData = Storedata;
    setState(() {});
    List<ProductModel> colorlist = [];
    AllData.forEach(
      (element) {
        fevorite_categoryall.add(false);
        setState(() {});
        element.productAttributes!.forEach(
          (elementss) {
            if (elementss.name == "Colors") {
              elementss.values!.forEach(
                (elementcode) {
                  if (Color(int.parse(elementcode)) == colorcode) {
                    colorlist.add(element);
                  }
                },
              );
            }
          },
        );
      },
    );
    AllData = colorlist;
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
        // ColorFilter().then(
        //   (value) {
        //     tooltipController.hide();
        //   },
        // );
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: 450),
        padding: EdgeInsets.symmetric(
          vertical: 15,
        ),
        margin: EdgeInsets.only(left: 24, right: 24, bottom: 24),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), color: AppColor.primary),
        child: Text(
          "Apply Filter",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColor.whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w600),
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
            AllData = Storedata;
            // viewallsearch = productList;
          });
          colorselected = 1;
          // firebasewishlistModel.wishitems = mostIntrestedController.Reserve;
        });

        tooltipController.hide();
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
            borderRadius: BorderRadius.circular(12),
            color: AppColor.whiteColor,
            border: Border.all(color: AppColor.dividercolor)),
        child: Text(
          "Reset Filter",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColor.ink, fontSize: 16, fontWeight: FontWeight.w600),
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
                            ? MediaQuery.of(context).size.width - 32
                            : 400,
                        decoration: ShapeDecoration(
                          color: AppColor.whiteColor,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: AppColor.dividercolor,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          shadows: [
                            BoxShadow(
                              color: AppColor.ink.withOpacity(0.16),
                              blurRadius: 32,
                              offset: const Offset(0, 18),
                              spreadRadius: -6,
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
                                  'Filters',
                                  style: TextStyle(
                                      fontFamily: AppFont.heading,
                                      color: AppColor.ink,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 22.0),
                                ),
                              ),
                            ),

                            Row(children: [
                              Checkbox(
                                value: filterController.isInStock,
                                activeColor: AppColor.BlackColor,
                                onChanged: (value) {
                                  setState(() {
                                    print(
                                        "filterController.isInStock value :: $value");
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
                        // (productList[index].price - (productList[index].price * (productList[index].salePrice * 0.01)))
                        sortingvalue = value as String;
                        if (sortingvalue == 'Price: High  to Low') {
                          AllData.sort((a, b) => double.parse(
                                  (a.price - (a.price * (a.salePrice * 0.01)))
                                      .toString())
                              .compareTo(double.parse(
                                  (b.price - (b.price * (b.salePrice * 0.01)))
                                      .toString())));
                          AllData = AllData.reversed.toList();
                          setState(() {});
                        } else if (sortingvalue == 'Price: Low  to High') {
                          AllData.sort((a, b) => double.parse(
                                  (a.price - (a.price * (a.salePrice * 0.01)))
                                      .toString())
                              .compareTo(double.parse(
                                  (b.price - (b.price * (b.salePrice * 0.01)))
                                      .toString())));
                          AllData = AllData.toList();
                          setState(() {});
                        } else if (sortingvalue == "A - Z") {
                          AllData.sort((a, b) => a.title.compareTo(b.title));
                          AllData = AllData.toList();
                          setState(() {});
                          // "Z - A",
                        } else if (sortingvalue == "Z - A") {
                          AllData.sort((a, b) => a.title.compareTo(b.title));
                          AllData = AllData.reversed.toList();
                          setState(() {});
                        }
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
                            ? MediaQuery.of(context).size.width - 32
                            : 400,
                        decoration: ShapeDecoration(
                          color: AppColor.whiteColor,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: AppColor.dividercolor,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          shadows: [
                            BoxShadow(
                              color: AppColor.ink.withOpacity(0.16),
                              blurRadius: 32,
                              offset: const Offset(0, 18),
                              spreadRadius: -6,
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
                                  'Filters',
                                  style: TextStyle(
                                      fontFamily: AppFont.heading,
                                      color: AppColor.ink,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 22.0),
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
                        AllData.sort((a, b) => int.parse(a.price.toString())
                            .compareTo(int.parse(b.price.toString())));
                        AllData = AllData.reversed.toList();
                        setState(() {});
                      } else if (sortingvalue == 'Price: Low  to High') {
                        AllData.sort((a, b) => int.parse(a.price.toString())
                            .compareTo(int.parse(b.price.toString())));
                        AllData = AllData.toList();
                        setState(() {});
                      } else if (sortingvalue == "A - Z") {
                        AllData.sort((a, b) => a.title.compareTo(b.title));
                        AllData = AllData.toList();
                        setState(() {});
                        // "Z - A",
                      } else if (sortingvalue == "Z - A") {
                        AllData.sort((a, b) => a.title.compareTo(b.title));
                        AllData = AllData.reversed.toList();
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
              children: List.generate(AllData.length, (index) {
                homecontoller.wishlist.asMap().forEach(
                  (listindex, element) {
                    if (element.productid == AllData[index].id) {
                      fevorite_categoryall[index] = true;
                      print(
                          "fevorite_categoryall t--:: $fevorite_categoryall");
                      setState(() {});
                    }
                  },
                );
                return HoverLift(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        routename:
                            '/ProductDetailScreen/${AllData[index].id}',
                        data: {
                          'productModel': AllData[index],
                          'index': index,
                          'productModelList': AllData,
                          'productName': AllData[index].title
                        },
                        screen: ProductDetailScreen(
                          index: index,
                          productModel: AllData[index],
                          productModelList: AllData,
                          title: AllData[index].title,
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
                                    imageUrl: AllData[index].thumbnail,
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
                                        if (fevorite_categoryall[index] ==
                                            true) {
                                          homecontoller.wishlist.removeWhere(
                                              (element) =>
                                                  element.productid ==
                                                  AllData[index].id);
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
                                              fevorite_categoryall[index] =
                                                  false;
                                              cartitem();
                                            },
                                          );
                                        } else {
                                          print(
                                              'SPcheck ${homecontoller.wishlistid}');
                                          print(
                                              'SPcheck User :: ${homecontoller.userid}');
                                          if (homecontoller.userid.isEmpty) {
                                            LoginDialog.showLoginDialog(context,
                                                () {
                                              setState(() {});
                                              if (homecontoller.wishlistid ==
                                                      '' ||
                                                  homecontoller
                                                      .wishlistid.isEmpty) {
                                                Addtowishlist(
                                                    FirebasewishlistModel(
                                                        userid: homecontoller
                                                            .userid,
                                                        wishitems: [
                                                      Wishitems(
                                                        brandname:
                                                            AllData[index]
                                                                .brand!
                                                                .name,
                                                        saleprice: (AllData[
                                                                        index]
                                                                    .price -
                                                                (AllData[index]
                                                                        .price *
                                                                    (AllData[index]
                                                                            .salePrice *
                                                                        0.01)))
                                                            .toString(),
                                                        image: AllData[index]
                                                            .thumbnail,
                                                        price: AllData[index]
                                                            .price
                                                            .toString(),
                                                        productid:
                                                            AllData[index].id,
                                                        productname:
                                                            AllData[index]
                                                                .title,
                                                      )
                                                    ])).then(
                                                  (value) {
                                                    cartitem();
                                                  },
                                                );
                                              } else {
                                                setState(() {});

                                                homecontoller.wishlist
                                                    .add(Wishitems(
                                                  brandname: AllData[index]
                                                      .brand!
                                                      .name,
                                                  image:
                                                      AllData[index].thumbnail,
                                                  price: AllData[index]
                                                      .price
                                                      .toString(),
                                                  saleprice: (AllData[index]
                                                              .price -
                                                          (AllData[index]
                                                                  .price *
                                                              (AllData[index]
                                                                      .salePrice *
                                                                  0.01)))
                                                      .toString(),
                                                  productid: AllData[index].id,
                                                  productname:
                                                      AllData[index].title,
                                                ));
                                                setState(() {});
                                                updatetowishlist(
                                                        FirebasewishlistModel(
                                                            userid:
                                                                homecontoller
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
                                            setState(() {});
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
                                                      brandname: AllData[index]
                                                          .brand!
                                                          .name,
                                                      saleprice: (AllData[index]
                                                                  .price -
                                                              (AllData[index]
                                                                      .price *
                                                                  (AllData[index]
                                                                          .salePrice *
                                                                      0.01)))
                                                          .toString(),
                                                      image: AllData[index]
                                                          .thumbnail,
                                                      price: AllData[index]
                                                          .price
                                                          .toString(),
                                                      productid:
                                                          AllData[index].id,
                                                      productname:
                                                          AllData[index].title,
                                                    )
                                                  ])).then(
                                                (value) {
                                                  cartitem();
                                                },
                                              );
                                            } else {
                                              setState(() {});
                                              homecontoller.wishlist
                                                  .add(Wishitems(
                                                brandname:
                                                    AllData[index].brand!.name,
                                                image: AllData[index].thumbnail,
                                                price: AllData[index]
                                                    .price
                                                    .toString(),
                                                saleprice: (AllData[index]
                                                            .price -
                                                        (AllData[index].price *
                                                            (AllData[index]
                                                                    .salePrice *
                                                                0.01)))
                                                    .toString(),
                                                productid: AllData[index].id,
                                                productname:
                                                    AllData[index].title,
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
                                          child: Container(
                                            height: 34,
                                            width: 34,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: AppColor.whiteColor,
                                                shape: BoxShape.circle,
                                                boxShadow: Appshadow.soft),
                                            child: Icon(
                                              fevorite_categoryall[index]
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              size: 18,
                                              color: fevorite_categoryall[index]
                                                  ? AppColor.primary
                                                  : AppColor.ink,
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 12, 10, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (AllData[index].brand?.name ?? '')
                                        .toString()
                                        .toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: AppColor.fontColorgrey,
                                        fontSize: 11,
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    AllData[index].title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        height: 1.25,
                                        color: AppColor.ink,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 8),
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 7,
                                    children: [
                                      Text(
                                        "₹${(AllData[index].price - (AllData[index].price * (AllData[index].salePrice * 0.01))).toStringAsFixed(0)}",
                                        style: TextStyle(
                                            color: AppColor.ink,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      if (AllData[index].salePrice != 0)
                                        Text(
                                          "₹${AllData[index].price}",
                                          style: TextStyle(
                                              color: AppColor.fontColorgrey,
                                              fontSize: 12,
                                              decoration:
                                                  TextDecoration.lineThrough),
                                        ),
                                      if (AllData[index].salePrice != 0)
                                        Text(
                                          "(${AllData[index].salePrice.toStringAsFixed(0)}% OFF)",
                                          style: TextStyle(
                                              color: Color(0xff2E8B57),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700),
                                        ),
                                    ],
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

  Widget NewPopularListviewForTwo() {
    return Padding(
        padding: EdgeInsets.only(left: 24.0, right: 24, top: 15, bottom: 15),
        child: Container(
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
              children: List.generate(AllData.length, (index) {
                // List<bool> fevorite = List.generate(
                //   AllData.length,
                //   (index) => false,
                // );
                // homecontoller.wishlist.asMap().forEach(
                //   (listindex, element) {
                //     if (element.productid == AllData[index].id) {
                //       fevorite_categoryall[index] = true;
                //     }
                //   },
                // );
                return HoverLift(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        routename:
                            '/ProductDetailScreen/${AllData[index].id}',
                        data: {
                          'productModel': AllData[index],
                          'index': index,
                          'productModelList': AllData,
                          'productName': AllData[index].title
                        },
                        screen: ProductDetailScreen(
                          index: index,
                          productModel: AllData[index],
                          productModelList: AllData,
                          title: AllData[index].title,
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
                                  imageUrl: AllData[index].thumbnail,
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
                                      if (fevorite_categoryall[index] == true) {
                                        homecontoller.wishlist.removeWhere(
                                            (element) =>
                                                element.productid ==
                                                AllData[index].id);
                                        removetowishlist(FirebasewishlistModel(
                                                userid: homecontoller.userid,
                                                wishlistid:
                                                    homecontoller.wishlistid,
                                                wishitems:
                                                    homecontoller.wishlist))
                                            .then(
                                          (value) {
                                            fevorite_categoryall[index] = false;
                                            cartitem();
                                          },
                                        );
                                      } else {
                                        print(
                                            'SPcheck ${homecontoller.wishlistid}');

                                        print(
                                            'SPcheck User :: ${homecontoller.userid}');
                                        if (homecontoller.userid.isEmpty) {
                                          LoginDialog.showLoginDialog(context,
                                              () {
                                            if (homecontoller.wishlistid ==
                                                    '' ||
                                                homecontoller
                                                    .wishlistid.isEmpty) {
                                              setState(() {});
                                              Addtowishlist(
                                                  FirebasewishlistModel(
                                                      userid:
                                                          homecontoller.userid,
                                                      wishitems: [
                                                    Wishitems(
                                                      brandname: AllData[index]
                                                          .brand!
                                                          .name,
                                                      image: AllData[index]
                                                          .thumbnail,
                                                      price: AllData[index]
                                                          .price
                                                          .toString(),
                                                      saleprice: (AllData[index]
                                                                  .price -
                                                              (AllData[index]
                                                                      .price *
                                                                  (AllData[index]
                                                                          .salePrice *
                                                                      0.01)))
                                                          .toString(),
                                                      productid:
                                                          AllData[index].id,
                                                      productname:
                                                          AllData[index].title,
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
                                                    AllData[index].brand!.name,
                                                image: AllData[index].thumbnail,
                                                price: AllData[index]
                                                    .price
                                                    .toString(),
                                                saleprice: (AllData[index]
                                                            .price -
                                                        (AllData[index].price *
                                                            (AllData[index]
                                                                    .salePrice *
                                                                0.01)))
                                                    .toString(),
                                                //  AllData[index]
                                                //     .salePrice
                                                //     .toString(),
                                                productid: AllData[index].id,
                                                productname:
                                                    AllData[index].title,
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
                                            setState(() {});
                                            Addtowishlist(FirebasewishlistModel(
                                                userid: homecontoller.userid,
                                                wishitems: [
                                                  Wishitems(
                                                    brandname: AllData[index]
                                                        .brand!
                                                        .name,
                                                    image: AllData[index]
                                                        .thumbnail,
                                                    price: AllData[index]
                                                        .price
                                                        .toString(),
                                                    saleprice: (AllData[index]
                                                                .price -
                                                            (AllData[index]
                                                                    .price *
                                                                (AllData[index]
                                                                        .salePrice *
                                                                    0.01)))
                                                        .toString(),
                                                    productid:
                                                        AllData[index].id,
                                                    productname:
                                                        AllData[index].title,
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
                                                  AllData[index].brand!.name,
                                              image: AllData[index].thumbnail,
                                              price: AllData[index]
                                                  .price
                                                  .toString(),
                                              saleprice: (AllData[index].price -
                                                      (AllData[index].price *
                                                          (AllData[index]
                                                                  .salePrice *
                                                              0.01)))
                                                  .toString(),
                                              //  AllData[index]
                                              //     .salePrice
                                              //     .toString(),
                                              productid: AllData[index].id,
                                              productname: AllData[index].title,
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
                                        child:
                                            // fevorite_categoryall[index]
                                            //     ? Icon(
                                            //         Icons.favorite,
                                            //         size: 30,
                                            //       )
                                            //     :

                                            Icon(
                                          Icons.favorite_border,
                                          size: 30,
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 12, 10, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (AllData[index].brand?.name ?? '')
                                      .toString()
                                      .toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: AppColor.fontColorgrey,
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  AllData[index].title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      height: 1.25,
                                      color: AppColor.ink,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 7,
                                  children: [
                                    Text(
                                      "₹${(AllData[index].price - (AllData[index].price * (AllData[index].salePrice * 0.01))).toStringAsFixed(0)}",
                                      style: TextStyle(
                                          color: AppColor.ink,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    if (AllData[index].salePrice != 0)
                                      Text(
                                        "₹${AllData[index].price}",
                                        style: TextStyle(
                                            color: AppColor.fontColorgrey,
                                            fontSize: 12,
                                            decoration:
                                                TextDecoration.lineThrough),
                                      ),
                                    if (AllData[index].salePrice != 0)
                                      Text(
                                        "(${AllData[index].salePrice.toStringAsFixed(0)}% OFF)",
                                        style: TextStyle(
                                            color: Color(0xff2E8B57),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ),
                );
              })),
        ));
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
