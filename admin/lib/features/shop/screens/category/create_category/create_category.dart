import 'package:flutter/material.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import 'responsive_screens/create_category_desktop.dart';
import 'responsive_screens/create_category_mobile.dart';
import 'responsive_screens/create_category_tablet.dart';

class CreateCategoryScreen extends StatelessWidget {
  const CreateCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
      desktop: CreateCategoryDesktopScreen(),
      tablet: CreateCategoryTabletScreen(),
      mobile: CreateCategoryMobileScreen(),
    );
  }
}
