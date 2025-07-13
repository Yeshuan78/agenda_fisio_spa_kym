// [eventos_stats_section.dart] - EXTRACCIÓN QUIRÚRGICA EXACTA
// 📁 Ubicación: /lib/widgets/eventos/components/eventos_stats_section.dart
// 🎯 COPY-PASTE EXACTO de líneas 520-600 eventos_screen.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/evento_model.dart';

class EventosStatsSection extends StatelessWidget {
  final List<EventoModel> eventos;
  final Animation<double> headerAnimation;

  const EventosStatsSection({
    super.key,
    required this.eventos,
    required this.headerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final totalEventos = eventos.length;
    final eventosActivos = eventos.where((e) => e.estado == 'activo').length;
    final eventosCompletados = eventos.where((e) => e.estado == 'completado').length;

    return AnimatedBuilder(
      animation: headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - headerAnimation.value)),
          child: Opacity(
            opacity: headerAnimation.value,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildStatCard('Total', totalEventos.toString(), kBrandPurple, Icons.event),
                      const SizedBox(width: 12),
                      _buildStatCard('Activos', eventosActivos.toString(), kAccentGreen, Icons.play_circle_filled),
                      const SizedBox(width: 12),
                      _buildStatCard('Completados', eventosCompletados.toString(), kAccentBlue, Icons.check_circle),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.02)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.01),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}