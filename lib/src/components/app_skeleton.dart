import 'package:flutter/material.dart';

class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.borderRadius = 8,
  });

  final double height;
  final double width;
  final double borderRadius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller.stop();
      _controller.value = 0.65;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.42,
        end: 0.9,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

class AppCardSkeleton extends StatelessWidget {
  const AppCardSkeleton({super.key, this.rows = 3});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSkeleton(height: 20, width: 150),
            const SizedBox(height: 16),
            for (var index = 0; index < rows; index++) ...[
              AppSkeleton(width: index == rows - 1 ? 190 : double.infinity),
              if (index < rows - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class AppScreenSkeleton extends StatelessWidget {
  const AppScreenSkeleton({super.key, this.showGrid = true});

  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      physics: const NeverScrollableScrollPhysics(),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSkeleton(height: 28, width: 220),
              const SizedBox(height: 10),
              const AppSkeleton(height: 15, width: 300),
              const SizedBox(height: 24),
              if (showGrid)
                GridView.count(
                  crossAxisCount: MediaQuery.sizeOf(context).width >= 700
                      ? 4
                      : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: const [
                    AppSkeleton(height: 110),
                    AppSkeleton(height: 110),
                    AppSkeleton(height: 110),
                    AppSkeleton(height: 110),
                  ],
                ),
              const SizedBox(height: 24),
              const AppSkeleton(height: 20, width: 160),
              const SizedBox(height: 12),
              const AppCardSkeleton(rows: 3),
              const SizedBox(height: 14),
              const AppCardSkeleton(rows: 2),
            ],
          ),
        ),
      ),
    );
  }
}

enum AppSectionSkeletonLayout { calendar, list, profile, report }

/// A first-load skeleton shaped like the section that is about to appear.
class AppSectionSkeleton extends StatelessWidget {
  const AppSectionSkeleton({super.key, required this.layout});

  final AppSectionSkeletonLayout layout;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Loading',
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: switch (layout) {
              AppSectionSkeletonLayout.calendar =>
                const _CalendarSectionSkeleton(),
              AppSectionSkeletonLayout.list => const _ListSectionSkeleton(),
              AppSectionSkeletonLayout.profile =>
                const _ProfileSectionSkeleton(),
              AppSectionSkeletonLayout.report => const _ReportSectionSkeleton(),
            },
          ),
        ),
      ),
    );
  }
}

class _CalendarSectionSkeleton extends StatelessWidget {
  const _CalendarSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('calendar-skeleton-layout'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: AppSkeleton(height: 30)),
            const SizedBox(width: 12),
            AppSkeleton(height: 36, width: 36, borderRadius: 18),
            const SizedBox(width: 8),
            AppSkeleton(height: 36, width: 36, borderRadius: 18),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            for (var index = 0; index < 7; index++) ...[
              Expanded(
                child: AppSkeleton(
                  height: 58,
                  borderRadius: index == 3 ? 14 : 10,
                ),
              ),
              if (index < 6) const SizedBox(width: 6),
            ],
          ],
        ),
        const SizedBox(height: 14),
        const AppSkeleton(height: 56, borderRadius: 14),
        const SizedBox(height: 16),
        Container(
          height: 330,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const AppSkeleton(height: 42, width: 52),
                  const SizedBox(width: 8),
                  for (var index = 0; index < 3; index++) ...[
                    const Expanded(
                      child: AppSkeleton(height: 42, borderRadius: 10),
                    ),
                    if (index < 2) const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              for (var index = 0; index < 5; index++) ...[
                const AppSkeleton(height: 2, borderRadius: 1),
                if (index < 4) const SizedBox(height: 46),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ListSectionSkeleton extends StatelessWidget {
  const _ListSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      key: ValueKey('list-skeleton-layout'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeleton(height: 28, width: 210),
        SizedBox(height: 10),
        AppSkeleton(height: 15, width: 300),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: AppSkeleton(height: 40, borderRadius: 20)),
            SizedBox(width: 8),
            Expanded(child: AppSkeleton(height: 40, borderRadius: 20)),
            SizedBox(width: 8),
            Expanded(child: AppSkeleton(height: 40, borderRadius: 20)),
          ],
        ),
        SizedBox(height: 18),
        AppCardSkeleton(rows: 3),
        SizedBox(height: 12),
        AppCardSkeleton(rows: 3),
        SizedBox(height: 12),
        AppCardSkeleton(rows: 2),
      ],
    );
  }
}

class _ProfileSectionSkeleton extends StatelessWidget {
  const _ProfileSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      key: ValueKey('profile-skeleton-layout'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppSkeleton(height: 88, width: 88, borderRadius: 44),
        SizedBox(height: 14),
        AppSkeleton(height: 24, width: 190),
        SizedBox(height: 8),
        AppSkeleton(height: 14, width: 140),
        SizedBox(height: 24),
        AppCardSkeleton(rows: 4),
        SizedBox(height: 14),
        AppCardSkeleton(rows: 3),
      ],
    );
  }
}

class _ReportSectionSkeleton extends StatelessWidget {
  const _ReportSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    final columns = MediaQuery.sizeOf(context).width >= 700 ? 4 : 2;
    return Column(
      key: const ValueKey('report-skeleton-layout'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSkeleton(height: 28, width: 210),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.7,
          children: const [
            AppSkeleton(borderRadius: 14),
            AppSkeleton(borderRadius: 14),
            AppSkeleton(borderRadius: 14),
            AppSkeleton(borderRadius: 14),
          ],
        ),
        const SizedBox(height: 20),
        const AppSkeleton(height: 250, borderRadius: 16),
        const SizedBox(height: 14),
        const AppCardSkeleton(rows: 3),
      ],
    );
  }
}
