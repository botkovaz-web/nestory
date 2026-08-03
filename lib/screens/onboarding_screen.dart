import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/database_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<OnboardingData> pages = [
      OnboardingData(
        title: l10n.onboarding1Title,
        description: l10n.onboarding1Desc,
        image: 'assets/nesti_happy.png',
      ),
      OnboardingData(
        title: l10n.onboarding2Title,
        description: l10n.onboarding2Desc,
        image: 'assets/nesti_organizing.png',
      ),
      OnboardingData(
        title: l10n.onboarding3Title,
        description: l10n.onboarding3Desc,
        image: 'assets/nesti_in_basket.png',
      ),
      OnboardingData(
        title: l10n.onboarding4Title,
        description: l10n.onboarding4Desc,
        image: 'assets/nesty_stats.png',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(l10n.skip, style: TextStyle(color: theme.colorScheme.primary)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(pages[index].image, height: 200),
                        const SizedBox(height: 40),
                        Text(
                          pages[index].title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          pages[index].description,
                          style: TextStyle(fontSize: 16, color: isDark ? AppColors.textDark.withAlpha(180) : Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? theme.colorScheme.primary : theme.colorScheme.primary.withAlpha(50),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == pages.length - 1) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 50),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_currentPage == pages.length - 1 ? l10n.onboardingDone : l10n.next),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _finishOnboarding() async {
    await DatabaseService().completeOnboarding();
    widget.onDone();
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;
  OnboardingData({required this.title, required this.description, required this.image});
}
