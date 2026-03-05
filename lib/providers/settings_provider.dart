import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_provider.dart';

class AppSettings {
  final String theme;
  final String currency;
  final String accentColor;

  const AppSettings({
    this.theme = 'dark',
    this.currency = 'USD',
    this.accentColor = '#05c293',
  });

  Color get accentAsColor {
    final hex = accentColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  AppSettings copyWith({
    String? theme,
    String? currency,
    String? accentColor,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      currency: currency ?? this.currency,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      theme: prefs.getString('theme') ?? 'dark',
      currency: prefs.getString('currency') ?? 'USD',
      accentColor: prefs.getString('accentColor') ?? '#05c293',
    );
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
    state = state.copyWith(theme: theme);
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    state = state.copyWith(currency: currency);
  }

  Future<void> setAccentColor(String color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accentColor', color);
    state = state.copyWith(accentColor: color);
  }

  void syncFromProfile(String currency, String theme, String accentColor) {
    state = state.copyWith(
      currency: currency,
      theme: theme,
      accentColor: accentColor,
    );
  }

  Color get accentAsColor {
    final hex = state.accentColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final notifier = SettingsNotifier();
  ref.listen(profileProvider, (_, next) {
    final profile = next.valueOrNull;
    if (profile != null) {
      notifier.syncFromProfile(
        profile.currency,
        profile.theme,
        profile.accentColor,
      );
    }
  });
  return notifier;
});
