import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
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

    final profile = profileAsync.valueOrNull;
    final emojiAvatars = {
      'avatar1': '😎',
      'avatar2': '🦁',
      'avatar3': '🐬',
      'avatar4': '🦊',
      'avatar5': '🤖',
      'avatar6': '🧑‍💼',
    };
    final avatarEmoji = emojiAvatars[profile?.userAvatar] ?? '😎';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        border: const Border(
                          bottom: BorderSide(
                              color: AppColors.surfaceHighlight),
                        ),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: primary, width: 2),
                                ),
                                child: Center(
                                  child: Text(avatarEmoji,
                                      style:
                                          const TextStyle(fontSize: 36)),
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
                                    ),
                                    child: const Icon(Icons.edit_rounded,
                                        color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            profile?.userName ?? 'User',
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Member',
                            style: GoogleFonts.manrope(
                                color: AppColors.greyText, fontSize: 13),
                          ),
                        ],
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
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.logout_rounded,
                                  color: AppColors.danger, size: 20),
                              label: const Text('Sign Out',
                                  style:
                                      TextStyle(color: AppColors.danger)),
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
                                  builder: (_) => AlertDialog(
                                    backgroundColor: AppColors.cardDark,
                                    title: const Text('Sign Out',
                                        style:
                                            TextStyle(color: Colors.white)),
                                    content: const Text(
                                      'Are you sure you want to sign out?',
                                      style: TextStyle(
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
                                        child: const Text('Sign Out',
                                            style: TextStyle(
                                                color: AppColors.danger)),
                                      ),
                                    ],
                                  ),
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
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            title,
            style: GoogleFonts.manrope(
              color: AppColors.greyText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceHighlight),
          ),
          child: Column(
            children: items
                .asMap()
                .entries
                .map((e) => Column(children: [
                      e.value,
                      if (e.key < items.length - 1)
                        const Divider(
                          height: 1,
                          color: AppColors.surfaceHighlight,
                          indent: 52,
                        ),
                    ]))
                .toList(),
          ),
        ),
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
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ),
            if (trailing != null) ...[
              Text(trailing!,
                  style: const TextStyle(
                      color: AppColors.greyText, fontSize: 13)),
              const SizedBox(width: 4),
            ],
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.greyText, size: 20),
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
