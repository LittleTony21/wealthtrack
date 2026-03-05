import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../config/theme_colors.dart';
import '../providers/assets_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/asset_card.dart';

class AssetsScreen extends ConsumerStatefulWidget {
  const AssetsScreen({super.key});

  @override
  ConsumerState<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends ConsumerState<AssetsScreen> {
  String _filter = 'All';
  bool _showSearch = false;
  String _query = '';

  final _filters = [
    'All',
    'electronics',
    'vehicle',
    'home',
    'furniture',
    'appliance',
    'other',
  ];

  String _label(String f) {
    switch (f) {
      case 'All':
        return 'All';
      case 'electronics':
        return 'Tech';
      case 'vehicle':
        return 'Vehicle';
      case 'home':
        return 'Home';
      case 'furniture':
        return 'Furniture';
      case 'appliance':
        return 'Appliance';
      default:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(assetsProvider);
    final settings = ref.watch(settingsProvider);
    final primary = Theme.of(context).primaryColor;
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

    final allAssets = assetsAsync.valueOrNull ?? [];
    var filtered = allAssets;
    if (_filter != 'All') {
      filtered = filtered.where((a) => a.category == _filter).toList();
    }
    if (_query.isNotEmpty) {
      filtered = filtered
          .where((a) =>
              a.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }

    final totalValue =
        allAssets.fold(0.0, (sum, a) => sum + a.currentValue);

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
                        'My Assets',
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

                  // Total value (large, primary color)
                  Text(
                    'Total Assets',
                    style: GoogleFonts.manrope(
                        color: c.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fmt(totalValue),
                    style: GoogleFonts.manrope(
                      color: primary,
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
                        hintText: 'Search assets...',
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
                                  ? primary
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
                                    ? FontWeight.w600
                                    : FontWeight.w400,
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
              child: assetsAsync.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: primary))
                  : filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.account_balance_wallet_rounded,
                                    color: c.textSecondary, size: 56),
                                const SizedBox(height: 16),
                                Text(
                                  'No assets yet',
                                  style: GoogleFonts.manrope(
                                    color: c.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap + to add your first asset.',
                                  style: GoogleFonts.manrope(
                                      color: c.textSecondary,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(24, 16, 24, 24),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => AssetCard(
                            asset: filtered[i],
                            currency: currency,
                            onDelete: () => ref
                                .read(assetsProvider.notifier)
                                .delete(filtered[i].id),
                          ),
                        ),
            ),

            AppBottomNav(currentIndex: 1),
          ],
        ),
      ),
      // FAB matching design
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton(
          onPressed: () => context.push('/add-asset'),
          backgroundColor: primary,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
