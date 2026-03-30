import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/avatars.dart';
import '../config/theme.dart';
import '../config/theme_colors.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../services/premium_service.dart';
import '../widgets/premium_sheet.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() =>
      _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  late TextEditingController _nameCtrl;
  String? _selectedAvatar;
  bool _loading = false;
  bool _init = false;


  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _initFromProfile() {
    if (_init) return;
    _init = true;
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile != null) {
      _nameCtrl.text = profile.userName;
      _selectedAvatar = profile.userAvatar;
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final existing = ref.read(profileProvider).valueOrNull;
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final profile = existing ??
          UserProfile(id: uid, userName: '', userAvatar: 'avatar1');
      final updated = profile.copyWith(
        userName: _nameCtrl.text.trim(),
        userAvatar: _selectedAvatar ?? profile.userAvatar,
      );
      await ref.read(profileProvider.notifier).update(updated);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _initFromProfile();
    final primary = Theme.of(context).primaryColor;
    final c = WealthColors.of(context);
    final hasAvatarAccess =
        ref.watch(premiumAccessProvider(PremiumFeature.avatars));

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('Personal Info'),
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
              'Choose Avatar',
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
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: kAvatarList.length,
              itemBuilder: (_, i) {
                final av = kAvatarList[i];
                final isSelected = _selectedAvatar == av.id;
                final isLocked = !hasAvatarAccess && av.id != 'avatar1';
                return GestureDetector(
                  onTap: () {
                    if (isLocked) {
                      showPremiumSheet(context,
                          featureKey: PremiumFeature.avatars);
                      return;
                    }
                    setState(() => _selectedAvatar = av.id);
                  },
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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Opacity(
                          opacity: isLocked ? 0.4 : 1.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.asset(
                                  av.path,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: primary.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        av.name[0],
                                        style: TextStyle(
                                            fontSize: 22,
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
                                    color: c.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isLocked)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: c.textSecondary.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.lock_rounded,
                                  color: Colors.white, size: 10),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Display Name',
              style: GoogleFonts.manrope(
                color: c.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              style: TextStyle(color: c.textPrimary),
              decoration: InputDecoration(
                hintText: 'Your display name',
                prefixIcon: Icon(Icons.person_rounded,
                    color: c.textSecondary, size: 20),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
