// [mandala_painters_sacred.dart] - GEOMETRÍA SAGRADA ESTILO TRADICIONAL
// 📁 Ubicación: /lib/widgets/mandala/mandala_painters.dart
// 🎯 OBJETIVO: Mandalas con múltiples capas, pétalos y detalles como las imágenes de referencia

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:agenda_fisio_spa_kym/config/module_mandala_mapping.dart'
    as mapping;

// ==========================================
// 🌸 LOTUS MANDALA - Estilo Imagen 1 y 2
// ==========================================
class LotusMandala extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final double strokeWidth;

  const LotusMandala({
    required this.animationValue,
    this.primaryColor = const Color(0xFFFF6B6B), // Coral vibrante
    this.secondaryColor = const Color(0xFF4ECDC4), // Turquesa
    this.accentColor = const Color(0xFFFFE66D), // Amarillo dorado
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2.2;

    // 🌸 CAPAS DEL MANDALA (de exterior a interior)
    _drawOuterPetals(canvas, center, maxRadius, animationValue);
    _drawMiddlePetals(canvas, center, maxRadius * 0.75, animationValue);
    _drawInnerPetals(canvas, center, maxRadius * 0.5, animationValue);
    _drawCenterCore(canvas, center, maxRadius * 0.25, animationValue);
    _drawSacredGeometry(canvas, center, maxRadius, animationValue);
    _drawDecorativeElements(canvas, center, maxRadius, animationValue);
  }

  void _drawOuterPetals(
      Canvas canvas, Offset center, double radius, double progress) {
    if (progress < 0.2) return;

    const petalCount = 16;
    final petalProgress = ((progress - 0.2) / 0.8).clamp(0.0, 1.0);

    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * math.pi) / petalCount;
      _drawDetailedPetal(canvas, center, radius, angle, petalProgress,
          primaryColor, 0.8, PetalStyle.pointed);
    }
  }

  void _drawMiddlePetals(
      Canvas canvas, Offset center, double radius, double progress) {
    if (progress < 0.4) return;

    const petalCount = 12;
    final petalProgress = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);

    for (int i = 0; i < petalCount; i++) {
      final angle =
          (i * 2 * math.pi) / petalCount + (math.pi / petalCount); // Offset
      _drawDetailedPetal(canvas, center, radius, angle, petalProgress,
          secondaryColor, 0.9, PetalStyle.rounded);
    }
  }

  void _drawInnerPetals(
      Canvas canvas, Offset center, double radius, double progress) {
    if (progress < 0.6) return;

    const petalCount = 8;
    final petalProgress = ((progress - 0.6) / 0.4).clamp(0.0, 1.0);

    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * math.pi) / petalCount;
      _drawDetailedPetal(canvas, center, radius, angle, petalProgress,
          accentColor, 1.0, PetalStyle.lotus);
    }
  }

  void _drawDetailedPetal(
      Canvas canvas,
      Offset center,
      double radius,
      double angle,
      double progress,
      Color color,
      double opacity,
      PetalStyle style) {
    final petalLength = radius * progress;
    final petalWidth = petalLength * 0.4;

    // Petal base position
    final baseX = center.dx + (radius * 0.3) * math.cos(angle);
    final baseY = center.dy + (radius * 0.3) * math.sin(angle);
    final tipX = center.dx + petalLength * math.cos(angle);
    final tipY = center.dy + petalLength * math.sin(angle);

    final path = Path();

    switch (style) {
      case PetalStyle.pointed:
        _createPointedPetal(
            path, Offset(baseX, baseY), Offset(tipX, tipY), petalWidth, angle);
        break;
      case PetalStyle.rounded:
        _createRoundedPetal(
            path, Offset(baseX, baseY), Offset(tipX, tipY), petalWidth, angle);
        break;
      case PetalStyle.lotus:
        _createLotusPetal(
            path, Offset(baseX, baseY), Offset(tipX, tipY), petalWidth, angle);
        break;
    }

    // Gradiente del pétalo
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(opacity),
          color.withOpacity(opacity * 0.3),
          Colors.white.withOpacity(opacity * 0.1),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(
          Rect.fromCircle(center: Offset(tipX, tipY), radius: petalWidth))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Borde del pétalo
    final borderPaint = Paint()
      ..color = color.withOpacity(opacity * 0.8)
      ..strokeWidth = strokeWidth * 0.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, borderPaint);

    // Detalles internos del pétalo
    _drawPetalDetails(canvas, Offset(baseX, baseY), Offset(tipX, tipY),
        petalWidth, angle, color, opacity);
  }

  void _createPointedPetal(
      Path path, Offset base, Offset tip, double width, double angle) {
    final perpAngle1 = angle + math.pi / 2;
    final perpAngle2 = angle - math.pi / 2;

    final side1X = base.dx + (width * 0.5) * math.cos(perpAngle1);
    final side1Y = base.dy + (width * 0.5) * math.sin(perpAngle1);
    final side2X = base.dx + (width * 0.5) * math.cos(perpAngle2);
    final side2Y = base.dy + (width * 0.5) * math.sin(perpAngle2);

    path.moveTo(base.dx, base.dy);
    path.quadraticBezierTo(side1X, side1Y, tip.dx, tip.dy);
    path.quadraticBezierTo(side2X, side2Y, base.dx, base.dy);
    path.close();
  }

  void _createRoundedPetal(
      Path path, Offset base, Offset tip, double width, double angle) {
    final perpAngle1 = angle + math.pi / 2;
    final perpAngle2 = angle - math.pi / 2;

    final control1X = base.dx + width * math.cos(perpAngle1);
    final control1Y = base.dy + width * math.sin(perpAngle1);
    final control2X = base.dx + width * math.cos(perpAngle2);
    final control2Y = base.dy + width * math.sin(perpAngle2);

    path.moveTo(base.dx, base.dy);
    path.cubicTo(control1X, control1Y, tip.dx, tip.dy, tip.dx, tip.dy);
    path.cubicTo(control2X, control2Y, base.dx, base.dy, base.dx, base.dy);
    path.close();
  }

  void _createLotusPetal(
      Path path, Offset base, Offset tip, double width, double angle) {
    final midPoint = Offset(
      base.dx + (tip.dx - base.dx) * 0.6,
      base.dy + (tip.dy - base.dy) * 0.6,
    );

    final perpAngle1 = angle + math.pi / 2;
    final perpAngle2 = angle - math.pi / 2;

    final curve1X = midPoint.dx + (width * 0.7) * math.cos(perpAngle1);
    final curve1Y = midPoint.dy + (width * 0.7) * math.sin(perpAngle1);
    final curve2X = midPoint.dx + (width * 0.7) * math.cos(perpAngle2);
    final curve2Y = midPoint.dy + (width * 0.7) * math.sin(perpAngle2);

    path.moveTo(base.dx, base.dy);
    path.quadraticBezierTo(curve1X, curve1Y, tip.dx, tip.dy);
    path.quadraticBezierTo(curve2X, curve2Y, base.dx, base.dy);
    path.close();
  }

  void _drawPetalDetails(Canvas canvas, Offset base, Offset tip, double width,
      double angle, Color color, double opacity) {
    final detailPaint = Paint()
      ..color = color.withOpacity(opacity * 0.6)
      ..strokeWidth = strokeWidth * 0.3
      ..style = PaintingStyle.stroke;

    // Línea central del pétalo
    canvas.drawLine(base, tip, detailPaint);

    // Líneas laterales decorativas
    for (int i = 1; i <= 3; i++) {
      final progress = i / 4.0;
      final midPoint = Offset(
        base.dx + (tip.dx - base.dx) * progress,
        base.dy + (tip.dy - base.dy) * progress,
      );

      final sideLength = width * (1.0 - progress) * 0.3;
      final perpAngle1 = angle + math.pi / 2;
      final perpAngle2 = angle - math.pi / 2;

      final side1 = Offset(
        midPoint.dx + sideLength * math.cos(perpAngle1),
        midPoint.dy + sideLength * math.sin(perpAngle1),
      );
      final side2 = Offset(
        midPoint.dx + sideLength * math.cos(perpAngle2),
        midPoint.dy + sideLength * math.sin(perpAngle2),
      );

      canvas.drawLine(side1, side2, detailPaint);
    }
  }

  void _drawCenterCore(
      Canvas canvas, Offset center, double radius, double progress) {
    if (progress < 0.8) return;

    final coreProgress = ((progress - 0.8) / 0.2).clamp(0.0, 1.0);

    // Núcleo principal con gradiente
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.9),
          secondaryColor.withOpacity(0.7),
          accentColor.withOpacity(0.5),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(
          Rect.fromCircle(center: center, radius: radius * coreProgress))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * coreProgress, corePaint);

    // Anillos concéntricos decorativos
    for (int ring = 1; ring <= 4; ring++) {
      final ringPaint = Paint()
        ..color = Colors.white.withOpacity(0.3 - (ring * 0.05))
        ..strokeWidth = strokeWidth * (0.8 - ring * 0.1)
        ..style = PaintingStyle.stroke;

      final ringRadius = radius * coreProgress * (0.3 + ring * 0.15);
      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    // Patrón central sagrado
    _drawSacredCore(canvas, center, radius * coreProgress * 0.6, coreProgress);
  }

  void _drawSacredCore(
      Canvas canvas, Offset center, double radius, double progress) {
    final sacredPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = strokeWidth * 0.6
      ..style = PaintingStyle.stroke;

    // Flower of Life central pequeña
    const petals = 6;
    for (int i = 0; i < petals; i++) {
      final angle = (i * 2 * math.pi) / petals;
      final petalCenter = Offset(
        center.dx + (radius * 0.5) * math.cos(angle),
        center.dy + (radius * 0.5) * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, radius * 0.3, sacredPaint);
    }

    // Centro absoluto
    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.2, centerPaint);
  }

  void _drawSacredGeometry(
      Canvas canvas, Offset center, double radius, double progress) {
    if (progress < 0.3) return;

    final geometryPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = strokeWidth * 0.4
      ..style = PaintingStyle.stroke;

    // Líneas de conexión geométrica
    const divisions = 12;
    for (int i = 0; i < divisions; i++) {
      final angle = (i * 2 * math.pi) / divisions;
      final startRadius = radius * 0.3;
      final endRadius = radius * 0.9;

      final startX = center.dx + startRadius * math.cos(angle);
      final startY = center.dy + startRadius * math.sin(angle);
      final endX = center.dx + endRadius * math.cos(angle);
      final endY = center.dy + endRadius * math.sin(angle);

      canvas.drawLine(
          Offset(startX, startY), Offset(endX, endY), geometryPaint);
    }

    // Círculos de proporción áurea
    const goldenRatio = 1.618033988749;
    for (int circle = 1; circle <= 3; circle++) {
      final circleRadius = radius * math.pow(goldenRatio, -circle) * progress;
      canvas.drawCircle(center, circleRadius, geometryPaint);
    }
  }

  void _drawDecorativeElements(
      Canvas canvas, Offset center, double radius, double progress) {
    if (progress < 0.5) return;

    // Puntos decorativos entre pétalos
    const pointCount = 24;
    for (int i = 0; i < pointCount; i++) {
      final angle = (i * 2 * math.pi) / pointCount;
      final pointRadius = radius * (0.85 + math.sin(i * 0.5) * 0.1);

      final pointX = center.dx + pointRadius * math.cos(angle);
      final pointY = center.dy + pointRadius * math.sin(angle);

      final pointPaint = Paint()
        ..color = primaryColor.withOpacity(0.4)
        ..style = PaintingStyle.fill;

      final size = 2.0 + math.sin(angle * 3) * 1.0;
      canvas.drawCircle(Offset(pointX, pointY), size, pointPaint);
    }

    // Rayos externos decorativos
    const rayCount = 32;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi) / rayCount;
      final rayLength = 15 + math.sin(i * 0.3) * 8;

      final startRadius = radius * 1.05;
      final endRadius = startRadius + rayLength;

      final startX = center.dx + startRadius * math.cos(angle);
      final startY = center.dy + startRadius * math.sin(angle);
      final endX = center.dx + endRadius * math.cos(angle);
      final endY = center.dy + endRadius * math.sin(angle);

      final rayPaint = Paint()
        ..color = secondaryColor.withOpacity(0.3)
        ..strokeWidth = strokeWidth * 0.8
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// 🌟 SACRED STAR MANDALA - Estilo Imagen 3
// ==========================================
class SacredStarMandala extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final double strokeWidth;

  const SacredStarMandala({
    required this.animationValue,
    this.primaryColor = const Color(0xFFFF6B6B), // Coral vibrante
    this.secondaryColor = const Color(0xFF4ECDC4), // Turquesa
    this.accentColor = const Color(0xFFFFE66D), // Amarillo dorado
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2.2;

    // Capas del mandala estrella
    _drawStarLayers(canvas, center, maxRadius, animationValue);
    _drawGeometricRings(canvas, center, maxRadius, animationValue);
    _drawSacredPolygons(canvas, center, maxRadius, animationValue);
    _drawCentralStar(canvas, center, maxRadius, animationValue);
    _drawOrientationalMarks(canvas, center, maxRadius, animationValue);
  }

  void _drawStarLayers(
      Canvas canvas, Offset center, double radius, double progress) {
    // Estrella exterior de 12 puntas
    if (progress > 0.2) {
      _drawDetailedStar(canvas, center, radius * 0.9, 12,
          ((progress - 0.2) / 0.8).clamp(0.0, 1.0), primaryColor, 0.7);
    }

    // Estrella media de 8 puntas
    if (progress > 0.4) {
      _drawDetailedStar(canvas, center, radius * 0.7, 8,
          ((progress - 0.4) / 0.6).clamp(0.0, 1.0), secondaryColor, 0.8);
    }

    // Estrella interior de 6 puntas
    if (progress > 0.6) {
      _drawDetailedStar(canvas, center, radius * 0.5, 6,
          ((progress - 0.6) / 0.4).clamp(0.0, 1.0), accentColor, 0.9);
    }
  }

  void _drawDetailedStar(Canvas canvas, Offset center, double radius,
      int points, double progress, Color color, double opacity) {
    final starPath = Path();
    final innerRadius = radius * 0.6;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points;
      final currentRadius =
          (i % 2 == 0) ? radius * progress : innerRadius * progress;

      final x = center.dx + currentRadius * math.cos(angle - math.pi / 2);
      final y = center.dy + currentRadius * math.sin(angle - math.pi / 2);

      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    // Relleno con gradiente
    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(opacity),
          color.withOpacity(opacity * 0.5),
          Colors.white.withOpacity(opacity * 0.2),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawPath(starPath, fillPaint);

    // Borde
    final borderPaint = Paint()
      ..color = color.withOpacity(opacity * 0.9)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawPath(starPath, borderPaint);

    // Detalles internos de la estrella
    _drawStarDetails(
        canvas, center, radius, innerRadius, points, progress, color, opacity);
  }

  void _drawStarDetails(
      Canvas canvas,
      Offset center,
      double outerRadius,
      double innerRadius,
      int points,
      double progress,
      Color color,
      double opacity) {
    final detailPaint = Paint()
      ..color = color.withOpacity(opacity * 0.5)
      ..strokeWidth = strokeWidth * 0.4
      ..style = PaintingStyle.stroke;

    // Líneas desde el centro a cada punta
    for (int i = 0; i < points; i++) {
      final angle = (i * 2 * math.pi) / points - math.pi / 2;
      final x = center.dx + outerRadius * progress * math.cos(angle);
      final y = center.dy + outerRadius * progress * math.sin(angle);

      canvas.drawLine(center, Offset(x, y), detailPaint);
    }

    // Círculo interior decorativo
    final innerCirclePaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.3)
      ..strokeWidth = strokeWidth * 0.6
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, innerRadius * progress * 0.7, innerCirclePaint);
  }

  void _drawGeometricRings(
      Canvas canvas, Offset center, double radius, double progress) {
    if (progress < 0.3) return;

    final ringProgress = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);

    // Anillos concéntricos con patrones
    for (int ring = 1; ring <= 5; ring++) {
      final ringRadius = radius * (0.2 + ring * 0.15) * ringProgress;

      final ringPaint = Paint()
        ..color = primaryColor.withOpacity(0.3 - (ring * 0.04))
        ..strokeWidth = strokeWidth * (1.0 - ring * 0.1)
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(center, ringRadius, ringPaint);

      // Marcas direccionales en cada anillo
      if (ring % 2 == 1) {
        _drawDirectionalMarks(
            canvas, center, ringRadius, ring * 8, ringProgress);
      }
    }
  }

  void _drawDirectionalMarks(Canvas canvas, Offset center, double radius,
      int markCount, double progress) {
    final markPaint = Paint()
      ..color = secondaryColor.withOpacity(0.4)
      ..strokeWidth = strokeWidth * 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < markCount; i++) {
      final angle = (i * 2 * math.pi) / markCount;
      final innerRadius = radius * 0.95;
      final outerRadius = radius * 1.05;

      final innerX = center.dx + innerRadius * math.cos(angle);
      final innerY = center.dy + innerRadius * math.sin(angle);
      final outerX = center.dx + outerRadius * math.cos(angle);
      final outerY = center.dy + outerRadius * math.sin(angle);

      canvas.drawLine(
          Offset(innerX, innerY), Offset(outerX, outerY), markPaint);
    }
  }

  void _drawSacredPolygons(
      Canvas canvas, Offset center, double radius, double progress) {
    if (progress < 0.5) return;

    final polyProgress = ((progress - 0.5) / 0.5).clamp(0.0, 1.0);

    // Hexágono sagrado
    _drawPolygon(canvas, center, radius * 0.8 * polyProgress, 6,
        accentColor.withOpacity(0.3), false);

    // Dodecágono (12 lados)
    _drawPolygon(canvas, center, radius * 0.6 * polyProgress, 12,
        secondaryColor.withOpacity(0.25), true);

    // Octágono
    _drawPolygon(canvas, center, radius * 0.4 * polyProgress, 8,
        primaryColor.withOpacity(0.4), false);
  }

  void _drawPolygon(Canvas canvas, Offset center, double radius, int sides,
      Color color, bool filled) {
    final path = Path();

    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi) / sides - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth * 0.8
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  void _drawCentralStar(
      Canvas canvas, Offset center, double radius, double progress) {
    if (progress < 0.7) return;

    final centerProgress = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);

    // Estrella central de 8 puntas muy detallada
    final centralRadius = radius * 0.25 * centerProgress;

    final centralPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.9),
          primaryColor.withOpacity(0.8),
          secondaryColor.withOpacity(0.6),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: centralRadius))
      ..style = PaintingStyle.fill;

    // Estrella central
    final starPath = Path();
    const points = 8;
    final innerRadius = centralRadius * 0.5;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points;
      final currentRadius = (i % 2 == 0) ? centralRadius : innerRadius;

      final x = center.dx + currentRadius * math.cos(angle - math.pi / 2);
      final y = center.dy + currentRadius * math.sin(angle - math.pi / 2);

      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    canvas.drawPath(starPath, centralPaint);

    // Punto central absoluto
    final corePaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, centralRadius * 0.2, corePaint);
  }

  void _drawOrientationalMarks(
      Canvas canvas, Offset center, double radius, double progress) {
    if (progress < 0.8) return;

    // Marcas direccionales principales (N, S, E, W)
    final directions = [0, math.pi / 2, math.pi, 3 * math.pi / 2];

    for (final angle in directions) {
      final markRadius = radius * 1.1;
      final x = center.dx + markRadius * math.cos(angle - math.pi / 2);
      final y = center.dy + markRadius * math.sin(angle - math.pi / 2);

      final markPaint = Paint()
        ..color = primaryColor.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      // Marca triangular direccional
      final markPath = Path();
      final markSize = 8.0;

      markPath.moveTo(x, y - markSize);
      markPath.lineTo(x - markSize * 0.5, y + markSize * 0.5);
      markPath.lineTo(x + markSize * 0.5, y + markSize * 0.5);
      markPath.close();

      canvas.drawPath(markPath, markPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// 🌀 ACTUALIZACIÓN DE PAINTERS PRINCIPALES
// ==========================================

// Actualizar FlowerOfLifePainter para usar el nuevo estilo
class FlowerOfLifePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double strokeWidth;

  const FlowerOfLifePainter({
    required this.animationValue,
    this.color = Colors.white,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Usar LotusMandala con COLORES VIBRANTES como mandalas tradicionales
    final lotusPainter = LotusMandala(
      animationValue: animationValue,
      primaryColor: const Color(0xFFFF6B6B), // Coral vibrante
      secondaryColor: const Color(0xFF4ECDC4), // Turquesa
      accentColor: const Color(0xFFFFE66D), // Amarillo dorado
      strokeWidth: strokeWidth,
    );

    lotusPainter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Actualizar FibonacciPainter para usar estilo más denso
class FibonacciPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double strokeWidth;

  const FibonacciPainter({
    required this.animationValue,
    this.color = Colors.white,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Usar SacredStarMandala con COLORES VIBRANTES como mandalas tradicionales
    final starPainter = SacredStarMandala(
      animationValue: animationValue,
      primaryColor: const Color(0xFFFF6B6B), // Coral vibrante
      secondaryColor: const Color(0xFF4ECDC4), // Turquesa
      accentColor: const Color(0xFFFFE66D), // Amarillo dorado
      strokeWidth: strokeWidth,
    );

    starPainter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// 🌈 MANDALA COLORIDO ESTILO IMAGEN 2
// ==========================================
class ColorfulLotusMandala extends CustomPainter {
  final double animationValue;
  final List<Color> colors;
  final double strokeWidth;

  const ColorfulLotusMandala({
    required this.animationValue,
    this.colors = const [
      Color(0xFFFF6B6B), // Coral vibrante
      Color(0xFF4ECDC4), // Turquesa
      Color(0xFFFFE66D), // Amarillo dorado
      Color(0xFFFF8E53), // Naranja cálido
      Color(0xFFB4E7CE), // Verde menta
      Color(0xFFFFA0AC), // Rosa suave
    ],
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2.2;

    // Múltiples capas con diferentes colores
    _drawColorfulOuterRing(canvas, center, maxRadius, animationValue);
    _drawColorfulMiddleRing(canvas, center, maxRadius * 0.75, animationValue);
    _drawColorfulInnerRing(canvas, center, maxRadius * 0.5, animationValue);
    _drawColorfulCenter(canvas, center, maxRadius * 0.25, animationValue);
    _drawColorfulDetails(canvas, center, maxRadius, animationValue);
  }

  void _drawColorfulOuterRing(
      Canvas canvas, Offset center, double radius, double progress) {
    if (progress < 0.2) return;

    const petalCount = 20;
    final petalProgress = ((progress - 0.2) / 0.8).clamp(0.0, 1.0);

    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * math.pi) / petalCount;
      final colorIndex = i % colors.length;

      _drawColorfulPetal(canvas, center, radius, angle, petalProgress,
          colors[colorIndex], PetalComplexity.detailed);
    }
  }

  void _drawColorfulMiddleRing(
      Canvas canvas, Offset center, double radius, double progress) {
    if (progress < 0.4) return;

    const petalCount = 16;
    final petalProgress = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);

    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * math.pi) / petalCount + (math.pi / petalCount);
      final colorIndex = (i + 2) % colors.length; // Offset de color

      _drawColorfulPetal(canvas, center, radius, angle, petalProgress,
          colors[colorIndex], PetalComplexity.medium);
    }
  }

  void _drawColorfulInnerRing(
      Canvas canvas, Offset center, double radius, double progress) {
    if (progress < 0.6) return;

    const petalCount = 12;
    final petalProgress = ((progress - 0.6) / 0.4).clamp(0.0, 1.0);

    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * math.pi) / petalCount;
      final colorIndex = (i + 4) % colors.length; // Otro offset

      _drawColorfulPetal(canvas, center, radius, angle, petalProgress,
          colors[colorIndex], PetalComplexity.simple);
    }
  }

  void _drawColorfulPetal(Canvas canvas, Offset center, double radius,
      double angle, double progress, Color color, PetalComplexity complexity) {
    final petalLength = radius * progress;
    final petalWidth = petalLength * 0.4;

    final baseX = center.dx + (radius * 0.2) * math.cos(angle);
    final baseY = center.dy + (radius * 0.2) * math.sin(angle);
    final tipX = center.dx + petalLength * math.cos(angle);
    final tipY = center.dy + petalLength * math.sin(angle);

    // Gradiente más colorido
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.9),
          color.withOpacity(0.6),
          Colors.white.withOpacity(0.3),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromPoints(Offset(baseX, baseY), Offset(tipX, tipY)))
      ..style = PaintingStyle.fill;

    // Crear pétalo con curvas suaves
    final path = Path();
    final perpAngle1 = angle + math.pi / 2;
    final perpAngle2 = angle - math.pi / 2;

    final midX = baseX + (tipX - baseX) * 0.7;
    final midY = baseY + (tipY - baseY) * 0.7;

    final control1X = midX + (petalWidth * 0.6) * math.cos(perpAngle1);
    final control1Y = midY + (petalWidth * 0.6) * math.sin(perpAngle1);
    final control2X = midX + (petalWidth * 0.6) * math.cos(perpAngle2);
    final control2Y = midY + (petalWidth * 0.6) * math.sin(perpAngle2);

    path.moveTo(baseX, baseY);
    path.quadraticBezierTo(control1X, control1Y, tipX, tipY);
    path.quadraticBezierTo(control2X, control2Y, baseX, baseY);
    path.close();

    canvas.drawPath(path, paint);

    // Borde con el mismo color pero más intenso
    final borderPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = strokeWidth * 0.6
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, borderPaint);

    // Detalles según complejidad
    if (complexity == PetalComplexity.detailed) {
      _drawPetalPattern(canvas, Offset(baseX, baseY), Offset(tipX, tipY),
          petalWidth, angle, color);
    }
  }

  void _drawPetalPattern(Canvas canvas, Offset base, Offset tip, double width,
      double angle, Color color) {
    final patternPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = strokeWidth * 0.3
      ..style = PaintingStyle.stroke;

    // Líneas decorativas dentro del pétalo
    for (int i = 1; i <= 3; i++) {
      final progress = i / 4.0;
      final pointX = base.dx + (tip.dx - base.dx) * progress;
      final pointY = base.dy + (tip.dy - base.dy) * progress;

      final sideWidth = width * (1.0 - progress) * 0.4;
      final perpAngle1 = angle + math.pi / 2;
      final perpAngle2 = angle - math.pi / 2;

      final side1X = pointX + sideWidth * math.cos(perpAngle1);
      final side1Y = pointY + sideWidth * math.sin(perpAngle1);
      final side2X = pointX + sideWidth * math.cos(perpAngle2);
      final side2Y = pointY + sideWidth * math.sin(perpAngle2);

      canvas.drawLine(
          Offset(side1X, side1Y), Offset(side2X, side2Y), patternPaint);
    }

    // Puntos decorativos
    for (int i = 1; i <= 5; i++) {
      final progress = i / 6.0;
      final pointX = base.dx + (tip.dx - base.dx) * progress;
      final pointY = base.dy + (tip.dy - base.dy) * progress;

      final dotPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(pointX, pointY), 1.0, dotPaint);
    }
  }

  void _drawColorfulCenter(
      Canvas canvas, Offset center, double radius, double progress) {
    if (progress < 0.8) return;

    final centerProgress = ((progress - 0.8) / 0.2).clamp(0.0, 1.0);

    // Centro con gradiente radial multicolor
    final centerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          colors[0].withOpacity(0.9),
          colors[1].withOpacity(0.7),
          colors[2].withOpacity(0.5),
          Colors.white.withOpacity(0.8),
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(
          Rect.fromCircle(center: center, radius: radius * centerProgress))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * centerProgress, centerPaint);

    // Anillos decorativos concéntricos
    for (int ring = 1; ring <= 4; ring++) {
      final ringPaint = Paint()
        ..color = colors[ring % colors.length].withOpacity(0.4)
        ..strokeWidth = strokeWidth * (0.8 - ring * 0.1)
        ..style = PaintingStyle.stroke;

      final ringRadius = radius * centerProgress * (0.2 + ring * 0.18);
      canvas.drawCircle(center, ringRadius, ringPaint);
    }
  }

  void _drawColorfulDetails(
      Canvas canvas, Offset center, double radius, double progress) {
    if (progress < 0.5) return;

    // Puntos de color entre pétalos
    const pointCount = 32;
    for (int i = 0; i < pointCount; i++) {
      final angle = (i * 2 * math.pi) / pointCount;
      final pointRadius = radius * (0.9 + math.sin(i * 0.3) * 0.08);
      final colorIndex = i % colors.length;

      final pointX = center.dx + pointRadius * math.cos(angle);
      final pointY = center.dy + pointRadius * math.sin(angle);

      final pointPaint = Paint()
        ..color = colors[colorIndex].withOpacity(0.6)
        ..style = PaintingStyle.fill;

      final size = 2.5 + math.sin(angle * 2) * 1.0;
      canvas.drawCircle(Offset(pointX, pointY), size, pointPaint);
    }

    // Líneas radiales sutiles
    const lineCount = 24;
    for (int i = 0; i < lineCount; i++) {
      final angle = (i * 2 * math.pi) / lineCount;
      final colorIndex = (i ~/ 4) % colors.length;

      final startRadius = radius * 0.7;
      final endRadius = radius * 0.95;

      final startX = center.dx + startRadius * math.cos(angle);
      final startY = center.dy + startRadius * math.sin(angle);
      final endX = center.dx + endRadius * math.cos(angle);
      final endY = center.dy + endRadius * math.sin(angle);

      final linePaint = Paint()
        ..color = colors[colorIndex].withOpacity(0.2)
        ..strokeWidth = strokeWidth * 0.4
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// 🔄 ACTUALIZAR PAINTERS EXISTENTES
// ==========================================

// Actualizar MolecularPainter para usar estilo más ornamental
class MolecularPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double strokeWidth;

  const MolecularPainter({
    required this.animationValue,
    this.color = Colors.white,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Usar ColorfulLotusMandala con PALETA VIBRANTE como mandalas tradicionales
    final colorfulPainter = ColorfulLotusMandala(
      animationValue: animationValue,
      colors: const [
        Color(0xFFFF6B6B), // Coral vibrante
        Color(0xFF4ECDC4), // Turquesa
        Color(0xFFFFE66D), // Amarillo dorado
        Color(0xFFFF8E53), // Naranja cálido
        Color(0xFFB4E7CE), // Verde menta
        Color(0xFFFFA0AC), // Rosa suave
      ],
      strokeWidth: strokeWidth,
    );

    colorfulPainter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Actualizar VortexPainter para estilo más ornamental
class VortexPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double strokeWidth;

  const VortexPainter({
    required this.animationValue,
    this.color = Colors.white,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Usar SacredStarMandala con COLORES VIBRANTES como mandalas tradicionales
    final starPainter = SacredStarMandala(
      animationValue: animationValue,
      primaryColor: const Color(0xFFFF6B6B), // Coral vibrante
      secondaryColor: const Color(0xFF4ECDC4), // Turquesa
      accentColor: const Color(0xFFFFE66D), // Amarillo dorado
      strokeWidth: strokeWidth,
    );

    starPainter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Actualizar CrystallinePainter
class CrystallinePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double strokeWidth;

  const CrystallinePainter({
    required this.animationValue,
    this.color = Colors.white,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Usar LotusMandala con COLORES VIBRANTES como mandalas tradicionales
    final lotusPainter = LotusMandala(
      animationValue: animationValue,
      primaryColor: const Color(0xFFFF6B6B), // Coral vibrante
      secondaryColor: const Color(0xFF4ECDC4), // Turquesa
      accentColor: const Color(0xFFFFE66D), // Amarillo dorado
      strokeWidth: strokeWidth,
    );

    lotusPainter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Actualizar PenrosePainter
class PenrosePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double strokeWidth;

  const PenrosePainter({
    required this.animationValue,
    this.color = Colors.white,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Usar ColorfulLotusMandala con PALETA VIBRANTE como mandalas tradicionales
    final colorfulPainter = ColorfulLotusMandala(
      animationValue: animationValue,
      colors: const [
        Color(0xFFFF6B6B), // Coral vibrante
        Color(0xFF4ECDC4), // Turquesa
        Color(0xFFFFE66D), // Amarillo dorado
        Color(0xFFFF8E53), // Naranja cálido
        Color(0xFFB4E7CE), // Verde menta
        Color(0xFFFFA0AC), // Rosa suave
      ],
      strokeWidth: strokeWidth,
    );

    colorfulPainter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==========================================
// 🎯 ENUMS Y CLASES DE SOPORTE
// ==========================================

enum PetalStyle { pointed, rounded, lotus }

enum PetalComplexity { simple, medium, detailed }
