// [agenda_conflict_service.dart]
// 📁 Ubicación: /lib/services/agenda/agenda_conflict_service.dart
// 🔍 SERVICIO DE VALIDACIÓN DE CONFLICTOS PARA AGENDA PREMIUM

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';
import 'package:agenda_fisio_spa_kym/services/agenda/calendario_service.dart';
import 'package:agenda_fisio_spa_kym/services/agenda/booking_service.dart';

class AgendaConflictService {
  static const String _logTag = 'AgendaConflictService';

  final CalendarioService _calendarioService = CalendarioService();
  final BookingService _bookingService = BookingService();

  /// Valida si un movimiento de cita es permitido
  Future<ValidationResult> validateAppointmentMove({
    required AppointmentModel appointment,
    required DateTime newDateTime,
    required String newResourceId,
  }) async {
    try {
      debugPrint('$_logTag: Validating appointment move for ${appointment.id}');

      final conflicts = <ConflictInfo>[];

      // 1. Verificar disponibilidad del profesional
      await _validateProfessionalAvailability(
          newResourceId, newDateTime, conflicts);

      // 2. Verificar conflictos con otras citas
      await _validateAppointmentConflicts(
        appointment,
        newResourceId,
        newDateTime,
        conflicts,
      );

      // 3. Verificar bloqueos de horario
      await _validateTimeBlocks(
        newResourceId,
        newDateTime,
        appointment.duracion ?? 60,
        conflicts,
      );

      // 4. Validar horarios laborales
      await _validateWorkingHours(
        newResourceId,
        newDateTime,
        conflicts,
      );

      final result = ValidationResult(
        hasConflicts: conflicts.isNotEmpty,
        conflicts: conflicts,
      );

      debugPrint(
          '$_logTag: Validation completed. Conflicts: ${conflicts.length}');
      return result;
    } catch (e, stackTrace) {
      debugPrint('$_logTag: Error validating appointment move: $e');
      debugPrint('$_logTag: StackTrace: $stackTrace');

      return ValidationResult(
        hasConflicts: true,
        conflicts: [
          ConflictInfo(
            type: ConflictType.systemError,
            message: 'Error validando conflictos: ${e.toString()}',
            severity: ConflictSeverity.high,
          ),
        ],
      );
    }
  }

  /// Valida disponibilidad del profesional en el horario solicitado
  Future<void> _validateProfessionalAvailability(
    String profesionalId,
    DateTime dateTime,
    List<ConflictInfo> conflicts,
  ) async {
    try {
      final calendar = await _calendarioService.getCalendario(profesionalId);

      if (calendar == null) {
        conflicts.add(ConflictInfo(
          type: ConflictType.unavailableTime,
          message: 'No se encontró calendario para el profesional',
          severity: ConflictSeverity.high,
        ));
        return;
      }

      if (!_isTimeAvailable(calendar, dateTime)) {
        conflicts.add(ConflictInfo(
          type: ConflictType.unavailableTime,
          message: 'Profesional no disponible en este horario',
          severity: ConflictSeverity.high,
        ));
      }
    } catch (e) {
      debugPrint('$_logTag: Error validating professional availability: $e');
      conflicts.add(ConflictInfo(
        type: ConflictType.systemError,
        message: 'Error verificando disponibilidad del profesional',
        severity: ConflictSeverity.medium,
      ));
    }
  }

