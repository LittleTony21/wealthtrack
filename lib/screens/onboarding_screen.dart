import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/avatars.dart';
import '../config/theme.dart';
import '../config/theme_colors.dart';
import '../models/user_profile.dart';
import '../providers/onboarding_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';

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
  // Step 6 — currency
  String _currency = 'USD';
  // Step 7 — name
  final _nameCtrl = TextEditingController();
  // Step 8 — avatar
  String _avatar = 'avatar1';
  // Step 9 — theme
  String _theme = 'dark';
  // Step 10 — pin
  String? _pinEnabled;
  final List<TextEditingController> _pinCtrls =
      List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    _nameCtrl.dispose();
    for (final c in _pinCtrls) {
      c.dispose();
    }
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
      case 6:
        return true;
      case 7:
        return true;
      case 8:
        return true;
      case 9:
        if (_pinEnabled == 'yes') {
          return _pinCtrls.every((c) => c.text.isNotEmpty);
        }
        return _pinEnabled != null;
      default:
        return false;
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      await ref.read(settingsProvider.notifier).setTheme(_theme);
      await ref.read(settingsProvider.notifier).setCurrency(_currency);

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Came from Sign Up — already logged in, save profile directly
        final profile = UserProfile(
          id: user.uid,
          userName: _nameCtrl.text.trim(),
          userAvatar: _avatar,
          pinEnabled: _pinEnabled == 'yes',
          pinCode: _pinEnabled == 'yes'
              ? _pinCtrls.map((c) => c.text).join()
              : '',
        );
        await ref.read(profileProvider.notifier).update(profile);
        if (mounted) context.go('/dashboard');
      } else {
        // Came from Welcome → Get Started — not logged in yet, store in memory
        ref.read(onboardingProvider.notifier).save(
              name: _nameCtrl.text.trim(),
              avatar: _avatar,
              currency: _currency,
              theme: _theme,
              pinEnabled: _pinEnabled == 'yes',
              pinCode: _pinEnabled == 'yes'
                  ? _pinCtrls.map((c) => c.text).join()
                  : '',
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
              value: (_step + 1) / 10,
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
                      'Step ${_step + 1} of 10',
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
                          if (_step < 9) {
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
                          _step < 9 ? 'Continue' : 'Get Started',
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
        return _StepCurrency(
            selected: _currency,
            onSelect: (v) => setState(() => _currency = v));
      case 6:
        return _StepName(controller: _nameCtrl);
      case 7:
        return _StepAvatar(
            selected: _avatar,
            onSelect: (v) => setState(() => _avatar = v));
      case 8:
        return _StepTheme(
            selected: _theme,
            onSelect: (v) => setState(() => _theme = v));
      case 9:
        return _StepPin(
            selected: _pinEnabled,
            controllers: _pinCtrls,
            onSelect: (v) => setState(() => _pinEnabled = v));
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

class _StepCurrency extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _StepCurrency({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final currencies = [
      ('USD', 'US Dollar', '🇺🇸'),
      ('EUR', 'Euro', '🇪🇺'),
      ('GBP', 'British Pound', '🇬🇧'),
      ('CAD', 'Canadian Dollar', '🇨🇦'),
      ('AUD', 'Australian Dollar', '🇦🇺'),
      ('JPY', 'Japanese Yen', '🇯🇵'),
    ];

    return _OnboardingStep(
      title: 'Your currency',
      subtitle: 'All values will be shown in this currency.',
      child: Column(
        children: currencies
            .map((cur) => _radio(
                context, '${cur.$1} — ${cur.$2}', cur.$1, selected, onSelect,
                emoji: cur.$3))
            .toList(),
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

class _StepAvatar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _StepAvatar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final c = WealthColors.of(context);

    return _OnboardingStep(
      title: 'Pick your avatar',
      subtitle: 'Choose how you appear in WealthTrack.',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: kAvatarList.length,
        itemBuilder: (_, i) {
          final av = kAvatarList[i];
          final isSelected = selected == av.id;
          return GestureDetector(
            onTap: () => onSelect(av.id),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? primary.withValues(alpha: 0.15)
                    : c.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? primary : c.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.asset(
                      av.path,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            av.name[0],
                            style: TextStyle(
                                fontSize: 24,
                                color: primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    av.name.split(' ').first,
                    style: TextStyle(
                        color: c.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StepTheme extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _StepTheme({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final themes = [
      ('dark', 'Dark', const Color(0xFF0F1117), const Color(0xFF1E2026),
          AppColors.primary),
      ('light', 'Light', AppColors.backgroundLight, Colors.white,
          AppColors.primary),
      ('neon', 'Neon', const Color(0xFF08070F), const Color(0xFF100F1A),
          const Color(0xFF00FFB3)),
    ];

    return _OnboardingStep(
      title: 'App theme',
      subtitle: 'Choose your preferred look.',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: themes.length,
        itemBuilder: (_, i) {
          final t = themes[i];
          final isSelected = selected == t.$1;
          return GestureDetector(
            onTap: () => onSelect(t.$1),
            child: Container(
              decoration: BoxDecoration(
                color: t.$3,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : t.$5.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 16,
                          decoration: BoxDecoration(
                            color: t.$4,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Container(
                              width: 18,
                              height: 6,
                              decoration: BoxDecoration(
                                color: t.$5,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      t.$2,
                      style: GoogleFonts.manrope(
                        color: isSelected ? AppColors.primary : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StepPin extends StatefulWidget {
  final String? selected;
  final List<TextEditingController> controllers;
  final ValueChanged<String> onSelect;
  const _StepPin({
    required this.selected,
    required this.controllers,
    required this.onSelect,
  });

  @override
  State<_StepPin> createState() => _StepPinState();
}

class _StepPinState extends State<_StepPin> {
  final List<FocusNode> _nodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingStep(
      title: 'Set a PIN lock?',
      subtitle: 'Add an extra layer of security.',
      child: Column(
        children: [
          _radio(context, 'Yes, use PIN lock', 'yes', widget.selected, widget.onSelect,
              emoji: '🔒'),
          _radio(context, 'No thanks', 'no', widget.selected, widget.onSelect,
              emoji: '🚫'),
          if (widget.selected == 'yes') ...[
            const SizedBox(height: 24),
            Text(
              'Enter your 4-digit PIN',
              style: GoogleFonts.manrope(
                  color: WealthColors.of(context).textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 56,
                  height: 64,
                  child: TextField(
                    controller: widget.controllers[i],
                    focusNode: _nodes[i],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: WealthColors.of(context).border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: WealthColors.of(context).surface,
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 3) {
                        _nodes[i + 1].requestFocus();
                      }
                      setState(() {});
                    },
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}
