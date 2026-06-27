import 'package:flutter/material.dart';

import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../widgets/image_meta.dart';
import '../widgets/settings_form.dart';

class SettingsMobileScreen extends StatelessWidget {
  const SettingsMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumbs
              TBreadcrumbsWithHeading(heading: 'Settings', breadcrumbItems: ['Settings']),
              SizedBox(height: TSizes.spaceBtwSections),

              Column(
                children: [
                  ImageAndMeta(),
                  SizedBox(height: TSizes.spaceBtwSections),

                  // Form
                  SettingsForm(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
