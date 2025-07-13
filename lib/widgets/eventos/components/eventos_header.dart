// [eventos_header.dart] - EXTRACCIÓN QUIRÚRGICA EXACTA
// 📁 Ubicación: /lib/widgets/eventos/components/eventos_header.dart
// 🎯 COPY-PASTE EXACTO de líneas 280-350 eventos_screen.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class EventosHeader extends StatelessWidget {
  final Animation<double> headerAnimation;
  final int totalEventos;
  final int eventosActivos;

  const EventosHeader({
    super.key,
    required this.headerAnimation,
    required this.totalEventos,
    required this.eventosActivos,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: kBrandPurple,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
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
          child: CustomPaint(
            painter: _PatternPainter(),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: headerAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (headerAnimation.value * 0.1),
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.event_available_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gestión de Eventos',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: kFontFamily,
                                letterSpacing: -1.0,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Administra todos tus eventos corporativos',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontFamily: kFontFamily,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Painter para el patrón decorativo del header - COPY EXACTO
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.01)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < size.width; i += 40) {
      for (int j = 0; j < size.height; j += 40) {
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 20, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}