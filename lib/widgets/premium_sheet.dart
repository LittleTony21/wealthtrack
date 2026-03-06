import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme_colors.dart';
import '../providers/profile_provider.dart';
import '../services/premium_service.dart';

void showPremiumSheet(BuildContext context, {String? featureKey}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PremiumSheet(featureKey: featureKey),
  );
}

class _PremiumSheet extends ConsumerStatefulWidget {
  final String? featureKey;
  const _PremiumSheet({this.featureKey});

  @override
  ConsumerState<_PremiumSheet> createState() => _PremiumSheetState();
}

class _PremiumSheetState extends ConsumerState<_PremiumSheet> {
  bool _unlocking = false;

  Future<void> _unlockWithCoins(String featureKey, int cost) async {
    setState(() => _unlocking = true);
    try {
      await ref
          .read(profileProvider.notifier)
          .unlockFeatureWithCoins(featureKey, cost);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _unlocking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final c = WealthColors.of(context);
    final profile = ref.watch(profileProvider).valueOrNull;
    final coins = profile?.coins ?? 0;
    final key = widget.featureKey;

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 32),
      child: key != null
          ? _buildSingleFeature(context, key, c, primary, coins)
          : _buildAllFeatures(context, c, primary, coins),
    );
  }

  Widget _buildHandle(WealthColors c) => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: c.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _buildUpgradeButton(BuildContext context, Color primary) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Premium purchase coming soon!')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB340),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium_rounded, size: 18),
            const SizedBox(width: 8),
            Text(
              'Upgrade to Premium',
              style: GoogleFonts.manrope(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllFeatures(
      BuildContext context, WealthColors c, Color primary, int coins) {
    const features = [
      PremiumFeature.chartTabs,
      PremiumFeature.customIcons,
      PremiumFeature.pinLock,
      PremiumFeature.export_,
      PremiumFeature.currencies,
      PremiumFeature.avatars,
      PremiumFeature.themes,
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(c),
          const SizedBox(height: 20),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB340).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: Color(0xFFFFB340), size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            'Go Premium',
            style: GoogleFonts.manrope(
                color: c.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'One-time purchase. Unlock everything forever.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
                color: c.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          ...features.map((f) {
            final icon = PremiumFeature.featureIcons[f]!;
            final name = PremiumFeature.featureNames[f]!;
            final desc = PremiumFeature.featureDescriptions[f]!;
            final cost = PremiumFeature.coinCosts[f]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: primary, size: 18),
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
                        Text(desc,
                            style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFFFB340).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on_rounded,
                            color: Color(0xFFFFB340), size: 12),
                        const SizedBox(width: 3),
                        Text('$cost',
                            style: const TextStyle(
                                color: Color(0xFFFFB340),
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on_rounded,
                  color: Color(0xFFFFB340), size: 14),
              const SizedBox(width: 4),
              Text('You have $coins coins',
                  style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          _buildUpgradeButton(context, primary),
        ],
      ),
    );
  }

  Widget _buildSingleFeature(BuildContext context, String featureKey,
      WealthColors c, Color primary, int coins) {
    final icon = PremiumFeature.featureIcons[featureKey]!;
    final name = PremiumFeature.featureNames[featureKey]!;
    final desc = PremiumFeature.featureDescriptions[featureKey]!;
    final cost = PremiumFeature.coinCosts[featureKey]!;
    final hasEnough = coins >= cost;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHandle(c),
        const SizedBox(height: 20),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primary, size: 28),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: GoogleFonts.manrope(
              color: c.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
              color: c.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasEnough && !_unlocking
                ? () => _unlockWithCoins(featureKey, cost)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasEnough ? primary : null,
              foregroundColor: hasEnough ? Colors.white : null,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _unlocking
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: primary),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        hasEnough
                            ? 'Unlock for $cost coins'
                            : 'Need $cost coins (you have $coins)',
                        style: GoogleFonts.manrope(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
          ),
        ),
        if (!hasEnough) ...[
          const SizedBox(height: 8),
          Text(
            'Check in daily to earn more coins.',
            style: TextStyle(
                color: c.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: c.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('or',
                  style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
            Expanded(child: Divider(color: c.border)),
          ],
        ),
        const SizedBox(height: 16),
        _buildUpgradeButton(context, primary),
      ],
    );
  }
}
