import 'package:flutter/material.dart';

/// Icon options per asset category (3 each — all confirmed Flutter Material icons)
const Map<String, List<Map<String, dynamic>>> assetCategoryIcons = {
  'electronics': [
    {'name': 'laptop', 'icon': Icons.laptop_mac_rounded},
    {'name': 'phone', 'icon': Icons.smartphone_rounded},
    {'name': 'tablet', 'icon': Icons.tablet_rounded},
  ],
  'vehicle': [
    {'name': 'car', 'icon': Icons.directions_car_rounded},
    {'name': 'motorcycle', 'icon': Icons.motorcycle_rounded},
    {'name': 'bus', 'icon': Icons.directions_bus_rounded},
  ],
  'home': [
    {'name': 'house', 'icon': Icons.home_rounded},
    {'name': 'apartment', 'icon': Icons.apartment_rounded},
    {'name': 'villa', 'icon': Icons.villa_rounded},
  ],
  'furniture': [
    {'name': 'chair', 'icon': Icons.chair_rounded},
    {'name': 'sofa', 'icon': Icons.weekend_rounded},
    {'name': 'bed', 'icon': Icons.bed_rounded},
  ],
  'appliance': [
    {'name': 'fridge', 'icon': Icons.kitchen_rounded},
    {'name': 'tv', 'icon': Icons.tv_rounded},
    {'name': 'ac', 'icon': Icons.ac_unit_rounded},
  ],
  'other': [
    {'name': 'box', 'icon': Icons.inventory_2_rounded},
    {'name': 'category', 'icon': Icons.category_rounded},
    {'name': 'star', 'icon': Icons.star_rounded},
  ],
};

/// Icon options per liability category (3 each — all confirmed Flutter Material icons)
const Map<String, List<Map<String, dynamic>>> liabilityCategoryIcons = {
  'mortgage': [
    {'name': 'homework', 'icon': Icons.home_work_rounded},
    {'name': 'apt', 'icon': Icons.apartment_rounded},
    {'name': 'city', 'icon': Icons.location_city_rounded},
  ],
  'auto': [
    {'name': 'auto_car', 'icon': Icons.directions_car_rounded},
    {'name': 'gas', 'icon': Icons.local_gas_station_rounded},
    {'name': 'build', 'icon': Icons.build_rounded},
  ],
  'credit': [
    {'name': 'card', 'icon': Icons.credit_card_rounded},
    {'name': 'wallet', 'icon': Icons.account_balance_wallet_rounded},
    {'name': 'cart', 'icon': Icons.shopping_cart_rounded},
  ],
  'student': [
    {'name': 'school', 'icon': Icons.school_rounded},
    {'name': 'book', 'icon': Icons.menu_book_rounded},
    {'name': 'calculate', 'icon': Icons.calculate_rounded},
  ],
  'personal': [
    {'name': 'handshake', 'icon': Icons.handshake_rounded},
    {'name': 'person', 'icon': Icons.person_rounded},
    {'name': 'paid', 'icon': Icons.paid_rounded},
  ],
  'other': [
    {'name': 'bank', 'icon': Icons.account_balance_rounded},
    {'name': 'receipt', 'icon': Icons.receipt_rounded},
    {'name': 'savings', 'icon': Icons.savings_rounded},
  ],
};

/// Flat name→IconData lookup for restoring saved icon names
const Map<String, IconData> iconNameMap = {
  // asset icons
  'laptop': Icons.laptop_mac_rounded,
  'phone': Icons.smartphone_rounded,
  'tablet': Icons.tablet_rounded,
  'car': Icons.directions_car_rounded,
  'motorcycle': Icons.motorcycle_rounded,
  'bus': Icons.directions_bus_rounded,
  'house': Icons.home_rounded,
  'apartment': Icons.apartment_rounded,
  'villa': Icons.villa_rounded,
  'chair': Icons.chair_rounded,
  'sofa': Icons.weekend_rounded,
  'bed': Icons.bed_rounded,
  'fridge': Icons.kitchen_rounded,
  'tv': Icons.tv_rounded,
  'ac': Icons.ac_unit_rounded,
  'box': Icons.inventory_2_rounded,
  'category': Icons.category_rounded,
  'star': Icons.star_rounded,
  // liability icons
  'homework': Icons.home_work_rounded,
  'apt': Icons.apartment_rounded,
  'city': Icons.location_city_rounded,
  'auto_car': Icons.directions_car_rounded,
  'gas': Icons.local_gas_station_rounded,
  'build': Icons.build_rounded,
  'card': Icons.credit_card_rounded,
  'wallet': Icons.account_balance_wallet_rounded,
  'cart': Icons.shopping_cart_rounded,
  'school': Icons.school_rounded,
  'book': Icons.menu_book_rounded,
  'calculate': Icons.calculate_rounded,
  'handshake': Icons.handshake_rounded,
  'person': Icons.person_rounded,
  'paid': Icons.paid_rounded,
  'bank': Icons.account_balance_rounded,
  'receipt': Icons.receipt_rounded,
  'savings': Icons.savings_rounded,
};
