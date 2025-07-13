// [calendar_state_extensions.dart] - Extensiones Helper para Calendario Enterprise
// 📁 Ubicación: /lib/services/calendar_state/calendar_state_extensions.dart
// 🔧 EXTENSIONES ENTERPRISE: Utilities y helpers para estado del calendario

import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';
import 'calendar_state_models.dart';

/// 🔧 Extensiones helper para el estado del calendario

extension CalendarStateExtensions on Map<DateTime, List<AppointmentModel>> {
  /// Convertir a formato para mini calendario
  Map<DateTime, List<dynamic>> toMiniCalendarFormat() {
    return map((key, value) => MapEntry(key, value.cast<dynamic>()));
  }

  /// Obtener appointments para un día específico
  List<AppointmentModel> forDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return this[normalizedDate] ?? [];
  }

  /// Verificar si un día tiene appointments
  bool hasAppointmentsOn(DateTime date) {
    return forDate(date).isNotEmpty;
  }

  /// Contar total de appointments
  int get totalAppointments {
    return values.fold(0, (sum, list) => sum + list.length);
  }

  /// Obtener días con appointments
  List<DateTime> get daysWithAppointments {
    return keys.where((date) => hasAppointmentsOn(date)).toList();
  }
}

extension DateTimeExtensions on DateTime {
  /// Normalizar fecha (solo año/mes/día)
  DateTime get normalized => DateTime(year, month, day);

  /// Verificar si es el mismo día
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Obtener inicio de la semana
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).normalized;
  }

  /// Obtener fin de la semana
  DateTime get endOfWeek {
    final daysToSunday = 7 - weekday;
    return add(Duration(days: daysToSunday)).normalized;
  }

  /// Verificar si es hoy
  bool get isToday => isSameDay(DateTime.now());

  /// Verificar si es mañana
  bool get isTomorrow => isSameDay(DateTime.now().add(const Duration(days: 1)));
}