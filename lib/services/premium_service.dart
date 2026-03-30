import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

class PremiumFeature {
  static const chartTabs = 'chart_tabs';
  static const customIcons = 'custom_icons';
  static const pinLock = 'pin_lock';
  static const export_ = 'export';
  static const currencies = 'currencies';
  static const avatars = 'avatars';
  static const themes = 'themes';

  static const coinCosts = {
    chartTabs: 30,
    customIcons: 20,
    pinLock: 25,
    export_: 30,
    currencies: 20,
    avatars: 20,
    themes: 15,
  };

  static const featureNames = {
    chartTabs: 'Chart Time Ranges',
    customIcons: 'Custom Icons',
    pinLock: 'PIN Lock Security',
    export_: 'Export Data',
    currencies: 'All Currencies',
    avatars: 'Premium Avatars',
    themes: 'App Themes',
  };

  static const featureDescriptions = {
    chartTabs: 'View your net worth over 1M, 6M, and 12M time periods',
    customIcons: 'Pick custom icons for your assets and liabilities',
    pinLock: 'Secure your app with a PIN code',
    export_: 'Export your data as CSV files',
    currencies: 'Track wealth in any of 20 global currencies',
    avatars: 'Use billionaire avatars beyond Elon Musk',
    themes: 'Unlock Light and Neon app themes',
  };

  static const Map<String, IconData> featureIcons = {
    chartTabs: Icons.show_chart_rounded,
    customIcons: Icons.palette_rounded,
    pinLock: Icons.lock_rounded,
    export_: Icons.download_rounded,
    currencies: Icons.currency_exchange_rounded,
    avatars: Icons.face_rounded,
    themes: Icons.color_lens_rounded,
  };
}

/// Returns true if the current user can access the given feature.
final premiumAccessProvider = Provider.family<bool, String>((ref, featureKey) {
  final profile = ref.watch(profileProvider).valueOrNull;
  if (profile == null) return false;
  return profile.isPremium || profile.unlockedFeatures.contains(featureKey);
});
