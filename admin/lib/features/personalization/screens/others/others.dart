import 'package:cwt_ecommerce_admin_panel/common/widgets/layouts/templates/site_layout.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/responsive_screens/other_desktop.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/responsive_screens/other_mobile.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/responsive_screens/other_teblet.dart';
import 'package:flutter/material.dart';

class OthersScreen extends StatelessWidget {
  const OthersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
        desktop: OtherDesktopScreen(),
        // desktop: OtherScreen(),
        // desktop: CreatePage(),
        tablet: OtherTebletScreen(),
        mobile: OtherMobileScreen());
  }
}
