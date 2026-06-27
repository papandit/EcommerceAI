import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../routes/routes.dart';
import '../../../utils/constants/colors.dart';

class TBreadcrumbs extends StatelessWidget {
  final List<String> breadcrumbItems;

  // Constructor for TBreadcrumbs widget
  const TBreadcrumbs({super.key, required this.breadcrumbItems});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Home Icon
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.offAllNamed(TRoutes.dashboard),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(Iconsax.home_copy, color: TColors.grey),
              ),
            ),
          ],
        ),
        // Breadcrumb items
        for (int i = 0; i < breadcrumbItems.length; i++)
          Row(
            children: [
              const Text('-'), // Separator
              InkWell(
                onTap: () => Get.toNamed(
                    breadcrumbItems[i]), // Navigate to the corresponding route
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    i ==
                            breadcrumbItems.length -
                                1 // Capitalize the last breadcrumb item
                        ? breadcrumbItems[i].capitalize.toString()
                        : capitalize(breadcrumbItems[i].substring(1)),
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // Function to capitalize the first letter of a string
  String capitalize(String s) {
    return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  }
}
