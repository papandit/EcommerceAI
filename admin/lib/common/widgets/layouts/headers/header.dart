import 'package:cwt_ecommerce_admin_panel/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../data/services/api/api_client.dart';
import '../../../../features/personalization/controllers/user_controller.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/device/device_utility.dart';
import '../../appbar/appbar.dart';
import '../../images/t_rounded_image.dart';
import '../../shimmers/shimmer.dart';

/// Header widget for the application.
///
/// Hosts a working product search (typeahead overlay) and an order
/// notifications bell with a count badge + recent-orders menu. Both load
/// their data once from the REST backend via [ApiClient].
class THeader extends StatefulWidget implements PreferredSizeWidget {
  const THeader({
    super.key,
    required this.scaffoldKey,
  });

  /// GlobalKey to access the Scaffold state
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<THeader> createState() => _THeaderState();

  @override
  Size get preferredSize =>
      Size.fromHeight(TDeviceUtils.getAppBarHeight() + 15);
}

class _THeaderState extends State<THeader> {
  // ---- Search state -------------------------------------------------------
  final LayerLink _searchLink = LayerLink();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  OverlayEntry? _searchOverlay;

  /// Cached product list (raw maps). Loaded once in [initState].
  final List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _searchResults = [];

  // ---- Notification (orders) state ---------------------------------------
  /// Cached orders (raw maps). Loaded once in [initState].
  final List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadOrders();
    _searchFocus.addListener(() {
      // Hide the overlay when focus is lost.
      if (!_searchFocus.hasFocus) _removeSearchOverlay();
    });
  }

  @override
  void dispose() {
    _removeSearchOverlay();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ---- Data loading -------------------------------------------------------

  Future<void> _loadProducts() async {
    try {
      final data = await ApiClient.instance.getList('/products');
      if (!mounted) return;
      setState(() {
        _allProducts
          ..clear()
          ..addAll(data);
      });
    } catch (_) {
      // Silent: search just stays empty if products can't be fetched.
    }
  }

  Future<void> _loadOrders() async {
    try {
      final data = await ApiClient.instance.getList('/orders');
      if (!mounted) return;
      setState(() {
        _orders
          ..clear()
          ..addAll(data);
      });
    } catch (_) {
      // Silent: bell just shows no badge if orders can't be fetched.
    }
  }

  // ---- Small field helpers (defensive about backend key casing) -----------

  String _productId(Map<String, dynamic> p) =>
      (p['id'] ?? p['Id'] ?? p['_id'] ?? '').toString();

  String _productTitle(Map<String, dynamic> p) =>
      (p['Title'] ?? p['title'] ?? '').toString();

  String _productThumb(Map<String, dynamic> p) =>
      (p['Thumbnail'] ?? p['thumbnail'] ?? '').toString();

  String _productPrice(Map<String, dynamic> p) {
    final raw = p['Price'] ?? p['price'];
    if (raw == null) return '';
    final value = double.tryParse(raw.toString());
    if (value == null) return '';
    return '₹${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2)}';
  }

  String _orderId(Map<String, dynamic> o) =>
      (o['Orderid'] ?? o['id'] ?? o['Id'] ?? o['_id'] ?? '').toString();

  String _orderShortId(Map<String, dynamic> o) {
    final id = _orderId(o);
    if (id.isEmpty) return '—';
    return id.length <= 8 ? id : '#${id.substring(id.length - 8)}';
  }

  String _orderAmount(Map<String, dynamic> o) {
    final value = double.tryParse((o['totalAmount'] ?? 0).toString()) ?? 0;
    return '₹${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2)}';
  }

  String _orderStatus(Map<String, dynamic> o) {
    final s = (o['status'] ?? '').toString().replaceAll('OrderStatus.', '');
    return s.isEmpty ? 'pending' : s;
  }

  String _orderEmail(Map<String, dynamic> o) =>
      (o['email'] ?? '').toString();

  /// Orders sorted newest-first by date.
  List<Map<String, dynamic>> get _recentOrders {
    final list = [..._orders];
    DateTime when(Map<String, dynamic> o) =>
        DateTime.tryParse(
            (o['orderDate'] ?? o['createdAt'] ?? '').toString()) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    list.sort((a, b) => when(b).compareTo(when(a)));
    return list;
  }

  int get _pendingCount =>
      _orders.where((o) => _orderStatus(o).toLowerCase() == 'pending').length;

  // ---- Search overlay -----------------------------------------------------

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      _searchResults = [];
      _removeSearchOverlay();
      return;
    }
    _searchResults = _allProducts
        .where((p) => _productTitle(p).toLowerCase().contains(q))
        .take(6)
        .toList();
    _showSearchOverlay();
  }

  void _showSearchOverlay() {
    _removeSearchOverlay();
    _searchOverlay = OverlayEntry(builder: (context) => _buildSearchOverlay());
    Overlay.of(context).insert(_searchOverlay!);
  }

  void _removeSearchOverlay() {
    _searchOverlay?.remove();
    _searchOverlay = null;
  }

  void _openProduct(Map<String, dynamic> product) {
    final id = _productId(product);
    _searchController.clear();
    _searchResults = [];
    _searchFocus.unfocus();
    _removeSearchOverlay();
    if (id.isNotEmpty) {
      Get.toNamed("${TRoutes.editProduct}?productId=$id");
    }
  }

  Widget _buildSearchOverlay() {
    return Positioned(
      width: 400,
      child: CompositedTransformFollower(
        link: _searchLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 52),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          color: TColors.white,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 340),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              border: Border.all(color: TColors.borderPrimary),
            ),
            child: _searchResults.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(TSizes.md),
                    child: Text(
                      'No products found',
                      style: TextStyle(color: TColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: TSizes.xs),
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: TColors.borderPrimary,
                    ),
                    itemBuilder: (context, index) {
                      final product = _searchResults[index];
                      final thumb = _productThumb(product);
                      final price = _productPrice(product);
                      return InkWell(
                        onTap: () => _openProduct(product),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: TSizes.sm, vertical: TSizes.sm),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    TSizes.borderRadiusSm),
                                child: thumb.isNotEmpty
                                    ? Image.network(
                                        thumb,
                                        width: 36,
                                        height: 36,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _thumbFallback(),
                                      )
                                    : _thumbFallback(),
                              ),
                              const SizedBox(width: TSizes.sm),
                              Expanded(
                                child: Text(
                                  _productTitle(product),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: TColors.textPrimary),
                                ),
                              ),
                              if (price.isNotEmpty) ...[
                                const SizedBox(width: TSizes.sm),
                                Text(
                                  price,
                                  style: const TextStyle(
                                    color: TColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _thumbFallback() => Container(
        width: 36,
        height: 36,
        color: TColors.lightContainer,
        child: const Icon(Iconsax.image, size: 18, color: TColors.primary),
      );

  Widget _buildSearchField() {
    return CompositedTransformTarget(
      link: _searchLink,
      child: SizedBox(
        width: 400,
        child: TextFormField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: _onSearchChanged,
          onFieldSubmitted: _onSearchChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(Iconsax.search_normal),
            hintText: 'Search anything...',
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Iconsax.close_circle, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                      setState(() {});
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  // ---- Notifications (orders) menu ----------------------------------------

  void _openOrders() {
    Get.toNamed(TRoutes.orders);
  }

  void _showNotifications() {
    final orders = _recentOrders.take(6).toList();
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<void>(
      context: context,
      color: TColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      position: RelativeRect.fromLTRB(
        overlay.size.width - 360,
        kToolbarHeight + 24,
        TSizes.md,
        0,
      ),
      constraints: const BoxConstraints(minWidth: 320, maxWidth: 340),
      items: [
        // Header
        PopupMenuItem<void>(
          enabled: false,
          height: 36,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Orders',
                style: TextStyle(
                  color: TColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: TSizes.fontSizeMd,
                ),
              ),
              if (_pendingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: TSizes.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: TColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_pendingCount pending',
                    style: const TextStyle(
                      color: TColors.primaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),

        // Empty state
        if (orders.isEmpty)
          const PopupMenuItem<void>(
            enabled: false,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: TSizes.sm),
              child: Text(
                'No new orders',
                style: TextStyle(color: TColors.textSecondary),
              ),
            ),
          )
        else
          ...orders.map(
            (o) => PopupMenuItem<void>(
              onTap: _openOrders,
              child: _buildOrderTile(o),
            ),
          ),

        const PopupMenuDivider(height: 1),

        // Footer action
        PopupMenuItem<void>(
          onTap: _openOrders,
          child: const Center(
            child: Text(
              'View all orders',
              style: TextStyle(
                color: TColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTile(Map<String, dynamic> o) {
    final email = _orderEmail(o);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _orderShortId(o),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: TColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: TSizes.sm),
            Text(
              _orderAmount(o),
              style: const TextStyle(
                color: TColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            _statusChip(_orderStatus(o)),
            if (email.isNotEmpty) ...[
              const SizedBox(width: TSizes.sm),
              Expanded(
                child: Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: TColors.lightContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: TColors.primaryDark,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Bell icon with a rose count badge.
  Widget _buildNotificationBell() {
    final count = _pendingCount > 0 ? _pendingCount : _orders.length;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Iconsax.notification),
          onPressed: _showNotifications,
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: TColors.white, width: 1),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TColors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Container(
      /// Background Color, Bottom Border
      decoration: const BoxDecoration(
        color: TColors.white,
        border:
            Border(bottom: BorderSide(color: TColors.borderPrimary, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: TSizes.md, vertical: TSizes.sm),
      child: TAppBar(
        /// Mobile Menu
        leadingIcon:
            !TDeviceUtils.isDesktopScreen(context) ? Iconsax.menu : null,
        leadingOnPressed: !TDeviceUtils.isDesktopScreen(context)
            ? () => widget.scaffoldKey.currentState?.openDrawer()
            : null,
        title: Row(
          children: [
            /// Search
            if (TDeviceUtils.isDesktopScreen(context)) _buildSearchField(),
          ],
        ),
        actions: [
          // Search Icon on Mobile
          if (!TDeviceUtils.isDesktopScreen(context))
            IconButton(
                icon: const Icon(Iconsax.search_normal),
                onPressed: () => _searchFocus.requestFocus()),

          // Notification Icon (with order count badge)
          _buildNotificationBell(),
          const SizedBox(width: TSizes.spaceBtwItems / 2),

          /// User Data
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// User Profile Image
              Obx(
                () => TRoundedImage(
                  width: 40,
                  padding: 2,
                  height: 40,
                  imageType: controller.user.value.profilePicture.isNotEmpty
                      ? ImageType.network
                      : ImageType.asset,
                  image: controller.user.value.profilePicture.isNotEmpty
                      ? controller.user.value.profilePicture
                      : TImages.user,
                ),
              ),

              const SizedBox(width: TSizes.sm),

              /// User Profile Data [Hide on Mobile]
              if (!TDeviceUtils.isMobileScreen(context))
                Obx(
                  () => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      controller.loading.value
                          ? const TShimmerEffect(width: 50, height: 13)
                          : Text(controller.user.value.fullName,
                              style: Theme.of(context).textTheme.titleLarge),
                      controller.loading.value
                          ? const TShimmerEffect(width: 70, height: 13)
                          : Text(controller.user.value.email,
                              style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
