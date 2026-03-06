import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../config/theme_colors.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../services/premium_service.dart';
import '../widgets/premium_sheet.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _loading = false;

  Future<void> _togglePin(bool enable, UserProfile profile) async {
    if (enable) {
      final pin = await _showSetPinSheet(context, currentPin: null);
      if (pin == null || !mounted) return;
      setState(() => _loading = true);
      try {
        await ref
            .read(profileProvider.notifier)
            .update(profile.copyWith(pinEnabled: true, pinCode: pin));
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    } else {
      setState(() => _loading = true);
      try {
        await ref
            .read(profileProvider.notifier)
            .update(profile.copyWith(pinEnabled: false, pinCode: ''));
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  Future<void> _changePin(UserProfile profile) async {
    final pin = await _showSetPinSheet(context, currentPin: profile.pinCode);
    if (pin == null || !mounted) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(profileProvider.notifier)
          .update(profile.copyWith(pinCode: pin));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN updated successfully')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String?> _showSetPinSheet(BuildContext context,
      {required String? currentPin}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _SetPinSheet(currentPin: currentPin),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final c = WealthColors.of(context);
    final profile = ref.watch(profileProvider).valueOrNull;
    final pinEnabled = profile?.pinEnabled ?? false;
    final hasPinAccess =
        ref.watch(premiumAccessProvider(PremiumFeature.pinLock));

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('Security'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'PIN LOCK',
                        style: GoogleFonts.manrope(
                          color: c.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (!hasPinAccess) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.lock_rounded,
                            color: c.textSecondary, size: 12),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.border),
                      boxShadow: c.glowShadow(),
                    ),
                    child: Column(
                      children: [
                        // Enable toggle row
                        GestureDetector(
                          onTap: hasPinAccess
                              ? null
                              : () => showPremiumSheet(context,
                                  featureKey: PremiumFeature.pinLock),
                          behavior: HitTestBehavior.opaque,
                          child: Opacity(
                            opacity: hasPinAccess ? 1.0 : 0.6,
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.lock_rounded,
                                    color: primary, size: 18),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Enable PIN Lock',
                                      style: TextStyle(
                                        color: c.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Require PIN every time you open the app',
                                      style: TextStyle(
                                        color: c.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (!hasPinAccess)
                                Icon(Icons.lock_rounded,
                                    color: c.textSecondary, size: 20)
                              else if (_loading)
                                SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: primary))
                              else
                                Switch(
                                    value: pinEnabled,
                                    onChanged: (v) => _togglePin(v, profile),
                                    activeColor: primary),
                            ],
                          ),
                        ),
                          ),
                        ),

                        // Change PIN row (only when PIN is enabled)
                        if (pinEnabled) ...[
                          Divider(height: 1, color: c.border, indent: 52),
                          GestureDetector(
                            onTap: () => _changePin(profile),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.pin_rounded,
                                        color: primary, size: 18),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      'Change PIN',
                                      style: TextStyle(
                                        color: c.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded,
                                      color: c.textSecondary, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Bottom sheet for setting / changing PIN ──────────────────────────────────

class _SetPinSheet extends StatefulWidget {
  final String? currentPin; // null = first time (no verification needed)

  const _SetPinSheet({this.currentPin});

  @override
  State<_SetPinSheet> createState() => _SetPinSheetState();
}

class _SetPinSheetState extends State<_SetPinSheet> {
  late int _step; // 0=verify current, 1=enter new, 2=confirm new
  final List<TextEditingController> _ctrls =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(4, (_) => FocusNode());
  String _newPin = '';
  bool _error = false;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _step = widget.currentPin != null ? 0 : 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  void _clearAll() {
    for (final c in _ctrls) c.clear();
    _nodes[0].requestFocus();
  }

  void _onDigit(int index, String value) {
    if (value.isEmpty) return;
    if (_error) setState(() => _error = false);
    if (index < 3) {
      _nodes[index + 1].requestFocus();
    } else {
      final entered = _ctrls.map((c) => c.text).join();
      if (entered.length == 4) _handleSubmit(entered);
    }
  }

  void _handleSubmit(String entered) {
    if (_step == 0) {
      // Verify current PIN
      if (entered == widget.currentPin) {
        setState(() {
          _step = 1;
          _error = false;
        });
        _clearAll();
      } else {
        setState(() {
          _error = true;
          _errorText = 'Incorrect PIN. Try again.';
        });
        _clearAll();
      }
    } else if (_step == 1) {
      // Store new PIN, move to confirm
      _newPin = entered;
      setState(() {
        _step = 2;
        _error = false;
      });
      _clearAll();
    } else {
      // Confirm new PIN
      if (entered == _newPin) {
        Navigator.pop(context, _newPin);
      } else {
        _newPin = '';
        setState(() {
          _step = 1;
          _error = true;
          _errorText = 'PINs do not match. Try again.';
        });
        _clearAll();
      }
    }
  }

  String get _title {
    switch (_step) {
      case 0:
        return 'Verify Current PIN';
      case 1:
        return widget.currentPin == null ? 'Set Your PIN' : 'Enter New PIN';
      default:
        return 'Confirm PIN';
    }
  }

  String get _subtitle {
    switch (_step) {
      case 0:
        return 'Enter your current PIN first';
      case 1:
        return 'Choose a 4-digit PIN';
      default:
        return 'Re-enter your new PIN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final c = WealthColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: c.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Header row with cancel button
          Row(
            children: [
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: c.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.border),
                  ),
                  child: Icon(Icons.close_rounded,
                      color: c.textSecondary, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _subtitle,
            style: GoogleFonts.manrope(
              color: c.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),

          // 4 PIN boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 60,
                height: 70,
                child: TextField(
                  controller: _ctrls[i],
                  focusNode: _nodes[i],
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: _error ? AppColors.danger : c.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: _error ? AppColors.danger : primary,
                          width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: _error ? AppColors.danger : c.border),
                    ),
                    filled: true,
                    fillColor: c.surface,
                  ),
                  onChanged: (v) => _onDigit(i, v),
                ),
              );
            }),
          ),

          if (_error) ...[
            const SizedBox(height: 16),
            Text(
              _errorText,
              style: GoogleFonts.manrope(
                color: AppColors.danger,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
