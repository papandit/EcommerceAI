// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'utillity.dart';

/// Two-panel auth layout (login / register / forgot) matching the
/// "E-commerce login pages" design: a berry-rose brand panel on the left
/// (wide screens only) and a centered form panel on the right. On mobile the
/// brand panel is hidden and only the form shows.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.child,
    this.maxFormWidth = 400,
    this.leading,
  });

  /// The form content (headings + fields + buttons).
  final Widget child;
  final double maxFormWidth;

  /// Optional top-left widget on the form panel (e.g. a mobile back button).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width >= 900;

    final form = Container(
      color: AppColor.cream,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxFormWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (leading != null)
                Align(alignment: Alignment.centerLeft, child: leading!),
              child,
            ],
          ),
        ),
      ),
    );

    if (!wide) return SafeArea(child: form);

    return Row(
      children: [
        const Expanded(flex: 46, child: AuthBrandPanel()),
        Expanded(flex: 54, child: form),
      ],
    );
  }
}

/// Left brand panel — gradient background, floating shopping-bag illustration,
/// an editorial headline and feature chips.
class AuthBrandPanel extends StatefulWidget {
  const AuthBrandPanel({super.key});

  @override
  State<AuthBrandPanel> createState() => _AuthBrandPanelState();
}

class _AuthBrandPanelState extends State<AuthBrandPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  Timer? _timer;
  int _slide = 0;

  // Rotating brand slides — each has its own headline, blurb and illustration
  // "props" (a pill label + glyphs), so the panel cycles through visibly
  // different compositions.
  static const List<_Slide> _slides = [
    _Slide(
      title: 'Everything you love,\nin one place.',
      subtitle:
          'Discover curated collections, exclusive drops and a checkout that just works.',
      art: _SlideArt(pill: '–40%', bigGlyph: '%', leftGlyph: null, rightGlyph: '★'),
    ),
    _Slide(
      title: 'Festive fits,\nready to twirl.',
      subtitle:
          'Shop Navratri chaniya cholis and ethnic edits made for every celebration.',
      art: _SlideArt(pill: 'NEW', bigGlyph: '✦', leftGlyph: '♥', rightGlyph: '★'),
    ),
    _Slide(
      title: 'Try it on,\nbefore you buy.',
      subtitle: 'See any outfit on you with AI try-on — no fitting room needed.',
      art: _SlideArt(pill: 'TRY-ON', bigGlyph: '♥', leftGlyph: '★', rightGlyph: '✦'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() => _slide = (_slide + 1) % _slides.length);
    });
  }

  void _goTo(int i) {
    setState(() => _slide = i);
    _startAutoPlay(); // reset the timer after a manual tap
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(48, 44, 48, 44),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xffC24C6B), Color(0xff9A3253), Color(0xff7C2743)],
          stops: [0.0, 0.58, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xff3C0A19).withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Image.asset('assets/image/onewebmart_logo.png',
                height: 30, fit: BoxFit.contain),
          ),

          // Illustration — cross-fades between slides.
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 550),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: AnimatedBuilder(
                  key: ValueKey('art-$_slide'),
                  animation: _c,
                  builder: (_, __) =>
                      _illustration(_c.value, _slides[_slide].art),
                ),
              ),
            ),
          ),

          // Headline + blurb — cross-fades per slide.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: Column(
              key: ValueKey('txt-$_slide'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _slides[_slide].title,
                  style: TextStyle(
                      fontFamily: AppFont.heading,
                      color: Colors.white,
                      fontSize: 36,
                      height: 1.14,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                Text(
                  _slides[_slide].subtitle,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 15,
                      height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _Chip('Free shipping'),
              _Chip('Easy returns'),
              _Chip('Secure checkout'),
            ],
          ),
          const SizedBox(height: 26),
          // Slide dots — tap to jump.
          Row(
            children: [
              for (int i = 0; i < _slides.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _goTo(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: i == _slide ? 26 : 9,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: i == _slide ? 1 : 0.45),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Small white glyph shown inside a glass bag (null → empty).
  Widget _glyph(String? g) => g == null
      ? const SizedBox.shrink()
      : Text(g,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800));

  // t in [0,1] drives a gentle float; [art] swaps the pill + glyphs per slide.
  Widget _illustration(double t, _SlideArt art) {
    final dy = math.sin(t * math.pi * 2) * 10;
    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // soft glow
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(34),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    Colors.white.withValues(alpha: 0.20),
                    Colors.white.withValues(alpha: 0.0),
                  ], stops: const [0.0, 0.68]),
                ),
              ),
            ),
          ),
          // discount tag
          Positioned(
            top: 18,
            left: 40,
            child: Transform.translate(
              offset: Offset(0, -dy),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xff3C0A19).withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: Text(art.pill,
                    style: const TextStyle(
                        color: Color(0xffC24C6B),
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
              ),
            ),
          ),
          // small glass bag (left)
          Positioned(
            left: 6,
            top: 150,
            child: Transform.translate(
                offset: Offset(0, dy),
                child: _glassBag(80, 92, _glyph(art.leftGlyph))),
          ),
          // small glass bag (right)
          Positioned(
            right: 4,
            top: 66,
            child: Transform.translate(
              offset: Offset(0, -dy),
              child: _glassBag(74, 86, _glyph(art.rightGlyph)),
            ),
          ),
          // big solid bag with the slide's headline glyph
          Positioned(
            left: 96,
            top: 92,
            child: Transform.translate(
              offset: Offset(0, dy * 0.6),
              child: _bigBag(art.bigGlyph),
            ),
          ),
          // sparkles
          _sparkle(60, 150, 12, t),
          _sparkle(250, 120, 9, (t + 0.3) % 1),
          _sparkle(96, 250, 10, (t + 0.55) % 1),
          _sparkle(220, 240, 8, (t + 0.8) % 1),
        ],
      ),
    );
  }

  Widget _sparkle(double left, double top, double size, double t) {
    final op = 0.25 + (0.75 * (0.5 + 0.5 * math.sin(t * math.pi * 2)));
    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: op.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Container(width: size, height: size, color: Colors.white),
        ),
      ),
    );
  }

  Widget _bigBag(String glyph) {
    return SizedBox(
      width: 130,
      height: 156,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // handle
          Positioned(
            top: 0,
            child: Container(
              width: 58,
              height: 22,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 6),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
            ),
          ),
          Positioned(
            top: 16,
            child: Container(
              width: 130,
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xff3C0A19).withValues(alpha: 0.45),
                      blurRadius: 40,
                      offset: const Offset(0, 24))
                ],
              ),
              child: Text(glyph,
                  style: TextStyle(
                      fontFamily: AppFont.heading,
                      color: const Color(0xffC24C6B),
                      fontWeight: FontWeight.w800,
                      fontSize: 44)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassBag(double w, double h, Widget child) {
    return SizedBox(
      width: w,
      height: h + 16,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            child: Container(
              width: w * 0.48,
              height: 16,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.85), width: 5),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
              ),
            ),
          ),
          Positioned(
            top: 12,
            child: Container(
              width: w,
              height: h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// One rotating brand slide: headline, blurb and illustration props.
class _Slide {
  const _Slide({
    required this.title,
    required this.subtitle,
    required this.art,
  });
  final String title;
  final String subtitle;
  final _SlideArt art;
}

/// Per-slide illustration "props" — the pill label plus the glyphs on the big
/// card and the two glass bags. Same style, different elements each slide.
class _SlideArt {
  const _SlideArt({
    required this.pill,
    required this.bigGlyph,
    this.leftGlyph,
    this.rightGlyph,
  });
  final String pill;
  final String bigGlyph;
  final String? leftGlyph;
  final String? rightGlyph;
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 7,
              height: 7,
              decoration:
                  const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Big editorial page title (Playfair), centered.
class AuthTitle extends StatelessWidget {
  const AuthTitle(this.text, {super.key, this.fontSize = 36, this.align = TextAlign.center});
  final String text;
  final double fontSize;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
          fontFamily: AppFont.heading,
          color: AppColor.ink,
          fontSize: fontSize,
          fontWeight: FontWeight.w800),
    );
  }
}

