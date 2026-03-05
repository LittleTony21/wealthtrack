import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _ctrls =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(4, (_) => FocusNode());
  bool _error = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(_shakeCtrl);
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _check() {
    final entered = _ctrls.map((c) => c.text).join();
    final profile = ref.read(profileProvider).valueOrNull;
    final correctPin = profile?.pinCode ?? '';

    if (entered == correctPin && correctPin.isNotEmpty) {
      context.go('/dashboard');
    } else {
      setState(() => _error = true);
      _shakeCtrl.forward(from: 0);
      for (final c in _ctrls) {
        c.clear();
      }
      _nodes[0].requestFocus();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _error = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_rounded, color: primary, size: 32),
              ),
              const SizedBox(height: 24),
              Text(
                'Enter your PIN',
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your 4-digit PIN to continue',
                style: GoogleFonts.manrope(
                    color: AppColors.greyText, fontSize: 14),
              ),
              const SizedBox(height: 48),
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (ctx, child) => Transform.translate(
                  offset: Offset(_shakeAnim.value, 0),
                  child: child,
                ),
                child: Row(
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _error
                                  ? AppColors.danger
                                  : AppColors.surfaceHighlight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _error ? AppColors.danger : primary,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _error
                                  ? AppColors.danger
                                  : AppColors.surfaceHighlight,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceDark,
                        ),
                        onChanged: (v) {
                          if (v.isNotEmpty) {
                            if (i < 3) {
                              _nodes[i + 1].requestFocus();
                            } else {
                              _check();
                            }
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),
              if (_error) ...[
                const SizedBox(height: 16),
                Text(
                  'Incorrect PIN. Try again.',
                  style: GoogleFonts.manrope(
                      color: AppColors.danger, fontSize: 13),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (!mounted) return;
                  context.go('/');
                },
                child: Text(
                  'Sign out instead',
                  style: GoogleFonts.manrope(
                    color: AppColors.greyText,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
