import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/avatars.dart';
import '../config/theme.dart';
import '../config/theme_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/bottom_nav.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final settings = ref.watch(settingsProvider);
    final primary = Theme.of(context).primaryColor;

    final c = WealthColors.of(context);
    final profile = profileAsync.valueOrNull;
    final currentAvatarId = profile?.userAvatar ?? 'avatar1';
    final currentAvatarPath = avatarPath(currentAvatarId);
    final currentAvatarInitial = avatarName(currentAvatarId)[0];

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header card — matches section card style
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: c.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: c.border),
                          boxShadow: c.glowShadow(),
                        ),
                        child: Row(
                          children: [
                            // Avatar with edit button
                            Stack(
                              children: [
                                Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: primary, width: 2.5),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      currentAvatarPath,
                                      width: 76,
                                      height: 76,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: primary.withValues(alpha: 0.15),
                                        child: Center(
                                          child: Text(
                                            currentAvatarInitial,
                                            style: TextStyle(
                                                fontSize: 30,
                                                color: primary,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () =>
                                        context.push('/profile/personal-info'),
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: c.card, width: 2),
                                      ),
                                      child: const Icon(Icons.edit_rounded,
                                          color: Colors.white, size: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Name + Member
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile?.userName ?? 'User',
                                    style: GoogleFonts.manrope(
                                      color: c.textPrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Member',
                                    style: GoogleFonts.manrope(
                                        color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _Section(title: 'Account', items: [
                            _MenuItem(
                              icon: Icons.person_rounded,
                              label: 'Personal Info',
                              onTap: () =>
                                  context.push('/profile/personal-info'),
                            ),
                            _MenuItem(
                              icon: Icons.currency_exchange_rounded,
                              label: 'Currency',
                              trailing: settings.currency,
                              onTap: () =>
                                  context.push('/profile/currency'),
                            ),
                            _MenuItem(
                              icon: Icons.palette_rounded,
                              label: 'App Theme',
                              trailing: settings.theme.capitalize(),
                              onTap: () => context.push('/profile/theme'),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _Section(title: 'Data & Privacy', items: [
                            _MenuItem(
                              icon: Icons.download_rounded,
                              label: 'Data Export',
                              onTap: () =>
                                  context.push('/profile/data-export'),
                            ),
                            _MenuItem(
                              icon: Icons.security_rounded,
                              label: 'Security',
                              onTap: () =>
                                  context.push('/profile/security'),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _Section(title: 'Support', items: [
                            _MenuItem(
                              icon: Icons.help_rounded,
                              label: 'Help & Support',
                              onTap: () =>
                                  context.push('/profile/support'),
                            ),
                          ]),
                          const SizedBox(height: 24),
                          // Delete Account
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.delete_forever_rounded,
                                  color: AppColors.danger, size: 20),
                              label: const Text('Delete Account',
                                  style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.danger),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: WealthColors.of(context).card,
                                    title: Text('Delete Account',
                                        style: TextStyle(color: WealthColors.of(context).textPrimary)),
                                    content: Text(
                                      'This will permanently delete your account and all your data (assets, liabilities, profile). This cannot be undone.',
                                      style: TextStyle(color: WealthColors.of(context).textSecondary),
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
                                if (ok == true && context.mounted) {
                                  try {
                                    await ref.read(authProvider.notifier).deleteAccount();
                                    if (context.mounted) context.go('/');
                                  } catch (e) {
                                    if (context.mounted) {
                                      final msg = e.toString().contains('requires-recent-login')
                                          ? 'For security, please sign out and sign back in before deleting your account.'
                                          : 'Failed to delete account. Please try again.';
                                      showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          final dc = WealthColors.of(ctx);
                                          return AlertDialog(
                                          backgroundColor: dc.card,
                                          title: Text('Error',
                                              style: TextStyle(color: dc.textPrimary)),
                                          content: Text(msg,
                                              style: TextStyle(color: dc.textSecondary)),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                        },
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Sign Out
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.logout_rounded,
                                  color: AppColors.danger, size: 20),
                              label: const Text('Sign Out',
                                  style:
                                      TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.danger),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) {
                                    final dc = WealthColors.of(ctx);
                                    return AlertDialog(
                                    backgroundColor: dc.card,
                                    title: Text('Sign Out',
                                        style: TextStyle(color: dc.textPrimary)),
                                    content: Text(
                                      'Are you sure you want to sign out?',
                                      style: TextStyle(color: dc.textSecondary),
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
                                        child: const Text('Sign Out',
                                            style: TextStyle(
                                                color: AppColors.danger)),
                                      ),
                                    ],
                                  );
                                  },
                                );
                                if (ok == true && context.mounted) {
                                  await ref.read(authProvider.notifier).signOut();
                                  if (context.mounted) context.go('/');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppBottomNav(currentIndex: 3),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(builder: (context) {
          final c = WealthColors.of(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  title,
                  style: GoogleFonts.manrope(
                    color: c.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.border),
                  boxShadow: c.glowShadow(),
                ),
                child: Column(
                  children: items
                      .asMap()
                      .entries
                      .map((e) => Column(children: [
                            e.value,
                            if (e.key < items.length - 1)
                              Divider(
                                height: 1,
                                color: c.border,
                                indent: 52,
                              ),
                          ]))
                      .toList(),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    color: WealthColors.of(context).textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
            if (trailing != null) ...[
              Text(trailing!,
                  style: TextStyle(
                      color: WealthColors.of(context).textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
            ],
            Icon(Icons.chevron_right_rounded,
                color: WealthColors.of(context).textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

extension StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
