import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/assets_provider.dart';
import '../providers/liabilities_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/bottom_nav.dart';
import '../models/asset.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetsProvider);
    final liabsAsync = ref.watch(liabilitiesProvider);
    final profileAsync = ref.watch(profileProvider);
    final settings = ref.watch(settingsProvider);
    final primary = Theme.of(context).primaryColor;

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

    final assets = assetsAsync.valueOrNull ?? [];
    final liabilities = liabsAsync.valueOrNull ?? [];

    final totalAssets =
        assets.fold(0.0, (sum, a) => sum + a.currentValue);
    final totalLiabilities =
        liabilities.fold(0.0, (sum, l) => sum + l.balance);
    final netWorth = totalAssets - totalLiabilities;

    final profileName = profileAsync.valueOrNull?.userName ?? 'User';

    // Recent activity — last 3 of assets + liabilities combined
    final recentItems = <({String name, String type, String value, DateTime date})>[];
    for (final a in assets.take(3)) {
      recentItems.add((
        name: a.name,
        type: 'asset',
        value: fmt(a.currentValue),
        date: a.purchaseDate,
      ));
    }
    for (final l in liabilities.take(3)) {
      recentItems.add((
        name: l.name,
        type: 'liability',
        value: fmt(l.balance),
        date: l.dateAdded,
      ));
    }
    recentItems.sort((a, b) => b.date.compareTo(a.date));
    final recent = recentItems.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'WealthTrack',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push('/notifications'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceHighlight),
                      ),
                      child: const Icon(Icons.notifications_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Hello, $profileName 👋',
                      style: GoogleFonts.manrope(
                          color: AppColors.greyText, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your Net Worth',
                      style: GoogleFonts.manrope(
                          color: AppColors.greyText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmt(netWorth),
                      style: GoogleFonts.manrope(
                        color: netWorth >= 0 ? primary : AppColors.danger,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Asset + Liability cards
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Total Assets',
                            value: fmt(totalAssets),
                            icon: Icons.trending_up_rounded,
                            color: primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Total Liabilities',
                            value: fmt(totalLiabilities),
                            icon: Icons.trending_down_rounded,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Mini chart
                    if (assets.isNotEmpty)
                      _MiniChart(assets: assets, primary: primary),

                    const SizedBox(height: 24),

                    // Quick actions
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.add_circle_rounded,
                            label: 'Add Asset',
                            color: primary,
                            onTap: () => context.push('/add-asset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.add_circle_outline_rounded,
                            label: 'Add Debt',
                            color: AppColors.danger,
                            onTap: () => context.push('/add-liability'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Recent Activity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/assets'),
                          child: Text(
                            'See all',
                            style: GoogleFonts.manrope(
                              color: primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (assetsAsync.isLoading || liabsAsync.isLoading)
                      const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                    else if (recent.isEmpty)
                      _EmptyState()
                    else
                      ...recent.map((item) => _ActivityItem(
                            name: item.name,
                            type: item.type,
                            value: item.value,
                            date: item.date,
                            primary: primary,
                          )),
                  ],
                ),
              ),
            ),

            AppBottomNav(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
                color: AppColors.greyText, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String name;
  final String type;
  final String value;
  final DateTime date;
  final Color primary;

  const _ActivityItem({
    required this.name,
    required this.type,
    required this.value,
    required this.date,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isAsset = type == 'asset';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isAsset ? primary : AppColors.danger).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isAsset
                  ? Icons.account_balance_wallet_rounded
                  : Icons.credit_card_rounded,
              color: isAsset ? primary : AppColors.danger,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(
                  DateFormat('MMM d, yyyy').format(date),
                  style: const TextStyle(
                      color: AppColors.greyText, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isAsset ? primary : AppColors.danger,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded,
              color: AppColors.greyText, size: 48),
          const SizedBox(height: 12),
          Text(
            'No activity yet',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first asset or liability to get started.',
            style: GoogleFonts.manrope(
              color: AppColors.greyText,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MiniChart extends StatelessWidget {
  final List<Asset> assets;
  final Color primary;

  const _MiniChart({required this.assets, required this.primary});

  @override
  Widget build(BuildContext context) {
    // Build a simple line chart from asset purchase dates
    final sorted = [...assets]
      ..sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));

    // Accumulate total value over time
    double running = 0;
    final points = <double>[];
    for (final a in sorted) {
      running += a.currentValue;
      points.add(running);
    }

    if (points.length < 2) return const SizedBox();

    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHighlight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Growth',
            style: GoogleFonts.manrope(
              color: AppColors.greyText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              painter: _LinePainter(points: points, color: primary),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _LinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final minVal = points.reduce((a, b) => a < b ? a : b);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal).clamp(1.0, double.infinity);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < points.length; i++) {
      final x = i / (points.length - 1) * size.width;
      final y = size.height - ((points[i] - minVal) / range * size.height);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.points != points || old.color != color;
}
