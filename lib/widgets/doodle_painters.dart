import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Painter that renders the classic squared school notebook paper
class NotebookPaperPainter extends CustomPainter {
  final double gridSize;
  final bool showMargin;
  final bool showHoles;

  const NotebookPaperPainter({
    this.gridSize = 22.0,
    this.showMargin = true,
    this.showHoles = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Paper Base Fill
    final paperPaint = Paint()..color = AppTheme.paperBackground;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paperPaint);

    // 2. Notebook Grid Lines (Blue Squares)
    final gridPaint = Paint()
      ..color = AppTheme.paperGridLine
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3. School Red Margin Line
    if (showMargin) {
      final marginX = 36.0;
      final marginPaint = Paint()
        ..color = AppTheme.paperMarginLine
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(marginX, 0), Offset(marginX, size.height), marginPaint);
    }

    // 4. Notebook Binder Rings / Holes (Far Left)
    if (showHoles) {
      final holePaint = Paint()..color = AppTheme.paperHoles;
      final holeBorderPaint = Paint()
        ..color = AppTheme.penBlack.withValues(alpha: 0.15)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      final holeRadius = 5.0;
      final holeX = 14.0;
      final step = size.height / 6;

      for (int i = 1; i < 6; i++) {
        final cy = step * i;
        canvas.drawCircle(Offset(holeX, cy), holeRadius, holePaint);
        canvas.drawCircle(Offset(holeX, cy), holeRadius, holeBorderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant NotebookPaperPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize ||
        oldDelegate.showMargin != showMargin ||
        oldDelegate.showHoles != showHoles;
  }
}

/// Custom diagonal ballpoint pen hatching fill (Crosshatch / Sea Battle 2 ship style)
class PenHatchPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double strokeWidth;
  final bool crossHatch;
  final double borderRadius;

  const PenHatchPainter({
    required this.color,
    this.spacing = 6.0,
    this.strokeWidth = 1.2,
    this.crossHatch = false,
    this.borderRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    canvas.save();
    canvas.clipRRect(rrect);

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final totalLength = size.width + size.height;

    // Diagonal lines from bottom-left to top-right
    for (double i = -size.height; i <= totalLength; i += spacing) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }

    // Cross hatching if enabled
    if (crossHatch) {
      for (double i = -size.height; i <= totalLength; i += spacing) {
        canvas.drawLine(
          Offset(i, 0),
          Offset(i + size.height, size.height),
          paint,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PenHatchPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.spacing != spacing ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.crossHatch != crossHatch;
  }
}

/// Hand-drawn sketch border painter with slight wobble / double line effect
class DoodleBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final bool isDoubleLine;

  const DoodleBorderPainter({
    required this.color,
    this.strokeWidth = 1.8,
    this.borderRadius = 10.0,
    this.isDoubleLine = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.5, 0.5, size.width - 1.0, size.height - 1.0);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(rrect, paint);

    if (isDoubleLine) {
      final innerRect = Rect.fromLTWH(2.5, 2.5, size.width - 5.0, size.height - 5.0);
      final innerRrect = RRect.fromRectAndRadius(innerRect, Radius.circular(max(1.0, borderRadius - 2)));
      final innerPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..strokeWidth = max(0.8, strokeWidth * 0.6)
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(innerRrect, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DoodleBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.isDoubleLine != isDoubleLine;
  }
}

/// Reusable background wrapper with the school notebook paper
class NotebookPaperBackground extends StatelessWidget {
  final Widget child;
  final bool showMargin;
  final bool showHoles;

  const NotebookPaperBackground({
    super.key,
    required this.child,
    this.showMargin = true,
    this.showHoles = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: NotebookPaperPainter(
        showMargin: showMargin,
        showHoles: showHoles,
      ),
      child: child,
    );
  }
}
