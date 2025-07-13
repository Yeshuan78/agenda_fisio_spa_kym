// [booking_progress_bar.dart] - BARRA DE PROGRESO PREMIUM
// 📁 Ubicación: /lib/widgets/booking/components/booking_progress_bar.dart
// 🎯 OBJETIVO: Progress bar con gradiente de 3 colores y animación suave
// ✅ OPTIMIZADO: ResponsiveMetrics + Gradiente Premium + iPhone SE

import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class BookingProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const BookingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;
    final isIPhoneSE = context.isIPhoneSE;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Paso $currentStep de $totalSteps',
              style: TextStyle(
                color: Colors.white,
                fontSize: isIPhoneSE ? 12 : 14,
                fontWeight: FontWeight.w500,
                fontFamily: kFontFamily,
              ),
            ),
            Text(
              '${(progress * 100).round()}% completado',
              style: TextStyle(
                color: Colors.white,
                fontSize: isIPhoneSE ? 12 : 14,
                fontWeight: FontWeight.w500,
                fontFamily: kFontFamily,
              ),
            ),
          ],
        ),
        SizedBox(height: isIPhoneSE ? 8 : 12),
        Container(
          height: isIPhoneSE ? 3 : 6, // ✅ MÁS DELGADO EN iPhone SE
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(isIPhoneSE ? 1.5 : 3),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600), // ✅ ANIMACIÓN SUAVE
            curve: Curves.easeOutCubic,
            width: MediaQuery.of(context).size.width * progress,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha: 0.9),
                  kAccentGreen.withValues(alpha: 0.9), // ✅ TOQUE DE COLOR VERDE
                ],
                stops: [0.0, 0.7, 1.0],
              ),
              borderRadius: BorderRadius.circular(isIPhoneSE ? 1.5 : 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: isIPhoneSE ? 4 : 8,
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

/// 🌟 VARIANTE PREMIUM CON GRADIENTE DE 3 COLORES DE MARCA
class BookingProgressBarPremium extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final bool animated;
  final Color? customColor;

  const BookingProgressBarPremium({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.animated = true,
    this.customColor,
  });

  @override
  State<BookingProgressBarPremium> createState() =>
      _BookingProgressBarPremiumState();
}

