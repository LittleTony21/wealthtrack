import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';

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

  final _emojiAvatars = [
    ('avatar1', '😎'),
    ('avatar2', '🦁'),
    ('avatar3', '🐬'),
    ('avatar4', '🦊'),
    ('avatar5', '🤖'),
    ('avatar6', '🧑‍💼'),
  ];

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

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
                color: AppColors.greyText,
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
                childAspectRatio: 1,
              ),
              itemCount: _emojiAvatars.length,
              itemBuilder: (_, i) {
                final (id, emoji) = _emojiAvatars[i];
                final isSelected = _selectedAvatar == id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primary.withValues(alpha: 0.15)
                          : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? primary
                            : AppColors.surfaceHighlight,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 36)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Display Name',
              style: GoogleFonts.manrope(
                color: AppColors.greyText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Your display name',
                prefixIcon: Icon(Icons.person_rounded,
                    color: AppColors.greyText, size: 20),
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
