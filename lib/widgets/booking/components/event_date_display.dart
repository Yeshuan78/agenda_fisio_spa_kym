// [event_date_display.dart] - WIDGET DISPLAY DE FECHA EVENTO EXTRAÍDO
// 📁 Ubicación: /lib/widgets/booking/components/event_date_display.dart
// 🎯 EXTRAER: _buildEventDateDisplay() de public_booking_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class EventDateDisplay extends StatelessWidget {
  final Map<String, dynamic>? selectedEventData;

  const EventDateDisplay({
    super.key,
    this.selectedEventData,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedEventData == null) return Container();

    final fechaEvento = (selectedEventData!['fecha'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kAccentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAccentGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kAccentGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fecha del evento',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kTextSecondary,
                  ),
                ),
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'es_MX').format(fechaEvento),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}