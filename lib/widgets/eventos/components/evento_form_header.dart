// [evento_form_header.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/evento_form_header.dart
// 🎯 OBJETIVO: Header premium con progress indicator para formulario de eventos

import 'package:flutter/material.dart';
import 'dart:math' as math; // ✅ CORRECCIÓN: Agregar import para cos() y sin()
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class EventoFormHeader extends StatefulWidget {
  final String title;
  final int currentStep;
  final int totalSteps;
  final bool isEditing;

  const EventoFormHeader({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    this.isEditing = false,
  });

  @override
  State<EventoFormHeader> createState() => _EventoFormHeaderState();
}

class _EventoFormHeaderState extends State<EventoFormHeader>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _titleController;
  late Animation<double> _progressAnimation;
  late Animation<double> _titleAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
    _titleAnimation = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutBack,
    );

    _titleController.forward();
    _updateProgress();
  }

  @override
  void didUpdateWidget(EventoFormHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    final targetProgress =
        (widget.currentStep / widget.totalSteps).clamp(0.0, 1.0);
    _progressController.animateTo(targetProgress);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  List<String> get _stepLabels => [
        'Información Básica',
        'Horarios',
        'Asignaciones',
        'Revisión',
      ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kBrandPurple,
            kAccentBlue,
            kAccentGreen,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Patrón decorativo
          Positioned.fill(
            child: CustomPaint(
              painter: _HexagonPatternPainter(),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título principal
                  AnimatedBuilder(
                    animation: _titleAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - _titleAnimation.value)),
                        child: Opacity(
                          opacity: _titleAnimation.value.clamp(0.0, 1.0),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Icon(
                                  widget.isEditing
                                      ? Icons.edit_calendar
                                      : Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Text(
                                      widget.isEditing
                                          ? 'Actualiza la información del evento'
                                          : 'Configura un nuevo evento corporativo',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Badge de paso actual
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  'Paso ${widget.currentStep}/${widget.totalSteps}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Progress bar y steps
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barra de progreso
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progressAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.white, Colors.white70],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      blurRadius: 4,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Indicador de paso actual
                      if (widget.currentStep <= _stepLabels.length)
                        Text(
                          _stepLabels[widget.currentStep - 1],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HexagonPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const double hexSize = 20.0;
    const double hexWidth = hexSize * 2;
    const double hexHeight = hexSize * 1.732050808;

    final int cols = (size.width / (hexWidth * 0.75)).ceil() + 2;
    final int rows = (size.height / hexHeight).ceil() + 2;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final double offsetX = col * hexWidth * 0.75;
        final double offsetY =
            row * hexHeight + (col.isOdd ? hexHeight / 2 : 0);

        _drawHexagon(canvas, paint, offsetX, offsetY, hexSize);
      }
    }
  }

  void _drawHexagon(
      Canvas canvas, Paint paint, double x, double y, double size) {
    final path = Path();
    const double angle = math.pi / 3; // ✅ CORRECCIÓN: Usar math.pi

    for (int i = 0; i < 6; i++) {
      final double currentAngle = angle * i;
      final double dx =
          x + size * math.cos(currentAngle); // ✅ CORRECCIÓN: Usar math.cos
      final double dy =
          y + size * math.sin(currentAngle); // ✅ CORRECCIÓN: Usar math.sin

      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
