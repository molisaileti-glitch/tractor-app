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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.42, end: 0.9).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
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
              AppSkeleton(
                width: index == rows - 1 ? 190 : double.infinity,
              ),
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
