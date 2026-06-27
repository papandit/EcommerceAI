// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, must_be_immutable, sized_box_for_whitespace

import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/product_colors.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/productmodel.dart';
import 'package:EcommerceApp/view/product_detail_page.dart';
import 'package:EcommerceApp/view/product_filter_view.dart';
import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class AllProductsPage extends StatefulWidget {
  AllProductsPage({super.key, this.heading});
  String? heading;
  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  bool loading = true;
  List<ProductModel> all = [];

  @override
  void initState() {
    _fetch();
    super.initState();
  }

  Future<void> _fetch() async {
    try {
      final data = await ApiClient.instance.getList('/products');
      all = data.map((d) => ProductModel.fromJson(d)).toList();
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool wide =
        MediaQuery.of(context).size.width > CommonWidget.headerWidth;

    if (loading) {
      return Scaffold(
        backgroundColor: AppColor.BgColor,
        appBar:
            wide ? null : CommonWidget().Header(context: context, heart: false),
        body:
            Center(child: CircularProgressIndicator(color: AppColor.primary)),
      );
    }

    final listing = ProductFilterView(
      products: all,
      cardBuilder: (p, index, filtered) => _productCard(p, index, filtered),
    );

    if (wide) {
      return Scaffold(
        backgroundColor: AppColor.BgColor,
        body: SingleChildScrollView(
          child: StickyHeader(
            header: CommonWidget().StickyHeaders(context, Refresh: setState),
            content: Column(
              children: [
                _hero(),
                listing,
                CommonWidget().Footer(context),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.BgColor,
      appBar: CommonWidget().Header(context: context, heart: false),
      endDrawer: CommonWidget().Drowers(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _hero(),
            listing,
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: AppColor.roseGradient),
          padding: EdgeInsets.symmetric(vertical: 38, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("SHOP THE EDIT",
                  style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 2,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w700)),
              SizedBox(height: 10),
              Text(widget.heading ?? "All Products",
                  style: TextStyle(
                      fontFamily: AppFont.heading,
                      fontSize: 34,
                      color: AppColor.ink,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 6),
              Text("${all.length} pieces to browse",
                  style:
                      TextStyle(fontSize: 14, color: AppColor.fontColorgrey)),
            ],
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: CommonWidget().heroBackArrow(context),
        ),
      ],
    );
  }

  Widget _productCard(ProductModel p, int index, List<ProductModel> list) {
    final offer = (p.price - (p.price * (p.salePrice * 0.01))).toDouble();
    return HoverLift(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        WebAPPNavigation.navigateToroute(
          context: context,
          routename: '/ProductDetailScreen/${p.id}',
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
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(14),
          border: Appborder.appborder,
          boxShadow: Appshadow.soft,
        ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        height: 1.25,
                        color: AppColor.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Text("₹${offer.toStringAsFixed(0)}",
                          style: TextStyle(
                              color: AppColor.ink,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700)),
                      if (p.salePrice != 0)
                        Text("₹${p.price}",
                            style: TextStyle(
                                color: AppColor.fontColorgrey,
                                fontSize: 11.5,
                                decoration: TextDecoration.lineThrough)),
                      if (p.salePrice != 0)
                        Text("(${p.salePrice.toStringAsFixed(0)}% OFF)",
                            style: TextStyle(
                                color: Color(0xff2E8B57),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700)),
                    ],
                  ),
                  productColorSwatches(p),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
