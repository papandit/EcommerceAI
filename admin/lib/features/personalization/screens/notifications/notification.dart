import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/notifications/all_notification/responsive_screens/notification_desktop.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/notifications/all_notification/responsive_screens/notification_mobile.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/notifications/all_notification/responsive_screens/notification_tablet.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/layouts/templates/site_layout.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
        desktop: NotificationDesktopScreen(),
        tablet: NotificationTabletScreen(),
        mobile: NotificationMobileScreen());
  }
}
