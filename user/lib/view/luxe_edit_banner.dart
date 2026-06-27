// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/luxeedit.dart';
import 'package:EcommerceApp/view/allproductspage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// The admin-managed "Luxe Edit" home section: a large background banner with
/// title / subtitle / Shop Now on the left and a 2×2 grid of editable tiles on
/// the right (stacked on mobile). Renders nothing until the admin activates it.
class LuxeEditBanner extends StatefulWidget {
  const LuxeEditBanner({super.key});

  @override
  State<LuxeEditBanner> createState() => _LuxeEditBannerState();
}

class _LuxeEditBannerState extends State<LuxeEditBanner> {
  LuxeEditModel? config;

  @override
  void initState() {
    _load();
    super.initState();
  }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.getOne('/luxeedit');
      if (data.isNotEmpty) {
        final m = LuxeEditModel.fromMap(data);
        if (mounted) setState(() => config = m);
      }
    } catch (_) {}
  }

  void _open(String link) {
    WebAPPNavigation.navigateToroute(
        context: context,
        routename: '/AllProducts',
        screen: AllProductsPage());
  }

  @override
  Widget build(BuildContext context) {
    final c = config;
    if (c == null || !c.active || !c.hasContent) return SizedBox();

    final bool isMobile =
        MediaQuery.of(context).size.width <= CommonWidget.headerWidth;
    // Near full-width: only ~10px gap on the left and right.
    const double sideGap = 10;

    return Container(
      margin: EdgeInsets.fromLTRB(sideGap, 30, sideGap, 30),
      child: isMobile
          ? Column(
              children: [
                _backgroundBanner(c, isMobile, height: 380),
                SizedBox(height: 14),
                _tilesPanel(c, isMobile),
              ],
            )
          : SizedBox(
              height: 760,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      flex: 5,
                      child: _backgroundBanner(c, isMobile, height: 760)),
                  SizedBox(width: 16),
                  Expanded(flex: 5, child: _tilesPanel(c, isMobile)),
                ],
              ),
            ),
    );
  }

  Widget _backgroundBanner(LuxeEditModel c, bool isMobile, {double? height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isMobile ? 16 : 22),
      child: SizedBox(
        height: height ?? 470,
        child: Stack(
          fit: StackFit.expand,
          children: [
            c.backgroundImage.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: c.backgroundImage,
                    fit: BoxFit.cover,
                    placeholder: (ctx, u) => Container(color: AppColor.blush),
                    errorWidget: (ctx, u, e) =>
                        Container(color: AppColor.blush),
                  )
                : Container(
                    decoration:
                        BoxDecoration(gradient: AppColor.roseGradient)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.80),
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 18 : 34),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (c.title.isNotEmpty)
                      Text(
                        c.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFont.heading,
                            color: Colors.white,
                            height: 1.05,
                            fontWeight: FontWeight.w700,
                            fontSize: isMobile ? 30 : 56),
                      ),
                    if (c.subtitle.isNotEmpty) ...[
                      SizedBox(height: 10),
                      ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: isMobile ? 260 : 380),
                        child: Text(
                          c.subtitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              height: 1.35,
                              fontSize: isMobile ? 13 : 16),
                        ),
                      ),
                    ],
                    if (c.buttonText.isNotEmpty) ...[
                      SizedBox(height: 18),
                      PressableScale(
                        onTap: () => _open(c.buttonLink),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 22, vertical: isMobile ? 11 : 14),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(100)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(c.buttonText,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isMobile ? 13 : 15)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: isMobile ? 16 : 19),
                          ]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tilesPanel(LuxeEditModel c, bool isMobile) {
    final tiles = c.visibleTiles;
    if (tiles.isEmpty) return SizedBox();

    // Mobile: simple shrink-wrapped 2-column grid (parent height is unbounded).
    if (isMobile) {
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: tiles.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, i) => _tile(tiles[i], isMobile),
      );
    }

    // Desktop: fill the banner height exactly with rows of two (Expanded rows
    // => equal heights, no overflow).
    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += 2) {
      rows.add(Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _tile(tiles[i], isMobile)),
            SizedBox(width: 16),
            Expanded(
              child: i + 1 < tiles.length
                  ? _tile(tiles[i + 1], isMobile)
                  : SizedBox(),
            ),
          ],
        ),
      ));
      if (i + 2 < tiles.length) rows.add(SizedBox(height: 16));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  Widget _tile(LuxeTile t, bool isMobile) {
    return PressableScale(
      onTap: () => _open(t.link),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                color: AppColor.blush,
                child: CachedNetworkImage(
                  imageUrl: t.image,
                  fit: BoxFit.cover,
                  placeholder: (ctx, u) => Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColor.primary)),
                  errorWidget: (ctx, u, e) => Center(
                      child: Icon(Icons.checkroom_outlined,
                          color: AppColor.primary)),
                ),
              ),
            ),
          ),
          if (t.label.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              t.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: AppColor.ink,
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}
