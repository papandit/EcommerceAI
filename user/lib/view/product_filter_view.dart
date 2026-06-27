// ignore_for_file: prefer_const_constructors, must_be_immutable, prefer_const_literals_to_create_immutables

import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/model/productmodel.dart';
import 'package:flutter/material.dart';

/// A reusable Nykaa/AJIO-style listing experience: a left filter sidebar on
/// web (Category, Brand, Colour, Size, Price, Discount + any extra product
/// attributes the admin defines) and a dedicated filter bottom-sheet on mobile,
/// with a 4-up (web) / 2-up (mobile) product grid and sort.
///
/// The actual product CARD is supplied by the host page via [cardBuilder] so
/// each page keeps its own card design unchanged.
class ProductFilterView extends StatefulWidget {
  const ProductFilterView({
    super.key,
    required this.products,
    required this.cardBuilder,
    this.childAspectRatio = 0.60,
    this.onChanged,
  });

  /// Full source list to filter from.
  final List<ProductModel> products;

  /// Builds a card for a product. Receives the product, its index in the
  /// currently-filtered list, and that filtered list (for detail navigation).
  final Widget Function(
      ProductModel product, int index, List<ProductModel> filtered) cardBuilder;

  final double childAspectRatio;

  /// Optional: notified with the filtered list whenever filters change.
  final void Function(List<ProductModel> filtered)? onChanged;

  @override
  State<ProductFilterView> createState() => _ProductFilterViewState();
}

class _ProductFilterViewState extends State<ProductFilterView> {
  List<ProductModel> filtered = [];

  // Option sets (built from the data => admin-managed).
  final Map<String, String> categories = {}; // id -> name
  List<String> brands = [];
  List<int> discountBuckets = [];
  // Generic attribute options: name -> sorted distinct values (Size, Colour,
  // Material, Occasion, Fit, Pattern, … whatever the admin stored).
  final Map<String, List<String>> attrOptions = {};
  double minPrice = 0;
  double maxPrice = 100000;

  // Selections.
  final Set<String> selCats = {};
  final Set<String> selBrands = {};
  final Set<int> selDiscounts = {};
  final Map<String, Set<String>> selAttrs = {};
  RangeValues priceRange = const RangeValues(0, 100000);
  String sortBy = "Relevance";

  static const List<String> _sortOptions = [
    "Relevance",
    "Price: Low to High",
    "Price: High to Low",
    "Discount",
    "A - Z",
  ];

