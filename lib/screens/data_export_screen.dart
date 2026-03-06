import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/theme.dart';
import '../config/theme_colors.dart';
import '../providers/assets_provider.dart';
import '../providers/liabilities_provider.dart';
import '../services/premium_service.dart';
import '../widgets/premium_sheet.dart';

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

  Future<void> _exportFile(
      BuildContext context, String csv, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: filename,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetsProvider);
    final liabsAsync = ref.watch(liabilitiesProvider);
    final primary = Theme.of(context).primaryColor;
    final c = WealthColors.of(context);
    final hasExportAccess =
        ref.watch(premiumAccessProvider(PremiumFeature.export_));

    final assets = assetsAsync.valueOrNull ?? [];
    final liabilities = liabsAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('Data Export'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: hasExportAccess
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export your data as CSV',
                    style: GoogleFonts.manrope(
                        color: c.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  _ExportCard(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Export Assets',
                    subtitle:
                        '${assets.length} asset${assets.length == 1 ? '' : 's'} tracked',
                    color: primary,
                    enabled: assets.isNotEmpty,
                    onTap: () async => _exportFile(
                        context, _assetsCSV(assets), 'assets_export'),
                  ),
                  const SizedBox(height: 12),
                  _ExportCard(
                    icon: Icons.credit_card_rounded,
                    title: 'Export Liabilities',
                    subtitle:
                        '${liabilities.length} liabilit${liabilities.length == 1 ? 'y' : 'ies'} tracked',
                    color: AppColors.danger,
                    enabled: liabilities.isNotEmpty,
                    onTap: () async => _exportFile(context,
                        _liabilitiesCSV(liabilities), 'liabilities_export'),
                  ),
                  const SizedBox(height: 12),
                  _ExportCard(
                    icon: Icons.download_rounded,
                    title: 'Export All',
                    subtitle: 'Assets + Liabilities combined',
                    color: const Color(0xFFFFB340),
                    enabled: assets.isNotEmpty || liabilities.isNotEmpty,
                    onTap: () async => _exportFile(
                      context,
                      'ASSETS\n${_assetsCSV(assets)}\nLIABILITIES\n${_liabilitiesCSV(liabilities)}',
                      'wealthtrack_export',
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(Icons.lock_rounded, color: primary, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Export Data',
                      style: GoogleFonts.manrope(
                          color: c.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock to export your assets and\nliabilities as CSV files.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                          color: c.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => showPremiumSheet(context,
                          featureKey: PremiumFeature.export_),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Unlock Export',
                        style: GoogleFonts.manrope(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
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
    final c = WealthColors.of(context);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border),
            boxShadow: c.glowShadow(),
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
                        style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: TextStyle(
                            color: c.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: enabled ? c.textPrimary : c.textSecondary,
                  size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
