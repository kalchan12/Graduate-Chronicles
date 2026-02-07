import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import '../../services/local/onboarding_storage.dart';

/// Unified Onboarding Screen with swipeable pages.
///
/// Features:
/// - PageView for swipe navigation between 3 pages
/// - Responsive layout that adapts to different screen sizes
/// - Persistent one-time display (only shows on first install)
/// - Skip, Back/Next navigation controls
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPageData(
      image: 'assets/images/onboarding_1.png',
      title: 'Your Legacy Starts Here.',
      description:
          'Capture your university moments, from late-night study sessions to graduation day, all in one place.',
    ),
    _OnboardingPageData(
      image: 'assets/images/onboarding_2.png',
      title: 'Connect, Share, Thrive.',
      description:
          'Build your professional network, share your academic journey, and find opportunities within your university community.',
    ),
    _OnboardingPageData(
      image: 'assets/images/onboarding_3.png',
      title: 'Relive Your Uni Days.',
      description:
          'Access your digital yearbook, find photos with friends, and rediscover shared memories from your time at university.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    await OnboardingStorage.markCompleted();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.purpleDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E0F3A), DesignSystem.purpleDark],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive sizing based on available height
              final availableHeight = constraints.maxHeight;
              final isSmallScreen = availableHeight < 600;

              // Calculate image height proportionally (40% of available height, min 180, max 320)
              final imageHeight = (availableHeight * 0.4).clamp(180.0, 320.0);

              // Reduce spacing on smaller screens
              final topSpacing = isSmallScreen ? 8.0 : 24.0;
              final imageTextSpacing = isSmallScreen ? 24.0 : 48.0;
              final textDotsSpacing = isSmallScreen ? 16.0 : 32.0;
              final bottomPadding = isSmallScreen ? 12.0 : 24.0;

              return Column(
                children: [
                  SizedBox(height: topSpacing),

                  // PageView for swipeable content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        final page = _pages[index];
                        return _OnboardingPageContent(
                          data: page,
                          imageHeight: imageHeight,
                          imageTextSpacing: imageTextSpacing,
                          textDotsSpacing: textDotsSpacing,
                          isSmallScreen: isSmallScreen,
                        );
                      },
                    ),
                  ),

                  // Dot Indicators
                  Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _Dot(active: index == _currentPage),
                        ),
                      ),
                    ),
                  ),

                  // Navigation buttons - Always visible at bottom
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: bottomPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left button: Skip on first page, Back arrow on others
                        if (_currentPage == 0)
                          TextButton(
                            onPressed: _completeOnboarding,
                            child: Text(
                              'Skip',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white54,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          )
                        else
                          IconButton(
                            onPressed: () => _goToPage(_currentPage - 1),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                            ),
                            iconSize: 24,
                            splashRadius: 24,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),

                        // Right button: Next arrow or Get Started on last page
                        if (_currentPage == _pages.length - 1)
                          ElevatedButton(
                            onPressed: _completeOnboarding,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignSystem.purpleAccent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 24 : 32,
                                vertical: isSmallScreen ? 12 : 16,
                              ),
                              elevation: 8,
                              shadowColor: DesignSystem.purpleAccent.withValues(
                                alpha: 0.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          IconButton(
                            onPressed: () => _goToPage(_currentPage + 1),
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                            iconSize: 24,
                            splashRadius: 24,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Data model for onboarding page content
class _OnboardingPageData {
  final String image;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.image,
    required this.title,
    required this.description,
  });
}

/// Content widget for a single onboarding page
class _OnboardingPageContent extends StatelessWidget {
  final _OnboardingPageData data;
  final double imageHeight;
  final double imageTextSpacing;
  final double textDotsSpacing;
  final bool isSmallScreen;

  const _OnboardingPageContent({
    required this.data,
    required this.imageHeight,
    required this.imageTextSpacing,
    required this.textDotsSpacing,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Artwork
            Container(
              height: imageHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: DesignSystem.purpleAccent.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(data.image, fit: BoxFit.cover),
                    // Gradient Overlay for blending
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            DesignSystem.purpleDark.withOpacity(0.3),
                            DesignSystem.purpleDark.withOpacity(0.8),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: imageTextSpacing),

            // Title
            Text(
              data.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: isSmallScreen ? 22 : null,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 8 : 16),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                data.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: isSmallScreen ? 13 : null,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: textDotsSpacing),
          ],
        ),
      ),
    );
  }
}

/// Animated dot indicator
class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({this.active = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? DesignSystem.purpleAccent : Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
