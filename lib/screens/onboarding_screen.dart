import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../config/theme_colors.dart';
import '../models/user_profile.dart';
import '../providers/onboarding_provider.dart';
import '../providers/profile_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  bool _saving = false;

  // Step 1 — goal
  String? _goal;
  // Step 2 — asset types (multi-select)
  final Set<String> _assetTypes = {};
  // Step 3 — debts
  String? _hasDebt;
  // Step 4 — most valuable
  String? _mostValuable;
  // Step 5 — know net worth
  String? _knowsNetWorth;
  // Step 6 — name
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _goal != null;
      case 1:
        return _assetTypes.isNotEmpty;
      case 2:
        return _hasDebt != null;
      case 3:
        return _mostValuable != null;
      case 4:
        return _knowsNetWorth != null;
      case 5:
        return true;
      default:
        return false;
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Came from Sign Up — already logged in, save profile directly
        final profile = UserProfile(
          id: user.uid,
          userName: _nameCtrl.text.trim(),
          userAvatar: 'avatar1',
          pinEnabled: false,
          pinCode: '',
        );
        await ref.read(profileProvider.notifier).update(profile);
        if (mounted) context.go('/dashboard');
      } else {
        // Came from Welcome → Get Started — not logged in yet, store in memory
        ref.read(onboardingProvider.notifier).save(
              name: _nameCtrl.text.trim(),
              avatar: 'avatar1',
              currency: 'USD',
              theme: 'dark',
              pinEnabled: false,
              pinCode: '',
            );
        if (mounted) context.go('/auth');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = WealthColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top progress bar (thin, at very top like design)
            LinearProgressIndicator(
              value: (_step + 1) / 6,
              backgroundColor: c.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
            // Header row: back | step counter | spacer
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: _step > 0 ? c.textPrimary : c.textSecondary,
                      size: 22,
                    ),
                    onPressed: _step > 0
                        ? () => setState(() => _step--)
                        : null,
                  ),
                  Expanded(
                    child: Text(
                      'Step ${_step + 1} of 6',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: c.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStep(),
              ),
            ),
            // Continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canContinue
                      ? () {
                          if (_step < 5) {
                            setState(() => _step++);
                          } else {
                            _finish();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canContinue
                        ? AppColors.primary
                        : c.border,
                    disabledBackgroundColor: c.border,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          _step < 5 ? 'Continue' : 'Get Started',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _canContinue
                                ? Colors.white
                                : c.textSecondary,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _StepGoal(
            selected: _goal,
            onSelect: (v) => setState(() => _goal = v));
      case 1:
        return _StepAssetTypes(
            selected: _assetTypes,
            onToggle: (v) => setState(() {
                  if (_assetTypes.contains(v)) {
                    _assetTypes.remove(v);
                  } else {
                    _assetTypes.add(v);
                  }
                }));
      case 2:
        return _StepHasDebt(
            selected: _hasDebt,
            onSelect: (v) => setState(() => _hasDebt = v));
      case 3:
        return _StepMostValuable(
            selected: _mostValuable,
            onSelect: (v) => setState(() => _mostValuable = v));
      case 4:
        return _StepKnowsNetWorth(
            selected: _knowsNetWorth,
            onSelect: (v) => setState(() => _knowsNetWorth = v));
      case 5:
        return _StepName(controller: _nameCtrl);
      default:
        return const SizedBox();
    }
  }
}

// ── Step widgets ───────────────────────────────────────────────────────────

class _OnboardingStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final c = WealthColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            color: c.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.manrope(
              color: c.textSecondary, fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 32),
        child,
      ],
    );
  }
}

Widget _radio(
    BuildContext context,
    String label, String value, String? selected, ValueChanged<String> onTap,
    {String? emoji}) {
  final isSelected = selected == value;
  final primary = Theme.of(context).primaryColor;
  final c = WealthColors.of(context);
  return GestureDetector(
    onTap: () => onTap(value),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: isSelected
            ? primary.withValues(alpha: 0.08)
            : c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primary : c.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? primary.withValues(alpha: 0.2)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? primary : c.textSecondary,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    ),
  );
}

