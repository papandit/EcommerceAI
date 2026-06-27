// ignore_for_file: prefer_const_constructors

import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/department/edit_department_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/depaerment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/validators/validation.dart';

class EditDepartmentForm extends StatelessWidget {
  const EditDepartmentForm({super.key, required this.category});

  final DepartmentModel category;

  @override
  Widget build(BuildContext context) {
    final editController = Get.put(EditDepartMentController());
    editController.init(category);
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
            Text('Update Category',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Name Text Field
            TextFormField(
              controller: editController.name,
              validator: (value) => TValidator.validateEmptyText('Name', value),
              decoration: const InputDecoration(
                  labelText: 'Category Name',
                  prefixIcon: Icon(Iconsax.category)),
            ),

            const SizedBox(height: TSizes.spaceBtwInputFields),

            // TextFormField(
            //   onFieldSubmitted: (value) {
            //     print("Value sub ${value}");
            //     if (editController.Forupdateid.value.isEmpty) {
            //       const uuid = Uuid();

            //       if (value.isNotEmpty) {
            //         editController.sub_category_data.add({
            //           'id': uuid.v4(), // Unique ID
            //           'name': value, // Original name
            //         });
            //         editController.parentname.clear();
            //         editController.Forupdateid.value = "";
            //         print(
            //             "sub_category_data PADS ${editController.Forupdateid.value}");
            //         print(
            //             "sub_category_data PADS ${editController.sub_category_data}");
            //       }
            //     } else {
            //       if (value.isNotEmpty) {
            //         int indexToRemove =
            //             editController.sub_category_data.indexWhere(
            //           (element) =>
            //               element['id'] == editController.Forupdateid.value,
            //         );
            //         if (indexToRemove != -1) {
            //           editController.sub_category_data.removeAt(indexToRemove);
            //         }
            //         editController.sub_category_data.add({
            //           'id': editController.Forupdateid.value, // Unique ID
            //           'name': value, // Original name
            //         });
            //         editController.parentname.clear();
            //         editController.Forupdateid.value = "";
            //         print(
            //             "sub_category_data PADS ${editController.Forupdateid.value}");
            //       }
            //     }
            //   },
            //   onSaved: (newValue) {
            //     print("Value ${newValue}");
            //   },
            //   controller: editController.parentname,
            //   // validator: (value) => TValidator.validateEmptyText('Name', value),
            //   decoration: const InputDecoration(
            //       labelText: 'Sub Category Name',
            //       prefixIcon: Icon(Iconsax.category)),
            // ),

            // Obx(
            //   () => GridView.builder(
            //     itemCount: editController.sub_category_data.length,
            //     shrinkWrap: true,
            //     // scrollDirection: Axis.horizontal,
            //     padding: EdgeInsets.zero,
            //     physics: NeverScrollableScrollPhysics(),
            //     itemBuilder: (context, index) {
            //       return Stack(
            //         children: [
            //           Padding(
            //             padding: const EdgeInsets.all(6.0),
            //             child: InputChip(
            //               padding: EdgeInsets.zero,
            //               color:
            //                   WidgetStatePropertyAll(TColors.primaryBackground),
            //               avatar: Icon(Icons.remove),
            //               labelPadding: EdgeInsets.symmetric(horizontal: 5),
            //               label: Text(
            //                 editController.sub_category_data.isEmpty
            //                     ? ""
            //                     : editController.sub_category_data[index]
            //                         ['name'] as String,
            //                 softWrap: true,
            //                 overflow: TextOverflow.ellipsis,
            //                 maxLines: 1,
            //               ),
            //               onPressed: () {
            //                 editController.parentname.text =
            //                     editController.sub_category_data[index]['name'];

            //                 editController.Forupdateid.value =
            //                     editController.sub_category_data[index]['id'];
            //                 // editController.sub_category_data.remove(
            //                 //     editController.sub_category_data[index]);
            //               },
            //             ),
            //           ),
            //           GestureDetector(
            //             onTap: () {
            //               editController.sub_category_data
            //                   .remove(editController.sub_category_data[index]);
            //             },
            //             child: Container(
            //               height: 20,
            //               width: 20,
            //               decoration: BoxDecoration(
            //                   color: TColors.error, shape: BoxShape.circle),
            //               child: Icon(
            //                 Icons.close,
            //                 color: TColors.white,
            //                 size: 10,
            //               ),
            //             ),
            //           ),
            //         ],
            //       );
            //     },
            //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //         crossAxisCount: 4, crossAxisSpacing: 0, mainAxisExtent: 50),
            //   ),
            // ),

            // Obx(
            //   () => MultiSelectDialogField(
            //     buttonText: Text("Parent Category",
            //         style: Theme.of(context).textTheme.headlineSmall),
            //     decoration: BoxDecoration(
            //         border: Border.all(color: Colors.grey.withOpacity(0.3)),
            //         borderRadius: BorderRadius.circular(10)),
            //     items: categoryController.allItems
            //         .map((item) => MultiSelectItem(item, item.name))
            //         .toList(),
            //     listType: MultiSelectListType.LIST,
            //     onConfirm: (values) {
            //       editController.selectedParent.value = values as CategoryModel;
            //     },
            //   ),
            // ),

            // Obx(
            //   () => DropdownButtonFormField<CategoryModel>(
            //     decoration: const InputDecoration(
            //         hintText: 'Parent Category',
            //         labelText: 'Parent Category',
            //         prefixIcon: Icon(Iconsax.bezier)),
            //     value: editController.selectedParent.value.id.isNotEmpty
            //         ? editController.selectedParent.value
            //         : null,
            //     onChanged: (newValue) =>
            //         editController.selectedParent.value = newValue!,
            //     items: categoryController.allItems
            //         .map((item) => DropdownMenuItem(
            //               value: item,
            //               child: Row(
            //                   crossAxisAlignment: CrossAxisAlignment.end,
            //                   children: [Text(item.name)]),
            //             ))
            //         .toList(),
            //   ),
            // ),

            const SizedBox(height: TSizes.spaceBtwInputFields * 2),

            // Image Uploader & Featured Checkbox
            // Obx(
            //   () => TImageUploader(
            //     width: 80,
            //     height: 80,
            //     image: editController.imageURL.value.isNotEmpty
            //         ? editController.imageURL.value
            //         : TImages.defaultImage,
            //     imageType: editController.imageURL.value.isNotEmpty
            //         ? ImageType.network
            //         : ImageType.asset,
            //     onIconButtonPressed: () => editController.pickImage(),
            //   ),
            // ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            // Obx(
            //   () => CheckboxMenuButton(
            //     value: editController.isFeatured.value,
            //     onChanged: (value) =>
            //         editController.isFeatured.value = value ?? false,
            //     child: const Text('Featured'),
            //   ),
            // ),
            // const SizedBox(height: TSizes.spaceBtwInputFields * 2),
            Obx(
              () => AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: editController.loading.value
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () =>
                                editController.updateCategory(category),
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
