import 'package:flutter/material.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import 'responsive_screens/create_product_desktop.dart';
import 'responsive_screens/create_product_mobile.dart';

class CreateProductScreen extends StatelessWidget {
  const CreateProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
        desktop: CreateProductDesktopScreen(),
        mobile: CreateProductMobileScreen());
  }
}
