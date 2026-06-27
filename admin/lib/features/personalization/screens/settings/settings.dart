import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/settings/responsive_screens/settings_desktop.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/settings/responsive_screens/settings_mobile.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/settings/responsive_screens/settings_tablet.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/layouts/templates/site_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(desktop: SettingsDesktopScreen(), tablet: SettingsTabletScreen(), mobile: SettingsMobileScreen());
  }
}
