// =============================================
// core/auth/auth_gate.dart
// Routes users to the correct screen based on auth state.
//
// unknown           → Splash (while Firebase resolves initial state)
// loggedOut         → LoginScreen
// needsVerification → VerifyEmailScreen
// authenticated     → MainShell (4 tabs)
// =============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/verify_email_screen.dart';
import '../../screens/main_shell.dart';
import '../../screens/onboarding/mode_selection_screen.dart';
import '../../screens/splash_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    switch (auth.status) {
      case AuthStatus.unknown:
        return const DonguSplash();
      case AuthStatus.loggedOut:
        return const LoginScreen();
      case AuthStatus.needsVerification:
        return const VerifyEmailScreen();
      case AuthStatus.needsOnboarding:
        return const ModeSelectionScreen();
      case AuthStatus.authenticated:
        return const MainShell();
    }
  }
}
