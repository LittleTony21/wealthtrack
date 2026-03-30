import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/asset.dart';
import '../config/app_icons.dart';
import '../config/theme.dart';
import '../config/theme_colors.dart';

class AssetCard extends StatefulWidget {
  final Asset asset;
  final String currency;
  final VoidCallback onDelete;

  const AssetCard({
    super.key,
    required this.asset,
    required this.currency,
    required this.onDelete,
  });

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  bool _expanded = false;

  String _fmt(double amount) {
    final symbols = {
      'USD': '\$', 'EUR': '€', 'GBP': '£', 'CAD': 'CA\$', 'AUD': 'A\$',
      'JPY': '¥', 'CHF': 'Fr', 'CNY': '¥', 'INR': '₹', 'MXN': 'MX\$',
      'BRL': 'R\$', 'KRW': '₩', 'SGD': 'S\$', 'NZD': 'NZ\$', 'NOK': 'kr',
      'SEK': 'kr', 'DKK': 'kr', 'HKD': 'HK\$', 'ZAR': 'R', 'AED': 'د.إ',
    };
    final sym = symbols[widget.currency] ?? widget.currency;
    return '$sym${NumberFormat('#,##0.00').format(amount)}';
  }

  IconData get _icon {
    final custom = widget.asset.iconName;
    if (custom != null && iconNameMap.containsKey(custom)) {
      return iconNameMap[custom]!;
    }
    switch (widget.asset.category) {
      case 'electronics':
        return Icons.laptop_mac_rounded;
      case 'vehicle':
        return Icons.directions_car_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'furniture':
        return Icons.chair_rounded;
      case 'appliance':
        return Icons.kitchen_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final primary = Theme.of(context).primaryColor;
    final c = WealthColors.of(context);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
          boxShadow: c.glowShadow(),
        ),
        child: Column(
          children: [
            // Main row — matches design layout
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon square
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: c.border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_icon, color: primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  // Name + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          asset.name,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'costs ${_fmt(asset.dailyDepreciation)}/day',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Value — right-aligned, vertically centered by Row
                  Text(
                    _fmt(asset.currentValue),
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Expanded detail panel
            if (_expanded)
              Container(
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _Row('Purchase Price', _fmt(asset.price)),
                    _Row(
                      'Purchase Date',
                      DateFormat('MMM d, yyyy').format(asset.purchaseDate),
                    ),
                    _Row('Lifespan', '${asset.lifespanYears} years'),
                    _Row('Daily Depreciation', _fmt(asset.dailyDepreciation)),
                    _Row('Current Value', _fmt(asset.currentValue),
                        valueColor: primary),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.edit_rounded, size: 16),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primary,
                              side: BorderSide(color: primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () =>
                                context.push('/add-asset', extra: asset),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.delete_rounded, size: 16),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: const BorderSide(
                                  color: AppColors.danger),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) {
                                final dc = WealthColors.of(ctx);
                                return AlertDialog(
                                  backgroundColor: dc.card,
                                  title: Text('Delete Asset',
                                      style:
                                          TextStyle(color: dc.textPrimary, fontWeight: FontWeight.w600)),
                                  content: Text(
                                    'Delete "${asset.name}"? This cannot be undone.',
                                    style: TextStyle(
                                        color: dc.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text('Delete',
                                          style: TextStyle(
                                              color: AppColors.danger)),
                                    ),
                                  ],
                                );
                              },
                              );
                              if (ok == true) widget.onDelete();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Row(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    final c = WealthColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(value,
              style: TextStyle(
                color: valueColor ?? c.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}
