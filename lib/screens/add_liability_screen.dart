import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../config/app_icons.dart';
import '../config/theme.dart';
import '../config/theme_colors.dart';
import '../models/liability.dart';
import '../providers/liabilities_provider.dart';
import '../providers/settings_provider.dart';

class AddLiabilityScreen extends ConsumerStatefulWidget {
  final Liability? existingLiability;

  const AddLiabilityScreen({super.key, this.existingLiability});

  @override
  ConsumerState<AddLiabilityScreen> createState() =>
      _AddLiabilityScreenState();
}

class _AddLiabilityScreenState extends ConsumerState<AddLiabilityScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _balanceCtrl;
  late final TextEditingController _paymentCtrl;
  late String _category;
  late DateTime _dateAdded;
  String? _selectedIconName;
  bool _loading = false;
  String? _error;

  bool get _isEdit => widget.existingLiability != null;

  @override
  void initState() {
    super.initState();
    final l = widget.existingLiability;
    _nameCtrl = TextEditingController(text: l?.name ?? '');
    _balanceCtrl = TextEditingController(
        text: l != null ? l.balance.toStringAsFixed(2) : '');
    _paymentCtrl = TextEditingController(
        text: l != null ? l.monthlyPayment.toStringAsFixed(2) : '');
    _category = l?.category ?? 'credit';
    _dateAdded = l?.dateAdded ?? DateTime.now();
    _selectedIconName = l?.iconName;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    _paymentCtrl.dispose();
    super.dispose();
  }

  IconData get _categoryDefaultIcon {
    switch (_category) {
      case 'mortgage':
        return Icons.home_work_rounded;
      case 'auto':
        return Icons.directions_car_rounded;
      case 'credit':
        return Icons.credit_card_rounded;
      case 'student':
        return Icons.school_rounded;
      case 'personal':
        return Icons.handshake_rounded;
      default:
        return Icons.account_balance_rounded;
    }
  }

  IconData get _previewIcon {
    if (_selectedIconName != null && iconNameMap.containsKey(_selectedIconName)) {
      return iconNameMap[_selectedIconName]!;
    }
    return _categoryDefaultIcon;
  }

  void _showCategoryPicker(BuildContext context, WealthColors c) {
    final categories = [
      ('mortgage', 'Mortgage', Icons.home_work_rounded),
      ('auto', 'Auto Loan', Icons.directions_car_rounded),
      ('credit', 'Credit Card', Icons.credit_card_rounded),
      ('student', 'Student Loan', Icons.school_rounded),
      ('personal', 'Personal Loan', Icons.handshake_rounded),
      ('other', 'Other', Icons.account_balance_rounded),
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
                    color: isSelected
                        ? AppColors.danger.withValues(alpha: 0.1)
                        : c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.danger : c.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(cat.$3,
                          color: isSelected
                              ? AppColors.danger
                              : c.textSecondary,
                          size: 20),
                      const SizedBox(width: 12),
                      Text(cat.$2,
                          style: TextStyle(
                              color: isSelected
                                  ? AppColors.danger
                                  : c.textPrimary,
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600)),
                      const Spacer(),
                      if (isSelected)
                        const Icon(Icons.check_rounded,
                            color: AppColors.danger, size: 18),
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

  void _showIconPicker(BuildContext context, WealthColors c) {
    final icons = liabilityCategoryIcons[_category] ?? [];
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
                                ? AppColors.danger.withValues(alpha: 0.15)
                                : c.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.danger : c.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Icon(icon,
                              color: isSelected ? AppColors.danger : c.textSecondary,
                              size: 32),
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

  double get _previewBalance => double.tryParse(_balanceCtrl.text) ?? 0;
  double get _previewPayment => double.tryParse(_paymentCtrl.text) ?? 0;
  double get _dailyPayment => _previewPayment / 30;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final liability = Liability(
        id: widget.existingLiability?.id ?? '',
        userId: userId,
        name: _nameCtrl.text.trim(),
        category: _category,
        balance: double.parse(_balanceCtrl.text),
        monthlyPayment: double.parse(_paymentCtrl.text),
        dateAdded: _dateAdded,
        iconName: _selectedIconName,
      );

      if (_isEdit) {
        await ref.read(liabilitiesProvider.notifier).update(liability);
      } else {
        await ref.read(liabilitiesProvider.notifier).add(liability);
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

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Liability' : 'Add Liability'),
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
                  color: AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_previewIcon,
                              color: AppColors.danger, size: 24),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showIconPicker(context, c),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                                border: Border.all(color: c.card, width: 1.5),
                              ),
                              child: const Icon(Icons.edit_rounded,
                                  color: Colors.white, size: 9),
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
                            _nameCtrl.text.isEmpty
                                ? 'Liability Name'
                                : _nameCtrl.text,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Repaying ${fmt(_dailyPayment)}/day',
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
                          fmt(_previewBalance),
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'balance',
                          style: TextStyle(
                              color: c.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _nameCtrl,
                style: TextStyle(color: c.textPrimary),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.label_rounded,
                      color: c.textSecondary, size: 20),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter name' : null,
              ),

              const SizedBox(height: 16),

              // Category
              GestureDetector(
                onTap: () => _showCategoryPicker(context, c),
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
                        Liability(
                                id: '',
                                userId: '',
                                name: '',
                                category: _category,
                                balance: 0,
                                monthlyPayment: 0,
                                dateAdded: DateTime.now())
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

              TextFormField(
                controller: _balanceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: c.textPrimary),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Current Balance',
                  prefixIcon: Icon(Icons.attach_money_rounded,
                      color: c.textSecondary, size: 20),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter balance';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _paymentCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: c.textPrimary),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Monthly Payment',
                  prefixIcon: Icon(Icons.calendar_month_rounded,
                      color: c.textSecondary, size: 20),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter monthly payment';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Date added
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dateAdded,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: c.isLight
                            ? ColorScheme.light(primary: AppColors.danger, surface: c.card)
                            : ColorScheme.dark(primary: AppColors.danger, surface: c.card),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setState(() => _dateAdded = picked);
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
                        DateFormat('MMM d, yyyy').format(_dateAdded),
                        style: TextStyle(color: c.textPrimary),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded,
                          color: c.textSecondary, size: 20),
                    ],
                  ),
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
                    backgroundColor: AppColors.primary,
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
                      : Text(_isEdit ? 'Save Changes' : 'Save Liability'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
