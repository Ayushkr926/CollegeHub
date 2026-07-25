
import 'package:college/Screen/Auth/widgets/page_indicator.dart';
import 'package:flutter/material.dart';

import '../../utils/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

/// A 3-page onboarding flow introducing the app's core value propositions:
/// discovering events, joining clubs, and (for organizers) managing them.
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
      icon: Icons.explore_outlined,
      title: 'Discover Campus Events',
      subtitle:
          'Explore workshops, hackathons, fests and seminars happening around your campus.',
    ),
    _OnboardingPageData(
      icon: Icons.groups_2_outlined,
      title: 'Join Amazing Clubs',
      subtitle:
          'Become a member of coding, music, robotics, sports and cultural clubs.',
    ),
    _OnboardingPageData(
      icon: Icons.rocket_launch_outlined,
      title: 'Create. Manage. Grow.',
      subtitle:
          'Club organizers can create events, post updates and engage with students.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToWelcome() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _goToWelcome();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.sm,
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLastPage ? 0 : 1,
                  child: TextButton(
                    onPressed: isLastPage ? null : _goToWelcome,
                    child: Text('Skip', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      key: ValueKey(index),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Icon(page.icon, size: 88, color: AppColors.white),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          Text(
                            page.title,
                            style: AppTextStyles.headline,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            page.subtitle,
                            style: AppTextStyles.subtitle,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            PageIndicator(count: _pages.length, currentIndex: _currentPage),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.large),
                    ),
                  ),
                  child: Text(
                    isLastPage ? 'Get Started' : 'Next',
                    style: AppTextStyles.buttonLabel,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
