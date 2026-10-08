import 'package:flutter/material.dart';

import '../../../../core/presentation/components/components.dart';
import '../../../../core/theme/app_theme.dart';

class AppWelcomeScreen extends StatelessWidget {
  const AppWelcomeScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/tractor.jpeg',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.20),
                  AppColors.deepGreen.withValues(alpha: 0.32),
                  AppColors.deepGreen.withValues(alpha: 0.78),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BrandMark(),
                  const Spacer(),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Kwanza Track',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Mechanization work planned from real farm plots.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Schedule tractors, guide operators, verify field work, and close jobs with clear accountability.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 28),
                          AppGlowButton(
                            onPressed: onContinue,
                            icon: Icons.arrow_forward,
                            label: 'Get started',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.agriculture, color: AppColors.fieldGreen, size: 20),
            SizedBox(width: 8),
            Text(
              'Mechanization Management',
              style: TextStyle(
                color: AppColors.deepGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
