import 'package:cloud_firestore/cloud_firestore.dart';

class Asset {
  final String id;
  final String userId;
  final String name;
  final String category;
  final double price;
  final DateTime purchaseDate;
  final int lifespanYears;
  final String? iconName;

  const Asset({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.price,
    required this.purchaseDate,
    required this.lifespanYears,
    this.iconName,
  });

  double get dailyDepreciation => price / (lifespanYears * 365);

  double get currentValue {
    final days =
        DateTime.now().difference(purchaseDate).inDays.toDouble();
    return (price - dailyDepreciation * days).clamp(0, price);
  }

  double get healthPercent {
    final days =
        DateTime.now().difference(purchaseDate).inDays.toDouble();
    return (100 - (days / (lifespanYears * 365)) * 100).clamp(0, 100);
  }

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchase_date'] as String),
      lifespanYears: (json['lifespan_years'] as num).toInt(),
      iconName: json['icon_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'price': price,
      'purchase_date': purchaseDate.toIso8601String().split('T').first,
      'lifespan_years': lifespanYears,
      if (iconName != null) 'icon_name': iconName,
    };
  }

  factory Asset.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Asset(
      id: doc.id,
      userId: data['user_id'] as String,
      name: data['name'] as String,
      category: data['category'] as String,
      price: (data['price'] as num).toDouble(),
      purchaseDate: (data['purchase_date'] as Timestamp).toDate(),
      lifespanYears: (data['lifespan_years'] as num).toInt(),
      iconName: data['icon_name'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'name': name,
      'category': category,
      'price': price,
      'purchase_date': Timestamp.fromDate(purchaseDate),
      'lifespan_years': lifespanYears,
      if (iconName != null) 'icon_name': iconName,
    };
  }

  Asset copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    double? price,
    DateTime? purchaseDate,
    int? lifespanYears,
    String? iconName,
  }) {
    return Asset(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      lifespanYears: lifespanYears ?? this.lifespanYears,
      iconName: iconName ?? this.iconName,
    );
  }

  static const List<String> categories = [
    'electronics',
    'vehicle',
    'home',
    'furniture',
    'appliance',
    'other',
  ];

  String get categoryLabel {
    switch (category) {
      case 'electronics':
        return 'Electronics';
      case 'vehicle':
        return 'Vehicle';
      case 'home':
        return 'Home';
      case 'furniture':
        return 'Furniture';
      case 'appliance':
        return 'Appliance';
      default:
        return 'Other';
    }
  }
}
