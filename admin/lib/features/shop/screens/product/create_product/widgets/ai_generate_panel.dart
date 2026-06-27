import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../controllers/product/ai_photoshoot_controller.dart';
import 'camera_capture.dart';

/// Guided "Generate AI model photos" panel for the Create Product screen.
/// Flow: pick a model -> add the product photo (upload / camera) -> generate the
/// model wearing the product (several poses) -> add chosen poses to the product.
class AiGeneratePanel extends StatefulWidget {
  const AiGeneratePanel({super.key});

  @override
  State<AiGeneratePanel> createState() => _AiGeneratePanelState();
}

class _AiGeneratePanelState extends State<AiGeneratePanel> {
  final AiPhotoshootController c = Get.put(AiPhotoshootController());

  @override
  void initState() {
    super.initState();
    c.loadModels();
  }

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.magic_star, color: TColors.primary, size: 20),
              const SizedBox(width: TSizes.sm),
              Expanded(
                child: Text('Generate AI model photos',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
            ],
          ),
          const SizedBox(height: TSizes.xs),
          Text(
            'Pick a model, add the product photo, and generate the model wearing it.',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          _stepLabel(context, '1. Choose a model'),
          const SizedBox(height: TSizes.sm),
          _modelGrid(),
          const SizedBox(height: TSizes.spaceBtwItems),

          _stepLabel(context, '2. Add the product photo'),
          const SizedBox(height: TSizes.sm),
          _productPhoto(context),
          const SizedBox(height: TSizes.spaceBtwItems),

          _stepLabel(context, '3. Generate'),
          const SizedBox(height: TSizes.sm),
          _generateButton(),

          _results(context),
        ],
      ),
    );
  }

  Widget _stepLabel(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w600),
      );

  // ---- Step 1: model cards ----
  Widget _modelGrid() {
    return Obx(() {
      if (c.loadingModels.value && c.models.isEmpty) {
        return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
      }
      if (c.models.isEmpty) {
        return const Text('No models available. Check BrandShoot settings.',
            style: TextStyle(color: TColors.darkGrey));
      }
      return SizedBox(
        height: 130,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: c.models.length,
          separatorBuilder: (_, __) => const SizedBox(width: TSizes.sm),
          itemBuilder: (_, i) {
            final m = c.models[i];
            final id = (m['id'] ?? '').toString();
            final name = (m['name'] ?? '').toString();
            final img = (m['imageFullUrl'] ?? '').toString();
            final selected = c.selectedModelId.value == id;
            return GestureDetector(
              onTap: () => c.selectModel(id),
              child: Container(
                width: 92,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(TSizes.sm),
                  border: Border.all(
                    color: selected ? TColors.primary : TColors.borderPrimary,
                    width: selected ? 2.4 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(TSizes.sm)),
                        child: Image.network(
                          img,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Iconsax.user, color: TColors.grey)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? TColors.primary : TColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ---- Step 2: product photo ----
  Widget _productPhoto(BuildContext context) {
    return Obx(() {
      final b64 = c.productImageB64.value;
      if (b64 != null && b64.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(TSizes.sm),
              child: Image.memory(
                base64Decode(b64),
                height: 150,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: TSizes.sm),
            Row(
              children: [
                TextButton.icon(
                  onPressed: c.clearProductImage,
                  icon: const Icon(Iconsax.trash, size: 16),
                  label: const Text('Remove'),
                ),
              ],
            ),
          ],
        );
      }
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: c.pickProductImageFile,
              icon: const Icon(Iconsax.gallery_add, size: 18),
              label: const Text('Upload'),
            ),
          ),
          const SizedBox(width: TSizes.sm),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final bytes = await captureFromCamera(context);
                if (bytes != null) c.setProductImageBytes(bytes);
              },
              icon: const Icon(Iconsax.camera, size: 18),
              label: const Text('Camera'),
            ),
          ),
        ],
      );
    });
  }

  // ---- Step 3: generate ----
  Widget _generateButton() {
    return Obx(() {
      if (c.isGenerating.value) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: TSizes.md),
          alignment: Alignment.center,
          child: Column(
            children: const [
              SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(height: TSizes.sm),
              Text('Creating your photos… ~20–40s'),
            ],
          ),
        );
      }
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
          onPressed: c.generateForNewProduct,
          icon: const Icon(Iconsax.magic_star, color: Colors.white, size: 18),
          label: const Text('Generate model photos',
              style: TextStyle(color: Colors.white)),
        ),
      );
    });
  }

  // ---- Results ----
  Widget _results(BuildContext context) {
    return Obx(() {
      if (c.jobImages.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: TSizes.spaceBtwItems),
          const Divider(),
          const SizedBox(height: TSizes.sm),
          Text('Results — tap to select',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: TSizes.sm),
          Wrap(
            spacing: TSizes.sm,
            runSpacing: TSizes.sm,
            children: c.jobImages.map((img) {
              final url = (img['fullUrl'] ?? '').toString();
              final isPicked = c.picked.contains(url);
              return GestureDetector(
                onTap: () => c.togglePick(url),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(TSizes.sm),
                        border: Border.all(
                          color:
                              isPicked ? TColors.primary : TColors.borderPrimary,
                          width: isPicked ? 2.5 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(TSizes.sm),
                        child: Image.network(url,
                            width: 96, height: 120, fit: BoxFit.cover),
                      ),
                    ),
                    if (isPicked)
                      const Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          radius: 11,
                          backgroundColor: TColors.primary,
                          child: Icon(Icons.check,
                              size: 14, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: TColors.primary),
                  onPressed: c.addToProduct,
                  icon: const Icon(Iconsax.add, color: Colors.white, size: 18),
                  label: const Text('Add to product',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: TSizes.sm),
              OutlinedButton.icon(
                onPressed: c.generateForNewProduct,
                icon: const Icon(Iconsax.refresh, size: 16),
                label: const Text('More poses'),
              ),
            ],
          ),
        ],
      );
    });
  }
}
