import 'package:cwt_ecommerce_admin_panel/features/shop/screens/review/create_review/widgets/create_review_form.dart';
import 'package:flutter/material.dart';

import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/sizes.dart';

class CreateReviewDesktopScreen extends StatelessWidget {
  const CreateReviewDesktopScreen({super.key});

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
              TBreadcrumbsWithHeading(
                  returnToPreviousScreen: true,
                  heading: 'Create Review',
                  breadcrumbItems: [TRoutes.review, 'Create Review']),
              SizedBox(height: TSizes.spaceBtwSections),

              // Form
              CreateReviewForm(),
            ],
          ),
        ),
      ),
    );
  }
}
