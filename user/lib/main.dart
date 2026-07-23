// ignore_for_file: prefer_const_constructors, implicit_call_tearoffs, deprecated_member_use, avoid_print, unnecessary_brace_in_string_interps, avoid_web_libraries_in_flutter, prefer_typing_uninitialized_variables, avoid_function_literals_in_foreach_calls, must_be_immutable, non_constant_identifier_names

import 'dart:ui';
import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/main_screen_locatin.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:EcommerceApp/helper/itemprovioder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

SharedPreferences? perfs;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  perfs = await SharedPreferences.getInstance();

  // Load the JWT (if any) so authenticated API calls work after a restart.
  await ApiClient.instance.loadToken();

  CommonWidget().Maincategory().then(
    (value) {
      value.forEach(
        (element) {
          CommonWidget.categorylist.add(element);
          CommonWidget.categorylsit.add(element.name);
          CommonWidget.categorylistid.add(element.id);
        },
      );
    },
  );
  CommonWidget.HeaderandFooter().then(
    (values) {
      CommonWidget.headerFotterlist.clear();
      CommonWidget.headerlist.clear();
      CommonWidget.optionsList.clear();
      CommonWidget.footerfirstlist.clear();
      CommonWidget.footerexplorelist.clear();
      CommonWidget.footerpolicylist.clear();
      CommonWidget.DataDivided(values).then(
        (value) {
          print(
              "CommonWidget.footerfirstlist ::  ${CommonWidget.footerfirstlist}");
        },
      );
    },
  );
  CommonWidget().getuserdata();
  CommonWidget().cartdacheck();
  if (kIsWeb) {
    setPathUrlStrategy(); // Apply only for web
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final routerDelegate = BeamerDelegate(
    transitionDelegate: NoAnimationTransitionDelegate(),
    locationBuilder: (routeinfo, data) {
      // Beamer passes `data` as nullable: it is only non-null when we navigate
      // in-app via beamToNamed(..., data: ...). Browser back/forward, a page
      // refresh or a pasted deep link all call this with null — force-unwrapping
      // it crashed the route build, which is why the back button appeared dead.
      final params = data ?? const BeamParameters();
      if (routeinfo.uri.pathSegments.contains('ProductDetailScreen')) {
        return ProductDetailScreenLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('TryOnHistory')) {
        return TryOnHistoryLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('TryOn')) {
        return TryOnLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('HomePage')) {
        return HomeLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('SpleshPage')) {
        return SpleshLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('BottomBar')) {
        return BottomBarLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('FavoritePage')) {
        return FavoritePageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('FilterPage')) {
        return FilterPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('ForgotpasswordPage')) {
        return ForgotpasswordPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('Pages')) {
        return HtmlConainLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('Page')) {
        return HtmlConainCopyLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('IntroPage')) {
        return IntroPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('LegalPolicy')) {
        return LegalPolicyLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('LoginPage')) {
        return LoginPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('Myaddresses')) {
        return MyaddressesLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('MyOrderPage')) {
        return MyOrderPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('SuccessPage')) {
        return SuccessPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('NotificationPage')) {
        return NotificationPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('DeliveryAdressadd')) {
        return DeliveryAdressaddLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('Verifyotp')) {
        return VerifyotpLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('CategoryPage')) {
        return CategoryPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('CategoryPages')) {
        return CategoryPageCopyLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('ViewAll')) {
        return ViewAllLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('DeliveryAdress')) {
        return DeliveryAdressLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('DeliveryAdressadds')) {
        return DeliveryAdressaddsLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('OrderDetails')) {
        return OrderDetailsLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('PopularPage')) {
        return PopularPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('ProfilePage')) {
        return ProfilePageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('RegisterPage')) {
        return RegisterPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('ReviewPage')) {
        return ReviewPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('SearchPage')) {
        return SearchPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('ShoppingPage')) {
        return ShoppingPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('UpdateProfile')) {
        return UpdateProfileLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('CheckoutPage')) {
        return CheckoutPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('ChnagepasswordPage')) {
        return ChnagepasswordPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('CategoryViewallPage')) {
        return CategoryViewallPageLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('ContectUs')) {
        return ContectUsLocation(routeinfo, params);
      } else if (routeinfo.uri.pathSegments.contains('AllProducts')) {
        return AllProductsLocation(routeinfo, params);
      } else {
        return SpleshLocation(routeinfo, params);
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return GetMaterialApp.router(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          /*Add this*/
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.unknown,
        },
      ),
      title: 'E-CommerceApp',
      theme: AppTheme.light,

      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
      debugShowCheckedModeBanner: false,
      backButtonDispatcher:
          BeamerBackButtonDispatcher(delegate: routerDelegate),
      // home: SpleshPage(),
    );
  }
}
