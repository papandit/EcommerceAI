import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../common/widgets/containers/rounded_container.dart';
import '../../../../common/widgets/layouts/templates/site_layout.dart';
import '../../../../data/repositories/credits/credit_request_model.dart';
import '../../../../data/repositories/credits/credit_user_model.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/credit_controller.dart';

/// Admin "Try-On Credits" hub: pool costing, shopper credit requests,
/// per-user distribution (add / set / deduct) and try-on model curation.
///
/// Wrapped in [TSiteTemplate] so it gets the standard admin chrome (sidebar +
/// header) like every other screen.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
      desktop: CreditsBody(),
      tablet: CreditsBody(),
      mobile: CreditsBody(),
    );
  }
}

class CreditsBody extends StatefulWidget {
  const CreditsBody({super.key});

  @override
  State<CreditsBody> createState() => _CreditsBodyState();
}

class _CreditsBodyState extends State<CreditsBody> {
  late final CreditController c;
  final _bulkAmount = TextEditingController(text: '10');
  final _search = TextEditingController();
  final _poolTotal = TextEditingController();
  final _poolCost = TextEditingController();
  Worker? _poolSync;

  @override
  void initState() {
    super.initState();
    c = Get.isRegistered<CreditController>()
        ? CreditController.instance
        : Get.put(CreditController());
    c.loadAll();
    // Pre-fill the pool inputs once the summary lands (and whenever it changes),
    // but never clobber what the admin is currently typing.
    _poolSync = ever<int>(c.purchased, (_) {
      if (!mounted) return;
      if (_poolTotal.text.isEmpty) _poolTotal.text = '${c.purchased.value}';
      if (_poolCost.text.isEmpty && c.costPerCredit.value > 0) {
        _poolCost.text = c.costPerCredit.value.toString();
      }
    });
  }

