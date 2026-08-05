import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';

/// Chibi rider marker for the trip playback animation: a custom-painted
/// cartoon driver with true chibi proportions (oversized helmeted head,
/// tiny body) on a scooter whose wheels actually spin. The rider bobs on
/// the suspension while riding and always faces the direction of travel.
///
/// Painted rather than emoji-based so it looks identical on every device
/// and each style reads clearly:
///  * normal — teal helmet + sunglasses;
///  * cute   — pink helmet, blushing cheeks, heart-shaped exhaust puffs;
///  * fierce — black helmet with red stripe and little devil horns.
class RiderAvatar extends StatefulWidget {
  const RiderAvatar({
    super.key,
    required this.style,
    this.size = 56,
    this.bearingRadians = 0,
    this.animate = true,
  });

  final RiderStyle style;
  final double size;

  /// Travel direction (0 = north, clockwise); the rider is flipped so it
  /// never drives backwards.
  final double bearingRadians;

  final bool animate;

  @override
  State<RiderAvatar> createState() => _RiderAvatarState();
}

class _RiderAvatarState extends State<RiderAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _t.repeat();
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The painter draws the rider facing east; flip when heading west.
    final headingWest = math.sin(widget.bearingRadians) < 0;
    return Transform.flip(
      flipX: headingWest,
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _ChibiRiderPainter(
            style: widget.style,
            t: widget.animate ? _t.value : 0,
            animate: widget.animate,
          ),
        ),
      ),
    );
  }
}

class _ChibiRiderPainter extends CustomPainter {
  const _ChibiRiderPainter({
    required this.style,
    required this.t,
    required this.animate,
  });

  final RiderStyle style;

  /// Animation phase 0..1 (wheel spin, bob, puffs).
  final double t;

  final bool animate;

  // Style palette.
  Color get _helmet => switch (style) {
    RiderStyle.normal => const Color(0xFF009688),
    RiderStyle.cute => const Color(0xFFF48FB1),
    RiderStyle.fierce => const Color(0xFF263238),
  };

  Color get _helmetDark => switch (style) {
    RiderStyle.normal => const Color(0xFF00695C),
    RiderStyle.cute => const Color(0xFFEC407A),
    RiderStyle.fierce => const Color(0xFF102027),
  };

  Color get _jacket => switch (style) {
    RiderStyle.normal => const Color(0xFF0A1F2E),
    RiderStyle.cute => const Color(0xFFCE93D8),
    RiderStyle.fierce => const Color(0xFF4E342E),
  };

  Color get _scooter => switch (style) {
    RiderStyle.normal => const Color(0xFF00B4D8),
    RiderStyle.cute => const Color(0xFF80CBC4),
    RiderStyle.fierce => const Color(0xFFE53935),
  };

  static const _skin = Color(0xFFFFCC9C);
  static const _tire = Color(0xFF37474F);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    canvas.scale(s);
    final bob = animate ? math.sin(t * 2 * math.pi) * 1.6 : 0.0;

