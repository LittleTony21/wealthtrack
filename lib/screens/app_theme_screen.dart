import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../config/theme_colors.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../services/premium_service.dart';
import '../widgets/premium_sheet.dart';

class AppThemeScreen extends ConsumerWidget {
  const AppThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final primary = Theme.of(context).primaryColor;
    final c = WealthColors.of(context);
    final hasThemeAccess =
        ref.watch(premiumAccessProvider(PremiumFeature.themes));

    final themes = [
      (
        'dark',
        'Dark',
        const Color(0xFF0F1117),
        const Color(0xFF1E2026),
        AppColors.primary
      ),
      (
        'light',
        'Light',
        AppColors.backgroundLight,
        Colors.white,
        AppColors.primary
      ),
      (
        'neon',
        'Neon',
        const Color(0xFF08070F),
        const Color(0xFF100F1A),
        const Color(0xFF00FFB3)
      ),
    ];

    Future<void> applyTheme(String theme) async {
      await ref.read(settingsProvider.notifier).setTheme(theme);
      final profile = ref.read(profileProvider).valueOrNull;
      if (profile != null) {
        await ref.read(profileProvider.notifier).update(
              profile.copyWith(theme: theme),
            );
      }
    }

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('App Theme'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Theme',
              style: GoogleFonts.manrope(
                color: c.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: themes.length,
              itemBuilder: (_, i) {
                final (id, label, bg, card, accent) = themes[i];
                final isSelected = settings.theme == id;
                final isLocked = !hasThemeAccess && id != 'dark';
                return GestureDetector(
                  onTap: () {
                    if (isLocked) {
                      showPremiumSheet(context,
                          featureKey: PremiumFeature.themes);
                      return;
                    }
                    applyTheme(id);
                  },
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: isLocked ? 0.5 : 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? primary
                                  : accent.withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: card,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 20,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: accent,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: GoogleFonts.manrope(
                                          color: isSelected
                                              ? primary
                                              : Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.check_circle_rounded,
                                          color: primary, size: 18),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isLocked)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_rounded,
                                color: Colors.white, size: 12),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Apply Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
