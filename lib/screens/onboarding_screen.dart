import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../models/user_profile.dart';
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
        // Came from Welcome → Get Started — not logged in yet, save as pending
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_name', _nameCtrl.text.trim());
        await prefs.setString('pending_avatar', _avatar);
        await prefs.setString('pending_pin_enabled', _pinEnabled ?? 'no');
        await prefs.setString(
          'pending_pin_code',
          _pinEnabled == 'yes' ? _pinCtrls.map((c) => c.text).join() : '',
        );
        if (mounted) context.go('/auth');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top progress bar (thin, at very top like design)
            LinearProgressIndicator(
              value: (_step + 1) / 10,
              backgroundColor: AppColors.surfaceHighlight,
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
                      color: _step > 0 ? Colors.white : AppColors.greyText,
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
                        color: AppColors.greyText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
                        : AppColors.surfaceHighlight,
                    disabledBackgroundColor: AppColors.surfaceHighlight,
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
                                : AppColors.greyText,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.manrope(
              color: AppColors.greyText, fontSize: 15),
        ),
        const SizedBox(height: 32),
        child,
      ],
    );
  }
}

Widget _radio(
    String label, String value, String? selected, ValueChanged<String> onTap,
    {String? emoji}) {
  final isSelected = selected == value;
  return GestureDetector(
    onTap: () => onTap(value),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Radio circle
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.greyText,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
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
          _radio('Build long-term wealth', 'wealth', selected, onSelect,
              emoji: '📈'),
          _radio('Save for a big purchase', 'save', selected, onSelect,
              emoji: '🏠'),
          _radio('Pay off debt', 'debt', selected, onSelect, emoji: '💳'),
          _radio('Track my spending', 'track', selected, onSelect,
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
          return GestureDetector(
            onTap: () => onToggle(o.$2),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      o.$1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Checkbox square
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.greyText,
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
          _radio('Yes, I have loans or debt', 'yes', selected, onSelect,
              emoji: '💰'),
          _radio('No debts at the moment', 'no', selected, onSelect,
              emoji: '✅'),
          _radio("Not sure", 'unsure', selected, onSelect, emoji: '🤔'),
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
          _radio('Phone or laptop', 'phone', selected, onSelect, emoji: '📱'),
          _radio('Car', 'car', selected, onSelect, emoji: '🚗'),
          _radio('Home', 'home', selected, onSelect, emoji: '🏠'),
          _radio('Work equipment', 'work', selected, onSelect, emoji: '🔧'),
          _radio('Not sure', 'unsure', selected, onSelect, emoji: '🤷'),
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
          _radio('I know exactly', 'exact', selected, onSelect, emoji: '🎯'),
          _radio('I have a rough idea', 'rough', selected, onSelect,
              emoji: '🧮'),
          _radio('No clue', 'none', selected, onSelect, emoji: '🙈'),
          _radio("Scared to find out", 'scared', selected, onSelect,
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
            .map((c) => _radio(
                '${c.$1} — ${c.$2}', c.$1, selected, onSelect,
                emoji: c.$3))
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
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Your display name (optional)',
          prefixIcon: Icon(Icons.person_rounded,
              color: AppColors.greyText, size: 20),
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
    final avatars = [
      'avatar1',
      'avatar2',
      'avatar3',
      'avatar4',
      'avatar5',
      'avatar6',
    ];
    final emojiAvatars = ['😎', '🦁', '🐬', '🦊', '🤖', '🧑‍💼'];

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
        ),
        itemCount: avatars.length,
        itemBuilder: (_, i) {
          final isSelected = selected == avatars[i];
          return GestureDetector(
            onTap: () => onSelect(avatars[i]),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceHighlight,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(emojiAvatars[i],
                    style: const TextStyle(fontSize: 40)),
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
      ('custom', 'Custom', const Color(0xFF0F1117), const Color(0xFF1E2026),
          Colors.purple),
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
          _radio('Yes, use PIN lock', 'yes', widget.selected, widget.onSelect,
              emoji: '🔒'),
          _radio('No thanks', 'no', widget.selected, widget.onSelect,
              emoji: '🚫'),
          if (widget.selected == 'yes') ...[
            const SizedBox(height: 24),
            Text(
              'Enter your 4-digit PIN',
              style: GoogleFonts.manrope(
                  color: AppColors.greyText, fontSize: 14),
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
                        borderSide: const BorderSide(
                            color: AppColors.surfaceHighlight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceDark,
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
