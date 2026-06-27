// ignore_for_file: prefer_const_constructors


import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────
///  THEME:  "Bloom"  —  a women's fashion palette.
///  Dusty rose on a clean white canvas, with warm plum-ink text.
///  All historical field names are preserved so every screen keeps working;
///  only the values changed + a few brand tokens were added.
/// ─────────────────────────────────────────────────────────────────────────
class AppColor {
  // Core surfaces ----------------------------------------------------------
  static Color BgColor = Color(0xffFFFFFF);
  static Color whiteColor = Color(0xffFFFFFF);
  static Color cream = Color(0xffFCF7F9); // soft rose-tinted page background

  // Text / ink -------------------------------------------------------------
  // NOTE: "BlackColor" is used app-wide for text, buttons, icons & the footer.
  // It is now a warm plum-ink (not pure black) so the whole UI feels softer.
  static Color BlackColor = Color(0xff2A1E26);
  static Color fontblack = Color(0xff2A1E26);
  static Color ink = Color(0xff2A1E26);
  static Color fontColorgrey = Color(0xff8B8089);

  // Brand accent (berry rose) ---------------------------------------------
  static Color primary = Color(0xffC04A66);
  static Color primaryDark = Color(0xffA23A54);
  static Color accent = Color(0xffD98BA0);
  static Color blush = Color(0xffFBEFF3); // soft chip / surface tint
  static Color blushDeep = Color(0xffF6E0E8);
  static Color gold = Color(0xffC9A24B);

  // "View All" / highlight accent (was orange, now rose) -------------------
  static Color viewallcolor = Color(0xffC04A66);

  // Buttons — primary CTA colour (rose). Name kept for backward-compat.
  static Color btnColorblack = Color(0xffC04A66);

  // Misc / state -----------------------------------------------------------
  static Color imagebg = Color(0xffFBF1F4); // blush image placeholder
  static Color setctintroindicator = Color(0xffC04A66);
  static Color unsetctintroindicator = Color(0xffEAD7DD);
  static Color redcolor = Color(0xffD14D5E);
  static Color activeusercolor = Color(0xff46C45D);
  static Color slidercolor = Color(0xffC04A66);
  static Color starcolor = Color(0xffEAC92C);
  static Color processbarcolor = Color(0xffC04A66);
  static Color lightbluecolor = Color(0xff179BD7);
  static Color dividercolor = Color(0xffEFE3E8);
  static Color bluecolor = Color(0xff253B80);
  // Neutral hover/highlight (no pink) for menus & subtle states.
  static Color hoverGrey = Color(0xffF4F3F5);

