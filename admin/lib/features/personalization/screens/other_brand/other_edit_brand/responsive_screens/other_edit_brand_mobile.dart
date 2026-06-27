import 'package:cwt_ecommerce_admin_panel/features/personalization/models/other_brand_model.dart';
import 'package:flutter/material.dart';

import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../widgets/other_edit_brand_form.dart';

class OtherEditBrandMobileScreen extends StatelessWidget {
  const OtherEditBrandMobileScreen({super.key, required this.brand});

  final OtherBrandModel brand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TBreadcrumbsWithHeading(
                  returnToPreviousScreen: true,
                  heading: 'Create Field',
                  breadcrumbItems: [TRoutes.editOther, 'Create Field']),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Form
              OtherEditBrandForm(
                brand: brand,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
