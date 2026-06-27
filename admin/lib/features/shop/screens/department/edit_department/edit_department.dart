import 'package:cwt_ecommerce_admin_panel/features/shop/screens/department/edit_department/responsive_screens/edit_department_desktop.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/department/edit_department/responsive_screens/edit_department_mobile.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/department/edit_department/responsive_screens/edit_department_tablet.dart';
import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../common/widgets/layouts/templates/site_layout.dart';

class EditDepartMentScreen extends StatelessWidget {
  const EditDepartMentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final category = Get.arguments;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (category == null) {
        Get.offAllNamed(TRoutes.dashboard);
      }
    });
    return TSiteTemplate(
      desktop: EditDepartMentDesktopScreen(category: category),
      tablet: EditDepartMentTabletScreen(category: category),
      mobile: EditDepartMentMobileScreen(category: category),
    );
  }
}
