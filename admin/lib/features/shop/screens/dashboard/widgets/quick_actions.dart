import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../routes/routes.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

/// Dashboard "Quick Actions" — fast shortcuts to the most-used admin tasks.
class TDashboardQuickActions extends StatelessWidget {
  const TDashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction('Add Product', Icons.add_shopping_cart_outlined,
          TRoutes.createProduct),
      _QuickAction('Add Category', Icons.category_outlined,
          TRoutes.createCategory),
      _QuickAction('Department', Icons.account_tree_outlined,
          TRoutes.department),
      _QuickAction('Add Brand', Icons.sell_outlined, TRoutes.createBrand),
      _QuickAction('Customers', Icons.people_alt_outlined, TRoutes.customers),
      _QuickAction('Orders', Icons.receipt_long_outlined, TRoutes.orders),
      _QuickAction('Add Banner', Icons.image_outlined, TRoutes.createBanner),
      _QuickAction('Coupons', Icons.local_offer_outlined, TRoutes.coupons),
      _QuickAction('Reviews', Icons.star_border, TRoutes.review),
      _QuickAction('Settings', Icons.settings_outlined, TRoutes.settings),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: TSizes.spaceBtwItems),
        Wrap(
          spacing: TSizes.spaceBtwItems,
          runSpacing: TSizes.spaceBtwItems,
          children: actions.map((a) => _card(context, a)).toList(),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, _QuickAction a) {
    return InkWell(
      onTap: () => Get.toNamed(a.route),
      borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      hoverColor: TColors.lightContainer,
      child: Container(
        width: 190,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          border: Border.all(color: TColors.borderPrimary),
          boxShadow: [
            BoxShadow(
              color: TColors.primary.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColors.lightContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(a.icon, color: TColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                a.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: TColors.textPrimary,
                    fontSize: 14),
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: TColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final String route;
  _QuickAction(this.label, this.icon, this.route);
}
