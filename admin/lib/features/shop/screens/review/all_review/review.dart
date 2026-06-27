import 'package:cwt_ecommerce_admin_panel/features/shop/screens/review/all_review/responsive_screens/review_desktop.dart';
import 'package:flutter/material.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';

import 'responsive_screens/review_mobile.dart';
import 'responsive_screens/review_tablet.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
        desktop: ReviewDesktopScreen(),
        tablet: ReviewTabletScreen(),
        mobile: ReviewMobileScreen());
  }
}
