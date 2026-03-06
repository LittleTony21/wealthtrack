class UserProfile {
  final String id;
  final String userName;
  final String userAvatar;
  final String currency;
  final String theme;
  final String accentColor;
  final bool pinEnabled;
  final String pinCode;
  final int coins;
  final int streak;
  final String lastCheckIn; // 'YYYY-MM-DD' or ''
  final List<String> checkInDates; // all checked-in dates as 'YYYY-MM-DD'
  final bool isPremium;
  final List<String> unlockedFeatures; // coin-unlocked feature keys
  final List<String> earnedMilestones; // milestone IDs already awarded

  const UserProfile({
    required this.id,
    required this.userName,
    required this.userAvatar,
    this.currency = 'USD',
    this.theme = 'dark',
    this.accentColor = '#05c293',
    this.pinEnabled = false,
    this.pinCode = '',
    this.coins = 0,
    this.streak = 0,
    this.lastCheckIn = '',
    this.checkInDates = const [],
    this.isPremium = false,
    this.unlockedFeatures = const [],
    this.earnedMilestones = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      userName: (json['user_name'] as String?) ?? '',
      userAvatar: (json['user_avatar'] as String?) ?? 'avatar1',
      currency: (json['currency'] as String?) ?? 'USD',
      theme: (json['theme'] as String?) ?? 'dark',
      accentColor: (json['accent_color'] as String?) ?? '#05c293',
      pinEnabled: (json['pin_enabled'] as bool?) ?? false,
      pinCode: (json['pin_code'] as String?) ?? '',
      coins: (json['coins'] as int?) ?? 0,
      streak: (json['streak'] as int?) ?? 0,
      lastCheckIn: (json['last_check_in'] as String?) ?? '',
      checkInDates: (json['check_in_dates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isPremium: (json['is_premium'] as bool?) ?? false,
      unlockedFeatures: (json['unlocked_features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      earnedMilestones: (json['earned_milestones'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'user_avatar': userAvatar,
      'currency': currency,
      'theme': theme,
      'accent_color': accentColor,
      'pin_enabled': pinEnabled,
      'pin_code': pinCode,
      'coins': coins,
      'streak': streak,
      'last_check_in': lastCheckIn,
      'check_in_dates': checkInDates,
      'is_premium': isPremium,
      'unlocked_features': unlockedFeatures,
      'earned_milestones': earnedMilestones,
    };
  }

  UserProfile copyWith({
    String? id,
    String? userName,
    String? userAvatar,
    String? currency,
    String? theme,
    String? accentColor,
    bool? pinEnabled,
    String? pinCode,
    int? coins,
    int? streak,
    String? lastCheckIn,
    List<String>? checkInDates,
    bool? isPremium,
    List<String>? unlockedFeatures,
    List<String>? earnedMilestones,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      currency: currency ?? this.currency,
      theme: theme ?? this.theme,
      accentColor: accentColor ?? this.accentColor,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      pinCode: pinCode ?? this.pinCode,
      coins: coins ?? this.coins,
      streak: streak ?? this.streak,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      checkInDates: checkInDates ?? this.checkInDates,
      isPremium: isPremium ?? this.isPremium,
      unlockedFeatures: unlockedFeatures ?? this.unlockedFeatures,
      earnedMilestones: earnedMilestones ?? this.earnedMilestones,
    );
  }
}
