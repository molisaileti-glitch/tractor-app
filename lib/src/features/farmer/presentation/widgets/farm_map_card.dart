import 'package:flutter/material.dart';

class FarmMapCard extends StatelessWidget {
  const FarmMapCard({super.key, this.showTractor = false, this.pointCount = 4});

  final bool showTractor;
  final int pointCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1.55,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE6EFE8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _MapPainter(
                  color: scheme.primary,
                  pointCount: pointCount,
                ),
              ),
            ),
            if (showTractor)
              Positioned(
                top: 28,
                left: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.agriculture, size: 28),
                  ),
                ),
              ),
            Center(
              child: Text(
                'FARM BOUNDARY',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                  color: const Color(0xFF284437),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.color, required this.pointCount});

  final Color color;
  final int pointCount;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.24, size.height * 0.25)
      ..lineTo(size.width * 0.72, size.height * 0.20)
      ..lineTo(size.width * 0.80, size.height * 0.70)
      ..lineTo(size.width * 0.30, size.height * 0.78)
      ..close();

    final fill = Paint()..color = color.withValues(alpha: 0.14);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    final points = [
      Offset(size.width * 0.24, size.height * 0.25),
      Offset(size.width * 0.72, size.height * 0.20),
      Offset(size.width * 0.80, size.height * 0.70),
      Offset(size.width * 0.30, size.height * 0.78),
    ];
    final markerFill = Paint()..color = Colors.white;
    final markerStroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (final point in points.take(pointCount.clamp(0, 4))) {
      canvas.drawCircle(point, 8, markerFill);
      canvas.drawCircle(point, 8, markerStroke);
    }

    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.52)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.pointCount != pointCount;
  }
}
