import 'package:flutter/material.dart';

class AppWelcomeScreen extends StatelessWidget {
  const AppWelcomeScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/tractor.jpeg',
            fit: BoxFit.cover,
            alignment: size.width > 700
                ? Alignment.centerRight
                : Alignment.center,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFFFF3D6).withValues(alpha: 0.08),
                  const Color(0xFFF6DBA6).withValues(alpha: 0.40),
                  const Color(0xFFF2C978).withValues(alpha: 0.88),
                ],
                stops: const [0.0, 0.48, 1.0],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF26553C).withValues(alpha: 0.48),
                  Colors.transparent,
                ],
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Shamba Bora',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: const Color(0xFF173B2A),
                                  fontWeight: FontWeight.w900,
                                  height: 0.95,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tractor services planned from real farm plots.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: const Color(0xFF214634),
                                  fontWeight: FontWeight.w800,
                                  height: 1.12,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Register land boundaries, request mechanization, track assigned operators, and confirm completed work even before full backend sync.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: const Color(0xFF31513D),
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 20),
                          const _TrustRow(),
                          const SizedBox(height: 22),
                          FilledButton.icon(
                            onPressed: onContinue,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Get started'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2F6F4E),
                              foregroundColor: const Color(0xFFFFF8E8),
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
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
        color: const Color(0xFFFFF4D9).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.agriculture, color: Color(0xFF2F6F4E), size: 20),
            SizedBox(width: 8),
            Text(
              'Mechanization Management',
              style: TextStyle(
                color: Color(0xFF214634),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: const [
        _TrustChip(icon: Icons.offline_bolt_outlined, label: 'Offline first'),
        _TrustChip(icon: Icons.gps_fixed, label: 'GPS verified'),
        _TrustChip(icon: Icons.groups_outlined, label: 'Union managed'),
      ],
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF9B6A20).withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF2F6F4E)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF274935),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
