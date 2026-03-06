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
    );
  }
}