  @override
  void dispose() {
    _poolSync?.dispose();
    _bulkAmount.dispose();
    _search.dispose();
    _poolTotal.dispose();
    _poolCost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TBreadcrumbsWithHeading(
                heading: 'Try-On Credits', breadcrumbItems: ['Credits']),
            const SizedBox(height: TSizes.spaceBtwSections),
            _summary(),
            const SizedBox(height: TSizes.spaceBtwSections),
            _bulkDistribute(),
            const SizedBox(height: TSizes.spaceBtwSections),
            _requestsInbox(),
            const SizedBox(height: TSizes.spaceBtwSections),
            _usersTable(),
            const SizedBox(height: TSizes.spaceBtwSections),
            _modelCuration(),
          ],
        ),
      ),
    );
  }

  // ---- Costing summary ---------------------------------------------------

  Widget _summary() {
    return Obx(() {
      final cur = c.currency.value;
      return TRoundedContainer(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Iconsax.wallet_3, size: 20),
                const SizedBox(width: 8),
                Text('Credit pool',
                    style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: c.loadAll,
                  icon: const Icon(Iconsax.refresh, size: 18),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Wrap(
              spacing: 28,
              runSpacing: 16,
              children: [
                _stat('Key credits', '${c.purchased.value}'),
                _stat('Consumed', '${c.consumed.value}'),
                _stat('Remaining', '${c.remaining.value}',
                    danger: c.remaining.value < 0),
                _stat('Spent (est.)',
                    '$cur ${c.estConsumedCost.value.toStringAsFixed(2)}'),
                _stat('Pool value left',
                    '$cur ${c.estRemainingValue.value.toStringAsFixed(2)}'),
              ],
            ),
            if (c.remaining.value < 0) ...[
              const SizedBox(height: 10),
              Text(
                'Remaining is negative because the pool total is lower than what '
                'has been used. Enter the credits your BrandShoot key actually '
                'carries below.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.red),
              ),
            ],
            const Divider(height: 28),
            // Distribution across shoppers.
            Wrap(
              spacing: 28,
              runSpacing: 16,
              children: [
                _stat('Users', '${c.totalUsers.value}'),
                _stat('Held by users', '${c.allocated.value}'),
                _stat('Avg / user', c.avgPerUser.value.toStringAsFixed(1)),
                _stat('Used by users', '${c.usedTotal.value}'),
                _stat('Held value',
                    '$cur ${c.estAllocatedCost.value.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(height: 28),
            _poolEditor(cur),
          ],
        ),
      );
    });
  }

  /// Enter the credits the BrandShoot key carries + the price per credit, so
  /// every figure above (and per-user cost) is computed from real numbers.
  Widget _poolEditor(String cur) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Key balance & pricing',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          'Enter the credits included with your BrandShoot API key (e.g. 10000) '
          'and what you paid per credit.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 170,
              child: TextField(
                controller: _poolTotal,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Key credits', isDense: true),
              ),
            ),
            SizedBox(
              width: 170,
              child: TextField(
                controller: _poolCost,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                    labelText: 'Cost / credit ($cur)', isDense: true),
              ),
            ),
            Obx(() => ElevatedButton.icon(
                  onPressed: c.savingPool.value ? null : _savePool,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18)),
                  icon: const Icon(Iconsax.save_2, size: 16),
                  label: const Text('Save pool',
                      softWrap: false, overflow: TextOverflow.visible),
                )),
          ],
        ),
      ],
    );
  }

  void _savePool() {
    final total = int.tryParse(_poolTotal.text.trim());
    final cost = double.tryParse(_poolCost.text.trim());
    if (total == null && cost == null) return;
    c.savePool(purchasedCredits: total, costPerCredit: cost);
  }

  Widget _stat(String label, String value, {bool danger = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: danger ? Colors.red : null, fontWeight: FontWeight.w700)),
      ],
    );
  }

  // ---- Bulk distribution -------------------------------------------------

  Widget _bulkDistribute() {
    return TRoundedContainer(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distribute credits',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Give credits to every shopper at once. New signups already receive '
            'the free amount set in Settings.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 130,
                child: TextField(
                  controller: _bulkAmount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Amount', isDense: true),
                ),
              ),
              // Intrinsic width + no-wrap label, so the text is never clipped.
              Obx(() => ElevatedButton.icon(
                    onPressed: c.adjusting.value ? null : () => _bulk(false),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18)),
                    icon: const Icon(Iconsax.people, size: 16),
                    label: const Text('Give to everyone',
                        softWrap: false, overflow: TextOverflow.visible),
                  )),
              Obx(() => OutlinedButton.icon(
                    onPressed: c.adjusting.value ? null : () => _bulk(true),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18)),
                    icon: const Icon(Iconsax.user_add, size: 16),
                    label: const Text('Only users with none',
                        softWrap: false, overflow: TextOverflow.visible),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  void _bulk(bool onlyUngranted) {
    final n = int.tryParse(_bulkAmount.text.trim()) ?? 0;
    if (n <= 0) return;
    c.grantAll(n, onlyUngranted: onlyUngranted);
  }

  // ---- Requests inbox ----------------------------------------------------

  Widget _requestsInbox() {
    return TRoundedContainer(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Row(
                children: [
                  const Icon(Iconsax.sms, size: 20),
                  const SizedBox(width: 8),
                  Text('Credit requests',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(width: 10),
                  if (c.pendingCount.value > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(999)),
                      child: Text('${c.pendingCount.value} new',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: c.requestFilter.value,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(
                          value: 'approved', child: Text('Approved')),
                      DropdownMenuItem(
                          value: 'rejected', child: Text('Rejected')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      c.requestFilter.value = v;
                      c.fetchRequests();
                    },
                  ),
                ],
              )),
          const SizedBox(height: TSizes.spaceBtwItems),
          Obx(() {
            if (c.requestsLoading.value) {
              return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()));
            }
            if (c.requests.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('No credit requests yet.',
                    style: Theme.of(context).textTheme.bodySmall),
              );
            }
            return Column(
              children: c.requests.map(_requestRow).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _requestRow(CreditRequestModel r) {
    final color = r.status == 'pending'
        ? Colors.orange
        : (r.status == 'approved' ? Colors.green : Colors.red);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: TColors.borderPrimary),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.userName.isEmpty ? r.userEmail : r.userName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(r.userEmail,
                    style: Theme.of(context).textTheme.bodySmall),
                if (r.message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('"${r.message}"',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('asked for ${r.amount}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999)),
                child: Text(r.status,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(width: 8),
          if (r.isPending) ...[
            IconButton(
              tooltip: 'Approve & grant',
              onPressed: () =>
                  c.handleRequest(r.id, action: 'approve', amount: r.amount),
              icon: const Icon(Iconsax.tick_circle,
                  color: Colors.green, size: 20),
            ),
            IconButton(
              tooltip: 'Reject',
              onPressed: () => c.handleRequest(r.id, action: 'reject'),
              icon: const Icon(Iconsax.close_circle,
                  color: Colors.red, size: 20),
            ),
          ],
          IconButton(
            tooltip: 'Delete',
            onPressed: () => c.deleteRequest(r.id),
            icon: const Icon(Iconsax.trash, size: 18),
          ),
        ],
      ),
    );
  }

  // ---- Users / distribution table ---------------------------------------

  Widget _usersTable() {
    return TRoundedContainer(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.profile_2user, size: 20),
              const SizedBox(width: 8),
              Text('Credits per user',
                  style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              SizedBox(
                width: 240,
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Search name or email',
                    prefixIcon: Icon(Iconsax.search_normal, size: 16),
                  ),
                  onSubmitted: (v) {
                    c.userSearch.value = v.trim();
                    c.fetchUsers();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Obx(() {
            if (c.usersLoading.value) {
              return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()));
            }
            if (c.users.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('No users found.',
                    style: Theme.of(context).textTheme.bodySmall),
              );
            }
            return Column(children: c.users.map(_userRow).toList());
          }),
        ],
      ),
    );
  }

  Widget _userRow(CreditUserModel u) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: TColors.borderPrimary),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(u.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Obx(() {
              final cost = u.consumedTotal * c.costPerCredit.value;
              return Text(
                'Granted ${u.grantedTotal} · Used ${u.consumedTotal}'
                '${c.costPerCredit.value > 0 ? ' · ${c.currency.value} ${cost.toStringAsFixed(2)}' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              );
            }),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
                color: (u.tryonCredits > 0 ? Colors.green : Colors.red)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999)),
            child: Text('${u.tryonCredits}',
                style: TextStyle(
                    color: u.tryonCredits > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Add credits',
            onPressed: () => _editDialog(u, 'add'),
            icon: const Icon(Iconsax.add_circle, size: 20),
          ),
          IconButton(
            tooltip: 'Set exact balance',
            onPressed: () => _editDialog(u, 'set'),
            icon: const Icon(Iconsax.edit, size: 18),
          ),
          IconButton(
            tooltip: 'Remove credits',
            onPressed: () => _editDialog(u, 'deduct'),
            icon: const Icon(Iconsax.minus_cirlce,
                size: 20, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _editDialog(CreditUserModel u, String op) {
    final amount = TextEditingController(text: op == 'set' ? '${u.tryonCredits}' : '10');
    final reason = TextEditingController();
    final title = op == 'add'
        ? 'Add credits'
        : (op == 'set' ? 'Set balance' : 'Remove credits');
    Get.dialog(
      AlertDialog(
        title: Text('$title — ${u.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reason,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final n = int.tryParse(amount.text.trim()) ?? -1;
              if (n < 0) return;
              Get.back();
              c.adjustUser(u.id, op: op, amount: n, reason: reason.text.trim());
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  // ---- Try-on model curation --------------------------------------------

  Widget _modelCuration() {
    return TRoundedContainer(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.user_square, size: 20),
              const SizedBox(width: 8),
              Text('Try-on models',
                  style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              Obx(() => ElevatedButton.icon(
                    onPressed: c.savingModels.value ? null : c.saveModels,
                    icon: const Icon(Iconsax.save_2, size: 16),
                    label: const Text('Publish selection'),
                  )),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Pick which BrandShoot models shoppers can try clothes on. '
            'Select none to fall back to the default women-only list.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Obx(() {
            if (c.modelsLoading.value) {
              return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()));
            }
            if (c.brandshootModels.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                    'No models available — check the BrandShoot key in Settings.',
                    style: Theme.of(context).textTheme.bodySmall),
              );
            }
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: c.brandshootModels.map(_modelTile).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _modelTile(Map<String, dynamic> m) {
    final id = (m['id'] ?? '').toString();
    final name = (m['name'] ?? 'Model').toString();
    final img = (m['imageFullUrl'] ?? '').toString();
    return Obx(() {
      final on = c.enabledModelIds.contains(id);
      return InkWell(
        onTap: () => c.toggleModel(id),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 132,
          decoration: BoxDecoration(
            border: Border.all(
                color: on ? TColors.primary : TColors.borderPrimary,
                width: on ? 2 : 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(9)),
                    child: img.isEmpty
                        ? Container(
                            height: 150,
                            width: 132,
                            color: Colors.black12,
                            child: const Icon(Iconsax.user))
                        : Image.network(img,
                            height: 150,
                            width: 132,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                height: 150,
                                width: 132,
                                color: Colors.black12,
                                child: const Icon(Iconsax.user))),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      decoration: BoxDecoration(
                          color: on ? TColors.primary : Colors.white,
                          shape: BoxShape.circle),
                      padding: const EdgeInsets.all(3),
                      child: Icon(on ? Icons.check : Icons.add,
                          size: 14,
                          color: on ? Colors.white : Colors.black54),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    });
  }
}
