import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme_colors.dart';
import '../providers/profile_provider.dart';

void showPaymentSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PaymentSheet(),
  );
}

class _PaymentSheet extends ConsumerStatefulWidget {
  const _PaymentSheet();

  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

enum _PayState { idle, processing, success }

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  _PayState _state = _PayState.idle;
  int _selectedMethod = 0; // 0 = card, 1 = apple pay, 2 = google pay

  Future<void> _pay() async {
    setState(() => _state = _PayState.processing);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1800));
    await ref.read(profileProvider.notifier).upgradeToPremium();
    if (mounted) setState(() => _state = _PayState.success);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst || r.settings.name != null);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = WealthColors.of(context);
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottom + 28),
      child: _state == _PayState.success
          ? _buildSuccess(c)
          : _state == _PayState.processing
              ? _buildProcessing(c)
              : _buildForm(c),
    );
  }

  Widget _buildHandle(WealthColors c) => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: c.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _buildForm(WealthColors c) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHandle(c),
        const SizedBox(height: 20),
        // Header
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB340).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: Color(0xFFFFB340), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WealthTrack Premium',
                      style: GoogleFonts.manrope(
                          color: c.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  Text('One-time purchase · Unlock everything',
                      style: GoogleFonts.manrope(
                          color: c.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Text('\$4.99',
                style: GoogleFonts.manrope(
                    color: c.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 24),
        Divider(color: c.border),
        const SizedBox(height: 20),

        // Payment method label
        Text('Payment method',
            style: GoogleFonts.manrope(
                color: c.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),

        // Method selector
        Row(
          children: [
            _MethodChip(
              label: 'Card',
              icon: Icons.credit_card_rounded,
              selected: _selectedMethod == 0,
              onTap: () => setState(() => _selectedMethod = 0),
              c: c,
            ),
            const SizedBox(width: 10),
            _MethodChip(
              label: 'Apple Pay',
              icon: Icons.apple_rounded,
              selected: _selectedMethod == 1,
              onTap: () => setState(() => _selectedMethod = 1),
              c: c,
            ),
            const SizedBox(width: 10),
            _MethodChip(
              label: 'Google Pay',
              icon: Icons.g_mobiledata_rounded,
              selected: _selectedMethod == 2,
              onTap: () => setState(() => _selectedMethod = 2),
              c: c,
            ),
          ],
        ),

        const SizedBox(height: 20),

        if (_selectedMethod == 0) ...[
          // Card number
          _cardField(c, 'Card number', '4242  4242  4242  4242',
              Icons.credit_card_rounded),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _cardField(c, 'Expiry', 'MM / YY', Icons.date_range_rounded)),
              const SizedBox(width: 12),
              Expanded(
                  child: _cardField(c, 'CVV', '•••', Icons.lock_outline_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          _cardField(c, 'Cardholder name', 'Full name', Icons.person_outline_rounded),
        ] else ...[
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Center(
              child: Text(
                _selectedMethod == 1
                    ? 'Touch ID / Face ID to pay'
                    : 'Authenticate with Google Pay',
                style: GoogleFonts.manrope(
                    color: c.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Pay button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _pay,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB340),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Pay \$4.99',
                style: GoogleFonts.manrope(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),

        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_rounded, size: 12, color: c.textSecondary),
            const SizedBox(width: 4),
            Text('Secured by Stripe · No subscription',
                style: GoogleFonts.manrope(
                    color: c.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _cardField(WealthColors c, String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.manrope(
                color: c.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: c.textSecondary),
              const SizedBox(width: 10),
              Text(hint,
                  style: GoogleFonts.manrope(
                      color: c.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessing(WealthColors c) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFFFFB340)),
            const SizedBox(height: 20),
            Text('Processing payment…',
                style: GoogleFonts.manrope(
                    color: c.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Please wait',
                style: GoogleFonts.manrope(
                    color: c.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(WealthColors c) {
    return SizedBox(
      height: 260,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFF4CAF50), size: 40),
            ),
            const SizedBox(height: 20),
            Text('Payment Successful!',
                style: GoogleFonts.manrope(
                    color: c.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Welcome to Premium 🎉',
                style: GoogleFonts.manrope(
                    color: c.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final WealthColors c;

  const _MethodChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: 0.1) : c.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? primary : c.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: selected ? primary : c.textSecondary),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: selected ? primary : c.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
