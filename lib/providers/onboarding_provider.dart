import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingData {
  final String name;
  final String avatar;
  final String currency;
  final String theme;
  final bool pinEnabled;
  final String pinCode;

  const OnboardingData({
    this.name = '',
    this.avatar = 'avatar1',
    this.currency = 'USD',
    this.theme = 'dark',
    this.pinEnabled = false,
    this.pinCode = '',
  });
}

class OnboardingNotifier extends StateNotifier<OnboardingData> {
  OnboardingNotifier() : super(const OnboardingData());

  void save({
    required String name,
    required String avatar,
    required String currency,
    required String theme,
    required bool pinEnabled,
    required String pinCode,
  }) {
    state = OnboardingData(
      name: name,
      avatar: avatar,
      currency: currency,
      theme: theme,
      pinEnabled: pinEnabled,
      pinCode: pinCode,
    );
  }

  void clear() {
    state = const OnboardingData();
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingData>(
  (_) => OnboardingNotifier(),
);