  // Brand gradient ---------------------------------------------------------
  static LinearGradient roseGradient = LinearGradient(
    colors: const [Color(0xffF6E0E8), Color(0xffFBF1F4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient ctaGradient = LinearGradient(
    colors: const [Color(0xffC04A66), Color(0xffA23A54)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppFont {
  // Body / UI font — modern variable grotesque (bundled, offline).
  static String switzer = "Switzer";
  // Historically "lato"; many screens reference this for body text.
  // Re-pointed to Switzer so typography is consistent everywhere.
  static String lato = "Switzer";
  // Elegant serif used for headings / editorial titles.
  static String heading = "PlayfairDisplay";
  static String serif = "PlayfairDisplay";
}

class AppImage {
  static String appIcon = "assets/image/";
  static String appmodel = "assets/semple/";
}

class Appshadow {
  // Kept name `shadow` for backward-compat; softened to a warm rose shadow.
  static BoxShadow shadow = BoxShadow(
    blurRadius: 18,
    color: Color(0xff2A1E26).withValues(alpha: 0.06),
    offset: Offset(0, 8),
    spreadRadius: 0,
  );

  // A lighter elevation for cards.
  static BoxShadow card = BoxShadow(
    blurRadius: 24,
    color: Color(0xffC04A66).withValues(alpha: 0.08),
    offset: Offset(0, 10),
    spreadRadius: 0,
  );

  static List<BoxShadow> soft = [
    BoxShadow(
      blurRadius: 14,
      color: Color(0xff2A1E26).withValues(alpha: 0.05),
      offset: Offset(0, 6),
    ),
  ];
}

class Appborder {
  // Subtle blush hairline border instead of harsh black26.
  static Border appborder = Border.all(color: Color(0xffEFE3E8), width: 1);
}

class AppRadius {
  static BorderRadius sm = BorderRadius.circular(10);
  static BorderRadius md = BorderRadius.circular(16);
  static BorderRadius lg = BorderRadius.circular(22);
  static BorderRadius pill = BorderRadius.circular(100);
}

/// Global Material theme for the storefront.
/// Body/UI text uses Switzer; headlines & display text use Playfair Display.
class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppFont.switzer,
      scaffoldBackgroundColor: AppColor.BgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColor.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColor.primary,
        onPrimary: AppColor.whiteColor,
        surface: AppColor.BgColor,
        onSurface: AppColor.ink,
        secondary: AppColor.accent,
      ),
    );

    return base.copyWith(
      primaryColor: AppColor.primary,
      dividerColor: AppColor.dividercolor,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColor.BgColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColor.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppFont.heading,
          color: AppColor.ink,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColor.ink),
      ),
      textTheme: _textTheme(base.textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.whiteColor,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
          textStyle: TextStyle(
            fontFamily: AppFont.switzer,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.ink,
          side: BorderSide(color: AppColor.dividercolor),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColor.primary),
      ),
      iconTheme: IconThemeData(color: AppColor.ink),
      progressIndicatorTheme:
          ProgressIndicatorThemeData(color: AppColor.primary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.blush,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: AppColor.fontColorgrey),
        border: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: BorderSide(color: AppColor.primary, width: 1.4),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColor.blush,
        labelStyle: TextStyle(color: AppColor.ink),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
      ),
      // Dropdown / submenu panels (e.g. the Categories mega-menu)
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppColor.whiteColor),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(8),
          shadowColor: WidgetStatePropertyAll(AppColor.ink.withValues(alpha: 0.16)),
          padding:
              const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 8)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColor.dividercolor),
          )),
        ),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(AppColor.whiteColor),
          overlayColor: WidgetStatePropertyAll(AppColor.hoverGrey),
          foregroundColor: WidgetStatePropertyAll(AppColor.ink),
          textStyle: WidgetStatePropertyAll(TextStyle(
              fontFamily: AppFont.switzer,
              fontSize: 15,
              fontWeight: FontWeight.w500)),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 18, vertical: 4)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9))),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    TextStyle serif(TextStyle? s) =>
        (s ?? TextStyle()).copyWith(fontFamily: AppFont.heading, color: AppColor.ink);
    TextStyle sans(TextStyle? s) =>
        (s ?? TextStyle()).copyWith(fontFamily: AppFont.switzer, color: AppColor.ink);
    return base.copyWith(
      displayLarge: serif(base.displayLarge),
      displayMedium: serif(base.displayMedium),
      displaySmall: serif(base.displaySmall),
      headlineLarge: serif(base.headlineLarge),
      headlineMedium: serif(base.headlineMedium),
      headlineSmall: serif(base.headlineSmall),
      titleLarge: serif(base.titleLarge),
      titleMedium: sans(base.titleMedium),
      titleSmall: sans(base.titleSmall),
      bodyLarge: sans(base.bodyLarge),
      bodyMedium: sans(base.bodyMedium),
      bodySmall: sans(base.bodySmall),
      labelLarge: sans(base.labelLarge),
      labelMedium: sans(base.labelMedium),
      labelSmall: sans(base.labelSmall),
    );
  }
}

/// Wrap any tappable container to give it a smooth, springy press transition
/// and a pointer cursor on web. Use instead of a bare InkWell/GestureDetector
/// for primary buttons (Add to Cart, Buy Now, Subscribe, wishlist, etc.).
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final double hoverScale;
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.95,
    this.hoverScale = 1.03,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;
  bool _hover = false;
  void _setDown(bool v) {
    if (mounted) setState(() => _down = v);
  }

  void _setHover(bool v) {
    if (mounted) setState(() => _hover = v);
  }

  @override
  Widget build(BuildContext context) {
    final double targetScale =
        _down ? widget.scale : (_hover ? widget.hoverScale : 1.0);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setDown(true),
        onTapUp: (_) => _setDown(false),
        onTapCancel: () => _setDown(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: targetScale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _down ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 130),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Hover-lift wrapper for cards: smoothly scales up + raises a soft shadow
/// when the mouse hovers (web), and presses down slightly on tap.
class HoverLift extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  const HoverLift({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(18);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _down = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.98 : (_hover ? 1.03 : 1.0),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: _hover
                  ? [
                      BoxShadow(
                        color: AppColor.primary.withValues(alpha: 0.18),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      )
                    ]
                  : [],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Lightweight, on-brand toast for useful events (added to bag, wishlist,
/// subscribed, profile updated, etc.). Uses the floating SnackBar so it works
/// from any page that has a Scaffold.
class AppToast {
  static void show(
    BuildContext context,
    String message, {
    bool success = true,
    IconData? icon,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: AppColor.ink,
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        duration: const Duration(milliseconds: 2200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ??
                  (success ? Icons.check_circle_rounded : Icons.info_outline),
              color: success ? AppColor.accent : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class Baseurl {
//   static String baseurl = "https://13bfe0-14.myshopify.com/admin/api/";
// }
