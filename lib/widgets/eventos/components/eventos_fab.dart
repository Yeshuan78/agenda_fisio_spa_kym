// [eventos_fab.dart] - EXTRACCIÓN QUIRÚRGICA EXACTA
// 📁 Ubicación: /lib/widgets/eventos/components/eventos_fab.dart
// 🎯 COPY-PASTE EXACTO de líneas 900-950 eventos_screen.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class EventosFab extends StatelessWidget {
  final Animation<double> fabAnimation;
  final VoidCallback onPressed;

  const EventosFab({
    super.key,
    required this.fabAnimation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: fabAnimation.value,
          child: Transform.rotate(
            angle: (1 - fabAnimation.value) * 0.5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kBrandPurple.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: onPressed,
                backgroundColor: kBrandPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                icon: const Icon(Icons.add_rounded, size: 24),
                label: const Text(
                  'Nuevo Evento',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}