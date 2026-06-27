import 'package:flutter/material.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import 'responsive_screens/create_notification_desktop.dart';
import 'responsive_screens/create_notification_mobile.dart';
import 'responsive_screens/create_notification_tablet.dart';

class CreateNotificationScreen extends StatelessWidget {
  const CreateNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
      desktop: CreateNotificationDesktopScreen(),
      tablet: CreatenotificationMobileScreen(),
      mobile: CreateNotificationTabletScreen(),
    );
  }
}
