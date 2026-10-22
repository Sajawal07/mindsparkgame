import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/game_providers.dart';
import '../../shared/widgets/gradient_scaffold.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _disclaimerAccepted = false;

  static const _slides = [
    _SlideData(
      image: AppAssets.onboardingSlide1,
      title: AppStrings.onboardingTitle1,
      body: AppStrings.onboardingBody1,
    ),
    _SlideData(
      image: AppAssets.onboardingSlide2,
      title: AppStrings.onboardingTitle2,
      body: AppStrings.onboardingBody2,
    ),
    _SlideData(
      image: AppAssets.onboardingSlide3,
      title: AppStrings.onboardingTitle3,
      body: AppStrings.onboardingBody3,
    ),
  ];

  Future<void> _finish() async {
    if (!_disclaimerAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the disclaimer to continue.'),
        ),
      );
      return;
    }
    await ref.read(gameStateProvider).completeOnboarding();
    if (mounted) context.go(AppRoutes.home);
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return GradientScaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _finish,
              child: const Text('Skip'),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.asset(
                          slide.image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.image_outlined,
                            size: 120,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      Text(
                        slide.title,
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        slide.body,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _slides.length,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? AppColors.primary
                      : AppColors.ringEmpty,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          if (isLastPage) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CheckboxListTile(
                value: _disclaimerAccepted,
                onChanged: (v) =>
                    setState(() => _disclaimerAccepted = v ?? false),
                title: Text(
                  AppStrings.iqDisclaimer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryButtonGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(isLastPage ? 'Get Started' : 'Next'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.image,
    required this.title,
    required this.body,
  });

  final String image;
  final String title;
  final String body;
}
