import 'package:cwt_ecommerce_admin_panel/common/widgets/containers/rounded_container.dart';
import 'package:cwt_ecommerce_admin_panel/common/widgets/shimmers/shimmer.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/other_controller.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iconsax_flutter/iconsax_flutter.dart';

class SelectBox extends StatefulWidget {
  const SelectBox({super.key});

  @override
  State<SelectBox> createState() => _SelectBoxState();
}

class _SelectBoxState extends State<SelectBox> {
  final OthersController _otherCoontroller = Get.put(OthersController());
  List createData = [
    'Header',
    'Footer',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TSizes.spaceBtwSections),
            TRoundedContainer(
              width: 500,
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  const SizedBox(height: TSizes.sm),
                  TextFormField(
                    controller: _otherCoontroller.aboutusController,
                    decoration: const InputDecoration(prefixIcon: Icon(Iconsax.ship)),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields * 2),
                  _otherCoontroller.isLoading.value
                      ? const TShimmerEffect(width: double.infinity, height: 50)
                      : DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              hintText: 'Select an Options',
                              labelText: 'Select an Options',
                              prefixIcon: Icon(Iconsax.bezier)),
                          onChanged: (newValue) {
                            _otherCoontroller.departmentname = newValue!;
                          },
                          items:
                              createData.map<DropdownMenuItem<String>>((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: TSizes.spaceBtwInputFields * 2),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () => _otherCoontroller.aboutUs(),
                        child: const Text('Create')),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
