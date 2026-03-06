import 'package:cloud_firestore/cloud_firestore.dart';

class Liability {
  final String id;
  final String userId;
  final String name;
  final String category;
  final double balance;
  final double monthlyPayment;
  final DateTime dateAdded;
  final String? iconName;

  const Liability({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.balance,
    required this.monthlyPayment,
    required this.dateAdded,
    this.iconName,
  });

  double get dailyPayment => monthlyPayment / 30;

  factory Liability.fromJson(Map<String, dynamic> json) {
    return Liability(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      balance: (json['balance'] as num).toDouble(),
      monthlyPayment: (json['monthly_payment'] as num).toDouble(),
      dateAdded: DateTime.parse(json['date_added'] as String),
      iconName: json['icon_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'balance': balance,
      'monthly_payment': monthlyPayment,
      'date_added': dateAdded.toIso8601String().split('T').first,
      if (iconName != null) 'icon_name': iconName,
    };
  }

  factory Liability.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Liability(
      id: doc.id,
      userId: data['user_id'] as String,
      name: data['name'] as String,
      category: data['category'] as String,
      balance: (data['balance'] as num).toDouble(),
      monthlyPayment: (data['monthly_payment'] as num).toDouble(),
      dateAdded: (data['date_added'] as Timestamp).toDate(),
      iconName: data['icon_name'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'name': name,
      'category': category,
      'balance': balance,
      'monthly_payment': monthlyPayment,
      'date_added': Timestamp.fromDate(dateAdded),
      if (iconName != null) 'icon_name': iconName,
    };
  }

  Liability copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    double? balance,
    double? monthlyPayment,
    DateTime? dateAdded,
    String? iconName,
  }) {
    return Liability(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      balance: balance ?? this.balance,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      dateAdded: dateAdded ?? this.dateAdded,
      iconName: iconName ?? this.iconName,
    );
  }

  static const List<String> categories = [
    'mortgage',
    'auto',
    'credit',
    'student',
    'personal',
    'other',
  ];

  String get categoryLabel {
    switch (category) {
      case 'mortgage':
        return 'Mortgage';
      case 'auto':
        return 'Auto Loan';
      case 'credit':
        return 'Credit Card';
      case 'student':
        return 'Student Loan';
      case 'personal':
        return 'Personal Loan';
      default:
        return 'Other';
    }
  }
}
