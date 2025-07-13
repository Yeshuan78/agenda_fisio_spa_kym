// [booking_app_bar.dart] - ✨ PREMIUM WOW EFFECTS CON PANAL DE ABEJA
// 📁 Ubicación: /lib/widgets/booking/layout/booking_app_bar.dart
// 🎯 OBJETIVO: Efectos premium que hacen decir "WOW" - Con panal de abeja

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../theme/theme.dart';
import '../../../services/booking/booking_configuration_service.dart';

class BookingAppBar extends StatefulWidget {
  final BookingConfiguration configuration;
  final int currentStep;
  final int totalSteps;
  final Map<String, dynamic>? companyData;
  final Map<String, dynamic>? eventData;
  final bool isMobile;

  const BookingAppBar({
    super.key,
    required this.configuration,
    required this.currentStep,
    required this.totalSteps,
    this.companyData,
    this.eventData,
    this.isMobile = false,
  });

  @override
  State<BookingAppBar> createState() => _BookingAppBarState();
}

class _BookingAppBarState extends State<BookingAppBar>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // ✨ EFECTO SHIMMER SUTIL
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // ✨ EFECTO PULSE EN ÍCONO
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // ✨ EFECTO FLOATING EN BADGES
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    // Iniciar animaciones
    _shimmerController.repeat();
    _pulseController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = context.appBarHeight - 5;

    return SliverAppBar(
      expandedHeight: height,
      floating: false,
      pinned: true,
      snap: false,
      stretch: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      // ✅ FIJO - NO SCROLL
      collapsedHeight: height, // ✅ MISMA ALTURA SIEMPRE
      toolbarHeight: height, // ✅ TOOLBAR FIJO
      flexibleSpace: Container(
        height: height,
        child: _buildPremiumWowContainer(context),
      ),
    );
  }

  /// 🚀 CONTENEDOR PREMIUM WOW - MÚLTIPLES EFECTOS
  Widget _buildPremiumWowContainer(BuildContext context) {
    final radius = 24.0;
    final isIPhoneSE = context.isIPhoneSE;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _shimmerAnimation,
        _pulseAnimation,
        _floatingAnimation,
      ]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          // ✨ CAPA 1: FONDO GLASSMORPHISM CON EFECTO AURORA
          decoration: BoxDecoration(
            gradient: _buildAuroraGradient(),
            borderRadius: BorderRadius.all(Radius.circular(radius + 8)),
            boxShadow: _buildDynamicShadows(),
          ),
          child: Padding(
            padding: EdgeInsets.all(isIPhoneSE ? 8 : 12),
            child: Container(
              width: double.infinity,
              // ✨ CAPA 2: GRADIENTE CON EFECTOS
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(radius)),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  // 🎨 GRADIENTE BASE
                  Container(
                    decoration: BoxDecoration(
                      gradient: _buildPremiumGradient(),
                      borderRadius: BorderRadius.all(Radius.circular(radius)),
                    ),
                  ),

                  // 🍯 PANAL DE ABEJA DE FONDO
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(radius)),
                    child: CustomPaint(
                      painter: HoneycombPainter(),
                      child: Container(),
                    ),
                  ),

                  // ✨ SHIMMER OVERLAY
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(radius)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin:
                              Alignment(-1.0 + _shimmerAnimation.value, -1.0),
                          end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 🎯 CONTENIDO PRINCIPAL
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        context.containerPadding,
                        20,
                        context.containerPadding,
                        isIPhoneSE ? 15 : 25,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🏷️ BADGE DE EMPRESA CON FLOATING
                          if (widget.companyData != null) ...[
                            Transform.translate(
                              offset: Offset(0, _floatingAnimation.value),
                              child: _buildFloatingCompanyBadge(context),
                            ),
                            SizedBox(height: isIPhoneSE ? 6 : 10),
                          ],

                          // 🎯 HEADER CON ÍCONO PULSANTE
                          _buildPremiumHeader(context),

                          const Spacer(),

                          // 📊 PROGRESS BAR CON EFECTO GLOW
                          _buildGlowingProgressBar(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🌈 GRADIENTE AURORA DINÁMICO
  LinearGradient _buildAuroraGradient() {
    final animationValue = _shimmerAnimation.value;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        kBrandPurple.withValues(
            alpha: 0.12 + (0.03 * math.sin(animationValue * math.pi))),
        kAccentBlue.withValues(
            alpha: 0.08 + (0.02 * math.cos(animationValue * math.pi))),
        kAccentGreen.withValues(
            alpha: 0.06 + (0.02 * math.sin(animationValue * math.pi * 1.5))),
        kBrandPurple.withValues(
            alpha: 0.04 + (0.02 * math.cos(animationValue * math.pi * 0.8))),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
  }

  /// 💎 GRADIENTE PREMIUM DE MARCA
  LinearGradient _buildPremiumGradient() {
    return kHeaderGradientPremium; // ✅ GRADIENTE DE 3 COLORES DE LA MARCA
  }

  /// 🌟 SOMBRAS DINÁMICAS
  List<BoxShadow> _buildDynamicShadows() {
    final intensity = 0.8 + (0.2 * _pulseAnimation.value);

    return [
      BoxShadow(
        color: kBrandPurple.withValues(alpha: 0.15 * intensity),
        offset: const Offset(0, 8),
        blurRadius: 32 * intensity,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: kAccentBlue.withValues(alpha: 0.08 * intensity),
        offset: const Offset(0, 16),
        blurRadius: 48 * intensity,
        spreadRadius: -8,
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.05 * intensity),
        offset: const Offset(0, -2),
        blurRadius: 8 * intensity,
        spreadRadius: 0,
      ),
    ];
  }

  /// 🏷️ BADGE FLOATING
  Widget _buildFloatingCompanyBadge(BuildContext context) {
    final isIPhoneSE = context.isIPhoneSE;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isIPhoneSE ? 10 : 16,
        vertical: isIPhoneSE ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isIPhoneSE ? 16 : 20,
            height: isIPhoneSE ? 16 : 20,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.business,
              color: kBrandPurple,
              size: isIPhoneSE ? 10 : 12,
            ),
          ),
          SizedBox(width: isIPhoneSE ? 6 : 8),
          Flexible(
            child: Text(
              widget.companyData!['nombre'] ?? 'Empresa',
              style: TextStyle(
                color: Colors.white,
                fontSize: isIPhoneSE ? 11 : 14,
                fontWeight: FontWeight.w700,
                fontFamily: kFontFamily,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 🎯 HEADER PREMIUM CON ÍCONO PULSANTE
  Widget _buildPremiumHeader(BuildContext context) {
    final iconSize = context.isIPhoneSE ? 52 : 68;
    final titleSize = context.titleSize;
    final subtitleSize = context.subtitleSize;
    final spacing = context.isIPhoneSE ? 14 : 18;

    return Row(
      children: [
        // 📱 ÍCONO PRINCIPAL CON PULSE Y GLOW
        Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: iconSize.toDouble(),
            height: iconSize.toDouble(),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [Colors.white, Colors.white],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white
                      .withValues(alpha: 0.3 * _pulseAnimation.value),
                  blurRadius: 20 * _pulseAnimation.value,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: kBrandPurple.withValues(
                      alpha: 0.2 * _pulseAnimation.value),
                  blurRadius: 15 * _pulseAnimation.value,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(context.isIPhoneSE ? 6 : 8),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    widget.configuration.icon,
                    color: Colors.white,
                    size: context.isIPhoneSE ? 28 : 36,
                  );
                },
              ),
            ),
          ),
        ),

        SizedBox(width: spacing.toDouble()),

        // 📝 TÍTULOS CON EFECTO GLOW
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.configuration.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -0.8,
                  fontFamily: kFontFamily,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                    Shadow(
                      color: Colors.white.withValues(alpha: 0.2),
                      offset: const Offset(0, 0),
                      blurRadius: 8,
                    ),
                  ],
                ),
                maxLines: context.isIPhoneSE ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: context.isIPhoneSE ? 4 : 8),
              Text(
                widget.configuration.subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                  fontFamily: kFontFamily,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                maxLines: context.isIPhoneSE ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),

              // 📅 EVENTO INFO CON GLOW
              if (widget.eventData != null) ...[
                SizedBox(height: context.isIPhoneSE ? 6 : 12),
                _buildGlowingEventInfo(context),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// 📅 EVENTO INFO CON GLOW
  Widget _buildGlowingEventInfo(BuildContext context) {
    final isIPhoneSE = context.isIPhoneSE;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isIPhoneSE ? 8 : 14,
        vertical: isIPhoneSE ? 4 : 8,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event,
              color: Colors.white,
              size: isIPhoneSE ? 8 : 12,
            ),
          ),
          SizedBox(width: isIPhoneSE ? 4 : 8),
          Flexible(
            child: Text(
              widget.eventData!['nombre'] ?? 'Evento',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: isIPhoneSE ? 10 : 12,
                fontWeight: FontWeight.w600,
                fontFamily: kFontFamily,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 PROGRESS BAR CON GLOW
  Widget _buildGlowingProgressBar(BuildContext context) {
    final progress = widget.currentStep / widget.totalSteps;
    final isIPhoneSE = context.isIPhoneSE;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Paso ${widget.currentStep} de ${widget.totalSteps}',
              style: TextStyle(
                color: Colors.white,
                fontSize: isIPhoneSE ? 12 : 14,
                fontWeight: FontWeight.w600,
                fontFamily: kFontFamily,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isIPhoneSE ? 8 : 12,
                vertical: isIPhoneSE ? 2 : 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isIPhoneSE ? 12 : 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: kFontFamily,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isIPhoneSE ? 10 : 14),
        Container(
          height: isIPhoneSE ? 4 : 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(isIPhoneSE ? 2 : 4),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            width: MediaQuery.of(context).size.width * progress,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha: 0.9),
                  kAccentGreen.withValues(alpha: 0.9),
                  Colors.white,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
              borderRadius: BorderRadius.circular(isIPhoneSE ? 2 : 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 0),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: kAccentGreen.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 🍯 PAINTER PARA PANAL DE ABEJA REAL - SIN ROMBOS
class HoneycombPainter extends CustomPainter {
  HoneycombPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.15);

    // ✅ HEXÁGONOS FLAT-TOP PERFECTOS
    final hexRadius = 25.0;

    // ✅ MATEMÁTICAS EXACTAS PARA EVITAR ROMBOS
    final hexWidth = hexRadius * 2;
    final hexHeight = hexRadius * math.sqrt(3);

    // ✅ ESPACIADO CORRECTO - SIN ROMBOS
    final dx = hexWidth * 0.75; // Horizontal correcto
    final dy = hexHeight * 0.5; // ✅ MEDIA ALTURA para encajar perfectamente

    // Calcular cuántos hexágonos caben
    final cols = (size.width / dx).ceil() + 3;
    final rows =
        (size.height / dy).ceil() + 6; // Más filas por ser más compactas

    // Dibujar el panal
    for (int row = -3; row <= rows; row++) {
      for (int col = -2; col <= cols; col++) {
        // ✅ PATRÓN HONEYCOMB PERFECTO
        final isOddRow = row % 2 == 1;
        final x = col * dx + (isOddRow ? dx * 0.5 : 0);
        final y = row * dy; // ✅ Usar dy que es media altura

        _drawFlatHexagon(canvas, paint, Offset(x, y), hexRadius);
      }
    }
  }

  /// 🔷 HEXÁGONO PLANO PERFECTO
  void _drawFlatHexagon(
      Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();

    // ✅ HEXÁGONO FLAT-TOP EXACTO - SIN ROMBOS
    final points = <Offset>[];

    for (int i = 0; i < 6; i++) {
      // ✅ ÁNGULOS EXACTOS PARA FLAT-TOP
      final angle = (i * math.pi / 3) + (math.pi / 6); // +30° para flat-top
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      points.add(Offset(x, y));
    }

    // Dibujar el hexágono conectando todos los puntos
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < 6; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
