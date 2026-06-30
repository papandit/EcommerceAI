// ignore_for_file: prefer_const_literals_to_create_immutables, non_constant_identifier_names, prefer_const_constructors, unnecessary_import, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, deprecated_member_use, sized_box_for_whitespace, avoid_print, use_key_in_widget_constructors, must_be_immutable, no_logic_in_create_state, avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:io';
import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/api/user_data_api.dart';
import 'package:EcommerceApp/helper/bottom_bar.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/timestamp.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/cartmodels.dart';
import 'package:EcommerceApp/model/headerfootermodel.dart';
import 'package:EcommerceApp/model/productmodel.dart';
import 'package:EcommerceApp/model/userdataset.dart';
import 'package:EcommerceApp/view/addressadd.dart';
import 'package:EcommerceApp/view/allproductspage.dart';
import 'package:EcommerceApp/view/categorypage.dart';
import 'package:EcommerceApp/view/contect_us.dart';
import 'package:EcommerceApp/view/htmlcontain.dart';
import 'package:EcommerceApp/view/loginpage.dart';
import 'package:EcommerceApp/view/myorder.dart';
import 'package:EcommerceApp/view/notificationpage.dart';
import 'package:EcommerceApp/view/profileupdate.dart';
import 'package:EcommerceApp/view/searchpage.dart';
import 'package:EcommerceApp/viewmodel/homecontroller.dart';
import 'package:beamer/beamer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_svg/svg.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }

  static List<String> sortinglist = [
    "Price: High  to Low",
    "Price: Low  to High",
    "A - Z",
    "Z - A",
  ];

  static int finalamount = 0;
  static int shippingcost = 0;
  static int deliveryfee = 0;
  static int headerWidth = 1000;
  static List<Cartitems> cartitemsdata = [];
  static List<HeaderFooterModel> headerFotterlist = [];
  static List<HeaderFooterModel> headerlist = [];
  static List<HeaderFooterModel> footerfirstlist = [];
  static List<HeaderFooterModel> footerexplorelist = [];
  static List<HeaderFooterModel> footerpolicylist = [];
  static UserModel userModel = UserModel(email: "");
  static bool UnverifyedUser = true;
  static bool isRegister = false;
  static int cartitems = 0;
  static TextEditingController newsletterController = TextEditingController();
  AppBar Header({title, ontap, isfev, exit, context, heart, leading = true}) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title ?? "",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.transparent,
      backgroundColor: AppColor.BgColor,
      leading: leading == true
          ? InkWell(
              overlayColor: WidgetStatePropertyAll(Colors.white),
              onTap: () {
                exit == true
                    ? CommonWidget().showExitPopup(context)
                    : WebAPPNavigation.navigateTo(context: context);
              },
              child: CommonWidget().backicon())
          : null,
      actions: [
        heart ?? true
            ? InkWell(
                overlayColor: WidgetStatePropertyAll(Colors.white),
                onTap: ontap,
                child: Container(
                  height: 45,
                  width: 45,
                  margin: EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                      color: AppColor.whiteColor, shape: BoxShape.circle),
                  child: isfev ?? false
                      ? Icon(
                          Icons.favorite,
                          color: AppColor.BlackColor,
                        )
                      : Icon(Icons.favorite_border),
                ),
              )
            : SizedBox(),
      ],
    );
  }

  Widget backicon() {
    return Container(
      margin: EdgeInsets.only(left: 15),
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: AppColor.whiteColor),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Image.asset(
          AppImage.appIcon + "back_btn.png",
        ),
      ),
    );
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

  Future<void> launchFacebook(String fbUrl, String fbWebUrl) async {
    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(Uri.parse(fbUrl))) {
          await launchUrl(Uri.parse(fbUrl));
        }
      } else {
        if (await canLaunchUrl(Uri.parse(fbUrl))) {
          await launchUrl(Uri.parse(fbUrl));
        }
      }
    } catch (e) {
      await launchUrl(Uri.parse(fbWebUrl),
          mode: LaunchMode.externalApplication);
    }
  }

  AppBar NewHeader({title, ontap, isfev, exit, context, heart}) {
    return AppBar(
      leadingWidth: 90,
      leading: InkWell(
        overlayColor: WidgetStatePropertyAll(AppColor.whiteColor),
        onTap: () {
          WebAPPNavigation.navigateToroute(
              context: context, routename: '/HomePage', screen: BottomBar());
        },
        child: Container(
            height: 52,
            child: Image.asset(
              "assets/image/onewebmart_logo.png",
              height: 44,
              fit: BoxFit.contain,
            )),
      ),
      automaticallyImplyLeading: false,
      backgroundColor: AppColor.BgColor,
      surfaceTintColor: AppColor.BgColor,
      foregroundColor: AppColor.BlackColor,
    );
  }

  Future<void> launchInstagram(String fbUrl, String fbWebUrl) async {
    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(Uri.parse(fbUrl))) {
          await launchUrl(Uri.parse(fbUrl));
        }
      } else {
        if (await canLaunchUrl(Uri.parse(fbUrl))) {
          await launchUrl(Uri.parse(fbUrl));
        }
      }
    } catch (e) {
      await launchUrl(Uri.parse(fbWebUrl),
          mode: LaunchMode.externalApplication);
    }
  }

  Widget TextWidget(
      {text,
      maxline,
      align,
      size,
      color,
      weight,
      letterspace,
      wordheight,
      fontFamily,
      overflow,
      decoration}) {
    return Text(
      text,
      maxLines: maxline,
      textAlign: align,
      style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: weight,
          height: wordheight,
          fontFamily: fontFamily,
          letterSpacing: letterspace,
          overflow: overflow,
          decoration: decoration),
    );
  }

  Future<bool> showExitPopup(context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            surfaceTintColor: AppColor.whiteColor,
            title: Text('Exit App',
                style: TextStyle(
                    color: AppColor.BlackColor, fontWeight: FontWeight.w600)),
            content: Text('Are You Sure Want To Exit?',
                style: TextStyle(
                    color: AppColor.BlackColor, fontWeight: FontWeight.w500)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No',
                    style: TextStyle(
                        color: AppColor.btnColorblack,
                        fontWeight: FontWeight.w400)),
              ),
              TextButton(
                onPressed: () => exit(1),
                child: Text('Yes',
                    style: TextStyle(
                        color: AppColor.btnColorblack,
                        fontWeight: FontWeight.w400)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> LogoutPopup(context, {tap}) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            surfaceTintColor: AppColor.whiteColor,
            title: Text('Logout',
                style: TextStyle(
                    color: AppColor.BlackColor, fontWeight: FontWeight.w600)),
            content: Text('Are you sure you want to Logout?',
                style: TextStyle(
                    color: AppColor.BlackColor, fontWeight: FontWeight.w600)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No',
                    style: TextStyle(
                        color: AppColor.btnColorblack,
                        fontWeight: FontWeight.w600)),
              ),
              TextButton(
                onPressed: tap,
                child: Text('Yes',
                    style: TextStyle(
                        color: AppColor.btnColorblack,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ) ??
        false;
  }

  String categoryvalue = "";
  static List<String> categorylsit = [
    // "Shoes",
    // "Women",
  ];
  static List<CategoryModel> categorylist = [
    // "Shoes",
    // "Women",
  ];

  /// Whether the secondary category bar is open (toggled by the "Categories"
  /// nav item). The bar shutters open/closed in response.
  static final ValueNotifier<bool> categoriesOpen = ValueNotifier<bool>(false);

  static List<String> categorylistid = [
    // "Shoes",
    // "Women",
  ];
  String optionsvalue = "More";

  static List<String> optionsList = [];
  static List<String> datasss = [];

  final Map<String, List<String>> categories = {
    "Fruits": ["Apple", "Banana", "Mango"],
    "Vehicles": ["Car", "Bike", "Truck"],
  };

  String? selectedCategory;
  String? selectedSubCategory;
  Offset dropdownOffset = Offset.zero;

  /// 3-step checkout progress: 0 = Bag, 1 = Delivery, 2 = Payment.
  Widget checkoutSteps(BuildContext context, int active) {
    const steps = ["Bag", "Delivery", "Payment"];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final done = (i ~/ 2) < active;
            return Container(
              width: 44,
              height: 2,
              margin: EdgeInsets.symmetric(horizontal: 6),
              color: done ? AppColor.primary : AppColor.dividercolor,
            );
          }
          final idx = i ~/ 2;
          final bool isActive = idx == active;
          final bool isDone = idx < active;
          final bool on = isActive || isDone;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 30,
                width: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? AppColor.primary : AppColor.blush,
                  shape: BoxShape.circle,
                ),
                child: isDone
                    ? Icon(Icons.check, size: 16, color: Colors.white)
                    : Text("${idx + 1}",
                        style: TextStyle(
                            color:
                                isActive ? Colors.white : AppColor.fontColorgrey,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
              ),
              SizedBox(width: 8),
              Text(steps[idx],
                  style: TextStyle(
                      color: on ? AppColor.ink : AppColor.fontColorgrey,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5)),
            ],
          );
        }),
      ),
    );
  }

  Widget backButton(BuildContext context, {String label = "Back"}) {
    // Compact, transparent arrow — no full-width white strip (removes the
    // extra white space that used to sit above page content). Uses a
    // height-wrapping Container (NOT Align) so it stays bounded inside the
    // scrollable Columns these pages live in.
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 16, top: 10, bottom: 2),
      child: PressableScale(
        onTap: () {
          WebAPPNavigation.navigateTo(context: context);
        },
        child: Container(
          height: 44,
          width: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColor.blush,
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.blushDeep)),
          child: Icon(Icons.arrow_back_rounded, size: 20, color: AppColor.ink),
        ),
      ),
    );
  }

  /// Arrow-only back button meant to be OVERLAID on the rose hero (top-left)
  /// so there's no separate white strip taking vertical space.
  Widget heroBackArrow(BuildContext context) {
    return PressableScale(
      onTap: () {
        WebAPPNavigation.navigateTo(context: context);
      },
      child: Container(
        height: 44,
        width: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          shape: BoxShape.circle,
          boxShadow: Appshadow.soft,
        ),
        child: Icon(Icons.arrow_back_rounded, size: 20, color: AppColor.ink),
      ),
    );
  }

  Widget AnnouncementBar(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: AppColor.ink,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.spa_outlined, size: 15, color: AppColor.accent),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              "Complimentary shipping over ₹999   •   The women's edit, refreshed every week",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColor.whiteColor,
                fontSize: 12.5,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget StickyHeaders(
    BuildContext context, {
    Function? Refresh,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        border: Border(
            bottom: BorderSide(color: AppColor.dividercolor, width: 1)),
        boxShadow: Appshadow.soft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // MediaQuery.of(context).size.width < 1400
          //     ? SizedBox()
          //     : Flexible(
          //         flex: 1,
          //         child: Container(),
          //       ),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 12),
              constraints: BoxConstraints(maxHeight: 80),
              child: InkWell(
                onTap: () async {
                  WebAPPNavigation.navigateToroute(
                      context: context,
                      routename: '/HomePage',
                      screen: BottomBar(
                        pageindex: 0,
                      ));
                },
                child: Image.asset(
                  "assets/image/onewebmart_logo.png",
                  height: 44,
                  fit: BoxFit.contain,
                ),
              )),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 26.0),
                child: InkWell(
                  onTap: () {
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        routename: '/HomePage',
                        screen: BottomBar(
                          pageindex: 0,
                        ));
                  },
                  child: NavText("Home"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 26.0),
                child: InkWell(
                  onTap: () {
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        routename: '/AllProducts',
                        screen: AllProductsPage());
                  },
                  child: NavText("Shop All"),
                ),
              ),
              Container(
                height: 50,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(right: 26.0),
                child: InkWell(
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    CommonWidget.categoriesOpen.value =
                        !CommonWidget.categoriesOpen.value;
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NavText("Categories"),
                        const SizedBox(width: 4),
                        ValueListenableBuilder<bool>(
                          valueListenable: CommonWidget.categoriesOpen,
                          builder: (context, open, _) => AnimatedRotation(
                            turns: open ? 0.5 : 0,
                            duration: const Duration(milliseconds: 240),
                            child: Icon(Icons.keyboard_arrow_down_rounded,
                                size: 18, color: AppColor.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 26.0),
                child: InkWell(
                  onTap: () {
                    // The About page renders its own (curated) content, so it
                    // doesn't depend on a backend "Others" entry — navigate
                    // directly. Use any stored "About Us" copy if present.
                    String aboutHtml = '';
                    for (final e in footerexplorelist) {
                      if (e.name == "About Us") aboutHtml = e.about ?? '';
                    }
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        routename: '/Pages/About-Us',
                        data: {'conainName': 'About Us', 'htmldata': aboutHtml},
                        screen: HtmlConain(
                          title: "About Us",
                          htmldata: aboutHtml,
                        ));
                  },
                  child: NavText("About Us"),
                ),
              ),
              InkWell(
                onTap: () {
                  WebAPPNavigation.navigateToroute(
                      context: context,
                      routename: '/ContectUs',
                      screen: ContectUs());
                },
                child: NavText("Contact Us"),
              ),
              optionsList.isEmpty
                  ? SizedBox()
                  : Container(
                      height: 50,
                      width: 100,
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: 12.0,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            // focusColor: AppColor.BgColor,
                            // dropdownColor: AppColor.BgColor,

                            isExpanded: false,
                            isDense: true,
                            dropdownStyleData: DropdownStyleData(
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              offset: const Offset(-20, 0),
                              scrollbarTheme: ScrollbarThemeData(
                                radius: const Radius.circular(40),
                                thickness: MaterialStateProperty.all(6),
                                thumbVisibility:
                                    MaterialStateProperty.all(true),
                              ),
                            ),

                            onChanged: (value) {
                              optionsvalue = value as String;
                              optionsvalue = optionsvalue;
                            },

                            alignment: Alignment.center,
                            hint: Text(
                              "More",
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 550
                                          ? 14
                                          : 18,
                                  color: AppColor.BlackColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            items: optionsList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                alignment: Alignment.centerLeft,
                                value: value,
                                // enabled: false,
                                child: Text(
                                  "${value.toString()}",
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  550
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
            ],
          ),
          Row(
            children: [
              SearchWidget(context),
              functiond(context),
            ],
          ),
        ],
      ),
        ),
        const CategoryMegaNavBar(),
      ],
    );
  }

  Homecontoller homecontoller = Get.put(Homecontoller());
  Future<void> getuserdata() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      homecontoller.userid = prefs.getString(prefrenceKey.userid) ?? '';

      if (homecontoller.userid.isEmpty) {
        return;
      }

      final data = await ApiClient.instance.getOne('/auth/me');
      if (data.isNotEmpty) {
        CommonWidget.userModel = UserModel.fromJson(data);
        CommonWidget.UnverifyedUser = false;
      }
    } catch (e) {}
  }

  List<Cartitems> cartitemstake = [];

  Future cartdacheck() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    homecontoller.userid = prefs.getString(prefrenceKey.userid) ?? '';

    try {
      cartitemstake = await UserDataApi.getCart();
      CommonWidget.cartitems = cartitemstake.length;
    } catch (_) {}
  }

  InStock(
    List<ProductModel> attributes,
  ) {
    List<ProductModel> Products = [];

    if (attributes.isNotEmpty) {
      attributes.forEach((element) {
        if (element.Stockvalue != "OutStock") {
          Products.add(element);
        }
      });
    }

    return Products;
  }

  CategoryModel? categoryModel;
  Widget Drowers(
    BuildContext context, {
    Function? refresh,
    String? userid,
  }) {
    return Drawer(
      backgroundColor: AppColor.BgColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            margin: EdgeInsets.zero,
            accountName: Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                userModel.firstName != '' ? userModel.firstName : 'Guest',
                style: TextStyle(
                    fontFamily: AppFont.heading,
                    fontSize: 22,
                    color: AppColor.whiteColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            accountEmail: Text(
              userModel.email != '' ? userModel.email : 'Welcome to the edit',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w500),
            ),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
              ),
              child: ProfilePicture(
                  random: false,
                  name:
                      userModel.firstName != '' ? userModel.firstName : 'Guest',
                  radius: 30,
                  fontsize: 22),
            ),
            decoration: BoxDecoration(
              gradient: AppColor.ctaGradient,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.category,
              color: AppColor.BlackColor,
            ),
            title: Container(
              alignment: Alignment.centerLeft,
              // width: 100,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<CategoryModel>(
                  // focusColor: AppColor.BgColor,
                  // dropdownColor: AppColor.BgColor,
                  // onTap: () {},
                  dropdownStyleData: DropdownStyleData(
                    width: 150,
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
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        routename:
                            '/CategoryPage/${value!.name.replaceAll(' ', '-')}',
                        data: {'id': value.id},
                        screen: CategoryPage(
                          id: value.id,
                          title: value.name,
                        ));
                  },
                  value: categoryModel,
                  isExpanded: true,
                  isDense: true,
                  alignment: Alignment.center,
                  hint: Text(
                    "Categories",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  items: categorylist.map((CategoryModel value) {
                    return DropdownMenuItem<CategoryModel>(
                      alignment: Alignment.centerLeft,
                      value: value,
                      child: Text(
                        "${value.name.toString()}",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 550
                                ? 16
                                : 18,
                            fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            leading: Icon(
              Icons.center_focus_weak_rounded,
              color: AppColor.BlackColor,
            ),
            title: DropdownButtonHideUnderline(
              child: DropdownButton2<HeaderFooterModel>(
                dropdownStyleData: DropdownStyleData(
                  width: 150,
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
                  Navigator.of(context).pop();
                  if (value == null) return;
                  if (value.name == "Contanct Us") {
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        routename: '/ContectUs',
                        screen: ContectUs());
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (Beamer.of(context)
                            .configuration
                            .uri
                            .toString()
                            .contains("/Pages") ==
                        false) {
                      CommonWidget.datamethod(context).then(
                        (val) {
                          WebAPPNavigation.navigateToroute(
                              context: context,
                              routename:
                                  '/Pages/${value.name!.replaceAll(' ', '-')}',
                              data: {'htmldata': value.about},
                              screen: HtmlConain(
                                htmldata: value.about,
                              ));
                        },
                      );
                    } else {
                      WebAPPNavigation.navigateToroute(
                          context: context,
                          routename:
                              '/Page/${value.name!.replaceAll(' ', '-')}',
                          data: {'htmldata': value.about},
                          screen: HtmlConain(
                            htmldata: value.about,
                          ));
                    }
                  });
                },
                isExpanded: true,
                isDense: true,
                alignment: Alignment.center,
                hint: Text(
                  "Service",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                items: footerfirstlist.map((HeaderFooterModel value) {
                  return DropdownMenuItem<HeaderFooterModel>(
                    alignment: Alignment.centerLeft,
                    value: value,
                    child: Text(
                      "${value.name.toString()}",
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width < 550 ? 16 : 18,
                          fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
              ),
            ),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            leading: Icon(
              Icons.live_help,
              color: AppColor.BlackColor,
            ),
            title: DropdownButtonHideUnderline(
              child: DropdownButton2<HeaderFooterModel>(
                dropdownStyleData: DropdownStyleData(
                  width: 150,
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
                  Navigator.of(context).pop();
                  if (value == null) return;
                  if (value.name == "Contanct Us") {
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        routename: '/ContectUs',
                        // /${item.name!.replaceAll(' ', '-')}
                        // data: {'htmldata': item.about},
                        screen: ContectUs());
                  } else {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (Beamer.of(context)
                              .configuration
                              .uri
                              .toString()
                              .contains("/Pages") ==
                          false) {
                        CommonWidget.datamethod(context).then(
                          (val) {
                            WebAPPNavigation.navigateToroute(
                                context: context,
                                routename:
                                    '/Pages/${value.name!.replaceAll(' ', '-')}',
                                data: {'htmldata': value.about},
                                screen: HtmlConain(
                                  htmldata: value.about,
                                ));

                            // Beamer.of(context).update();
                          },
                        );
                      } else {
                        WebAPPNavigation.navigateToroute(
                            context: context,
                            routename:
                                '/Page/${value.name!.replaceAll(' ', '-')}',
                            data: {'htmldata': value.about},
                            screen: HtmlConain(
                              htmldata: value.about,
                            ));
                      }
                    });
                  }
                },
                isExpanded: true,
                isDense: true,
                alignment: Alignment.center,
                hint: Text(
                  "Explore",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                items: footerexplorelist.map((HeaderFooterModel value) {
                  return DropdownMenuItem<HeaderFooterModel>(
                    alignment: Alignment.centerLeft,
                    value: value,
                    child: Text(
                      "${value.name.toString()}",
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width < 550 ? 16 : 18,
                          fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.local_police_sharp,
              color: AppColor.BlackColor,
            ),
            title: DropdownButtonHideUnderline(
              child: DropdownButton2<HeaderFooterModel>(
                // focusColor: AppColor.BgColor,
                // dropdownColor: AppColor.BgColor,
                // onTap: () {},
                dropdownStyleData: DropdownStyleData(
                  width: 150,
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
                  Navigator.of(context).pop();
                  if (value == null) return;
                  if (value.name == "Contanct Us") {
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        routename: '/ContectUs',
                        // /${item.name!.replaceAll(' ', '-')}
                        // data: {'htmldata': item.about},
                        screen: ContectUs());
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (Beamer.of(context)
                            .configuration
                            .uri
                            .toString()
                            .contains("/Pages") ==
                        false) {
                      CommonWidget.datamethod(context).then(
                        (val) {
                          WebAPPNavigation.navigateToroute(
                              context: context,
                              routename:
                                  '/Pages/${value.name!.replaceAll(' ', '-')}',
                              data: {'htmldata': value.about},
                              screen: HtmlConain(
                                htmldata: value.about,
                              ));

                          Beamer.of(context).update();
                        },
                      );
                    } else {
                      WebAPPNavigation.navigateToroute(
                          context: context,
                          routename:
                              '/Page/${value.name!.replaceAll(' ', '-')}',
                          data: {'htmldata': value.about},
                          screen: HtmlConain(
                            htmldata: value.about,
                          ));
                    }
                  });
                },

                isExpanded: true,
                isDense: true,
                alignment: Alignment.center,
                hint: Text(
                  "Policies",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                items: footerpolicylist.map((HeaderFooterModel value) {
                  return DropdownMenuItem<HeaderFooterModel>(
                    alignment: Alignment.centerLeft,
                    value: value,
                    child: Text(
                      "${value.name.toString()}",
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width < 550 ? 16 : 18,
                          fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.favorite_outline_rounded,
              color: AppColor.BlackColor,
            ),
            title: Text(
              'WishList',
              style: TextStyle(
                  color: AppColor.BlackColor, fontWeight: FontWeight.w700),
            ),
            onTap: () {
              Navigator.pop(context);


              Future.delayed(
                Duration(seconds: 1),
                () {
                  WebAPPNavigation.navigateToroute(
                      context: context,
                      routename: '/FavoritePage',
                      screen: BottomBar(
                        pageindex: 1,
                      ));
                },
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.trolley,
              color: AppColor.BlackColor,
            ),
            title: Text(
              'Cart',
              style: TextStyle(
                  color: AppColor.BlackColor, fontWeight: FontWeight.w700),
            ),
            onTap: () {
              Navigator.pop(context);


              Future.delayed(
                Duration(seconds: 1),
                () {
                  WebAPPNavigation.navigateToroute(
                      context: context,
                      routename: '/ShoppingPage',
                      screen: BottomBar(
                        pageindex: 2,
                      ));
                },
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.notifications_on,
              color: AppColor.BlackColor,
            ),
            title: Text(
              'Notifications',
              style: TextStyle(
                  color: AppColor.BlackColor, fontWeight: FontWeight.w700),
            ),
            onTap: () {
              Navigator.pop(context);


              Future.delayed(
                Duration(seconds: 1),
                () {
                  WebAPPNavigation.navigateToroute(
                      context: context,
                      routename: '/NotificationPage',
                      screen: NotificationPage());
                },
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.contact_mail,
              color: AppColor.BlackColor,
            ),
            title: Text(
              'Contact Us',
              style: TextStyle(
                  color: AppColor.BlackColor, fontWeight: FontWeight.w700),
            ),
            onTap: () {
              Navigator.pop(context);


              Future.delayed(
                Duration(seconds: 1),
                () {
                  WebAPPNavigation.navigateToroute(
                      context: context,
                      routename: '/ContectUs',
                      screen: ContectUs());
                },
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.search_sharp,
              color: AppColor.BlackColor,
            ),
            title: Text(
              'Search',
              style: TextStyle(
                  color: AppColor.BlackColor, fontWeight: FontWeight.w700),
            ),
            onTap: () {
              Navigator.pop(context);

              Future.delayed(
                Duration(seconds: 1),
                () {
                  WebAPPNavigation.navigateToroute(
                      context: context,
                      routename: '/SearchPage',
                      screen: SearchPage());
                },
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.account_circle_outlined,
              color: AppColor.BlackColor,
            ),
            title: Text(
              'Profile',
              style: TextStyle(
                  color: AppColor.BlackColor, fontWeight: FontWeight.w700),
            ),
            onTap: () {
              Navigator.pop(context);
              Future.delayed(
                Duration(seconds: 1),
                () {
                  WebAPPNavigation.navigateToroute(
                      context: context,
                      routename: '/ProfilePage',
                      screen: BottomBar(
                        pageindex: 3,
                      ));
                },
              );
            },
          ),
          userid != null && userid.isEmpty
              ? ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: AppColor.BlackColor,
                  ),
                  title: Text(
                    'Login',
                    style: TextStyle(
                        color: AppColor.BlackColor,
                        fontWeight: FontWeight.w700),
                  ),
                  onTap: () async {
                    Navigator.pop(context);

                    final SharedPreferences perfs =
                        await SharedPreferences.getInstance();
                    perfs.clear();
                    Future.delayed(
                      Duration(seconds: 1),
                      () {
                        WebAPPNavigation.navigateToroute(
                            context: context,
                            routename: '/LoginPage',
                            screen: LoginPage());
                      },
                    );
                  },
                )
              : ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: AppColor.BlackColor,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                        color: AppColor.BlackColor,
                        fontWeight: FontWeight.w700),
                  ),
                  onTap: () async {
                    CommonWidget().LogoutPopup(context, tap: () async {
                      // CommonWidget

                      homecontoller.wishlist = [];
                      homecontoller.wishlistid = '';
                      homecontoller.MyCart = FirebaseCartModel();
                      homecontoller.userid = '';
                      refresh!.call();

                      CommonWidget.userModel = UserModel.empty();
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      Get.find<Homecontoller>().dispose();
                      await preferences.clear().then((value) {
                        WebAPPNavigation.navigateToroute(
                          context: context,
                          routename: '/HomePage',
                          screen: BottomBar(),
                        );
                      });
                    });
                  },
                ),
        ],
      ),
    );
  }

  Widget _userAvatar() {
    final n = userModel.firstName.trim().isNotEmpty
        ? userModel.firstName.trim()
        : (userModel.email.trim().isNotEmpty ? userModel.email.trim() : 'G');
    final initial = n.isNotEmpty ? n[0].toUpperCase() : 'G';
    return Container(
      height: 44,
      width: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          gradient: AppColor.ctaGradient, shape: BoxShape.circle),
      child: Text(initial,
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700)),
    );
  }

  Widget headerIcon(String asset, {double size = 22}) {
    return Container(
      height: 44,
      width: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.blush,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(asset, width: size, height: size),
    );
  }

  Widget functiond(context) {
    return Row(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            // color: AppColor.BgColor,
            padding: EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                WebAPPNavigation.navigateToroute(
                    context: context,
                    routename: '/FavoritePage',
                    screen: BottomBar(
                      pageindex: 1,
                    ));
              },
              child: headerIcon("assets/image/heart.svg"),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            right: 12,
          ),
          child: Container(
            child: Stack(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    // color: AppColor.BgColor,

                    child: InkWell(
                      onTap: () {
                        WebAPPNavigation.navigateToroute(
                            context: context,
                            routename: '/ShoppingPage',
                            screen: BottomBar(
                              pageindex: 2,
                            ));
                      },
                      child: headerIcon("assets/image/Cart icon.svg"),
                    ),
                  ),
                ),
                cartitems == 0
                    ? SizedBox()
                    : Positioned(
                        right: 2,
                        top: 0,
                        child: Container(
                          height: 18,
                          width: 18,
                          decoration: BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              '$cartitems',
                              style: TextStyle(
                                  fontSize: 12, color: AppColor.whiteColor),
                            ),
                          ),
                        ),
                      )
              ],
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            // color: AppColor.BgColor,
            padding: EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                WebAPPNavigation.navigateToroute(
                    context: context,
                    routename: '/NotificationPage',
                    screen: NotificationPage());
              },
              child: headerIcon("assets/image/bell.svg"),
            ),
          ),
        ),
        UnverifyedUser
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      WebAPPNavigation.navigateToroute(
                          context: context,
                          routename: '/LoginPage',
                          screen: LoginPage());
                    },
                    child: headerIcon("assets/image/Frame.svg"),
                  ),
                ),
              )
            : DropdownButtonHideUnderline(
                child: DropdownButton2(
                  customButton: _userAvatar(),
                  items: [
                    ...MenuItems.firstItems.map(
                      (item) => DropdownMenuItem<MenuItem>(
                        value: item,
                        child: MenuItems.buildItem(item),
                      ),
                    ),
                    const DropdownMenuItem<Divider>(
                        enabled: false, child: Divider()),
                    ...MenuItems.secondItems.map(
                      (item) => DropdownMenuItem<MenuItem>(
                        value: item,
                        child: MenuItems.buildItem(item),
                      ),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == MenuItems.home) {
                      Future.delayed(const Duration(milliseconds: 500)).then(
                          (value) => WebAPPNavigation.navigateToroute(
                              context: context,
                              routename: '/UpdateProfile',
                              screen: UpdateProfile()));
                    } else if (value == MenuItems.settings) {
                      Future.delayed(const Duration(milliseconds: 500)).then(
                          (value) => WebAPPNavigation.navigateToroute(
                              context: context,
                              routename: '/MyOrderPage',
                              screen: MyOrderPage()));
                    } else if (value == MenuItems.share) {
                      Future.delayed(const Duration(milliseconds: 500)).then(
                          (value) => WebAPPNavigation.navigateToroute(
                              context: context,
                              routename: '/DeliveryAdressadd',
                              screen: DeliveryAdressadd()));
                    } else if (value == MenuItems.logout) {
                      LogoutPopup(context, tap: () async {
                        final SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences.clear();
                        homecontoller.wishlist = [];
                        homecontoller.wishlistid = '';
                        homecontoller.MyCart = FirebaseCartModel();
                        homecontoller.userid = '';
                        // Refresh!.call();

                        CommonWidget.userModel = UserModel.empty();

                        Get.find<Homecontoller>().dispose();
                        print(
                            "currentConfiguration :: ${Beamer.of(context).currentConfiguration!.uri}");
                        Future.delayed(const Duration(milliseconds: 500)).then(
                            (value) => WebAPPNavigation.navigateToroute(
                                context: context,
                                routename: '/LoginPage',
                                screen: LoginPage()));
                      });
                    }
                  },
                  dropdownStyleData: DropdownStyleData(
                    width: 200,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColor.whiteColor,
                      border: Border.all(color: AppColor.dividercolor),
                    ),
                    offset: const Offset(0, -8),
                  ),
                  menuItemStyleData: MenuItemStyleData(
                    customHeights: [
                      ...List<double>.filled(MenuItems.firstItems.length, 48),
                      8,
                      ...List<double>.filled(MenuItems.secondItems.length, 48),
                    ],
                    padding: const EdgeInsets.only(left: 16, right: 16),
                  ),
                ),
              ),
        SizedBox(width: 6),
      ],
    );
  }

  Widget SearchWidget(context) {
    final double w = MediaQuery.of(context).size.width;
    final double barWidth = w < 1200 ? 200 : (w < 1500 ? 260 : 320);
    return Container(
      margin: EdgeInsets.only(right: 14),
      width: barWidth,
      child: InkWell(
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        onTap: () {
          WebAPPNavigation.navigateToroute(
              context: context,
              routename: '/SearchPage',
              screen: SearchPage());
        },
        child: Container(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.blush,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColor.blushDeep),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded,
                  size: 20, color: AppColor.fontColorgrey),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Search products, brands & more",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColor.fontColorgrey,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget Footer(BuildContext context, {Function? Refresh}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: AppColor.ink,
      child: Column(
        children: [
          FooterBrandBand(context),
          Divider(color: Colors.white.withOpacity(0.10), thickness: 1, height: 1),
          SizedBox(height: 26),
          _footerLinkColumns(context),
          SizedBox(height: 24),
          _footerGetInTouch(context),
          SizedBox(height: 10),
          socialmedia(context),
          SizedBox(height: 22),
          Divider(
            color: Colors.white.withOpacity(0.12),
            thickness: 1,
            indent: 24,
            endIndent: 24,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 6,
              children: [
                Text(
                  "© 2026 $storeName · Crafted with care for women everywhere",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.65), fontSize: 13),
                ),
                Container(
                    height: 4,
                    width: 4,
                    decoration: BoxDecoration(
                        color: AppColor.accent, shape: BoxShape.circle)),
                InkWell(
                  onTap: () => launchFacebook(
                      "https://onewebmart.com/", "https://onewebmart.com/"),
                  child: Text(
                    "All rights reserved by onewebmart.com",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- "Get In Touch" block (email + phone numbers) shown in the footer ----
  Widget _footerGetInTouch(BuildContext context) {
    Widget contactLine(String text, String url, IconData icon) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => launchFacebook(url, url),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: AppColor.accent),
              SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(
                    color: AppColor.accent,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Get In Touch",
            style: TextStyle(
                fontFamily: AppFont.heading,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColor.whiteColor),
          ),
          SizedBox(height: 16),
          contactLine("business@onewebmart.com",
              "mailto:business@onewebmart.com", Icons.mail_outline),
          contactLine(
              "+91 9033806717", "tel:+919033806717", Icons.call_outlined),
          contactLine(
              "+91 9408307302", "tel:+919408307302", Icons.call_outlined),
        ],
      ),
    );
  }

  // Store brand name shown in the footer / copyright. Change this in one place.
  static const String storeName = "E-Fashion";

  // ---- Complete footer link section (categories + policies + company) ------
  // Self-contained: always renders, independent of backend "Others" data.
  Widget _footerLinkColumns(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width >= 900;

    // Category names — from the loaded catalog, with a curated fallback so the
    // footer always shows something on a fresh database.
    final List<CategoryModel> cats = CommonWidget.categorylist;
    final List<Widget> categoryLinks = (cats.isNotEmpty
            ? cats.take(12).map((c) {
                final name = c.name.toString();
                return _footerLink(context, name, () {
                  WebAPPNavigation.navigateToroute(
                    context: context,
                    routename: '/CategoryPage/${name.replaceAll(' ', '-')}',
                    screen: CategoryPage(id: c.id, title: name),
                  );
                });
              }).toList()
            : <String>[
                "Sarees",
                "Lehengas",
                "Kurtis & Suits",
                "Ethnic Wear",
                "Dresses",
                "Tops",
                "Western Wear",
                "Jewellery",
              ].map((name) {
                return _footerLink(context, name, () {
                  WebAPPNavigation.navigateToroute(
                    context: context,
                    routename: '/AllProducts',
                    screen: AllProductsPage(heading: name),
                  );
                });
              }).toList());

    final List<Widget> serviceLinks = [
      _footerLink(context, "Terms & Conditions",
          () => _openInfoPage(context, "Terms & Conditions")),
      _footerLink(context, "Privacy Policy",
          () => _openInfoPage(context, "Privacy Policy")),
      _footerLink(context, "Delivery Information",
          () => _openInfoPage(context, "Delivery Information")),
      _footerLink(context, "Cash on Delivery (COD)",
          () => _openInfoPage(context, "Cash on Delivery (COD)")),
      _footerLink(
          context, "GST Details", () => _openInfoPage(context, "GST Details")),
      _footerLink(context, "Returns & Refunds",
          () => _openInfoPage(context, "Returns & Refunds")),
      _footerLink(context, "Shipping Policy",
          () => _openInfoPage(context, "Shipping Policy")),
    ];

    final List<Widget> companyLinks = [
      _footerLink(context, "About Us", () {
        WebAPPNavigation.navigateToroute(
            context: context,
            routename: '/Pages/About-Us',
            data: {'conainName': 'About Us', 'htmldata': ''},
            screen: HtmlConain(title: "About Us", htmldata: ''));
      }),
      _footerLink(context, "Contact Us", () {
        WebAPPNavigation.navigateToroute(
            context: context, routename: '/ContectUs', screen: ContectUs());
      }),
      _footerLink(context, "Careers", () => _openInfoPage(context, "Careers")),
      _footerLink(context, "Shop All", () {
        WebAPPNavigation.navigateToroute(
            context: context,
            routename: '/AllProducts',
            screen: AllProductsPage());
      }),
    ];

    final columns = [
      _footerColumn(context, "Shop by Category", categoryLinks),
      _footerColumn(context, "Customer Service", serviceLinks),
      _footerColumn(context, "Company", companyLinks),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 48 : 24, vertical: 4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 40,
          runSpacing: 30,
          children: columns
              .map((c) => SizedBox(
                  width: wide
                      ? 300
                      : (MediaQuery.of(context).size.width - 70) / 2,
                  child: c))
              .toList(),
        ),
      ),
    );
  }

  Widget _footerColumn(BuildContext context, String title, List<Widget> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(height: 2, width: 28, color: AppColor.accent),
        const SizedBox(height: 14),
        ...links,
      ],
    );
  }

  Widget _footerLink(BuildContext context, String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: InkWell(
        onTap: onTap,
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
            fontSize: 13.5,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  // Opens a simple information/policy page (content can be filled via admin).
  void _openInfoPage(BuildContext context, String title) {
    WebAPPNavigation.navigateToroute(
      context: context,
      routename: '/Pages/${title.replaceAll(' ', '-')}',
      data: {'conainName': title, 'htmldata': ''},
      screen: HtmlConain(title: title, htmldata: ''),
    );
  }

  Widget FooterBrandBand(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width >= 900;
    final brand = Column(
      crossAxisAlignment:
          wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset("assets/image/onewebmart_logo.png", height: 46, fit: BoxFit.contain),
        ),
        SizedBox(height: 14),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 360),
          child: Text(
            "Thoughtfully curated fashion, made for every her. Discover pieces you'll love to live in.",
            textAlign: wide ? TextAlign.start : TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );

    final newsletter = Column(
      crossAxisAlignment:
          wide ? CrossAxisAlignment.end : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Join the list",
          style: TextStyle(
            fontFamily: AppFont.heading,
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "New arrivals & private offers, straight to your inbox.",
          textAlign: wide ? TextAlign.end : TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13),
        ),
        SizedBox(height: 14),
        Container(
          width: 380,
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 48),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          padding: EdgeInsets.only(left: 18, right: 6, top: 6, bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: newsletterController,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  cursorColor: AppColor.accent,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Your email address",
                    hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 14),
                  ),
                ),
              ),
              PressableScale(
                onTap: () {
                  final email = newsletterController.text.trim();
                  newsletterController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: AppColor.ink,
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      email.isEmpty
                          ? "Please enter your email to subscribe."
                          : "Thanks for subscribing — welcome to the edit!",
                      style: TextStyle(color: Colors.white),
                    ),
                  ));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppColor.ctaGradient,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    "Subscribe",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: wide ? 48 : 20, vertical: wide ? 44 : 30),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: brand),
                SizedBox(width: 30),
                Flexible(child: newsletter),
              ],
            )
          : Column(
              children: [
                brand,
                SizedBox(height: 30),
                newsletter,
              ],
            ),
    );
  }

  Widget Service(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
          runSpacing: 10,
          alignment: WrapAlignment.spaceAround,
          verticalDirection: VerticalDirection.down,
          children: List.generate(
            footerfirstlist.length,
            (index) {
              return InkWell(
                onTap: () {
                  print(
                      "configuration :: ${Beamer.of(context).configuration.uri}");
                  print(
                      "configuration :: ${Beamer.of(context).navigatorObservers}");

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (Beamer.of(context)
                            .configuration
                            .uri
                            .toString()
                            .contains("/Pages") ==
                        false) {
                      datamethod(context).then(
                        (value) {
                          WebAPPNavigation.navigateToroute(
                              context: context,
                              routename:
                                  '/Pages/${footerfirstlist[index].name!.replaceAll(' ', '-')}',
                              data: {'htmldata': footerfirstlist[index].about},
                              screen: HtmlConain(
                                htmldata: footerfirstlist[index].about,
                                title: footerfirstlist[index].name!,
                              ));

                          Beamer.of(context).update();
                        },
                      );
                    } else {
                      WebAPPNavigation.navigateToroute(
                          context: context,
                          routename:
                              '/Page/${footerfirstlist[index].name!.replaceAll(' ', '-')}',
                          data: {'htmldata': footerfirstlist[index].about},
                          screen: HtmlConain(
                            htmldata: footerfirstlist[index].about,
                            title: footerfirstlist[index].name!,
                          ));
                    }
                  });
                },
                child: SeviceSet(context,
                    image: footerfirstlist[index].image,
                    title: footerfirstlist[index].name,
                    subtitle: footerfirstlist[index].name,
                    divider:
                        index == (footerfirstlist.length - 1) ? false : true),
              );
            },
          )),
    );
  }

  static Future datamethod(context) async {
    Navigator.maybePop(context);
    WebAPPNavigation.navigateTo(context: context);

  }

  Widget socialmedia(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Text(
            "Follow Along",
            style: TextStyle(
                fontFamily: AppFont.heading,
                fontSize: 24,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
                color: AppColor.BgColor),
          ),
          Container(
              margin: EdgeInsets.only(top: 6, bottom: 2),
              height: 2,
              width: 34,
              color: AppColor.accent),
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Wrap(
                runSpacing: 10,
                spacing: 40,
                alignment: WrapAlignment.spaceAround,
                verticalDirection: VerticalDirection.down,
                children: [
                  InkWell(
                    overlayColor: WidgetStatePropertyAll(AppColor.BgColor),
                    onTap: () {
                      String url =
                          "https://www.linkedin.com/company/onewebmart-solution";
                      launchFacebook(url, url);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColor.BgColor,
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: SvgPicture.asset(
                          "assets/image/linkedin.svg",
                          height: 30,
                          width: 30,
                          color: AppColor.BgColor,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    overlayColor: WidgetStatePropertyAll(AppColor.BgColor),
                    onTap: () {
                      String webUrl = "https://www.instagram.com/onewebmart/";
                      launchFacebook(webUrl, webUrl);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColor.BgColor,
                          )),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: SvgPicture.asset(
                          "assets/image/instagram.svg",
                          height: 30,
                          width: 30,
                          color: AppColor.BgColor,
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }

  static void _addElementInOrder(
      List<HeaderFooterModel> list, HeaderFooterModel element) {
    Timestampss timestamp = Timestampss.fromString(element.createdAt!);
    DateTime elementCreatedAt = timestamp.toDateTime();

    int index = list.indexWhere((e) => Timestampss.fromString(e.createdAt!)
        .toDateTime()
        .isAfter(elementCreatedAt));

    if (index == -1) {
      list.add(element);
    } else {
      list.insert(index, element);
    }
  }

  static Future DataDivided(value) async {
    CommonWidget.headerFotterlist = value;
    CommonWidget.headerFotterlist.forEach(
      (element) {
        if (element.category == "Header") {
          CommonWidget.headerlist.add(element);
          CommonWidget.optionsList.add(element.name!);
        } else {
          if (element.subcategory == "Fist Data") {
            CommonWidget.footerfirstlist.add(element);
          } else if (element.subcategory == "Explore") {
            CommonWidget.footerexplorelist.add(element);
          } else if (element.subcategory == "Policies") {
            CommonWidget.footerpolicylist.add(element);
          } else {
          }
        }
      },
    );
  }

  Future<List<CategoryModel>> Maincategory() async {
    try {
      final list = await ApiClient.instance.getList('/categories');
      return list.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<HeaderFooterModel>> HeaderandFooter() async {
    try {
      final list = await ApiClient.instance.getList('/others');
      return list.map((e) => HeaderFooterModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Widget Explore(context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Text(
            "Explore",
            style: TextStyle(
                fontFamily: AppFont.heading,
                fontSize: 24,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
                color: AppColor.BgColor),
          ),
          Container(
              margin: EdgeInsets.only(top: 6, bottom: 4),
              height: 2,
              width: 34,
              color: AppColor.accent),
          Wrap(
              runSpacing: 10,
              alignment: WrapAlignment.spaceAround,
              verticalDirection: VerticalDirection.down,
              children: List.generate(
                footerexplorelist.length,
                (index) {
                  return InkWell(
                    onTap: () {
                      print(
                          "footerexplorelist :: ${footerexplorelist[index].about}");
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (Beamer.of(context)
                                .configuration
                                .uri
                                .toString()
                                .contains("/Pages") ==
                            false) {
                          datamethod(context).then(
                            (value) {
                              WebAPPNavigation.navigateToroute(
                                  context: context,
                                  routename:
                                      '/Pages/${footerexplorelist[index].name!.replaceAll(' ', '-')}',
                                  data: {
                                    'htmldata': footerexplorelist[index].about
                                  },
                                  screen: HtmlConain(
                                    htmldata: footerexplorelist[index].about,
                                    title: footerexplorelist[index].name!,
                                  ));

                              Beamer.of(context).update();
                            },
                          );
                        } else {
                          WebAPPNavigation.navigateToroute(
                              context: context,
                              routename:
                                  '/Page/${footerexplorelist[index].name!.replaceAll(' ', '-')}',
                              data: {
                                'htmldata': footerexplorelist[index].about
                              },
                              screen: HtmlConain(
                                htmldata: footerexplorelist[index].about,
                                title: footerexplorelist[index].name!,
                              ));
                        }
                      });
                    },
                    child: Explorecontent(
                        title: footerexplorelist[index].name,
                        divider: index == (footerexplorelist.length - 1)
                            ? false
                            : true),
                  );
                },
              )),
        ],
      ),
    );
  }

  Widget Policies(context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Text(
            "Policies",
            style: TextStyle(
                fontFamily: AppFont.heading,
                fontSize: 24,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
                color: AppColor.BgColor),
          ),
          Container(
              margin: EdgeInsets.only(top: 6, bottom: 4),
              height: 2,
              width: 34,
              color: AppColor.accent),
          Wrap(
              runSpacing: 10,
              alignment: WrapAlignment.spaceAround,
              verticalDirection: VerticalDirection.down,
              children: List.generate(
                footerpolicylist.length,
                (index) {
                  return InkWell(
                    onTap: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (Beamer.of(context)
                                .configuration
                                .uri
                                .toString()
                                .contains("/Pages") ==
                            false) {
                          datamethod(context).then(
                            (value) {
                              WebAPPNavigation.navigateToroute(
                                  context: context,
                                  routename:
                                      '/Pages/${footerpolicylist[index].name!.replaceAll(' ', '-')}',
                                  data: {
                                    'htmldata': footerpolicylist[index].about
                                  },
                                  screen: HtmlConain(
                                    htmldata: footerpolicylist[index].about,
                                    title: footerpolicylist[index].name!,
                                  ));

                              Beamer.of(context).update();
                            },
                          );
                        } else {
                          WebAPPNavigation.navigateToroute(
                              context: context,
                              routename:
                                  '/Page/${footerpolicylist[index].name!.replaceAll(' ', '-')}',
                              data: {'htmldata': footerpolicylist[index].about},
                              screen: HtmlConain(
                                htmldata: footerpolicylist[index].about,
                                title: footerpolicylist[index].name!,
                              ));
                          // Beamer.of(context).beamToNamed(
                          //     '/Page/${footerpolicylist[index].name!.replaceAll(' ', '-')}',
                          //     data: {
                          //       'htmldata': footerpolicylist[index].about
                          //     });
                        }
                      });
                    },
                    child: Explorecontent(
                        title: footerpolicylist[index].name,
                        divider: index == (footerpolicylist.length - 1)
                            ? false
                            : true),
                  );
                },
              )),
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

  Widget SeviceSet(
    BuildContext context, {
    title,
    subtitle,
    image,
    divider,
  }) {
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
            child: CachedNetworkImage(
              imageUrl: image,
              imageBuilder: (context, imageProvider) {
                return Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                );
              },
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                color: AppColor.BlackColor,
              )),
              errorWidget: (context, url, error) => Container(
                height: 60,
                width: 60,
                child: Icon(
                  Icons.error,
                  color: AppColor.whiteColor,
                ),
              ),
            ),
            // SvgPicture.network(
            //   image,
            //   color: AppColor.BgColor,
            //   height: 40,
            // ),
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

  Widget SeviceSetNew(
    BuildContext context, {
    title,
    subtitle,
    image,
    divider,
  }) {
    return Container(
      padding: EdgeInsets.only(right: 15, left: 15),
      decoration: BoxDecoration(
          // border: Border(
          //     right: divider == false
          //         ? BorderSide.none
          //         : BorderSide(color: Colors.white, width: 1))

          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width < 600.0 ? 8.0 : 20.0),
            child: CachedNetworkImage(
              imageUrl: image,
              imageBuilder: (context, imageProvider) {
                return Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                );
              },
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                color: AppColor.BlackColor,
              )),
              errorWidget: (context, url, error) => Container(
                height: 60,
                width: 60,
                child: Icon(
                  Icons.error,
                  color: AppColor.whiteColor,
                ),
              ),
            ),
            // SvgPicture.network(
            //   image,
            //   color: AppColor.BgColor,
            //   height: 40,
            // ),
          ),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     FittedBox(
          //       child: Text(
          //         title,
          //         style: TextStyle(
          //           fontSize: 18,
          //           color: AppColor.BgColor,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     ),
          //     FittedBox(
          //       child: Text(
          //         title,
          //         style: TextStyle(
          //           fontSize: 14,
          //           color: AppColor.BgColor,
          //           fontWeight: FontWeight.w400,
          //         ),
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
    );
  }
}

