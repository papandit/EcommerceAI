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
      if (routeinfo.uri.pathSegments.contains('ProductDetailScreen')) {
        return ProductDetailScreenLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('TryOnHistory')) {
        return TryOnHistoryLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('TryOn')) {
        return TryOnLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('HomePage')) {
        return HomeLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('SpleshPage')) {
        return SpleshLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('BottomBar')) {
        return BottomBarLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('FavoritePage')) {
        return FavoritePageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('FilterPage')) {
        return FilterPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('ForgotpasswordPage')) {
        return ForgotpasswordPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('Pages')) {
        return HtmlConainLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('Page')) {
        return HtmlConainCopyLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('IntroPage')) {
        return IntroPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('LegalPolicy')) {
        return LegalPolicyLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('LoginPage')) {
        return LoginPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('Myaddresses')) {
        return MyaddressesLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('MyOrderPage')) {
        return MyOrderPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('SuccessPage')) {
        return SuccessPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('NotificationPage')) {
        return NotificationPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('DeliveryAdressadd')) {
        return DeliveryAdressaddLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('Verifyotp')) {
        return VerifyotpLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('CategoryPage')) {
        return CategoryPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('CategoryPages')) {
        return CategoryPageCopyLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('ViewAll')) {
        return ViewAllLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('DeliveryAdress')) {
        return DeliveryAdressLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('DeliveryAdressadds')) {
        return DeliveryAdressaddsLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('OrderDetails')) {
        return OrderDetailsLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('PopularPage')) {
        return PopularPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('ProfilePage')) {
        return ProfilePageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('RegisterPage')) {
        return RegisterPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('ReviewPage')) {
        return ReviewPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('SearchPage')) {
        return SearchPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('ShoppingPage')) {
        return ShoppingPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('UpdateProfile')) {
        return UpdateProfileLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('CheckoutPage')) {
        return CheckoutPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('ChnagepasswordPage')) {
        return ChnagepasswordPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('CategoryViewallPage')) {
        return CategoryViewallPageLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('ContectUs')) {
        return ContectUsLocation(routeinfo, data!);
      } else if (routeinfo.uri.pathSegments.contains('AllProducts')) {
        return AllProductsLocation(routeinfo, data!);
      } else {
        return SpleshLocation(routeinfo, data!);
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
