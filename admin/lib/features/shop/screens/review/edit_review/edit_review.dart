import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import 'responsive_screens/edit_review_desktop.dart';
import 'responsive_screens/edit_review_mobile.dart';
import 'responsive_screens/edit_review_tablet.dart';

class EditReviewScreen extends StatelessWidget {
  const EditReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final review = Get.arguments;
    return TSiteTemplate(
      desktop: EditReviewDesktopScreen(review: review),
      tablet: EditReviewTabletScreen(review: review),
      mobile: EditReviewMobileScreen(review: review),
    );
  }
}
