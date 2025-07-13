// [date_picker_field.dart] - WIDGET SELECTOR DE FECHA EXTRAÍDO
// 📁 Ubicación: /lib/widgets/booking/components/date_picker_field.dart
// 🎯 EXTRAER: _buildDatePicker() de public_booking_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final Color accentColor;
  final Function(DateTime) onDateSelected;

  const DatePickerField({
    super.key,
    this.selectedDate,
    required this.accentColor,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorderSoft),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: kTextSecondary),
            const SizedBox(width: 12),
            Text(
              selectedDate != null
                  ? DateFormat('EEEE, d MMMM', 'es_MX').format(selectedDate!)
                  : 'Seleccionar fecha',
              style: TextStyle(
                fontSize: 16,
                color: selectedDate != null ? Colors.black87 : kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('es', 'MX'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: accentColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      onDateSelected(date);
    }
  }
}