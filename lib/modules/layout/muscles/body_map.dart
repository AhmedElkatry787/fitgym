import 'package:FitGym/core/theme/app_colors.dart';
import 'package:FitGym/model/muscle.dart';
import 'package:flutter/material.dart';

enum BodySide { front, back }

/// The body figure from the design with [highlight], if any, drawn in yellow.
class BodyMap extends StatelessWidget {
  const BodyMap({super.key, required this.side, required this.highlight});

  final BodySide side;
  final Muscle? highlight;

  @override
  Widget build(BuildContext context) {
    final sideLabel = side == BodySide.front ? 'الجسم من الأمام' : 'الجسم من الخلف';
    final highlight = this.highlight;

    return Semantics(
      label: highlight == null ? sideLabel : '$sideLabel، ${highlight.label} متعلّم',
      child: CustomPaint(
        size: const Size(90, 170),
        painter: _BodyPainter(side: side, highlight: highlight),
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  const _BodyPainter({required this.side, required this.highlight});

  final BodySide side;
  final Muscle? highlight;

  @override
  void paint(Canvas canvas, Size size) {
    // Drawn on the design's 90×170 grid.
    canvas.scale(size.width / 90, size.height / 170);

    final base = Paint()..color = AppColors.outline;
    final marked = Paint()..color = AppColors.primary;
    Paint paintFor(Muscle muscle) => highlight == muscle ? marked : base;
    RRect box(double x, double y, double width, double height, double radius) {
      return RRect.fromRectAndRadius(Rect.fromLTWH(x, y, width, height), Radius.circular(radius));
    }

    canvas.drawCircle(const Offset(45, 16), 11, base);
    canvas.drawRect(const Rect.fromLTWH(40, 26, 10, 8), base);
    canvas.drawRRect(box(27, 33, 36, 60, 10), base);

    final arms = paintFor(Muscle.arms);
    canvas.drawRRect(box(13, 44, 11, 54, 5.5), arms);
    canvas.drawRRect(box(66, 44, 11, 54, 5.5), arms);

    final legs = paintFor(Muscle.legs);
    canvas.drawRRect(box(29, 94, 14, 72, 7), legs);
    canvas.drawRRect(box(47, 94, 14, 72, 7), legs);

    if (side == BodySide.front && highlight == Muscle.chest) {
      canvas.drawRRect(box(30, 37, 14.5, 19, 6), marked);
      canvas.drawRRect(box(45.5, 37, 14.5, 19, 6), marked);
    } else if (side == BodySide.front && highlight == Muscle.abs) {
      canvas.drawRRect(box(34, 58, 22, 31, 6), marked);
    } else if (side == BodySide.back && highlight == Muscle.back) {
      canvas.drawRRect(box(30, 37, 30, 46, 9), marked);
    }

    final shoulders = paintFor(Muscle.shoulders);
    canvas.drawOval(Rect.fromCenter(center: const Offset(22, 42), width: 20, height: 18), shoulders);
    canvas.drawOval(Rect.fromCenter(center: const Offset(68, 42), width: 20, height: 18), shoulders);

    final line = Paint()
      ..color = AppColors.outlineSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    if (side == BodySide.front) {
      canvas.drawLine(const Offset(33, 48), const Offset(57, 48), line);
      canvas.drawLine(const Offset(45, 48), const Offset(45, 86), line);
    } else {
      canvas.drawLine(const Offset(45, 36), const Offset(45, 90), line);
    }
  }

  @override
  bool shouldRepaint(_BodyPainter oldDelegate) => oldDelegate.side != side || oldDelegate.highlight != highlight;
}
