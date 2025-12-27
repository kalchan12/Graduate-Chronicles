import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import '../screens/screens.dart';
import '../ui/onboarding/onboarding1_screen.dart';
import '../ui/mentorship/mentorship_home_screen.dart';
import '../ui/mentorship/find_mentorship_screen.dart';
import '../ui/mentorship/my_mentorship_screen.dart';
import '../ui/reunion/reunion_hub_screen.dart';
import '../ui/reunion/find_join_reunion_screen.dart';
import '../ui/reunion/reunion_event_details_screen.dart';
import '../ui/reunion/my_reunions_screen.dart';
import '../ui/reunion/reunion_gallery_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

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
        '/mentorship': (_) => const MentorshipHomeScreen(),
        '/mentorship/find': (_) => const FindMentorshipScreen(),
        '/mentorship/my': (_) => const MyMentorshipScreen(),
        '/reunion': (_) => const ReunionHubScreen(),
        '/reunion/find': (_) => const FindJoinReunionScreen(),
        '/reunion/details': (_) => const ReunionEventDetailsScreen(),
        '/reunion/my': (_) => const MyReunionsScreen(),
        '/reunion/gallery': (_) => const ReunionGalleryScreen(),
      },
      home: const SplashScreen(),
    );
  }
}
