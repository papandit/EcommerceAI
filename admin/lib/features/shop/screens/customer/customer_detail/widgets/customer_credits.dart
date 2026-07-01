import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../features/personalization/controllers/credit_controller.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../personalization/models/user_model.dart';

/// Admin control on the customer detail screen: view try-on credit balance,
/// add/set/deduct credits (with a reason), and see the credit history.
class CustomerCredits extends StatefulWidget {
  const CustomerCredits({super.key, required this.customer});

  final UserModel customer;

  @override
  State<CustomerCredits> createState() => _CustomerCreditsState();
}

class _CustomerCreditsState extends State<CustomerCredits> {
  late final CreditController controller;
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  String _op = 'add';

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CreditController>()
        ? CreditController.instance
        : Get.put(CreditController());
    final id = widget.customer.id;
    if (id != null && id.isNotEmpty) {
      controller.loadUserLedger(id, currentBalance: widget.customer.tryonCredits);
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    final id = widget.customer.id;
    if (id == null || id.isEmpty) return;
    final amount = int.tryParse(_amount.text.trim()) ?? -1;
    if (amount < 0) return;
    controller.adjust(id, op: _op, amount: amount, reason: _reason.text.trim());
    _amount.clear();
    _reason.clear();
  }

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.coin, color: TColors.primary, size: 20),
              const SizedBox(width: TSizes.sm),
              Text('Try-On Credits',
                  style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: TSizes.md, vertical: TSizes.sm),
                    decoration: BoxDecoration(
                      color: TColors.lightContainer,
                      borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                    ),
                    child: Text('${controller.userBalance.value} credits',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                                color: TColors.primary,
                                fontWeight: FontWeight.bold)),
                  )),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          // Adjust controls
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: DropdownButtonFormField<String>(
                  value: _op,
                  decoration: const InputDecoration(labelText: 'Action'),
                  items: const [
                    DropdownMenuItem(value: 'add', child: Text('Add')),
                    DropdownMenuItem(value: 'deduct', child: Text('Deduct')),
                    DropdownMenuItem(value: 'set', child: Text('Set to')),
                  ],
                  onChanged: (v) => setState(() => _op = v ?? 'add'),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: TextField(
                  controller: _reason,
                  decoration: const InputDecoration(labelText: 'Reason (optional)'),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Obx(() => ElevatedButton(
                    onPressed: controller.adjusting.value ? null : _submit,
                    child: controller.adjusting.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Apply'),
                  )),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          const Divider(),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text('History', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: TSizes.spaceBtwItems),

          Obx(() {
            if (controller.ledgerLoading.value && controller.ledger.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(TSizes.md),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            if (controller.ledger.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: TSizes.md),
                child: Text('No credit activity yet.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: TColors.textSecondary)),
              );
            }
            return Column(
              children: controller.ledger.map((e) {
                final positive = e.amount >= 0;
                final amountText =
                    '${positive ? '+' : ''}${e.amount}';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        positive ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                        size: 16,
                        color: positive ? TColors.success : TColors.warning,
                      ),
                      const SizedBox(width: TSizes.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.label,
                                style: Theme.of(context).textTheme.bodyLarge),
                            if (e.reason.isNotEmpty)
                              Text(e.reason,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: TColors.textSecondary)),
                          ],
                        ),
                      ),
                      Text(amountText,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color: positive
                                      ? TColors.success
                                      : TColors.warning,
                                  fontWeight: FontWeight.w600)),
                      if (e.balanceAfter != null) ...[
                        const SizedBox(width: TSizes.sm),
                        Text('→ ${e.balanceAfter}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: TColors.textSecondary)),
                      ],
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
