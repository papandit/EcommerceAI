import 'package:flutter/material.dart';

import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../widgets/create_notification_form.dart';

class CreateNotificationTabletScreen extends StatelessWidget {
  const CreateNotificationTabletScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TBreadcrumbsWithHeading(
                  returnToPreviousScreen: true,
                  heading: 'Create Notification',
                  breadcrumbItems: [
                    TRoutes.createnotification,
                    'Create Notification'
                  ]),
              SizedBox(height: TSizes.spaceBtwSections),

              // Form
              CreateNotificationForm(),
            ],
          ),
        ),
      ),
    );
  }
}
