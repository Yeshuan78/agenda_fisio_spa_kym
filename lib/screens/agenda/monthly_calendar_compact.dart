import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class MonthlyCalendarCompact extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Map<DateTime, List<AppointmentModel>> events;
  final void Function(DateTime day)? onDaySelected;

  const MonthlyCalendarCompact({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.events,
    this.onDaySelected,
  });

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<DateTime> _generateDays(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final startWeekday = first.weekday % 7;
    final total = last.day + startWeekday;

    return List.generate(total, (index) {
      if (index < startWeekday) return DateTime(0);
      return DateTime(month.year, month.month, index - startWeekday + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _generateDays(focusedDay);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBrandPurple),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Encabezado
          Text(
            DateFormat('MMMM yyyy', 'es_MX').format(focusedDay),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: kBrandPurple,
            ),
          ),
          const SizedBox(height: 6),
          // Iniciales de días
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          // Días del mes
          Wrap(
            spacing: 2,
            runSpacing: 2,
            children: days.map((day) {
              final isPlaceholder = day.year == 0;
              final isSelected = _isSameDay(day, selectedDay);
              final key = DateTime(day.year, day.month, day.day);
              final cantidad = events[key]?.length ?? 0;

              return SizedBox(
                width: 32,
                height: 32,
                child: isPlaceholder
                    ? const SizedBox()
                    : GestureDetector(
                        onTap: () => onDaySelected?.call(day),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isSelected ? kAccentGreen : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              if (cantidad > 0)
                                Positioned(
                                  bottom: 3,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      cantidad.clamp(1, 3),
                                      (_) => Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 1),
                                        width: 3,
                                        height: 3,
                                        decoration: const BoxDecoration(
                                          color: kBrandPurple,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
