// [horario_duration_indicator.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/horario_duration_indicator.dart
// 🎯 OBJETIVO: Indicador visual premium de duración de horario

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class HorarioDurationIndicator extends StatefulWidget {
  final String inicio;
  final String fin;

  const HorarioDurationIndicator({
    super.key,
    required this.inicio,
    required this.fin,
  });

  @override
  State<HorarioDurationIndicator> createState() => _HorarioDurationIndicatorState();
}

class _HorarioDurationIndicatorState extends State<HorarioDurationIndicator>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _progressController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
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

  Map<String, dynamic> _calculateDuration() {
    try {
      final start = _parseTime(widget.inicio);
      final end = _parseTime(widget.fin);
      
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;
      final durationMinutes = endMinutes - startMinutes;
      
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      
      String formattedDuration;
      if (hours > 0 && minutes > 0) {
        formattedDuration = '${hours}h ${minutes}min';
      } else if (hours > 0) {
        formattedDuration = '${hours}h';
      } else {
        formattedDuration = '${minutes}min';
      }
      
      // Calcular progreso basado en un día laboral de 8 horas
      final progress = (durationMinutes / (8 * 60)).clamp(0.0, 1.0);
      
      Color progressColor;
      String statusText;
      
      if (durationMinutes < 120) { // Menos de 2 horas
        progressColor = Colors.orange.shade400;
        statusText = 'Evento corto';
      } else if (durationMinutes < 480) { // Menos de 8 horas
        progressColor = kAccentGreen;
        statusText = 'Duración óptima';
      } else { // 8 horas o más
        progressColor = kAccentBlue;
        statusText = 'Evento completo';
      }
      
      return {
        'duration': formattedDuration,
        'minutes': durationMinutes,
        'progress': progress,
        'color': progressColor,
        'status': statusText,
      };
    } catch (e) {
      return {
        'duration': 'Error',
        'minutes': 0,
        'progress': 0.0,
        'color': Colors.red.shade400,
        'status': 'Horario inválido',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final durationData = _calculateDuration();
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            (durationData['color'] as Color).withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (durationData['color'] as Color).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Header con información
          Row(
            children: [
              // Icono con estado
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (durationData['color'] as Color).withValues(
                        alpha: 0.1 + (_pulseAnimation.value * 0.05),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (durationData['color'] as Color).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      _getStatusIcon(durationData['minutes'] as int),
                      color: durationData['color'] as Color,
                      size: 20,
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 12),
              
              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Duración del Evento',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: (durationData['color'] as Color),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      durationData['duration'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (durationData['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  durationData['status'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: durationData['color'] as Color,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Barra de progreso animada
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso del día laboral',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${((durationData['progress'] as double) * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: durationData['color'] as Color,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Barra de progreso custom
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (durationData['progress'] as double) * _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              durationData['color'] as Color,
                              (durationData['color'] as Color).withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Timeline visual
          _buildTimeline(durationData),
        ],
      ),
    );
  }

  Widget _buildTimeline(Map<String, dynamic> durationData) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Inicio
          Expanded(
            child: Column(
              children: [
                Text(
                  'INICIO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.inicio,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // Separador con duración
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        durationData['color'] as Color,
                        (durationData['color'] as Color).withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  durationData['duration'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: durationData['color'] as Color,
                  ),
                ),
              ],
            ),
          ),
          
          // Fin
          Expanded(
            child: Column(
              children: [
                Text(
                  'FIN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.fin,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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

  IconData _getStatusIcon(int minutes) {
    if (minutes < 120) {
      return Icons.access_time;
    } else if (minutes < 480) {
      return Icons.schedule;
    } else {
      return Icons.event_available;
    }
  }
}