import 'package:flutter/material.dart';

import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../widgets/create_banner_form.dart';

class CreateBannerTabletScreen extends StatelessWidget {
  const CreateBannerTabletScreen({
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
                  heading: 'Create Banner',
                  breadcrumbItems: [TRoutes.banners, 'Create Banner']),
              SizedBox(height: TSizes.spaceBtwSections),

              // Form
              CreateBannerForm(),
            ],
          ),
        ),
      ),
    );
  }
}
