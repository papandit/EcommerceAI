import 'package:cwt_ecommerce_admin_panel/features/shop/screens/review/create_review/responsive_screens/create_review_desktop.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/review/create_review/responsive_screens/create_review_mobile.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/review/create_review/responsive_screens/create_review_tablet.dart';
import 'package:flutter/material.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';

class CreateReviewScreen extends StatelessWidget {
  const CreateReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
      desktop: CreateReviewDesktopScreen(),
      tablet: CreateReviewMobileScreen(),
      mobile: CreateReviewTabletScreen(),
    );
  }
}
