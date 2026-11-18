import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/design_system/tokens.dart';

/// Horno de laboratorio 2D original (sin logotipos ni planos de fabricantes).
/// El color de la pieza es un LENGUAJE VISUAL ilustrativo (doc 08 §6).
class FurnacePainter extends CustomPainter {
  FurnacePainter({required this.visualTemp, required this.inFurnace, required this.brightness,
      required this.stageKind, this.pulse = 0});

  factory FurnacePainter.idle(Brightness b) =>
      FurnacePainter(visualTemp: 20, inFurnace: true, brightness: b, stageKind: 'idle');

  final double visualTemp, pulse;
  final bool inFurnace;
  final Brightness brightness;
  final String stageKind;

  @override
  void paint(Canvas canvas, Size size) {
    final dark = brightness == Brightness.dark;
    final w = size.width, h = size.height;
    final unit = math.min(w / 1.7, h);
    final fw = unit * 1.0, fh = unit * .86;
    final left = (w - fw * 1.55) / 2;
    final top = (h - fh) / 2;
    final body = RRect.fromRectAndRadius(Rect.fromLTWH(left, top, fw, fh), Radius.circular(unit * .07));
    final shell = Paint()..color = dark ? const Color(0xFF2C3833) : const Color(0xFFE7EBE5);
    final edge = Paint()
      ..color = dark ? const Color(0xFF45534C) : const Color(0xFFC9D0C8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(body.shift(Offset(0, unit * .02)), Paint()..color = Colors.black.withValues(alpha: .08));
    canvas.drawRRect(body, shell);
    canvas.drawRRect(body, edge);

    // Cámara
    final ch = Rect.fromLTWH(left + fw * .12, top + fh * .14, fw * .76, fh * .52);
    final heat = inFurnace ? ((visualTemp - 20) / 1200).clamp(0.0, 1.0) : 0.0;
    final chamberColor = Color.lerp(dark ? const Color(0xFF11171A) : const Color(0xFF3A4447),
        const Color(0xFF7A2A12), heat * .85)!;
    final chamber = RRect.fromRectAndRadius(ch, Radius.circular(unit * .03));
    canvas.drawRRect(chamber, Paint()..color = chamberColor);
    // Resistencias (brillo proporcional a la temperatura del historial: visual)
    final coil = Paint()
      ..color = Color.lerp(const Color(0xFF59605F), const Color(0xFFFF8A3D), heat)!
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 3; i++) {
      final y = ch.top + ch.height * (.2 + i * .3);
      final path = Path()..moveTo(ch.left + 8, y);
      for (var x = ch.left + 8; x < ch.right - 8; x += 10) {
        path.relativeQuadraticBezierTo(2.5, (i.isEven ? -5 : 5), 5, 0);
        path.relativeQuadraticBezierTo(2.5, (i.isEven ? 5 : -5), 5, 0);
      }
      canvas.drawPath(path, coil);
    }
    if (heat > 0) {
      canvas.drawRRect(chamber, Paint()
        ..color = const Color(0xFFFF7A2A).withValues(alpha: .12 * heat + .05 * pulse * heat)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    }
    // Panel de control
    final panel = Rect.fromLTWH(left + fw * .12, top + fh * .74, fw * .76, fh * .14);
    canvas.drawRRect(RRect.fromRectAndRadius(panel, Radius.circular(unit * .02)),
        Paint()..color = dark ? const Color(0xFF1B2420) : const Color(0xFFF7F9F5));
    canvas.drawCircle(Offset(panel.left + panel.height * .6, panel.center.dy), panel.height * .22,
        Paint()..color = heat > .05 ? FlColors.peachRed : FlColors.yellowGreen);
    for (var i = 0; i < 2; i++) {
      canvas.drawCircle(Offset(panel.right - panel.height * (.6 + i * .9), panel.center.dy), panel.height * .25,
          Paint()..color = dark ? const Color(0xFF45534C) : const Color(0xFFC9D0C8));
    }

    final piece = FlGlow.forTemperature(visualTemp);
    final pieceW = ch.width * .34, pieceH = ch.height * .2;
    if (inFurnace) {
      final pr = Rect.fromCenter(center: Offset(ch.center.dx, ch.bottom - pieceH * .9), width: pieceW, height: pieceH);
      _drawPiece(canvas, pr, piece, visualTemp);
      // Puerta cerrada (vidrio)
      canvas.drawRRect(chamber, Paint()
        ..color = Colors.white.withValues(alpha: dark ? .04 : .10)
        ..style = PaintingStyle.fill);
      canvas.drawRRect(chamber, edge);
    } else {
      // Puerta abierta (abatida) + medio de enfriamiento / baño
      final door = Path()
        ..moveTo(ch.left, ch.bottom)
        ..lineTo(ch.left - ch.width * .18, ch.bottom + ch.height * .1)
        ..lineTo(ch.left - ch.width * .18, ch.top + ch.height * .1)
        ..lineTo(ch.left, ch.top)
        ..close();
      canvas.drawPath(door, Paint()..color = (dark ? const Color(0xFF3A4842) : const Color(0xFFD8DED6)));
      final tank = RRect.fromRectAndRadius(
          Rect.fromLTWH(left + fw * 1.08, top + fh * .42, fw * .44, fh * .5), Radius.circular(unit * .03));
      final isBath = stageKind == 'isothermal_hold' || stageKind == 'cool';
      canvas.drawRRect(tank, Paint()..color = dark ? const Color(0xFF24313A) : const Color(0xFFDCE8EE));
      final liquid = Rect.fromLTWH(tank.left + 4, tank.top + tank.height * .3, tank.width - 8, tank.height * .7 - 4);
      canvas.drawRRect(RRect.fromRectAndRadius(liquid, Radius.circular(unit * .02)),
          Paint()..color = (isBath ? const Color(0xFF6FA3BF) : const Color(0xFF9CC3D6)).withValues(alpha: .7));
      canvas.drawRRect(tank, edge);
      final pr = Rect.fromCenter(
          center: Offset(tank.center.dx, stageKind == 'transfer' ? tank.top - pieceH : liquid.center.dy),
          width: pieceW * .9,
          height: pieceH);
      _drawPiece(canvas, pr, piece, visualTemp);
    }
  }

  void _drawPiece(Canvas canvas, Rect r, Color c, double t) {
    if (t > 600) {
      canvas.drawRRect(RRect.fromRectAndRadius(r.inflate(6), const Radius.circular(8)),
          Paint()
            ..color = c.withValues(alpha: .45)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    }
    canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)), Paint()..color = c);
    canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(4)),
        Paint()
          ..color = Colors.black.withValues(alpha: .25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(FurnacePainter old) =>
      old.visualTemp != visualTemp || old.inFurnace != inFurnace || old.brightness != brightness ||
      old.stageKind != stageKind || old.pulse != pulse;
}
