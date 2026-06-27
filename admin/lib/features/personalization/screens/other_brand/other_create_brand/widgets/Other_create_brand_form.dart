// ignore_for_file: unused_local_variable, avoid_print, unnecessary_brace_in_string_interps, non_constant_identifier_names, prefer_const_constructors, sized_box_for_whitespace

import 'dart:typed_data';
import 'package:cwt_ecommerce_admin_panel/common/widgets/containers/rounded_container.dart';
import 'package:cwt_ecommerce_admin_panel/common/widgets/shimmers/shimmer.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/controllers/Otherbrand/other_create_brand_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/controllers/other_category/other_category_controller.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:cwt_ecommerce_admin_panel/utils/validators/validation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:image_picker_web/image_picker_web.dart';

class OtherCreateBrandForm extends StatefulWidget {
  const OtherCreateBrandForm({super.key});

  @override
  State<OtherCreateBrandForm> createState() => _OtherCreateBrandFormState();
}

class _OtherCreateBrandFormState extends State<OtherCreateBrandForm> {
  late QuillEditorController quillcontroller;

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
  final _backgroundColor = Colors.white70;
  final _toolbarIconColor = Colors.black87;
  final _editorTextStyle = const TextStyle(
      fontSize: 18,
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontFamily: 'Roboto');
  final _hintTextStyle = const TextStyle(
      fontSize: 18, color: Colors.black38, fontWeight: FontWeight.normal);

  final bool _hasFocus = false;
  String? htmlText;
  @override
  void initState() {
    quillcontroller = QuillEditorController();
    quillcontroller.onTextChanged((text) {
      debugPrint('listening to $text');
    });
    quillcontroller.onEditorLoaded(() {
      debugPrint('Editor Loaded :)');
    });
    super.initState();
  }

