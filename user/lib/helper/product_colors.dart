import 'package:EcommerceApp/model/productmodel.dart';
import 'package:flutter/material.dart';

/// Extracts the colour values an admin set on a product (ProductAttributes
/// whose name contains "colo" — e.g. "Colors"/"Colour") into real [Color]s.
List<Color> productColors(ProductModel p) {
  final out = <Color>[];
  for (final a in (p.productAttributes ?? [])) {
    final name = (a.name ?? '').toLowerCase();
    if (name.contains('colo')) {
      for (final v in (a.values ?? [])) {
        final c = parseProductColor(v.toString());
        if (c != null) out.add(c);
      }
    }
  }
  return out;
}

/// Parses a stored colour value: hex (#rrggbb), 0x / plain int (ARGB), or a few
/// common colour names.
Color? parseProductColor(String value) {
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

/// A compact row of colour dots for a product card. Returns an empty box when
/// the product has no colours, so it can be dropped into any card safely.
Widget productColorSwatches(ProductModel p, {double size = 13, int max = 5}) {
  final colors = productColors(p);
  if (colors.isEmpty) return const SizedBox.shrink();
  final show = colors.take(max).toList();
  return Padding(
    padding: const EdgeInsets.only(top: 7),
    child: Row(
      children: [
        for (final c in show)
          Container(
            margin: const EdgeInsets.only(right: 6),
            height: size,
            width: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c,
              border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
            ),
          ),
        if (colors.length > max)
          Text("+${colors.length - max}",
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    ),
  );
}
