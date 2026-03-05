import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/liability.dart';
import '../config/theme.dart';

class LiabilityCard extends StatefulWidget {
  final Liability liability;
  final String currency;
  final VoidCallback onDelete;

  const LiabilityCard({
    super.key,
    required this.liability,
    required this.currency,
    required this.onDelete,
  });

  @override
  State<LiabilityCard> createState() => _LiabilityCardState();
}

class _LiabilityCardState extends State<LiabilityCard> {
  bool _expanded = false;

  String _fmt(double amount) {
    final symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'CAD': 'CA\$',
      'AUD': 'A\$',
      'JPY': '¥',
    };
    final sym = symbols[widget.currency] ?? '\$';
    return '$sym${NumberFormat('#,##0.00').format(amount)}';
  }

  IconData get _icon {
    switch (widget.liability.category) {
      case 'mortgage':
        return Icons.home_work_rounded;
      case 'auto':
        return Icons.directions_car_rounded;
      case 'credit':
        return Icons.credit_card_rounded;
      case 'student':
        return Icons.school_rounded;
      case 'personal':
        return Icons.handshake_rounded;
      default:
        return Icons.account_balance_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final liability = widget.liability;
    final primary = Theme.of(context).primaryColor;

    // Display progress as how manageable the interest rate is (lower is better)
    final paidRatio = (1.0 - (liability.interestRate / 30.0).clamp(0.0, 1.0));
    final displayPct = (paidRatio * 100).round();

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
                    child: Icon(_icon, color: AppColors.danger, size: 24),
                  ),
                  const SizedBox(width: 16),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: name + balance
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                liability.name,
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
                              _fmt(liability.balance),
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
                              'Repaying ${_fmt(liability.dailyPayment)}/day',
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
                                      value: paidRatio.clamp(0.0, 1.0),
                                      backgroundColor:
                                          AppColors.surfaceHighlight,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              AppColors.danger),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 26,
                                  child: Text(
                                    '$displayPct',
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
                    _Row('Balance', _fmt(liability.balance),
                        valueColor: AppColors.danger),
                    _Row('Monthly Payment', _fmt(liability.monthlyPayment)),
                    _Row('Interest Rate',
                        '${liability.interestRate.toStringAsFixed(2)}%'),
                    _Row(
                      'Date Added',
                      DateFormat('MMM d, yyyy').format(liability.dateAdded),
                    ),
                    _Row('Daily Cost', _fmt(liability.dailyPayment)),
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
                            onPressed: () => context.push(
                                '/add-liability',
                                extra: liability),
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
                                  title: const Text('Delete Liability',
                                      style:
                                          TextStyle(color: Colors.white)),
                                  content: Text(
                                    'Delete "${liability.name}"? This cannot be undone.',
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
