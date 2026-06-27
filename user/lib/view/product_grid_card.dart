import 'package:EcommerceApp/helper/product_colors.dart';
import 'package:EcommerceApp/helper/tryon_nav.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/productmodel.dart';
import 'package:EcommerceApp/view/product_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Shared product card used across Shop All / Search / Favourites so every
/// listing looks identical: full-width cover image, brand, title, price — the
/// whole card is tappable (no separate "View Details" button). Opens the
/// product by its **id** in the URL.
class ProductGridCard extends StatelessWidget {
  const ProductGridCard({
    super.key,
    required this.product,
    required this.index,
    required this.list,
  });

  final ProductModel product;
  final int index;
  final List<ProductModel> list;

  @override
  Widget build(BuildContext context) {
    final p = product;
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
              child: Stack(
                children: [
                  Positioned.fill(
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
                  if (p.aiTryOnEnabled != false)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: PressableScale(
                        onTap: () => openTryOn(context, p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor.withValues(alpha: 0.94),
                            borderRadius: AppRadius.pill,
                            boxShadow: Appshadow.soft,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome,
                                  size: 13, color: AppColor.primary),
                              const SizedBox(width: 4),
                              Text(
                                'Try on',
                                style: TextStyle(
                                    color: AppColor.primaryDark,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
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
                  const SizedBox(height: 3),
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
                  const SizedBox(height: 8),
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
                            style: const TextStyle(
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
