import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'config/router.dart';
import 'config/theme.dart';
import 'providers/settings_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/pin_provider.dart';
import 'screens/pin_lock_screen.dart';
import 'widgets/milestone_celebration.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: WealthTrackApp()));
}

class WealthTrackApp extends ConsumerStatefulWidget {
  const WealthTrackApp({super.key});

  @override
  ConsumerState<WealthTrackApp> createState() => _WealthTrackAppState();
}

class _WealthTrackAppState extends ConsumerState<WealthTrackApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    ThemeData theme;
    final accent = settings.accentAsColor;

    switch (settings.theme) {
      case 'light':
        theme = AppTheme.lightTheme(accent: accent);
        break;
      case 'neon':
        theme = AppTheme.neonTheme(
          accent: settings.accentColor != '#05c293'
              ? accent
              : const Color(0xFF00FFB3),
        );
        break;
      case 'custom':
        theme = AppTheme.darkTheme(accent: accent);
        break;
      default:
        theme = AppTheme.darkTheme(accent: accent);
    }

    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final profileAsync = ref.watch(profileProvider);
    final pinUnlocked = ref.watch(pinUnlockedProvider);

    // While profile is loading for a logged-in user, show blank to avoid flash
    if (isLoggedIn && !pinUnlocked && profileAsync.isLoading) {
      return MaterialApp(
        theme: theme,
        debugShowCheckedModeBanner: false,
        home: Scaffold(backgroundColor: theme.scaffoldBackgroundColor),
      );
    }

    // Show PIN lock if enabled and not yet unlocked this session
    final pinEnabled = profileAsync.valueOrNull?.pinEnabled ?? false;
    if (isLoggedIn && pinEnabled && !pinUnlocked) {
      return MaterialApp(
        theme: theme,
        debugShowCheckedModeBanner: false,
        home: const PinLockScreen(),
      );
    }

    return MaterialApp.router(
      title: 'WealthTrack',
      theme: theme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Stack(
        children: [
          child!,
          const MilestoneCelebrationLayer(),
        ],
      ),
    );
  }
}
