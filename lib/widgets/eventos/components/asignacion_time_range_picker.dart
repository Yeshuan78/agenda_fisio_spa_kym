// [asignacion_time_range_picker.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/asignacion_time_range_picker.dart
// 🎯 OBJETIVO: Time picker específico para asignaciones individuales

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class AsignacionTimeRangePicker extends StatefulWidget {
  final String startTime;
  final String endTime;
  final String? eventoStartTime;
  final String? eventoEndTime;
  final Function(String start, String end) onChanged;

  const AsignacionTimeRangePicker({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onChanged,
    this.eventoStartTime,
    this.eventoEndTime,
  });

  @override
  State<AsignacionTimeRangePicker> createState() => _AsignacionTimeRangePickerState();
}

class _AsignacionTimeRangePickerState extends State<AsignacionTimeRangePicker>
    with TickerProviderStateMixin {
  late AnimationController _validationController;
  late Animation<Color?> _colorAnimation;
  bool _hasValidationError = false;

  @override
  void initState() {
    super.initState();
    _validationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: kAccentGreen,
      end: Colors.red.shade400,
    ).animate(_validationController);
  }

  @override
  void dispose() {
    _validationController.dispose();
    super.dispose();
  }

  bool _validateTimeRange(String start, String end) {
    try {
      final startTime = _parseTime(start);
      final endTime = _parseTime(end);
      
      // Validar que fin sea después de inicio
      final startMinutes = startTime.hour * 60 + startTime.minute;
      final endMinutes = endTime.hour * 60 + endTime.minute;
      
      if (endMinutes <= startMinutes) {
        return false;
      }

      // Validar duración mínima (30 minutos)
      if (endMinutes - startMinutes < 30) {
        return false;
      }

      // Validar que esté dentro del rango del evento si se especifica
      if (widget.eventoStartTime != null && widget.eventoEndTime != null) {
        final eventoStart = _parseTime(widget.eventoStartTime!);
        final eventoEnd = _parseTime(widget.eventoEndTime!);
        
        final eventoStartMinutes = eventoStart.hour * 60 + eventoStart.minute;
        final eventoEndMinutes = eventoEnd.hour * 60 + eventoEnd.minute;
        
        if (startMinutes < eventoStartMinutes || endMinutes > eventoEndMinutes) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void _updateStartTime(String time) {
    final isValid = _validateTimeRange(time, widget.endTime);
    setState(() {
      _hasValidationError = !isValid;
    });
    
    if (isValid) {
      _validationController.reverse();
      widget.onChanged(time, widget.endTime);
    } else {
      _validationController.forward();
    }
  }

  void _updateEndTime(String time) {
    final isValid = _validateTimeRange(widget.startTime, time);
    setState(() {
      _hasValidationError = !isValid;
    });
    
    if (isValid) {
      _validationController.reverse();
      widget.onChanged(widget.startTime, time);
    } else {
      _validationController.forward();
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

  String _getDurationText() {
    try {
      final start = _parseTime(widget.startTime);
      final end = _parseTime(widget.endTime);
      
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;
      final durationMinutes = endMinutes - startMinutes;
      
      if (durationMinutes <= 0) return 'Duración inválida';
      
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      
      if (hours > 0 && minutes > 0) {
        return '${hours}h ${minutes}min';
      } else if (hours > 0) {
        return '${hours}h';
      } else {
        return '${minutes}min';
      }
    } catch (e) {
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _hasValidationError 
                ? Colors.red.shade50 
                : kAccentGreen.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hasValidationError 
                  ? Colors.red.shade300 
                  : kAccentGreen.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con ícono y título
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _hasValidationError 
                          ? Colors.red.shade400 
                          : kAccentGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _hasValidationError ? Icons.error : Icons.schedule,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Horario de Asignación',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _hasValidationError 
                          ? Colors.red.shade700 
                          : kAccentGreen,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _hasValidationError 
                          ? Colors.red.shade100 
                          : kAccentGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getDurationText(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _hasValidationError 
                            ? Colors.red.shade700 
                            : kAccentGreen,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker(
                      label: 'Inicio',
                      time: widget.startTime,
                      onChanged: _updateStartTime,
                      icon: Icons.play_arrow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimePicker(
                      label: 'Fin',
                      time: widget.endTime,
                      onChanged: _updateEndTime,
                      icon: Icons.stop,
                    ),
                  ),
                ],
              ),
              
              // Mensaje de validación
              if (_hasValidationError) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: Colors.red.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Horario inválido. Revisa duración mínima y rango del evento.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimePicker({
    required String label,
    required String time,
    required Function(String) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _hasValidationError 
              ? Colors.red.shade200 
              : kBorderColor.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: _parseTime(time),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: _hasValidationError ? Colors.red.shade400 : kAccentGreen,
                      onSurface: Colors.black87,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
              onChanged(formattedTime);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: _hasValidationError 
                          ? Colors.red.shade400 
                          : kAccentGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _hasValidationError 
                            ? Colors.red.shade600 
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _hasValidationError 
                        ? Colors.red.shade700 
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}