import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/profile/responsive_screens/profile_desktop.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/profile/responsive_screens/profile_mobile.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/profile/responsive_screens/profile_tablet.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/layouts/templates/site_layout.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
        desktop: ProfileDesktopScreen(),
        tablet: ProfileTabletScreen(),
        mobile: ProfileMobileScreen());
  }
}
