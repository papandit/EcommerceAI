import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/create_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../utils/constants/sizes.dart';

class VideoLink extends StatefulWidget {
  const VideoLink({
    super.key,
  });

  @override
  State<VideoLink> createState() => _VideoLinkState();
}

class _VideoLinkState extends State<VideoLink> {
  final RegExp facebookRegExp = RegExp(
    r'^(https?:\/\/)?(www\.)?facebook\.com\/[a-zA-Z0-9(.?)?]',
    caseSensitive: false,
  );
  final RegExp twitterRegExp = RegExp(
    r'^(https?:\/\/)?(www\.)?twitter\.com\/[a-zA-Z0-9_]{1,15}$',
    caseSensitive: false,
  );
  final RegExp instagramRegExp = RegExp(
    r'^(https?:\/\/)?(www\.)?instagram\.com\/[a-zA-Z0-9_.]+$',
    caseSensitive: false,
  );
  // YouTube URL validation regex
  final RegExp youtubeRegExp = RegExp(
    r'^(https?:\/\/)?(www\.)?(youtube\.com\/(channel\/|user\/|c\/|watch\?v=|playlist\?list=)|youtu\.be\/)[a-zA-Z0-9_\-]{1,}$',
    caseSensitive: false,
  );
  String? _validateSocialMediaUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a URL';
    }
// X (Twitter rebranded) URL validation regex
    final RegExp xRegExp = RegExp(
      r'^(https?:\/\/)?(www\.)?x\.com\/[a-zA-Z0-9_]{1,15}\/status\/\d+\?s=\d+$',
      caseSensitive: false,
    );
    if (facebookRegExp.hasMatch(value) ||
        twitterRegExp.hasMatch(value) ||
        instagramRegExp.hasMatch(value) ||
        youtubeRegExp.hasMatch(value) ||
        xRegExp.hasMatch(value)) {
      return null; // Valid URL for Facebook, Twitter, or Instagram
    } else {
      return 'Please enter a valid Facebook, Twitter, Instagram, or YouTube URL';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get instances of controllers
    final controller = Get.put(CreateProductController());
    // final brandController = Get.put(BrandController());
    // final LinkController = Get.put(BrandController());

    // Fetch brands if the list is empty
    // if (brandController.allItems.isEmpty) {
    //   brandController.fetchItems();
    // }

    return TRoundedContainer(
      child: Form(
        key: controller.linkFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand label
            Text('Link', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: TSizes.spaceBtwItems),

            // TypeAheadField for brand selection

            TextFormField(
              controller: controller.linkController,
              validator: (value) => _validateSocialMediaUrl(value),
              decoration: const InputDecoration(
                  labelText: 'Link',
                  prefixIcon: Icon(Iconsax.category),
                  hintText: "URL link of your post",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
