import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'config/router.dart';
import 'config/theme.dart';
import 'providers/settings_provider.dart';
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

    return MaterialApp.router(
      title: 'WealthTrack',
      theme: theme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
