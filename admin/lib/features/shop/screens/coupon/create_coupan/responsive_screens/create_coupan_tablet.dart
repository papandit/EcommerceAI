import 'package:flutter/material.dart';

import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../widgets/create_coupan_form.dart';

class CreateCoupanTabletScreen extends StatelessWidget {
  const CreateCoupanTabletScreen({
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
                  heading: 'Create Coupan',
                  breadcrumbItems: [TRoutes.coupons, 'Create Coupan']),
              SizedBox(height: TSizes.spaceBtwSections),

              // Form
              CreateCoupanForm(),
            ],
          ),
        ),
      ),
    );
  }
}
