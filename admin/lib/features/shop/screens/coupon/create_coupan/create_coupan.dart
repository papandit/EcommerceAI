import 'package:flutter/material.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import 'responsive_screens/create_coupan_desktop.dart';
import 'responsive_screens/create_coupan_mobile.dart';
import 'responsive_screens/create_coupan_tablet.dart';

class CreateCoupanScreen extends StatelessWidget {
  const CreateCoupanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
      desktop: CreateCoupanDesktopScreen(),
      tablet: CreateCoupanMobileScreen(),
      mobile: CreateCoupanTabletScreen(),
    );
  }
}
