import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../config/theme_colors.dart';
import '../providers/assets_provider.dart';
import '../providers/liabilities_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/check_in_dialog.dart';
import '../widgets/milestone_dialog.dart';
import '../widgets/premium_sheet.dart';
import '../services/premium_service.dart';
import '../models/asset.dart';
import '../models/liability.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetsProvider);
    final liabsAsync = ref.watch(liabilitiesProvider);
    final profileAsync = ref.watch(profileProvider);
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

    final assets = assetsAsync.valueOrNull ?? [];
    final liabilities = liabsAsync.valueOrNull ?? [];

    final totalAssets =
        assets.fold(0.0, (sum, a) => sum + a.currentValue);
    final totalLiabilities =
        liabilities.fold(0.0, (sum, l) => sum + l.balance);
    final netWorth = totalAssets - totalLiabilities;

    final profileName = profileAsync.valueOrNull?.userName ?? 'User';

    void _checkMilestones() {
      final profile = ref.read(profileProvider).valueOrNull;
      if (profile == null) return;
      final a = ref.read(assetsProvider).valueOrNull ?? [];
      final l = ref.read(liabilitiesProvider).valueOrNull ?? [];
      final nw = a.fold(0.0, (s, x) => s + x.currentValue) -
          l.fold(0.0, (s, x) => s + x.balance);
      ref.read(profileProvider.notifier).checkAndAwardMilestones(
        netWorth: nw,
        assetCount: a.length,
        liabilityCount: l.length,
        streak: profile.streak,
        isPremium: profile.isPremium,
        hasUnlockedFeature: profile.unlockedFeatures.isNotEmpty,
        coins: profile.coins,
      ).then((earned) {
        if (earned.isEmpty || !context.mounted) return;
        for (final m in earned) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('🏆 ${m.name} earned! +${m.coinReward} coin${m.coinReward == 1 ? '' : 's'}'),
            duration: const Duration(seconds: 3),
          ));
        }
      });
    }

    ref.listen(assetsProvider, (_, next) {
      if (next.hasValue) _checkMilestones();
    });
    ref.listen(liabilitiesProvider, (_, next) {
      if (next.hasValue) _checkMilestones();
    });

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
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
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
                      color: c.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => showPremiumSheet(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        color: primary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => showMilestoneDialog(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.military_tech_rounded,
                        color: primary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const CheckInDialog(),
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: primary,
                        size: 18,
                      ),
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
                          color: c.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your Net Worth',
                      style: GoogleFonts.manrope(
                          color: c.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
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

                    if (assetsAsync.hasValue && liabsAsync.hasValue)
                      _NetWorthChart(
                        assets: assets,
                        liabilities: liabilities,
                        currency: currency,
                        netWorth: netWorth,
                      )
                    else
                      const SizedBox(height: 180),

                    const SizedBox(height: 24),

                    // Recent Activity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: GoogleFonts.manrope(
                            color: c.textPrimary,
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
    final c = WealthColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: c.glowShadow(),
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
            style: TextStyle(
                color: c.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
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

enum _ChartRange { oneMonth, sixMonths, twelveMonths, allTime }

typedef _ChartData = ({
  List<FlSpot> spots,
  DateTime rangeStart,
  int totalDays,
});

class _NetWorthChart extends ConsumerStatefulWidget {
  final List<Asset> assets;
  final List<Liability> liabilities;
  final String currency;
  final double netWorth;

  const _NetWorthChart({
    required this.assets,
    required this.liabilities,
    required this.currency,
    required this.netWorth,
  });

  @override
  ConsumerState<_NetWorthChart> createState() => _NetWorthChartState();
}

class _NetWorthChartState extends ConsumerState<_NetWorthChart> {
  _ChartRange _range = _ChartRange.oneMonth;

  String _fmtValue(double amount) {
    final symbols = {
      'USD': '\$', 'EUR': '€', 'GBP': '£', 'CAD': 'CA\$', 'AUD': 'A\$',
      'JPY': '¥', 'CHF': 'Fr', 'CNY': '¥', 'INR': '₹', 'MXN': 'MX\$',
      'BRL': 'R\$', 'KRW': '₩', 'SGD': 'S\$', 'NZD': 'NZ\$', 'NOK': 'kr',
      'SEK': 'kr', 'DKK': 'kr', 'HKD': 'HK\$', 'ZAR': 'R', 'AED': 'د.إ',
    };
    final sym = symbols[widget.currency] ?? widget.currency;
    final abs = amount.abs();
    if (abs >= 1000000) return '$sym${(amount / 1000000).toStringAsFixed(1)}M';
    if (abs >= 1000) return '$sym${(amount / 1000).toStringAsFixed(1)}K';
    return '$sym${amount.toStringAsFixed(0)}';
  }

  String _fmtDate(DateTime date, int totalDays) {
    if (totalDays >= 365) return DateFormat('MMM yy').format(date);
    return DateFormat('MMM d').format(date);
  }

  double _netWorthAt(DateTime t, DateTime now) {
    // Normalize to date-only (midnight) so that items whose dates carry a
    // time component (DateTime.now()) are not accidentally excluded from a
    // chart point that lands at midnight on the same calendar day.
    final tDay = DateTime(t.year, t.month, t.day);

    // Use each item's CURRENT value/balance (same numbers shown in the header)
    // filtered by whether the item existed on date t.  This keeps the Y-axis
    // values consistent with "Your Net Worth" throughout the chart.
    double assetValue = 0;
    for (final a in widget.assets) {
      final aDay = DateTime(
          a.purchaseDate.year, a.purchaseDate.month, a.purchaseDate.day);
      if (!aDay.isAfter(tDay)) {
        assetValue += a.currentValue;
      }
    }
    double liabilityValue = 0;
    for (final l in widget.liabilities) {
      final lDay = DateTime(
          l.dateAdded.year, l.dateAdded.month, l.dateAdded.day);
      if (!lDay.isAfter(tDay)) {
        liabilityValue += l.balance;
      }
    }
    return assetValue - liabilityValue;
  }

  _ChartData _buildChartData(_ChartRange range) {
    final now = DateTime.now();
    DateTime rangeStart;
    int pointCount;

    switch (range) {
      case _ChartRange.oneMonth:
        rangeStart = now.subtract(const Duration(days: 30));
        pointCount = 31;
      case _ChartRange.sixMonths:
        rangeStart = now.subtract(const Duration(days: 180));
        pointCount = 26;
      case _ChartRange.twelveMonths:
        rangeStart = now.subtract(const Duration(days: 365));
        pointCount = 25;
      case _ChartRange.allTime:
        final dates = [
          ...widget.assets.map((a) => a.purchaseDate),
          ...widget.liabilities.map((l) => l.dateAdded),
        ];
        if (dates.isEmpty) {
          rangeStart = now.subtract(const Duration(days: 30));
        } else {
          final earliest = dates.reduce((a, b) => a.isBefore(b) ? a : b);
          // Normalize to midnight — purchaseDate/dateAdded from Firestore may
          // carry a time component (e.g., 14:30) that makes now.difference()
          // truncate to 0 days when the earliest item was added today.
          rangeStart = DateTime(earliest.year, earliest.month, earliest.day);
        }
        final spanDays = now.difference(rangeStart).inDays;
        pointCount = (spanDays / 7).ceil().clamp(2, 52);
    }

    final totalDays = now.difference(rangeStart).inDays.clamp(1, 9999);
    final spots = <FlSpot>[];

    for (int i = 0; i < pointCount; i++) {
      // x = actual days from rangeStart → proportional to real time
      final dayOffset = (totalDays.toDouble() * i / (pointCount - 1)).round();
      final t = rangeStart.add(Duration(days: dayOffset));
      spots.add(FlSpot(dayOffset.toDouble(), _netWorthAt(t, now)));
    }

    return (spots: spots, rangeStart: rangeStart, totalDays: totalDays);
  }

  @override
  Widget build(BuildContext context) {
    final c = WealthColors.of(context);
    final primary = Theme.of(context).primaryColor;
    final hasChartAccess =
        ref.watch(premiumAccessProvider(PremiumFeature.chartTabs));
    final effectiveRange =
        hasChartAccess ? _range : _ChartRange.allTime;
    final data = _buildChartData(effectiveRange);
    final spots = data.spots;
    final rangeStart = data.rangeStart;
    final totalDays = data.totalDays;

    if (spots.length < 2) return const SizedBox();

    final firstVal = spots.first.y;
    final lastVal = spots.last.y;
    final change = lastVal - firstVal;
    final changePct = firstVal != 0 ? change / firstVal.abs() * 100 : 0.0;
    final isUp = change >= 0;
    final lineColor = isUp ? primary : AppColors.danger;

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final yRange = (maxY - minY).abs().clamp(1.0, double.infinity);
    final yPad = yRange * 0.2;

    final tabs = [
      ('1M', _ChartRange.oneMonth),
      ('6M', _ChartRange.sixMonths),
      ('12M', _ChartRange.twelveMonths),
      ('All', _ChartRange.allTime),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: c.glowShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + tabs row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Net Worth',
                  style: GoogleFonts.manrope(
                      color: c.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              Row(
                children: tabs.map((tab) {
                  final isAllTab = tab.$2 == _ChartRange.allTime;
                  final isLocked = !hasChartAccess && !isAllTab;
                  final isSelected = effectiveRange == tab.$2;
                  return GestureDetector(
                    onTap: () {
                      if (isLocked) {
                        showPremiumSheet(context,
                            featureKey: PremiumFeature.chartTabs);
                        return;
                      }
                      setState(() => _range = tab.$2);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? lineColor.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? lineColor : c.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLocked) ...[
                            Icon(Icons.lock_rounded,
                                size: 9,
                                color: c.textSecondary
                                    .withValues(alpha: 0.5)),
                            const SizedBox(width: 3),
                          ],
                          Text(tab.$1,
                              style: TextStyle(
                                  color: isLocked
                                      ? c.textSecondary
                                          .withValues(alpha: 0.5)
                                      : isSelected
                                          ? lineColor
                                          : c.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Change indicator
          Row(
            children: [
              Text(
                '${change >= 0 ? '+' : ''}${_fmtValue(change)}',
                style: GoogleFonts.manrope(
                    color: lineColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: lineColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${changePct >= 0 ? '+' : ''}${changePct.toStringAsFixed(1)}%',
                  style: TextStyle(
                      color: lineColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Chart
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: totalDays.toDouble(),
                minY: minY - yPad,
                maxY: maxY + yPad,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yRange / 3,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: c.border.withValues(alpha: 0.35),
                    strokeWidth: 1,
                    dashArray: [4, 6],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: totalDays / 2.0,
                      getTitlesWidget: (value, meta) {
                        final date = rangeStart
                            .add(Duration(days: value.toInt()));
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            _fmtDate(date, totalDays),
                            style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => c.surface,
                    tooltipBorder: BorderSide(color: c.border),
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) =>
                        touchedSpots.map((s) {
                      final date = rangeStart
                          .add(Duration(days: s.x.toInt()));
                      return LineTooltipItem(
                        '${_fmtDate(date, totalDays)}\n',
                        TextStyle(
                            color: c.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                        children: [
                          TextSpan(
                            text: _fmtValue(s.y),
                            style: TextStyle(
                                color: lineColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  getTouchedSpotIndicator: (barData, indicators) =>
                      indicators.map((i) {
                    return TouchedSpotIndicatorData(
                      FlLine(
                          color: lineColor.withValues(alpha: 0.4),
                          strokeWidth: 1.5,
                          dashArray: [4, 4]),
                      FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: lineColor,
                          strokeWidth: 2,
                          strokeColor: c.card,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    preventCurveOverShooting: true,
                    color: lineColor,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          lineColor.withValues(alpha: 0.2),
                          lineColor.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    final c = WealthColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
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
                    style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(
                  DateFormat('MMM d, yyyy').format(date),
                  style: TextStyle(
                      color: c.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
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
    final c = WealthColors.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded,
              color: c.textSecondary, size: 48),
          const SizedBox(height: 12),
          Text(
            'No activity yet',
            style: GoogleFonts.manrope(
              color: c.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first asset or liability to get started.',
            style: GoogleFonts.manrope(
              color: c.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

