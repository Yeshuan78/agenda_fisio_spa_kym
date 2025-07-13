// [event_selector_widget.dart] - WIDGET SELECTOR DE EVENTOS EXTRAÍDO
// 📁 Ubicación: /lib/widgets/booking/components/event_selector_widget.dart
// 🎯 EXTRAER: _buildEventSelector() de public_booking_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class EventSelectorWidget extends StatelessWidget {
  final List<DocumentSnapshot> eventos;
  final String? selectedEventId;
  final Function(String) onEventSelected;

  const EventSelectorWidget({
    super.key,
    required this.eventos,
    this.selectedEventId,
    required this.onEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona el evento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kBrandPurple,
          ),
        ),
        const SizedBox(height: 12),
        ...eventos.map((event) {
          final data = event.data() as Map<String, dynamic>;
          final isSelected = selectedEventId == event.id;
          final fecha = (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now();

          return GestureDetector(
            onTap: () => onEventSelected(event.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? kBrandPurple : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? kSombraCard : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    color: isSelected ? kBrandPurple : Colors.grey[500],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['nombre'] ?? 'Evento',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? kBrandPurple : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(fecha),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: kBrandPurple),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}