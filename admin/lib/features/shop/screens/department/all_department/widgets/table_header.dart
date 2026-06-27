import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../utils/device/device_utility.dart';
import '../../../../controllers/customer/customer_controller.dart';
import '../../../../controllers/department/department_controller.dart';

class DepartMentTableHeader extends StatelessWidget {
  const DepartMentTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerController());
    final deptController = Get.put(DepartMentController());
    return Row(
      children: [
        Expanded(
          flex: !TDeviceUtils.isDesktopScreen(context) ? 0 : 3,
          child: Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: () => _showAddDepartmentDialog(context, deptController),
              icon: const Icon(Iconsax.add),
              label: const Text('Add Department'),
            ),
          ),
        ),
        Expanded(
          flex: TDeviceUtils.isDesktopScreen(context) ? 2 : 1,
          child: TextFormField(
            controller: controller.searchTextController,
            onChanged: (query) => controller.searchQuery(query),
            decoration: const InputDecoration(
                hintText: 'Search DepartMent',
                prefixIcon: Icon(Iconsax.search_normal)),
          ),
        ),
      ],
    );
  }

  void _showAddDepartmentDialog(
      BuildContext context, DepartMentController deptController) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Department'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: nameController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Department name',
              hintText: 'e.g. New Arrivals',
              prefixIcon: Icon(Iconsax.box),
            ),
            onSubmitted: (_) {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              deptController.addDepartment(name);
              Navigator.of(ctx).pop();
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              deptController.addDepartment(name);
              Navigator.of(ctx).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