class _StepGoal extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _StepGoal({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return _OnboardingStep(
      title: "What's your main goal?",
      subtitle: 'This helps us personalize your experience.',
      child: Column(
        children: [
          _radio(context, 'Build long-term wealth', 'wealth', selected, onSelect,
              emoji: '📈'),
          _radio(context, 'Save for a big purchase', 'save', selected, onSelect,
              emoji: '🏠'),
          _radio(context, 'Pay off debt', 'debt', selected, onSelect, emoji: '💳'),
          _radio(context, 'Track my spending', 'track', selected, onSelect,
              emoji: '📊'),
        ],
      ),
    );
  }
}

class _StepAssetTypes extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  const _StepAssetTypes({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final options = [
      ('Tech & Electronics', 'tech', '💻'),
      ('Vehicles', 'vehicles', '🚗'),
      ('Property', 'property', '🏡'),
      ('Hobbies & Sports', 'hobbies', '🎸'),
      ('Clothing & Fashion', 'clothing', '👗'),
      ('Other', 'other', '📦'),
    ];

    return _OnboardingStep(
      title: 'What do you own?',
      subtitle: 'Select all that apply.',
      child: Column(
        children: options.map((o) {
          final isSelected = selected.contains(o.$2);
          final primary = Theme.of(context).primaryColor;
          final wc = WealthColors.of(context);
          return GestureDetector(
            onTap: () => onToggle(o.$2),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: isSelected
                    ? primary.withValues(alpha: 0.08)
                    : wc.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? primary : wc.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      o.$1,
                      style: TextStyle(
                        color: wc.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: isSelected ? primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? primary : wc.textSecondary,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14)
                        : null,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StepHasDebt extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _StepHasDebt({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return _OnboardingStep(
      title: 'Do you have any debts?',
      subtitle: 'Loans, credit cards, mortgages, etc.',
      child: Column(
        children: [
          _radio(context, 'Yes, I have loans or debt', 'yes', selected, onSelect,
              emoji: '💰'),
          _radio(context, 'No debts at the moment', 'no', selected, onSelect,
              emoji: '✅'),
          _radio(context, "Not sure", 'unsure', selected, onSelect, emoji: '🤔'),
        ],
      ),
    );
  }
}

class _StepMostValuable extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _StepMostValuable({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return _OnboardingStep(
      title: 'Most valuable asset?',
      subtitle: 'Pick the one that is worth the most.',
      child: Column(
        children: [
          _radio(context, 'Phone or laptop', 'phone', selected, onSelect, emoji: '📱'),
          _radio(context, 'Car', 'car', selected, onSelect, emoji: '🚗'),
          _radio(context, 'Home', 'home', selected, onSelect, emoji: '🏠'),
          _radio(context, 'Work equipment', 'work', selected, onSelect, emoji: '🔧'),
          _radio(context, 'Not sure', 'unsure', selected, onSelect, emoji: '🤷'),
        ],
      ),
    );
  }
}

class _StepKnowsNetWorth extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _StepKnowsNetWorth({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return _OnboardingStep(
      title: 'Do you know your net worth?',
      subtitle: 'Assets minus liabilities.',
      child: Column(
        children: [
          _radio(context, 'I know exactly', 'exact', selected, onSelect, emoji: '🎯'),
          _radio(context, 'I have a rough idea', 'rough', selected, onSelect,
              emoji: '🧮'),
          _radio(context, 'No clue', 'none', selected, onSelect, emoji: '🙈'),
          _radio(context, "Scared to find out", 'scared', selected, onSelect,
              emoji: '😬'),
        ],
      ),
    );
  }
}

class _StepName extends StatelessWidget {
  final TextEditingController controller;
  const _StepName({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _OnboardingStep(
      title: "What's your name?",
      subtitle: 'We\'ll use this to personalize your dashboard.',
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: WealthColors.of(context).textPrimary),
        decoration: InputDecoration(
          hintText: 'Your display name (optional)',
          prefixIcon: Icon(Icons.person_rounded,
              color: WealthColors.of(context).textSecondary, size: 20),
        ),
      ),
    );
  }
}

