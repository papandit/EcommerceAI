import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/category/category_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import 'responsive_screens/create_brand_desktop.dart';
import 'responsive_screens/create_brand_mobile.dart';
import 'responsive_screens/create_brand_tablet.dart';

class CreateBrandScreen extends StatelessWidget {
  const CreateBrandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.put(CategoryController());

    return const TSiteTemplate(
      desktop: CreateBrandDesktopScreen(),
      tablet: CreateBrandTabletScreen(),
      mobile: CreateBrandMobileScreen(),
    );
  }
}
