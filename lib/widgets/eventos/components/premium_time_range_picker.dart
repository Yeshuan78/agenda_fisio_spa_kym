// [premium_time_range_picker.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/premium_time_range_picker.dart
// 🎯 OBJETIVO: Time picker premium para horarios de evento

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class PremiumTimeRangePicker extends StatefulWidget {
  final String startTime;
  final String endTime;
  final Function(String start, String end) onChanged;
  final Duration minDuration;
  final Duration maxDuration;

  const PremiumTimeRangePicker({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onChanged,
    this.minDuration = const Duration(hours: 2),
    this.maxDuration = const Duration(hours: 12),
  });

  @override
  State<PremiumTimeRangePicker> createState() => _PremiumTimeRangePickerState();
}

class _PremiumTimeRangePickerState extends State<PremiumTimeRangePicker>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _updateStartTime(String time) {
    widget.onChanged(time, widget.endTime);
  }

  void _updateEndTime(String time) {
    widget.onChanged(widget.startTime, time);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            kBrandPurpleLight.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Time picker inicio
          Expanded(
            child: PremiumTimePicker(
              label: 'Hora de Inicio',
              time: widget.startTime,
              onChanged: _updateStartTime,
              icon: Icons.access_time,
              color: kAccentGreen,
            ),
          ),

          // Separador animado
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kBrandPurple.withValues(alpha: 0.1 + (_pulseAnimation.value * 0.05)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: kBrandPurple,
                  size: 20,
                ),
              );
            },
          ),

          // Time picker fin
          Expanded(
            child: PremiumTimePicker(
              label: 'Hora de Fin',
              time: widget.endTime,
              onChanged: _updateEndTime,
              icon: Icons.schedule,
              color: kAccentBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumTimePicker extends StatelessWidget {
  final String label;
  final String time;
  final Function(String) onChanged;
  final IconData icon;
  final Color color;

  const PremiumTimePicker({
    super.key,
    required this.label,
    required this.time,
    required this.onChanged,
    required this.icon,
    required this.color,
  });

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(time),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: color,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectTime(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
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