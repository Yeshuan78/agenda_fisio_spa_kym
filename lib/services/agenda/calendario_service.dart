// [calendario_service.dart]
// 📁 Ubicación: /lib/services/agenda/calendario_service.dart
// 📅 SERVICIO DE GESTIÓN DE CALENDARIOS Y HORARIOS

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/services/agenda/booking_service.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';

class CalendarioService {
  static const String _collection = 'calendarios';
  static const String _logTag = 'CalendarioService';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BookingService _bookingService = BookingService();

  /// Obtiene el calendario de un profesional
  Future<Map<String, dynamic>?> getCalendario(String profesionalId) async {
    try {
      debugPrint('$_logTag: Getting calendar for professional $profesionalId');

      final doc =
          await _firestore.collection(_collection).doc(profesionalId).get();

      if (doc.exists && doc.data() != null) {
        debugPrint('$_logTag: Calendar found for professional $profesionalId');
        return doc.data();
      } else {
        debugPrint(
            '$_logTag: No calendar found for professional $profesionalId');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('$_logTag: Error loading calendar for $profesionalId: $e');
      debugPrint('$_logTag: StackTrace: $stackTrace');
      return null;
    }
  }

  /// Obtiene calendarios múltiples en una sola consulta
  Future<Map<String, Map<String, dynamic>>> getCalendariosMultiples(
      List<String> profesionalIds) async {
    try {
      final calendarios = <String, Map<String, dynamic>>{};

      // Firestore tiene límite de 10 elementos en whereIn
      final chunks = _chunkList(profesionalIds, 10);

      for (final chunk in chunks) {
        final query = await _firestore
            .collection(_collection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (final doc in query.docs) {
          if (doc.data().isNotEmpty) {
            calendarios[doc.id] = doc.data();
          }
        }
      }

      debugPrint('$_logTag: Loaded ${calendarios.length} calendars');
      return calendarios;
    } catch (e) {
      debugPrint('$_logTag: Error loading multiple calendars: $e');
      return {};
    }
  }

  /// Obtiene horarios disponibles para un profesional en una fecha específica
  Future<List<DateTime>> getHorariosDisponibles({
    required String profesionalId,
    required DateTime fecha,
    required int duracionMinutos,
    int intervalMinutos = 30,
  }) async {
    try {
      debugPrint(
          '$_logTag: Getting available slots for $profesionalId on ${fecha.toString()}');

      final calendar = await getCalendario(profesionalId);
      if (calendar == null) {
        debugPrint('$_logTag: No calendar found, returning empty slots');
        return [];
      }

      final dayName = _getDayName(fecha);
      final dayConfig = _getDayConfig(calendar, dayName);

      if (dayConfig == null) {
        debugPrint('$_logTag: Professional does not work on $dayName');
        return [];
      }

      final slots = <DateTime>[];
      final workStart = _parseTime(dayConfig['inicio'] ?? '09:00');
      final workEnd = _parseTime(dayConfig['fin'] ?? '18:00');

      DateTime current = DateTime(
          fecha.year, fecha.month, fecha.day, workStart.hour, workStart.minute);

      final endTime = DateTime(
          fecha.year, fecha.month, fecha.day, workEnd.hour, workEnd.minute);

      // Generar slots cada X minutos
      while (
          current.add(Duration(minutes: duracionMinutos)).isBefore(endTime) ||
              current
                  .add(Duration(minutes: duracionMinutos))
                  .isAtSameMomentAs(endTime)) {
        // Verificar si el slot está disponible
        if (await _isSlotAvailable(profesionalId, current, duracionMinutos)) {
          // Verificar que no esté bloqueado
          if (!_isSlotBlocked(dayConfig, current, duracionMinutos)) {
            slots.add(current);
          }
        }

        current = current.add(Duration(minutes: intervalMinutos));
      }

      debugPrint('$_logTag: Found ${slots.length} available slots');
      return slots;
    } catch (e, stackTrace) {
      debugPrint('$_logTag: Error getting available slots: $e');
      debugPrint('$_logTag: StackTrace: $stackTrace');
      return [];
    }
  }

  /// Verifica si un slot específico está disponible
  Future<bool> _isSlotAvailable(
      String profesionalId, DateTime slot, int duration) async {
    try {
      // Obtener citas existentes en ese horario
      final existingAppointments = await _bookingService
          .getCitasPorProfesionalYFecha(profesionalId, slot);

      final slotEnd = slot.add(Duration(minutes: duration));

      // Verificar solapamiento con citas existentes
      for (final appointment in existingAppointments) {
        if (appointment.fechaInicio == null) continue;

        final appointmentEnd = appointment.fechaInicio!
            .add(Duration(minutes: appointment.duracion ?? 60));

        // Hay solapamiento si:
        // - El slot empieza antes de que termine la cita existente Y
        // - El slot termina después de que empiece la cita existente
        if (slot.isBefore(appointmentEnd) &&
            slotEnd.isAfter(appointment.fechaInicio!)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('$_logTag: Error checking slot availability: $e');
      return false;
    }
  }

  /// Verifica si un slot está bloqueado según la configuración del calendario
  bool _isSlotBlocked(
      Map<String, dynamic> dayConfig, DateTime slot, int duration) {
    try {
      final bloqueos = dayConfig['bloqueos'] as List<dynamic>?;
      if (bloqueos == null || bloqueos.isEmpty) return false;

      final slotEnd = slot.add(Duration(minutes: duration));

      for (final bloqueo in bloqueos) {
        final blockStart = _parseTimeToDateTime(slot, bloqueo['inicio']);
        final blockEnd = _parseTimeToDateTime(slot, bloqueo['fin']);

        // Verificar solapamiento con bloqueo
        if (slot.isBefore(blockEnd) && slotEnd.isAfter(blockStart)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('$_logTag: Error checking if slot is blocked: $e');
      return false;
    }
  }

  /// Crea o actualiza un calendario para un profesional
  Future<void> crearOActualizarCalendario({
    required String profesionalId,
    required String calendarName,
    required List<DiaDisponible> diasDisponibles,
  }) async {
    try {
      debugPrint('$_logTag: Creating/updating calendar for $profesionalId');

      final calendarData = {
        'calendarId': profesionalId,
        'calendarName': calendarName,
        'profesionalId': profesionalId,
        'availableDays': diasDisponibles.map((dia) => dia.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_collection)
          .doc(profesionalId)
          .set(calendarData, SetOptions(merge: true));

      debugPrint('$_logTag: Calendar updated successfully for $profesionalId');
    } catch (e, stackTrace) {
      debugPrint('$_logTag: Error creating/updating calendar: $e');
      debugPrint('$_logTag: StackTrace: $stackTrace');
      throw CalendarioException('Error al guardar calendario: $e');
    }
  }

  /// Agrega un bloqueo de tiempo a un día específico
  Future<void> agregarBloqueo({
    required String profesionalId,
    required String diaSemana,
    required TimeOfDay horaInicio,
    required TimeOfDay horaFin,
    required String motivo,
  }) async {
    try {
      debugPrint(
          '$_logTag: Adding time block for $profesionalId on $diaSemana');

      final calendar = await getCalendario(profesionalId);
      if (calendar == null) {
        throw CalendarioException(
            'Calendario no encontrado para el profesional');
      }

      final availableDays =
          List<Map<String, dynamic>>.from(calendar['availableDays'] ?? []);

      // Buscar el día correspondiente
      final dayIndex =
          availableDays.indexWhere((day) => day['dia'] == diaSemana);

      if (dayIndex == -1) {
        throw CalendarioException(
            'Día $diaSemana no encontrado en el calendario');
      }

      // Agregar bloqueo
      final bloqueos = List<Map<String, dynamic>>.from(
          availableDays[dayIndex]['bloqueos'] ?? []);

      bloqueos.add({
        'inicio':
            '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}',
        'fin':
            '${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}',
        'motivo': motivo,
        'creadoEn': DateTime.now().toIso8601String(),
      });

      availableDays[dayIndex]['bloqueos'] = bloqueos;

      // Actualizar en Firestore
      await _firestore.collection(_collection).doc(profesionalId).update({
        'availableDays': availableDays,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('$_logTag: Time block added successfully');
    } catch (e, stackTrace) {
      debugPrint('$_logTag: Error adding time block: $e');
      debugPrint('$_logTag: StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Elimina un bloqueo de tiempo
  Future<void> eliminarBloqueo({
    required String profesionalId,
    required String diaSemana,
    required int bloqueoIndex,
  }) async {
    try {
      debugPrint(
          '$_logTag: Removing time block $bloqueoIndex for $profesionalId on $diaSemana');

      final calendar = await getCalendario(profesionalId);
      if (calendar == null) {
        throw CalendarioException(
            'Calendario no encontrado para el profesional');
      }

      final availableDays =
          List<Map<String, dynamic>>.from(calendar['availableDays'] ?? []);

      final dayIndex =
          availableDays.indexWhere((day) => day['dia'] == diaSemana);

      if (dayIndex == -1) {
        throw CalendarioException(
            'Día $diaSemana no encontrado en el calendario');
      }

      final bloqueos = List<Map<String, dynamic>>.from(
          availableDays[dayIndex]['bloqueos'] ?? []);

      if (bloqueoIndex < 0 || bloqueoIndex >= bloqueos.length) {
        throw CalendarioException('Índice de bloqueo inválido');
      }

      bloqueos.removeAt(bloqueoIndex);
      availableDays[dayIndex]['bloqueos'] = bloqueos;

      await _firestore.collection(_collection).doc(profesionalId).update({
        'availableDays': availableDays,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('$_logTag: Time block removed successfully');
    } catch (e, stackTrace) {
      debugPrint('$_logTag: Error removing time block: $e');
      debugPrint('$_logTag: StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Obtiene los bloqueos para un día específico
  Future<List<BloqueoTiempo>> getBloqueosPorDia({
    required String profesionalId,
    required String diaSemana,
  }) async {
    try {
      final calendar = await getCalendario(profesionalId);
      if (calendar == null) return [];

      final dayConfig = _getDayConfig(calendar, diaSemana);
      if (dayConfig == null) return [];

      final bloqueos = dayConfig['bloqueos'] as List<dynamic>?;
      if (bloqueos == null) return [];

      return bloqueos.map((bloqueo) => BloqueoTiempo.fromMap(bloqueo)).toList();
    } catch (e) {
      debugPrint('$_logTag: Error getting blocks for day: $e');
      return [];
    }
  }

  /// Valida la configuración de un día antes de guardarla
  bool validarConfiguracionDia(DiaDisponible dia) {
    try {
      // Verificar que la hora de inicio sea antes que la de fin
      final inicio = _parseTime(dia.horaInicio);
      final fin = _parseTime(dia.horaFin);

      if (inicio.hour > fin.hour ||
          (inicio.hour == fin.hour && inicio.minute >= fin.minute)) {
        return false;
      }

      // Verificar bloqueos
      for (final bloqueo in dia.bloqueos) {
        final bloqueoInicio = _parseTime(bloqueo.horaInicio);
        final bloqueoFin = _parseTime(bloqueo.horaFin);

        // El bloqueo debe estar dentro del horario laboral
        if (bloqueoInicio.hour < inicio.hour || bloqueoFin.hour > fin.hour) {
          return false;
        }

        // La hora de inicio del bloqueo debe ser antes que la de fin
        if (bloqueoInicio.hour > bloqueoFin.hour ||
            (bloqueoInicio.hour == bloqueoFin.hour &&
                bloqueoInicio.minute >= bloqueoFin.minute)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('$_logTag: Error validating day configuration: $e');
      return false;
    }
  }

  /// Obtiene estadísticas de disponibilidad para un profesional
  Future<EstadisticasDisponibilidad> getEstadisticasDisponibilidad({
    required String profesionalId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final calendar = await getCalendario(profesionalId);
      if (calendar == null) {
        return EstadisticasDisponibilidad.empty();
      }

      int diasLaborales = 0;
      int horasDisponibles = 0;
      int horasBloqueadas = 0;
      int slotsOcupados = 0;
      int slotsDisponibles = 0;

      // Iterar por cada día en el rango
      DateTime currentDate = fechaInicio;
      while (currentDate.isBefore(fechaFin) ||
          currentDate.isAtSameMomentAs(fechaFin)) {
        final dayName = _getDayName(currentDate);
        final dayConfig = _getDayConfig(calendar, dayName);

        if (dayConfig != null) {
          diasLaborales++;

          // Calcular horas disponibles
          final inicio = _parseTime(dayConfig['inicio']);
          final fin = _parseTime(dayConfig['fin']);
          final horasDelDia = fin.hour - inicio.hour;
          horasDisponibles += horasDelDia;

          // Calcular horas bloqueadas
          final bloqueos = dayConfig['bloqueos'] as List<dynamic>?;
          if (bloqueos != null) {
            for (final bloqueo in bloqueos) {
              final bloqueoInicio = _parseTime(bloqueo['inicio']);
              final bloqueoFin = _parseTime(bloqueo['fin']);
              final horasBloqueadasDelBloqueo =
                  bloqueoFin.hour - bloqueoInicio.hour;
              horasBloqueadas += horasBloqueadasDelBloqueo;
            }
          }

          // Obtener citas del día para calcular ocupación
          final citasDelDia = await _bookingService
              .getCitasPorProfesionalYFecha(profesionalId, currentDate);
          slotsOcupados += citasDelDia.length;

          // Calcular slots disponibles (aproximado)
          final slotsDelDia = horasDelDia * 2; // Asumiendo slots de 30 min
          slotsDisponibles +=
              (slotsDelDia - citasDelDia.length).clamp(0, slotsDelDia);
        }

        currentDate = currentDate.add(const Duration(days: 1));
      }

      return EstadisticasDisponibilidad(
        diasLaborales: diasLaborales,
        horasDisponibles: horasDisponibles,
        horasBloqueadas: horasBloqueadas,
        slotsOcupados: slotsOcupados,
        slotsDisponibles: slotsDisponibles,
        porcentajeOcupacion: slotsDisponibles > 0
            ? (slotsOcupados / (slotsOcupados + slotsDisponibles)) * 100
            : 0.0,
      );
    } catch (e) {
      debugPrint('$_logTag: Error calculating availability stats: $e');
      return EstadisticasDisponibilidad.empty();
    }
  }

  /// Copia configuración de calendario de un profesional a otro
  Future<void> copiarCalendario({
    required String profesionalOrigenId,
    required String profesionalDestinoId,
    String? nuevoNombre,
  }) async {
    try {
      final calendarOrigen = await getCalendario(profesionalOrigenId);
      if (calendarOrigen == null) {
        throw CalendarioException('Calendario origen no encontrado');
      }

      final calendarDestino = Map<String, dynamic>.from(calendarOrigen);
      calendarDestino['calendarId'] = profesionalDestinoId;
      calendarDestino['profesionalId'] = profesionalDestinoId;
      calendarDestino['calendarName'] =
          nuevoNombre ?? '${calendarOrigen['calendarName']} - Copia';
      calendarDestino['createdAt'] = FieldValue.serverTimestamp();
      calendarDestino['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_collection)
          .doc(profesionalDestinoId)
          .set(calendarDestino);

      debugPrint('$_logTag: Calendar copied successfully');
    } catch (e, stackTrace) {
      debugPrint('$_logTag: Error copying calendar: $e');
      debugPrint('$_logTag: StackTrace: $stackTrace');
      rethrow;
    }
  }

  // MÉTODOS HELPER PRIVADOS

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

      for (final day in availableDays) {
        if (day['dia'] == dayName) {
          return Map<String, dynamic>.from(day);
        }
      }
      return null;
    } catch (e) {
      debugPrint('$_logTag: Error getting day config: $e');
      return null;
    }
  }

  /// Convierte string de tiempo a TimeOfDay
  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Convierte string de tiempo a DateTime completo
  DateTime _parseTimeToDateTime(DateTime baseDate, String timeStr) {
    final time = _parseTime(timeStr);
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      time.hour,
      time.minute,
    );
  }

  /// Divide una lista en chunks más pequeños
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, (i + chunkSize).clamp(0, list.length)));
    }
    return chunks;
  }
}

// MODELOS DE DATOS

/// Representa un día disponible en el calendario
class DiaDisponible {
  final String dia;
  final String horaInicio;
  final String horaFin;
  final List<BloqueoTiempo> bloqueos;
  final bool activo;

  DiaDisponible({
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    this.bloqueos = const [],
    this.activo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'dia': dia,
      'inicio': horaInicio,
      'fin': horaFin,
      'bloqueos': bloqueos.map((b) => b.toMap()).toList(),
      'activo': activo,
    };
  }

  factory DiaDisponible.fromMap(Map<String, dynamic> map) {
    return DiaDisponible(
      dia: map['dia'] ?? '',
      horaInicio: map['inicio'] ?? '09:00',
      horaFin: map['fin'] ?? '18:00',
      bloqueos: (map['bloqueos'] as List<dynamic>?)
              ?.map((b) => BloqueoTiempo.fromMap(b))
              .toList() ??
          [],
      activo: map['activo'] ?? true,
    );
  }

  DiaDisponible copyWith({
    String? dia,
    String? horaInicio,
    String? horaFin,
    List<BloqueoTiempo>? bloqueos,
    bool? activo,
  }) {
    return DiaDisponible(
      dia: dia ?? this.dia,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      bloqueos: bloqueos ?? this.bloqueos,
      activo: activo ?? this.activo,
    );
  }
}

/// Representa un bloqueo de tiempo específico
class BloqueoTiempo {
  final String horaInicio;
  final String horaFin;
  final String motivo;
  final DateTime? creadoEn;

  BloqueoTiempo({
    required this.horaInicio,
    required this.horaFin,
    required this.motivo,
    this.creadoEn,
  });

  Map<String, dynamic> toMap() {
    return {
      'inicio': horaInicio,
      'fin': horaFin,
      'motivo': motivo,
      'creadoEn': creadoEn?.toIso8601String(),
    };
  }

  factory BloqueoTiempo.fromMap(Map<String, dynamic> map) {
    return BloqueoTiempo(
      horaInicio: map['inicio'] ?? '12:00',
      horaFin: map['fin'] ?? '13:00',
      motivo: map['motivo'] ?? '',
      creadoEn:
          map['creadoEn'] != null ? DateTime.tryParse(map['creadoEn']) : null,
    );
  }
}

/// Estadísticas de disponibilidad
class EstadisticasDisponibilidad {
  final int diasLaborales;
  final int horasDisponibles;
  final int horasBloqueadas;
  final int slotsOcupados;
  final int slotsDisponibles;
  final double porcentajeOcupacion;

  EstadisticasDisponibilidad({
    required this.diasLaborales,
    required this.horasDisponibles,
    required this.horasBloqueadas,
    required this.slotsOcupados,
    required this.slotsDisponibles,
    required this.porcentajeOcupacion,
  });

  factory EstadisticasDisponibilidad.empty() {
    return EstadisticasDisponibilidad(
      diasLaborales: 0,
      horasDisponibles: 0,
      horasBloqueadas: 0,
      slotsOcupados: 0,
      slotsDisponibles: 0,
      porcentajeOcupacion: 0.0,
    );
  }

  @override
  String toString() {
    return 'EstadisticasDisponibilidad('
        'diasLaborales: $diasLaborales, '
        'horasDisponibles: $horasDisponibles, '
        'ocupacion: ${porcentajeOcupacion.toStringAsFixed(1)}%)';
  }
}

/// Excepción personalizada para errores de calendario
class CalendarioException implements Exception {
  final String message;

  CalendarioException(this.message);

  @override
  String toString() => 'CalendarioException: $message';
}
