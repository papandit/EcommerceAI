// ignore_for_file: prefer_final_fields, avoid_print

import 'package:cwt_ecommerce_admin_panel/common/widgets/images/t_rounded_image.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/controllers/Otherbrand/other_create_brand_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/controllers/Otherbrand/other_edit_brand_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/models/other_brand_model.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/enums.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/image_strings.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/validators/validation.dart';

class OtherEditBrandForm extends StatefulWidget {
  const OtherEditBrandForm({super.key, required this.brand});

  final OtherBrandModel brand;

  @override
  State<OtherEditBrandForm> createState() => _OtherEditBrandFormState();
}

class _OtherEditBrandFormState extends State<OtherEditBrandForm> {
  late QuillEditorController quillcontroller;
  late QuillEditorController quillcontrolle_new;

  final customToolBarList = [
    ToolBarStyle.bold,
    ToolBarStyle.italic,
    ToolBarStyle.align,
    ToolBarStyle.color,
    ToolBarStyle.background,
    ToolBarStyle.listBullet,
    ToolBarStyle.listOrdered,
    ToolBarStyle.clean,
    ToolBarStyle.addTable,
    ToolBarStyle.editTable,
  ];

  final _toolbarColor = Colors.grey.shade200;
  final _backgroundColor = Colors.white38;
  final _toolbarIconColor = Colors.black87;
  final _editorTextStyle = const TextStyle(
      fontSize: 18,
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontFamily: 'Roboto');
  final _hintTextStyle = const TextStyle(
      fontSize: 18, color: Colors.black38, fontWeight: FontWeight.normal);

  bool _hasFocus = false;
  String? htmlText;
  // var _image;
  // final controller1 = Get.put(OtherCreateBrandController());
  TextEditingController nameController = TextEditingController();

  final controller1 = Get.put(OtherCreateBrandController());
  final controller = Get.put(OtherEditBrandController());
  @override
  void initState() {
    quillcontroller = QuillEditorController();

    Future.delayed(const Duration(seconds: 3), () {
      quillcontroller.setText(widget.brand.about);
      dataGet();
    });

    // quillcontroller.onEditorLoaded(() {
    //   // Set the initial text for the editor from widget.brand.about
    //   setEditorText();
    // });
    controller1.departmentname.value = widget.brand.category;
    controller1.subdepartmentname.value = widget.brand.subcategory ?? '';
    nameController.text = widget.brand.name;
    // controller1.about.value = widget.brand.about;

    // If there's an image, you can also initialize _image with it
    controller.imageURL.value = widget
        .brand.image; // Assuming you have a method to convert it to Uint8List

    super.initState();
  }

  @override
  void dispose() {
    quillcontroller.dispose();
    super.dispose();
  }

  List createData = [
    'Header',
    'Footer',
  ];
  List footerData = [
    'Fist Data',
    'Explore',
    'Policies',
  ];
  //==================

  Uint8List? _image;
  String? _downloadUrl;

  Future<void> _pickImage() async {
    // Pick the image from the gallery
    Uint8List? imageBytes = await ImagePickerWeb.getImageAsBytes();

    // If an image is selected, update the UI
    if (imageBytes != null) {
      setState(() {
        _image = imageBytes;
      });
    }
  }

  Future<void> _uploadImage() async {
    setState(() {});

    try {
      // Generate a unique filename
      String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.png';

      // Upload the image to Firebase Storage
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(fileName);
      UploadTask uploadTask = ref.putData(_image!);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _downloadUrl = downloadUrl;
      });

      print('Download URL: $downloadUrl');
    } catch (e) {
      setState(() {});
      print('Error uploading image: $e');
    }
  }

  void getHtmlText() async {
    htmlText = await quillcontroller.getText();
    print("htmlText ::  $htmlText");
  }