  /// Valida conflictos con citas existentes
  Future<void> _validateAppointmentConflicts(
    AppointmentModel appointment,
    String newResourceId,
    DateTime newDateTime,
    List<ConflictInfo> conflicts,
  ) async {
    try {
      final existingAppointments = await _bookingService
          .getCitasPorProfesionalYFecha(newResourceId, newDateTime);

      final appointmentDuration = appointment.duracion ?? 60;

      for (final existing in existingAppointments) {
        // No comparar con la misma cita
        if (existing.id == appointment.id) continue;

        if (_hasTimeConflict(existing, newDateTime, appointmentDuration)) {
          conflicts.add(ConflictInfo(
            type: ConflictType.appointmentConflict,
            message:
                'Conflicto con cita de ${existing.nombreCliente ?? 'Cliente'}',
            severity: ConflictSeverity.high,
            relatedAppointmentId: existing.id,
          ));
        }
      }
    } catch (e) {
      debugPrint('$_logTag: Error validating appointment conflicts: $e');
      conflicts.add(ConflictInfo(
        type: ConflictType.systemError,
        message: 'Error verificando conflictos de citas',
        severity: ConflictSeverity.medium,
      ));
    }
  }

  /// Valida bloqueos de tiempo
  Future<void> _validateTimeBlocks(
    String profesionalId,
    DateTime dateTime,
    int durationMinutes,
    List<ConflictInfo> conflicts,
  ) async {
    try {
      final blocks = await _getBloqueosPorFecha(profesionalId, dateTime);

      for (final block in blocks) {
        if (_isTimeBlocked(block, dateTime, durationMinutes)) {
          conflicts.add(ConflictInfo(
            type: ConflictType.blockedTime,
            message: 'Horario bloqueado: ${block['motivo'] ?? 'Sin motivo'}',
            severity: ConflictSeverity.high,
          ));
        }
      }
    } catch (e) {
      debugPrint('$_logTag: Error validating time blocks: $e');
      conflicts.add(ConflictInfo(
        type: ConflictType.systemError,
        message: 'Error verificando bloqueos de horario',
        severity: ConflictSeverity.low,
      ));
    }
  }

  /// Valida horarios laborales
  Future<void> _validateWorkingHours(
    String profesionalId,
    DateTime dateTime,
    List<ConflictInfo> conflicts,
  ) async {
    try {
      final calendar = await _calendarioService.getCalendario(profesionalId);
      if (calendar == null) return;

      final dayName = _getDayName(dateTime);
      final dayConfig = _getDayConfig(calendar, dayName);

      if (dayConfig == null) {
        conflicts.add(ConflictInfo(
          type: ConflictType.unavailableTime,
          message: 'Profesional no trabaja los ${_getDayDisplayName(dayName)}',
          severity: ConflictSeverity.medium,
        ));
        return;
      }

      final workStartTime = _parseTimeToDateTime(dateTime, dayConfig['inicio']);
      final workEndTime = _parseTimeToDateTime(dateTime, dayConfig['fin']);

      if (dateTime.isBefore(workStartTime) || dateTime.isAfter(workEndTime)) {
        conflicts.add(ConflictInfo(
          type: ConflictType.outsideWorkingHours,
          message:
              'Fuera del horario laboral (${dayConfig['inicio']} - ${dayConfig['fin']})',
          severity: ConflictSeverity.medium,
        ));
      }
    } catch (e) {
      debugPrint('$_logTag: Error validating working hours: $e');
      conflicts.add(ConflictInfo(
        type: ConflictType.systemError,
        message: 'Error verificando horarios laborales',
        severity: ConflictSeverity.low,
      ));
    }
  }

  /// Verifica si existe conflicto de tiempo entre citas
  bool _hasTimeConflict(
      AppointmentModel existing, DateTime newTime, int duration) {
    if (existing.fechaInicio == null) return false;

    final newEnd = newTime.add(Duration(minutes: duration));
    final existingEnd =
        existing.fechaInicio!.add(Duration(minutes: existing.duracion ?? 60));

    // Conflicto si se solapan los horarios
    return (newTime.isBefore(existingEnd) &&
        newEnd.isAfter(existing.fechaInicio!));
  }

