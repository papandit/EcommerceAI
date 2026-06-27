import 'package:cwt_ecommerce_admin_panel/features/personalization/controllers/settings_controller.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import 'menu/menu_item.dart';
import 'sidebar_controller.dart';

/// Sidebar widget for navigation menu
class TSidebar extends StatelessWidget {
  const TSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const BeveledRectangleBorder(),
      child: Container(
        decoration: const BoxDecoration(
          color: TColors.white,
          border:
              Border(right: BorderSide(width: 1, color: TColors.borderPrimary)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TSizes.sm),
              Obx(() {
                final collapsed = SidebarController.instance.collapsed.value;
                final logo = SettingsController.instance.settings.value.appLogo;
                final name = SettingsController.instance.settings.value.appName;
                final brandIcon = Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color:
                        logo.isNotEmpty ? Colors.transparent : TColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: logo.isNotEmpty
                      ? Image.network(logo,
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(
                              Icons.shopping_bag_rounded,
                              color: Colors.white,
                              size: 22))
                      : const Icon(Icons.shopping_bag_rounded,
                          color: Colors.white, size: 22),
                );
                if (collapsed) {
                  // Keep the logo in the SAME left/top position as expanded —
                  // only the name + toggle direction change.
                  return Padding(
                    padding: const EdgeInsets.only(left: TSizes.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        brandIcon,
                        const SizedBox(height: 4),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: SidebarController.instance.toggleCollapsed,
                          tooltip: 'Expand',
                          icon: const Icon(Icons.chevron_right,
                              color: TColors.primary),
                        ),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(left: TSizes.sm),
                  child: Row(
                    children: [
                      brandIcon,
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          name.isEmpty ? 'E-Fashion' : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall!.apply(
                              color: TColors.primary, fontWeightDelta: 2),
                        ),
                      ),
                      IconButton(
                        onPressed: SidebarController.instance.toggleCollapsed,
                        tooltip: 'Collapse',
                        icon: const Icon(Icons.chevron_left,
                            color: TColors.primary),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(
                  color: TColors.borderPrimary, height: 1, thickness: 1),
              const SizedBox(height: TSizes.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => SidebarController.instance.collapsed.value
                        ? const SizedBox(height: 4)
                        : Text('MENU',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .apply(letterSpacingDelta: 1.2))),
                    // Menu Items
                    const TMenuItem(
                        route: TRoutes.dashboard,
                        icon: Icons.dashboard_outlined,
                        itemName: 'Dashboard'),
                    const TMenuItem(
                        route: TRoutes.media,
                        icon: Icons.perm_media_outlined,
                        itemName: 'Media'),
                    const TMenuItem(
                        route: TRoutes.banners,
                        icon: Icons.image_outlined,
                        itemName: 'Banners'),
                    const TMenuItem(
                        route: TRoutes.luxeEdit,
                        icon: Icons.workspace_premium_outlined,
                        itemName: 'Luxe Edit'),
                    const TMenuItem(
                        route: TRoutes.products,
                        icon: Icons.shopping_bag_outlined,
                        itemName: 'Products'),
                    const TMenuItem(
                        route: TRoutes.categories,
                        icon: Icons.category_outlined,
                        itemName: 'Categories'),
                    const TMenuItem(
                        route: TRoutes.brands,
                        icon: Icons.sell_outlined,
                        itemName: 'Brands'),
                    const TMenuItem(
                        route: TRoutes.department,
                        icon: Icons.account_tree_outlined,
                        itemName: 'Department'),
                    const TMenuItem(
                        route: TRoutes.customers,
                        icon: Icons.people_alt_outlined,
                        itemName: 'Customers'),
                    const TMenuItem(
                        route: TRoutes.orders,
                        icon: Icons.receipt_long_outlined,
                        itemName: 'Orders'),
                    const TMenuItem(
                        route: TRoutes.coupons,
                        icon: Icons.local_offer_outlined,
                        itemName: 'Coupons'),
                    const SizedBox(height: TSizes.sm),
                    Obx(() => SidebarController.instance.collapsed.value
                        ? const SizedBox(height: 4)
                        : Text('OTHER',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .apply(letterSpacingDelta: 1.2))),
                    // Other menu items
                    const TMenuItem(
                        route: TRoutes.others,
                        icon: Icons.description_outlined,
                        itemName: 'Others'),
                    // const TMenuItem(
                    //     route: TRoutes.notification,
                    //     icon: Iconsax.notification,
                    //     itemName: 'Notifications'),
                    const TMenuItem(
                        route: TRoutes.review,
                        icon: Icons.star_border,
                        itemName: 'Reviews'),
                    const TMenuItem(
                        route: TRoutes.profile,
                        icon: Icons.person_outline,
                        itemName: 'Profile'),
                    const TMenuItem(
                        route: TRoutes.settings,
                        icon: Icons.settings_outlined,
                        itemName: 'Settings'),
                    const TMenuItem(
                        route: 'logout',
                        icon: Icons.logout,
                        itemName: 'Logout'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
