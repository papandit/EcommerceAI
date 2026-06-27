import 'package:cwt_ecommerce_admin_panel/common/widgets/layouts/templates/site_layout.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/department/all_department/responsive_screen/department_desktop.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/department/all_department/responsive_screen/department_mobile.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/department/all_department/responsive_screen/department_teblet.dart';
import 'package:flutter/material.dart';

class DepartmentScreen extends StatelessWidget {
  const DepartmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
        desktop: DepartmentDesktopScreen(),
        tablet: DepartmentTebletScreen(),
        mobile: DepartmentMobileScreen());
  }
}
