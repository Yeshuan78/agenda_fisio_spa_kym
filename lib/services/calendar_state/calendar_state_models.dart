// [calendar_state_models.dart] - Modelos para Estado Global del Calendario
// 📁 Ubicación: /lib/services/calendar_state/calendar_state_models.dart
// 📊 MODELOS ENTERPRISE: Tipos y estructuras de datos para el calendario

import 'package:flutter/foundation.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';

/// 📊 Modelos para el Estado Global del Calendario

/// Modos de vista del calendario
enum CalendarViewMode {
  day('Día'),
  week('Semana'),
  month('Mes'),
  agenda('Agenda');

  const CalendarViewMode(this.displayName);
  final String displayName;
}

/// Filtros del calendario
class CalendarFilters {
  final List<String> selectedProfessionals;
  final List<String> selectedServices;
  final List<String> selectedStatuses;
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;

  const CalendarFilters({
    this.selectedProfessionals = const [],
    this.selectedServices = const [],
    this.selectedStatuses = const [],
    this.startDate,
    this.endDate,
    this.searchQuery = '',
  });

  factory CalendarFilters.empty() => const CalendarFilters();

  bool get hasActiveFilters {
    return selectedProfessionals.isNotEmpty ||
           selectedServices.isNotEmpty ||
           selectedStatuses.isNotEmpty ||
           startDate != null ||
           endDate != null ||
           searchQuery.isNotEmpty;
  }

  CalendarFilters copyWith({
    List<String>? selectedProfessionals,
    List<String>? selectedServices,
    List<String>? selectedStatuses,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    bool clearDates = false,
  }) {
    return CalendarFilters(
      selectedProfessionals: selectedProfessionals ?? this.selectedProfessionals,
      selectedServices: selectedServices ?? this.selectedServices,
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarFilters &&
          runtimeType == other.runtimeType &&
          listEquals(selectedProfessionals, other.selectedProfessionals) &&
          listEquals(selectedServices, other.selectedServices) &&
          listEquals(selectedStatuses, other.selectedStatuses) &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode =>
      selectedProfessionals.hashCode ^
      selectedServices.hashCode ^
      selectedStatuses.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      searchQuery.hashCode;
}

/// Tipos de eventos del calendario
enum CalendarEventType {
  dateChanged,
  appointmentsChanged,
  viewModeChanged,
  filtersChanged,
  loadingChanged,
}

/// Evento base del calendario
abstract class CalendarEvent {
  final CalendarEventType type;
  final DateTime timestamp;
  final String source;

  CalendarEvent({
    required this.type,
    required this.source,
  }) : timestamp = DateTime.now();

  factory CalendarEvent.dateChanged({
    required DateTime oldDate,
    required DateTime newDate,
    required String source,
  }) = CalendarEventDateChanged;

  factory CalendarEvent.appointmentsChanged({
    required int oldCount,
    required int newCount,
    required String source,
  }) = CalendarEventAppointmentsChanged;

  factory CalendarEvent.viewModeChanged({
    required CalendarViewMode oldMode,
    required CalendarViewMode newMode,
    required String source,
  }) = CalendarEventViewModeChanged;
}

/// Evento de cambio de fecha
class CalendarEventDateChanged extends CalendarEvent {
  final DateTime oldDate;
  final DateTime newDate;

  CalendarEventDateChanged({
    required this.oldDate,
    required this.newDate,
    required String source,
  }) : super(type: CalendarEventType.dateChanged, source: source);
}

/// Evento de cambio de appointments
class CalendarEventAppointmentsChanged extends CalendarEvent {
  final int oldCount;
  final int newCount;

  CalendarEventAppointmentsChanged({
    required this.oldCount,
    required this.newCount,
    required String source,
  }) : super(type: CalendarEventType.appointmentsChanged, source: source);
}

/// Evento de cambio de modo de vista
class CalendarEventViewModeChanged extends CalendarEvent {
  final CalendarViewMode oldMode;
  final CalendarViewMode newMode;

  CalendarEventViewModeChanged({
    required this.oldMode,
    required this.newMode,
    required String source,
  }) : super(type: CalendarEventType.viewModeChanged, source: source);
}