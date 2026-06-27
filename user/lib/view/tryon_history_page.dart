// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// "My Try-Ons" — the shopper's saved virtual try-on creations: total count,
/// a gallery of results, and a per-image download. Themed dusty-rose.
class TryOnHistoryPage extends StatefulWidget {
  const TryOnHistoryPage({super.key});

  @override
  State<TryOnHistoryPage> createState() => _TryOnHistoryPageState();
}

class _TryOnHistoryPageState extends State<TryOnHistoryPage> {
  bool _loading = true;
  String _error = '';
  int _total = 0;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!ApiClient.instance.hasToken) {
      setState(() {
        _loading = false;
        _error = 'Please sign in to see your try-ons.';
      });
      return;
    }
    try {
      final data = await ApiClient.instance.getOne('/ai/tryon/history');
      final items = (data['items'] is List)
          ? List<Map<String, dynamic>>.from(
              (data['items'] as List).map((e) => Map<String, dynamic>.from(e)))
          : <Map<String, dynamic>>[];
      setState(() {
        _total = (data['total'] is int)
            ? data['total']
            : int.tryParse('${data['total']}') ?? items.length;
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Could not load your try-ons. Please try again.';
      });
    }
  }

  Future<void> _download(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _fmtDate(dynamic iso) {
    final d = DateTime.tryParse('$iso');
    if (d == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cream,
      appBar: AppBar(
        title: const Text('My Try-Ons'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.ink),
          onPressed: () => WebAPPNavigation.navigateTo(context: context),
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: AppColor.primary))
          : _error.isNotEmpty
              ? _emptyOrError(_error)
              : _items.isEmpty
                  ? _emptyOrError('You haven\'t created any try-ons yet.')
                  : _content(),
    );
  }

  Widget _emptyOrError(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: AppColor.primary, size: 44),
              const SizedBox(height: 14),
              Text(msg,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColor.fontColorgrey, fontSize: 14)),
            ],
          ),
        ),
      );

  Widget _content() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _totalCard(),
              const SizedBox(height: 18),
              ..._items.map(_itemCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _totalCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: AppColor.ctaGradient,
        borderRadius: AppRadius.md,
        boxShadow: Appshadow.soft,
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 30),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_total',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700)),
              const Text('total try-on creations',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _itemCard(Map<String, dynamic> item) {
    final name = (item['productName'] ?? 'Product').toString();
    final date = _fmtDate(item['createdAt']);
    final images = (item['images'] is List)
        ? List<String>.from((item['images'] as List).map((e) => e.toString()))
        : <String>[];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: AppRadius.md,
        border: Appborder.appborder,
        boxShadow: Appshadow.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColor.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
              Text(date,
                  style: TextStyle(
                      color: AppColor.fontColorgrey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: images.map((url) => _resultThumb(url)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _resultThumb(String url) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: AppRadius.sm,
          child: CachedNetworkImage(
            imageUrl: url,
            width: 150,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (c, u) => Container(
              width: 150,
              height: 200,
              color: AppColor.blush,
              child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColor.primary)),
            ),
            errorWidget: (c, u, e) => Container(
              width: 150,
              height: 200,
              color: AppColor.blush,
              child: Icon(Icons.broken_image_outlined, color: AppColor.primary),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 150,
          child: PressableScale(
            onTap: () => _download(url),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColor.blush,
                borderRadius: AppRadius.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_rounded,
                      color: AppColor.primary, size: 18),
                  const SizedBox(width: 6),
                  Text('Download',
                      style: TextStyle(
                          color: AppColor.primaryDark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
