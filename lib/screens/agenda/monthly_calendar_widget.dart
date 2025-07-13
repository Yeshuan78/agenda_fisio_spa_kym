// ===============================================================
// [Sección 1.1] – Importaciones y declaración del widget
// ===============================================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';

class MonthlyCalendarWidget extends StatefulWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Map<DateTime, List<AppointmentModel>> events;
  final void Function(DateTime day)? onDaySelected;

  const MonthlyCalendarWidget({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.events,
    this.onDaySelected,
  });

  @override
  State<MonthlyCalendarWidget> createState() => _MonthlyCalendarWidgetState();
}

class _MonthlyCalendarWidgetState extends State<MonthlyCalendarWidget> {
  late DateTime _visibleMonth; // mes mostrado internamente

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(widget.focusedDay.year, widget.focusedDay.month);
  }

// ===============================================================
// [Sección 1.2] – Helpers internos
// ===============================================================
  void _goToPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildDots(int cantidad) {
    final puntos = List.generate(
      cantidad.clamp(1, 3),
      (_) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        width: 3,
        height: 3,
        decoration:
            const BoxDecoration(color: kBrandPurple, shape: BoxShape.circle),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: puntos,
      ),
    );
  }

// ===============================================================
// [Sección 1.3] – Build principal
// ===============================================================
  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7;

    final List<Widget> dayWidgets = [];

    // Espacios en blanco antes del primer día
    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Días del mes
    for (int day = 1; day <= daysInMonth; day++) {
      final currentDay = DateTime(_visibleMonth.year, _visibleMonth.month, day);
      final isSelected = _isSameDay(currentDay, widget.selectedDay);
      final normalized =
          DateTime(currentDay.year, currentDay.month, currentDay.day);
      final citas = widget.events[normalized] ?? [];

      dayWidgets.add(
        InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => widget.onDaySelected?.call(currentDay),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? kAccentGreen : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                if (citas.isNotEmpty) _buildDots(citas.length),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBrandPurple),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        children: [
          // --------------------- Encabezado con flechas ---------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                color: kBrandPurple,
                splashRadius: 18,
                onPressed: _goToPreviousMonth,
              ),
              Text(
                DateFormat('MMMM yyyy', 'es_MX').format(_visibleMonth),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                color: kBrandPurple,
                splashRadius: 18,
                onPressed: _goToNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 4),
          // --------------------- Días de la semana --------------------------
          _buildDaysOfWeekHeader(),
          const SizedBox(height: 4),
          // --------------------- Cuadrícula de días -------------------------
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              mainAxisSpacing: 1, // más compacto
              crossAxisSpacing: 2,
              childAspectRatio: 1.6, // reduce altura de celdas
              children: dayWidgets,
            ),
          ),
        ],
      ),
    );
  }

// ===============================================================
// [Sección 1.4] – Cabecera con iniciales de días
// ===============================================================
  Widget _buildDaysOfWeekHeader() {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map((d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
