import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import '../config/theme_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final c = WealthColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        border: Border(
          top: BorderSide(color: c.border, width: 1),
        ),
        boxShadow: c.glowShadow(),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: currentIndex == 0
                    ? Icons.home_rounded
                    : Icons.home_outlined,
                label: 'Home',
                isSelected: currentIndex == 0,
                selectedColor: primary,
                onTap: () => context.go('/dashboard'),
              ),
              _NavItem(
                icon: currentIndex == 1
                    ? Icons.business_center_rounded
                    : Icons.business_center_outlined,
                label: 'Assets',
                isSelected: currentIndex == 1,
                selectedColor: primary,
                onTap: () => context.go('/assets'),
              ),
              _NavItem(
                icon: currentIndex == 2
                    ? Icons.credit_card_rounded
                    : Icons.credit_card_outlined,
                label: 'Debts',
                isSelected: currentIndex == 2,
                selectedColor: primary,
                onTap: () => context.go('/liabilities'),
              ),
              _NavItem(
                icon: currentIndex == 3
                    ? Icons.person_rounded
                    : Icons.person_outline_rounded,
                label: 'Profile',
                isSelected: currentIndex == 3,
                selectedColor: primary,
                onTap: () => context.go('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = WealthColors.of(context);
    final color = isSelected ? selectedColor : c.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
