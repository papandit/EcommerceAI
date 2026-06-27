// ignore_for_file: non_constant_identifier_names

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebAPPNavigation {
  static Future<void> navigateToroute(
      {context, routename, screen, data}) async {
    if (!kIsWeb) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    } else {
      Beamer.of(context).beamToNamed(routename, data: data);
    }
  }

  static Future<void> navigateTo({
    context,
  }) async {
    if (!kIsWeb) {
      Navigator.pop(context);
    } else {
      Beamer.of(context).beamBack();
    }
  }

  static Future<void> navigateToCart(
      {context, Function? WebTap, Function? AndroidTap}) async {
    if (kIsWeb) {
      WebTap!.call();
    } else {
      AndroidTap!.call();
    }
  }
}
