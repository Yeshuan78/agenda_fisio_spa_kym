// [birthday_date_picker.dart] - WIDGET ESPECIALIZADO PARA FECHA DE NACIMIENTO
// 📁 Ubicación: /lib/widgets/clients/birthday_date_picker.dart
// 🎯 OBJETIVO: DatePicker personalizado para cumpleaños con validaciones y cálculos automáticos

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class BirthdayDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime?) onDateChanged;
  final String? label;
  final String? hint;

  const BirthdayDatePicker({
    super.key,
    this.initialDate,
    required this.onDateChanged,
    this.label = 'Fecha de Nacimiento',
    this.hint = 'Opcional - Para campañas de cumpleaños',
  });

  @override
  State<BirthdayDatePicker> createState() => _BirthdayDatePickerState();
}

class _BirthdayDatePickerState extends State<BirthdayDatePicker> {
  DateTime? _selectedDate;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _updateController();
  }

  void _updateController() {
    if (_selectedDate != null) {
      _controller.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    } else {
      _controller.clear();
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? DateTime(now.year - 30, now.month, now.day);
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now.subtract(const Duration(days: 1)), // No futuro
      locale: const Locale('es', 'MX'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: kBrandPurple,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _updateController();
      });
      widget.onDateChanged(pickedDate);
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
      _controller.clear();
    });
    widget.onDateChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Input Field
        TextFormField(
          controller: _controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.cake, color: kBrandPurple),
            suffixIcon: _selectedDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear, color: kTextMuted),
                    onPressed: _clearDate,
                  )
                : const Icon(Icons.calendar_today, color: kTextMuted),
          ),
          onTap: _selectDate,
        ),

        // Info adicional
        if (_selectedDate != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBrandPurpleLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBrandPurple.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: kBrandPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Edad: ${_calculateAge(_selectedDate!)} años • Próximo cumpleaños en ${_daysUntilNextBirthday(_selectedDate!)} días',
                    style: const TextStyle(
                      fontSize: 12,
                      color: kBrandPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  int _daysUntilNextBirthday(DateTime birthDate) {
    final today = DateTime.now();
    final thisYearBirthday = DateTime(today.year, birthDate.month, birthDate.day);
    
    if (thisYearBirthday.isAfter(today)) {
      return thisYearBirthday.difference(today).inDays;
    } else {
      final nextYearBirthday = DateTime(today.year + 1, birthDate.month, birthDate.day);
      return nextYearBirthday.difference(today).inDays;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}