// Function to set text in the editor once it's ready
  void setEditorText() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (widget.brand.about != "" && widget.brand.about.isNotEmpty) {
        quillcontroller.setText(
            widget.brand.about); // Use setText() to set the default text
      } else {
        quillcontroller
            .setText("<h1>hello</h1>"); // Set empty text if about is null
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
        "controller1.subdepartmentname.value${controller1.subdepartmentname.value}");
    print("controller.imageURL.value ${controller.imageURL.value}");
    print(" controller1.about.value ${controller1.about.value}");
    print("widget.brand.imaget${widget.brand.image}");
    print("_downloadUrl$_downloadUrl");
    print("imagee$_image");
    // print("${Get.arguments}");
    // controller.init(widget.brand);
    return TRoundedContainer(
      width: 500,
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TSizes.sm),
            Text('Update Field',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: TSizes.spaceBtwSections),
            TextFormField(
              // controller: controller1.name.value
              //   ..text = widget.brand.name,
              controller: nameController,
              // Set initial value
              validator: (value) => TValidator.validateEmptyText('Name', value),
              decoration: const InputDecoration(
                  labelText: 'Field Name', prefixIcon: Icon(Iconsax.box)),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            Text('Select Categories',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TSizes.spaceBtwInputFields / 2),
            DropdownButtonFormField<String>(
              initialValue: controller1.departmentname.value, // Set initial value
              decoration: const InputDecoration(
                  hintText: 'Select an Option',
                  labelText: 'Select an Option',
                  prefixIcon: Icon(Iconsax.bezier)),
              onChanged: (newValue) {
                controller1.departmentname.value = newValue!;
                setState(() {});
              },
              items: createData.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            if (controller1.departmentname.value == "Footer") ...[
              Text('Select Sub Categories',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: TSizes.spaceBtwInputFields / 2),
              DropdownButtonFormField<String>(
                initialValue: controller1.subdepartmentname.value, // Set initial value
                decoration: const InputDecoration(
                    hintText: 'Select an Option',
                    labelText: 'Select an Option',
                    prefixIcon: Icon(Iconsax.bezier)),
                onChanged: (newValue) {
                  controller1.subdepartmentname.value = newValue!;
                  setState(() {});
                },
                items: footerData.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
            ],
            // Text("${Get.parameters["category"]}"),
            // _image != null
            //     ? Container(
            //         height: 80,
            //         width: 80,
            //         child: Image.memory(
            //           _image!,
            //           scale: 2,
            //         ))
            //     : Container(
            //         height: 50,
            //         width: 50,
            //         color: Colors.amber,
            //       ),
            controller1.subdepartmentname.value != "Fist Data"
                ? const SizedBox()
                : Row(
                    children: [
                      _image != null
                          ? SizedBox(
                              height: 80,
                              width: 80,
                              child: Image.memory(
                                _image!,
                                scale: 2,
                              ))
                          : TRoundedImage(
                              width: 200,
                              height: 200,
                              backgroundColor: TColors.primaryBackground,
                              image: widget.brand.image.isNotEmpty
                                  ? widget.brand.image
                                  : TImages.defaultImage,
                              imageType: widget.brand.image.isNotEmpty
                                  ? ImageType.network
                                  : ImageType.asset,
                            ),
                      // _image != null
                      //     ? TRoundedImage(
                      //         width: 400,
                      //         height: 200,
                      //         backgroundColor: TColors.primaryBackground,
                      //         image: controller.imageURL.value.isNotEmpty
                      //             ? controller.imageURL.value
                      //             : TImages.defaultImage,
                      //         imageType: controller.imageURL.value.isNotEmpty
                      //             ? ImageType.network
                      //             : ImageType.asset,
                      //       )
                      //     // ? Container(
                      //     //     height: 80,
                      //     //     width: 80,
                      //     //     child: Image.network(
                      //     //       "",
                      //     //     ))
                      //     // ? Container(
                      //     //     height: 80,
                      //     //     width: 80,
                      //     //     child: Image.memory(
                      //     //       _image!,
                      //     //       scale: 2,
                      //     //     ))
                      //     : Text('No image selected11.'),
                      const SizedBox(width: 10),
                      OutlinedButton(
                          onPressed: () {
                            _pickImage();
                          },
                          child: const Text('Select Image')),
                    ],
                  ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Editor', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            ToolBar(
              toolBarColor: _toolbarColor,
              padding: const EdgeInsets.all(8),
              iconSize: 25,
              iconColor: _toolbarIconColor,
              activeIconColor: Colors.greenAccent.shade400,
              controller: quillcontroller,
              crossAxisAlignment: WrapCrossAlignment.start,
              direction: Axis.horizontal,
              customButtons: [
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      color: _hasFocus ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(15)),
                ),
              ],
            ),
            SizedBox(
              height: 120,
              child: QuillHtmlEditor(
                text: "<h1>Hello</h1>", // Set initial value
                controller: quillcontroller,
                hintText: 'Write About Yourself',
                isEnabled: true,
                ensureVisible: false,
                minHeight: 500,
                autoFocus: false,
                textStyle: _editorTextStyle,
                hintTextStyle: _hintTextStyle,
                hintTextAlign: TextAlign.start,
                padding: const EdgeInsets.only(left: 10, top: 10),
                hintTextPadding: const EdgeInsets.only(left: 20),
                backgroundColor: _backgroundColor,
                inputAction: InputAction.newline,
                // onEditorCreated: () {
                //   setEditorText(); // Set text after editor is created
                //   setState(() {});
                // },
                // onTextChanged: (text) {
                //   debugPrint('Editor text changed: $text');
                // },
                loadingBuilder: (context) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      color: Colors.transparent,
                    ),
                  );
                },
                onEditingComplete: (s) => debugPrint('Editing completed $s'),

                onEditorResized: (height) =>
                    debugPrint('Editor resized $height'),
                // onSelectionChanged: (sel) =>
                //     debugPrint('index ${sel.index}, range ${sel.length}'),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwInputFields * 2),
            Obx(
              () => AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: controller.loading.value
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            getHtmlText();
                            _uploadImage().then(
                              (value) {
                                controller.updateBrand(widget.brand,
                                    name: nameController.text,
                                    category: controller1.departmentname.value,
                                    subcategory:
                                        controller1.subdepartmentname.value,
                                    about: htmlText.toString(),
                                    // about: widget.brand.about,
                                    imageUrl:
                                        _downloadUrl ?? widget.brand.image);
                                // Get.back();
                                print('name 555 ${nameController.text}');
                                print(
                                    'controller1.departmentname.value 555 ${controller1.departmentname.value}');
                                print(
                                    'controller1.subdepartmentname.value 555 ${controller1.subdepartmentname.value}');
                                print(
                                    'htmlText.toString() 555 ${htmlText.toString()}');
                                print(
                                    'widget.brand.about ${widget.brand.about}');
                                print('_downloadUrl555 $_downloadUrl');
                              },
                            );
                          },
                          child: const Text('Update Field'),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void dataGet() async {
    String? html = await quillcontroller.getText();
    print("quillcontrolle_new $html");
  }
}