/// A labelled text field styled to the design (blush fill, rounded 12, rose
/// focus ring). Optionally wraps in a [Form] so callers keep their per-field
/// validation flow.
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.suffix,
    this.formKey,
    this.autovalidate = true,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final Widget? suffix;
  final GlobalKey<FormState>? formKey;
  final bool autovalidate;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c, [double w = 1.5]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );

    Widget field = TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      cursorColor: AppColor.primary,
      style: TextStyle(
          fontSize: 15, color: AppColor.ink, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        counterText: '',
        isDense: true,
        filled: true,
        fillColor: AppColor.blush,
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xffBCA9AF), fontSize: 14.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        suffixIcon: suffix,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 44, minHeight: 24),
        enabledBorder: border(Colors.transparent),
        disabledBorder: border(Colors.transparent),
        focusedBorder: border(AppColor.primary),
        errorBorder: border(const Color(0xffD98BA0)),
        focusedErrorBorder: border(AppColor.primary),
        errorStyle: const TextStyle(fontSize: 11.5),
      ),
    );

    if (formKey != null) {
      field = Form(
        key: formKey,
        autovalidateMode:
            autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled,
        child: field,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColor.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          field,
        ],
      ),
    );
  }
}

/// A "Show"/"Hide" text button used as a password field suffix.
class AuthPasswordToggle extends StatelessWidget {
  const AuthPasswordToggle({super.key, required this.visible, required this.onTap});
  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(visible ? 'Hide' : 'Show',
          style: TextStyle(
              color: AppColor.primaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.4)),
    );
  }
}

/// Primary gradient submit button with a busy state.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.busy = false,
    this.topMargin = 26,
  });

  final String label;
  final VoidCallback onTap;
  final bool busy;
  final double topMargin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topMargin),
      child: PressableScale(
        onTap: busy ? () {} : onTap,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColor.ctaGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xff9A3253).withValues(alpha: 0.5),
                  blurRadius: 28,
                  offset: const Offset(0, 14))
            ],
          ),
          child: busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

/// White "Sign in with Google" outline button.
class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({super.key, required this.onTap, this.busy = false});
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: PressableScale(
        onTap: busy ? () {} : onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xffEEDDE2), width: 1.5),
          ),
          child: busy
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColor.primary))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 4,
                              offset: const Offset(0, 1))
                        ],
                      ),
                      child: const Text('G',
                          style: TextStyle(
                              color: Color(0xff4285F4),
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                    ),
                    const SizedBox(width: 12),
                    Text('Sign in with Google',
                        style: TextStyle(
                            color: AppColor.ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Footer row like: "Don't have an account? [Sign up]".
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.text,
    required this.actionLabel,
    required this.onTap,
    this.topMargin = 26,
  });

  final String text;
  final String actionLabel;
  final VoidCallback onTap;
  final double topMargin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topMargin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text,
              style: TextStyle(color: const Color(0xff8C8792), fontSize: 14)),
          const SizedBox(width: 6),
          InkWell(
            onTap: onTap,
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
            child: Text(actionLabel,
                style: TextStyle(
                    color: AppColor.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
