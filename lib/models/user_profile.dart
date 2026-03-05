class UserProfile {
  final String id;
  final String userName;
  final String userAvatar;
  final String currency;
  final String theme;
  final String accentColor;
  final bool pinEnabled;
  final String pinCode;

  const UserProfile({
    required this.id,
    required this.userName,
    required this.userAvatar,
    this.currency = 'USD',
    this.theme = 'dark',
    this.accentColor = '#05c293',
    this.pinEnabled = false,
    this.pinCode = '',
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
    );
  }
}