  /// Verifica disponibilidad en calendario
  bool _isTimeAvailable(Map<String, dynamic> calendar, DateTime dateTime) {
    try {
      final dayName = _getDayName(dateTime);
      final dayConfig = _getDayConfig(calendar, dayName);

      if (dayConfig == null) return false;

      final workStart = _parseTimeToDateTime(dateTime, dayConfig['inicio']);
      final workEnd = _parseTimeToDateTime(dateTime, dayConfig['fin']);

      return dateTime.isAfter(workStart) && dateTime.isBefore(workEnd);
    } catch (e) {
      debugPrint('$_logTag: Error checking time availability: $e');
      return false;
    }
  }

  /// Verifica si el tiempo está bloqueado
  bool _isTimeBlocked(
      Map<String, dynamic> block, DateTime dateTime, int duration) {
    try {
      final blockStart = _parseTimeToDateTime(dateTime, block['inicio']);
      final blockEnd = _parseTimeToDateTime(dateTime, block['fin']);
      final appointmentEnd = dateTime.add(Duration(minutes: duration));

      return (dateTime.isBefore(blockEnd) &&
          appointmentEnd.isAfter(blockStart));
    } catch (e) {
      debugPrint('$_logTag: Error checking time block: $e');
      return false;
    }
  }

  /// Obtiene bloqueos para una fecha específica
  Future<List<Map<String, dynamic>>> _getBloqueosPorFecha(
      String profesionalId, DateTime fecha) async {
    try {
      final calendar = await _calendarioService.getCalendario(profesionalId);
      if (calendar == null) return [];

      final dayName = _getDayName(fecha);
      final dayConfig = _getDayConfig(calendar, dayName);

      if (dayConfig == null || !dayConfig.containsKey('bloqueos')) {
        return [];
      }

      return List<Map<String, dynamic>>.from(dayConfig['bloqueos'] ?? []);
    } catch (e) {
      debugPrint('$_logTag: Error getting blocks for date: $e');
      return [];
    }
  }

  /// Obtiene el nombre del día en formato usado por Firestore
  String _getDayName(DateTime fecha) {
    const days = [
      'lunes',
      'martes',
      'miercoles',
      'jueves',
      'viernes',
      'sabado',
      'domingo'
    ];
    return days[fecha.weekday - 1];
  }

  /// Obtiene configuración del día desde el calendario
  Map<String, dynamic>? _getDayConfig(
      Map<String, dynamic> calendar, String dayName) {
    try {
      final availableDays = calendar['availableDays'] as List<dynamic>?;
      if (availableDays == null) return null;

      return availableDays.firstWhere(
        (day) => day['dia'] == dayName,
        orElse: () => null,
      );
    } catch (e) {
      debugPrint('$_logTag: Error getting day config: $e');
      return null;
    }
  }

  /// Convierte string de tiempo a DateTime completo
  DateTime _parseTimeToDateTime(DateTime baseDate, String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;

    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hour,
      minute,
    );
  }

  /// Obtiene nombre amigable del día
  String _getDayDisplayName(String dayName) {
    const displayNames = {
      'lunes': 'lunes',
      'martes': 'martes',
      'miercoles': 'miércoles',
      'jueves': 'jueves',
      'viernes': 'viernes',
      'sabado': 'sábados',
      'domingo': 'domingos',
    };
    return displayNames[dayName] ?? dayName;
  }

  /// Valida múltiples citas de una vez (para operaciones batch)
  Future<List<ValidationResult>> validateMultipleAppointments(
      List<AppointmentMoveRequest> requests) async {
    final results = <ValidationResult>[];

    for (final request in requests) {
      final result = await validateAppointmentMove(
        appointment: request.appointment,
        newDateTime: request.newDateTime,
        newResourceId: request.newResourceId,
      );
      results.add(result);
    }

    return results;
  }

  /// Obtiene horarios sugeridos cuando hay conflictos
  Future<List<DateTime>> getSuggestedTimes({
    required String profesionalId,
    required DateTime preferredDate,
    required int durationMinutes,
    int maxSuggestions = 5,
  }) async {
    try {
      final suggestions = <DateTime>[];
      final calendar = await _calendarioService.getCalendario(profesionalId);

      if (calendar == null) return suggestions;

      // Buscar en el día preferido
      final daySlots = await _calendarioService.getHorariosDisponibles(
        profesionalId: profesionalId,
        fecha: preferredDate,
        duracionMinutos: durationMinutes,
      );

      suggestions.addAll(daySlots.take(maxSuggestions));

      // Si no hay suficientes, buscar en días siguientes
      if (suggestions.length < maxSuggestions) {
        for (int i = 1; i <= 7 && suggestions.length < maxSuggestions; i++) {
          final nextDay = preferredDate.add(Duration(days: i));
          final nextDaySlots = await _calendarioService.getHorariosDisponibles(
            profesionalId: profesionalId,
            fecha: nextDay,
            duracionMinutos: durationMinutes,
          );

          final remaining = maxSuggestions - suggestions.length;
          suggestions.addAll(nextDaySlots.take(remaining));
        }
      }

      return suggestions;
    } catch (e) {
      debugPrint('$_logTag: Error getting suggested times: $e');
      return [];
    }
  }
}

