import 'package:cwt_ecommerce_admin_panel/features/shop/models/review_model.dart';
import 'package:flutter/material.dart';

import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../widgets/edit_review_form.dart';

class EditReviewTabletScreen extends StatelessWidget {
  const EditReviewTabletScreen({super.key, required this.review});

  final ReviewModel review;

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
                  heading: 'Update Review',
                  breadcrumbItems: [TRoutes.review, 'Update Review']),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Form
              EditReviewForm(
                review: review,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
