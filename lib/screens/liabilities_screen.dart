import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../config/theme_colors.dart';
import '../providers/liabilities_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/liability_card.dart';

class LiabilitiesScreen extends ConsumerStatefulWidget {
  const LiabilitiesScreen({super.key});

  @override
  ConsumerState<LiabilitiesScreen> createState() =>
      _LiabilitiesScreenState();
}

class _LiabilitiesScreenState extends ConsumerState<LiabilitiesScreen> {
  String _filter = 'All';
  bool _showSearch = false;
  String _query = '';

  final _filters = [
    'All',
    'mortgage',
    'auto',
    'credit',
    'student',
    'personal',
    'other',
  ];

  String _label(String f) {
    switch (f) {
      case 'All':
        return 'All';
      case 'mortgage':
        return 'Mortgage';
      case 'auto':
        return 'Auto';
      case 'credit':
        return 'Credit';
      case 'student':
        return 'Student';
      case 'personal':
        return 'Personal';
      default:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final liabsAsync = ref.watch(liabilitiesProvider);
    final settings = ref.watch(settingsProvider);
    final c = WealthColors.of(context);
    final currency = settings.currency;

    String fmt(double amount) {
      final symbols = {
        'USD': '\$', 'EUR': '€', 'GBP': '£', 'CAD': 'CA\$', 'AUD': 'A\$',
        'JPY': '¥', 'CHF': 'Fr', 'CNY': '¥', 'INR': '₹', 'MXN': 'MX\$',
        'BRL': 'R\$', 'KRW': '₩', 'SGD': 'S\$', 'NZD': 'NZ\$', 'NOK': 'kr',
        'SEK': 'kr', 'DKK': 'kr', 'HKD': 'HK\$', 'ZAR': 'R', 'AED': 'د.إ',
      };
      final sym = symbols[currency] ?? currency;
      return '$sym${NumberFormat('#,##0.00').format(amount)}';
    }

    final allLiabs = liabsAsync.valueOrNull ?? [];
    var filtered = allLiabs;
    if (_filter != 'All') {
      filtered = filtered.where((l) => l.category == _filter).toList();
    }
    if (_query.isNotEmpty) {
      filtered = filtered
          .where((l) =>
              l.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }

    final totalBalance =
        allLiabs.fold(0.0, (sum, l) => sum + l.balance);
    final totalDailyPayment =
        allLiabs.fold(0.0, (sum, l) => sum + l.dailyPayment);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Liabilities',
                        style: GoogleFonts.manrope(
                          color: c.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showSearch = !_showSearch),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: c.border),
                          ),
                          child: Icon(
                            _showSearch
                                ? Icons.close_rounded
                                : Icons.search_rounded,
                            color: c.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Total Liabilities
                  Text(
                    'Total Liabilities',
                    style: GoogleFonts.manrope(
                        color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fmt(totalBalance),
                    style: GoogleFonts.manrope(
                      color: AppColors.danger,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Repaying per day
                  Text(
                    'Repaying / day',
                    style: GoogleFonts.manrope(
                        color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fmt(totalDailyPayment),
                    style: GoogleFonts.manrope(
                      color: AppColors.danger,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search bar
                  if (_showSearch) ...[
                    TextField(
                      style: TextStyle(color: c.textPrimary),
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Search liabilities...',
                        prefixIcon: Icon(Icons.search_rounded,
                            color: c.textSecondary, size: 20),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) {
                        final isSelected = _filter == f;
                        return GestureDetector(
                          onTap: () => setState(() => _filter = f),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.danger
                                  : c.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? null
                                  : Border.all(color: c.border),
                            ),
                            child: Text(
                              _label(f),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : c.textSecondary,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            Expanded(
              child: liabsAsync.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.danger))
                  : filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.credit_card_rounded,
                                    color: c.textSecondary, size: 56),
                                const SizedBox(height: 16),
                                Text(
                                  'No debts tracked',
                                  style: GoogleFonts.manrope(
                                    color: c.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap + to add a loan or debt.',
                                  style: GoogleFonts.manrope(
                                      color: c.textSecondary,
                                      fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(24, 16, 24, 24),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => LiabilityCard(
                            liability: filtered[i],
                            currency: currency,
                            onDelete: () => ref
                                .read(liabilitiesProvider.notifier)
                                .delete(filtered[i].id),
                          ),
                        ),
            ),

            AppBottomNav(currentIndex: 2),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton(
          onPressed: () => context.push('/add-liability'),
          backgroundColor: AppColors.danger,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