  @override
  void dispose() {
    /// please do not forget to dispose the controller
    quillcontroller.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    print('httml text$htmlText ');
    print("_downloadUrl${_downloadUrl}");
    print("imagee${_image}");
    final controller = Get.put(OtherCreateBrandController());
    // OthersController _otherCoontroller = Get.put(OthersController());
    List createData = [
      'Header',
      'Footer',
    ];
    List footerData = [
      'Fist Data',
      'Explore',
      'Policies',
    ];
    print('department Name${controller.departmentname.value}');

    // final othercontroller = Get.put(OtherCategoryController());
    // final otherMediaController = Get.put(OtherMediaController());
    final OtherCategoryController1 = Get.put(OtherCategoryController());
    return Obx(
      () => TRoundedContainer(
        width: 500,
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              const SizedBox(height: TSizes.sm),
              Text('Create New Field',
                  style: Theme.of(context).textTheme.headlineMedium),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Name Text Field
              TextFormField(
                controller: controller.name.value,
                validator: (value) =>
                    TValidator.validateEmptyText('Name', value),
                decoration: const InputDecoration(
                    labelText: 'Field Name', prefixIcon: Icon(Iconsax.box)),
              ),

              const SizedBox(height: TSizes.spaceBtwInputFields),
              Text('Select Categories',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: TSizes.spaceBtwInputFields / 2),
              // Obx(() => Wrap(
              //       spacing: TSizes.sm,
              //       children: OtherCategoryController.instance.allItems
              //           .map((element) => Padding(
              //                 padding: const EdgeInsets.only(bottom: TSizes.sm),
              //                 child: TChoiceChip(
              //                     text: element.name,
              //                     selected: controller.selectedCategories
              //                         .contains(element),
              //                     onSelected: (value) =>
              //                         controller.toggleSelection(element)),
              //               ))
              //           .toList(),
              //     )),

              controller.loading.value
                  ? const TShimmerEffect(width: double.infinity, height: 50)
                  : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          hintText: 'Select an Options',
                          labelText: 'Select an Options',
                          prefixIcon: Icon(Iconsax.bezier)),
                      onChanged: (newValue) {
                        controller.departmentname.value = newValue!;
                        print("vall${controller.departmentname.value}");
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
              controller.departmentname.value != "Footer"
                  ? SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Sub Categories',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: TSizes.spaceBtwInputFields / 2),
                        // Obx(() => Wrap(
                        //       spacing: TSizes.sm,
                        //       children: OtherCategoryController.instance.allItems
                        //           .map((element) => Padding(
                        //                 padding: const EdgeInsets.only(
                        //                     bottom: TSizes.sm),
                        //                 child: TChoiceChip(
                        //                     text: element.name,
                        //                     selected: controller
                        //                         .selectedCategories
                        //                         .contains(element),
                        //                     onSelected: (value) => controller
                        //                         .toggleSelection(element)),
                        //               ))
                        //           .toList(),
                        //     )),
                        controller.loading.value
                            ? const TShimmerEffect(
                                width: double.infinity, height: 50)
                            : DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                    hintText: 'Select an Options',
                                    labelText: 'Select an Options',
                                    prefixIcon: Icon(Iconsax.bezier)),
                                onChanged: (newValue) {
                                  controller.subdepartmentname.value =
                                      newValue!;
                                  print(
                                      "vall${controller.subdepartmentname.value}");
                                },
                                items: footerData
                                    .map<DropdownMenuItem<String>>((value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                        const SizedBox(height: TSizes.spaceBtwInputFields),
                      ],
                    ),

              controller.subdepartmentname.value != "Fist Data"
                  ? SizedBox()
                  : Row(
                      children: [
                        _image != null
                            ? Container(
                                height: 80,
                                width: 80,
                                child: Image.memory(
                                  _image!,
                                  scale: 2,
                                ))
                            : Text('No image selected.'),
                        const SizedBox(
                          width: 10,
                        ),
                        OutlinedButton(
                            onPressed: () {
                              _pickImage();
                            },
                            child: const Text('Select Images')),
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
                  // InkWell(
                  //     onTap: () => unFocusEditor(),
                  //     child: const Icon(
                  //       Icons.favorite,
                  //       color: Colors.black,
                  //     )),
                  // InkWell(
                  //     onTap: () async {
                  //       var selectedText =
                  //           await quillcontroller.getSelectedText();
                  //       debugPrint('selectedText $selectedText');
                  //       var selectedHtmlText =
                  //           await quillcontroller.getSelectedHtmlText();
                  //       debugPrint('selectedHtmlText $selectedHtmlText');
                  //     },
                  //     child: const Icon(
                  //       Icons.add_circle,
                  //       color: Colors.black,
                  //     )),
                ],
              ),

              SizedBox(
                height: 120,
                child: QuillHtmlEditor(
                  text: "<h1>Hello</h1>This is a quill html editor example 😊",
                  hintText: 'Write About your self',
                  controller: quillcontroller,
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

                  onEditingComplete: (s) => debugPrint('Editing completed $s'),
                  loadingBuilder: (context) {
                    return const Center(
                        //     child: CircularProgressIndicator(
                        //   strokeWidth: 1,
                        //   color: Colors.red,
                        // )
                        );
                  },
                  // onFocusChanged: (focus) {
                  //   debugPrint('has focus $focus');
                  //   setState(() {
                  //     _hasFocus = focus;
                  //   });
                  // },
                  onTextChanged: (text) =>
                      debugPrint('widget text change $text'),
                  onEditorCreated: () {
                    debugPrint('Editor has been loaded');
                    setHtmlText('Testing text on load');
                  },
                  onEditorResized: (height) =>
                      debugPrint('Editor resized $height'),
                  onSelectionChanged: (sel) =>
                      debugPrint('index ${sel.index}, range ${sel.length}'),
                ),
              ),

              Container(
                width: double.maxFinite,
                color: _toolbarColor,
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  children: [
                    // textButton(
                    //     text: 'Set Text',
                    //     onPressed: () {
                    //       setHtmlText('This text is set by you 🫵');
                    //     }),
                    // textButton(
                    //     text: 'Submit Text',
                    //     onPressed: () {
                    //       getHtmlText();
                    //     }),
                    // textButton(
                    //     text: 'Insert Video',
                    //     onPressed: () {
                    //       ////insert
                    //       insertVideoURL(
                    //           'https://www.youtube.com/watch?v=4AoFA19gbLo');
                    //       insertVideoURL('https://vimeo.com/440421754');
                    //       insertVideoURL(
                    //           'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4');
                    //     }),
                    // textButton(
                    //     text: 'Insert Image',
                    //     onPressed: () {
                    //       insertNetworkImage('https://i.imgur.com/0DVAOec.gif');
                    //     }),
                    // textButton(
                    //     text: 'Insert Index',
                    //     onPressed: () {
                    //       insertHtmlText(
                    //           "This text is set by the insertText method",
                    //           index: 10);
                    //     }),
                    const SizedBox(
                      width: 80,
                    ),
                    textButton(
                        text: 'Undo',
                        onPressed: () {
                          quillcontroller.undo();
                        }),
                    const SizedBox(
                      width: 80,
                    ),
                    // textButton(
                    //     text: 'Redo',
                    //     onPressed: () {
                    //       quillcontroller.redo();
                    //     }),
                    // textButton(
                    //     text: 'Clear History',
                    //     onPressed: () async {
                    //       quillcontroller.clearHistory();
                    //     }),
                    textButton(
                        text: 'Clear Editor',
                        onPressed: () {
                          quillcontroller.clear();
                        }),
                    // textButton(
                    //     text: 'Get Delta',
                    //     onPressed: () async {
                    //       var delta = await quillcontroller.getDelta();
                    //       debugPrint('delta');
                    //       debugPrint(jsonEncode(delta));
                    //     }),
                    // textButton(
                    //     text: 'Set Delta',
                    //     onPressed: () {
                    //       final Map<dynamic, dynamic> deltaMap = {
                    //         "ops": [
                    //           {
                    //             "insert": {
                    //               "video":
                    //                   "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
                    //             }
                    //           },
                    //           {
                    //             "insert": {
                    //               "video":
                    //                   "https://www.youtube.com/embed/4AoFA19gbLo"
                    //             }
                    //           },
                    //           {"insert": "Hello"},
                    //           {
                    //             "attributes": {"header": 1},
                    //             "insert": "\n"
                    //           },
                    //           {"insert": "You just set the Delta text 😊\n"}
                    //         ]
                    //       };
                    //       quillcontroller.setDelta(deltaMap);
                    //     }),
                  ],
                ),
              ),
              // Text(
              //   "${htmlText}",
              //   style: TextStyle(fontSize: 16, color: Colors.black),
              // ),
              // Image Uploader & Featured Checkbox
              // Obx(
              //   () => TImageUploader(
              //     width: 80,
              //     height: 80,
              //     image: controller.imageURL.value.isNotEmpty
              //         ? controller.imageURL.value
              //         : TImages.defaultImage,
              //     imageType: controller.imageURL.value.isNotEmpty
              //         ? ImageType.network
              //         : ImageType.asset,
              //     onIconButtonPressed: () => controller.pickImage(),
              //   ),
              // ),
              // const SizedBox(height: TSizes.spaceBtwInputFields),
              // Obx(
              //   () => CheckboxMenuButton(
              //     value: controller.isFeatured.value,
              //     onChanged: (value) =>
              //         controller.isFeatured.value = value ?? false,
              //     child: const Text('Featured'),
              //   ),
              // ),
              // const SizedBox(height: TSizes.spaceBtwInputFields * 2),

              const SizedBox(
                height: 10,
              ),
              Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: controller.loading.value
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () async {
                                print(
                                    'drop value${controller.departmentname.value}');
                                getHtmlText();

                                _uploadImage().then(
                                  (value) {
                                    controller.createBrand(
                                        subcategory:
                                            controller.subdepartmentname.value,
                                        category1:
                                            controller.departmentname.value,
                                        about: htmlText.toString(),
                                        imageUrl: _downloadUrl ?? "");
                                    print('_downloadUrl${_downloadUrl}');
                                  },
                                );

                                // if (_downloadUrl != null) {
                                // getHtmlText();
                                //   controller.createBrand(
                                //       subcategory:
                                //           controller.subdepartmentname.value,
                                //       category1:
                                //           controller.departmentname.value,
                                //       about: htmlText.toString(),
                                //       imageUrl: _downloadUrl);
                                //   _uploadImage();
                                // } else {
                                //   CircularProgressIndicator();
                                // }
                              },
                              child: Text('Create')),
                        ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget textButton({required String text, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MaterialButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: _toolbarIconColor,
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(color: _toolbarColor),
          )),
    );
  }

  ///[getHtmlText] to get the html text from editor
  void getHtmlText() async {
    htmlText = await quillcontroller.getText();
    print("htmlText ::  $htmlText");
  }

  ///[setHtmlText] to set the html text to editor
  void setHtmlText(String text) async {
    await quillcontroller.setText(text);
  }

  ///[insertNetworkImage] to set the html text to editor
  // void insertNetworkImage(String url) async {
  //   await quillcontroller.embedImage(url);
  // }

  ///[insertVideoURL] to set the video url to editor
  ///this method recognises the inserted url and sanitize to make it embeddable url
  ///eg: converts youtube video to embed video, same for vimeo
  // void insertVideoURL(String url) async {
  //   await quillcontroller.embedVideo(url);
  // }

  /// to set the html text to editor
  /// if index is not set, it will be inserted at the cursor postion
  void insertHtmlText(String text, {int? index}) async {
    await quillcontroller.insertText(text, index: index);
  }

  /// to clear the editor
  void clearEditor() => quillcontroller.clear();

  /// to enable/disable the editor
  // void enableEditor(bool enable) => quillcontroller.enableEditor(enable);

  /// method to un focus editor
  // void unFocusEditor() => quillcontroller.unFocus();
}
