// [evento_card_info_section.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/card/evento_card_info_section.dart
// 🎯 EXTRACCIÓN QUIRÚRGICA: Sección de información del EventoCard original

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/evento_model.dart';

class EventoCardInfoSection extends StatelessWidget {
  final EventoModel evento;

  const EventoCardInfoSection({
    super.key,
    required this.evento,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ EXTRACCIÓN EXACTA del método _buildEventoInfo() líneas 650-720
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBrandPurple.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBrandPurple.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: kBrandPurple, size: 18),
              SizedBox(width: 8),
              Text(
                'Detalles del Evento',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kBrandPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (evento.observaciones.isNotEmpty)
            Text(
              evento.observaciones,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }
}