/// Resultado de validación de conflictos
class ValidationResult {
  final bool hasConflicts;
  final List<ConflictInfo> conflicts;

  ValidationResult({
    required this.hasConflicts,
    required this.conflicts,
  });

  /// Obtiene conflictos por severidad
  List<ConflictInfo> getConflictsBySeverity(ConflictSeverity severity) {
    return conflicts.where((c) => c.severity == severity).toList();
  }

  /// Verifica si hay conflictos críticos que impiden el movimiento
  bool get hasCriticalConflicts {
    return conflicts.any((c) => c.severity == ConflictSeverity.high);
  }

  /// Obtiene resumen de conflictos
  String get conflictSummary {
    if (!hasConflicts) return 'Sin conflictos';

    final highCount = getConflictsBySeverity(ConflictSeverity.high).length;
    final mediumCount = getConflictsBySeverity(ConflictSeverity.medium).length;
    final lowCount = getConflictsBySeverity(ConflictSeverity.low).length;

    final parts = <String>[];
    if (highCount > 0) parts.add('$highCount críticos');
    if (mediumCount > 0) parts.add('$mediumCount importantes');
    if (lowCount > 0) parts.add('$lowCount menores');

    return parts.join(', ');
  }
}

/// Información de conflicto específico
class ConflictInfo {
  final ConflictType type;
  final String message;
  final ConflictSeverity severity;
  final String? relatedAppointmentId;
  final Map<String, dynamic>? metadata;

  ConflictInfo({
    required this.type,
    required this.message,
    this.severity = ConflictSeverity.medium,
    this.relatedAppointmentId,
    this.metadata,
  });

  @override
  String toString() =>
      'ConflictInfo(type: $type, message: $message, severity: $severity)';
}

/// Tipos de conflictos posibles
enum ConflictType {
  unavailableTime, // Profesional no disponible
  appointmentConflict, // Conflicto con otra cita
  blockedTime, // Horario bloqueado
  outsideWorkingHours, // Fuera de horario laboral
  professionalUnavailable, // Profesional no disponible ese día
  systemError, // Error del sistema
}

/// Severidad de conflictos
enum ConflictSeverity {
  low, // Advertencia menor
  medium, // Advertencia importante
  high, // Conflicto crítico que impide la acción
}

/// Request para movimiento de cita
class AppointmentMoveRequest {
  final AppointmentModel appointment;
  final DateTime newDateTime;
  final String newResourceId;

  AppointmentMoveRequest({
    required this.appointment,
    required this.newDateTime,
    required this.newResourceId,
  });
}

/// Excepción personalizada para conflictos de agenda
class AgendaConflictException implements Exception {
  final String message;
  final ConflictType type;
  final List<ConflictInfo> conflicts;

  AgendaConflictException({
    required this.message,
    required this.type,
    this.conflicts = const [],
  });

  @override
  String toString() => 'AgendaConflictException: $message';
}
