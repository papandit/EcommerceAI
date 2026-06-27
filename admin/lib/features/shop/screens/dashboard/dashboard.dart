import 'package:cwt_ecommerce_admin_panel/features/shop/screens/dashboard/responsive_screens/dashboard_desktop.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/dashboard/responsive_screens/dashboard_mobile.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/dashboard/responsive_screens/dashboard_tablet.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/layouts/templates/site_layout.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(desktop: DashboardDesktopScreen(), tablet: DashboardTabletScreen(), mobile: DashboardMobileScreen());
  }
}
