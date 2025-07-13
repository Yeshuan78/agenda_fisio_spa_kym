// [time_slot_grid_widget.dart] - WIDGET GRID DE HORARIOS EXTRAÍDO
// 📁 Ubicación: /lib/widgets/booking/components/time_slot_grid_widget.dart
// 🎯 EXTRAER: _buildTimeSlotGrid() de public_booking_screen.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class TimeSlotGridWidget extends StatelessWidget {
  final List<String> timeSlots;
  final String? selectedTime;
  final Color accentColor;
  final Function(String) onTimeSelected;

  const TimeSlotGridWidget({
    super.key,
    required this.timeSlots,
    this.selectedTime,
    required this.accentColor,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (timeSlots.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horarios disponibles',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: timeSlots.map((slot) {
            final isSelected = selectedTime == slot;

            return GestureDetector(
              onTap: () => onTimeSelected(slot),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? accentColor : kBorderSoft,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderSoft),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: kTextMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay horarios disponibles',
            style: TextStyle(
              fontSize: 16,
              color: kTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}