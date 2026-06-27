import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/other_brand/other_create_brand/widgets/Other_create_brand_form.dart';
import 'package:flutter/material.dart';

import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/sizes.dart';

class OtherCreateBrandTabletScreen extends StatelessWidget {
  const OtherCreateBrandTabletScreen({
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
                  heading: 'Create Brand',
                  breadcrumbItems: [TRoutes.brands, 'Create Brand']),
              SizedBox(height: TSizes.spaceBtwSections),

              // Form
              OtherCreateBrandForm(),
            ],
          ),
        ),
      ),
    );
  }
}
