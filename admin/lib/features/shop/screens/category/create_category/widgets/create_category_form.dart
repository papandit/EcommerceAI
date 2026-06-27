// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cwt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:cwt_ecommerce_admin_panel/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../common/widgets/images/image_uploader.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/image_strings.dart';
import '../../../../controllers/category/category_controller.dart';
import '../../../../controllers/category/create_category_controller.dart';

class CreateCategoryForm extends StatelessWidget {
  const CreateCategoryForm({super.key});

  @override
  Widget build(BuildContext context) {
    final createController = Get.put(CreateCategoryController());
    Get.put(CategoryController());
    return TRoundedContainer(
      width: 500,
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Form(
        key: createController.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TSizes.sm),
            Text('Create New Category',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Name Text Field
            TextFormField(
              controller: createController.name,
              validator: (value) => TValidator.validateEmptyText('Name', value),
              decoration: const InputDecoration(
                  labelText: 'Category Name',
                  prefixIcon: Icon(Iconsax.category)),
            ),

            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Name Text Field
            TextFormField(
              onFieldSubmitted: (value) {
                if (createController.Forupdateid.value.isEmpty) {
                  const uuid = Uuid();

                  if (value.isNotEmpty) {
                    createController.sub_category_data.add({
                      'id': uuid.v4(), // Unique ID
                      'name': value, // Original name
                    });
                    createController.parentname.clear();
                    createController.Forupdateid.value = "";
                  }
                } else {
                  if (value.isNotEmpty) {
                    int indexToRemove =
                        createController.sub_category_data.indexWhere(
                      (element) =>
                          element['id'] == createController.Forupdateid.value,
                    );
                    if (indexToRemove != -1) {
                      createController.sub_category_data
                          .removeAt(indexToRemove);
                    }
                    createController.sub_category_data.add({
                      'id': createController.Forupdateid.value, // Unique ID
                      'name': value, // Original name
                    });
                    createController.parentname.clear();
                    createController.Forupdateid.value = "";
                  }
                }
              },
              onSaved: (newValue) {
                print("Value $newValue");
              },
              controller: createController.parentname,
              // validator: (value) => TValidator.validateEmptyText('Name', value),
              decoration: const InputDecoration(
                  labelText: 'Sub Category Name',
                  prefixIcon: Icon(Iconsax.category)),
            ),
            // const SizedBox(height: TSizes.spaceBtwInputFields),

            Obx(
              () => GridView.builder(
                itemCount: createController.sub_category_data.length,
                shrinkWrap: true,
                // scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: InputChip(
                          padding: EdgeInsets.zero,
                          color:
                              WidgetStatePropertyAll(TColors.primaryBackground),
                          avatar: Icon(Icons.remove),
                          labelPadding: EdgeInsets.symmetric(horizontal: 5),
                          label: Text(
                            createController.sub_category_data.isEmpty
                                ? ""
                                : createController.sub_category_data[index]
                                    ['name'] as String,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          onPressed: () {
                            createController.parentname.text = createController
                                .sub_category_data[index]['name'];

                            createController.Forupdateid.value =
                                createController.sub_category_data[index]['id'];
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          createController.sub_category_data.remove(
                              createController.sub_category_data[index]);
                        },
                        child: Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                              color: TColors.error, shape: BoxShape.circle),
                          child: Icon(
                            Icons.close,
                            color: TColors.white,
                            size: 10,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, crossAxisSpacing: 0, mainAxisExtent: 50),
              ),
            ),

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
            //       createController.selectedParent.value =
            //           values as CategoryModel;
            //     },
            //   ),
            // ),
            // const SizedBox(height: TSizes.spaceBtwInputFields),

            // ElevatedButton(
            //     style: ButtonStyle(
            //         padding: WidgetStatePropertyAll(
            //             EdgeInsets.symmetric(horizontal: 5))),
            //     onPressed: () {
            //       Get.defaultDialog(
            //           title: "Add New Parent Category",
            //           content: Column(
            //             children: [
            //               TextFormField(
            //                 controller: createController.parentname,
            //                 validator: (value) =>
            //                     TValidator.validateEmptyText('Name', value),
            //                 decoration: const InputDecoration(
            //                     labelText: 'Parent Category Name',
            //                     prefixIcon: Icon(Iconsax.category)),
            //               ),
            //               SizedBox(height: TSizes.spaceBtwInputFields),
            //               ElevatedButton(
            //                   onPressed: () {
            //                     createController.createParentCategory();
            //                     Get.back();
            //                   },
            //                   child: Text("Done"))
            //             ],
            //           ));
            //     },
            //     child: Text("Add New Parent Category")),

            // Obx(
            //   () => categoryController.isLoading.value
            //       ? const TShimmerEffect(width: double.infinity, height: 55)
            //       : DropdownButtonFormField<CategoryModel>(
            //           decoration: const InputDecoration(
            //               hintText: 'Parent Category',
            //               labelText: 'Parent Category',
            //               prefixIcon: Icon(Iconsax.bezier)),
            //           onChanged: (newValue) =>
            //               createController.selectedParent.value = newValue!,
            //           items: categoryController.allItems
            //               .map((item) => DropdownMenuItem(
            //                     value: item,
            //                     child: Row(
            //                         crossAxisAlignment: CrossAxisAlignment.end,
            //                         children: [Text(item.name)]),
            //                   ))
            //               .toList(),
            //         ),
            // ),

            const SizedBox(height: TSizes.spaceBtwInputFields * 2),

            // Image Uploader & Featured Checkbox
            Obx(
              () => TImageUploader(
                width: 80,
                height: 80,
                image: createController.imageURL.value.isNotEmpty
                    ? createController.imageURL.value
                    : TImages.defaultImage,
                imageType: createController.imageURL.value.isNotEmpty
                    ? ImageType.network
                    : ImageType.asset,
                onIconButtonPressed: () => createController.pickImage(),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            // Obx(
            //   () => CheckboxMenuButton(
            //     value: createController.isFeatured.value,
            //     onChanged: (value) =>
            //         createController.isFeatured.value = value ?? false,
            //     child: const Text('Featured'),
            //   ),
            // ),
            // const SizedBox(height: TSizes.spaceBtwInputFields * 2),
            Obx(
              () => AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: createController.loading.value
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () => createController.createCategory(),
                            child: const Text('Create')),
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
