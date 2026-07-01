import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/credit_controller.dart';

/// Shows how much of the purchased BrandShoot try-on credit pool has been used.
/// BrandShoot has no balance API, so this is tracked internally from the ledger.
class CreditCostingDashboard extends StatelessWidget {
  const CreditCostingDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<CreditController>()
        ? CreditController.instance
        : Get.put(CreditController());

    return TRoundedContainer(
      padding: const EdgeInsets.symmetric(
          vertical: TSizes.lg, horizontal: TSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.coin, color: TColors.primary, size: 20),
              const SizedBox(width: TSizes.sm),
              Expanded(
                child: Text('Try-On Credit Usage',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: controller.fetchSummary,
                icon: const Icon(Iconsax.refresh, size: 18),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Obx(() {
            if (controller.summaryLoading.value && controller.purchased.value == 0) {
              return const Padding(
                padding: EdgeInsets.all(TSizes.lg),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            final cur = controller.currency.value;
            String money(double v) => '$cur ${v.toStringAsFixed(2)}';
            return Column(
              children: [
                Row(
                  children: [
                    _stat(context, 'Purchased', '${controller.purchased.value}',
                        Iconsax.shopping_cart, TColors.info),
                    _stat(context, 'Consumed', '${controller.consumed.value}',
                        Iconsax.flash_1, TColors.warning),
                    _stat(
                        context,
                        'Remaining',
                        '${controller.remaining.value}',
                        Iconsax.wallet_3,
                        controller.remaining.value <= 0
                            ? TColors.error
                            : TColors.success),
                  ],
                ),
                const Divider(height: TSizes.spaceBtwSections),
                _row(context, 'Cost / credit', money(controller.costPerCredit.value)),
                const SizedBox(height: TSizes.sm),
                _row(context, 'Spent so far', money(controller.estConsumedCost.value)),
                const SizedBox(height: TSizes.sm),
                _row(context, 'Remaining value', money(controller.estRemainingValue.value)),
                if (controller.remaining.value <= 0) ...[
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Row(
                    children: const [
                      Icon(Iconsax.warning_2, color: TColors.error, size: 16),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Pool exhausted — top up BrandShoot and update Purchased Credits.',
                          style: TextStyle(color: TColors.error, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value, IconData icon,
      Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: TColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: TColors.textSecondary)),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
