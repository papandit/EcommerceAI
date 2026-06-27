// ignore_for_file: prefer_const_constructors

import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/coupan/edit_coupan_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/coupan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/validators/validation.dart';

class EditCoupanForm extends StatelessWidget {
  const EditCoupanForm({super.key, required this.coupan});

  final CoupanModel coupan;

  @override
  Widget build(BuildContext context) {
    final editController = Get.put(EditCoupanController());
    editController.init(coupan);
    return TRoundedContainer(
      width: 500,
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Form(
        key: editController.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            const SizedBox(height: TSizes.sm),
            Text('Update Coupan',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Name Text Field
            TextFormField(
              controller: editController.name,
              validator: (value) => TValidator.validateEmptyText('Name', value),
              decoration: const InputDecoration(
                  labelText: 'Coupan Name', prefixIcon: Icon(Icons.edit)),
            ),

            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              controller: editController.percentage,
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              validator: (value) => TValidator.validateDigit(value),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              decoration: const InputDecoration(
                  labelText: 'Coupan Percentage',
                  prefixIcon: Icon(Iconsax.category)),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields * 2),

            Obx(
              () => CheckboxMenuButton(
                value: editController.isActive.value,
                onChanged: (value) =>
                    editController.isActive.value = value ?? false,
                child: const Text('Is Active'),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields * 2),
            Obx(
              () => AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: editController.loading.value
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () =>
                                editController.updateCategory(coupan),
                            child: const Text('Update')),
                      ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields * 2),
          ],
        ),
      ),
    );
  }
}