  @override
  void initState() {
    _buildOptions();
    _apply();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ProductFilterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products != widget.products) {
      _buildOptions();
      _apply();
    }
  }

  double _offer(ProductModel p) =>
      (p.price - (p.price * (p.salePrice * 0.01))).toDouble();

  void _buildOptions() {
    categories.clear();
    attrOptions.clear();
    final brandSet = <String>{};
    final attrSets = <String, Set<String>>{};
    final catIds = <String>{};
    final discounts = <int>{};
    double mx = 0;

    for (final p in widget.products) {
      final b = p.brand?.name;
      if (b != null && b.trim().isNotEmpty) brandSet.add(b);
      if ((p.categoryId ?? '').isNotEmpty) catIds.add(p.categoryId!);
      if (p.price.toDouble() > mx) mx = p.price.toDouble();

      // Discount buckets.
      final d = p.salePrice;
      for (final t in const [10, 20, 30, 40, 50]) {
        if (d >= t) discounts.add(t);
      }

      // Generic attributes.
      for (final a in (p.productAttributes ?? [])) {
        final name = (a.name ?? '').trim();
        if (name.isEmpty) continue;
        attrSets.putIfAbsent(name, () => <String>{});
        for (final v in (a.values ?? [])) {
          final vs = v.toString().trim();
          if (vs.isNotEmpty) attrSets[name]!.add(vs);
        }
      }
    }

    brands = brandSet.toList()..sort();
    discountBuckets = discounts.toList()..sort();

    // Category names from the global category list (admin-managed).
    for (final c in CommonWidget.categorylist) {
      if (catIds.contains(c.id)) categories[c.id] = c.name;
    }

    attrSets.forEach((k, v) {
      final list = v.toList()..sort();
      if (list.isNotEmpty) attrOptions[k] = list;
    });

    maxPrice = mx <= 0 ? 100000 : mx.ceilToDouble();
    minPrice = 0;
    priceRange = RangeValues(0, maxPrice);
  }

  List<String> _attrValues(ProductModel p, String name) {
    final out = <String>[];
    for (final a in (p.productAttributes ?? [])) {
      // Trim both sides so the option built in _buildOptions() (which trims)
      // matches the product's stored value here (which may have stray spaces).
      if ((a.name ?? '').trim() == name) {
        out.addAll((a.values ?? []).map((e) => e.toString().trim()));
      }
    }
    return out;
  }

  void _apply() {
    final list = widget.products.where((p) {
      final offer = _offer(p);
      if (selCats.isNotEmpty && !selCats.contains(p.categoryId)) return false;
      if (selBrands.isNotEmpty && !selBrands.contains(p.brand?.name)) {
        return false;
      }
      if (offer < priceRange.start || offer > priceRange.end) return false;
      if (selDiscounts.isNotEmpty) {
        final minSel = selDiscounts.reduce((a, b) => a < b ? a : b);
        if (p.salePrice < minSel) return false;
      }
      for (final entry in selAttrs.entries) {
        if (entry.value.isEmpty) continue;
        final pv = _attrValues(p, entry.key);
        if (!entry.value.any((s) => pv.contains(s))) return false;
      }
      return true;
    }).toList();

    switch (sortBy) {
      case "Price: Low to High":
        list.sort((a, b) => _offer(a).compareTo(_offer(b)));
        break;
      case "Price: High to Low":
        list.sort((a, b) => _offer(b).compareTo(_offer(a)));
        break;
      case "Discount":
        list.sort((a, b) => b.salePrice.compareTo(a.salePrice));
        break;
      case "A - Z":
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    filtered = list;
    widget.onChanged?.call(filtered);
    if (mounted) setState(() {});
  }

  void _reset() {
    selCats.clear();
    selBrands.clear();
    selDiscounts.clear();
    selAttrs.clear();
    priceRange = RangeValues(0, maxPrice);
    sortBy = "Relevance";
    _apply();
  }

  bool get _hasActiveFilters =>
      selCats.isNotEmpty ||
      selBrands.isNotEmpty ||
      selDiscounts.isNotEmpty ||
      selAttrs.values.any((s) => s.isNotEmpty) ||
      priceRange.start > 0 ||
      priceRange.end < maxPrice;

  @override
  Widget build(BuildContext context) {
    final bool wide =
        MediaQuery.of(context).size.width > CommonWidget.headerWidth;

    if (wide) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 280, child: _sidebar(scroll: false)),
            SizedBox(width: 28),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(),
                  SizedBox(height: 12),
                  _grid(wide),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile / narrow
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${filtered.length} items",
                  style: TextStyle(
                      color: AppColor.fontColorgrey,
                      fontWeight: FontWeight.w600)),
              PressableScale(
                onTap: _openFilterSheet,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                      color: _hasActiveFilters
                          ? AppColor.primary
                          : AppColor.blush,
                      borderRadius: BorderRadius.circular(100)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.tune_rounded,
                        size: 18,
                        color: _hasActiveFilters
                            ? Colors.white
                            : AppColor.ink),
                    SizedBox(width: 8),
                    Text("Filter & Sort",
                        style: TextStyle(
                            color: _hasActiveFilters
                                ? Colors.white
                                : AppColor.ink,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ],
          ),
        ),
        _grid(wide),
      ],
    );
  }

  // ───────────────────────────── Top bar (web) ────────────────────────────
  Widget _topBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColor.dividercolor))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${filtered.length} Items Found",
              style: TextStyle(
                  color: AppColor.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          Row(
            children: [
              Text("SORT BY  ",
                  style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.5,
                      color: AppColor.fontColorgrey,
                      fontWeight: FontWeight.w600)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    color: AppColor.blush,
                    borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: sortBy,
                    borderRadius: BorderRadius.circular(12),
                    style: TextStyle(
                        color: AppColor.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    items: _sortOptions
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      sortBy = v ?? "Relevance";
                      _apply();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────── Sidebar ──────────────────────────────────
  Widget _sidebar({bool scroll = false}) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Filters",
                style: TextStyle(
                    fontFamily: AppFont.heading,
                    fontSize: 20,
                    color: AppColor.ink,
                    fontWeight: FontWeight.w600)),
            PressableScale(
              onTap: _reset,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.refresh_rounded, size: 15, color: AppColor.primary),
                SizedBox(width: 4),
                Text("Reset",
                    style: TextStyle(
                        color: AppColor.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ]),
            ),
          ],
        ),
        SizedBox(height: 4),
        if (categories.length > 1)
          _section(
            "Category",
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categories.entries
                  .map((e) => _checkRow(e.value, selCats.contains(e.key), () {
                        selCats.contains(e.key)
                            ? selCats.remove(e.key)
                            : selCats.add(e.key);
                        _apply();
                      }))
                  .toList(),
            ),
          ),
        _section("Price", _priceFilter()),
        if (discountBuckets.isNotEmpty)
          _section(
            "Discount",
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: discountBuckets
                  .map((t) =>
                      _checkRow("$t% and above", selDiscounts.contains(t), () {
                        selDiscounts.contains(t)
                            ? selDiscounts.remove(t)
                            : selDiscounts.add(t);
                        _apply();
                      }))
                  .toList(),
            ),
          ),
        if (brands.isNotEmpty)
          _section(
            "Brand",
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: brands
                  .map((b) => _checkRow(b, selBrands.contains(b), () {
                        selBrands.contains(b)
                            ? selBrands.remove(b)
                            : selBrands.add(b);
                        _apply();
                      }))
                  .toList(),
            ),
          ),
        // Dynamic attribute sections (Size, Colour, Material, Occasion, …).
        ...attrOptions.entries.map((e) => _attrSection(e.key, e.value)),
      ],
    );

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(18),
        border: Appborder.appborder,
        boxShadow: Appshadow.soft,
      ),
      child: scroll
          ? SingleChildScrollView(child: content)
          : content,
    );
  }

  Widget _attrSection(String name, List<String> values) {
    final low = name.toLowerCase();
    final isColor = low.contains('colo'); // colour / color / colors
    final isSize = low.contains('size');
    selAttrs.putIfAbsent(name, () => <String>{});
    final sel = selAttrs[name]!;

    if (isColor) {
      return _section(
        name,
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: values.map((v) {
            final c = _parseColor(v);
            final picked = sel.contains(v);
            return PressableScale(
              onTap: () {
                picked ? sel.remove(v) : sel.add(v);
                _apply();
              },
              child: Container(
                height: 30,
                width: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c ?? AppColor.blush,
                  border: Border.all(
                      color: picked ? AppColor.ink : AppColor.dividercolor,
                      width: picked ? 2 : 1),
                ),
                child: picked
                    ? Icon(Icons.check,
                        size: 15,
                        color: (c == null)
                            ? AppColor.ink
                            : ((c.computeLuminance() > 0.6)
                                ? Colors.black
                                : Colors.white))
                    : (c == null
                        ? Text(
                            v.isNotEmpty ? v[0].toUpperCase() : '?',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColor.ink,
                                fontWeight: FontWeight.w600),
                          )
                        : null),
              ),
            );
          }).toList(),
        ),
      );
    }

    if (isSize) {
      return _section(
        name,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((s) {
            final picked = sel.contains(s);
            return PressableScale(
              onTap: () {
                picked ? sel.remove(s) : sel.add(s);
                _apply();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: picked ? AppColor.ink : AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: picked ? AppColor.ink : AppColor.dividercolor),
                ),
                child: Text(s,
                    style: TextStyle(
                        color: picked ? AppColor.whiteColor : AppColor.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),
      );
    }

    // Generic checkbox list (Material, Occasion, Fit, Pattern, …).
    return _section(
      name,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: values
            .map((v) => _checkRow(v, sel.contains(v), () {
                  sel.contains(v) ? sel.remove(v) : sel.add(v);
                  _apply();
                }))
            .toList(),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.only(bottom: 12),
        title: Text(title,
            style: TextStyle(
                color: AppColor.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        iconColor: AppColor.primary,
        collapsedIconColor: AppColor.ink,
        children: [Align(alignment: Alignment.centerLeft, child: child)],
      ),
    );
  }

  Widget _checkRow(String label, bool checked, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(
              height: 18,
              width: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: checked ? AppColor.primary : AppColor.whiteColor,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    color: checked ? AppColor.primary : AppColor.fontColorgrey),
              ),
              child: checked
                  ? Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColor.ink,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("₹${priceRange.start.round()}",
                style: TextStyle(
                    color: AppColor.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            Text("₹${priceRange.end.round()}",
                style: TextStyle(
                    color: AppColor.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColor.primary,
            inactiveTrackColor: AppColor.blush,
            thumbColor: AppColor.primary,
            overlayColor: AppColor.primary.withValues(alpha: 0.12),
            rangeThumbShape: RoundRangeSliderThumbShape(enabledThumbRadius: 9),
            trackHeight: 4,
          ),
          child: RangeSlider(
            min: 0,
            max: maxPrice,
            values: RangeValues(
                priceRange.start.clamp(0, maxPrice).toDouble(),
                priceRange.end.clamp(0, maxPrice).toDouble()),
            onChanged: (v) => setState(() => priceRange = v),
            onChangeEnd: (v) => _apply(),
          ),
        ),
      ],
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.BgColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (ctx, controller) => Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 14, 12, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Filter & Sort",
                          style: TextStyle(
                              fontFamily: AppFont.heading,
                              fontSize: 22,
                              color: AppColor.ink,
                              fontWeight: FontWeight.w600)),
                      IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: Icon(Icons.close_rounded, color: AppColor.ink)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Listener(
                      // Rebuild the sheet after every tap so the selection
                      // checkboxes / chips reflect the new state immediately.
                      onPointerUp: (_) => WidgetsBinding.instance
                          .addPostFrameCallback((_) => setSheet(() {})),
                      child: _sidebar(scroll: false),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: PressableScale(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          gradient: AppColor.ctaGradient,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text("Show ${filtered.length} results",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────────── Grid ─────────────────────────────────────
  Widget _grid(bool wide) {
    if (filtered.isEmpty) {
      return Container(
        height: 320,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 84,
              width: 84,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(color: AppColor.blush, shape: BoxShape.circle),
              child: Icon(Icons.search_off_rounded,
                  size: 38, color: AppColor.primary),
            ),
            SizedBox(height: 16),
            Text("No products match your filters",
                style: TextStyle(
                    fontFamily: AppFont.heading,
                    fontSize: 20,
                    color: AppColor.ink,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            PressableScale(
                onTap: _reset,
                child: Text("Clear filters",
                    style: TextStyle(
                        color: AppColor.primary,
                        fontWeight: FontWeight.w600))),
          ],
        ),
      );
    }

    // 4 products per row on web, 2 on mobile (per request).
    final int cols = wide ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: wide ? 18 : 12,
        mainAxisSpacing: 20,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) =>
          widget.cardBuilder(filtered[index], index, filtered),
    );
  }

  // Parse a stored colour value (hex, 0x int, plain int, or a few names).
  Color? _parseColor(String value) {
    var s = value.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('#')) s = s.substring(1);
    final hex = s.startsWith('0x') || s.startsWith('0X') ? s.substring(2) : s;
    if (RegExp(r'^[0-9a-fA-F]{6,8}$').hasMatch(hex)) {
      var h = hex;
      if (h.length == 6) h = 'ff$h';
      final v = int.tryParse(h, radix: 16);
      if (v != null) return Color(v);
    }
    final asInt = int.tryParse(s);
    if (asInt != null) {
      // Treat as ARGB; if no alpha bits, force opaque.
      return Color(asInt < 0x01000000 ? (0xff000000 | asInt) : asInt);
    }
    const named = <String, Color>{
      'black': Colors.black,
      'white': Colors.white,
      'red': Colors.red,
      'pink': Colors.pink,
      'purple': Colors.purple,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'brown': Colors.brown,
      'grey': Colors.grey,
      'gray': Colors.grey,
      'beige': Color(0xffF5F5DC),
      'maroon': Color(0xff800000),
      'navy': Color(0xff000080),
      'gold': Color(0xffD4AF37),
      'cream': Color(0xffFFFDD0),
    };
    return named[s.toLowerCase()];
  }
}
