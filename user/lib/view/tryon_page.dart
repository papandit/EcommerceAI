// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';

import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as ip;
import 'package:url_launcher/url_launcher.dart';

/// Virtual "Try it on" page (BrandShoot Try-On). The shopper uploads or takes a
/// photo; we send it to our backend (which holds the API key) and poll for the
/// rendered result. Styled to the "Bloom" dusty-rose theme.
class TryOnPage extends StatefulWidget {
  const TryOnPage({
    super.key,
    required this.productId,
    required this.productName,
    this.thumbnail = '',
  });

  final String productId;
  final String productName;
  final String thumbnail;

  @override
  State<TryOnPage> createState() => _TryOnPageState();
}

enum _TryOnState { idle, generating, done, error }

class _TryOnPageState extends State<TryOnPage> {
  _TryOnState _state = _TryOnState.idle;
  Uint8List? _photoBytes; // local preview
  String? _photoB64; // raw base64 (no data-uri prefix) sent to the backend
  String? _resultUrl;
  String _msg = '';
  bool _busy = false;

  // Preset model option: women/girl models (Indian + International). The shopper
  // can pick a model instead of uploading their own photo.
  List<Map<String, dynamic>> _models = [];
  String? _selectedModelId;
  bool _modelsLoading = false;

  // Remaining try-on credits for the signed-in shopper (null = unknown/not
  // signed in). Each try-on costs 1 credit; at 0 the Generate button is blocked.
  int? _credits;

