// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, must_be_immutable

import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/model/productmodel.dart';
import 'package:EcommerceApp/viewmodel/filtercontroller.dart';
import 'package:EcommerceApp/viewmodel/mostInterestedcontoller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    this.height = 48,
    this.width,
    this.onTap,
    this.child,
  });

  final double? height;
  final double? width;

  final VoidCallback? onTap;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Material(
        color: AppColor.imagebg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black12),
        ),
        child: InkWell(
          overlayColor: WidgetStatePropertyAll(Colors.white),
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: child ?? const SizedBox(),
          ),
        ),
      ),
    );
  }
}

class MenuWidget extends StatefulWidget {
  MenuWidget(
      {super.key,
      this.width,
      required this.tooltipControllerss,
      this.setState});

  final double? width;
  Function? setState;
  OverlayPortalController tooltipControllerss;

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  FilterController filterController = Get.put(FilterController());
  MostIntrestedController mostIntrestedController =
      Get.put(MostIntrestedController());
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? MediaQuery.of(context).size.width * 0.975,
      // height: MediaQuery.of(context).size.height * 0.5,
      decoration: ShapeDecoration(
        color: Colors.white60,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1.5,
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 32,
            offset: Offset(0, 20),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                'Filter Dailog',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.0),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right: 25.0,
                  ),
                  child: Text(
                    "COLOR",
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 19.0),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Wrap(
                    runSpacing: 10,
                    verticalDirection: VerticalDirection.down,
                    children: <Widget>[
                      Colormanage(
                          color: Colors.white, selcted: 1, setStates: setState),
                      Colormanage(
                          color: Colors.black, selcted: 2, setStates: setState),
                      Colormanage(
                          color: Colors.red, selcted: 3, setStates: setState),
                      Colormanage(
                          color: Colors.blue, selcted: 4, setStates: setState),
                      Colormanage(
                          color: Colors.green, selcted: 5, setStates: setState),
                      InkWell(
                          overlayColor:
                              WidgetStatePropertyAll(AppColor.BgColor),
                          onTap: () {
                            addNewColor();
                          },
                          child: Icon(Icons.color_lens))
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Colorfilter()
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right: 25.0,
                  ),
                  child: Text(
                    "SIZE",
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 19.0),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Wrap(
                    runSpacing: 10,
                    verticalDirection: VerticalDirection.down,
                    children: <Widget>[
                      Sizemanage(size: "XS", selcted: 1, setStates: setState),
                      Sizemanage(size: "S", selcted: 2, setStates: setState),
                      Sizemanage(size: "M", selcted: 3, setStates: setState),
                      Sizemanage(size: "L", selcted: 4, setStates: setState),
                      Sizemanage(size: "XL", selcted: 5, setStates: setState),
                      Sizemanage(size: "XXL", selcted: 6, setStates: setState),
                      Sizemanage(size: "XXXL", selcted: 7, setStates: setState),
                    ],
                  ),
                ),
              ],
            ),
          ),

          //  Sizefilter(),
          CommanDivider(),
          Commantitle(
            title: "Price Range",
            viewall: false,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹ ${filterController.syncvalues.start.toStringAsFixed(1)}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "₹ ${filterController.syncvalues.end.toStringAsFixed(1)}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackShape: RectangularSliderTrackShape(),
                      trackHeight: 7.0,
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    ),
                    child: RangeSlider(
                      min: 0.0,
                      max: 100000.0,
                      labels: RangeLabels(
                          filterController.syncvalues.start.toString(),
                          filterController.syncvalues.end.toString()),
                      activeColor: AppColor.BlackColor,
                      inactiveColor: AppColor.imagebg,
                      onChanged: (values) {
                        setState(() => filterController.syncvalues = values);
                      },
                      values: filterController.syncvalues,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Amountslider(),
          SizedBox(
            height: 30,
          ),
          Wrap(
            runAlignment: WrapAlignment.spaceAround,
            runSpacing: 10,
            children: [
              ApplyBotton(setStates: setState),
              ResetBotton(setStates: setState),
            ],
          ),
        ],
      ),
    );
  }

  int sizeselected = 1;

  int colorselected = 1;
  Widget ApplyBotton({Function? setStates}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        setStates!(() {});
        Filterprefset().then((value) {
          setState(() {
            widget.tooltipControllerss.hide();
            setStates(() {});
          });
        });
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: 450),
        padding: EdgeInsets.symmetric(
          vertical: 15,
        ),
        margin: EdgeInsets.only(left: 24, right: 24, bottom: 24),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColor.btnColorblack),
        child: Text(
          "Apply Filter",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColor.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget ResetBotton({Function? setStates}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        setStates!(() {
          filterController.syncvalues = RangeValues(0.0, 100000.0);
          sizeselected = 1;
          setState(() {
            viewallsearch = viewall;
          });
          colorselected = 1;
          viewall = mostIntrestedController.Reserve;
        });

        setState(() {
          widget.tooltipControllerss.hide();

          setStates(() {});
        });

        // filterController.GetFilterApply().then((value) {
        //   setState(() {
        //     filterController.isLoader = true;
        //   });
        // });
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: 450),
        padding: EdgeInsets.symmetric(
          vertical: 15,
        ),
        margin: EdgeInsets.only(left: 24, right: 24, bottom: 24),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColor.btnColorblack),
        child: Text(
          "Reset Filter",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColor.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  List<ProductModel> viewall = [];
  List<ProductModel> viewallsearch = [];
  Future Filterprefset() async {
    viewallsearch = viewall;
    setState(() {});
    viewall = viewall
        .where((item) =>
            item.price >= filterController.syncvalues.start &&
            item.price <= filterController.syncvalues.end)
        .toList();
    setState(() {});
    // perfs.setDouble("minimum", filterController.syncvalues.start);
    // perfs.setDouble("maximum", filterController.syncvalues.end);
  }

  var productAttributes;
  var attributesFormKeycolors;
  TextEditingController colors_attributes = TextEditingController();
  void addNewColor() {
    // Form Validation
    if (!attributesFormKeycolors.currentState!.validate()) {
      return;
    }

    // Extract only the color codes from the attributes
    List<String> attributeValues =
        colors_attributes.text.trim().split('|').map((e) {
      // Use a regular expression to extract the color code
      final match = RegExp(r'0x[0-9A-Fa-f]{8}').firstMatch(e);
      if (match != null) {
        return match.group(0)!;
      } else {
        return e.trim();
      }
    }).toList();
    final match =
        RegExp(r'0x[0-9A-Fa-f]{8}').firstMatch(colors_attributes.text.trim());
    String Colors = match!.group(0)!;

    bool is_dataIn = false;

    if (productAttributes.isNotEmpty) {
      productAttributes.asMap().forEach(
        (index, element) {
          if (element.name!.contains("Colors")) {
            is_dataIn = true;

            productAttributes[index].values!.add(Colors);

            productAttributes[index] = ProductAttributeModel(
                name: productAttributes[index].name,
                values: productAttributes[index].values);
          } else {
            if (!is_dataIn) {
              is_dataIn = false;
            }
          }
        },
      );
    }

    if (!is_dataIn || productAttributes.isEmpty) {
      // productAttributes
      //     .add(ProductAttributeModel(name: "Colors", values: attributeValues));
    }

    // Debugging output

    // colors_attributes.text = '';
  }

  Widget Sizemanage({size, selcted, Function? setStates}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        setStates!(() {
          sizeselected = selcted;
        });
      },
      child: Container(
        height: 33,
        width: 33,
        padding: EdgeInsets.all(4),
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
            color: sizeselected != selcted
                ? AppColor.BgColor
                : AppColor.BlackColor,
            border: Appborder.appborder,
            borderRadius: BorderRadius.circular(8)),
        child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              size,
              style: TextStyle(
                  fontSize: 18,
                  color: sizeselected == selcted
                      ? AppColor.BgColor
                      : AppColor.BlackColor,
                  fontWeight: FontWeight.w600),
            )),
      ),
    );
  }

  CommanDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 15),
      child: Divider(
        color: AppColor.imagebg,
      ),
    );
  }

  Commantitle({title, viewall, viewalltap}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          viewall == true
              ? InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  onTap: viewalltap,
                  child: Text(
                    "View all",
                    style:
                        TextStyle(fontSize: 16, color: AppColor.viewallcolor),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

  Widget Colormanage({color, selcted, Function? setStates}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        setStates!(() {
          colorselected = selcted;
        });
      },
      child: Container(
        height: 30,
        width: 30,
        padding: EdgeInsets.all(4),
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Appborder.appborder,
        ),
        child: colorselected == selcted
            ? Center(
                child: Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.grey,
                ),
              )
            : null,
      ),
    );
  }
}
