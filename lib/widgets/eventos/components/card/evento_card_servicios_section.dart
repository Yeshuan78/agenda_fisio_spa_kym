// [evento_card_servicios_section.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/card/evento_card_servicios_section.dart
// 🎯 EXTRACCIÓN QUIRÚRGICA: Sección de servicios asignados del EventoCard original

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/evento_model.dart';
import 'evento_card_servicio_item.dart';

class EventoCardServiciosSection extends StatelessWidget {
  final EventoModel evento;
  final Animation<double> copyAnimation;

  const EventoCardServiciosSection({
    super.key,
    required this.evento,
    required this.copyAnimation,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ EXTRACCIÓN EXACTA del método _buildServiciosAsignados() líneas 730-850
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFE0E0E0).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kAccentGreen.withValues(alpha: 0.02),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.assignment_turned_in,
                    color: kAccentGreen, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Servicios Asignados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kAccentGreen,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kAccentGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${evento.serviciosAsignados.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            child: evento.serviciosAsignados.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: evento.serviciosAsignados.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final asignacion = evento.serviciosAsignados[index];
                      return EventoCardServicioItem(
                        asignacion: asignacion,
                        index: index,
                        evento: evento,
                        copyAnimation: copyAnimation,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ✅ EXTRACCIÓN EXACTA del método _buildEmptyState()
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No hay servicios asignados',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
