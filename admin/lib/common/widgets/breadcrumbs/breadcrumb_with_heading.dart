import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../routes/routes.dart';
import '../../../utils/constants/sizes.dart';
import '../texts/page_heading.dart';

class TBreadcrumbsWithHeading extends StatelessWidget {
  const TBreadcrumbsWithHeading({
    super.key,
    required this.breadcrumbItems,
    required this.heading,
    this.returnToPreviousScreen = false,
  });

  // The heading for the page
  final String heading;

  // List of breadcrumb items representing the navigation path
  final List<String> breadcrumbItems;

  // Flag indicating whether to include a button to return to the previous screen
  final bool returnToPreviousScreen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumb trail
        Row(
          children: [
            // Dashboard link
            InkWell(
              onTap: () => Get.offAllNamed(TRoutes.dashboard),
              child: Padding(
                padding: const EdgeInsets.all(TSizes.xs),
                child: Text(
                  'Dashboard',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .apply(fontWeightDelta: -1),
                ),
              ),
            ),
            // Breadcrumb items
            for (int i = 0; i < breadcrumbItems.length; i++)
              Row(
                children: [
                  const Text('/'), // Separator
                  InkWell(
                    // Last item should not be clickable
                    onTap: i == breadcrumbItems.length - 1
                        ? null
                        : () => Get.toNamed(breadcrumbItems[i]),
                    child: Padding(
                      padding: const EdgeInsets.all(TSizes.xs),
                      // Format breadcrumb item: capitalize and remove leading '/'
                      child: Text(
                        i == breadcrumbItems.length - 1
                            ? breadcrumbItems[i].capitalize.toString()
                            : capitalize(breadcrumbItems[i].substring(1)),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .apply(fontWeightDelta: -1),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: TSizes.sm),
        // Heading of the page
        Row(
          children: [
            if (returnToPreviousScreen)
              IconButton(
                  onPressed: () => _goBack(context),
                  icon: const Icon(Iconsax.arrow_left)),
            if (returnToPreviousScreen)
              const SizedBox(width: TSizes.spaceBtwItems),
            TPageHeading(heading: heading),
          ],
        ),
      ],
    );
  }

  // Robust back navigation. Sidebar navigation often replaces the route stack,
  // so Get.back()/Navigator.pop can have nothing to return to (the back arrow
  // then appears to "do nothing"). Prefer the explicit parent route from the
  // breadcrumb trail; fall back to popping, then to the dashboard.
  void _goBack(BuildContext context) {
    final routes = breadcrumbItems.where((e) => e.startsWith('/')).toList();
    if (routes.isNotEmpty) {
      Get.offAllNamed(routes.last);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.offAllNamed(TRoutes.dashboard);
    }
  }

  // Function to capitalize the first letter of a string
  String capitalize(String s) {
    return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  }
}