  // An open request to the admin for more credits (null = none pending).
  Map<String, dynamic>? _pendingRequest;
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    _loadModels();
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    if (!ApiClient.instance.hasToken) return; // credits require auth
    try {
      final data = await ApiClient.instance.getOne('/ai/tryon/credits');
      if (!mounted) return;
      setState(() {
        _credits = (data['credits'] as num?)?.toInt();
        final pr = data['pendingRequest'];
        _pendingRequest = pr is Map ? Map<String, dynamic>.from(pr) : null;
      });
    } catch (_) {
      // non-fatal — badge just stays hidden
    }
  }

  bool get _outOfCredits => _credits != null && _credits! <= 0;
  bool get _hasPendingRequest => _pendingRequest != null;

  /// Ask the admin for more credits. The request lands in the admin's Credits
  /// inbox, where it can be approved (which grants the credits) or rejected.
  Future<void> _requestCredits() async {
    if (_requesting || _hasPendingRequest) return;
    setState(() => _requesting = true);
    try {
      await ApiClient.instance
          .post('/ai/tryon/credits/request', {'amount': 10, 'message': ''});
      if (!mounted) return;
      setState(() {
        _pendingRequest = {'amount': 10};
        _requesting = false;
      });
      _toast('Request sent — the admin will review it shortly.');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _requesting = false;
        if (e.statusCode == 409) _pendingRequest = {'amount': 10};
      });
      _toast(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _requesting = false);
      _toast('Could not send the request. Please try again.');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _loadModels() async {
    if (!ApiClient.instance.hasToken) return; // models endpoint requires auth
    setState(() => _modelsLoading = true);
    try {
      final list = await ApiClient.instance.getList('/ai/models');
      if (!mounted) return;
      setState(() => _models = list);
    } catch (_) {
      // non-fatal — the model row just stays hidden
    } finally {
      if (mounted) setState(() => _modelsLoading = false);
    }
  }

  void _selectModel(String id) {
    setState(() {
      _selectedModelId = (_selectedModelId == id) ? null : id;
      // Picking a model and uploading a photo are mutually exclusive.
      if (_selectedModelId != null) {
        _photoBytes = null;
        _photoB64 = null;
      }
      _state = _TryOnState.idle;
      _msg = '';
    });
  }

  Future<void> _pick(ip.ImageSource source) async {
    try {
      final ip.XFile? file = await ip.ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _photoB64 = base64Encode(bytes);
        _selectedModelId = null; // a photo overrides any picked model
        _state = _TryOnState.idle;
        _msg = '';
      });
    } catch (_) {
      setState(() {
        _state = _TryOnState.error;
        _msg = "Couldn't read that photo. Please try another.";
      });
    }
  }

  bool get _hasPerson => _photoB64 != null || _selectedModelId != null;

  Future<void> _generate() async {
    if (!_hasPerson) return;
    if (!ApiClient.instance.hasToken) {
      _promptLogin();
      return;
    }
    setState(() {
      _state = _TryOnState.generating;
      _msg = 'Creating your look… this takes ~20–40s';
      _busy = true;
    });
    try {
      final res = await ApiClient.instance.post('/ai/tryon', {
        'productId': widget.productId,
        // Either the shopper's own photo or a chosen preset model.
        if (_photoB64 != null) 'userImage': _photoB64,
        if (_photoB64 == null && _selectedModelId != null)
          'modelId': _selectedModelId,
      });
      final jobId = (res['jobId'] ?? '').toString();
      if (jobId.isEmpty) {
        _fail('Could not start try-on. Please try again.');
        return;
      }
      // The backend deducts 1 credit on start and returns the new balance.
      final remaining = (res['credits'] as num?)?.toInt();
      if (remaining != null) _credits = remaining;
      await _poll(jobId);
    } on ApiException catch (e) {
      // 402 = out of try-on credits. Nothing was charged (we deduct before the
      // job starts), so show a distinct, non-retryable message.
      if (e.statusCode == 402) {
        setState(() => _credits = 0);
        _fail("You're out of try-on credits.");
      } else {
        _fail(e.message);
      }
    } catch (_) {
      _fail('Network error. Please check your connection.');
    } finally {
      _busy = false;
    }
  }

  Future<void> _poll(String jobId) async {
    // Poll every 2.5s for up to ~2.5 minutes.
    for (var i = 0; i < 60; i++) {
      await Future.delayed(const Duration(milliseconds: 2500));
      if (!mounted) return;
      try {
        final data = await ApiClient.instance.getOne('/ai/jobs/$jobId');
        final status = (data['status'] ?? '').toString();
        final images = (data['images'] is List)
            ? List<String>.from(data['images'])
            : <String>[];
        if (status == 'done' && images.isNotEmpty) {
          setState(() {
            _resultUrl = images.first;
            _state = _TryOnState.done;
          });
          return;
        }
        if (status == 'error') {
          _fail('Something went wrong, please try again.');
          return;
        }
      } on ApiException catch (e) {
        _fail(e.message);
        return;
      } catch (_) {
        // transient — keep polling
      }
    }
    _fail('Timed out — please try again.');
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _state = _TryOnState.error;
      _msg = message;
    });
  }

  void _reset() {
    setState(() {
      _state = _TryOnState.idle;
      _photoBytes = null;
      _photoB64 = null;
      _selectedModelId = null;
      _resultUrl = null;
      _msg = '';
    });
  }

  void _promptLogin() {
    AppToast.show(context, 'Please sign in to try this on.', success: false);
    WebAPPNavigation.navigateToroute(
      context: context,
      routename: '/LoginPage',
      data: {'refresh': () {}},
      screen: const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cream,
      appBar: AppBar(
        title: const Text('Virtual Try-On'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.ink),
          onPressed: () => WebAPPNavigation.navigateTo(context: context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _productHeader(),
                const SizedBox(height: 22),
                _body(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _productHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: AppRadius.md,
        border: Appborder.appborder,
        boxShadow: Appshadow.soft,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.sm,
            child: Container(
              width: 58,
              height: 58,
              color: AppColor.blush,
              child: widget.thumbnail.isEmpty
                  ? Icon(Icons.checkroom_outlined, color: AppColor.primary)
                  : CachedNetworkImage(
                      imageUrl: widget.thumbnail,
                      fit: BoxFit.cover,
                      errorWidget: (c, u, e) =>
                          Icon(Icons.checkroom_outlined, color: AppColor.primary),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Try on',
                  style: TextStyle(
                      color: AppColor.fontColorgrey,
                      fontSize: 11.5,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColor.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    switch (_state) {
      case _TryOnState.generating:
        return _generatingView();
      case _TryOnState.done:
        return _doneView();
      case _TryOnState.error:
        return _errorView();
      case _TryOnState.idle:
        return _idleView();
    }
  }

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: AppRadius.lg,
          border: Appborder.appborder,
          boxShadow: Appshadow.soft,
        ),
        child: child,
      );

  Widget _idleView() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_photoBytes != null)
            ClipRRect(
              borderRadius: AppRadius.md,
              child: Image.memory(_photoBytes!,
                  height: 320, width: double.infinity, fit: BoxFit.cover),
            )
          else
            Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: AppColor.roseGradient,
                borderRadius: AppRadius.md,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: AppColor.primary, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    'See it on you',
                    style: TextStyle(
                        fontFamily: AppFont.heading,
                        color: AppColor.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Upload a clear, well-lit full-body photo for the best result.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColor.fontColorgrey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _outlineBtn(
                  icon: Icons.photo_library_outlined,
                  label: 'Upload',
                  onTap: () => _pick(ip.ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _outlineBtn(
                  icon: Icons.photo_camera_outlined,
                  label: 'Camera',
                  onTap: () => _pick(ip.ImageSource.camera),
                ),
              ),
            ],
          ),
          _modelPicker(),
          if (_credits != null) ...[
            const SizedBox(height: 14),
            _creditsBadge(),
            if (_outOfCredits) ...[
              const SizedBox(height: 10),
              _requestCreditsBtn(),
            ],
          ],
          const SizedBox(height: 14),
          _primaryBtn(
            label: _outOfCredits
                ? "You're out of try-on credits"
                : (_hasPerson
                    ? 'Generate try-on'
                    : 'Add a photo or pick a model'),
            enabled: _hasPerson && !_outOfCredits,
            onTap: _generate,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 13, color: AppColor.fontColorgrey),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Your photo is used only to create this image.',
                  style:
                      TextStyle(color: AppColor.fontColorgrey, fontSize: 11.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modelPicker() {
    if (_models.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Divider(color: AppColor.dividercolor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('or try it on a model',
                    style: TextStyle(
                        color: AppColor.fontColorgrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              Expanded(child: Divider(color: AppColor.dividercolor)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 124,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _models.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final m = _models[i];
                final id = (m['id'] ?? '').toString();
                final name = (m['name'] ?? '').toString();
                final img = (m['imageFullUrl'] ?? '').toString();
                final selected = _selectedModelId == id;
                return GestureDetector(
                  onTap: () => _selectModel(id),
                  child: Container(
                    width: 86,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.sm,
                      border: Border.all(
                        color:
                            selected ? AppColor.primary : AppColor.dividercolor,
                        width: selected ? 2.4 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10)),
                            child: CachedNetworkImage(
                              imageUrl: img,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (c, u, e) => Container(
                                color: AppColor.blush,
                                child: Icon(Icons.person,
                                    color: AppColor.primary),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 2),
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? AppColor.primary
                                  : AppColor.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _creditsBadge() {
    final out = _outOfCredits;
    final n = _credits ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: out ? const Color(0xFFFCEBEB) : AppColor.blush,
        borderRadius: AppRadius.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(out ? Icons.info_outline : Icons.auto_awesome,
              size: 16, color: out ? const Color(0xFFC0392B) : AppColor.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              out
                  ? (_hasPendingRequest
                      ? 'Request sent — waiting for admin approval.'
                      : 'No try-on credits left. Ask the admin for more.')
                  : (n == 1
                      ? '1 try-on credit left'
                      : '$n try-on credits left'),
              style: TextStyle(
                color: out ? const Color(0xFFC0392B) : AppColor.primaryDark,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "Ask admin for credits" button, shown when the shopper is out of credits.
  /// Disabled once a request is pending so they can't spam the admin inbox.
  Widget _requestCreditsBtn() {
    final pending = _hasPendingRequest;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: (pending || _requesting) ? null : _requestCredits,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.primary,
          side: BorderSide(color: AppColor.primary.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
        ),
        icon: _requesting
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColor.primary),
              )
            : Icon(pending ? Icons.hourglass_top : Icons.card_giftcard_outlined,
                size: 18),
        label: Text(
          pending ? 'Request pending' : 'Ask admin for credits',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  Widget _generatingView() {
    return _card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            SizedBox(
              width: 46,
              height: 46,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: AppColor.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Creating your look…',
              style: TextStyle(
                  fontFamily: AppFont.heading,
                  color: AppColor.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _msg,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.fontColorgrey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _doneView() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: AppRadius.md,
            child: CachedNetworkImage(
              imageUrl: _resultUrl!,
              fit: BoxFit.cover,
              placeholder: (c, u) => Container(
                height: 320,
                color: AppColor.blush,
                child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColor.primary)),
              ),
              errorWidget: (c, u, e) => Container(
                height: 320,
                color: AppColor.blush,
                child: Icon(Icons.broken_image_outlined,
                    color: AppColor.primary),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _primaryBtn(
            label: 'Download',
            enabled: true,
            icon: Icons.download_rounded,
            onTap: () async {
              final uri = Uri.tryParse(_resultUrl ?? '');
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 12),
          _outlineBtn(
            icon: Icons.refresh,
            label: 'Try another photo',
            onTap: _reset,
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return _card(
      child: Column(
        children: [
          Icon(Icons.sentiment_dissatisfied_outlined,
              color: AppColor.primary, size: 40),
          const SizedBox(height: 14),
          Text(
            _msg.isEmpty ? 'Something went wrong.' : _msg,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColor.ink, fontSize: 14.5),
          ),
          const SizedBox(height: 18),
          _primaryBtn(label: 'Try again', enabled: true, onTap: _reset),
        ],
      ),
    );
  }

  Widget _primaryBtn({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final child = Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: enabled ? AppColor.ctaGradient : null,
        color: enabled ? null : AppColor.dividercolor,
        borderRadius: AppRadius.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon,
                color: enabled ? Colors.white : AppColor.fontColorgrey,
                size: 19),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
                color: enabled ? Colors.white : AppColor.fontColorgrey,
                fontSize: 15.5,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
    if (!enabled || _busy) return Opacity(opacity: enabled ? 1 : 0.9, child: child);
    return PressableScale(onTap: onTap, child: child);
  }

  Widget _outlineBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColor.blush,
          borderRadius: AppRadius.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColor.primary, size: 19),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                  color: AppColor.primaryDark,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
