// ignore_for_file: must_be_immutable, sized_box_for_whitespace

import 'package:EcommerceApp/helper/bottom_bar.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/viewmodel/homecontroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class HtmlConain extends StatefulWidget {
  HtmlConain({super.key, this.htmldata, this.title});
  String? htmldata;
  String? title;
  @override
  State<HtmlConain> createState() => _HtmlConainState();
}

class _HtmlConainState extends State<HtmlConain> {
  Homecontoller homecontoller = Get.put(Homecontoller());
  GetCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    homecontoller.userid = prefs.getString(prefrenceKey.userid) ?? '';
  }

  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool wide =
        MediaQuery.of(context).size.width > CommonWidget.headerWidth;
    final bool hasData = widget.htmldata != null &&
        "${widget.htmldata}".trim().isNotEmpty &&
        "${widget.htmldata}".trim() != "null";

    final bool isAbout = _isAboutPage;

    Widget pageBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _headerBand(context),
        isAbout
            ? _aboutContent(context)
            : (hasData
                ? _htmlContent(context)
                : (_defaultContent(context) ?? _emptyState(context))),
      ],
    );

    if (wide) {
      return Scaffold(
        body: WillPopScope(
          onWillPop: () => Future(() => false),
          child: Container(
            color: AppColor.BgColor,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: StickyHeader(
                header:
                    CommonWidget().StickyHeaders(context, Refresh: setState),
                content: Column(
                  children: [
                    pageBody,
                    CommonWidget().Footer(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CommonWidget().Header(
          context: context, heart: false, title: _resolveTitle("Information")),
      endDrawer:
          CommonWidget().Drowers(context, userid: homecontoller.userid),
      body: Container(
        color: AppColor.BgColor,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(child: pageBody),
      ),
    );
  }

  // Resolve a friendly section title. The router sometimes passes "Unknown"
  // (or a raw code) when a page is opened directly / reloaded — in that case
  // derive a readable name from the URL slug instead.
  // Robust "is this the About page?" check — the router is unreliable about
  // titles/URLs, so we look at the title, the page content, and the URL.
  bool get _isAboutPage {
    final t = (widget.title ?? '').toLowerCase();
    if (t.contains('about')) return true;
    final h = (widget.htmldata ?? '').toLowerCase();
    if (h.contains('about us') || h.trim() == 'about') return true;
    try {
      if (Uri.base.toString().toLowerCase().contains('about')) return true;
    } catch (_) {}
    return false;
  }

  String _resolveTitle(String fallback) {
    // The URL slug is the most reliable per-page indicator — the router's
    // passed title can be stale (e.g. a leftover "ContectUs"). Prefer it.
    try {
      final segs = Uri.base.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segs.isNotEmpty) {
        final lastLow = segs.last.toLowerCase();
        final last = Uri.decodeComponent(segs.last)
            .replaceAll('-', ' ')
            .replaceAll('_', ' ')
            .trim();
        final looksLikeId = last.length > 18 && !last.contains(' ');
        if (last.isNotEmpty &&
            !looksLikeId &&
            lastLow != 'pages' &&
            lastLow != 'page' &&
            lastLow != 'homepage' &&
            lastLow != 'bottombar' &&
            lastLow != 'splashpage') {
          return last
              .split(' ')
              .where((w) => w.isNotEmpty)
              .map((w) => w[0].toUpperCase() + w.substring(1))
              .join(' ');
        }
      }
    } catch (_) {}
    // Fall back to the passed title if the URL wasn't usable.
    final raw = (widget.title ?? '').trim();
    final low = raw.toLowerCase();
    if (raw.isNotEmpty &&
        low != 'unknown' &&
        low != 'null' &&
        !low.startsWith('page-') &&
        !low.startsWith('pages-')) {
      return raw;
    }
    return fallback;
  }

  Widget _headerBand(BuildContext context) {
    final bool wide =
        MediaQuery.of(context).size.width > CommonWidget.headerWidth;
    final title = _isAboutPage ? "About Us" : _resolveTitle("Information");
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: AppColor.roseGradient),
          padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFont.heading,
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                  color: AppColor.ink,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 3,
                width: 56,
                decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
        ),
        if (wide)
          Positioned(
            top: 16,
            left: 16,
            child: CommonWidget().heroBackArrow(context),
          ),
      ],
    );
  }

  Widget _htmlContent(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Html(shrinkWrap: true, data: "${widget.htmldata}"),
      ),
    );
  }

  Widget _aboutContent(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width > 900;
    return Column(
      children: [
        // ── Our Story ──────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: 24, vertical: wide ? 64 : 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: [
                  Text("OUR STORY",
                      style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 2,
                          color: AppColor.primary,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text("Fashion made for every her",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: AppFont.heading,
                          fontSize: wide ? 34 : 26,
                          color: AppColor.ink,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 18),
                  Text(
                    "We started with a simple belief — that every woman deserves to feel beautiful, confident and completely herself. What began as a small, hand-picked edit has grown into a destination for thoughtfully curated women's fashion, where timeless silhouettes meet of-the-moment trends.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16, height: 1.7, color: AppColor.fontColorgrey),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Every piece in our collection is chosen with care — for its quality, its fit and the way it makes you feel. From everyday essentials to standout statement pieces, we're here to help you build a wardrobe you'll love to live in.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16, height: 1.7, color: AppColor.fontColorgrey),
                  ),
                ],
              ),
            ),
          ),
        ),
        // ── What we stand for ──────────────────────────────────────
        Container(
          width: double.infinity,
          color: AppColor.cream,
          padding: EdgeInsets.symmetric(
              horizontal: 24, vertical: wide ? 56 : 40),
          child: Column(
            children: [
              Text("What we stand for",
                  style: TextStyle(
                      fontFamily: AppFont.heading,
                      fontSize: wide ? 30 : 24,
                      color: AppColor.ink,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                  height: 3,
                  width: 50,
                  decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 36),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: [
                  _valueCard(Icons.auto_awesome_outlined, "Curated with Care",
                      "Every style is hand-picked by our team — no filler, just pieces worth wearing."),
                  _valueCard(Icons.workspace_premium_outlined, "Quality, Always",
                      "Premium fabrics and considered construction, so your favourites last."),
                  _valueCard(Icons.favorite_outline, "Made for Every Her",
                      "Inclusive sizing and styles designed to flatter and celebrate every body."),
                  _valueCard(Icons.eco_outlined, "Conscious & Kind",
                      "Thoughtful choices and responsible partners, every step of the way."),
                ],
              ),
            ],
          ),
        ),
        // ── Mission quote ──────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: AppColor.roseGradient),
          padding: EdgeInsets.symmetric(
              horizontal: 24, vertical: wide ? 60 : 44),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  Icon(Icons.format_quote_rounded,
                      color: AppColor.primary, size: 44),
                  const SizedBox(height: 10),
                  Text(
                    "\"To make every woman feel effortlessly beautiful — with fashion that's as thoughtful as it is timeless.\"",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: AppFont.heading,
                        fontSize: wide ? 26 : 20,
                        height: 1.5,
                        color: AppColor.ink,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 14),
                  Text("— The Team",
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColor.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ),
        // ── CTA ────────────────────────────────────────────────────
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: 24, vertical: wide ? 60 : 44),
          child: Column(
            children: [
              Text("Ready to find your new favourite?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: AppFont.heading,
                      fontSize: wide ? 28 : 22,
                      color: AppColor.ink,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              PressableScale(
                onTap: () {
                  WebAPPNavigation.navigateToroute(
                      context: context,
                      routename: '/HomePage',
                      screen: BottomBar(pageindex: 0));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  decoration: BoxDecoration(
                      gradient: AppColor.ctaGradient,
                      borderRadius: BorderRadius.circular(100)),
                  child: const Text("Explore the Collection",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _valueCard(IconData icon, String title, String desc) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.dividercolor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 54,
            width: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColor.blush, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: AppColor.primary, size: 26),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: TextStyle(
                  fontSize: 17,
                  color: AppColor.ink,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(desc,
              style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: AppColor.fontColorgrey)),
        ],
      ),
    );
  }

  // ── Built-in content for known policy / info pages ──────────────────────
  String _pageKind() {
    final t = _resolveTitle('').toLowerCase();
    if (t.contains('t&c') || t.contains('term')) return 'terms';
    if (t.contains('privacy')) return 'privacy';
    if (t.contains('track')) return 'tracking';
    if (t.contains('return') || t.contains('refund')) return 'return';
    if (t.contains('exchange')) return 'exchange';
    if (t.contains('shipping') || t.contains('cod')) return 'shipping';
    if (t.contains('size')) return 'size';
    if (t.contains('career')) return 'career';
    return '';
  }

  Widget? _defaultContent(BuildContext context) {
    final kind = _pageKind();
    if (kind.isEmpty) return null;
    if (kind == 'size') return _sizeChartContent(context);
    final sections = _contentMap[kind];
    if (sections == null) return null;
    return _infoBody(context, sections);
  }

  Map<String, List<List<String>>> get _contentMap => {
        'terms': [
          ['1. Acceptance of Terms',
              'By accessing and shopping on this website you agree to these Terms & Conditions and our Privacy Policy. If you do not agree, please do not use the site.'],
          ['2. Products & Pricing',
              'All prices are in INR and inclusive of applicable taxes. We try to display product details and prices accurately; in case of an error we reserve the right to cancel the affected order.'],
          ['3. Orders',
              'An order is confirmed once payment is received (or, for COD, once verified). We may refuse or cancel any order at our discretion, including for suspected fraud or stock issues.'],
          ['4. Intellectual Property',
              'All content on this site — images, logos, text and design — is owned by us and may not be reproduced without written permission.'],
          ['5. Limitation of Liability',
              'We are not liable for any indirect or consequential loss arising from the use of this site, to the extent permitted by law.'],
          ['6. Governing Law',
              'These terms are governed by the laws of India and subject to the jurisdiction of the courts of Bhuj, Gujarat.'],
        ],
        'privacy': [
          ['Information We Collect',
              'We collect details you provide — name, email, phone, shipping address and order history — plus basic usage data to operate and improve the store.'],
          ['How We Use It',
              'To process orders, provide support, send order updates, and (with your consent) share offers. We never sell your personal data.'],
          ['Cookies',
              'We use cookies to keep you signed in, remember your cart and understand site usage. You can disable cookies in your browser settings.'],
          ['Data Sharing',
              'We share data only with trusted partners needed to fulfil your order — payment gateways and delivery partners.'],
          ['Security',
              'Your data is stored securely with restricted access. Payment details are handled by PCI-compliant gateways.'],
          ['Your Rights',
              'You may request access to, correction of, or deletion of your personal data by contacting us.'],
        ],
        'tracking': [
          ['How to Track Your Order',
              'Open My Orders → tap an order → View Details to see the live status. You will also receive updates by email.'],
          ['Order Statuses',
              'Pending → Processing (packed) → Shipped → Delivered. Each stage appears on your order tracking timeline.'],
          ['Delivery Timelines',
              'Orders are usually dispatched within 1–2 business days and delivered within 4–7 business days, depending on your location.'],
          ['Need Help?',
              'If your order is delayed or the status hasn\'t updated, reach us via the Contact Us page and we\'ll help right away.'],
        ],
        'return': [
          ['Return Window',
              'You can request a return within 7 days of delivery for eligible items.'],
          ['Eligibility',
              'Items must be unused, unwashed and have their original tags and packaging. Innerwear and customised items are non-returnable.'],
          ['How to Return',
              'Open My Orders → select the item → request a return. Our team will arrange a pickup or guide you on shipping it back.'],
          ['Refund Timeline',
              'After we receive and inspect the item, refunds are processed to the original payment method within 5–7 business days. COD orders are refunded to your bank/UPI.'],
        ],
        'exchange': [
          ['Exchange Window',
              'Exchanges are accepted within 7 days of delivery, subject to stock availability.'],
          ['Eligibility',
              'The item must be unused with original tags. Exchange for a different size or colour of the same product, or another item of equal value.'],
          ['How to Exchange',
              'Open My Orders → select the item → request an exchange and choose the new size/colour. We\'ll arrange a pickup and ship the replacement.'],
          ['Size Issues',
              'Not sure of your size? Check our Size Chart before ordering to reduce the need for exchanges.'],
        ],
        'shipping': [
          ['Shipping Coverage',
              'We ship across India to all serviceable pincodes.'],
          ['Charges',
              'Standard shipping is complimentary on orders above ₹999. A nominal fee applies to smaller orders and is shown at checkout.'],
          ['Delivery Time',
              'Orders are dispatched in 1–2 business days and typically delivered within 4–7 business days.'],
          ['Cash on Delivery (COD)',
              'COD is available on most pincodes for orders up to ₹20,000. A small COD handling fee may apply and is shown at checkout.'],
        ],
        'career': [
          ['Work With Us',
              'We\'re a fast-growing women\'s fashion brand on a mission to make every woman feel effortlessly beautiful. If that excites you, we\'d love to meet you.'],
          ['Open Roles',
              'We regularly hire across Merchandising, Catalog & Photography, Customer Experience, Operations and Technology.'],
          ['Our Culture',
              'A small, passionate team • ownership from day one • a shared love for great product and happy customers.'],
          ['How to Apply',
              'Email your CV and a short note about yourself to careers@clickandcollect.com (or use the Contact Us page) and our team will get back to you.'],
        ],
      };

  Widget _infoBody(BuildContext context, List<List<String>> sections) {
    return Container(
      width: double.infinity,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      constraints:
          BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sections
              .map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s[0],
                            style: TextStyle(
                                fontFamily: AppFont.heading,
                                fontSize: 20,
                                color: AppColor.ink,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Text(s[1],
                            style: TextStyle(
                                fontSize: 15,
                                height: 1.7,
                                color: AppColor.fontColorgrey)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _sizeChartContent(BuildContext context) {
    const rows = [
      ['Size', 'Bust (in)', 'Waist (in)', 'Hips (in)'],
      ['XS', '30–32', '24–26', '33–35'],
      ['S', '32–34', '26–28', '35–37'],
      ['M', '34–36', '28–30', '37–39'],
      ['L', '36–38', '30–32', '39–41'],
      ['XL', '38–40', '32–34', '41–43'],
      ['XXL', '40–43', '34–37', '43–46'],
      ['XXXL', '43–46', '37–40', '46–49'],
    ];
    return Container(
      width: double.infinity,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Women's Size Guide",
                style: TextStyle(
                    fontFamily: AppFont.heading,
                    fontSize: 22,
                    color: AppColor.ink,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
                "All measurements are body measurements in inches. If you're between sizes, we recommend sizing up.",
                style: TextStyle(
                    fontSize: 14, height: 1.6, color: AppColor.fontColorgrey)),
            const SizedBox(height: 20),
            Table(
              border: TableBorder.all(color: AppColor.dividercolor),
              children: rows.asMap().entries.map((e) {
                final isHeader = e.key == 0;
                return TableRow(
                  decoration: BoxDecoration(
                      color: isHeader ? AppColor.blush : AppColor.whiteColor),
                  children: e.value
                      .map((c) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Text(c,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColor.ink,
                                    fontWeight: isHeader
                                        ? FontWeight.w700
                                        : FontWeight.w500)),
                          ))
                      .toList(),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Text("How to Measure",
                style: TextStyle(
                    fontFamily: AppFont.heading,
                    fontSize: 18,
                    color: AppColor.ink,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(
                "• Bust: measure around the fullest part of your chest.\n• Waist: measure around the narrowest part of your waist.\n• Hips: measure around the fullest part of your hips.\nKeep the tape snug but not tight.",
                style: TextStyle(
                    fontSize: 14.5, height: 1.8, color: AppColor.fontColorgrey)),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 84,
            width: 84,
            decoration:
                BoxDecoration(color: AppColor.blush, shape: BoxShape.circle),
            child: Icon(Icons.auto_stories_outlined,
                color: AppColor.primary, size: 38),
          ),
          const SizedBox(height: 18),
          Text(
            "Content coming soon",
            style: TextStyle(
                fontFamily: AppFont.heading,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColor.ink),
          ),
          const SizedBox(height: 8),
          Text(
            "We're putting the finishing touches on this page.\nPlease check back shortly.",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, height: 1.5, color: AppColor.fontColorgrey),
          ),
        ],
      ),
    );
  }
}
