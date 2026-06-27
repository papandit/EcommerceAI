import 'package:cwt_ecommerce_admin_panel/features/media/controllers/media_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/enums.dart';

class MediaFolderDropdown extends StatelessWidget {
  const MediaFolderDropdown({super.key, this.onChanged});

  final void Function(MediaCategory?)? onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = MediaController.instance;
    return Obx(
      () => SizedBox(
        width: 140,
        child: DropdownButtonFormField<MediaCategory>(
          isExpanded: false,
          onChanged: onChanged,
          initialValue: controller.selectedPath.value,
          items: MediaCategory.values.map(
            (category) {
              return DropdownMenuItem<MediaCategory>(
                value: category,
                child: Text(category.name.capitalize.toString()),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
