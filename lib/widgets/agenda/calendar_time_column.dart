// [calendar_time_column.dart]
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class CalendarTimeColumn extends StatelessWidget {
  final List<DateTime> timeSlots;
  final ScrollController controller;
  final double height;
  final double width;
  final int workStartHour;
  final int workEndHour;

  const CalendarTimeColumn({
    super.key,
    required this.timeSlots,
    required this.controller,
    this.height = 85.0,
    this.width = 140.0,
    this.workStartHour = 8,
    this.workEndHour = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: ListView.builder(
        controller: controller,
        itemCount: timeSlots.length,
        itemBuilder: (context, index) => _buildTimeLabel(timeSlots[index]),
      ),
    );
  }

  Widget _buildTimeLabel(DateTime timeSlot) {
    final isHourStart = timeSlot.minute == 0;
    final isWorkingHours =
        timeSlot.hour >= workStartHour && timeSlot.hour < workEndHour;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: kBrandPurple.withValues(alpha: 0.2), width: 1.0),
          right: BorderSide(
              color: kBrandPurple.withValues(alpha: 0.2), width: 1.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('HH:mm').format(timeSlot),
            style: TextStyle(
              fontSize: isHourStart ? 13 : 11,
              fontWeight: isHourStart ? FontWeight.bold : FontWeight.w500,
              color: isWorkingHours ? kBrandPurple : Colors.grey.shade500,
            ),
          ),
          if (!isWorkingHours && isHourStart)
            Text('Fuera',
                style: TextStyle(fontSize: 8, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}
