import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  late final TextEditingController _rateCtrl;
  late String _category;
  late DateTime _dateAdded;
  bool _hasInterest = false;
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
    _rateCtrl = TextEditingController(
        text: l != null ? l.interestRate.toStringAsFixed(2) : '');
    _category = l?.category ?? 'credit';
    _dateAdded = l?.dateAdded ?? DateTime.now();
    _hasInterest = l != null && l.interestRate > 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    _paymentCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
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
        interestRate:
            _hasInterest ? (double.tryParse(_rateCtrl.text) ?? 0) : 0,
        dateAdded: _dateAdded,
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
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.credit_card_rounded,
                          color: AppColors.danger, size: 24),
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
                                color: c.textSecondary, fontSize: 12),
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
                              color: c.textSecondary, fontSize: 10),
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

              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: c.surface,
                style: TextStyle(color: c.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_rounded,
                      color: c.textSecondary, size: 20),
                ),
                items: Liability.categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(
                      Liability(
                              id: '',
                              userId: '',
                              name: '',
                              category: cat,
                              balance: 0,
                              monthlyPayment: 0,
                              interestRate: 0,
                              dateAdded: DateTime.now())
                          .categoryLabel,
                      style: TextStyle(color: WealthColors.of(context).textPrimary),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _category = v!),
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

              // Interest rate toggle
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Has interest rate?',
                      style: GoogleFonts.manrope(
                          color: c.textPrimary, fontSize: 14),
                    ),
                  ),
                  Switch(
                    value: _hasInterest,
                    onChanged: (v) => setState(() => _hasInterest = v),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),

              if (_hasInterest) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _rateCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: c.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Interest Rate (%)',
                    prefixIcon: Icon(Icons.percent_rounded,
                        color: c.textSecondary, size: 20),
                  ),
                ),
              ],

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
                          color: AppColors.danger, fontSize: 13)),
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
