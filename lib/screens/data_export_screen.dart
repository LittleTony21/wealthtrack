import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../providers/assets_provider.dart';
import '../providers/liabilities_provider.dart';

class DataExportScreen extends ConsumerWidget {
  const DataExportScreen({super.key});

  String _assetsCSV(List assets) {
    final sb = StringBuffer();
    sb.writeln('Name,Category,Price,Purchase Date,Lifespan Years,Current Value');
    for (final a in assets) {
      sb.writeln(
          '${a.name},${a.category},${a.price},${a.purchaseDate.toIso8601String().split('T').first},${a.lifespanYears},${a.currentValue.toStringAsFixed(2)}');
    }
    return sb.toString();
  }

  String _liabilitiesCSV(List liabilities) {
    final sb = StringBuffer();
    sb.writeln(
        'Name,Category,Balance,Monthly Payment,Interest Rate,Date Added');
    for (final l in liabilities) {
      sb.writeln(
          '${l.name},${l.category},${l.balance},${l.monthlyPayment},${l.interestRate},${l.dateAdded.toIso8601String().split('T').first}');
    }
    return sb.toString();
  }

  void _showCopied(BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Export Data',
            style: TextStyle(color: Colors.white)),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Text(
              data,
              style: const TextStyle(
                  color: AppColors.greyText,
                  fontSize: 11,
                  fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetsProvider);
    final liabsAsync = ref.watch(liabilitiesProvider);
    final primary = Theme.of(context).primaryColor;

    final assets = assetsAsync.valueOrNull ?? [];
    final liabilities = liabsAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Data Export'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export your data as CSV',
              style: GoogleFonts.manrope(
                  color: AppColors.greyText, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _ExportCard(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Export Assets',
              subtitle: '${assets.length} asset${assets.length == 1 ? '' : 's'} tracked',
              color: primary,
              enabled: assets.isNotEmpty,
              onTap: () => _showCopied(context, _assetsCSV(assets)),
            ),
            const SizedBox(height: 12),
            _ExportCard(
              icon: Icons.credit_card_rounded,
              title: 'Export Liabilities',
              subtitle:
                  '${liabilities.length} liabilit${liabilities.length == 1 ? 'y' : 'ies'} tracked',
              color: AppColors.danger,
              enabled: liabilities.isNotEmpty,
              onTap: () => _showCopied(context, _liabilitiesCSV(liabilities)),
            ),
            const SizedBox(height: 12),
            _ExportCard(
              icon: Icons.download_rounded,
              title: 'Export All',
              subtitle: 'Assets + Liabilities combined',
              color: const Color(0xFFFFB340),
              enabled: assets.isNotEmpty || liabilities.isNotEmpty,
              onTap: () => _showCopied(
                context,
                'ASSETS\n${_assetsCSV(assets)}\n\nLIABILITIES\n${_liabilitiesCSV(liabilities)}',
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_rounded, color: primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Data will be shown as CSV text. Copy and paste into a spreadsheet.',
                      style: GoogleFonts.manrope(
                          color: AppColors.greyText, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ExportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceHighlight),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.greyText, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: enabled ? Colors.white : AppColors.greyText,
                  size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
