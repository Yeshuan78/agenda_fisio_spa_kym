// [evento_card_header.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/card/evento_card_header.dart
// 🎯 EXTRACCIÓN QUIRÚRGICA: Header premium del EventoCard original

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/evento_model.dart';
import 'evento_card_utils.dart';

class EventoCardHeader extends StatelessWidget {
  final EventoModel evento;
  final bool isHovered;
  final VoidCallback onEstadoTap;

  const EventoCardHeader({
    super.key,
    required this.evento,
    required this.isHovered,
    required this.onEstadoTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ EXTRACCIÓN EXACTA del método _buildPremiumHeader() líneas 350-500
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // ✅ GRADIENTE MUY SUTIL (NO AGRESIVO)
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            EventoCardUtils.getStatusColor(evento.estado).withValues(alpha: 0.02), // Muy sutil
            EventoCardUtils.getStatusColor(evento.estado).withValues(alpha: 0.005),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // ✅ AVATAR ELEGANTE
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  EventoCardUtils.getStatusColor(evento.estado).withValues(alpha: 0.1),
                  EventoCardUtils.getStatusColor(evento.estado).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: EventoCardUtils.getStatusColor(evento.estado).withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.event_available,
              color: EventoCardUtils.getStatusColor(evento.estado),
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // ✅ INFORMACIÓN PRINCIPAL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.nombre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  evento.empresa,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMetaChip(
                      Icons.calendar_today,
                      DateFormat('d MMM yyyy', 'es_MX')
                          .format(evento.fecha),
                      kAccentBlue,
                    ),
                    const SizedBox(width: 8),
                    _buildMetaChip(
                      Icons.location_on,
                      evento.ubicacion,
                      kAccentGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ✅ BADGE DE ESTADO VISIBLE + SELECTOR
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ✅ BADGE DE ESTADO MÁS VISIBLE
              GestureDetector(
                onTap: onEstadoTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        EventoCardUtils.getStatusColor(evento.estado),
                        EventoCardUtils.getStatusColor(evento.estado).withValues(alpha: 0.8)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: EventoCardUtils.getStatusColor(evento.estado).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(EventoCardUtils.getStatusIcon(evento.estado), color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        EventoCardUtils.getStatusLabel(evento.estado).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ✅ INDICADOR DE SERVICIOS
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kAccentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: kAccentGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.assignment, size: 14, color: kAccentGreen),
                    const SizedBox(width: 4),
                    Text(
                      '${evento.serviciosAsignados.length} servicios',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kAccentGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ EXTRACCIÓN EXACTA del método _buildMetaChip()
  Widget _buildMetaChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}