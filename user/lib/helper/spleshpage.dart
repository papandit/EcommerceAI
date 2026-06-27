// ignore_for_file: prefer_const_constructors, unnecessary_brace_in_string_interps, prefer_interpolation_to_compose_strings

import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/bottom_bar.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/platformcheck.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/headerfootermodel.dart';
import 'package:EcommerceApp/model/productmodel.dart';
import 'package:EcommerceApp/view/intropage.dart';
import 'package:flutter/material.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpleshPage extends StatefulWidget {
  const SpleshPage({super.key});

  @override
  State<SpleshPage> createState() => _SpleshPageState();
}

class _SpleshPageState extends State<SpleshPage> {
  HeaderFooterModel? headerFooterModel;
  List<HeaderFooterModel> headerFooterModelList = [];

  @override
  void initState() {
    Authchecker().then(
      (value) async {
        DataDivided(value).then(
          (value) {
            if (isLogin == false) {
              Future.delayed(Duration(seconds: 2), () {
                if (mounted) {
                  WebAPPNavigation.navigateToroute(
                      context: context,
                      routename: '/HomePage',
                      screen: BottomBar(
                        pageindex: 0,
                      ));
                }
              });
            } else {

              WebAPPNavigation.navigateToroute(
                  context: context,
                  routename: '/HomePage',
                  screen: BottomBar(
                    pageindex: 0,
                  ));
            }
          },
        );
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.BgColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/image/onewebmart_logo.png",
                width: 260,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              CircularProgressIndicator(
                color: AppColor.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isLogin = false;
  bool isIntro = false;

  Future Authchecker() async {
    // var isLogin =
    //     Preference.preference.getBool(defVal: false, key: prefrenceKey.isLogin);

    final SharedPreferences pref = await SharedPreferences.getInstance();
    isLogin = pref.getBool(prefrenceKey.isLogin) ?? false;
    isIntro = pref.getBool('Intro') ?? false;
    setState(() {});
  }

  Future DataDivided(value) async {
    // var isLogin =
    //     Preference.preference.getBool(defVal: false, key: prefrenceKey.isLogin);

    // setState(() {
    //   CommonWidget.headerFotterlist = value;
    // });

    // CommonWidget.headerFotterlist.forEach(
    //   (element) {
    //     if (element.category == "Header") {
    //       CommonWidget.headerlist.add(element);
    //       CommonWidget.optionsList.add(element.name!);
    //     } else {
    //       if (element.subcategory == "Fist Data") {
    //         CommonWidget.footerfirstlist.add(element);
    //       } else if (element.subcategory == "Explore") {
    //         CommonWidget.footerexplorelist.add(element);
    //       } else if (element.subcategory == "Policies") {
    //         CommonWidget.footerpolicylist.add(element);
    //       }
    //     }
    //   },
    // );

    Future.delayed(
      Duration(seconds: 2),
      () {
        print(
            " CommonWidget.footerfirstlist :: ${CommonWidget.footerfirstlist}");
        print(
            " CommonWidget.footerexplorelist :: ${CommonWidget.footerexplorelist}");
        print(
            " CommonWidget.footerpolicylist :: ${CommonWidget.footerpolicylist}");
      },
    );
  }

  Future<List<HeaderFooterModel>> HeaderandFooter() async {
    try {
      final list = await ApiClient.instance.getList('/others');
      if (mounted) setState(() {});
      return list.map((e) => HeaderFooterModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  void Data_Collect() async {
    if (isLogin == false) {
      isIntro || PlatformInfo().isWeb()
          ? WebAPPNavigation.navigateToroute(
              context: context,
              routename: '/HomePage',
              screen: BottomBar(pageindex: 0))
          : WebAPPNavigation.navigateToroute(
              context: context,
              routename: '/IntroPage',
              screen: IntroPage());
    } else {
      WebAPPNavigation.navigateToroute(
          context: context,
          routename: '/HomePage',
          screen: BottomBar(pageindex: 0));
    }
  }

  Future<List<CategoryModel>> Maincategory() async {
    try {
      final list = await ApiClient.instance.getList('/categories');
      if (mounted) setState(() {});
      return list.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
