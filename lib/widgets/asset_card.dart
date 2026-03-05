import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/asset.dart';
import '../config/theme.dart';

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

  Color get _healthColor {
    final p = widget.asset.healthPercent;
    if (p > 60) return AppColors.primary;
    if (p > 30) return const Color(0xFFFFB340);
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final primary = Theme.of(context).primaryColor;
    final healthPct = (asset.healthPercent / 100).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceHighlight),
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
                      color: AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_icon, color: primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: name + value
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                asset.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _fmt(asset.currentValue),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Row 2: subtitle + progress bar + %
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'costs ${_fmt(asset.dailyDepreciation)}/day',
                              style: const TextStyle(
                                color: AppColors.greyText,
                                fontSize: 12,
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 64,
                                  height: 6,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: healthPct,
                                      backgroundColor:
                                          AppColors.surfaceHighlight,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              _healthColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 26,
                                  child: Text(
                                    '${asset.healthPercent.round()}',
                                    style: const TextStyle(
                                      color: AppColors.greyText,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Expanded detail panel
            if (_expanded)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
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
                                builder: (_) => AlertDialog(
                                  backgroundColor: AppColors.cardDark,
                                  title: const Text('Delete Asset',
                                      style:
                                          TextStyle(color: Colors.white)),
                                  content: Text(
                                    'Delete "${asset.name}"? This cannot be undone.',
                                    style: const TextStyle(
                                        color: AppColors.greyText),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete',
                                          style: TextStyle(
                                              color: AppColors.danger)),
                                    ),
                                  ],
                                ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.greyText, fontSize: 13)),
          Text(value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
