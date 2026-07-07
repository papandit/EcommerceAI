// ignore_for_file: unnecessary_import, prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace, avoid_unnecessary_containers, non_constant_identifier_names, prefer_const_constructors_in_immutables, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, body_might_complete_normally_nullable, avoid_print, avoid_function_literals_in_foreach_calls, unnecessary_brace_in_string_interps, must_be_immutable, dead_code, deprecated_member_use, invalid_return_type_for_catch_error, body_might_complete_normally_catch_error, unused_element
import 'dart:io';
import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/api/user_data_api.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/loginshow.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/product_colors.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/cartmodels.dart';
import 'package:EcommerceApp/model/depaerment_model.dart';
import 'package:EcommerceApp/model/headerfootermodel.dart';
import 'package:EcommerceApp/model/homebanner.dart';
import 'package:EcommerceApp/model/productmodel.dart';
import 'package:EcommerceApp/model/userdataset.dart';
import 'package:EcommerceApp/model/wishlistmodel.dart';
import 'package:EcommerceApp/view/allproductspage.dart';
import 'package:EcommerceApp/view/categorypage.dart';
import 'package:EcommerceApp/view/categoryviewall.dart';
import 'package:EcommerceApp/view/luxe_edit_banner.dart';
import 'package:EcommerceApp/view/mostinterestedpage.dart';
import 'package:EcommerceApp/view/notificationpage.dart';
import 'package:EcommerceApp/view/product_detail_page.dart';
import 'package:EcommerceApp/view/searchpage.dart';
import 'package:autoscale_tabbarview/autoscale_tabbarview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/homecontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  HomePage(
      // this.refresh,
      {
    super.key,
  });
  Function? refresh;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  Homecontoller homecontoller = Get.put(Homecontoller());
  bool datanotfound = false;
  ProductModel? productModel;
  late TabController tabController;
  int offerindex = 0;
  int offerindexone = 0;
  final itemSize = 100.0;
  Future cartidchecker() async {
    final SharedPreferences perfs = await SharedPreferences.getInstance();
    homecontoller.cartid = perfs.getString('cartid') ?? "";
    setState(() {});
  }

  Future getuserdata() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    homecontoller.userid = prefs.getString(prefrenceKey.userid) ?? '';
    setState(() {});
    try {
      final map = await ApiClient.instance.getOne('/auth/me');
      CommonWidget.userModel = UserModel.fromJson(map);
      cartdacheck();
    } catch (_) {}
  }

  List<Cartitems> cartitems = [];
  Future cartdacheck() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    homecontoller.userid = prefs.getString(prefrenceKey.userid) ?? '';
    if (mounted) setState(() {});
    try {
      cartitems = await UserDataApi.getCart();
      CommonWidget.cartitems = cartitems.length;
      if (mounted) setState(() {});
    } catch (_) {}
  }

  List<String> BannersList = [];
  List<HomeBanner> bannerObjs = [];
  List<CategoryModel> CategoryList = [];
  List<ProductModel> productList = [];
  // Future DataGet() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   homecontoller.userid = prefs.getString(prefrenceKey.userid) ?? '';
  //   await Banners.get().then(
  //     (QuerySnapshot querySnapshot) {
  //       querySnapshot.docs.forEach((doc) {
  //         BannersList.add(doc["imageUrl"]);
  //         // print("imageUrl :: ${doc["imageUrl"]}");
  //       });
  //     },
  //     //   FirebaseFirestore.instance
  //     // .collection('users')
  //     // .get()
  //     // .then();
  //   ).catchError((error) => print("Failed to add user: $error"));
  // }

  Future DataGet() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    homecontoller.userid = prefs.getString(prefrenceKey.userid) ?? '';

    try {
      final list = await ApiClient.instance.getList('/banners');
      BannersList.clear();
      bannerObjs.clear();
      for (final data in list) {
        if (data['active'] == false) continue; // only active banners
        final banner = HomeBanner.fromMap(data);
        if (banner.imageUrl.isEmpty) continue;
        BannersList.add(banner.imageUrl);
        bannerObjs.add(banner);
      }
    } catch (error) {
      print("Failed to fetch banners: $error");
    }
  }

  var data;
  Future cartitem() async {
    homecontoller.wishlist.clear();
    if (homecontoller.userid.isEmpty) {
      if (mounted) setState(() {});
      return;
    }
    CommonWidget.UnverifyedUser = false;
    final items = await UserDataApi.getWishlist();
    homecontoller.wishlist.addAll(items);
    // Non-empty id so subsequent adds take the "update full list" path.
    homecontoller.wishlistid = homecontoller.userid;
    if (mounted) setState(() {});
  }

  // Wishlist persistence now goes through the Node/MongoDB backend
  // (/api/me/wishlist). The single per-user doc means add/update/remove all
  // just save the full item list passed by the caller.
  Future<void> Addtowishlist(FirebasewishlistModel wishlist) async {
    await UserDataApi.saveWishlist(wishlist.wishitems ?? []);
  }

  Future<void> updatetowishlist(FirebasewishlistModel wishlist) async {
    await UserDataApi.saveWishlist(wishlist.wishitems ?? []);
  }

  Future<void> removetowishlist(FirebasewishlistModel wishlist) async {
    await UserDataApi.saveWishlist(wishlist.wishitems ?? []);
  }

  Future<List<CategoryModel>> CategoryDataGet() async {
    try {
      final list = await ApiClient.instance.getList('/categories');
      return list.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ProductModel>> ProductsDataGet() async {
    try {
      final list =
          await ApiClient.instance.getList('/products', query: {'sort': 'newest'});
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<DepartmentModel>> ProductsDepartMentGet() async {
    try {
      final list = await ApiClient.instance.getList('/departments');
      return list.map((e) => DepartmentModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  HeaderFooterModel? headerFooterModel;
  List<HeaderFooterModel> headerFooterModelList = [];
  List<ProductModel> Festival = [];
  List<ProductModel> Bestselling = [];
  List<ProductModel> Trendings = [];
  List<ProductModel> Populer = [];
  List<ProductModel> Discountoffer = [];
  List<ProductModel> Allunder = [];
  List<ProductModel> Quickship = [];
  List<DepartmentModel> department = [];
  Future datasset(List<ProductModel> caller) {
    caller.forEach(
      (element) {
        alldata.add(element);
        filteredDepartments = [];
        datasetforDepartment(alldata, department[0].deptName);
        if (element.departmentname == "Trending") {
          Trendings.add(element);
          fevorite_trending.add(false);
        } else if (element.departmentname == "Best Selling") {
          Bestselling.add(element);
          fevorite_Best_selling.add(false);
        } else if (element.departmentname == "Popular") {
          Populer.add(element);
          fevorite_populer.add(false);
        } else if (element.departmentname == "Festival") {
          Festival.add(element);
          fevorite_Festival.add(false);
        } else if (element.departmentname == "Buy 3 Get 60% Off") {
          Discountoffer.add(element);
          fevorite_Tab1.add(false);
        } else if (element.departmentname == "All Under ₹100") {
          Allunder.add(element);
          fevorite_Tab2.add(false);
        } else if (element.departmentname == "Quickship") {
          Quickship.add(element);
          fevorite_Tab3.add(false);
        } else {
        }
      },
    );
    return Future(
      () => null,
    );
  }

  notification() async {
    // FCM/FirebaseMessaging removed during backend migration.
    setState(() {});
  }

  List<ProductModel> alldata = [];

  @override
  void initState() {
    // Placeholder; rebuilt to match the loaded department count below.
    tabController = TabController(length: 1, vsync: this);
    // notification();

    DataGet().then(
      (value) {
        if (homecontoller.userid.isNotEmpty) {
          getuserdata();
        }
        CategoryDataGet().then(
          (value) {
            setState(() {
              CategoryList = value;
            });
          },
        );
        ProductsDepartMentGet().then((value) {
          final newLen = value.isEmpty ? 1 : value.length;
          setState(() {
            department = value;
            // Rebuild the TabController so its length matches the tab count
            // (one tab per department) — avoids the length-mismatch error
            // that was hiding the products section + footer. Requires
            // TickerProviderStateMixin (plural) so a new ticker can be created.
            if (tabController.length != newLen) {
              tabController.dispose();
              tabController = TabController(length: newLen, vsync: this);
            }
          });
        });
        ProductsDataGet().then(
          (value) {
            productList = value;
            setState(() {});
            cartitem();
            datasset(productList).then(
              (value) {
                // alldata = value;
                Future.delayed(
                  Duration(seconds: 0),
                  () {
                    setState(() {
                      homecontoller.isLoader = true;
                    });
                  },
                );
              },
            );
          },
        );
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediaQuery.of(context).size.width > CommonWidget.headerWidth
          ? null
          : CommonWidget().NewHeader(context: context),
      endDrawer: MediaQuery.of(context).size.width > CommonWidget.headerWidth
          ? null
          : CommonWidget().Drowers(context),
      backgroundColor: AppColor.BgColor,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.isMobile(context) ? 0 : 40.0,
            vertical: Responsive.isMobile(context) ? 60 : 40),
        child: InkWell(
          overlayColor: WidgetStatePropertyAll(Colors.white),
          onTap: () {
            whatsapp();
          },
          child: Container(
            height: Responsive.isMobile(context) ? 60 : 75,
            width: Responsive.isMobile(context) ? 60 : 75,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.green),
            child: SvgPicture.asset(
              'assets/image/whatsapplogo.svg',
              height: Responsive.isMobile(context) ? 60 : 75,
              width: Responsive.isMobile(context) ? 60 : 75,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: !homecontoller.isLoader
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColor.BlackColor,
                    ),
                  )
                : false
                    ? Center(
                        child: Text(
                          "No Data Found",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      )
                    : MediaQuery.of(context).size.width <
                            CommonWidget.headerWidth
                        ? SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Specialoffer(),
                                SizedBox(
                                  height: 10,
                                ),
                                IndicatorWidget(),
                                CategotyWidget(),
                                AutoSlideCards(),
                                LuxeEditBanner(),
                                FestivalFashions(),
                                FestivalFashionsListview(),
                                BestSelling(),
                                BestSellingListview(),
                                Discountvauchers(),
                                IndicatorWidgetsec(),
                                if (department.isNotEmpty) ...[
                                  Tabbars(department),
                                  TabbarViews(department),
                                ],
                                Trending(),
                                TrendingListview(),
                                Listoneadd(),
                                // Listtowadd(),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: StickyHeader(
                              header: CommonWidget()
                                  .StickyHeaders(context, Refresh: setState),
                              content: Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Specialoffer(),
                                  IndicatorWidget(),
                                  Categotytitle(),
                                  CategotyWidget(),
                                  AutoSlideCards(),
                                  LuxeEditBanner(),
                                  FestivalFashions(),
                                  FestivalFashionsListview(),
                                  BestSelling(),
                                  BestSellingListview(),
                                  Discountvauchers(),
                                  IndicatorWidgetsec(),
                                  if (department.isNotEmpty) ...[
                                    Tabbars(department),
                                    TabbarViews(department),
                                  ],
                                  Trending(),
                                  TrendingListview(),
                                  Listoneadd(),
                                  // Listtowadd(),

                                  CommonWidget().Footer(context)
                                ],
                              ),
                            ),
                          )),
      ),
    );
  }

  void _openBannerTarget(HomeBanner banner) {
    // Shop Now → browse all products (admin can later point links elsewhere).
    WebAPPNavigation.navigateToroute(
        context: context,
        routename: '/AllProducts',
        screen: AllProductsPage());
  }

  Widget pagewidget({index}) {
    final bool isMobile = Responsive.isMobile(context);
    final HomeBanner banner = index < bannerObjs.length
        ? bannerObjs[index]
        : HomeBanner(imageUrl: BannersList[index]);

    // Pronounced left/right gaps so the banner sits centred with margins.
    final double sideGap = isMobile
        ? 16
        : (MediaQuery.of(context).size.width * 0.12).clamp(90.0, 300.0);
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: sideGap, vertical: isMobile ? 12 : 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 26),
        child: InkWell(
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
          onTap: () => _openBannerTarget(banner),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Banner image
              CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: banner.imageUrl,
                placeholder: (context, url) => Container(
                  color: AppColor.blush,
                  child: Center(
                      child: CircularProgressIndicator(color: AppColor.primary)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColor.blush,
                  child: Center(
                      child: Icon(Icons.image_outlined,
                          color: AppColor.primary, size: 40)),
                ),
              ),

              // Promo overlay (only when admin filled title/subtitle/button)
              if (banner.hasOverlay) ...[
                // Left-to-right dark scrim for text legibility
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Colors.black.withOpacity(0.18),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.45, 0.8],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 18 : 52, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (banner.title.isNotEmpty)
                          ConstrainedBox(
                            constraints:
                                BoxConstraints(maxWidth: isMobile ? 230 : 560),
                            child: Text(
                              banner.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppFont.heading,
                                color: Colors.white,
                                height: 1.05,
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 26 : 52,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        if (banner.subtitle.isNotEmpty) ...[
                          SizedBox(height: isMobile ? 6 : 12),
                          ConstrainedBox(
                            constraints:
                                BoxConstraints(maxWidth: isMobile ? 230 : 460),
                            child: Text(
                              banner.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.92),
                                height: 1.3,
                                fontWeight: FontWeight.w400,
                                fontSize: isMobile ? 12 : 18,
                              ),
                            ),
                          ),
                        ],
                        if (banner.buttonText.isNotEmpty) ...[
                          SizedBox(height: isMobile ? 12 : 22),
                          PressableScale(
                            onTap: () => _openBannerTarget(banner),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 18 : 26,
                                  vertical: isMobile ? 10 : 14),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    banner.buttonText,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: isMobile ? 13 : 16,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: isMobile ? 16 : 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  ProfileWidget() {
    return Container(
      padding: EdgeInsets.only(bottom: 10, left: 20, right: 20, top: 20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3)),
            child: ProfilePicture(
              name: homecontoller.customerid == 0 ||
                      homecontoller.customername == '' ||
                      homecontoller.customername.isEmpty
                  ? "Guest"
                  : homecontoller.customername,
              radius: 20,
              fontsize: 17,
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome,",
                    style: TextStyle(
                      color: AppColor.fontColorgrey,
                    ),
                  ),
                  Text(
                    homecontoller.customerid == 0 ||
                            homecontoller.customername == '' ||
                            homecontoller.customername.isEmpty
                        ? "Guest"
                        : homecontoller.customername,
                    style: TextStyle(
                        color: AppColor.BlackColor,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.white),
            onTap: () {
              WebAPPNavigation.navigateToroute(
                  context: context,
                  routename: '/NotificationPage',
                  screen: NotificationPage());
            },
            child: CircleAvatar(
              backgroundColor: AppColor.whiteColor,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.asset("assets/image/notification.png"),
              ),
            ),
          )
        ],
      ),
    );
  }

  SearchWidget() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        WebAPPNavigation.navigateToroute(
            context: context, routename: '/SearchPage', screen: SearchPage());
      },
      child: Container(
        margin: EdgeInsets.only(right: 12),
        // height: 70,
        // constraints:
        //     BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),

        child: Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: InkWell(
              overlayColor: WidgetStatePropertyAll(Colors.white),
              onTap: () {},
              child: SvgPicture.asset(
                "assets/image/Search Icon.svg",
                width: 25,
                height: 25,
              )),
        ),
      ),
    );
  }

  Specialoffer() {
    return BannersList.isEmpty
        ? SizedBox()
        : Container(
            height: Responsive.isMobile(context)
                ? 200
                : MediaQuery.of(context).size.height * 0.55,
            child: CarouselSlider.builder(
              options: CarouselOptions(
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    offerindex = index;
                  });
                },
                autoPlay: true,
                // Avoids carousel_slider's huge initial page offset (~10000)
                // that trips a Flutter debug precision assertion and blanks the
                // page on web.
                enableInfiniteScroll: false,
                height: Responsive.isMobile(context)
                    ? 200
                    : MediaQuery.of(context).size.height * 0.55,
              ),
              itemCount: BannersList.length,
              itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) {
                offerindex = offerindex;

                return pagewidget(index: itemIndex);
              },
            ),
          );
  }

  Discountvauchers() {
    return BannersList.isEmpty
        ? SizedBox()
        : Container(
            height: Responsive.isMobile(context)
                ? 200
                : MediaQuery.of(context).size.height * 0.55,
            child: CarouselSlider.builder(
              itemCount: BannersList.length,
              options: CarouselOptions(
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    offerindexone = index;
                  });
                },
                autoPlay: true,
                enableInfiniteScroll: false,
                height: Responsive.isMobile(context)
                    ? 200
                    : MediaQuery.of(context).size.height * 0.55,
              ),
              itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) {
                return pagewidget(index: itemIndex);
              },
            ),
          );
  }

  // IndicatorWidget() {
  //   return SmoothPageIndicator(
  //     controller: homecontoller.controller,
  //     count: SpecialofferList.length,
  //     axisDirection: Axis.horizontal,
  //     effect: SlideEffect(
  //       activeDotColor: AppColor.btnColorblack,
  //       dotColor: AppColor.fontColorgrey,
  //       dotHeight: 10,
  //       dotWidth: 10,
  //       spacing: 10,
  //     ),
  //   );
  // }
  // IndicatorWidget() {
  //   return InkWell(
  //     overlayColor: WidgetStatePropertyAll(Colors.white),
  //     onTap: () {},
  //     child: PageViewDotIndicator(
  //         currentItem: offerindex,
  //         count: SpecialofferList.length,
  //         size: Size(8, 8),
  //         unselectedColor: AppColor.BlackColor.withOpacity(0.2),
  //         selectedColor: AppColor.BlackColor),
  //   );
  // }
  IndicatorWidget() {
    return BannersList.isEmpty
        ? SizedBox()
        : InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.white),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: DotsIndicator(
                position: offerindex,
                decorator: DotsDecorator(
                    activeColor: AppColor.btnColorblack,
                    color: AppColor.fontColorgrey),
                dotsCount: BannersList.length,
              ),
            ),
          );
  }

  IndicatorWidgetsec() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: DotsIndicator(
          position: offerindexone,
          decorator: DotsDecorator(
              activeColor: AppColor.btnColorblack,
              color: AppColor.fontColorgrey),
          dotsCount: BannersList.isEmpty ? 2 : BannersList.length,
        ),
      ),
    );
  }

  Widget CategotyWidget() {
    final bool isMobile = Responsive.isMobile(context);
    final double tile = isMobile ? 175 : 240; // square card size
    return CategoryList.isEmpty
        ? SizedBox()
        : Container(
            alignment: Alignment.center,
            height: tile + 62,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 18, vertical: 10),
            child: ListView.builder(
              itemCount: CategoryList.length,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return PressableScale(
                  onTap: () {
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        routename:
                            '/CategoryPage/${CategoryList[index].name.replaceAll(' ', '-')}',
                        data: {'id': CategoryList[index].id},
                        screen: CategoryPage(
                          id: CategoryList[index].id,
                        ));
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: isMobile ? 6 : 10),
                    child: Column(
                      children: [
                        // Light square card holding a ringed circular image
                        Container(
                          height: tile,
                          width: tile,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColor.blush,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Container(
                            height: tile * 0.84,
                            width: tile * 0.84,
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.whiteColor,
                              border: Border.all(
                                  color: AppColor.blushDeep, width: 1.5),
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                imageUrl: CategoryList[index].image,
                                placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                        color: AppColor.primary)),
                                errorWidget: (context, url, error) => Center(
                                    child: Icon(Icons.spa_outlined,
                                        color: AppColor.primary)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: tile + 8,
                          child: Text(
                            "${CategoryList[index].name}",
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                height: 1.2,
                                overflow: TextOverflow.ellipsis,
                                color: AppColor.ink,
                                fontFamily: AppFont.heading,
                                fontSize: isMobile ? 13 : 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  // AJIO-style card content (brand -> title -> discounted pricing) used by
  // all the home product rails.
  Widget _railCardContent(ProductModel p) {
    final offer = p.price - (p.price * (p.salePrice * 0.01));
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: SizedBox(
        width: double.infinity,
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
              Text("₹${offer.toStringAsFixed(0)}",
                  style: TextStyle(
                      color: AppColor.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              if (p.salePrice != 0)
                Text("₹${p.price}",
                    style: TextStyle(
                        color: AppColor.fontColorgrey,
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough)),
              if (p.salePrice != 0)
                Text("(${p.salePrice.toStringAsFixed(0)}% OFF)",
                    style: TextStyle(
                        color: Color(0xff2E8B57),
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
            ],
          ),
          productColorSwatches(p),
        ],
      ),
      ),
    );
  }

  // "Just For You" product carousel — manual swipe (auto-scroll disabled).
  Widget AutoSlideCards() {
    final List<ProductModel> list =
        (alldata.isNotEmpty ? alldata : Trendings).take(10).toList();
    if (list.isEmpty) return SizedBox();
    final double w = MediaQuery.of(context).size.width;
    final double vf = w > 1500
        ? 0.21
        : w > 1100
            ? 0.26
            : w > 700
                ? 0.34
                : 0.55;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Just For You", () {
          WebAPPNavigation.navigateToroute(
              context: context,
              routename: '/AllProducts',
              screen: AllProductsPage());
        }),
        CarouselSlider.builder(
          itemCount: list.length,
          options: CarouselOptions(
            height: Responsive.isMobile(context) ? 320 : 420,
            viewportFraction: vf,
            autoPlay: false, // stopped auto-scrolling — manual swipe only
            enableInfiniteScroll: false,
            enlargeCenterPage: false,
            padEnds: false,
            scrollPhysics: const BouncingScrollPhysics(),
          ),
          itemBuilder: (context, index, real) => _autoCard(list[index], index, list),
        ),
      ],
    );
  }

  Widget _autoCard(ProductModel p, int index, List<ProductModel> list) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        onTap: () {
          WebAPPNavigation.navigateToroute(
            context: context,
            routename:
                '/ProductDetailScreen/${p.id}',
            data: {
              'index': index,
              'productModelList': list,
              'productModel': p,
              'productName': p.title
            },
            screen: ProductDetailScreen(
                index: index,
                productModelList: list,
                productModel: p,
                title: p.title),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(14),
            border: Appborder.appborder,
            boxShadow: Appshadow.soft,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: AppColor.blush,
                  child: CachedNetworkImage(
                    imageUrl: p.thumbnail,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColor.primary)),
                    errorWidget: (c, u, e) => Center(
                        child: Icon(Icons.checkroom_outlined,
                            color: AppColor.primary)),
                  ),
                ),
              ),
              _railCardContent(p),
            ],
          ),
        ),
      ),
    );
  }

  // Centered section header: the title sits in the MIDDLE of the page while
  // the "View All" action stays pinned to the right edge.
  Widget _sectionHeader(String title, VoidCallback onViewAll) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: AppFont.heading,
                  color: AppColor.ink,
                  letterSpacing: 0.2,
                  fontSize: Responsive.isMobile(context) ? 20 : 26,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              overlayColor: WidgetStatePropertyAll(Colors.white),
              onTap: onViewAll,
              child: Text(
                "View All",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 14 : 18,
                    fontWeight: FontWeight.w500,
                    color: AppColor.viewallcolor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget FestivalFashions() {
    return Festival.isEmpty
        ? SizedBox()
        : _sectionHeader("Festival Fashions", () {
            WebAPPNavigation.navigateToroute(
                context: context,
                routename: '/ViewAll',
                data: {'visitlist': Festival},
                screen: ViewAll(visitlist: Festival));
          });
  }

  Categotytitle() {
    return _sectionHeader("Shop by Category", () {
      WebAPPNavigation.navigateToroute(
          context: context,
          routename: '/CategoryViewallPage',
          data: {'visitlist': CategoryList},
          screen: CategoryViewallPage(visitlist: CategoryList));
    });
  }

  Trending() {
    return _sectionHeader("Trending Now", () {
      WebAPPNavigation.navigateToroute(
          context: context,
          routename: '/ViewAll',
          data: {'visitlist': Trendings},
          screen: ViewAll(visitlist: Trendings));
    });
  }

  BestSelling() {
    return Bestselling.isEmpty
        ? SizedBox()
        : _sectionHeader("Best Selling", () {
            WebAPPNavigation.navigateToroute(
                context: context,
                routename: '/ViewAll',
                data: {'visitlist': Bestselling},
                screen: ViewAll(visitlist: Bestselling));
          });
  }

  List<bool> fevorite_Festival = [];
  List<bool> fevorite_Best_selling = [];
  List<bool> fevorite_Tab1 = [];
  List<bool> fevorite_Tab2 = [];
  List<bool> fevorite_Tab3 = [];
  List<bool> fevorite_trending = [];
  List<bool> fevorite_populer = [];

  FestivalFashionsListview() {
    return Festival.isEmpty
        ? Container(
            height: Responsive.isMobile(context) ? 300 : 430,
            width: MediaQuery.of(context).size.width,
            child: Center(
                child: Text(
              "No Data Found",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            )))
        : Container(
            height: Responsive.isMobile(context) ? 300 : 430,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              itemCount: Festival.length <= 6 ? Festival.length : 6,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                homecontoller.wishlist.asMap().forEach(
                  (listindex, element) {
                    if (element.productid == Festival[index].id) {
                      // print("Festival = =  ${Festival[index].id}");

                      fevorite_Festival[index] = true;
                    }
                  },
                );
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.isMobile(context) ? 6.0 : 15.0,
                      vertical: 8),
                  child: HoverLift(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      WebAPPNavigation.navigateToroute(
                          context: context,
                          routename:
                              '/ProductDetailScreen/${Festival[index].id}',
                          data: {
                            'index': index,
                            'productModelList': Festival,
                            'productModel': Festival[index],
                            'productName': Festival[index].title
                          },
                          screen: ProductDetailScreen(
                            index: index,
                            productModelList: Festival,
                            productModel: Festival[index],
                            title: Festival[index].title,
                          ));
                    },
                    child: Container(
                      width: Responsive.isMobile(context) ? 180 : 300,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          color: AppColor.whiteColor,
                          border: Appborder.appborder,
                          boxShadow: [Appshadow.shadow],
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: EdgeInsets.zero,
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
                                                  fit: BoxFit.cover)),
                                        );
                                      },
                                      imageUrl: Festival[index].thumbnail,
                                      placeholder: (context, url) => Center(
                                              child: CircularProgressIndicator(
                                            color: AppColor.BlackColor,
                                          )),
                                      errorWidget: (context, url, error) {
                                        // print("errror :: ${error}");
                                        return Icon(Icons.error);
                                      }),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      overlayColor:
                                          WidgetStatePropertyAll(Colors.white),
                                      onTap: () {
                                        int removeindex = 0;
                                        if (fevorite_Festival[index] == true) {
                                          homecontoller.wishlist.removeWhere(
                                              (element) =>
                                                  element.productid ==
                                                  Festival[index].id);
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
                                              fevorite_Festival[index] = false;
                                              cartitem();
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
                                                        userid: homecontoller
                                                            .userid,
                                                        wishitems: [
                                                      Wishitems(
                                                        brandname:
                                                            Festival[index]
                                                                .brand!
                                                                .name,
                                                        image: Festival[index]
                                                            .thumbnail,
                                                        price: Festival[index]
                                                            .price
                                                            .toString(),
                                                        saleprice: (Festival[
                                                                        index]
                                                                    .price -
                                                                (Festival[index]
                                                                        .price *
                                                                    (Festival[index]
                                                                            .salePrice *
                                                                        0.01)))
                                                            .toString(),
                                                        productid:
                                                            Festival[index].id,
                                                        productname:
                                                            Festival[index]
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
                                                  brandname: Festival[index]
                                                      .brand!
                                                      .name,
                                                  image:
                                                      Festival[index].thumbnail,
                                                  price: Festival[index]
                                                      .price
                                                      .toString(),
                                                  // saleprice: Festival[index]
                                                  //     .salePrice
                                                  //     .toString(),
                                                  saleprice: (Festival[index]
                                                              .price -
                                                          (Festival[index]
                                                                  .price *
                                                              (Festival[index]
                                                                      .salePrice *
                                                                  0.01)))
                                                      .toString(),
                                                  productid: Festival[index].id,
                                                  productname:
                                                      Festival[index].title,
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
                                            });
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
                                                      brandname: Festival[index]
                                                          .brand!
                                                          .name,
                                                      image: Festival[index]
                                                          .thumbnail,
                                                      price: Festival[index]
                                                          .price
                                                          .toString(),
                                                      saleprice: (Festival[
                                                                      index]
                                                                  .price -
                                                              (Festival[index]
                                                                      .price *
                                                                  (Festival[index]
                                                                          .salePrice *
                                                                      0.01)))
                                                          .toString(),
                                                      productid:
                                                          Festival[index].id,
                                                      productname:
                                                          Festival[index].title,
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
                                                    Festival[index].brand!.name,
                                                image:
                                                    Festival[index].thumbnail,
                                                price: Festival[index]
                                                    .price
                                                    .toString(),
                                                // saleprice: Festival[index]
                                                //     .salePrice
                                                //     .toString(),
                                                saleprice: (Festival[index]
                                                            .price -
                                                        (Festival[index].price *
                                                            (Festival[index]
                                                                    .salePrice *
                                                                0.01)))
                                                    .toString(),
                                                productid: Festival[index].id,
                                                productname:
                                                    Festival[index].title,
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
                                          child: fevorite_Festival[index]
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
                            _railCardContent(Festival[index]),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

  Widget Listoneadd() {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.width < 600 ? 20 : 60.0),
      child: Column(
        children: [NewlistWidget(), NewListview()],
      ),
    );
  }

  NewlistWidget() {
    return Populer.isEmpty
        ? SizedBox()
        : _sectionHeader("Popular", () {
            WebAPPNavigation.navigateToroute(
                context: context,
                data: {'visitlist': Populer},
                routename: '/ViewAll',
                screen: ViewAll(visitlist: Populer));
          });
  }

  NewListview() {
    return false
        ? SizedBox()
        : Container(
            height: Responsive.isMobile(context) ? 300 : 430,
            width: MediaQuery.of(context).size.width,
            child:
                // homecontoller.isLoaderintrested
                //     ? Center(
                //         child: CircularProgressIndicator(
                //           color: AppColor.BlackColor,
                //         ),
                //       )
                //     :

                ListView.builder(
              itemCount: Populer.length <= 6 ? Populer.length : 6,
              shrinkWrap: true,
              // padding: EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                // List<bool> fevorite = List.generate(
                //   Populer.length,
                //   (index) => false,
                // );
                homecontoller.wishlist.asMap().forEach(
                  (listindex, element) {
                    if (element.productid == Populer[index].id) {
                      fevorite_populer[index] = true;
                    }
                  },
                );
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.isMobile(context) ? 6.0 : 15.0,
                      vertical: 8),
                  child: HoverLift(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      WebAPPNavigation.navigateToroute(
                          context: context,
                          data: {
                            'index': index,
                            'productModelList': Populer,
                            'productModel': Populer[index],
                            'productName': Populer[index].title
                          },
                          routename:
                              '/ProductDetailScreen/${Populer[index].id}',
                          screen: ProductDetailScreen(
                            index: index,
                            productModelList: Populer,
                            productModel: Populer[index],
                            title: Populer[index].title,
                          ));
                    },
                    child: Container(
                      width: Responsive.isMobile(context) ? 180 : 300,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          color: AppColor.whiteColor,
                          border: Appborder.appborder,
                          boxShadow: [Appshadow.shadow],
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: EdgeInsets.zero,
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
                                                fit: BoxFit.cover)),
                                      );
                                    },
                                    imageUrl: Populer[index].thumbnail,
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
                                        if (fevorite_populer[index] == true) {
                                          homecontoller.wishlist.removeWhere(
                                              (element) =>
                                                  element.productid ==
                                                  Populer[index].id);
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
                                              fevorite_populer[index] = false;
                                              cartitem();
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
                                                        userid: homecontoller
                                                            .userid,
                                                        wishitems: [
                                                      Wishitems(
                                                        brandname:
                                                            Populer[index]
                                                                .brand!
                                                                .name,
                                                        image: Populer[index]
                                                            .thumbnail,
                                                        price: Populer[index]
                                                            .price
                                                            .toString(),
                                                        // saleprice: Populer[index]
                                                        //     .salePrice
                                                        //     .toString(),
                                                        saleprice: (Populer[
                                                                        index]
                                                                    .price -
                                                                (Populer[index]
                                                                        .price *
                                                                    (Populer[index]
                                                                            .salePrice *
                                                                        0.01)))
                                                            .toString(),
                                                        productid:
                                                            Populer[index].id,
                                                        productname:
                                                            Populer[index]
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
                                                  brandname: Populer[index]
                                                      .brand!
                                                      .name,
                                                  image:
                                                      Populer[index].thumbnail,
                                                  price: Populer[index]
                                                      .price
                                                      .toString(),
                                                  // saleprice: Populer[index]
                                                  //     .salePrice
                                                  //     .toString(),
                                                  saleprice: (Populer[index]
                                                              .price -
                                                          (Populer[index]
                                                                  .price *
                                                              (Populer[index]
                                                                      .salePrice *
                                                                  0.01)))
                                                      .toString(),
                                                  productid: Populer[index].id,
                                                  productname:
                                                      Populer[index].title,
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
                                            });
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
                                                      brandname: Populer[index]
                                                          .brand!
                                                          .name,
                                                      image: Populer[index]
                                                          .thumbnail,
                                                      price: Populer[index]
                                                          .price
                                                          .toString(),
                                                      // saleprice: Populer[index]
                                                      //     .salePrice
                                                      //     .toString(),
                                                      saleprice: (Populer[index]
                                                                  .price -
                                                              (Populer[index]
                                                                      .price *
                                                                  (Populer[index]
                                                                          .salePrice *
                                                                      0.01)))
                                                          .toString(),
                                                      productid:
                                                          Populer[index].id,
                                                      productname:
                                                          Populer[index].title,
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
                                                    Populer[index].brand!.name,
                                                image: Populer[index].thumbnail,
                                                price: Populer[index]
                                                    .price
                                                    .toString(),
                                                // saleprice: Populer[index]
                                                //     .salePrice
                                                //     .toString(),
                                                saleprice: (Populer[index]
                                                            .price -
                                                        (Populer[index].price *
                                                            (Populer[index]
                                                                    .salePrice *
                                                                0.01)))
                                                    .toString(),
                                                productid: Populer[index].id,
                                                productname:
                                                    Populer[index].title,
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
                                          child: fevorite_populer[index]
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
                            _railCardContent(Populer[index]),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

  Widget Listtowadd() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [NewlistsecWidget(), NewListsecview()],
      ),
    );
  }

  NewlistsecWidget() {
    return false
        ? SizedBox()
        : Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Best Selling",
                  style: TextStyle(
                      fontFamily: AppFont.heading,
                      color: AppColor.ink,
                      letterSpacing: 0.2,
                      fontSize: Responsive.isMobile(context) ? 20 : 26,
                      fontWeight: FontWeight.w600),
                ),
                InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  onTap: () {
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        routename: '/ViewAll',
                        data: {'visitlist': Bestselling},
                        screen: ViewAll(
                          visitlist: Bestselling,
                        ));
                  },
                  child: Text(
                    "View All",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 18,
                        color: AppColor.viewallcolor),
                  ),
                )
              ],
            ),
          );
  }

  NewListsecview() {
    return false
        ? SizedBox()
        : Container(
            height: Responsive.isMobile(context) ? 300 : 430,
            width: MediaQuery.of(context).size.width,
            child:

                //  homecontoller.isLoaderintrested
                //     ? Center(
                //         child: CircularProgressIndicator(
                //           color: AppColor.BlackColor,
                //         ),
                //       )
                //     :

                ListView.builder(
              itemCount: 6,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.isMobile(context) ? 6.0 : 15.0,
                      vertical: 8),
                  child: InkWell(
                    overlayColor: WidgetStatePropertyAll(Colors.white),
                    onTap: () {},
                    child: Container(
                      width: Responsive.isMobile(context) ? 180 : 300,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          color: AppColor.whiteColor,
                          border: Appborder.appborder,
                          boxShadow: [Appshadow.shadow],
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Flexible(
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
                                                fit: BoxFit.cover)),
                                      );
                                    },
                                    imageUrl:
                                        "https://eatanytime.in/cdn/shop/products/AllinOneProteinBalls-ProteinHouse_a7ea0956-e0b2-4717-8768-4cd8c549b9fd-399401.png?v=1704714089&width=533https://eatanytime.in/cdn/shop/products/AllinOneProteinBalls-ProteinHouse_a7ea0956-e0b2-4717-8768-4cd8c549b9fd-399401.png?v=1704714089&width=533",
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              "TITLE",
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
                                              "Furniture",
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
                                      Container(
                                        child: Text(
                                          "₹ 500.00",
                                          style: TextStyle(
                                              color: AppColor.viewallcolor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
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
                                        : 290,
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
              },
            ),
          );
  }

  BestSellingListview() {
    return Bestselling.isEmpty
        ? Container(
            height: Responsive.isMobile(context) ? 300 : 430,
            width: MediaQuery.of(context).size.width,
            child: Center(
                child: Text(
              "No Data Found",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            )))
        : Container(
            height: Responsive.isMobile(context) ? 300 : 430,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(bottom: 20),
            child:
                //  homecontoller.isLoaderintrested
                //     ? Center(
                //         child: CircularProgressIndicator(
                //           color: AppColor.BlackColor,
                //         ),
                //       )
                //     :
                ListView.builder(
              itemCount: Bestselling.length <= 6 ? Bestselling.length : 6,
              shrinkWrap: true,
              // padding: EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                // List<bool> fevorite = List.generate(
                //   Bestselling.length,
                //   (index) => false,
                // );
                homecontoller.wishlist.asMap().forEach(
                  (listindex, element) {
                    if (element.productid == Bestselling[index].id) {
                      fevorite_Best_selling[index] = true;
                    }
                  },
                );
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.isMobile(context) ? 6.0 : 15.0,
                      vertical: 8),
                  child: InkWell(
                    overlayColor: WidgetStatePropertyAll(Colors.white),
                    onTap: () {
                      WebAPPNavigation.navigateToroute(
                          context: context,
                          routename:
                              '/ProductDetailScreen/${Bestselling[index].id}',
                          data: {
                            'index': index,
                            'productModelList': Bestselling,
                            'productModel': Bestselling[index],
                            'productName': Bestselling[index].title
                          },
                          screen: ProductDetailScreen(
                              index: index,
                              productModelList: Bestselling,
                              productModel: Bestselling[index],
                              title: Bestselling[index].title));

                    },
                    child: Container(
                      width: Responsive.isMobile(context) ? 180 : 300,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          color: AppColor.whiteColor,
                          border: Appborder.appborder,
                          boxShadow: [Appshadow.shadow],
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: EdgeInsets.zero,
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
                                                fit: BoxFit.cover)),
                                      );
                                    },
                                    imageUrl: Bestselling[index].thumbnail,
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
                                        if (fevorite_Best_selling[index] ==
                                            true) {
                                          homecontoller.wishlist.removeWhere(
                                              (element) =>
                                                  element.productid ==
                                                  Bestselling[index].id);
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
                                              fevorite_Best_selling[index] =
                                                  false;
                                              cartitem();
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
                                                        userid: homecontoller
                                                            .userid,
                                                        wishitems: [
                                                      Wishitems(
                                                        brandname:
                                                            Bestselling[index]
                                                                .brand!
                                                                .name,
                                                        image:
                                                            Bestselling[index]
                                                                .thumbnail,
                                                        price:
                                                            Bestselling[index]
                                                                .price
                                                                .toString(),
                                                        // saleprice:
                                                        //     Bestselling[index]
                                                        //         .salePrice
                                                        //         .toString(),
                                                        saleprice: (Bestselling[
                                                                        index]
                                                                    .price -
                                                                (Bestselling[
                                                                            index]
                                                                        .price *
                                                                    (Bestselling[index]
                                                                            .salePrice *
                                                                        0.01)))
                                                            .toString(),
                                                        productid:
                                                            Bestselling[index]
                                                                .id,
                                                        productname:
                                                            Bestselling[index]
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
                                                  brandname: Bestselling[index]
                                                      .brand!
                                                      .name,
                                                  image: Bestselling[index]
                                                      .thumbnail,
                                                  price: Bestselling[index]
                                                      .price
                                                      .toString(),
                                                  // saleprice: Bestselling[index]
                                                  //     .salePrice
                                                  //     .toString(),
                                                  saleprice: (Bestselling[index]
                                                              .price -
                                                          (Bestselling[index]
                                                                  .price *
                                                              (Bestselling[
                                                                          index]
                                                                      .salePrice *
                                                                  0.01)))
                                                      .toString(),
                                                  productid:
                                                      Bestselling[index].id,
                                                  productname:
                                                      Bestselling[index].title,
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
                                            });
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
                                                          Bestselling[index]
                                                              .brand!
                                                              .name,
                                                      image: Bestselling[index]
                                                          .thumbnail,
                                                      price: Bestselling[index]
                                                          .price
                                                          .toString(),
                                                      // saleprice:
                                                      //     Bestselling[index]
                                                      //         .salePrice
                                                      //         .toString(),
                                                      saleprice: (Bestselling[
                                                                      index]
                                                                  .price -
                                                              (Bestselling[
                                                                          index]
                                                                      .price *
                                                                  (Bestselling[
                                                                              index]
                                                                          .salePrice *
                                                                      0.01)))
                                                          .toString(),
                                                      productid:
                                                          Bestselling[index].id,
                                                      productname:
                                                          Bestselling[index]
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
                                                brandname: Bestselling[index]
                                                    .brand!
                                                    .name,
                                                image: Bestselling[index]
                                                    .thumbnail,
                                                price: Bestselling[index]
                                                    .price
                                                    .toString(),
                                                // saleprice: Bestselling[index]
                                                //     .salePrice
                                                //     .toString(),
                                                saleprice: (Bestselling[index]
                                                            .price -
                                                        (Bestselling[index]
                                                                .price *
                                                            (Bestselling[index]
                                                                    .salePrice *
                                                                0.01)))
                                                    .toString(),
                                                productid:
                                                    Bestselling[index].id,
                                                productname:
                                                    Bestselling[index].title,
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
                                          child: fevorite_Best_selling[index]
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
                            _railCardContent(Bestselling[index]),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

  TrendingListview() {
    return Trendings.isEmpty
        ? Container(
            height: Responsive.isMobile(context) ? 300 : 430,
            width: MediaQuery.of(context).size.width,
            child: Center(
                child: Text(
              "No Data Found",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            )))
        : Container(
            height: Responsive.isMobile(context) ? 300 : 430,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(
              bottom: 20,
            ),
            child: ListView.builder(
              itemCount: Trendings.length <= 6 ? Trendings.length : 6,
              // padding: EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                // List<bool> fevorite = List.generate(
                //   Trendings.length,
                //   (index) => false,
                // );
                homecontoller.wishlist.asMap().forEach(
                  (listindex, element) {
                    if (element.productid == Trendings[index].id) {
                      fevorite_trending[index] = true;
                    }
                  },
                );
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.isMobile(context) ? 6.0 : 15.0,
                      vertical: 8),
                  child: InkWell(
                    overlayColor: WidgetStatePropertyAll(Colors.white),
                    onTap: () {
                      WebAPPNavigation.navigateToroute(
                          context: context,
                          routename:
                              '/ProductDetailScreen/${Trendings[index].id}',
                          data: {
                            'index': index,
                            'productModelList': Trendings,
                            'productModel': Trendings[index],
                            'productName': Trendings[index].title
                          },
                          screen: ProductDetailScreen(
                            index: index,
                            productModel: Trendings[index],
                            productModelList: Trendings,
                            title: Trendings[index].title,
                          ));
                    },
                    child: Container(
                      width: Responsive.isMobile(context) ? 180 : 300,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          color: AppColor.whiteColor,
                          border: Appborder.appborder,
                          boxShadow: [Appshadow.shadow],
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: EdgeInsets.zero,
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
                                                fit: BoxFit.cover)),
                                      );
                                    },
                                    imageUrl: Trendings[index].thumbnail,
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
                                        if (fevorite_trending[index] == true) {
                                          homecontoller.wishlist.removeWhere(
                                              (element) =>
                                                  element.productid ==
                                                  Trendings[index].id);
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
                                              fevorite_trending[index] = false;
                                              cartitem();
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
                                                        userid: homecontoller
                                                            .userid,
                                                        wishitems: [
                                                      Wishitems(
                                                        brandname:
                                                            Trendings[index]
                                                                .brand!
                                                                .name,
                                                        image: Trendings[index]
                                                            .thumbnail,
                                                        price: Trendings[index]
                                                            .price
                                                            .toString(),
                                                        // saleprice:
                                                        //     Trendings[index]
                                                        //         .salePrice
                                                        //         .toString(),
                                                        saleprice: (Trendings[
                                                                        index]
                                                                    .price -
                                                                (Trendings[index]
                                                                        .price *
                                                                    (Trendings[index]
                                                                            .salePrice *
                                                                        0.01)))
                                                            .toString(),
                                                        productid:
                                                            Trendings[index].id,
                                                        productname:
                                                            Trendings[index]
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
                                                  brandname: Trendings[index]
                                                      .brand!
                                                      .name,
                                                  image: Trendings[index]
                                                      .thumbnail,
                                                  price: Trendings[index]
                                                      .price
                                                      .toString(),
                                                  saleprice: (Trendings[index]
                                                              .price -
                                                          (Trendings[index]
                                                                  .price *
                                                              (Trendings[index]
                                                                      .salePrice *
                                                                  0.01)))
                                                      .toString(),
                                                  productid:
                                                      Trendings[index].id,
                                                  productname:
                                                      Trendings[index].title,
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
                                            });
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
                                                          Trendings[index]
                                                              .brand!
                                                              .name,
                                                      image: Trendings[index]
                                                          .thumbnail,
                                                      price: Trendings[index]
                                                          .price
                                                          .toString(),
                                                      saleprice: (Trendings[
                                                                      index]
                                                                  .price -
                                                              (Trendings[index]
                                                                      .price *
                                                                  (Trendings[index]
                                                                          .salePrice *
                                                                      0.01)))
                                                          .toString(),
                                                      productid:
                                                          Trendings[index].id,
                                                      productname:
                                                          Trendings[index]
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
                                                brandname: Trendings[index]
                                                    .brand!
                                                    .name,
                                                image:
                                                    Trendings[index].thumbnail,
                                                price: Trendings[index]
                                                    .price
                                                    .toString(),
                                                saleprice: (Trendings[index]
                                                            .price -
                                                        (Trendings[index]
                                                                .price *
                                                            (Trendings[index]
                                                                    .salePrice *
                                                                0.01)))
                                                    .toString(),
                                                productid: Trendings[index].id,
                                                productname:
                                                    Trendings[index].title,
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
                                        child: fevorite_trending[index]
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
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _railCardContent(Trendings[index]),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

  Widget TabviewListview(
      List<ProductModel> productmodel, List<bool> fevorite_Tab) {
    return Obx(() {
      return isdpL.value
          ? SizedBox(
              height: Responsive.isMobile(context) ? 300 : 450,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColor.BlackColor,
                ),
              ),
            )
          : productmodel.isEmpty
              ? Container(
                  height: Responsive.isMobile(context) ? 300 : 430,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: Text(
                    "No Data Found",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  )))
              : Container(
                  height: Responsive.isMobile(context) ? 300 : 430,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 20),
                  child:

                      // homecontoller.isLoaderintrested
                      //     ? Center(
                      //         child: CircularProgressIndicator(
                      //           color: AppColor.BlackColor,
                      //         ),
                      //       )
                      //     :
                      ListView.builder(
                    itemCount:
                        productmodel.length <= 6 ? productmodel.length : 6,
                    // padding: EdgeInsets.symmetric(horizontal: 10),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      homecontoller.wishlist.asMap().forEach(
                        (listindex, element) {
                          if (element.productid == productmodel[index].id) {
                            // fevorite_Best_selling[index] = false;
                            fevorite_Tab[index] = true;
                          }
                        },
                      );
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                Responsive.isMobile(context) ? 6.0 : 15.0,
                            vertical: 8),
                        child: InkWell(
                          overlayColor: WidgetStatePropertyAll(Colors.white),
                          onTap: () {
                            WebAPPNavigation.navigateToroute(
                                context: context,
                                data: {
                                  'index': index,
                                  'productModelList': productmodel,
                                  'productModel': productmodel[index],
                                  'productName': productmodel[index].title
                                },
                                routename:
                                    '/ProductDetailScreen/${productmodel[index].id}',
                                screen: ProductDetailScreen(
                                  index: index,
                                  productModel: productmodel[index],
                                  productModelList: productmodel,
                                  title: productmodel[index].title,
                                ));
                          },
                          child: Container(
                            width: Responsive.isMobile(context) ? 180 : 300,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                                color: AppColor.whiteColor,
                                border: Appborder.appborder,
                                boxShadow: [Appshadow.shadow],
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageBuilder:
                                              (context, imageProvider) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover)),
                                            );
                                          },
                                          imageUrl:
                                              productmodel[index].thumbnail,
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
                                                WidgetStatePropertyAll(
                                                    Colors.white),
                                            onTap: () {
                                              if (fevorite_Tab[index] == true) {
                                                homecontoller.wishlist
                                                    .removeWhere((element) =>
                                                        element.productid ==
                                                        productmodel[index].id);
                                                removetowishlist(
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
                                                    fevorite_Tab[index] = false;
                                                    cartitem();
                                                  },
                                                );
                                              } else {
                                                print(
                                                    'SPcheck ${homecontoller.wishlistid}');
                                                if (homecontoller
                                                    .userid.isEmpty) {
                                                  LoginDialog.showLoginDialog(
                                                      context, () {
                                                    if (homecontoller
                                                                .wishlistid ==
                                                            '' ||
                                                        homecontoller.wishlistid
                                                            .isEmpty) {
                                                      Addtowishlist(
                                                          FirebasewishlistModel(
                                                              userid:
                                                                  homecontoller
                                                                      .userid,
                                                              wishitems: [
                                                            Wishitems(
                                                              brandname:
                                                                  productmodel[
                                                                          index]
                                                                      .brand!
                                                                      .name,
                                                              image:
                                                                  productmodel[
                                                                          index]
                                                                      .thumbnail,
                                                              price: productmodel[
                                                                      index]
                                                                  .price
                                                                  .toString(),
                                                              // saleprice:
                                                              //     productmodel[index]
                                                              //         .salePrice
                                                              //         .toString(),
                                                              saleprice: (productmodel[
                                                                              index]
                                                                          .price -
                                                                      (productmodel[index]
                                                                              .price *
                                                                          (productmodel[index].salePrice *
                                                                              0.01)))
                                                                  .toString(),
                                                              productid:
                                                                  productmodel[
                                                                          index]
                                                                      .id,
                                                              productname:
                                                                  productmodel[
                                                                          index]
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
                                                            productmodel[index]
                                                                .brand!
                                                                .name,
                                                        image:
                                                            productmodel[index]
                                                                .thumbnail,
                                                        price:
                                                            productmodel[index]
                                                                .price
                                                                .toString(),
                                                        // saleprice: productmodel[index]
                                                        //     .salePrice
                                                        //     .toString(),
                                                        saleprice: (productmodel[
                                                                        index]
                                                                    .price -
                                                                (productmodel[
                                                                            index]
                                                                        .price *
                                                                    (productmodel[index]
                                                                            .salePrice *
                                                                        0.01)))
                                                            .toString(),
                                                        productid:
                                                            productmodel[index]
                                                                .id,
                                                        productname:
                                                            productmodel[index]
                                                                .title,
                                                      ));
                                                      setState(() {});
                                                      updatetowishlist(FirebasewishlistModel(
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
                                                  });
                                                } else {
                                                  if (homecontoller
                                                              .wishlistid ==
                                                          '' ||
                                                      homecontoller
                                                          .wishlistid.isEmpty) {
                                                    Addtowishlist(
                                                        FirebasewishlistModel(
                                                            userid:
                                                                homecontoller
                                                                    .userid,
                                                            wishitems: [
                                                          Wishitems(
                                                            brandname:
                                                                productmodel[
                                                                        index]
                                                                    .brand!
                                                                    .name,
                                                            image: productmodel[
                                                                    index]
                                                                .thumbnail,
                                                            price: productmodel[
                                                                    index]
                                                                .price
                                                                .toString(),
                                                            // saleprice:
                                                            //     productmodel[index]
                                                            //         .salePrice
                                                            //         .toString(),
                                                            saleprice: (productmodel[
                                                                            index]
                                                                        .price -
                                                                    (productmodel[index]
                                                                            .price *
                                                                        (productmodel[index].salePrice *
                                                                            0.01)))
                                                                .toString(),
                                                            productid:
                                                                productmodel[
                                                                        index]
                                                                    .id,
                                                            productname:
                                                                productmodel[
                                                                        index]
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
                                                          productmodel[index]
                                                              .brand!
                                                              .name,
                                                      image: productmodel[index]
                                                          .thumbnail,
                                                      price: productmodel[index]
                                                          .price
                                                          .toString(),
                                                      // saleprice: productmodel[index]
                                                      //     .salePrice
                                                      //     .toString(),
                                                      saleprice: (productmodel[
                                                                      index]
                                                                  .price -
                                                              (productmodel[
                                                                          index]
                                                                      .price *
                                                                  (productmodel[
                                                                              index]
                                                                          .salePrice *
                                                                      0.01)))
                                                          .toString(),
                                                      productid:
                                                          productmodel[index]
                                                              .id,
                                                      productname:
                                                          productmodel[index]
                                                              .title,
                                                    ));
                                                    setState(() {});
                                                    updatetowishlist(FirebasewishlistModel(
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
                                                }
                                              }
                                            },
                                            child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: fevorite_Tab[index]
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
                                                      )

                                                //  Image.asset(
                                                //   AppImage.appIcon + 'health.png',
                                                //   color: Colors.black,
                                                //   height: 30,
                                                //   width: 30,
                                                //   // color: AppColor.redcolor,
                                                // ),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _railCardContent(productmodel[index]),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
    });
  }

  Widget StickyHeaders() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        boxShadow: kElevationToShadow[2],
        color: AppColor.whiteColor,
      ),
      // margin: EdgeInsets.symmetric(
      //     horizontal: MediaQuery.of(context).size.width * 0.15),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 5),
                    constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width * 0.08,
                        maxHeight: 90),
                    child: SvgPicture.asset(
                      "assets/image/app_logos.svg",
                      height: 90,
                    )),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    "Home",
                    style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width < 550 ? 14 : 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  height: 50,
                  width: 130,
                  child: Padding(
                    padding: EdgeInsets.only(right: 12.0, top: 2),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        focusColor: AppColor.BgColor,
                        dropdownColor: AppColor.BgColor,
                        onTap: () {},
                        onChanged: (value) {
                          categoryvalue = value as String;
                          categoryvalue = categoryvalue;
                          setState(() {});
                        },
                        value: categoryvalue,
                        isExpanded: true,
                        alignment: Alignment.center,
                        hint: Text("Categories"),
                        items: categorylsit
                            ?.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            alignment: Alignment.centerRight,
                            value: value,
                            // enabled: false,
                            child: Text(
                              "${value.toString()}",
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 550
                                          ? 14
                                          : 18,
                                  color: AppColor.BlackColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    "About Us",
                    style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width < 550 ? 14 : 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  "Contact Us",
                  style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 550 ? 14 : 18,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          SearchWidget(),
          functiond(),
        ],
      ),
    );
  }

  String categoryvalue = "Categories";
  List<String>? categorylsit = ["Categories", "Shoes", "Women"];
  Widget functiond() {
    return Row(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            // color: AppColor.BgColor,
            padding: EdgeInsets.only(right: 12),
            child: Container(
              constraints: BoxConstraints(minWidth: 25, maxHeight: 25),
              child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SvgPicture.asset(
                    "assets/image/heart.svg",
                    width: 25,
                    height: 25,
                  )
                  //  Image.asset(
                  //   "assets/image/cart.png",
                  //   height: 20,
                  //   width: 20,
                  //   color: AppColor.BlackColor,
                  // ),
                  ),
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            // color: AppColor.BgColor,
            padding: EdgeInsets.only(right: 12),
            child: Container(
              constraints: BoxConstraints(minWidth: 25, maxHeight: 25),
              child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SvgPicture.asset(
                    "assets/image/Cart icon.svg",
                    width: 25,
                    height: 25,
                  )
                  //  Image.asset(
                  //   "assets/image/cart.png",
                  //   height: 20,
                  //   width: 20,
                  //   color: AppColor.BlackColor,
                  // ),
                  ),
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            // color: AppColor.BgColor,
            padding: EdgeInsets.only(right: 12),
            child: Container(
              constraints: BoxConstraints(minWidth: 25, maxHeight: 25),
              child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: SvgPicture.asset(
                    "assets/image/bell.svg",
                    width: 25,
                    height: 25,
                  )),
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            // color: AppColor.BgColor,
            padding: EdgeInsets.only(right: 10),
            child: Container(
              // constraints: BoxConstraints(minWidth: 25, maxHeight: 25),
              child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SvgPicture.asset(
                    "assets/image/profile.svg",
                    width: 35,
                    height: 35,
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Widget Footer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: AppColor.BlackColor,
      child: Column(
        children: [
          Service(),
          Explore(),
          Policies(),
          Divider(
            color: AppColor.whiteColor,
            thickness: 1,
          ),
          Container(
              margin: EdgeInsets.symmetric(
                vertical: 5,
              ),
              child: Text(
                "© NameAPP by iNiLabs 2024, All Rights Reserved",
                style: TextStyle(color: AppColor.whiteColor),
              )),
        ],
      ),
    );
  }

  Widget Support() {
    return Container(
        width: MediaQuery.of(context).size.width * 0.13,
        child: Container(
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  "Support",
                  style: TextStyle(
                      color: AppColor.whiteColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 22),
                ),
              ),
              ListTile(
                title: Text(
                  "Return & Exchange",
                  style: TextStyle(color: AppColor.whiteColor, fontSize: 14),
                ),
              ),
              ListTile(
                title: Text(
                  "Size Charts",
                  style: TextStyle(color: AppColor.whiteColor, fontSize: 14),
                ),
              ),
              ListTile(
                title: Text(
                  "FAQ",
                  style: TextStyle(color: AppColor.whiteColor, fontSize: 14),
                ),
              ),
            ],
          ),
        ));
  }

  Widget Legal() {
    return Container(
        width: MediaQuery.of(context).size.width * 0.13,
        child: Container(
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  "Legal",
                  style: TextStyle(
                      color: AppColor.whiteColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 22),
                ),
              ),
              ListTile(
                title: Text(
                  "Cookies Policy",
                  style: TextStyle(color: AppColor.whiteColor, fontSize: 14),
                ),
              ),
              ListTile(
                title: Text(
                  "Terms & Conditions",
                  style: TextStyle(color: AppColor.whiteColor, fontSize: 14),
                ),
              ),
              ListTile(
                title: Text(
                  "Privacy Policy",
                  style: TextStyle(color: AppColor.whiteColor, fontSize: 14),
                ),
              ),
              ListTile(
                title: Text(
                  "About Us",
                  style: TextStyle(color: AppColor.whiteColor, fontSize: 14),
                ),
              ),
              ListTile(
                title: Text(
                  "Contact Us",
                  style: TextStyle(color: AppColor.whiteColor, fontSize: 14),
                ),
              ),
            ],
          ),
        ));
  }

  Widget Contects() {
    return Container(
        width: MediaQuery.of(context).size.width * 0.13,
        child: Container(
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  "Contact",
                  style: TextStyle(
                      color: AppColor.whiteColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 22),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: AppColor.whiteColor,
                ),
                title: Text(
                  "House : 25, Road No: 2, Block A, Mirpur-1, Dhaka 1216",
                  style: TextStyle(color: AppColor.whiteColor, fontSize: 14),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.mail_rounded,
                  color: AppColor.whiteColor,
                ),
                title: Text(
                  "info@inilabs.net",
                  style: TextStyle(color: AppColor.whiteColor, fontSize: 14),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.call,
                  color: AppColor.whiteColor,
                ),
                title: Text(
                  "13333846282",
                  style: TextStyle(color: AppColor.whiteColor, fontSize: 14),
                ),
              ),
            ],
          ),
        ));
  }

  Widget Sharelink() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      // color: AppColor.fontColorgrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: SvgPicture.asset(
                "assets/image/svg_appicon.svg",
                width: 70,
                height: 50,
              )),
          // Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Subscribe to our newsletter",
                style: TextStyle(color: AppColor.whiteColor, fontSize: 14),
              ),
              emailTextfeildwidget(),
            ],
          )
        ],
      ),
    );
  }

  emailTextfeildwidget() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          child: TextFormField(
            controller: homecontoller.emailLogincontoller,
            validator: homecontoller.validateEmail,
            keyboardType: TextInputType.emailAddress,
            cursorColor: AppColor.fontblack,
            decoration: InputDecoration(
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: AppColor.BlackColor),
                    // margin: EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Subscribe",
                        style: TextStyle(color: AppColor.whiteColor),
                      ),
                    ),
                  ),
                ),
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
                fillColor: Colors.white,
                border: InputBorder.none,
                hintText: "Enter Your Email",
                hintStyle: TextStyle(fontFamily: AppFont.lato)),
            style: TextStyle(
                fontSize: 14,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget service({image, title, subtitle}) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 70,
        maxWidth: MediaQuery.of(context).size.width * 0.13,
      ),
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            image,
            height: 40,
            width: 40,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                subtitle,
                maxLines: 1,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget Service() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        runSpacing: 10,
        alignment: WrapAlignment.spaceAround,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          SeviceSet(
              image: "assets/image/securedelivery.svg",
              title: "Free shipping",
              subtitle: "Standard Shipping",
              divider: true),
          SeviceSet(
              image: "assets/image/securepayment.svg",
              title: "Secure Payment",
              subtitle: "100% risk-free shopping",
              divider: true),
          SeviceSet(
              image: "assets/image/special campian.svg",
              title: "Special Campaigns",
              subtitle: "Guaranteed Saving",
              divider: true),
          SeviceSet(
              image: "assets/image/customerservice.svg",
              title: "Customer Service",
              subtitle: "Give us feedback",
              divider: false),
        ],
      ),
    );
  }

  Widget Explore() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Text(
            "EXPLORE",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColor.BgColor),
          ),
          Wrap(
            runSpacing: 10,
            alignment: WrapAlignment.spaceAround,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Explorecontent(title: "About Us", divider: true),
              Explorecontent(title: "Contact Us", divider: true),
              Explorecontent(title: "Size Chart", divider: true),
              Explorecontent(title: "Career", divider: false)
            ],
          ),
        ],
      ),
    );
  }

  Widget Policies() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Text(
            "POLICIES",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColor.BgColor),
          ),
          Wrap(
            runSpacing: 10,
            alignment: WrapAlignment.spaceAround,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Explorecontent(title: "T&C", divider: true),
              Explorecontent(title: "Privacy Policy", divider: true),
              Explorecontent(title: "Cancellation Policy", divider: true),
              Explorecontent(title: "Return & Refunds", divider: true),
              Explorecontent(title: "Exchange Policy", divider: true),
              Explorecontent(title: "Order Tracking", divider: true),
              Explorecontent(title: "Shipping & COD", divider: false)
            ],
          ),
        ],
      ),
    );
  }

  Widget Explorecontent({title, divider}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          border: Border(
              right: divider == false
                  ? BorderSide.none
                  : BorderSide(color: Colors.white, width: 1))),
      child: FittedBox(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: AppColor.BgColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget SeviceSet({title, subtitle, image, divider}) {
    return Container(
      padding: EdgeInsets.only(right: 15, left: 15),
      decoration: BoxDecoration(
          border: Border(
              right: divider == false
                  ? BorderSide.none
                  : BorderSide(color: Colors.white, width: 1))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width < 600.0 ? 8.0 : 20.0),
            child: SvgPicture.asset(
              image,
              color: AppColor.BgColor,
              height: 40,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FittedBox(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColor.BgColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              FittedBox(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColor.BgColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Widget Tabbars() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     child: TabBar(
  //       tabAlignment: TabAlignment.center,
  //       controller: tabController,
  //       indicatorColor: AppColor.BlackColor,
  //       dividerColor: Colors.transparent,
  //       labelColor: AppColor.BlackColor,
  //       isScrollable: true,
  //       overlayColor: WidgetStatePropertyAll(Colors.black12),
  //       labelStyle: TextStyle(
  //           fontSize: MediaQuery.of(context).size.width < 850 ? 16 : 18,
  //           fontWeight: FontWeight.w600),
  //       unselectedLabelColor: AppColor.fontColorgrey,
  //       tabs: [
  //         Tab(
  //           text: "Buy 3 Get 60% Off",
  //         ),
  //         Tab(
  //           text: "All Under ₹100",
  //         ),
  //         Tab(
  //           text: "Quickship",
  //         ),
  //       ],
  //     ),
  //   );
  // }
  List<ProductModel> filteredDepartments =
      []; // List to store matching departments
  Widget Tabbars(List<DepartmentModel> departments) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: TabBar(
        tabAlignment: TabAlignment.center,
        controller: tabController,
        onTap: (value) async {

          // Clear previous results
          filteredDepartments.clear();
          filteredDepartments = [];
          await datasetforDepartment(alldata, departments[value].deptName);

          setState(() {});
          // update();
        },
        indicatorColor: AppColor.BlackColor,
        dividerColor: Colors.transparent,
        labelColor: AppColor.BlackColor,
        isScrollable: true,
        overlayColor: WidgetStatePropertyAll(Colors.black12),
        labelStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.width < 850 ? 16 : 18,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelColor: AppColor.fontColorgrey,
        tabs: departments
            .map((department) => Tab(text: department.deptName))
            .toList(),
      ),
    );
  }

  Widget TabbarViews(List<DepartmentModel> departments) {
    return AutoScaleTabBarView(
      controller: tabController,
      children: List.generate(departments.length, (index) {
        return TabviewListview(filteredDepartments ?? [], fevorite_Tab3);
      }),
    );
  }

  var isdpL = false.obs;
  Future<void> datasetforDepartment(
      List<ProductModel> caller, String departmentName) async {

    isdpL.value = true; // Set loading indicator to true
    filteredDepartments.clear(); // Clear previous results
    fevorite_Tab3.clear();

    for (var element in caller) {
      if (element.departmentname == departmentName) {
        filteredDepartments.add(element);
        fevorite_Tab3.add(false);
      }
    }


    // Wait for 2 seconds before setting isdpL to false
    await Future.delayed(Duration(seconds: 2));
    isdpL.value = false;

  }

  whatsapp() async {
    String contact = "+91 9033806717";
    String text = '';
    String androidUrl = "whatsapp://send?phone=$contact&text=$text";
    String iosUrl = "https://wa.me/$contact?text=${Uri.parse(text)}";

    String webUrl = 'https://api.whatsapp.com/send/?phone=$contact&text=hi';

    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(Uri.parse(iosUrl))) {
          await launchUrl(Uri.parse(iosUrl));
        }
      } else {
        if (await canLaunchUrl(Uri.parse(androidUrl))) {
          await launchUrl(Uri.parse(androidUrl));
        }
      }
    } catch (e) {
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }
}