class _BookingProgressBarPremiumState extends State<BookingProgressBarPremium>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _glowController;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.animated) {
      _progressController = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      );

      _glowController = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      );

      _progressAnimation = Tween<double>(
        begin: 0.0,
        end: widget.currentStep / widget.totalSteps,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));

      _glowAnimation = Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ));

      // Iniciar animaciones
      _progressController.forward();
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BookingProgressBarPremium oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animated && widget.currentStep != oldWidget.currentStep) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.currentStep / widget.totalSteps,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _progressController.dispose();
      _glowController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.currentStep / widget.totalSteps;
    final isIPhoneSE = context.isIPhoneSE;

    if (!widget.animated) {
      return _buildStaticProgressBar(context, progress, isIPhoneSE);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _glowAnimation]),
      builder: (context, child) {
        return _buildAnimatedProgressBar(context, isIPhoneSE);
      },
    );
  }

  Widget _buildStaticProgressBar(
      BuildContext context, double progress, bool isIPhoneSE) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabels(context, isIPhoneSE),
        SizedBox(height: isIPhoneSE ? 8 : 12),
        _buildProgressContainer(context, progress, isIPhoneSE, false),
      ],
    );
  }

  Widget _buildAnimatedProgressBar(BuildContext context, bool isIPhoneSE) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabels(context, isIPhoneSE),
        SizedBox(height: isIPhoneSE ? 8 : 12),
        _buildProgressContainer(
            context, _progressAnimation.value, isIPhoneSE, true),
      ],
    );
  }

  Widget _buildLabels(BuildContext context, bool isIPhoneSE) {
    final progress = widget.currentStep / widget.totalSteps;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Paso ${widget.currentStep} de ${widget.totalSteps}',
          style: TextStyle(
            color: Colors.white,
            fontSize: isIPhoneSE ? 12 : 14,
            fontWeight: FontWeight.w500,
            fontFamily: kFontFamily,
          ),
        ),
        Text(
          '${(progress * 100).round()}% completado',
          style: TextStyle(
            color: Colors.white,
            fontSize: isIPhoneSE ? 12 : 14,
            fontWeight: FontWeight.w500,
            fontFamily: kFontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressContainer(
      BuildContext context, double progress, bool isIPhoneSE, bool animated) {
    return Container(
      height: isIPhoneSE ? 3 : 6,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kBrandPurple.withValues(alpha: 0.2),
            kAccentBlue.withValues(alpha: 0.2),
            kAccentGreen.withValues(alpha: 0.2),
          ], // ✅ BACKGROUND CON 3 COLORES
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(isIPhoneSE ? 1.5 : 3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient:
                kHeaderGradientPremium, // ✅ GRADIENTE PREMIUM DE 3 COLORES
            borderRadius: BorderRadius.circular(isIPhoneSE ? 1.5 : 3),
            boxShadow: animated && widget.animated
                ? [
                    BoxShadow(
                      color: kBrandPurple.withValues(
                          alpha: 0.4 * _glowAnimation.value),
                      blurRadius: (isIPhoneSE ? 8 : 12) * _glowAnimation.value,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: kAccentBlue.withValues(
                          alpha: 0.3 * _glowAnimation.value),
                      blurRadius: (isIPhoneSE ? 6 : 10) * _glowAnimation.value,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: kBrandPurple.withValues(alpha: 0.3),
                      blurRadius: isIPhoneSE ? 4 : 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}

/// ⭐ VARIANTE CIRCULAR PREMIUM
class BookingProgressBarCircular extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final double size;
  final double strokeWidth;
  final bool showLabel;

  const BookingProgressBarCircular({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.size = 80,
    this.strokeWidth = 6,
    this.showLabel = true,
  });

  @override
  State<BookingProgressBarCircular> createState() =>
      _BookingProgressBarCircularState();
}

class _BookingProgressBarCircularState extends State<BookingProgressBarCircular>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.currentStep / widget.totalSteps,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(BookingProgressBarCircular oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentStep != oldWidget.currentStep) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.currentStep / widget.totalSteps,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // CÍRCULO DE FONDO
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _CircularProgressBackgroundPainter(
              strokeWidth: widget.strokeWidth,
            ),
          ),

          // CÍRCULO DE PROGRESO ANIMADO
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircularProgressPainter(
                  progress: _animation.value,
                  strokeWidth: widget.strokeWidth,
                ),
              );
            },
          ),

          // LABEL CENTRAL
          if (widget.showLabel)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.currentStep}',
                  style: TextStyle(
                    fontSize: widget.size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: kBrandPurple,
                    fontFamily: kFontFamily,
                  ),
                ),
                Text(
                  'de ${widget.totalSteps}',
                  style: TextStyle(
                    fontSize: widget.size * 0.12,
                    color: kTextSecondary,
                    fontFamily: kFontFamily,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// 🎨 PAINTER PARA CÍRCULO DE FONDO
class _CircularProgressBackgroundPainter extends CustomPainter {
  final double strokeWidth;

  _CircularProgressBackgroundPainter({required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = kBorderSoft
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🎨 PAINTER PARA CÍRCULO DE PROGRESO
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // GRADIENTE CIRCULAR PREMIUM
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      colors: [kBrandPurple, kAccentBlue, kAccentGreen, kBrandPurple],
      stops: [0.0, 0.33, 0.66, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // DIBUJAR ARCO DE PROGRESO
    const startAngle = -1.5708; // -90 grados (empezar arriba)
    final sweepAngle = 2 * 3.14159 * progress; // Ángulo según progreso

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// 📊 VARIANTE CON STEPS DISCRETOS
class BookingProgressBarSteps extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;
  final double height;

  const BookingProgressBarSteps({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    final isIPhoneSE = context.isIPhoneSE;
    final stepWidth = (MediaQuery.of(context).size.width - 64) / totalSteps;

    return Container(
      height: height,
      child: Row(
        children: List.generate(totalSteps, (index) {
          final stepNumber = index + 1;
          final isActive = stepNumber <= currentStep;
          final isCurrent = stepNumber == currentStep;

          return Expanded(
            child: Column(
              children: [
                // STEP INDICATOR
                Container(
                  width: isIPhoneSE ? 24 : 32,
                  height: isIPhoneSE ? 24 : 32,
                  decoration: BoxDecoration(
                    color: isActive ? kBrandPurple : kBorderSoft,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: kAccentBlue, width: 3)
                        : null,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: kBrandPurple.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isActive
                        ? Icon(
                            stepNumber < currentStep
                                ? Icons.check
                                : Icons.circle,
                            color: Colors.white,
                            size: isIPhoneSE ? 12 : 16,
                          )
                        : Text(
                            stepNumber.toString(),
                            style: TextStyle(
                              color: kTextMuted,
                              fontSize: isIPhoneSE ? 10 : 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: kFontFamily,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: isIPhoneSE ? 6 : 8),

                // STEP LABEL
                if (stepLabels != null && index < stepLabels!.length)
                  Expanded(
                    child: Text(
                      stepLabels![index],
                      style: TextStyle(
                        fontSize: isIPhoneSE ? 10 : 12,
                        color: isActive ? kBrandPurple : kTextMuted,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                        fontFamily: kFontFamily,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // CONNECTOR LINE
                if (index < totalSteps - 1)
                  Positioned(
                    top: isIPhoneSE ? 12 : 16,
                    left: isIPhoneSE ? 32 : 40,
                    child: Container(
                      width: stepWidth - (isIPhoneSE ? 32 : 40),
                      height: 2,
                      color:
                          stepNumber < currentStep ? kBrandPurple : kBorderSoft,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// 🎯 VARIANTE MINIMALISTA PARA ESPACIOS PEQUEÑOS
class BookingProgressBarMini extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool showPercentage;

  const BookingProgressBarMini({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;
    final isIPhoneSE = context.isIPhoneSE;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: isIPhoneSE ? 2 : 3,
            decoration: BoxDecoration(
              color: kBorderSoft,
              borderRadius: BorderRadius.circular(isIPhoneSE ? 1 : 1.5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: kHeaderGradientPremium, // ✅ GRADIENTE PREMIUM
                  borderRadius: BorderRadius.circular(isIPhoneSE ? 1 : 1.5),
                ),
              ),
            ),
          ),
        ),
        if (showPercentage) ...[
          SizedBox(width: isIPhoneSE ? 6 : 8),
          Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              fontSize: isIPhoneSE ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: kBrandPurple,
              fontFamily: kFontFamily,
            ),
          ),
        ],
      ],
    );
  }
}
