import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/welcome_screen.dart';
import '../screens/auth_selection_screen.dart';
import '../screens/signin_selection_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/assets_screen.dart';
import '../screens/liabilities_screen.dart';
import '../screens/add_asset_screen.dart';
import '../screens/add_liability_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/personal_info_screen.dart';
import '../screens/currency_screen.dart';
import '../screens/app_theme_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/data_export_screen.dart';
import '../screens/security_screen.dart';
import '../screens/support_screen.dart';
import '../screens/pin_lock_screen.dart';
import '../screens/verify_email_screen.dart';
import '../models/asset.dart';
import '../models/liability.dart';

class _GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _sub;

  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: _GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final path = state.matchedLocation;

      const authOnlyPaths = {'/', '/auth', '/login', '/signup', '/onboarding'};
      final isProtected = path == '/dashboard' ||
          path == '/assets' ||
          path == '/liabilities' ||
          path == '/add-asset' ||
          path == '/add-liability' ||
          path == '/notifications' ||
          path.startsWith('/profile');

      if (!isLoggedIn && isProtected) return '/';
      if (isLoggedIn && authOnlyPaths.contains(path)) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthSelectionScreen()),
      GoRoute(path: '/signin', builder: (_, __) => const SignInSelectionScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
      GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerifyEmailScreen(email: email);
        },
      ),
      GoRoute(
          path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: HomeScreen()),
      ),
      GoRoute(
        path: '/assets',
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: AssetsScreen()),
      ),
      GoRoute(
        path: '/liabilities',
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: LiabilitiesScreen()),
      ),
      GoRoute(
        path: '/add-asset',
        builder: (context, state) {
          final asset = state.extra as Asset?;
          return AddAssetScreen(existingAsset: asset);
        },
      ),
      GoRoute(
        path: '/add-liability',
        builder: (context, state) {
          final liability = state.extra as Liability?;
          return AddLiabilityScreen(existingLiability: liability);
        },
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: ProfileScreen()),
      ),
      GoRoute(
          path: '/profile/personal-info',
          builder: (_, __) => const PersonalInfoScreen()),
      GoRoute(
          path: '/profile/currency',
          builder: (_, __) => const CurrencyScreen()),
      GoRoute(
          path: '/profile/theme',
          builder: (_, __) => const AppThemeScreen()),
      GoRoute(
          path: '/profile/data-export',
          builder: (_, __) => const DataExportScreen()),
      GoRoute(
          path: '/profile/security',
          builder: (_, __) => const SecurityScreen()),
      GoRoute(
          path: '/profile/support',
          builder: (_, __) => const SupportScreen()),
      GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationsScreen()),
      GoRoute(
          path: '/pin-lock', builder: (_, __) => const PinLockScreen()),
    ],
  );
}
