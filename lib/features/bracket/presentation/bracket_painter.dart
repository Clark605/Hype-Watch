import 'package:flutter/material.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';

/// Draws bracket connector lines between two adjacent round columns.
///
/// For each pair of left-column cards, it draws:
///   - A short horizontal stub out of each left card's right edge
///   - A vertical bar joining the two stubs
///   - A horizontal line from the midpoint of that bar to the right card
class BracketPainter extends CustomPainter {
  /// Y-centers of cards in the feeder (left) column, in canvas coordinates.
  final List<double> leftCenters;

  /// Y-centers of cards in the output (right) column, in canvas coordinates.
  final List<double> rightCenters;

  /// Full width of this painter's zone (= _colGap from bracket_screen).
  final double gapWidth;

  const BracketPainter({
    required this.leftCenters,
    required this.rightCenters,
    required this.gapWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.65)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final stubLen = gapWidth * 0.38;

    for (var r = 0; r < rightCenters.length; r++) {
      final l1 = r * 2;
      final l2 = r * 2 + 1;
      if (l2 >= leftCenters.length) break;

      final topY = leftCenters[l1];
      final botY = leftCenters[l2];
      final midY = (topY + botY) / 2;
      final rightY = rightCenters[r];

      final path = Path();

      // Top horizontal stub
      path.moveTo(0, topY);
      path.lineTo(stubLen, topY);

      // Vertical bar connecting top stub to bottom stub
      path.moveTo(stubLen, topY);
      path.lineTo(stubLen, botY);

      // Bottom horizontal stub
      path.moveTo(0, botY);
      path.lineTo(stubLen, botY);

      // Bridge from midpoint to right card center
      path.moveTo(stubLen, midY);
      path.lineTo(gapWidth, rightY);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(BracketPainter oldDelegate) =>
      oldDelegate.leftCenters != leftCenters ||
      oldDelegate.rightCenters != rightCenters ||
      oldDelegate.gapWidth != gapWidth;
}
