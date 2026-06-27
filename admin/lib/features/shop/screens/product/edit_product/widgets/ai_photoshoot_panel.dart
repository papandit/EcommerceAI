import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../controllers/product/ai_photoshoot_controller.dart';
import '../../../../models/product_model.dart';

/// "Generate AI model photos" panel (BrandShoot photoshoot / catalog) shown in
/// the Edit Product sidebar. Admin picks a model, generates, then publishes
/// chosen results to the product gallery.
class AiPhotoshootPanel extends StatelessWidget {
  const AiPhotoshootPanel({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AiPhotoshootController());
    return TRoundedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.magicpen, color: TColors.primary, size: 20),
              const SizedBox(width: TSizes.sm),
              Text('AI Model Photos',
                  style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: TSizes.xs),
          Text(
            'Generate model photos of this product, then publish the best to the gallery. Each image uses BrandShoot credits.',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Feature toggle
          Obx(
            () => Row(
              children: [
                _featureChip(c, 'photoshoot', 'Photoshoot'),
                const SizedBox(width: TSizes.sm),
                _featureChip(c, 'catalog', 'Catalog'),
              ],
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Inputs
          Obx(() => _inputs(context, c)),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Generate button
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: c.isGenerating.value ? null : () => c.start(product.id),
                icon: c.isGenerating.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Iconsax.flash_1, size: 18),
                label: Text(c.isGenerating.value ? 'Generating…' : 'Generate'),
              ),
            ),
          ),

          // Results
          Obx(() => _results(context, c)),
        ],
      ),
    );
  }

  Widget _featureChip(AiPhotoshootController c, String value, String label) {
    final selected = c.feature.value == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => c.feature.value = value,
      selectedColor: TColors.primary,
      labelStyle: TextStyle(
          color: selected ? Colors.white : TColors.textPrimary,
          fontWeight: FontWeight.w600),
    );
  }

  Widget _inputs(BuildContext context, AiPhotoshootController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (c.feature.value == 'photoshoot') ...[
          TextFormField(
            initialValue: c.modelId.value,
            onChanged: (v) => c.modelId.value = v,
            decoration: const InputDecoration(
              labelText: 'Preset model ID (optional)',
              hintText: 'e.g. model_01',
              prefixIcon: Icon(Iconsax.user_octagon),
            ),
          ),
          const SizedBox(height: TSizes.sm),
          Text('— or upload a model photo —',
              style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: TSizes.sm),
        ],
        _modelImagePicker(context, c),
      ],
    );
  }

  Widget _modelImagePicker(BuildContext context, AiPhotoshootController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: () => c.pickModelImage(),
          icon: const Icon(Iconsax.gallery_add, size: 18),
          label: Text(c.feature.value == 'catalog'
              ? 'Add model photo'
              : 'Upload model photo'),
        ),
        if (c.modelImagesB64.isNotEmpty) ...[
          const SizedBox(height: TSizes.sm),
          Wrap(
            spacing: TSizes.sm,
            runSpacing: TSizes.sm,
            children: List.generate(c.modelImagesB64.length, (i) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(TSizes.sm),
                    child: Image.memory(base64Decode(c.modelImagesB64[i]),
                        width: 56, height: 56, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => c.removeModelImage(i),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: TColors.error, shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _results(BuildContext context, AiPhotoshootController c) {
    if (c.jobImages.isEmpty) {
      if (c.isGenerating.value) {
        return const Padding(
          padding: EdgeInsets.only(top: TSizes.spaceBtwItems),
          child: Text('Working on it… results will appear here.'),
        );
      }
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: TSizes.spaceBtwItems),
        Text('Results — tap to select',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: TSizes.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: c.jobImages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: TSizes.sm,
            mainAxisSpacing: TSizes.sm,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, i) {
            final url = (c.jobImages[i]['fullUrl'] ?? '').toString();
            final selected = c.picked.contains(url);
            return GestureDetector(
              onTap: () => c.togglePick(url),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(TSizes.sm),
                    child: Image.network(url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            color: TColors.lightContainer,
                            child: const Icon(Iconsax.image))),
                  ),
                  if (selected)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(TSizes.sm),
                        border: Border.all(color: TColors.primary, width: 3),
                        color: TColors.primary.withOpacity(0.12),
                      ),
                    ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Icon(
                      selected
                          ? Iconsax.tick_circle
                          : Iconsax.add_circle,
                      color: selected ? TColors.primary : Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Obx(
          () => SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: c.picked.isEmpty ? null : () => c.publish(),
              icon: const Icon(Iconsax.cloud_add, size: 18),
              label: Text('Publish ${c.picked.length} to product'),
            ),
          ),
        ),
      ],
    );
  }
}
