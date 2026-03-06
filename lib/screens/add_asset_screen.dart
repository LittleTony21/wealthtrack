import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../config/app_icons.dart';
import '../config/theme.dart';
import '../config/theme_colors.dart';
import '../models/asset.dart';
import '../providers/assets_provider.dart';
import '../providers/liabilities_provider.dart';
import '../providers/milestone_queue_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../services/premium_service.dart';
import '../widgets/premium_sheet.dart';

class AddAssetScreen extends ConsumerStatefulWidget {
  final Asset? existingAsset;

  const AddAssetScreen({super.key, this.existingAsset});

  @override
  ConsumerState<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends ConsumerState<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late String _category;
  late DateTime _purchaseDate;
  late int _lifespanYears;
  String? _selectedIconName;
  bool _loading = false;
  String? _error;

  bool get _isEdit => widget.existingAsset != null;

  @override
  void initState() {
    super.initState();
    final a = widget.existingAsset;
    _nameCtrl = TextEditingController(text: a?.name ?? '');
    _priceCtrl =
        TextEditingController(text: a != null ? a.price.toStringAsFixed(2) : '');
    _category = a?.category ?? 'electronics';
    _purchaseDate = a?.purchaseDate ?? DateTime.now();
    _lifespanYears = a?.lifespanYears ?? 3;
    _selectedIconName = a?.iconName;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  double get _previewPrice {
    return double.tryParse(_priceCtrl.text) ?? 0;
  }

  double get _dailyDep =>
      _previewPrice > 0 ? _previewPrice / (_lifespanYears * 365) : 0;

  IconData get _categoryDefaultIcon {
    switch (_category) {
      case 'electronics':
        return Icons.laptop_mac_rounded;
      case 'vehicle':
        return Icons.directions_car_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'furniture':
        return Icons.chair_rounded;
      case 'appliance':
        return Icons.kitchen_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  IconData get _previewIcon {
    if (_selectedIconName != null && iconNameMap.containsKey(_selectedIconName)) {
      return iconNameMap[_selectedIconName]!;
    }
    return _categoryDefaultIcon;
  }

  void _showCategoryPicker(BuildContext context, Color primary, WealthColors c) {
    final categories = [
      ('electronics', 'Electronics', Icons.laptop_mac_rounded),
      ('vehicle', 'Vehicle', Icons.directions_car_rounded),
      ('home', 'Home', Icons.home_rounded),
      ('furniture', 'Furniture', Icons.chair_rounded),
      ('appliance', 'Appliance', Icons.kitchen_rounded),
      ('other', 'Other', Icons.inventory_2_rounded),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category',
                style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...categories.map((cat) {
              final isSelected = _category == cat.$1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _category = cat.$1;
                    _selectedIconName = null;
                  });
                  Navigator.pop(ctx);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? primary.withValues(alpha: 0.1) : c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? primary : c.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(cat.$3,
                          color: isSelected ? primary : c.textSecondary,
                          size: 20),
                      const SizedBox(width: 12),
                      Text(cat.$2,
                          style: TextStyle(
                              color: isSelected ? primary : c.textPrimary,
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600)),
                      const Spacer(),
                      if (isSelected)
                        Icon(Icons.check_rounded, color: primary, size: 18),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showIconPicker(BuildContext context, Color primary, WealthColors c) {
    final icons = assetCategoryIcons[_category] ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Icon',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: icons.map((entry) {
                      final name = entry['name'] as String;
                      final icon = entry['icon'] as IconData;
                      final isSelected = _selectedIconName == name;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedIconName = name);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary.withValues(alpha: 0.15)
                                : c.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? primary : c.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Icon(icon, color: isSelected ? primary : c.textSecondary, size: 32),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double get _currentValue {
    if (_previewPrice <= 0) return 0;
    final days =
        DateTime.now().difference(_purchaseDate).inDays.toDouble();
    return (_previewPrice - _dailyDep * days).clamp(0, _previewPrice);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final asset = Asset(
        id: widget.existingAsset?.id ?? '',
        userId: userId,
        name: _nameCtrl.text.trim(),
        category: _category,
        price: double.parse(_priceCtrl.text),
        purchaseDate: _purchaseDate,
        lifespanYears: _lifespanYears,
        iconName: _selectedIconName,
      );

      if (_isEdit) {
        await ref.read(assetsProvider.notifier).update(asset);
      } else {
        await ref.read(assetsProvider.notifier).add(asset);
      }

      // Check milestones with updated counts (stream may not have fired yet)
      final profile = ref.read(profileProvider).valueOrNull;
      if (profile != null) {
        final currentAssets = ref.read(assetsProvider).valueOrNull ?? [];
        final liabs = ref.read(liabilitiesProvider).valueOrNull ?? [];
        final assetCount = currentAssets.length;
        final nw = currentAssets.fold(0.0, (s, a) => s + a.currentValue)
            - liabs.fold(0.0, (s, l) => s + l.balance);
        ref.read(profileProvider.notifier).checkAndAwardMilestones(
          netWorth: nw,
          assetCount: assetCount,
          liabilityCount: liabs.length,
          streak: profile.streak,
          isPremium: profile.isPremium,
          hasUnlockedFeature: profile.unlockedFeatures.isNotEmpty,
          coins: profile.coins,
        ).then((earned) {
          if (earned.isNotEmpty) {
            ref.read(milestoneQueueProvider.notifier).enqueue(earned);
          }
        });
      }

      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final primary = Theme.of(context).primaryColor;
    final c = WealthColors.of(context);
    final currency = settings.currency;

    String fmt(double v) {
      final symbols = {
        'USD': '\$', 'EUR': '€', 'GBP': '£', 'CAD': 'CA\$', 'AUD': 'A\$',
        'JPY': '¥', 'CHF': 'Fr', 'CNY': '¥', 'INR': '₹', 'MXN': 'MX\$',
        'BRL': 'R\$', 'KRW': '₩', 'SGD': 'S\$', 'NZD': 'NZ\$', 'NOK': 'kr',
        'SEK': 'kr', 'DKK': 'kr', 'HKD': 'HK\$', 'ZAR': 'R', 'AED': 'د.إ',
      };
      final sym = symbols[currency] ?? currency;
      return '$sym${NumberFormat('#,##0.00').format(v)}';
    }

    final hasIconAccess =
        ref.watch(premiumAccessProvider(PremiumFeature.customIcons));

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Asset' : 'Add Asset'),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_previewIcon, color: primary, size: 24),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              if (!hasIconAccess) {
                                showPremiumSheet(context,
                                    featureKey:
                                        PremiumFeature.customIcons);
                                return;
                              }
                              _showIconPicker(context, primary, c);
                            },
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: hasIconAccess
                                    ? primary
                                    : c.textSecondary,
                                shape: BoxShape.circle,
                                border: Border.all(color: c.card, width: 1.5),
                              ),
                              child: Icon(
                                hasIconAccess
                                    ? Icons.edit_rounded
                                    : Icons.lock_rounded,
                                color: Colors.white,
                                size: 9,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameCtrl.text.isEmpty ? 'Asset Name' : _nameCtrl.text,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'costs ${fmt(_dailyDep)}/day',
                            style: TextStyle(
                                color: c.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          fmt(_currentValue),
                          style: TextStyle(
                            color: primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'current value',
                          style: TextStyle(
                              color: c.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Name
              TextFormField(
                controller: _nameCtrl,
                style: TextStyle(color: c.textPrimary),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Asset Name',
                  prefixIcon: Icon(Icons.label_rounded,
                      color: c.textSecondary, size: 20),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter asset name' : null,
              ),

              const SizedBox(height: 16),

              // Category
              GestureDetector(
                onTap: () => _showCategoryPicker(context, primary, c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.category_rounded,
                          color: c.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        Asset(
                                id: '',
                                userId: '',
                                name: '',
                                category: _category,
                                price: 0,
                                purchaseDate: DateTime.now(),
                                lifespanYears: 1)
                            .categoryLabel,
                        style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded,
                          color: c.textSecondary, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: c.textPrimary),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Purchase Price',
                  prefixIcon: Icon(Icons.attach_money_rounded,
                      color: c.textSecondary, size: 20),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter price';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Purchase Date
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _purchaseDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: c.isLight
                            ? ColorScheme.light(primary: primary, surface: c.card)
                            : ColorScheme.dark(primary: primary, surface: c.card),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setState(() => _purchaseDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          color: c.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMM d, yyyy').format(_purchaseDate),
                        style: TextStyle(color: c.textPrimary),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded,
                          color: c.textSecondary, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Lifespan slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lifespan',
                      style: TextStyle(
                          color: c.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(
                    '$_lifespanYears ${_lifespanYears == 1 ? 'year' : 'years'}',
                    style: TextStyle(
                      color: primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: primary,
                  inactiveTrackColor: c.border,
                  thumbColor: primary,
                  overlayColor: primary.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: _lifespanYears.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (v) => setState(() => _lifespanYears = v.toInt()),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(
                          color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_isEdit ? 'Save Changes' : 'Save Asset'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
