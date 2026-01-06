import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import '../screens/screens.dart';
import '../ui/community/mentorship/mentorship_screen.dart';
import '../ui/community/reunion/reunion_list_screen.dart';
import '../ui/community/reunion/reunion_create_screen.dart';
import '../ui/auth/forgot/forgot_password_screen.dart';
import '../ui/auth/forgot/password_reset_screen.dart';
import '../ui/auth/forgot/set_new_password_screen.dart';
import '../ui/auth/forgot/password_updated_screen.dart';
import '../ui/auth/admin/admin_dashboard_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graduate Chronicles',
      theme: DesignSystem.theme,
      debugShowCheckedModeBanner: false,
      routes: {
        '/onboarding1': (_) => const Onboarding1Screen(),
        '/onboarding2': (_) => const Onboarding2Screen(),
        '/onboarding3': (_) => const Onboarding3Screen(),
        '/login': (_) => const LoginScreen(),
        '/signup1': (_) => const SignupStep1(),
        '/signup2': (_) => const SignupStep2(),
        '/signup3': (_) => const SignupStep3(),
        '/signup4': (_) => const SignupStep4(),
        '/app': (_) => const BottomNavigationScaffold(),
        '/community/mentorship': (_) => const MentorshipScreen(),
        '/community/reunion': (_) => const ReunionListScreen(),
        '/community/reunion/create': (_) => const ReunionCreateScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/forgot/verify': (_) => const PasswordResetScreen(),
        '/forgot/set': (_) => const SetNewPasswordScreen(),
        '/forgot/done': (_) => const PasswordUpdatedScreen(),
        '/admin': (_) => const AdminDashboardScreen(),
        '/notifications': (_) => const NotificationScreen(),
        '/messages': (_) => const MessageListScreen(),
      },
      home: const SplashScreen(),
    );
  }
}
