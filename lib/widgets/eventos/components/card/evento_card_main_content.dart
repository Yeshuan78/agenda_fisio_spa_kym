// [evento_card_main_content.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/card/evento_card_main_content.dart
// 🎯 EXTRACCIÓN QUIRÚRGICA: Layout principal de 3 columnas del EventoCard original

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/evento_model.dart';
import 'evento_card_info_section.dart';
import 'evento_card_servicios_section.dart';
import 'evento_card_actions_section.dart';

class EventoCardMainContent extends StatelessWidget {
  final EventoModel evento;
  final Animation<double> copyAnimation;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventoCardMainContent({
    super.key,
    required this.evento,
    required this.copyAnimation,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ EXTRACCIÓN EXACTA del método _buildMainContent() líneas 520-580
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ COLUMNA 1: INFORMACIÓN DEL EVENTO
          Expanded(
            flex: 2,
            child: EventoCardInfoSection(evento: evento),
          ),

          const SizedBox(width: 32),

          // ✅ COLUMNA 2: SERVICIOS ASIGNADOS
          Expanded(
            flex: 3,
            child: EventoCardServiciosSection(
              evento: evento,
              copyAnimation: copyAnimation,
            ),
          ),

          const SizedBox(width: 24),

          // ✅ COLUMNA 3: ACCIONES
          EventoCardActionsSection(
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}
