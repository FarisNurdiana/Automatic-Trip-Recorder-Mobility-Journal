import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/traffic_sign.dart';

/// Ilustrasi rambu yang digambar sendiri dengan CustomPaint mengikuti bentuk
/// dan warna dasar per kategori (Permenhub PM 13/2014):
///  * peringatan — belah ketupat kuning tepi hitam;
///  * larangan — lingkaran putih tepi merah;
///  * perintah — lingkaran biru;
///  * petunjuk — persegi biru;
///  * sementara — belah ketupat oranye;
///  * marka — persegi abu gelap (representasi permukaan jalan).
class SignIllustration extends StatelessWidget {
  const SignIllustration({super.key, required this.sign, this.size = 96});

  final TrafficSign sign;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _SignPainter(sign));
  }
}

class _SignPainter extends CustomPainter {
  _SignPainter(this.sign);

  final TrafficSign sign;

  static const _yellow = Color(0xFFFFC107);
  static const _red = Color(0xFFD32F2F);
  static const _blue = Color(0xFF1565C0);
  static const _orange = Color(0xFFF57C00);
  static const _asphalt = Color(0xFF37474F);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final s = size.shortestSide;

    switch (sign.category) {
      case TrafficSignCategory.peringatan:
      case TrafficSignCategory.sementara:
        final color = sign.category == TrafficSignCategory.peringatan
            ? _yellow
            : _orange;
        final diamond = Path()
          ..moveTo(center.dx, rect.top + s * 0.04)
          ..lineTo(rect.right - s * 0.04, center.dy)
          ..lineTo(center.dx, rect.bottom - s * 0.04)
          ..lineTo(rect.left + s * 0.04, center.dy)
          ..close();
        canvas.drawPath(diamond, Paint()..color = color);
        canvas.drawPath(
          diamond,
          Paint()
            ..color = Colors.black87
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.045,
        );
      case TrafficSignCategory.larangan:
        canvas.drawCircle(center, s * 0.46, Paint()..color = Colors.white);
        canvas.drawCircle(
          center,
          s * 0.42,
          Paint()
            ..color = _red
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.09,
        );
      case TrafficSignCategory.perintah:
        canvas.drawCircle(center, s * 0.46, Paint()..color = _blue);
      case TrafficSignCategory.petunjuk:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.deflate(s * 0.06),
            Radius.circular(s * 0.08),
          ),
          Paint()..color = _blue,
        );
      case TrafficSignCategory.marka:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.deflate(s * 0.06),
            Radius.circular(s * 0.06),
          ),
          Paint()..color = _asphalt,
        );
    }

    _drawSymbol(canvas, size);
  }

  void _drawSymbol(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final center = (Offset.zero & size).center;
    final dark =
        sign.category == TrafficSignCategory.perintah ||
            sign.category == TrafficSignCategory.petunjuk ||
            sign.category == TrafficSignCategory.marka
        ? Colors.white
        : Colors.black87;
    final stroke = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.07
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = dark;

    IconData? icon;
    switch (sign.symbol) {
      case SignSymbol.text:
        final isStop = sign.symbolText == 'STOP';
        if (isStop) {
          // STOP: segi delapan merah dengan teks putih.
          final oct = Path();
          for (var i = 0; i < 8; i++) {
            final angle = (i * 45 - 22.5) * 3.14159265 / 180;
            final p = Offset(
              center.dx + s * 0.44 * math.cos(angle),
              center.dy + s * 0.44 * math.sin(angle),
            );
            if (i == 0) {
              oct.moveTo(p.dx, p.dy);
            } else {
              oct.lineTo(p.dx, p.dy);
            }
          }
          oct.close();
          canvas.drawPath(oct, Paint()..color = _red);
        }
        final painter = TextPainter(
          text: TextSpan(
            text: sign.symbolText ?? '',
            style: TextStyle(
              color: isStop ? Colors.white : dark,
              fontSize: sign.symbolText != null && sign.symbolText!.length > 3
                  ? s * 0.2
                  : s * 0.3,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(
          canvas,
          center - Offset(painter.width / 2, painter.height / 2),
        );
        return;
      case SignSymbol.noEntry:
        canvas.drawCircle(center, s * 0.38, Paint()..color = _red);
        canvas.drawRect(
          Rect.fromCenter(center: center, width: s * 0.5, height: s * 0.12),
          Paint()..color = Colors.white,
        );
        return;
      case SignSymbol.crossedP:
      case SignSymbol.crossedS:
      case SignSymbol.crossedU:
        final letter = switch (sign.symbol) {
          SignSymbol.crossedP => 'P',
          SignSymbol.crossedS => 'S',
          _ => 'U',
        };
        final painter = TextPainter(
          text: TextSpan(
            text: letter,
            style: TextStyle(
              color: Colors.black87,
              fontSize: s * 0.36,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(
          canvas,
          center - Offset(painter.width / 2, painter.height / 2),
        );
        // Garis coret merah diagonal.
        canvas.drawLine(
          center + Offset(-s * 0.28, s * 0.28),
          center + Offset(s * 0.28, -s * 0.28),
          Paint()
            ..color = _red
            ..strokeWidth = s * 0.08
            ..strokeCap = StrokeCap.round,
        );
        return;
      case SignSymbol.arrowLeft:
        icon = Icons.turn_left;
      case SignSymbol.arrowRight:
        icon = Icons.turn_right;
      case SignSymbol.arrowUp:
        icon = Icons.arrow_upward;
      case SignSymbol.pedestrian:
        icon = Icons.directions_walk;
      case SignSymbol.children:
        icon = Icons.escalator_warning;
      case SignSymbol.crossroad:
        icon = Icons.add;
      case SignSymbol.bend:
        icon = Icons.turn_sharp_right;
      case SignSymbol.bump:
        icon = Icons.speed;
      case SignSymbol.narrowRoad:
        icon = Icons.compress;
      case SignSymbol.trafficLight:
        icon = Icons.traffic;
      case SignSymbol.slippery:
        icon = Icons.waves;
      case SignSymbol.railway:
        icon = Icons.train;
      case SignSymbol.roundabout:
        icon = Icons.rotate_left;
      case SignSymbol.hospital:
        icon = Icons.local_hospital;
      case SignSymbol.fuel:
        icon = Icons.local_gas_station;
      case SignSymbol.parking:
        icon = Icons.local_parking;
      case SignSymbol.busStop:
        icon = Icons.directions_bus;
      case SignSymbol.mosque:
        icon = Icons.mosque;
      case SignSymbol.roadWork:
        icon = Icons.engineering;
      case SignSymbol.zebraCross:
        // Garis-garis zebra putih.
        for (var i = 0; i < 4; i++) {
          canvas.drawRect(
            Rect.fromLTWH(
              center.dx - s * 0.3,
              center.dy - s * 0.26 + i * s * 0.15,
              s * 0.6,
              s * 0.08,
            ),
            Paint()..color = Colors.white,
          );
        }
        return;
      case SignSymbol.yellowLine:
        canvas.drawLine(
          Offset(center.dx - s * 0.3, center.dy + s * 0.2),
          Offset(center.dx + s * 0.3, center.dy + s * 0.2),
          Paint()
            ..color = _yellow
            ..strokeWidth = s * 0.07,
        );
        canvas.drawLine(
          Offset(center.dx - s * 0.3, center.dy - s * 0.05),
          Offset(center.dx + s * 0.3, center.dy - s * 0.05),
          stroke..color = Colors.white,
        );
        return;
    }

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          fontSize: s * 0.4,
          color: fill.color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    iconPainter.paint(
      canvas,
      center - Offset(iconPainter.width / 2, iconPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _SignPainter oldDelegate) =>
      oldDelegate.sign != sign;
}