/// Navbar link with refined uppercase typography and an animated rose
/// underline on hover. The parent InkWell handles the tap.
class NavText extends StatefulWidget {
  final String text;
  const NavText(this.text, {super.key});
  @override
  State<NavText> createState() => _NavTextState();
}

class _NavTextState extends State<NavText> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width < 550 ? 12.5 : 14.5;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.text.toUpperCase(),
            style: TextStyle(
              fontSize: size,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w600,
              color: _hover ? AppColor.primary : AppColor.ink,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 2,
            width: _hover ? 22 : 0,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItem {
  const MenuItem({
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;
}

abstract class MenuItems {
  static const List<MenuItem> firstItems = [home, share, settings];
  static const List<MenuItem> secondItems = [logout];
  static const List<MenuItem> unverifyed = [login];

  static const home = MenuItem(text: 'Profile', icon: Icons.person);
  static const login = MenuItem(text: 'Login', icon: Icons.login);
  static const share =
      MenuItem(text: 'Billing Address', icon: Icons.add_home_work_sharp);
  static const settings =
      MenuItem(text: 'Order Data', icon: Icons.arrow_circle_up);
  static const logout = MenuItem(text: 'Log Out', icon: Icons.logout);

  static Widget buildItem(MenuItem item) {
    return Row(
      children: [
        Icon(item.icon, color: AppColor.primary, size: 20),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Text(
            item.text,
            style: TextStyle(
                color: AppColor.ink,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  static void onChanged(BuildContext context, MenuItem item) async {
    switch (item) {
      case MenuItems.home:
        WebAPPNavigation.navigateToroute(
            context: context,
            routename: '/UpdateProfile',
            screen: UpdateProfile());

        //Do something
        break;
      case MenuItems.settings:

        //Do something
        break;
      case MenuItems.share:
        //Do something

        break;
      case MenuItems.logout:
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        preferences.clear();

        WebAPPNavigation.navigateToroute(
            context: context,
            routename: '/HomePage',
            screen: BottomBar(
              pageindex: 0,
            ));

        break;
    }
  }
}

/// Nykaa-style secondary category bar: a horizontal row of all categories,
/// each opening a subcategory dropdown that slides down (shutter) on hover.
class CategoryMegaNavBar extends StatefulWidget {
  const CategoryMegaNavBar({super.key});

  @override
  State<CategoryMegaNavBar> createState() => _CategoryMegaNavBarState();
}

class _CategoryMegaNavBarState extends State<CategoryMegaNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 280),
        value: CommonWidget.categoriesOpen.value ? 1 : 0);
    CommonWidget.categoriesOpen.addListener(_onToggle);
  }

  void _onToggle() {
    if (!mounted) return;
    if (CommonWidget.categoriesOpen.value) {
      _anim.forward();
    } else {
      _anim.reverse();
    }
  }

  @override
  void dispose() {
    CommonWidget.categoriesOpen.removeListener(_onToggle);
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cats = CommonWidget.categorylist;
    if (cats.isEmpty) return const SizedBox.shrink();
    // Shutter: the whole bar reveals downward only when "Categories" is open.
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
      axisAlignment: -1.0,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          border: Border(
              bottom: BorderSide(color: AppColor.dividercolor, width: 1)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children:
                cats.map((c) => _CategoryHoverItem(category: c)).toList(),
          ),
        ),
      ),
    );
  }
}

class _CategoryHoverItem extends StatefulWidget {
  const _CategoryHoverItem({required this.category});
  final CategoryModel category;

  @override
  State<_CategoryHoverItem> createState() => _CategoryHoverItemState();
}

class _CategoryHoverItemState extends State<_CategoryHoverItem>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  late final AnimationController _anim;
  Timer? _closeTimer;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 240));
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  bool get _hasSubs =>
      widget.category.parentId != null &&
      widget.category.parentId!.isNotEmpty;

  void _open() {
    if (!_hasSubs) return;
    _closeTimer?.cancel();
    if (mounted) setState(() => _hovering = true);
    // Defer showing the overlay (which contains its own MouseRegion) until
    // after the current pointer-event / mouse-tracking pass completes.
    // Adding a MouseRegion to the tree mid hit-test triggers the
    // `mouse_tracker.dart:199` assertion on Flutter web.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_hovering) return;
      if (!_portal.isShowing) _portal.show();
      _anim.forward();
    });
  }

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 140), _close);
  }

  void _close() {
    if (!mounted) return;
    setState(() => _hovering = false);
    _anim.reverse().then((_) {
      if (!mounted || _anim.value != 0 || !_portal.isShowing) return;
      // Defer hiding for the same reason as _open(): removing the overlay's
      // MouseRegion must not happen during pointer-event dispatch.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hovering && _portal.isShowing) _portal.hide();
      });
    });
  }

  void _goCategory() {
    WebAPPNavigation.navigateToroute(
      context: context,
      routename: '/CategoryPage/${widget.category.name.replaceAll(' ', '-')}',
      data: {'id': widget.category.id},
      screen: CategoryPage(id: widget.category.id),
    );
  }

  void _goSub(Subcategory sub) {
    WebAPPNavigation.navigateToroute(
      context: context,
      routename:
          '/CategoryPages/${(sub.name ?? '').replaceAll(' ', '-')}',
      data: {'id': widget.category.id, 'subname': sub.id},
      screen: CategoryPage(id: widget.category.id, subname: sub.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (ctx) => _dropdown(),
        child: MouseRegion(
          onEnter: (_) => _open(),
          onExit: (_) => _scheduleClose(),
          child: InkWell(
            onTap: _goCategory,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.category.name.toUpperCase(),
                    style: TextStyle(
                        fontSize: 12.5,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w600,
                        color: _hovering ? AppColor.primary : AppColor.ink),
                  ),
                  if (_hasSubs) ...[
                    const SizedBox(width: 5),
                    AnimatedRotation(
                      turns: _hovering ? 0.5 : 0,
                      duration: const Duration(milliseconds: 240),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: _hovering
                              ? AppColor.primary
                              : AppColor.fontColorgrey),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdown() {
    final subs = widget.category.parentId ?? [];
    return CompositedTransformFollower(
      link: _link,
      targetAnchor: Alignment.bottomLeft,
      followerAnchor: Alignment.topLeft,
      offset: const Offset(0, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: MouseRegion(
          onEnter: (_) => _closeTimer?.cancel(),
          onExit: (_) => _scheduleClose(),
          // Shutter: the panel reveals downward from the top edge.
          child: SizeTransition(
            sizeFactor:
                CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
            axisAlignment: -1.0,
            child: FadeTransition(
              opacity: _anim,
              child: Container(
                margin: const EdgeInsets.only(top: 2),
                constraints:
                    const BoxConstraints(minWidth: 220, maxHeight: 420),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Appborder.appborder,
                  boxShadow: Appshadow.soft,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: subs.map((s) => _subRow(s)).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _subRow(Subcategory s) {
    return InkWell(
      onTap: () => _goSub(s),
      hoverColor: AppColor.blush,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chevron_right_rounded, size: 16, color: AppColor.primary),
            const SizedBox(width: 8),
            Text(s.name ?? '',
                style: TextStyle(
                    fontSize: 13.5,
                    color: AppColor.ink,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