    _paintShadow(canvas);
    _paintPuffs(canvas);
    _paintScooter(canvas, bob);
    _paintRider(canvas, bob);
    _paintWheels(canvas);
  }

  void _paintShadow(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(52, 93), width: 68, height: 9),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
  }

  /// Exhaust puffs drifting away behind the scooter — grey smoke normally,
  /// pink hearts for the cute style, dark smoke for fierce.
  void _paintPuffs(Canvas canvas) {
    if (!animate) return;
    final color = switch (style) {
      RiderStyle.normal => Colors.blueGrey.shade300,
      RiderStyle.cute => const Color(0xFFF06292),
      RiderStyle.fierce => Colors.blueGrey.shade700,
    };
    for (var i = 0; i < 3; i++) {
      final phase = (t + i / 3) % 1.0;
      final alpha = (1 - phase) * 0.55;
      if (alpha <= 0.02) continue;
      final center = Offset(16 - phase * 14, 74 - phase * 10);
      final puffSize = 2.5 + phase * 3.5;
      final paint = Paint()..color = color.withValues(alpha: alpha);
      if (style == RiderStyle.cute) {
        _drawHeart(canvas, center, puffSize, paint);
      } else {
        canvas.drawCircle(center, puffSize, paint);
      }
    }
    // Speed lines behind the rider.
    final line = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.35)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final shift = t * 6;
    canvas.drawLine(Offset(2 - shift, 48), Offset(14 - shift, 48), line);
    canvas.drawLine(Offset(6 - shift, 58), Offset(16 - shift, 58), line);
  }

  void _drawHeart(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path()
      ..moveTo(c.dx, c.dy + r)
      ..cubicTo(
        c.dx - 1.6 * r,
        c.dy,
        c.dx - r,
        c.dy - 1.2 * r,
        c.dx,
        c.dy - 0.3 * r,
      )
      ..cubicTo(c.dx + r, c.dy - 1.2 * r, c.dx + 1.6 * r, c.dy, c.dx, c.dy + r);
    canvas.drawPath(path, paint);
  }

  void _paintScooter(Canvas canvas, double bob) {
    final body = Paint()
      ..color = _scooter
      ..strokeCap = StrokeCap.round;

    // Deck between the wheels.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(28, 72 + bob * 0.4, 64, 79),
        const Radius.circular(3.5),
      ),
      body,
    );
    // Front column up to the handlebar.
    canvas.drawLine(
      Offset(62, 75),
      Offset(78, 52 + bob * 0.5),
      body
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.5,
    );
    // Handlebar grip.
    canvas.drawCircle(
      Offset(79, 50 + bob * 0.5),
      3.4,
      Paint()..color = _helmetDark,
    );
    // Seat.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(24, 60 + bob, 44, 67 + bob),
        const Radius.circular(3.5),
      ),
      Paint()..color = _jacket,
    );
    // Headlight.
    canvas.drawCircle(
      const Offset(72, 60),
      2.6,
      Paint()..color = const Color(0xFFFFF176),
    );
  }

  void _paintRider(Canvas canvas, double bob) {
    final limb = Paint()
      ..color = _jacket
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final hip = Offset(33, 60 + bob);
    final shoulder = Offset(47, 43 + bob);
    // Leg to the deck footrest.
    canvas.drawLine(hip, Offset(50, 72 + bob * 0.4), limb);
    // Torso leaning forward.
    canvas.drawLine(hip, shoulder, limb..strokeWidth = 9);
    // Arm reaching the handlebar.
    canvas.drawLine(
      shoulder,
      Offset(76, 50 + bob * 0.5),
      limb..strokeWidth = 5,
    );

    // --- oversized chibi head ---
    final head = Offset(53, 25 + bob);
    const r = 16.5;
    // Helmet shell.
    canvas.drawCircle(head, r, Paint()..color = _helmet);
    // Face opening: skin patch toward the front of the helmet.
    canvas.drawOval(
      Rect.fromCenter(
        center: head + const Offset(8, 4.5),
        width: 15,
        height: 14,
      ),
      Paint()..color = _skin,
    );
    // Helmet brim above the face.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: head + const Offset(8.5, -5.5),
          width: 14,
          height: 4.6,
        ),
        const Radius.circular(2.3),
      ),
      Paint()..color = _helmetDark,
    );

    switch (style) {
      case RiderStyle.normal:
        // Sunglasses.
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: head + const Offset(9, 1.5),
              width: 11,
              height: 4.4,
            ),
            const Radius.circular(2.2),
          ),
          Paint()..color = const Color(0xFF102027),
        );
        _smile(canvas, head + const Offset(9, 7));
      case RiderStyle.cute:
        // Big sparkly eye.
        final eye = head + const Offset(10, 2);
        canvas.drawCircle(eye, 2.6, Paint()..color = const Color(0xFF37474F));
        canvas.drawCircle(
          eye + const Offset(0.9, -0.9),
          0.9,
          Paint()..color = Colors.white,
        );
        // Blush.
        canvas.drawCircle(
          head + const Offset(5.5, 7),
          2.2,
          Paint()..color = const Color(0xFFF48FB1).withValues(alpha: 0.8),
        );
        _smile(canvas, head + const Offset(10.5, 7.5));
      case RiderStyle.fierce:
        // Red racing stripe on the helmet.
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: head + const Offset(-3, -9),
              width: 12,
              height: 4,
            ),
            const Radius.circular(2),
          ),
          Paint()..color = const Color(0xFFE53935),
        );
        // Little devil horns.
        final horn = Paint()..color = const Color(0xFFE53935);
        canvas.drawPath(
          Path()
            ..moveTo(head.dx - 10, head.dy - 11)
            ..lineTo(head.dx - 14, head.dy - 19)
            ..lineTo(head.dx - 5, head.dy - 14)
            ..close(),
          horn,
        );
        canvas.drawPath(
          Path()
            ..moveTo(head.dx + 2, head.dy - 15)
            ..lineTo(head.dx + 4, head.dy - 23)
            ..lineTo(head.dx + 9, head.dy - 12)
            ..close(),
          horn,
        );
        // Angry eyebrow + eye.
        final brow = Paint()
          ..color = const Color(0xFF102027)
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          head + const Offset(5.5, -1.5),
          head + const Offset(12, 0.5),
          brow,
        );
        canvas.drawCircle(
          head + const Offset(10, 3),
          2.0,
          Paint()..color = const Color(0xFF102027),
        );
        // Gritted flat mouth.
        canvas.drawLine(
          head + const Offset(6.5, 8),
          head + const Offset(12.5, 8),
          brow..strokeWidth = 1.6,
        );
    }
  }

  void _smile(Canvas canvas, Offset center) {
    canvas.drawArc(
      Rect.fromCenter(center: center, width: 5.5, height: 4),
      0.3,
      math.pi - 0.6,
      false,
      Paint()
        ..color = const Color(0xFF6D4C41)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintWheels(Canvas canvas) {
    for (final center in const [Offset(30, 81), Offset(76, 81)]) {
      canvas.drawCircle(center, 10.5, Paint()..color = _tire);
      canvas.drawCircle(center, 5.2, Paint()..color = const Color(0xFFCFD8DC));
      // Spinning spokes.
      final angle = t * 2 * math.pi * 2;
      final spoke = Paint()
        ..color = _tire
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 2; i++) {
        final a = angle + i * math.pi / 2;
        canvas.drawLine(
          center + Offset(math.cos(a), math.sin(a)) * 4.4,
          center - Offset(math.cos(a), math.sin(a)) * 4.4,
          spoke,
        );
      }
      canvas.drawCircle(center, 1.6, Paint()..color = _tire);
    }
  }

  @override
  bool shouldRepaint(_ChibiRiderPainter old) =>
      old.t != t || old.style != style || old.animate != animate;
}
