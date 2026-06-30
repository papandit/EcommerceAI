// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, sized_box_for_whitespace, non_constant_identifier_names, prefer_interpolation_to_compose_strings, unrelated_type_equality_checks, unnecessary_string_interpolations, prefer_const_constructors_in_immutables, must_be_immutable, unnecessary_import, avoid_function_literals_in_foreach_calls, unnecessary_brace_in_string_interps, dead_code, avoid_unnecessary_containers, sort_child_properties_last, depend_on_referenced_packages, avoid_single_cascade_in_expression_statements, collection_methods_unrelated_type, prefer_typing_uninitialized_variables, prefer_final_fields

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:EcommerceApp/helper/loginshow.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/product_colors.dart';
import 'package:EcommerceApp/helper/tryon_nav.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/cartmodels.dart';
import 'package:EcommerceApp/model/productmodel.dart';
import 'package:EcommerceApp/model/wishlistmodel.dart';
import 'package:EcommerceApp/view/checkoutpage.dart';
import 'package:EcommerceApp/view/loginpage.dart';
import 'package:EcommerceApp/view/mostinterestedpage.dart';
import 'package:EcommerceApp/view/shopping.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/bottom_bar.dart';
import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart' as ip;
import 'package:EcommerceApp/helper/api/user_data_api.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/homecontroller.dart';
import 'package:EcommerceApp/viewmodel/product_detailcontroller.dart';
import 'package:EcommerceApp/viewmodel/shoppingcontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class ProductDetailScreen extends StatefulWidget {
  ProductDetailScreen(
      {super.key,
      this.index,
      this.productModel,
      this.productModelList,
      this.title});
  ProductModel? productModel;
  List<ProductModel>? productModelList;
  int? index;
  String? title;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isCartloader = false;
  bool NoDataFound = false;
  List<dynamic> cartdata = [];
  List<dynamic> rendomseen = [];
  List<dynamic> randomer = [];
  bool fevorite = false;
  bool isvideo = false;
  List<ProductModel> Viwerlist = [];
  List<ProductModel> lastViwerlist = [];
  // Bottom recommendation sections.
  List<ProductModel> moreForYou = [];
  List<ProductModel> recentlyViewed = [];
  String type = "IMAGE";
  String userid = "";

  ProductDetailController productDetailController =
      Get.put(ProductDetailController());
  ShoppingDetailController shoppingDetailController =
      Get.put(ShoppingDetailController());
  Homecontoller homecontoller = Get.put(Homecontoller());
  Future cartidchecker() async {
    final SharedPreferences perfs = await SharedPreferences.getInstance();
    homecontoller.cartid = perfs.getString('cartid') ?? "";
    productDetailController.cartdata = perfs.getString("CartItems") ?? "";
    productDetailController.redomlikedata =
        perfs.getString("rendomseenlike") ?? "";
    userid = perfs.getString(prefrenceKey.userid) ?? '';

    setState(() {
      if (productDetailController.cartdata != '') {
        cartdata = json.decode(productDetailController.cartdata);
      }
      if (productDetailController.redomlikedata.isNotEmpty) {
        rendomseen = json.decode(productDetailController.redomlikedata);
        bool call = false;

        if (!call) {
          rendomlike();
          setState(() {
            call = true;
          });
        }
      } else {
        rendomlike();
        setState(() {});
      }
    });

  }

  taxmanagement() async {
    try {
      final s = await ApiClient.instance.getOne('/settings');
      shoppingDetailController.taxpayment =
          double.tryParse((s['taxRate'] ?? 0).toString()) ?? 0;
      shoppingDetailController.shippingcost =
          (num.tryParse((s['shippingCost'] ?? 0).toString()) ?? 0).toInt();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  rendomlike() async {
    final random = Random();
    int randomseen = random.nextInt(999);
    int randomlike = random.nextInt(999);
    _creatpeoplenumber();
    setState(() {});

    productDetailController.seens = randomseen;
    productDetailController.likes = randomlike;
    setState(() {});
    String encodeMap = json.encode(rendomseen);

    final SharedPreferences perfs = await SharedPreferences.getInstance();
    perfs.setString("rendomseenlike", encodeMap);
  }

  ScrollController scrollController = ScrollController();
  // VideoPlayerController? videoPlayerController;
  List<bool> fevorites = [];

  // ---- Reviews state ----
  List<Map<String, dynamic>> _reviews = [];
  double _avgRating = 0;
  double _myRating = 0;
  final TextEditingController _reviewComment = TextEditingController();
  final List<String> _reviewImages = [];
  bool _reviewSubmitting = false;
  bool _reviewsLoading = true;

  Future<void> _loadReviews() async {
    try {
      final data = await ApiClient.instance
          .getList('/reviews', query: {'productId': widget.productModel?.id});
      double sum = 0;
      int n = 0;
      for (final r in data) {
        final rt = double.tryParse((r['rating'] ?? 0).toString()) ?? 0;
        if (rt > 0) {
          sum += rt;
          n++;
        }
      }
      if (mounted) {
        setState(() {
          _reviews = data;
          _avgRating = n > 0 ? sum / n : 0;
          _reviewsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _reviewsLoading = false);
    }
  }

  Future<void> _pickReviewImage() async {
    try {
      final ip.XFile? file =
          await ip.ImagePicker().pickImage(source: ip.ImageSource.gallery);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() => _reviewSubmitting = true);
      final url = await ApiClient.instance
          .uploadImage(type: 'review', bytes: bytes, filename: file.name);
      setState(() {
        _reviewImages.add(url);
        _reviewSubmitting = false;
      });
    } catch (e) {
      setState(() => _reviewSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Couldn't upload image. Please log in and retry.")));
      }
    }
  }

  Future<void> _submitReview() async {
    if (_myRating < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a star rating.")));
      return;
    }
    setState(() => _reviewSubmitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      // Use the shopper's real profile name (from /auth/me) for the review.
      String name = (prefs.getString("customername") ?? "").trim();
      try {
        final me = await ApiClient.instance.getOne('/auth/me');
        final first =
            (me['FirstName'] ?? me['firstName'] ?? me['name'] ?? '').toString().trim();
        final last = (me['LastName'] ?? me['lastName'] ?? '').toString().trim();
        final full = ('$first $last').trim();
        if (full.isNotEmpty) name = full;
      } catch (_) {}
      if (name.isEmpty) name = "Customer";
      await ApiClient.instance.post('/reviews', {
        'productId': widget.productModel?.id ?? '',
        'rating': _myRating.toInt(),
        'comment': _reviewComment.text.trim(),
        'images': _reviewImages,
        'name': name,
      });
      _reviewComment.clear();
      _reviewImages.clear();
      _myRating = 0;
      await _loadReviews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Thanks! Your review has been added.")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Couldn't submit review.")));
      }
    }
    if (mounted) setState(() => _reviewSubmitting = false);
  }

  @override
  void initState() {
    _loadReviews();
    // Fallback: products created with only a thumbnail (no extra gallery
    // images) used to show "No View". Seed the gallery with the thumbnail so
    // the main image always renders.
    final p = widget.productModel;
    if (p != null) {
      p.images ??= [];
      final hasGallery = p.images!.any((e) => e.trim().isNotEmpty);
      if (!hasGallery && p.thumbnail.trim().isNotEmpty) {
        p.images!.add(p.thumbnail);
      }
      // Merge admin-published BrandShoot model photos into the carousel. Added
      // before the (optional) video link so the video stays the last item.
      if (p.aiGallery != null) {
        for (final ai in p.aiGallery!) {
          final url = ai.fullUrl.trim();
          if (url.isNotEmpty && !p.images!.contains(url)) {
            p.images!.add(url);
          }
        }
      }
    }

    inistate().then(
      (value) {
        if (widget.productModel!.link != null &&
            widget.productModel!.link != '' &&
            widget.productModel!.link!.isNotEmpty) {
          widget.productModel!.images!.add(widget.productModel!.link!);
          isvideo = true;

          setState(() {});
        } else {
          isvideo = false;
          setState(() {});
        }

        setState(() {
          productDetailController.isloder = false;
        });
      },
    );
    super.initState();
  }

  increment() {
    setState(() {
      int couter = 1;
      setState(() {});
      couter = productDetailController.count;
      setState(() {});
      couter++;
      productDetailController.count = couter;
      setState(() {});
    });
  }

  decrement() {
    setState(() {
      int couter = 1;
      setState(() {});
      couter = productDetailController.count;
      setState(() {});
      couter--;
      if (couter <= 1) {
        couter = 1;
      }

      productDetailController.count = couter;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // print("Back Tap");
        // Navigator.of(context).pop();
      },
      child: productDetailController.isloder == true
          ? MediaQuery.of(context).size.width > CommonWidget.headerWidth
              ? Scaffold(
                  body: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: AppColor.BgColor,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: StickyHeader(
                        header: CommonWidget()
                            .StickyHeaders(context, Refresh: setState),
                        content: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.8,
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            CommonWidget().Footer(context)
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Scaffold(
                  body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: AppColor.BgColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                ))
          : MediaQuery.of(context).size.width > CommonWidget.headerWidth
              ? Scaffold(
                  floatingActionButton: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Responsive.isMobile(context) ? 0 : 40.0,
                        vertical: Responsive.isMobile(context) ? 60 : 40),
                    child: InkWell(
                      overlayColor: WidgetStatePropertyAll(Colors.white),
                      onTap: () {
                        whatsapp();
                      },
                      child: Container(
                        height: Responsive.isMobile(context) ? 60 : 75,
                        width: Responsive.isMobile(context) ? 60 : 75,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.green),
                        child: SvgPicture.asset(
                          'assets/image/whatsapplogo.svg',
                          height: Responsive.isMobile(context) ? 60 : 75,
                          width: Responsive.isMobile(context) ? 60 : 75,
                        ),
                      ),
                    ),
                  ),
                  backgroundColor: AppColor.BgColor,
                  body: Container(
                      child: SingleChildScrollView(
                    controller: scrollController,
                    child: StickyHeader(
                      header: CommonWidget()
                          .StickyHeaders(context, Refresh: setState),
                      content: Column(
                        children: [
                          CommonWidget().backButton(context),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ImageWeb(),
                              Expanded(child: Webdetail()),
                            ],
                          ),
                          Newdetails_table(),
                          _reviewsSection(),
                          _recommendationSections(),
                          CommonWidget().Footer(context)
                        ],
                      ),
                    ),
                  )),
                )
              : Scaffold(
                  floatingActionButton: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Responsive.isMobile(context) ? 0 : 40.0,
                        vertical: Responsive.isMobile(context) ? 20 : 40),
                    child: InkWell(
                      overlayColor: WidgetStatePropertyAll(Colors.white),
                      onTap: () {
                        whatsapp();
                      },
                      child: Container(
                        height: Responsive.isMobile(context) ? 60 : 75,
                        width: Responsive.isMobile(context) ? 60 : 75,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.green),
                        child: SvgPicture.asset(
                          'assets/image/whatsapplogo.svg',
                          height: Responsive.isMobile(context) ? 60 : 75,
                          width: Responsive.isMobile(context) ? 60 : 75,
                        ),
                      ),
                    ),
                  ),
                  bottomNavigationBar: bottomPart(),
                  backgroundColor: AppColor.BgColor,
                  appBar: CommonWidget().Header(
                      context: context,
                      ontap: () {
                        if (fevorite == false) {
                          if (homecontoller.userid.isEmpty) {
                            LoginDialog.showLoginDialog(context, () {
                              if (homecontoller.wishlistid == '' ||
                                  homecontoller.wishlistid.isEmpty) {
                                Addtowishlist(FirebasewishlistModel(
                                    userid: homecontoller.userid,
                                    wishitems: [
                                      Wishitems(
                                        brandname:
                                            widget.productModel!.brand!.name,
                                        image: widget.productModel!.thumbnail,
                                        price: widget.productModel!.price
                                            .toString(),
                                        // saleprice: widget.productModel!.salePrice
                                        //     .toString(),
                                        saleprice: ((widget
                                                        .productModel!.price -
                                                    (widget.productModel!
                                                            .price *
                                                        (widget.productModel!
                                                                .salePrice *
                                                            0.01)))
                                                .toInt())
                                            .toString(),
                                        productid: widget.productModel!.id,
                                        productname: widget.productModel!.title,
                                      )
                                    ])).then(
                                  (value) {
                                    cartitem();
                                  },
                                );
                              } else {
                                homecontoller.wishlist.add(Wishitems(
                                  brandname: widget.productModel!.brand!.name,
                                  image: widget.productModel!.thumbnail,
                                  price: widget.productModel!.price.toString(),
                                  saleprice: ((widget.productModel!.price -
                                              (widget.productModel!.price *
                                                  (widget.productModel!
                                                          .salePrice *
                                                      0.01)))
                                          .toInt())
                                      .toString(),
                                  productid: widget.productModel!.id,
                                  productname: widget.productModel!.title,
                                ));
                                setState(() {});
                                updatetowishlist(FirebasewishlistModel(
                                        userid: homecontoller.userid,
                                        wishlistid: homecontoller.wishlistid,
                                        wishitems: homecontoller.wishlist))
                                    .then(
                                  (value) {
                                    setState(() {
                                      fevorite = !fevorite;
                                    });
                                    cartitem();
                                  },
                                );
                              }
                            });
                          } else {
                            if (homecontoller.wishlistid == '' ||
                                homecontoller.wishlistid.isEmpty) {
                              Addtowishlist(FirebasewishlistModel(
                                  userid: homecontoller.userid,
                                  wishitems: [
                                    Wishitems(
                                      brandname:
                                          widget.productModel!.brand!.name,
                                      image: widget.productModel!.thumbnail,
                                      price:
                                          widget.productModel!.price.toString(),
                                      // saleprice: widget.productModel!.salePrice
                                      //     .toString(),
                                      saleprice: ((widget.productModel!.price -
                                                  (widget.productModel!.price *
                                                      (widget.productModel!
                                                              .salePrice *
                                                          0.01)))
                                              .toInt())
                                          .toString(),
                                      productid: widget.productModel!.id,
                                      productname: widget.productModel!.title,
                                    )
                                  ])).then(
                                (value) {
                                  cartitem();
                                },
                              );
                            } else {
                              homecontoller.wishlist.add(Wishitems(
                                brandname: widget.productModel!.brand!.name,
                                image: widget.productModel!.thumbnail,
                                price: widget.productModel!.price.toString(),
                                saleprice: ((widget.productModel!.price -
                                            (widget.productModel!.price *
                                                (widget.productModel!
                                                        .salePrice *
                                                    0.01)))
                                        .toInt())
                                    .toString(),
                                productid: widget.productModel!.id,
                                productname: widget.productModel!.title,
                              ));
                              setState(() {});
                              updatetowishlist(FirebasewishlistModel(
                                      userid: homecontoller.userid,
                                      wishlistid: homecontoller.wishlistid,
                                      wishitems: homecontoller.wishlist))
                                  .then(
                                (value) {
                                  setState(() {
                                    fevorite = !fevorite;
                                  });
                                  cartitem();
                                },
                              );
                            }
                          }
                        } else {
                          homecontoller.wishlist.removeWhere((element) =>
                              element.productid == widget.productModel!.id);
                          removetowishlist(FirebasewishlistModel(
                                  userid: homecontoller.userid,
                                  wishlistid: homecontoller.wishlistid,
                                  wishitems: homecontoller.wishlist))
                              .then(
                            (value) {
                              setState(() {
                                fevorite = !fevorite;
                              });
                              cartitem();
                            },
                          );
                        }
                      },
                      isfev: fevorite),
                  body: ListView(
                    // controller: scrollController,
                    shrinkWrap: true,
                    primary: true,
                    children: [
                      ThreeDModel(),
                      SizedBox(height: 24),
                      imageshow(),
                      SizedBox(height: 24),
                      ProductDetail_Check(),
                      SizedBox(height: 24),
                      DeliveryReturn(),
                      Productdatas(),
                      Share(),
                      Newdetails_table(),
                      _reviewsSection(),
                      _recommendationSections(),
                    ],
                  ),
                ),
    );
  }

  List<dynamic> ordermodel = [];
  int index_item = 0;
  Widget ThreeDModel() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.4,
        // color: AppColor.whiteColor,
        width: MediaQuery.of(context).size.width,
        child: widget.productModel!.images!.isEmpty
            ? Center(
                child: Text(
                  "No View",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              )
            : type == "VIDEO"
                ? Chewie(
                    controller: ChewieController(
                        aspectRatio: 1,
                        autoPlay: true,
                        placeholder: Center(child: CircularProgressIndicator()),
                        fullScreenByDefault: false,
                        allowFullScreen: false,
                        showOptions: false,
                        videoPlayerController: VideoPlayerController.networkUrl(
                            Uri.parse(
                                "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4"))
                        //  videoPlayerController ??
                        //     VideoPlayerController.networkUrl(Uri.parse(
                        //         "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4"))

                        ),
                  )
                : CachedNetworkImage(
                    imageUrl: widget.productModel!.images![index_item],
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.contain),
                        ),
                      );
                    },
                    placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                      color: AppColor.BlackColor,
                    )),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ));
  }

  Widget imageshow() {
    return
        //  widget.productModel!.images == null ||
        //         widget.productModel!.images!.isEmpty
        //     ? Container(
        //         height: 100,
        //         width: 140,
        //       )
        //     :
        Container(
      height: 120,
      width: MediaQuery.of(context).size.width,
      // color: AppColor.bluecolor,
      margin: !Responsive.isMobile(context)
          ? EdgeInsets.symmetric(horizontal: 24)
          : EdgeInsets.zero,
      child: ListView.builder(
        itemCount: widget.productModel!.images!.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          print(
              " widget.productModel!.images! ${widget.productModel!.images![index]}");
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: isvideo == true &&
                    index == (widget.productModel!.images!.length - 1)
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        index_item = index;
                        type = 'VIDEO';
                      });
                    },
                    child: Container(
                      height: 100,
                      width: 140,
                      decoration: BoxDecoration(
                          color: AppColor.whiteColor,
                          border: Border.all(
                              color: index == index_item
                                  ? AppColor.viewallcolor
                                  : Colors.black54)),
                      // color: AppColor.fontColorgrey,
                      child: Icon(
                        Icons.play_arrow,
                        size: 30,
                      ),
                    ),
                  )
                : Container(
                    height: 100,
                    width: 100,
                    child: CachedNetworkImage(
                      imageUrl: widget.productModel!.images![index],
                      imageBuilder: (context, imageProvider) {
                        return InkWell(
                          overlayColor: WidgetStatePropertyAll(Colors.white),
                          onTap: () {
                            setState(() {
                              type = 'IMAGE';
                              index_item = index;
                            });
                          },
                          child: Container(
                            height: 60,
                            width: 100,
                            decoration: BoxDecoration(
                              color: AppColor.whiteColor,
                              border: Border.all(
                                  color: index == index_item
                                      ? AppColor.viewallcolor
                                      : Colors.black54),
                              // borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                        );
                      },
                      placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                        color: AppColor.BlackColor,
                      )),
                      errorWidget: (context, url, error) => InkWell(
                        overlayColor: WidgetStatePropertyAll(Colors.white),
                        onTap: () {
                          setState(() {
                            type = 'IMAGE';
                            index_item = index;
                          });
                        },
                        child: Container(
                          height: 60,
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor,
                            border: Border.all(
                                color: index == index_item
                                    ? AppColor.viewallcolor
                                    : Colors.black54),
                          ),
                          child: Icon(Icons.error),
                        ),
                      ),
                    )),
          );
        },
      ),
    );
  }

  Future relogin() async {
    WebAPPNavigation.navigateToroute(
        context: context, routename: '/LoginPage', screen: LoginPage());
  }

  Widget ProductDetail() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              width: MediaQuery.of(context).size.width * 0.55,
              child: CommonWidget().TextWidget(
                  text: "TITLE",
                  maxline: 4,
                  size: 20.0,
                  weight: FontWeight.w600,
                  color: AppColor.BlackColor,
                  overflow: TextOverflow.ellipsis)),
          Container(
            width: MediaQuery.of(context).size.width * 0.28,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: CommonWidget().TextWidget(
                maxline: 1,
                overflow: TextOverflow.fade,
                text: "₹ 500.0",
                size: 24.0,
                weight: FontWeight.w500,
                color: Color(0xffF2A666),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget ProductDetail_Check() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (widget.productModel!.brand != null &&
                        widget.productModel!.brand!.name
                            .toString()
                            .trim()
                            .isNotEmpty)
                    ? Text(
                        widget.productModel!.brand!.name
                            .toString()
                            .toUpperCase(),
                        style: TextStyle(
                            fontSize: 13,
                            letterSpacing: 1.2,
                            color: AppColor.primary,
                            fontWeight: FontWeight.w700),
                      )
                    : SizedBox(),
                SizedBox(height: 6),
                CommonWidget().TextWidget(
                    text: "${widget.productModel!.title}",
                    maxline: 2,
                    size: Responsive.isMobile(context) ? 22.0 : 32.0,
                    weight: FontWeight.w600,
                    fontFamily: AppFont.heading,
                    color: AppColor.ink,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "₹ ${(widget.productModel!.price - (widget.productModel!.price * (widget.productModel!.salePrice * 0.01))).toStringAsFixed(0)}",
                        style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 24 : 30,
                            fontWeight: FontWeight.w700,
                            color: AppColor.ink),
                      ),
                      SizedBox(width: 12),
                      widget.productModel!.salePrice == 0
                          ? SizedBox()
                          : Text(
                              "₹ ${widget.productModel!.price}",
                              style: TextStyle(
                                  fontSize: 18,
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColor.fontColorgrey,
                                  fontWeight: FontWeight.w500),
                            ),
                      SizedBox(width: 10),
                      widget.productModel!.salePrice == 0
                          ? SizedBox()
                          : Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: AppColor.blush,
                                  borderRadius: BorderRadius.circular(100)),
                              child: Text(
                                "${widget.productModel!.salePrice.toStringAsFixed(0)}% OFF",
                                style: TextStyle(
                                    color: AppColor.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13),
                              ),
                            ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text("MRP inclusive of all taxes",
                      style: TextStyle(
                          fontSize: 12, color: AppColor.fontColorgrey)),
                ],
              ),
            ),
          ),
          SizeList.isEmpty
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          right: 25.0,
                        ),
                        child: Text(
                          "SIZE",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 19.0),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Wrap(
                            runSpacing: 10,
                            verticalDirection: VerticalDirection.down,
                            children: List.generate(
                              SizeList.length,
                              (index) => Sizemanage(
                                  size: SizeList[index], selcted: (index + 1)),
                            )),
                      ),
                    ],
                  ),
                ),
          ColorsList.isEmpty
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          right: 25.0,
                        ),
                        child: Text(
                          "COLOR",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 19.0),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Wrap(
                            runSpacing: 10,
                            verticalDirection: VerticalDirection.down,
                            children: List.generate(
                              ColorsList.length,
                              (index) => Colormanage(
                                  color: Color(int.parse(ColorsList[index])),
                                  selcted: (index + 1)),
                            )),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  int sizeselected = 1;
  int colorselected = 1;

  Widget DescriptionWidget() {
    return false
        ? SizedBox()
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonWidget().TextWidget(
                  text: "Description",
                  size: 20.0,
                  weight: FontWeight.w600,
                  color: AppColor.BlackColor,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: HtmlWidget(
                    """Discriptions (HTML CODE)""",
                  ),
                )
              ],
            ),
          );
  }

  bottomPart() {
    return Container(
      margin: Responsive.isMobile(context)
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.15),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  onTap: () {
                    productDetailController.count == 0 ? null : decrement();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: CircleAvatar(
                      radius: 13,
                      child: Center(
                        child: Image.asset(AppImage.appIcon + "decrease.png"),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  onTap: () async {},
                  child: CommonWidget().TextWidget(
                      text: "${productDetailController.count}",
                      size: 14.0,
                      weight: FontWeight.w400),
                ),
                InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  onTap: () {
                    increment();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: CircleAvatar(
                      radius: 13,
                      child: Center(
                        child: Image.asset(AppImage.appIcon + "increase.png"),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                CommonWidget().TextWidget(
                    text: "Total: ₹ " +
                        (productDetailController.count *
                                ((widget.productModel!.price -
                                    (widget.productModel!.price *
                                        (widget.productModel!.salePrice *
                                            0.01)))))
                            .toStringAsFixed(0)
                            .toString(),
                    size: 16.0,
                    weight: FontWeight.w600),
              ],
            ),
            // Spacer(),
            InkWell(
              overlayColor: WidgetStatePropertyAll(Colors.white),
              onTap: () {
                if (isCartloader == false) {
                  isCartloader = true;
                  setState(() {});

                  if (homecontoller.cartid != "" ||
                      homecontoller.cartid.isNotEmpty) {
                    WebAPPNavigation.navigateToroute(
                            context: context,
                            routename: '/ShoppingPage',
                            screen: ShoppingPage())
                        .then((value) {
                      inistate();
                    });
                  } else {
                    isCartloader = false;
                    setState(() {});
                  }
                }
              },
              child: Buycart(),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<ProductModel>> ProductsDataGet() async {
    try {
      final list = await ApiClient.instance
          .getList('/products', query: {'sort': 'newest'});
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  var data;
  // List<Cartitems> cartitems = [];
  Future<dynamic> inistate() {
    setState(() {
      productDetailController.isloder = true;
      productDetailController.updatecart = false;
    });
    productDetailController.count = 1;

    setState(() {
    });
    taxmanagement();
    ProductsDataGet().then(
      (value) {
        value.forEach(
          (element) {
            if (element.categoryId == widget.productModel!.categoryId) {

              if (element.id != widget.productModel!.id) {
                Viwerlist.add(element);
                lastViwerlist.add(element);
                fevorites.add(false);
              }
            }
          },
        );

        // "More products for you" = other categories (fallback to any others).
        moreForYou = value
            .where((e) =>
                e.id != widget.productModel!.id &&
                e.categoryId != widget.productModel!.categoryId)
            .toList();
        if (moreForYou.length < 4) {
          moreForYou = value
              .where((e) => e.id != widget.productModel!.id)
              .toList();
        }

        // Recently viewed (persisted) + record the current product.
        _loadAndRecordRecentlyViewed(value);

        setState(() {});
        cartidchecker().then(
          (value) {
            UserDataApi.getCart().then(
              (cartItemsList) {
                dataget();
                cartitem();

                homecontoller.MyCart.cartitems ??= [];
                homecontoller.MyCart.cartitems!.addAll(cartItemsList);
                {
                  homecontoller.MyCart.cartitems!.forEach(
                    (element) {
                      if (element.title == widget.productModel!.title) {
                        productDetailController.count = element.quantity ?? 1;

                        if (ColorsList.isNotEmpty && SizeList.isNotEmpty) {
                          ColorsList.asMap().forEach(
                            (index, elements) {
                              if (elements == element.color) {
                                colorselected = (index + 1);
                              }
                            },
                          );
                          SizeList.asMap().forEach(
                            (index, elements) {
                              if (elements == element.size) {
                                sizeselected = (index + 1);
                              }
                            },
                          );
                        }
                      }
                    },
                  );
                }
                Future.delayed(Duration(seconds: 2), () {
                  Viwerlist.asMap().forEach((index, element) {
                    homecontoller.wishlist.forEach((element1) {
                      if (element1.productid == widget.productModel!.id) {
                        fevorite = true;
                      }
                      print(
                          // "checksss element1.element.id = ${element1.productid}");
                          // print(
                          "checksss element1.productid = ${element.id}");
                      // print(
                      //     "checksss element1.brandname = ${element1.brandname}");
                      if (element.id == element1.productid) {
                        print(
                            "ABCCC element1.productid = ${element1.productid}");

                        fevorites[index] = true;
                      } else {
                      }
                      setState(() {});
                    });
                  });
                });
              },
            );
          },
        );
      },
    );

    homecontoller.wishlist.asMap().forEach(
      (listindex, element) {
        if (element.productid == widget.productModel!.id) {
          fevorite = true;
          setState(() {});
        }
      },
    );

    return Future(
      () => null,
    );
  }

  List<String> ColorsList = [];
  List<String> SizeList = [];
  List<String> TagList = [];
  Future dataget() async {
    if (widget.productModel!.productAttributes != null &&
        widget.productModel!.productAttributes!.isNotEmpty) {
      widget.productModel!.productAttributes!.asMap().forEach(
        (index, element) {
          if (element.name == 'Colors') {
            ColorsList.addAll(
                widget.productModel!.productAttributes![index].values!);
          } else if (element.name == 'Sizes') {
            SizeList.addAll(
                widget.productModel!.productAttributes![index].values!);
          } else if (element.name == 'Tags') {
            TagList.addAll(
                widget.productModel!.productAttributes![index].values!);
          }
          setState(() {});
        },
      );
    }
  }

// WEB Widgets
  Widget Sizemanage({size, selcted}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        setState(() {
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

  Widget Colormanage({color, selcted}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        setState(() {
          colorselected = selcted;
        });
      },
      child: Container(
        height: 27,
        width: 27,
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
                  color: Color.fromARGB(255, 0, 255, 98),
                ),
              )
            : null,
      ),
    );
  }

  Widget ImageWeb() {
    final imgs = widget.productModel!.images ?? [];
    final double screenW = MediaQuery.of(context).size.width;
    // Narrower image column; main image is a portrait 3:4 frame (Nykaa-style)
    // so tall product photos aren't cropped at the top/bottom.
    final double colW = screenW * 0.42;
    const double thumbW = 64;
    final double mainW = (colW - 24 - thumbW - 12).clamp(180.0, 480.0);
    final double galleryH = mainW * 4 / 3;
    return Container(
      width: colW,
      padding: const EdgeInsets.only(left: 16, top: 14, right: 8),
      child: imgs.isEmpty
          ? Container(
              height: galleryH,
              alignment: Alignment.center,
              child: Text("No View",
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            )
          : SizedBox(
              height: galleryH,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Vertical scrollable thumbnail strip ──
                  SizedBox(
                    width: thumbW,
                    child: ListView.builder(
                      itemCount: imgs.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, i) {
                        final bool isVid =
                            isvideo == true && i == imgs.length - 1;
                        final bool sel = i == index_item;
                        return GestureDetector(
                          onTap: () => setState(() {
                            index_item = i;
                            type = isVid ? 'VIDEO' : 'IMAGE';
                          }),
                          child: Container(
                            height: 82,
                            margin: const EdgeInsets.only(bottom: 10),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: AppColor.blush,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: sel
                                      ? AppColor.primary
                                      : AppColor.dividercolor,
                                  width: sel ? 1.8 : 1),
                            ),
                            child: isVid
                                ? Icon(Icons.play_circle_fill,
                                    color: AppColor.primary, size: 28)
                                : CachedNetworkImage(
                                    imageUrl: imgs[i],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder: (c, u) => const SizedBox(),
                                    errorWidget: (c, u, e) => Icon(
                                        Icons.image_outlined,
                                        color: AppColor.primary),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  // ── Large main image — fills the column (big, square-ish) ──
                  Expanded(
                    child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Container(
                          decoration: BoxDecoration(
                            color: AppColor.blush,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          clipBehavior: Clip.antiAlias,
                          alignment: Alignment.center,
                          child: type == "VIDEO"
                              ? Chewie(
                                  controller: ChewieController(
                                      aspectRatio: 1,
                                      autoPlay: false,
                                      placeholder: Center(
                                          child: CircularProgressIndicator()),
                                      fullScreenByDefault: false,
                                      allowFullScreen: false,
                                      showOptions: false,
                                      autoInitialize: true,
                                      controlsSafeAreaMinimum: EdgeInsets.zero,
                                      videoPlayerController:
                                          VideoPlayerController.networkUrl(
                                              Uri.parse(
                                                  "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4"))),
                                )
                              : CachedNetworkImage(
                                  // Show the whole photo inside the portrait
                                  // frame so it's never cropped at top/bottom.
                                  imageUrl: imgs[index_item],
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                          color: AppColor.primary)),
                                  errorWidget: (context, url, error) => Center(
                                      child: Icon(Icons.checkroom_outlined,
                                          size: 50, color: AppColor.primary)),
                                ),
                        ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _pdpDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Divider(color: AppColor.dividercolor, height: 1, thickness: 1),
    );
  }

  final TextEditingController _pincodeController = TextEditingController();
  String _pincodeMsg = '';
  bool _pincodeOk = false;

  void _checkPincode() {
    final pin = _pincodeController.text.trim();
    setState(() {
      if (RegExp(r'^[1-9][0-9]{5}$').hasMatch(pin)) {
        _pincodeOk = true;
        final eta = DateTime.now().add(const Duration(days: 5));
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        _pincodeMsg =
            "Delivery available • Free delivery by ${eta.day} ${months[eta.month - 1]} • COD available";
      } else {
        _pincodeOk = false;
        _pincodeMsg = "Please enter a valid 6-digit pincode.";
      }
    });
  }

  Widget _deliveryLocationWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_outlined,
                size: 18, color: AppColor.primary),
            const SizedBox(width: 6),
            Text("Select Delivery Location",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColor.ink)),
          ],
        ),
        const SizedBox(height: 4),
        Text("Enter your pincode to check delivery options & date.",
            style: TextStyle(fontSize: 12.5, color: AppColor.fontColorgrey)),
        const SizedBox(height: 10),
        SizedBox(
          width: 320,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onSubmitted: (_) => _checkPincode(),
                  decoration: InputDecoration(
                    counterText: '',
                    isDense: true,
                    hintText: 'Enter pincode',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColor.blushDeep),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColor.primary, width: 1.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _checkPincode,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text("Apply",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
        if (_pincodeMsg.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(_pincodeOk ? Icons.check_circle : Icons.info_outline,
                  size: 16,
                  color: _pincodeOk ? const Color(0xff2E8B57) : AppColor.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(_pincodeMsg,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _pincodeOk
                            ? const Color(0xff2E8B57)
                            : AppColor.fontColorgrey)),
              ),
            ],
          ),
        ],
        const SizedBox(height: 4),
      ],
    );
  }

  Widget Webdetail() {
    return Container(
      margin: EdgeInsets.only(top: 14, bottom: 25),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          // controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductDetail_Check(),
              _pdpDivider(),
              Buycart(),
              _pdpDivider(),
              DeliveryReturn(),
              _pdpDivider(),
              _deliveryLocationWidget(),
              Productdatas(),
              _pdpDivider(),
              Share(),
            ],
          ),
        ),
      ),
    );
  }

  Widget CartANdBuy() {
    return Container(
      // width: MediaQuery.of(context).size.width * 0.35,
      margin: EdgeInsets.only(top: 12, left: 24),
      child: Wrap(
        runSpacing: 10,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black)),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    left: 2,
                  ),
                  child: InkWell(
                    overlayColor: WidgetStatePropertyAll(Colors.white),
                    onTap: () => decrement(),
                    child: Icon(
                      Icons.remove,
                      color: AppColor.BlackColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    "${productDetailController.count}",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 2.0,
                  ),
                  child: InkWell(
                    overlayColor: WidgetStatePropertyAll(Colors.white),
                    onTap: () => increment(),
                    child: Icon(
                      Icons.add,
                      color: AppColor.BlackColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToTop() async {
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
    // scrollController.animateTo(
    //   0.0,
    //   duration: Duration(milliseconds: 500),
    //   curve: Curves.easeInOut,
    // );
  }

  Future AddtocartTap(
      {List<ProductModel>? productModel,
      int index = 0,
      int counter = 1}) async {

    await cartidchecker().then(
      (value) {
        if (homecontoller.MyCart.cartitems == null ||
            homecontoller.MyCart.cartitems!.isEmpty) {
          Addtodcart(
              FirebaseCartModel(userid: homecontoller.userid, cartitems: [
            Cartitems(
                variationId: '',
                selectedVariation: {},
                brandName: widget.productModel!.brand != null
                    ? widget.productModel!.brand!.name
                    : '',
                image: widget.productModel!.thumbnail,
                // price: widget.productModel!.salePrice.toDouble(),
                price: (widget.productModel!.price -
                        (widget.productModel!.price *
                            (widget.productModel!.salePrice * 0.01)))
                    .toDouble(),
                productId: widget.productModel!.id,
                title: widget.productModel!.title,
                color: ColorsList.isEmpty
                    ? "0xff000000"
                    : ColorsList[(colorselected - 1)],
                size: SizeList.isEmpty ? "40" : SizeList[(sizeselected - 1)],
                quantity: productDetailController.count)
          ])).then(
            (value) {
              WebAPPNavigation.navigateToroute(
                context: context,
                routename: '/ShoppingPage',
                screen: BottomBar(
                  pageindex: 2,
                ),
              );

              CommonWidget.cartitems = homecontoller.MyCart.cartitems!.length;
              setState(() {});
            },
          ).onError(
            (error, stackTrace) {
            },
          );
        } else {

          cartItems().then(
            (value) {

              UpdateTocart(FirebaseCartModel(
                      cartitems: homecontoller.MyCart.cartitems!,
                      cartid: '',
                      userid: homecontoller.userid))
                  .then(
                (value) {
                  navigateSafely(context);
                },
              );
            },
          );
        }
        // }
      },
    );
  }

  Future<void> navigateSafely(BuildContext context) async {
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      WebAPPNavigation.navigateToroute(
        context: context,
        routename: '/ShoppingPage',
        screen: BottomBar(
          pageindex: 2,
        ),
      );
      CommonWidget.cartitems = homecontoller.MyCart.cartitems!.length;
      setState(() {});
    }
  }

  Future<void> Addtodcart(FirebaseCartModel cart) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    homecontoller.cartdata = (JsonEncoder().convert(cart.toJson()));


    setState(() {});
    homecontoller.MyCart =
        FirebaseCartModel.fromJson(jsonDecode(homecontoller.cartdata));
    setState(() {});
    prefs.setString(prefrenceKey.cartdata, homecontoller.cartdata);

    // Persist to the backend (MongoDB) so the cart syncs across devices.
    await UserDataApi.saveCart(homecontoller.MyCart.cartitems ?? []);

    if (homecontoller.MyCart.cartitems == null ||
        homecontoller.MyCart.cartitems!.isEmpty) {
      homecontoller.MyCart = cart;
      setState(() {});
      return;
    }
  }

  Future<void> Itemaddcart() async {
    // int idverify = -1;

    var data = homecontoller.MyCart.cartitems!.asMap().forEach(
      (index, element) {
        if (element.productId == widget.productModel!.id) {
          element.quantity = productDetailController.count;


// setState(() {
//     idverify = index;
// });
        }
      },
    );

  }

  Future<void> cartItems() async {
    // int idverify = -1;
    bool check_prod_id = false;
    homecontoller.MyCart.cartitems!.asMap().forEach(
      (index, element) {
        if (element.productId == widget.productModel!.id) {
          element.quantity = productDetailController.count;

          check_prod_id = true;
        }
      },
    );

    if (!check_prod_id) {
      homecontoller.MyCart.cartitems!.add(Cartitems(
          variationId: '',
          selectedVariation: {},
          brandName: widget.productModel!.brand != null
              ? widget.productModel!.brand!.name
              : 'Brand',
          image: widget.productModel!.thumbnail,
          // price: ((widget.productModel!.price -
          //             (widget.productModel!.price *
          //                 (widget.productModel!.salePrice * 0.01)))
          //         .toInt())
          //     .toDouble(),
          price: (widget.productModel!.price -
                  (widget.productModel!.price *
                      (widget.productModel!.salePrice * 0.01)))
              .toDouble(),
          productId: widget.productModel!.id,
          title: widget.productModel!.title,
          color: ColorsList.isEmpty
              ? "0xff000000"
              : ColorsList[(colorselected - 1)],
          size: SizeList.isEmpty ? "40" : SizeList[(sizeselected - 1)],
          quantity: productDetailController.count));
    } else {
      Updatecartitem();
    }
  }

  Future Updatecartitem() async {

    homecontoller.MyCart.cartitems!.removeWhere(
      (element) => element.productId == widget.productModel!.id,
    );
    homecontoller.MyCart.cartitems!.add(Cartitems(
        variationId: '',
        selectedVariation: {},
        brandName: widget.productModel!.brand!.name,
        image: widget.productModel!.thumbnail,
        price: (widget.productModel!.price -
                (widget.productModel!.price *
                    (widget.productModel!.salePrice * 0.01)))
            .toDouble(),
        productId: widget.productModel!.id,
        title: widget.productModel!.title,
        color:
            ColorsList.isEmpty ? "0xff000000" : ColorsList[(colorselected - 1)],
        size: SizeList.isEmpty ? "40" : SizeList[(sizeselected - 1)],
        quantity: productDetailController.count));
  }

  Future<void> UpdateTocart(FirebaseCartModel cart) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    homecontoller.cartdata = JsonEncoder().convert(cart.toJson());
    setState(() {});
    prefs.setString(prefrenceKey.cartdata, homecontoller.cartdata);

    // Persist to the backend (MongoDB).
    await UserDataApi.saveCart(cart.cartitems ?? []);

    if (homecontoller.MyCart.cartitems == null ||
        homecontoller.MyCart.cartitems!.isEmpty) {
      homecontoller.MyCart = cart;
      setState(() {});
      return;
    }
  }

  Widget Buycart() {
    return widget.productModel!.Stockvalue == "OutStock"
        ? Center(
            child: Container(
              margin: EdgeInsets.only(top: 20),
              width: MediaQuery.of(context).size.width < 600
                  ? MediaQuery.of(context).size.width * 0.7
                  : MediaQuery.of(context).size.width * 0.23,
              height: 45,
              decoration: BoxDecoration(
                  color: AppColor.BlackColor,
                  borderRadius: BorderRadius.circular(5)),
              child: Center(
                  child: Text(
                "OUT OF STOCK",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                  color: AppColor.BgColor,
                ),
              )),
            ),
          )
        : Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              MediaQuery.of(context).size.width > 800
                  ? CartANdBuy()
                  : SizedBox(),
              PressableScale(
                onTap: () {
                  AddtocartTap(
                      productModel: widget.productModelList,
                      index: widget.index ?? 0,
                      counter: productDetailController.count);
                  AppToast.show(context, "Added to your bag");
                },
                child: Container(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width * 0.4
                      : MediaQuery.of(context).size.width * 0.15,
                  margin: EdgeInsets.only(left: 0, right: 5, top: 10),
                  decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(8)),
                  height: 50,
                  child: Center(
                    child: Text(
                      "Add To Cart",
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColor.BgColor,
                          fontFamily: AppFont.lato),
                    ),
                  ),
                ),
              ),
              PressableScale(
                onTap: () {
                  print(
                      "Checksp ${((widget.productModel!.price - (widget.productModel!.price * (widget.productModel!.salePrice * 0.01))).toDouble()) * productDetailController.count}");
                  if (userid.isEmpty) {
                    LoginDialog.showLoginDialog(context, () {
                      WebAPPNavigation.navigateToroute(
                          context: context,
                          routename: '/CheckoutPage',
                          data: {
                            'deliveryfee': 0,
                            'finalamount': shoppingDetailController.taxpayment +
                                shoppingDetailController.shippingcost +
                                ((widget.productModel!.price -
                                        (widget.productModel!.price *
                                            (widget.productModel!.salePrice *
                                                0.01)))
                                    .toInt()),
                            'shippingcost': shoppingDetailController
                                    .taxpayment +
                                shoppingDetailController.shippingcost +
                                ((widget.productModel!.price -
                                        (widget.productModel!.price *
                                            (widget.productModel!.salePrice *
                                                0.01)))
                                    .toInt()),
                            'subtotal': ((widget.productModel!.price -
                                        (widget.productModel!.price *
                                            (widget.productModel!.salePrice *
                                                0.01)))
                                    .toDouble()) *
                                productDetailController.count,
                            'discountsubtotal': 0.0,
                            'cartitems': [
                              Cartitems(
                                  variationId: '',
                                  selectedVariation: {},
                                  brandName: widget.productModel!.brand!.name,
                                  image: widget.productModel!.thumbnail,
                                  price: (widget.productModel!.price -
                                          (widget.productModel!.price *
                                              (widget.productModel!.salePrice *
                                                  0.01)))
                                      .toDouble(),
                                  productId: widget.productModel!.id,
                                  title: widget.productModel!.title,
                                  color: ColorsList.isEmpty
                                      ? "0xff000000"
                                      : ColorsList[(colorselected - 1)],
                                  size: SizeList.isEmpty
                                      ? "40"
                                      : SizeList[(sizeselected - 1)],
                                  quantity: productDetailController.count)
                            ],
                          },
                          screen: CheckoutPage(
                            deliveryfee: 0,
                            discountsubtotal: 0.0,
                            finalamount: shoppingDetailController.taxpayment
                                    .toInt() +
                                shoppingDetailController.shippingcost +
                                ((widget.productModel!.price -
                                        (widget.productModel!.price *
                                            (widget.productModel!.salePrice *
                                                0.01)))
                                    .toInt()),
                            shippingcost: shoppingDetailController.taxpayment
                                    .toInt() +
                                shoppingDetailController.shippingcost +
                                ((widget.productModel!.price -
                                        (widget.productModel!.price *
                                            (widget.productModel!.salePrice *
                                                0.01)))
                                    .toInt()),
                            subtotal: ((widget.productModel!.price -
                                        (widget.productModel!.price *
                                            (widget.productModel!.salePrice *
                                                0.01)))
                                    .toDouble()) *
                                productDetailController.count,
                            cartitems: [
                              Cartitems(
                                  variationId: '',
                                  selectedVariation: {},
                                  brandName: widget.productModel!.brand!.name,
                                  image: widget.productModel!.thumbnail,
                                  price: (widget.productModel!.price -
                                          (widget.productModel!.price *
                                              (widget.productModel!.salePrice *
                                                  0.01)))
                                      .toDouble(),
                                  productId: widget.productModel!.id,
                                  title: widget.productModel!.title,
                                  color: ColorsList.isEmpty
                                      ? "0xff000000"
                                      : ColorsList[(colorselected - 1)],
                                  size: SizeList.isEmpty
                                      ? "40"
                                      : SizeList[(sizeselected - 1)],
                                  quantity: productDetailController.count)
                            ],
                          ));
                    });
                  } else {
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        routename: '/CheckoutPage',
                        data: {
                          'deliveryfee': 0,
                          'finalamount':
                              shoppingDetailController.taxpayment.toInt() +
                                  shoppingDetailController.shippingcost +
                                  ((widget.productModel!.price -
                                          (widget.productModel!.price *
                                              (widget.productModel!.salePrice *
                                                  0.01)))
                                      .toInt()),
                          'shippingcost':
                              shoppingDetailController.taxpayment.toInt() +
                                  shoppingDetailController.shippingcost +
                                  ((widget.productModel!.price -
                                          (widget.productModel!.price *
                                              (widget.productModel!.salePrice *
                                                  0.01)))
                                      .toInt()),
                          'subtotal': ((widget.productModel!.price -
                                      (widget.productModel!.price *
                                          (widget.productModel!.salePrice *
                                              0.01)))
                                  .toDouble()) *
                              productDetailController.count,
                          'discountsubtotal': 0.0,
                          'cartitems': [
                            Cartitems(
                                variationId: '',
                                selectedVariation: {},
                                brandName: widget.productModel!.brand!.name,
                                image: widget.productModel!.thumbnail,
                                price: (widget.productModel!.price -
                                        (widget.productModel!.price *
                                            (widget.productModel!.salePrice *
                                                0.01)))
                                    .toDouble(),
                                productId: widget.productModel!.id,
                                title: widget.productModel!.title,
                                color: ColorsList.isEmpty
                                    ? "0xff000000"
                                    : ColorsList[(colorselected - 1)],
                                size: SizeList.isEmpty
                                    ? "40"
                                    : SizeList[(sizeselected - 1)],
                                quantity: productDetailController.count)
                          ],
                        },
                        screen: CheckoutPage(
                          deliveryfee: 0,
                          subtotal: ((widget.productModel!.price -
                                      (widget.productModel!.price *
                                          (widget.productModel!.salePrice *
                                              0.01)))
                                  .toDouble()) *
                              productDetailController.count,
                          discountsubtotal: 0.0,
                          finalamount:
                              shoppingDetailController.taxpayment.toInt() +
                                  shoppingDetailController.shippingcost +
                                  ((widget.productModel!.price -
                                          (widget.productModel!.price *
                                              (widget.productModel!.salePrice *
                                                  0.01)))
                                      .toInt()),
                          shippingcost:
                              shoppingDetailController.taxpayment.toInt() +
                                  shoppingDetailController.shippingcost +
                                  ((widget.productModel!.price -
                                          (widget.productModel!.price *
                                              (widget.productModel!.salePrice *
                                                  0.01)))
                                      .toInt()),
                          cartitems: [
                            Cartitems(
                                variationId: '',
                                selectedVariation: {},
                                brandName: widget.productModel!.brand!.name,
                                image: widget.productModel!.thumbnail,
                                price: (widget.productModel!.price -
                                        (widget.productModel!.price *
                                            (widget.productModel!.salePrice *
                                                0.01)))
                                    .toDouble(),
                                productId: widget.productModel!.id,
                                title: widget.productModel!.title,
                                color: ColorsList.isEmpty
                                    ? "0xff000000"
                                    : ColorsList[(colorselected - 1)],
                                size: SizeList.isEmpty
                                    ? "40"
                                    : SizeList[(sizeselected - 1)],
                                quantity: productDetailController.count)
                          ],
                        ));
                  }
                },
                child: Container(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width * 0.4
                      : MediaQuery.of(context).size.width * 0.15,
                  margin: EdgeInsets.only(left: 5, top: 10),
                  decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(8)),
                  height: 50,
                  child: Center(
                    child: Text(
                      "Buy Now",
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColor.BgColor,
                          fontFamily: AppFont.lato),
                    ),
                  ),
                ),
              ),
              if (widget.productModel!.aiTryOnEnabled != false) TryOnButton(),
              Responsive.isMobile(context) ? SizedBox() : Fevorite(),
            ],
          );
  }

  Widget TryOnButton() {
    return PressableScale(
      onTap: () => openTryOn(context, widget.productModel!),
      child: Container(
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width * 0.4
            : MediaQuery.of(context).size.width * 0.15,
        margin: EdgeInsets.only(left: 5, top: 10),
        decoration: BoxDecoration(
          color: AppColor.blush,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.primary, width: 1.2),
        ),
        height: 50,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 17, color: AppColor.primary),
              const SizedBox(width: 7),
              Text(
                "Try it on",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primaryDark,
                    fontFamily: AppFont.lato),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget Fevorite() {
    return PressableScale(
      onTap: () {
        AppToast.show(
            context,
            fevorite == false
                ? "Added to your wishlist"
                : "Removed from wishlist",
            icon: Icons.favorite);
        if (fevorite == false) {
          if (homecontoller.userid.isEmpty) {
            LoginDialog.showLoginDialog(context, () {
              if (homecontoller.wishlistid.isEmpty) {
                Addtowishlist(FirebasewishlistModel(
                    userid: homecontoller.userid,
                    wishitems: [
                      Wishitems(
                        brandname: widget.productModel!.brand!.name,
                        image: widget.productModel!.thumbnail,
                        price: widget.productModel!.price.toString(),
                        saleprice: (widget.productModel!.price -
                                (widget.productModel!.price *
                                    (widget.productModel!.salePrice * 0.01)))
                            .toString(),
                        productid: widget.productModel!.id,
                        productname: widget.productModel!.title,
                      )
                    ])).then(
                  (value) {
                    cartitem();
                  },
                );
              } else {
                homecontoller.wishlist.add(Wishitems(
                  brandname: widget.productModel!.brand!.name,
                  image: widget.productModel!.thumbnail,
                  price: widget.productModel!.price.toString(),
                  saleprice: (widget.productModel!.price -
                          (widget.productModel!.price *
                              (widget.productModel!.salePrice * 0.01)))
                      .toString(),
                  productid: widget.productModel!.id,
                  productname: widget.productModel!.title,
                ));
                setState(() {});
                updatetowishlist(FirebasewishlistModel(
                        userid: homecontoller.userid,
                        wishlistid: homecontoller.wishlistid,
                        wishitems: homecontoller.wishlist))
                    .then(
                  (value) {
                    setState(() {
                      fevorite = !fevorite;
                    });
                    cartitem();
                  },
                );
              }
            });
          } else {
            if (homecontoller.wishlistid.isEmpty) {
              Addtowishlist(FirebasewishlistModel(
                  userid: homecontoller.userid,
                  wishitems: [
                    Wishitems(
                      brandname: widget.productModel!.brand!.name,
                      image: widget.productModel!.thumbnail,
                      price: widget.productModel!.price.toString(),
                      saleprice: ((widget.productModel!.price -
                                  (widget.productModel!.price *
                                      (widget.productModel!.salePrice * 0.01)))
                              .toInt())
                          .toString(),
                      productid: widget.productModel!.id,
                      productname: widget.productModel!.title,
                    )
                  ])).then(
                (value) {
                  cartitem();
                },
              );
            } else {
              homecontoller.wishlist.add(Wishitems(
                brandname: widget.productModel!.brand!.name,
                image: widget.productModel!.thumbnail,
                price: widget.productModel!.price.toString(),
                saleprice: ((widget.productModel!.price -
                            (widget.productModel!.price *
                                (widget.productModel!.salePrice * 0.01)))
                        .toInt())
                    .toString(),
                productid: widget.productModel!.id,
                productname: widget.productModel!.title,
              ));
              setState(() {});
              updatetowishlist(FirebasewishlistModel(
                      userid: homecontoller.userid,
                      wishlistid: homecontoller.wishlistid,
                      wishitems: homecontoller.wishlist))
                  .then(
                (value) {
                  setState(() {
                    fevorite = !fevorite;
                  });
                  cartitem();
                },
              );
            }
          }
        } else {
          // print("checksp1223 = = ${homecontoller.wishlist[0].productid}");
          // print("checksp1223 productModel= = ${widget.productModel!.id}");
          // // homecontoller.wishlist.removeWhere(
          // //     (element) => element.productid == widget.productModel!.id);
          // homecontoller.wishlist.asMap().forEach((index, element1) {
          //   if (homecontoller.wishlist[index].productid ==
          //       widget.productModel!.id) {
          //     homecontoller.wishlist.removeAt(index);
          //   }
          // });

          // print("checksp1223 = = ${homecontoller.wishlist}");
          // setState(() {});
          // Future.delayed(Duration(seconds: 2), () {
          //   removetowishlist(FirebasewishlistModel(
          //           userid: homecontoller.userid,
          //           wishlistid: homecontoller.wishlistid,
          //           wishitems: homecontoller.wishlist))
          //       .then(
          //     (value) {
          //       setState(() {
          //         fevorite = !fevorite;
          //       });
          //       cartitem();
          //     },
          //   );
          // });
          homecontoller.wishlist.removeWhere(
              (element) => element.productid == widget.productModel!.id);
          removetowishlist(FirebasewishlistModel(
                  userid: homecontoller.userid,
                  wishlistid: homecontoller.wishlistid,
                  wishitems: homecontoller.wishlist))
              .then(
            (value) {
              setState(() {
                fevorite = !fevorite;
              });


              cartitem();
            },
          );
        }
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColor.dividercolor.withValues(alpha: 0.3)),
        padding: EdgeInsets.symmetric(horizontal: 24),
        margin: EdgeInsets.only(top: 10, left: 10),
        child: Icon(fevorite ? Icons.favorite : Icons.favorite_border),
      ),
    );
  }

  Widget _pdpFeatureRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          width: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColor.blush, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColor.primary, size: 22),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      color: AppColor.ink,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 2),
              Text(desc,
                  style: TextStyle(
                      fontSize: 13, height: 1.4, color: AppColor.fontColorgrey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pdpMetaRow(IconData icon, String label, String value) {
    if (value.trim().isEmpty) return SizedBox();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColor.fontColorgrey),
          SizedBox(width: 10),
          Text("$label: ",
              style: TextStyle(
                  fontSize: 14.5,
                  color: AppColor.ink,
                  fontWeight: FontWeight.w600)),
          Flexible(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 14.5, color: AppColor.fontColorgrey))),
        ],
      ),
    );
  }

  Widget DeliveryReturn() {
    return Container(
      width: Responsive.isMobile(context)
          ? double.infinity
          : MediaQuery.of(context).size.width * 0.42,
      margin: EdgeInsets.only(left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pdpFeatureRow(Icons.local_shipping_outlined,
              "Free Delivery & Easy Returns",
              "Complimentary shipping with a 7-day return window."),
          SizedBox(height: 14),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
                color: AppColor.blush, borderRadius: BorderRadius.circular(100)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.visibility_outlined,
                    size: 16, color: AppColor.primary),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "${peoplecount == '' ? '45' : peoplecount} people are viewing this right now",
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColor.ink,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget Productdatas() {
    return Container(
      width: Responsive.isMobile(context)
          ? double.infinity
          : MediaQuery.of(context).size.width * 0.42,
      margin: EdgeInsets.only(left: 24, right: 24, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pdpMetaRow(
              Icons.qr_code_2_outlined, "SKU", "${widget.productModel!.sku}"),
          _pdpMetaRow(Icons.category_outlined, "Categories",
              "${widget.productModel!.subCategoryName}"),
          TagList.isEmpty
              ? SizedBox()
              : _pdpMetaRow(Icons.sell_outlined, "Tags", TagList.join(", ")),
          _pdpMetaRow(
              Icons.verified_outlined,
              "Brands",
              widget.productModel!.brand == null
                  ? "Brand"
                  : "${widget.productModel!.brand!.name}"),
        ],
      ),
    );
  }

  String peoplecount = '';
  String _creatpeoplenumber() {
    var rng = Random();
    peoplecount = rng.nextInt(100).toString();
    return rng.nextInt(100).toString();
  }

  Widget _shareIcon(String asset, double size, VoidCallback onTap) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 46,
        width: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.blush,
          shape: BoxShape.circle,
          border: Border.all(color: AppColor.blushDeep),
        ),
        child: SvgPicture.asset(asset, height: size, width: size),
      ),
    );
  }

  Widget Share() {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 6),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 12,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              "Share this product",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
                letterSpacing: 0.2,
                color: AppColor.ink,
              ),
            ),
          ),
          _shareIcon("assets/image/facebook.svg", 20, () {
            String digital_url = "https://facebook.com";
            var fbUrl = "fb://facewebmodal/f?href=" + digital_url;
            launchFacebook(fbUrl, digital_url);
          }),
          _shareIcon("assets/image/instagram.svg", 20, () {
            String nativeUrl = "instagram://user?username=severinas_app";
            String webUrl = "https://www.instagram.com";
            launchFacebook(nativeUrl, webUrl);
          }),
          _shareIcon("assets/image/whatsapps.svg", 22, () {
            whatsapp();
          }),
        ],
      ),
    );
  }

  List<bool> datas = [false, false, false, false, false];
  bool datasone = false;
  Widget Newdetails({title}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        setState(() {
          datas[0] = !datas[0];
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        padding: EdgeInsets.symmetric(vertical: 5),
        margin: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: InkWell(
                overlayColor: WidgetStatePropertyAll(Colors.white),
                onTap: () {
                  setState(() {
                    datas[0] = !datas[0];
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Icon(
                      datas == false
                          ? Icons.keyboard_arrow_down_outlined
                          : Icons.keyboard_arrow_up_outlined,
                      color: AppColor.BlackColor,
                      size: 25,
                    )
                  ],
                ),
              ),
            ),
            datas == false
                ? Container()
                : Container(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Whether you're hitting the pavement with your community or on your own, there's nothing quite like the joyful rush of a runner's high. One thing's for sure: comfort and support are paramount in maximizing your daily run. Introducing the Own the Run Woven Astro Pants — the ultimate running companion when it's too cold out for shorts. Crafted from a comfy weave fabric, they're cut for a regular fit with a drawcord waist to keep them in place. Sweat-wicking AEROREADY helps keep you feeling dry, while various pockets allow you to stash essentials on the go. Reflective details shine in low light, so you can fit your run schedule around your busy everyday life. ",
                        style: TextStyle(color: AppColor.BlackColor),
                      ),
                    ),
                  ),

            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 24),
            //   child: Divider(
            //     height: 1,
            //     thickness: 1,
            //     color: AppColor.fontColorgrey,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // ---- Accordion section content -----------------------------------------
  Widget _sectionContent(int index) {
    switch (index) {
      case 0:
        return _descriptionContent();
      case 1:
        return _productAttributesGrid();
      case 2:
        return _faqContent();
      case 3:
        return _shippingContent();
      default:
        return const SizedBox();
    }
  }

  Widget _descriptionContent() {
    final d = (widget.productModel?.description ?? '').trim();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          d.isNotEmpty && d.toLowerCase() != 'null'
              ? d
              : "A thoughtfully crafted ${(widget.productModel?.title ?? 'piece').toLowerCase()} designed for everyday comfort and effortless style. Made with quality materials and a flattering fit you'll love to wear again and again.",
          style: TextStyle(
              fontSize: 16, color: AppColor.BlackColor, height: 1.5),
        ),
      ),
    );
  }

  // Product attributes as a clean 2-column grid (Material / Pattern / …).
  Widget _productAttributesGrid() {
    final attrs = (widget.productModel?.productAttributes ?? [])
        .where((a) =>
            (a.name ?? '').trim().isNotEmpty &&
            (a.values ?? []).where((v) => v.trim().isNotEmpty).isNotEmpty)
        .toList();

    // Always-present basics derived from the product.
    final List<List<String>> basics = [];
    if ((widget.productModel?.brand?.name ?? '').isNotEmpty) {
      basics.add(["Brand", widget.productModel!.brand!.name]);
    }
    if ((widget.productModel?.subCategoryName ?? '').isNotEmpty) {
      basics.add(["Category", widget.productModel!.subCategoryName!]);
    }
    if ((widget.productModel?.sku ?? '').isNotEmpty) {
      basics.add(["SKU", widget.productModel!.sku!]);
    }

    final List<List<String>> rows = [
      ...basics,
      ...attrs.map((a) => [
            a.name!.trim(),
            (a.values ?? [])
                .where((v) => v.trim().isNotEmpty)
                .toList()
                .join(', ')
          ]),
    ];

    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text("No additional details available for this product.",
              style: TextStyle(fontSize: 15, color: AppColor.fontColorgrey)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(builder: (ctx, c) {
        final bool twoCol = c.maxWidth > 480;
        final double itemW = twoCol ? (c.maxWidth / 2 - 18) : c.maxWidth;
        return Wrap(
          spacing: 36,
          runSpacing: 18,
          children: rows.map((r) {
            return SizedBox(
              width: itemW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r[0],
                      style: TextStyle(
                          fontSize: 12.5,
                          color: AppColor.fontColorgrey,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(r[1],
                      style: TextStyle(
                          fontSize: 15,
                          height: 1.3,
                          color: AppColor.ink,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 10),
            child: Container(
                height: 6,
                width: 6,
                decoration: BoxDecoration(
                    color: AppColor.primary, shape: BoxShape.circle)),
          ),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 15, height: 1.45, color: AppColor.BlackColor)),
          ),
        ],
      ),
    );
  }

  Widget _qa(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q,
              style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColor.ink)),
          const SizedBox(height: 4),
          Text(a,
              style: TextStyle(
                  fontSize: 14.5, height: 1.45, color: AppColor.fontColorgrey)),
        ],
      ),
    );
  }

  Widget _faqContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _qa("Is Cash on Delivery (COD) available?",
              "Yes, COD is available on this product across most pincodes. You can also pay online via UPI, cards or net-banking."),
          _qa("How long will delivery take?",
              "Orders are usually delivered within 4–7 business days. You'll receive a tracking number once your order is shipped."),
          _qa("Can I return or exchange this item?",
              "Yes — we offer a 7-day easy return and size-exchange window from the date of delivery for unused items with tags intact."),
          _qa("How do I choose the right size?",
              "Use the Size Guide tab above to match your measurements. If you're between sizes, we recommend sizing up."),
          _qa("How should I care for this product?",
              "Please follow the care instructions listed under Additional information. When in doubt, gentle hand-wash and dry in shade."),
        ],
      ),
    );
  }

  Widget _shippingContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Shipping",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColor.ink)),
          const SizedBox(height: 8),
          _bullet(
              "Free standard delivery on this order. Estimated delivery in 4–7 business days."),
          _bullet(
              "A tracking number is shared once your order is dispatched — track it anytime from My Orders."),
          const SizedBox(height: 6),
          Text("Cash on Delivery (COD)",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColor.ink)),
          const SizedBox(height: 8),
          _bullet(
              "COD is available on this product. Please keep exact change ready at the time of delivery."),
          _bullet(
              "Prefer prepaid? Pay securely via UPI, cards or net-banking at checkout."),
          const SizedBox(height: 6),
          Text("Returns & Exchange",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColor.ink)),
          const SizedBox(height: 8),
          _bullet(
              "Easy 7-day returns & size exchange from delivery, for unused items with original tags and packaging."),
          _bullet(
              "Refunds are processed to your original payment method (or as store credit for COD) within 5–7 business days after pickup."),
        ],
      ),
    );
  }

  Widget Newdetails_table() {
    final sections = <Map<String, dynamic>>[
      {'i': 1, 't': "Product Details", 'ic': Icons.list_alt_outlined},
      {'i': 0, 't': "Description", 'ic': Icons.description_outlined},
      {'i': 2, 't': "FAQ", 'ic': Icons.help_outline_rounded},
      {
        'i': 3,
        't': "Shipping, COD & Returns",
        'ic': Icons.local_shipping_outlined
      },
      {'i': 4, 't': "Size Guide", 'ic': Icons.straighten_rounded},
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(
        children: sections
            .map((s) => _accordionCard(
                s['t'] as String, s['i'] as int, s['ic'] as IconData))
            .toList(),
      ),
    );
  }

  Widget _accordionCard(String title, int index, IconData icon) {
    final bool open = datas[index];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: open
                ? AppColor.primary.withValues(alpha: 0.45)
                : AppColor.blushDeep),
        boxShadow: open
            ? [
                BoxShadow(
                    color: AppColor.primary.withValues(alpha: 0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 6))
              ]
            : [],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
            onTap: () {
              if (datas[index] == true) {
                setState(() => datas[index] = false);
              } else {
                discriptionON().then((_) {
                  if (mounted) setState(() => datas[index] = true);
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: open ? AppColor.primary : AppColor.blush,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon,
                        size: 20, color: open ? Colors.white : AppColor.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColor.ink)),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColor.primary, size: 26),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: AppColor.blushDeep, height: 1),
                  const SizedBox(height: 12),
                  index == 4
                      ? Container(
                          height: 300,
                          alignment: Alignment.center,
                          child: Image.asset("assets/image/sizeguide.png"))
                      : _sectionContent(index),
                ],
              ),
            ),
            crossFadeState:
                open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }

  Future discriptionON() async {
    datas.asMap().forEach(
      (index, element) {
        datas[index] = false;
      },
    );
  }

  // ── Recently viewed (persisted in SharedPreferences) ────────────────────
  Future<void> _loadAndRecordRecentlyViewed(List<ProductModel> all) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> ids = prefs.getStringList('recentlyViewed') ?? [];

      // Resolve stored ids to products (excluding the current one), in order.
      final List<ProductModel> rv = [];
      for (final id in ids) {
        if (id == widget.productModel!.id) continue;
        final match = all.firstWhere((p) => p.id == id,
            orElse: () => ProductModel.empty());
        if (match.id.isNotEmpty) rv.add(match);
      }

      // Record the current product at the front (most recent first).
      ids.remove(widget.productModel!.id);
      ids.insert(0, widget.productModel!.id);
      if (ids.length > 12) ids = ids.sublist(0, 12);
      await prefs.setStringList('recentlyViewed', ids);

      if (mounted) setState(() => recentlyViewed = rv);
    } catch (_) {}
  }

  // ── Bottom recommendation sections (same card design everywhere) ─────────
  // ---- Ratings & Reviews section -----------------------------------------
  Widget _reviewsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.blushDeep),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Ratings & Reviews",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.ink)),
              const Spacer(),
              if (_reviews.isNotEmpty) ...[
                Icon(Icons.star_rounded,
                    color: const Color(0xffF5A623), size: 20),
                Text(" ${_avgRating.toStringAsFixed(1)}",
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: AppColor.ink)),
                Text("  (${_reviews.length})",
                    style: TextStyle(color: AppColor.fontColorgrey)),
              ],
            ],
          ),
          const SizedBox(height: 14),
          // ---- Write a review ----
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColor.blush.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Write a review",
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: AppColor.ink)),
                const SizedBox(height: 8),
                RatingBar.builder(
                  initialRating: _myRating,
                  minRating: 1,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 30,
                  glow: false,
                  unratedColor: AppColor.blushDeep,
                  itemBuilder: (c, _) =>
                      const Icon(Icons.star_rounded, color: Color(0xffF5A623)),
                  onRatingUpdate: (r) => setState(() => _myRating = r),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _reviewComment,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Share your experience with this product...",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColor.blushDeep),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: AppColor.primary, width: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ..._reviewImages.map((u) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(u,
                              height: 54, width: 54, fit: BoxFit.cover),
                        )),
                    InkWell(
                      onTap: _reviewSubmitting ? null : _pickReviewImage,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColor.primary),
                        ),
                        child: Icon(Icons.add_a_photo_outlined,
                            color: AppColor.primary, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _reviewSubmitting ? null : _submitReview,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _reviewSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text("Submit Review",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ---- Reviews list ----
          if (_reviewsLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text("No reviews yet — be the first to review!",
                  style: TextStyle(color: AppColor.fontColorgrey)),
            )
          else
            ..._reviews.map(_reviewTile),
        ],
      ),
    );
  }

  Widget _reviewTile(Map<String, dynamic> r) {
    final rating = double.tryParse((r['rating'] ?? 0).toString()) ?? 0;
    final name = (r['name'] ?? 'Customer').toString().trim();
    final comment = (r['comment'] ?? r['message'] ?? '').toString();
    final images = ((r['images'] as List?) ?? []).map((e) => e.toString()).toList();
    final created = (r['createdAt'] ?? r['CreatedAt'] ?? '').toString();
    String dateStr = '';
    final dt = DateTime.tryParse(created);
    if (dt != null) {
      const m = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      dateStr = "${dt.day} ${m[dt.month - 1]} ${dt.year}";
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColor.blush,
                child: Text(
                    (name.isNotEmpty ? name[0] : 'C').toUpperCase(),
                    style: TextStyle(
                        color: AppColor.primary, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.isNotEmpty ? name : 'Customer',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: AppColor.ink)),
                    if (dateStr.isNotEmpty)
                      Text(dateStr,
                          style: TextStyle(
                              fontSize: 11.5, color: AppColor.fontColorgrey)),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: rating,
                itemCount: 5,
                itemSize: 16,
                unratedColor: AppColor.blushDeep,
                itemBuilder: (c, _) =>
                    const Icon(Icons.star_rounded, color: Color(0xffF5A623)),
              ),
            ],
          ),
          if (comment.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(comment,
                style: TextStyle(
                    height: 1.4, color: AppColor.BlackColor, fontSize: 14.5)),
          ],
          if (images.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: images
                  .map((u) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(u,
                            height: 64, width: 64, fit: BoxFit.cover),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Divider(color: AppColor.blushDeep, height: 1),
        ],
      ),
    );
  }

  Widget _recommendationSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _recSection("Similar Products", lastViwerlist),
        _recSection("Recently Viewed", recentlyViewed),
        _recSection("More Products For You", moreForYou),
      ],
    );
  }

  Widget _recSection(String title, List<ProductModel> items) {
    if (items.isEmpty) return SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            title,
            style: TextStyle(
                fontFamily: AppFont.heading,
                color: AppColor.ink,
                letterSpacing: 0.2,
                fontSize: Responsive.isMobile(context) ? 20 : 26,
                fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: Responsive.isMobile(context) ? 300 : 360,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length <= 12 ? items.length : 12,
            itemBuilder: (context, index) => _recCard(items[index], items, index),
          ),
        ),
      ],
    );
  }

  Widget _recCard(ProductModel p, List<ProductModel> list, int index) {
    final offer = p.price - (p.price * (p.salePrice * 0.01));
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.isMobile(context) ? 6 : 10, vertical: 6),
      child: HoverLift(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          WebAPPNavigation.navigateToroute(
            context: context,
            routename:
                '/ProductDetailScreen/${p.id}',
            data: {
              'index': index,
              'productModelList': list,
              'productModel': p,
              'productName': p.title,
            },
            screen: ProductDetailScreen(
              index: index,
              productModelList: list,
              productModel: p,
              title: p.title,
            ),
          );
        },
        child: Container(
          width: Responsive.isMobile(context) ? 180 : 240,
          decoration: BoxDecoration(
              color: AppColor.whiteColor,
              border: Appborder.appborder,
              boxShadow: [Appshadow.shadow],
              borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: AppColor.blush,
                  child: CachedNetworkImage(
                    imageUrl: p.thumbnail,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColor.primary)),
                    errorWidget: (c, u, e) => Center(
                        child: Icon(Icons.checkroom_outlined,
                            color: AppColor.primary)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (p.brand?.name ?? '').toString().toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppColor.fontColorgrey,
                          fontSize: 11,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 3),
                    Text(
                      p.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          height: 1.25,
                          color: AppColor.ink,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 7,
                      children: [
                        Text(
                          "₹${offer.toStringAsFixed(0)}",
                          style: TextStyle(
                              color: AppColor.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        ),
                        if (p.salePrice != 0)
                          Text(
                            "₹${p.price}",
                            style: TextStyle(
                                color: AppColor.fontColorgrey,
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough),
                          ),
                        if (p.salePrice != 0)
                          Text(
                            "(${p.salePrice.toStringAsFixed(0)}% OFF)",
                            style: TextStyle(
                                color: Color(0xff2E8B57),
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                      ],
                    ),
                    productColorSwatches(p),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Viewerlooktitle() {
    return Viwerlist.isEmpty
        ? SizedBox()
        : Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Similar Products",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 18 : 23,
                      fontWeight: FontWeight.w700),
                ),
                InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  onTap: () {
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        routename: '/ViewAll',
                        data: {'visitlist': Viwerlist},
                        screen: ViewAll(
                          visitlist: Viwerlist,
                        ));
                  },
                  child: Text(
                    "View All",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 18,
                        fontWeight: FontWeight.w500,
                        color: AppColor.viewallcolor),
                  ),
                )
              ],
            ),
          );
  }

  ViewerlookListview() {
    return Container(
      height: Responsive.isMobile(context) ? 300 : 430,
      width: MediaQuery.of(context).size.width,
      child: Viwerlist.isEmpty
          ? Center(
              child: Text(
                "No Data Found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            )
          : ListView.builder(
              itemCount: Viwerlist.length <= 6 ? Viwerlist.length : 6,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {

                return
                    //  index == widget.index
                    //     ? Container()
                    //     :
                    Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.isMobile(context) ? 6.0 : 15.0,
                      vertical: 8),
                  child: InkWell(
                    overlayColor: WidgetStatePropertyAll(Colors.white),
                    onTap: () {
                      Viwerlist.add(widget.productModel!);
                      widget.productModel = Viwerlist[index];
                      widget.productModelList = Viwerlist;
                      Viwerlist.removeAt(index);
                      widget.index = index;
                      if (fevorites[index]) {
                        fevorite = true;
                      } else {
                        fevorite = false;
                      }
                      fevorites.fillRange(0, fevorites.length, false);

                      Viwerlist.asMap().forEach((index, element) {
                        homecontoller.wishlist.forEach((element1) {
                          if (element1.productid == widget.productModel!.id) {
                            fevorite = true;
                          }

                          if (element.id == element1.productid) {
                            print(
                                "ABCCC element1.productid = ${element1.productid}");

                            fevorites[index] = true;
                          } else {
                          }
                          setState(() {});
                        });
                      });
                      _scrollToTop();
                      setState(() {});
                    },
                    child: Container(
                      width: Responsive.isMobile(context) ? 180 : 300,
                      decoration: BoxDecoration(
                          color: AppColor.whiteColor,
                          border: Appborder.appborder,
                          boxShadow: [Appshadow.shadow],
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Flexible(
                              flex: 1,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageBuilder: (context, imageProvider) {
                                        return Container(
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.contain),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        );
                                      },
                                      imageUrl: Viwerlist[index].thumbnail,
                                      placeholder: (context, url) => Center(
                                              child: CircularProgressIndicator(
                                            color: AppColor.BlackColor,
                                          )),
                                      errorWidget: (context, url, error) {
                                        // print("errror :: ${error}");
                                        return Icon(Icons.error);
                                      }),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      overlayColor:
                                          WidgetStatePropertyAll(Colors.white),
                                      onTap: () {
                                        int removeindex = 0;
                                        if (fevorites[index] == true) {
                                          homecontoller.wishlist.removeWhere(
                                              (element) =>
                                                  element.productid ==
                                                  Viwerlist[index].id);
                                          removetowishlist(
                                                  FirebasewishlistModel(
                                                      userid:
                                                          homecontoller.userid,
                                                      wishlistid: homecontoller
                                                          .wishlistid,
                                                      wishitems: homecontoller
                                                          .wishlist))
                                              .then(
                                            (value) {
                                              fevorites[index] = false;
                                              setState(() {});
                                              print(
                                                  "fevorites index ${fevorites}");

                                              cartitem();
                                            },
                                          );
                                        } else {
                                          print(
                                              'SPcheck ${homecontoller.wishlistid}');
                                          if (homecontoller.userid.isEmpty) {
                                            LoginDialog.showLoginDialog(context,
                                                () {
                                              if (homecontoller.wishlistid ==
                                                      '' ||
                                                  homecontoller
                                                      .wishlistid.isEmpty) {
                                                Addtowishlist(
                                                    FirebasewishlistModel(
                                                        userid: homecontoller
                                                            .userid,
                                                        wishitems: [
                                                      Wishitems(
                                                        brandname:
                                                            Viwerlist[index]
                                                                .brand!
                                                                .name,
                                                        image: Viwerlist[index]
                                                            .thumbnail,
                                                        price: Viwerlist[index]
                                                            .price
                                                            .toString(),
                                                        saleprice: (Viwerlist[
                                                                        index]
                                                                    .price -
                                                                (Viwerlist[index]
                                                                        .price *
                                                                    (Viwerlist[index]
                                                                            .salePrice *
                                                                        0.01)))
                                                            .toString(),
                                                        productid:
                                                            Viwerlist[index].id,
                                                        productname:
                                                            Viwerlist[index]
                                                                .title,
                                                      )
                                                    ])).then(
                                                  (value) {
                                                    fevorites[index] = true;
                                                    cartitem();
                                                  },
                                                );
                                              } else {
                                                homecontoller.wishlist
                                                    .add(Wishitems(
                                                  brandname: Viwerlist[index]
                                                      .brand!
                                                      .name,
                                                  image: Viwerlist[index]
                                                      .thumbnail,
                                                  price: Viwerlist[index]
                                                      .price
                                                      .toString(),
                                                  saleprice: (Viwerlist[index]
                                                              .price -
                                                          (Viwerlist[index]
                                                                  .price *
                                                              (Viwerlist[index]
                                                                      .salePrice *
                                                                  0.01)))
                                                      .toString(),
                                                  productid:
                                                      Viwerlist[index].id,
                                                  productname:
                                                      Viwerlist[index].title,
                                                ));
                                                setState(() {});
                                                updatetowishlist(
                                                        FirebasewishlistModel(
                                                            userid:
                                                                homecontoller
                                                                    .userid,
                                                            wishlistid:
                                                                homecontoller
                                                                    .wishlistid,
                                                            wishitems:
                                                                homecontoller
                                                                    .wishlist))
                                                    .then(
                                                  (value) {
                                                    fevorites[index] = true;
                                                    cartitem();
                                                  },
                                                );
                                              }
                                            });
                                          } else {
                                            if (homecontoller.wishlistid ==
                                                    '' ||
                                                homecontoller
                                                    .wishlistid.isEmpty) {
                                              Addtowishlist(
                                                  FirebasewishlistModel(
                                                      userid:
                                                          homecontoller.userid,
                                                      wishitems: [
                                                    Wishitems(
                                                      brandname:
                                                          Viwerlist[index]
                                                              .brand!
                                                              .name,
                                                      image: Viwerlist[index]
                                                          .thumbnail,
                                                      price: Viwerlist[index]
                                                          .price
                                                          .toString(),
                                                      saleprice: (Viwerlist[
                                                                      index]
                                                                  .price -
                                                              (Viwerlist[index]
                                                                      .price *
                                                                  (Viwerlist[index]
                                                                          .salePrice *
                                                                      0.01)))
                                                          .toString(),
                                                      productid:
                                                          Viwerlist[index].id,
                                                      productname:
                                                          Viwerlist[index]
                                                              .title,
                                                    )
                                                  ])).then(
                                                (value) {
                                                  fevorites[index] = true;
                                                  setState(() {});
                                                  cartitem();
                                                },
                                              );
                                            } else {
                                              homecontoller.wishlist
                                                  .add(Wishitems(
                                                brandname: Viwerlist[index]
                                                    .brand!
                                                    .name,
                                                image:
                                                    Viwerlist[index].thumbnail,
                                                price: Viwerlist[index]
                                                    .price
                                                    .toString(),
                                                saleprice: (Viwerlist[index]
                                                            .price -
                                                        (Viwerlist[index]
                                                                .price *
                                                            (Viwerlist[index]
                                                                    .salePrice *
                                                                0.01)))
                                                    .toString(),
                                                productid: Viwerlist[index].id,
                                                productname:
                                                    Viwerlist[index].title,
                                              ));
                                              fevorites[index] = true;
                                              setState(() {});
                                              updatetowishlist(
                                                      FirebasewishlistModel(
                                                          userid: homecontoller
                                                              .userid,
                                                          wishlistid:
                                                              homecontoller
                                                                  .wishlistid,
                                                          wishitems:
                                                              homecontoller
                                                                  .wishlist))
                                                  .then(
                                                (value) {
                                                  cartitem();
                                                },
                                              );
                                            }
                                          }
                                        }
                                      },
                                      child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: fevorites[index]
                                              ? Icon(
                                                  Icons.favorite,
                                                  size: 30,
                                                )
                                              : Icon(
                                                  Icons.favorite_border,
                                                  size: 30,
                                                )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        fit: FlexFit.tight,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              Viwerlist[index].title,
                                              // replaceAll('RAJGARHWALA FURNITURE', '')
                                              maxLines: 1,
                                              style: TextStyle(
                                                  height: 1.2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: AppColor.BlackColor,
                                                  fontFamily: AppFont.lato,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              Viwerlist[index].brand == null
                                                  ? "Brand"
                                                  : Viwerlist[index]
                                                      .brand!
                                                      .name,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  color: AppColor.fontColorgrey,
                                                  fontFamily: AppFont.lato,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Viwerlist[index].salePrice == 0
                                              ? Container()
                                              : Container(
                                                  child: Text(
                                                    "₹ ${Viwerlist[index].price}.00",
                                                    style: TextStyle(
                                                        color: AppColor
                                                            .viewallcolor,
                                                        fontSize: 14,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                          Container(
                                            child: Text(
                                              // "₹ ${Viwerlist[index].salePrice}.00",
                                              "₹ ${(Viwerlist[index].price - (Viwerlist[index].price * (Viwerlist[index].salePrice * 0.01))).toStringAsFixed(0)}",
                                              style: TextStyle(
                                                  color: AppColor.BlackColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: AppColor.BlackColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    width: Responsive.isMobile(context)
                                        ? 200
                                        : 290,
                                    child: Center(
                                      child: Text(
                                        "View Details",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: AppColor.BgColor,
                                            fontFamily: AppFont.lato),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(top: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Future<void> updatetowishlist(FirebasewishlistModel wishlist) async {
  //   try {
  //     print('   :: ${wishlist.toJson()}');
  //     await firestore
  //         .collection("Wishlist")
  //         .doc(wishlist.wishlistid)
  //         .set(wishlist.toJson())
  //         .then(
  //       (value) {
  //         //  FirebaseFirestore.instance
  //         //   .collection('collection')
  //         //   .doc(userid)
  //         //   .update({'Cartid': });
  //       },
  //     );

  //     firestore
  //         .collection("Wishlist")
  //         .where("Userid", isEqualTo: homecontoller.userid)
  //         .get()
  //         .then(
  //       (value) {
  //         print("value = " + value.docs.first.id);
  //         print("userid = " + homecontoller.userid);
  //         firestore
  //             .collection('Wishlist')
  //             .doc(value.docs.first.id)
  //             .update({'Wishlistid': value.docs.first.id});
  //         FirebaseFirestore.instance
  //             .collection('Users')
  //             .doc(homecontoller.userid)
  //             .update({'Wishlistid': value.docs.first.id});
  //       },
  //     );
  //     print("homecontoller.wishlist :: ${homecontoller.wishlist}");
  //   } on FirebaseAuthException catch (e) {
  //     throw TFirebaseAuthException(e.code).message;
  //   } on FormatException catch (e) {
  //     print("error :: ${e}");
  //     throw const TFormatException();
  //   } on PlatformException catch (e) {
  //     print("error :: ${e}");
  //     throw TPlatformException(e.code).message;
  //   } catch (e) {
  //     print("error :: ${e}");
  //     throw 'Something went wrong. Please try again';
  //   }
  // }

  Future<void> updatetowishlist(FirebasewishlistModel wishlist) async {
    await UserDataApi.saveWishlist(wishlist.wishitems ?? []);
  }

  // Future cartitem() async {
  //   setState(() {});
  //   homecontoller.wishlist.clear();
  //   firestore
  //       .collection("Wishlist")
  //       .where("Userid", isEqualTo: homecontoller.userid)
  //       .get()
  //       .then(
  //     (value) {
  //       setState(() {
  //         data = value.docs.first.data();
  //       });
  //       print("SPcheck $data ");
  //       data['Wishlistitems'].forEach((v) {
  //         print('cart Cartitems :: ${v}');
  //         Wishitems data_cart = new Wishitems.fromJson(v);
  //         print('cart data_cart :: ${data_cart}');
  //         homecontoller.wishlist.add(data_cart);
  //       });
  //       if (data['Wishlistid'] == null ||
  //           data['Wishlistid'] == '' ||
  //           data['Wishlistid'] == "null") {
  //         homecontoller.wishlistid = '';
  //         print("SPcheck ONE ");
  //       } else {
  //         homecontoller.wishlistid = data['Wishlistid'];
  //         print("SPcheck TWO ");
  //       }
  //       print('homecontoller.wishlistid 123 ${homecontoller.wishlistid}');
  //       print("SPcheck THRee ${homecontoller.wishlistid}");

  //       setState(() {});
  //     },
  //   );
  //   // homecontoller.wishlist.asMap().forEach(
  //   //   (listindex, element) {
  //   //     if (element.productid == widget.productModel!.id) {
  //   //       fevorite = true;
  //   //     }
  //   //   },
  //   // );
  // }

  var fevdata;
  // Future cartitem() async {
  //   setState(() {});
  //   homecontoller.wishlist.clear();
  //   if (homecontoller.userid.isEmpty) {
  //     print("SPcheck ONE User Id Empty");
  //   } else {
  //     CommonWidget.UnverifyedUser = false;
  //     setState(() {});
  //     firestore
  //         .collection("Wishlist")
  //         .where("Userid", isEqualTo: homecontoller.userid)
  //         .get()
  //         .then(
  //       (value) {
  //         fevdata = value.docs.first.data();

  //         print("SPcheck $data ");
  //         fevdata['Wishlistitems'].forEach((v) {
  //           print('cart Cartitems :: ${v}');
  //           Wishitems data_cart = new Wishitems.fromJson(v);
  //           print('cart data_cart :: ${data_cart}');
  //           homecontoller.wishlist.add(data_cart);
  //         });
  //         if (fevdata['Wishlistid'] == null ||
  //             fevdata['Wishlistid'] == '' ||
  //             fevdata['Wishlistid'] == "null") {
  //           homecontoller.wishlistid = '';
  //           print("SPcheck ONE ");
  //         } else {
  //           homecontoller.wishlistid = fevdata['Wishlistid'];
  //           print("SPcheck TWO ");
  //         }
  //         print('homecontoller.wishlistid 123 ${homecontoller.wishlistid}');
  //         print("SPcheck THRee ${homecontoller.wishlistid}");

  //         setState(() {});
  //       },
  //     );
  //   }
  // }

  Future cartitem() async {
    setState(() {});
    homecontoller.wishlist.clear();
    if (homecontoller.userid.isEmpty) {
    } else {
      CommonWidget.UnverifyedUser = false;
      setState(() {});
      try {
        final items = await UserDataApi.getWishlist();
        homecontoller.wishlist.addAll(items);
        homecontoller.wishlistid =
            homecontoller.wishlist.isEmpty ? '' : homecontoller.userid;
      } catch (e) {
        homecontoller.wishlistid = '';
      }
      setState(() {});
    }
  }

  Future<void> removetowishlist(FirebasewishlistModel wishlist) async {
    await UserDataApi.saveWishlist(wishlist.wishitems ?? []);
  }

  Future<List<CategoryModel>> CategoryDataGet() async {
    try {
      final list = await ApiClient.instance.getList('/categories');
      return list.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // Future<void> Addtowishlist(FirebasewishlistModel wishlist) async {
  //   try {
  //     print(' dkjndjnjkdn  :: ${wishlist.toJson()}');
  //     await firestore.collection("Wishlist").doc().set(wishlist.toJson()).then(
  //           (value) {},
  //         );

  //     firestore
  //         .collection("Wishlist")
  //         .where("Userid", isEqualTo: homecontoller.userid)
  //         .get()
  //         .then(
  //       (value) {
  //         print("value = " + value.docs.first.id);
  //         print("userid = " + homecontoller.userid);
  //         firestore
  //             .collection('Wishlist')
  //             .doc(value.docs.first.id)
  //             .update({'Wishlistid': value.docs.first.id});
  //         FirebaseFirestore.instance
  //             .collection('Users')
  //             .doc(homecontoller.userid)
  //             .update({'Wishlistid': value.docs.first.id});
  //       },
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     throw TFirebaseAuthException(e.code).message;
  //   } on FormatException catch (e) {
  //     print("error :: ${e}");
  //     throw const TFormatException();
  //   } on PlatformException catch (e) {
  //     print("error :: ${e}");
  //     throw TPlatformException(e.code).message;
  //   } catch (e) {
  //     print("error :: ${e}");
  //     throw 'Something went wrong. Please try again';
  //   }
  // }

  Future<void> Addtowishlist(FirebasewishlistModel wishlist) async {
    await UserDataApi.saveWishlist(wishlist.wishitems ?? []);
  }

  whatsapp() async {
    String contact = "+91 9033806717";
    String text = '';
    String androidUrl = "whatsapp://send?phone=$contact&text=$text";
    String iosUrl = "https://wa.me/$contact?text=${Uri.parse(text)}";

    String webUrl = 'https://api.whatsapp.com/send/?phone=$contact&text=hi';

    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(Uri.parse(iosUrl))) {
          await launchUrl(Uri.parse(iosUrl));
        }
      } else {
        if (await canLaunchUrl(Uri.parse(androidUrl))) {
          await launchUrl(Uri.parse(androidUrl));
        }
      }
    } catch (e) {
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> launchFacebook(String fbUrl, String fbWebUrl) async {
    try {
      bool launched = await launchUrl(Uri.parse(fbWebUrl),
          mode: LaunchMode.externalApplication);

      if (!launched) {
        await launchUrl(Uri.parse(fbWebUrl),
            mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      await launchUrl(Uri.parse(fbWebUrl),
          mode: LaunchMode.externalApplication);
    }
  }
}

Future<void> launchInstagram(String fbUrl, String fbWebUrl) async {
  try {
    if (Platform.isIOS) {
      if (await canLaunchUrl(Uri.parse(fbUrl))) {
        await launchUrl(Uri.parse(fbUrl));
      }
    } else {
      if (await canLaunchUrl(Uri.parse(fbUrl))) {
        await launchUrl(Uri.parse(fbUrl));
      }
    }
  } catch (e) {
    await launchUrl(Uri.parse(fbWebUrl), mode: LaunchMode.externalApplication);
  }
  try {
    bool launched =
        await launchUrl(Uri.parse(fbUrl), mode: LaunchMode.externalApplication);

    if (!launched) {
      await launchUrl(Uri.parse(fbUrl), mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    await launchUrl(Uri.parse(fbUrl), mode: LaunchMode.externalApplication);
  }
}
