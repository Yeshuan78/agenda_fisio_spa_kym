// [evento_horario_section.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/evento_horario_section.dart
// 🎯 OBJETIVO: Sección de horarios premium con time pickers y validación

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/components/premium_time_range_picker.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/components/horario_duration_indicator.dart';

class EventoHorarioSection extends StatelessWidget {
  final String horarioInicio;
  final String horarioFin;
  final Function(String inicio, String fin) onHorarioChanged;

  const EventoHorarioSection({
    super.key,
    required this.horarioInicio,
    required this.horarioFin,
    required this.onHorarioChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: kAccentGreen.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de sección
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kAccentGreen, kAccentBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horario del Evento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Define el horario general del evento',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Indicador de estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isValidTimeRange() 
                      ? kAccentGreen.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isValidTimeRange() 
                        ? kAccentGreen.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isValidTimeRange() ? Icons.check_circle : Icons.warning,
                      size: 14,
                      color: _isValidTimeRange() ? kAccentGreen : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isValidTimeRange() ? 'Válido' : 'Revisar',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _isValidTimeRange() ? kAccentGreen : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Time Range Picker Premium
          PremiumTimeRangePicker(
            startTime: horarioInicio,
            endTime: horarioFin,
            onChanged: onHorarioChanged,
            minDuration: const Duration(hours: 2),
            maxDuration: const Duration(hours: 12),
          ),

          // Indicador visual de duración
          HorarioDurationIndicator(
            inicio: horarioInicio,
            fin: horarioFin,
          ),

          // Tips y recomendaciones
          const SizedBox(height: 16),
          _buildRecommendations(),
        ],
      ),
    );
  }

  bool _isValidTimeRange() {
    try {
      final start = _parseTime(horarioInicio);
      final end = _parseTime(horarioFin);
      
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;
      
      // Validar que fin sea después de inicio y duración mínima de 2 horas
      return endMinutes > startMinutes && (endMinutes - startMinutes) >= 120;
    } catch (e) {
      return false;
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  Widget _buildRecommendations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kAccentBlue.withValues(alpha: 0.05),
            kAccentGreen.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccentBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kAccentBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Recomendaciones',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kAccentBlue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          _buildRecommendationItem(
            '⏰',
            'Duración óptima: 4-6 horas para eventos corporativos',
          ),
          _buildRecommendationItem(
            '🕘',
            'Horario laboral: 9:00 AM - 5:00 PM es ideal',
          ),
          _buildRecommendationItem(
            '📋',
            'Las asignaciones individuales se ajustarán a este horario',
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}