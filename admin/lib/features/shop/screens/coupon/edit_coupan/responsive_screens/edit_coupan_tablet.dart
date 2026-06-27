import 'package:cwt_ecommerce_admin_panel/features/shop/models/coupan_model.dart';
import 'package:flutter/material.dart';

import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../widgets/edit_coupan_form.dart';

class EditCoupanTabletScreen extends StatelessWidget {
  const EditCoupanTabletScreen({super.key, required this.coupan});

  final CoupanModel coupan;

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
                  heading: 'Update Coupan',
                  breadcrumbItems: [TRoutes.coupons, 'Update Coupan']),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Form
              EditCoupanForm(
                coupan: coupan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
