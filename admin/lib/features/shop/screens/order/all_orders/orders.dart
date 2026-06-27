import 'package:flutter/material.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import 'responsive_screens/orders_desktop.dart';
import 'responsive_screens/orders_mobile.dart';
import 'responsive_screens/orders_tablet.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(desktop: OrdersDesktopScreen(), tablet: OrdersTabletScreen(), mobile: OrdersMobileScreen());
  }
}
