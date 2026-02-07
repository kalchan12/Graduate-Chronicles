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
import '../ui/auth/admin/screens/admin_login_screen.dart';
import '../ui/auth/admin/screens/admin_signup_screen.dart';
import '../ui/auth/admin/screens/admin_dashboard_screen.dart';
import '../ui/auth/admin/screens/user_monitoring_screen.dart';
import '../ui/auth/admin/screens/yearbook_monitoring_screen.dart';
import '../ui/auth/admin/screens/reports_monitoring_screen.dart';
import '../ui/auth/admin/screens/yearbook_entries_approval_screen.dart';
import '../ui/portfolio/portfolio_management_screen.dart';
import '../messaging/ui/conversations_screen.dart';
import '../ui/community/events/events_screen.dart';
import '../ui/community/events/create_event_screen.dart';

/*
  The root widget of the application.
  
  Responsible for:
  - Initializing the MaterialApp
  - Applying global theme settings
  - Defining the routing map for navigation
*/
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graduate Chronicles',
      theme: DesignSystem.theme,
      debugShowCheckedModeBanner: false,
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
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

        // Admin Routes
        '/admin/login': (_) => const AdminLoginScreen(),
        '/admin/signup': (_) => const AdminSignupScreen(),
        '/admin/dashboard': (_) => const AdminDashboardScreen(),
        '/admin/users': (_) => const UserMonitoringScreen(),
        '/admin/monitoring': (_) => const YearbookMonitoringScreen(),
        '/admin/reports': (_) => const ReportsMonitoringScreen(),
        '/admin/yearbook_entries': (_) => const YearbookEntriesApprovalScreen(),
        '/notifications': (_) => const NotificationScreen(),
        '/messages': (_) => const ConversationsScreen(),
        '/portfolio_management': (_) => const PortfolioManagementScreen(),
        '/community/events': (_) => const EventsScreen(),
        '/community/events/create': (_) => const CreateEventScreen(),
      },
      home: const SplashScreen(),
    );
  }
}
