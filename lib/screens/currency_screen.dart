import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../config/theme_colors.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';

class CurrencyScreen extends ConsumerStatefulWidget {
  const CurrencyScreen({super.key});

  @override
  ConsumerState<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends ConsumerState<CurrencyScreen> {
  String _query = '';

  final _currencies = [
    ('USD', 'US Dollar', '\$', '🇺🇸'),
    ('EUR', 'Euro', '€', '🇪🇺'),
    ('GBP', 'British Pound', '£', '🇬🇧'),
    ('CAD', 'Canadian Dollar', 'CA\$', '🇨🇦'),
    ('AUD', 'Australian Dollar', 'A\$', '🇦🇺'),
    ('JPY', 'Japanese Yen', '¥', '🇯🇵'),
    ('CHF', 'Swiss Franc', 'Fr', '🇨🇭'),
    ('CNY', 'Chinese Yuan', '¥', '🇨🇳'),
    ('INR', 'Indian Rupee', '₹', '🇮🇳'),
    ('MXN', 'Mexican Peso', '\$', '🇲🇽'),
    ('BRL', 'Brazilian Real', 'R\$', '🇧🇷'),
    ('KRW', 'South Korean Won', '₩', '🇰🇷'),
    ('SGD', 'Singapore Dollar', 'S\$', '🇸🇬'),
    ('NZD', 'New Zealand Dollar', 'NZ\$', '🇳🇿'),
    ('NOK', 'Norwegian Krone', 'kr', '🇳🇴'),
    ('SEK', 'Swedish Krona', 'kr', '🇸🇪'),
    ('DKK', 'Danish Krone', 'kr', '🇩🇰'),
    ('HKD', 'Hong Kong Dollar', 'HK\$', '🇭🇰'),
    ('ZAR', 'South African Rand', 'R', '🇿🇦'),
    ('AED', 'UAE Dirham', 'د.إ', '🇦🇪'),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final primary = Theme.of(context).primaryColor;
    final c = WealthColors.of(context);
    final current = settings.currency;

    final filtered = _query.isEmpty
        ? _currencies
        : _currencies
            .where((c) =>
                c.$1.toLowerCase().contains(_query.toLowerCase()) ||
                c.$2.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('Currency'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: TextStyle(color: c.textPrimary),
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search currencies...',
                prefixIcon: Icon(Icons.search_rounded,
                    color: c.textSecondary, size: 20),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final (code, name, symbol, flag) = filtered[i];
                final isSelected = code == current;
                return GestureDetector(
                  onTap: () async {
                    await ref
                        .read(settingsProvider.notifier)
                        .setCurrency(code);
                    final profile =
                        ref.read(profileProvider).valueOrNull;
                    if (profile != null) {
                      await ref
                          .read(profileProvider.notifier)
                          .update(profile.copyWith(currency: code));
                    }
                    if (context.mounted) context.pop();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primary.withValues(alpha: 0.1)
                          : c.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? primary : c.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(flag, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                code,
                                style: TextStyle(
                                  color: isSelected ? primary : c.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$name • $symbol',
                                style: GoogleFonts.manrope(
                                  color: c.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded,
                              color: primary, size: 22),
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
}
