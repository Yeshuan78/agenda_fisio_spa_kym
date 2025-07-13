// [booking_service.dart]
// 📁 Ubicación: /lib/services/agenda/booking_service.dart
// 📅 SERVICIO COMPLETO DE GESTIÓN DE CITAS - INTEGRACIÓN FIRESTORE TOTAL

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';

class BookingService {
  static const String collection = 'bookings';
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========================================================================
  // 🎯 MÉTODOS PRINCIPALES - LECTURA DE CITAS
  // ========================================================================

  /// ✅ OBTENER CITAS POR FECHA (sin filtro de profesional)
  Future<List<AppointmentModel>> getCitasPorFecha(DateTime fecha) async {
    try {
      final startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final query = await _db
          .collection(collection)
          .where('fecha',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('fecha', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('fecha')
          .get();

      return query.docs
          .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getCitasPorFecha: $e');
      throw BookingException('Error al cargar citas del día: $e');
    }
  }

  /// ✅ OBTENER CITAS POR PROFESIONAL Y FECHA
  Future<List<AppointmentModel>> getCitasPorProfesionalYFecha(
    String profesionalId,
    DateTime fecha,
  ) async {
    try {
      final startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final query = await _db
          .collection(collection)
          .where('profesionalId', isEqualTo: profesionalId)
          .where('fecha',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('fecha', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('fecha')
          .get();

      return query.docs
          .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getCitasPorProfesionalYFecha: $e');
      throw BookingException('Error al cargar citas del profesional: $e');
    }
  }

  /// ✅ OBTENER CITAS POR RANGO DE FECHAS
  Future<Map<DateTime, List<AppointmentModel>>> getCitasPorRango(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    try {
      final query = await _db
          .collection(collection)
          .where('fecha',
              isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio))
          .where('fecha', isLessThan: Timestamp.fromDate(fechaFin))
          .orderBy('fecha')
          .get();

      final Map<DateTime, List<AppointmentModel>> result = {};

      for (final doc in query.docs) {
        final appointment = AppointmentModel.fromMap(doc.data(), doc.id);
        if (appointment.fechaInicio != null) {
          final dateKey = DateTime(
            appointment.fechaInicio!.year,
            appointment.fechaInicio!.month,
            appointment.fechaInicio!.day,
          );
          result.putIfAbsent(dateKey, () => []).add(appointment);
        }
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error getCitasPorRango: $e');
      throw BookingException('Error al cargar citas del rango: $e');
    }
  }

  /// ✅ OBTENER CITA POR ID
  Future<AppointmentModel?> getCitaPorId(String appointmentId) async {
    try {
      final doc = await _db.collection(collection).doc(appointmentId).get();

      if (doc.exists && doc.data() != null) {
        return AppointmentModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getCitaPorId: $e');
      throw BookingException('Error al obtener la cita: $e');
    }
  }

  // ========================================================================
  // 🎯 MÉTODOS DE CREACIÓN Y MODIFICACIÓN
  // ========================================================================

  /// ✅ CREAR NUEVA CITA
  Future<String> crearCita({
    required String clienteNombre,
    required String profesionalId,
    required String servicioId,
    required DateTime fecha,
    String? clienteId,
    String? clientEmail,
    String? clientPhone,
    String estado = 'reservado',
    String? comentarios,
    int? duracion,
  }) async {
    try {
      final doc = _db.collection(collection).doc();

      // Obtener datos adicionales
      final futures = await Future.wait([
        _getProfessionalName(profesionalId),
        _getServiceData(servicioId),
      ]);

      final professionalName = futures[0] as String?;
      final serviceData = futures[1] as Map<String, dynamic>?;

      final appointmentData = {
        'bookingId': doc.id,
        'clienteId': clienteId,
        'clienteNombre': clienteNombre,
        'clientEmail': clientEmail,
        'clientPhone': clientPhone,
        'profesionalId': profesionalId,
        'profesionalNombre': professionalName ?? '',
        'servicioId': servicioId,
        'servicioNombre': serviceData?['name'] ?? '',
        'fecha': Timestamp.fromDate(fecha),
        'estado': estado,
        'comentarios': comentarios,
        'duracion': duracion ?? serviceData?['duration'] ?? 60,
        'creadoEn': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await doc.set(appointmentData);

      debugPrint('✅ Cita creada exitosamente: ${doc.id}');
      return doc.id;
    } catch (e) {
      debugPrint('❌ Error crearCita: $e');
      throw BookingException('Error al crear la cita: $e');
    }
  }

  /// ✅ MOVER CITA (DRAG & DROP)
  Future<void> moverCita({
    required String appointmentId,
    required DateTime nuevaFecha,
    required String nuevoProfesionalId,
  }) async {
    try {
      final doc = _db.collection(collection).doc(appointmentId);

      // Preparar datos para actualizar
      final updateData = {
        'fecha': Timestamp.fromDate(nuevaFecha),
        'profesionalId': nuevoProfesionalId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Actualizar nombre del profesional si cambió
      if (nuevoProfesionalId.isNotEmpty) {
        final professionalName = await _getProfessionalName(nuevoProfesionalId);
        if (professionalName != null) {
          updateData['profesionalNombre'] = professionalName;
        }
      }

      await doc.update(updateData);

      debugPrint('✅ Cita movida exitosamente: $appointmentId');
    } catch (e) {
      debugPrint('❌ Error moverCita: $e');
      throw BookingException('Error al mover la cita: $e');
    }
  }

  /// ✅ ACTUALIZAR CITA COMPLETA
  Future<void> actualizarCita({
    required String appointmentId,
    String? clienteNombre,
    String? clientEmail,
    String? clientPhone,
    String? profesionalId,
    String? servicioId,
    DateTime? fecha,
    String? estado,
    String? comentarios,
    int? duracion,
  }) async {
    try {
      final doc = _db.collection(collection).doc(appointmentId);
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (clienteNombre != null) updateData['clienteNombre'] = clienteNombre;
      if (clientEmail != null) updateData['clientEmail'] = clientEmail;
      if (clientPhone != null) updateData['clientPhone'] = clientPhone;

      if (profesionalId != null) {
        updateData['profesionalId'] = profesionalId;
        final professionalName = await _getProfessionalName(profesionalId);
        if (professionalName != null) {
          updateData['profesionalNombre'] = professionalName;
        }
      }

      if (servicioId != null) {
        updateData['servicioId'] = servicioId;
        final serviceData = await _getServiceData(servicioId);
        if (serviceData != null) {
          updateData['servicioNombre'] = serviceData['name'];
          if (duracion == null) {
            updateData['duracion'] = serviceData['duration'];
          }
        }
      }

      if (fecha != null) updateData['fecha'] = Timestamp.fromDate(fecha);
      if (estado != null) updateData['estado'] = estado;
      if (comentarios != null) updateData['comentarios'] = comentarios;
      if (duracion != null) updateData['duracion'] = duracion;

      await doc.update(updateData);

      debugPrint('✅ Cita actualizada exitosamente: $appointmentId');
    } catch (e) {
      debugPrint('❌ Error actualizarCita: $e');
      throw BookingException('Error al actualizar la cita: $e');
    }
  }

  /// ✅ CAMBIAR ESTADO DE CITA (método específico más eficiente)
  Future<void> cambiarEstadoCita(
      String appointmentId, String nuevoEstado) async {
    try {
      await _db.collection(collection).doc(appointmentId).update({
        'estado': nuevoEstado,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint(
          '✅ Estado de cita actualizado: $appointmentId -> $nuevoEstado');
    } catch (e) {
      debugPrint('❌ Error cambiarEstadoCita: $e');
      throw BookingException('Error al cambiar estado de la cita: $e');
    }
  }

  /// ✅ CANCELAR CITA
  Future<void> cancelarCita(String appointmentId) async {
    try {
      await _db.collection(collection).doc(appointmentId).update({
        'estado': 'cancelado',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Cita cancelada: $appointmentId');
    } catch (e) {
      debugPrint('❌ Error cancelarCita: $e');
      throw BookingException('Error al cancelar la cita: $e');
    }
  }

  /// ✅ ELIMINAR CITA DEFINITIVAMENTE
  Future<void> eliminarCita(String appointmentId) async {
    try {
      await _db.collection(collection).doc(appointmentId).delete();
      debugPrint('✅ Cita eliminada definitivamente: $appointmentId');
    } catch (e) {
      debugPrint('❌ Error eliminarCita: $e');
      throw BookingException('Error al eliminar la cita: $e');
    }
  }

  // ========================================================================
  // 🎯 MÉTODOS DE BÚSQUEDA Y FILTRADO
  // ========================================================================

  /// ✅ BUSCAR CITAS POR TEXTO
  Future<List<AppointmentModel>> buscarCitas({
    required String query,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? estado,
    String? profesionalId,
    int limit = 50,
  }) async {
    try {
      Query<Map<String, dynamic>> firestoreQuery = _db.collection(collection);

      // Filtros opcionales
      if (fechaInicio != null && fechaFin != null) {
        firestoreQuery = firestoreQuery
            .where('fecha',
                isGreaterThanOrEqualTo: Timestamp.fromDate(fechaInicio))
            .where('fecha', isLessThan: Timestamp.fromDate(fechaFin));
      }

      if (estado != null && estado.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('estado', isEqualTo: estado);
      }

      if (profesionalId != null && profesionalId.isNotEmpty) {
        firestoreQuery =
            firestoreQuery.where('profesionalId', isEqualTo: profesionalId);
      }

      final results = await firestoreQuery
          .orderBy('fecha', descending: true)
          .limit(limit)
          .get();

      final appointments = results.docs
          .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
          .toList();

      // Filtrar por texto en memoria (Firestore no soporta búsqueda de texto completa)
      if (query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        return appointments.where((appointment) {
          return appointment.nombreCliente
                      ?.toLowerCase()
                      .contains(lowerQuery) ==
                  true ||
              appointment.profesionalNombre
                      ?.toLowerCase()
                      .contains(lowerQuery) ==
                  true ||
              appointment.servicioNombre?.toLowerCase().contains(lowerQuery) ==
                  true ||
              appointment.estado?.toLowerCase().contains(lowerQuery) == true;
        }).toList();
      }

      return appointments;
    } catch (e) {
      debugPrint('❌ Error buscarCitas: $e');
      throw BookingException('Error al buscar citas: $e');
    }
  }

  /// ✅ BUSCAR CLIENTE POR TELÉFONO (método existente del proyecto)
  Future<DocumentSnapshot?> buscarClientePorTelefono(String telefono) async {
    try {
      final query = await _db
          .collection('clients')
          .where('telefono', isEqualTo: telefono)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error buscarClientePorTelefono: $e');
      return null;
    }
  }

  // ========================================================================
  // 🎯 MÉTODOS DE ESTADÍSTICAS Y MÉTRICAS
  // ========================================================================

  /// ✅ OBTENER ESTADÍSTICAS DE CITAS POR DÍA
  Future<Map<String, int>> getEstadisticasCitas(DateTime fecha) async {
    try {
      final citas = await getCitasPorFecha(fecha);
      final stats = <String, int>{
        'total': citas.length,
        'confirmadas': 0,
        'reservadas': 0,
        'canceladas': 0,
        'completadas': 0,
        'en_camino': 0,
      };

      for (final cita in citas) {
        final estado = cita.estado?.toLowerCase() ?? 'desconocido';
        switch (estado) {
          case 'confirmado':
          case 'confirmada':
            stats['confirmadas'] = (stats['confirmadas'] ?? 0) + 1;
            break;
          case 'reservado':
          case 'reservada':
            stats['reservadas'] = (stats['reservadas'] ?? 0) + 1;
            break;
          case 'cancelado':
          case 'cancelada':
            stats['canceladas'] = (stats['canceladas'] ?? 0) + 1;
            break;
          case 'completado':
          case 'completada':
          case 'realizada':
          case 'cita_realizada':
            stats['completadas'] = (stats['completadas'] ?? 0) + 1;
            break;
          case 'en camino':
          case 'profesional en camino':
            stats['en_camino'] = (stats['en_camino'] ?? 0) + 1;
            break;
        }
      }

      return stats;
    } catch (e) {
      debugPrint('❌ Error getEstadisticasCitas: $e');
      throw BookingException('Error al obtener estadísticas: $e');
    }
  }

  /// ✅ OBTENER MÉTRICAS DE OCUPACIÓN POR PROFESIONAL
  Future<Map<String, double>> getOcupacionPorProfesional(DateTime fecha) async {
    try {
      final citas = await getCitasPorFecha(fecha);
      final ocupacion = <String, double>{};
      final citasPorProfesional = <String, int>{};

      // Contar citas por profesional
      for (final cita in citas) {
        final profesionalId = cita.profesionalId;
        if (profesionalId != null && profesionalId.isNotEmpty) {
          citasPorProfesional[profesionalId] =
              (citasPorProfesional[profesionalId] ?? 0) + 1;
        }
      }

      // Calcular porcentaje de ocupación (asumiendo 10 slots máximos por día)
      const int maxSlotsPorDia = 10;
      for (final entry in citasPorProfesional.entries) {
        ocupacion[entry.key] = (entry.value / maxSlotsPorDia) * 100;
      }

      return ocupacion;
    } catch (e) {
      debugPrint('❌ Error getOcupacionPorProfesional: $e');
      return {};
    }
  }

  // ========================================================================
  // 🎯 STREAMS EN TIEMPO REAL
  // ========================================================================

  /// ✅ STREAM DE CITAS EN TIEMPO REAL POR FECHA
  Stream<List<AppointmentModel>> getCitasStream(DateTime fecha) {
    final startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _db
        .collection(collection)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('fecha', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('fecha')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// ✅ STREAM DE CITAS POR PROFESIONAL
  Stream<List<AppointmentModel>> getCitasProfesionalStream(
    String profesionalId,
    DateTime fecha,
  ) {
    final startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _db
        .collection(collection)
        .where('profesionalId', isEqualTo: profesionalId)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('fecha', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('fecha')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ========================================================================
  // 🎯 MÉTODOS DE VALIDACIÓN Y CONFLICTOS
  // ========================================================================

  /// ✅ VALIDAR CONFLICTOS DE TIEMPO
  bool hasTimeConflict(
    AppointmentModel existing,
    DateTime newStartTime,
    int newDurationMinutes,
  ) {
    if (existing.fechaInicio == null) return false;

    final newEndTime = newStartTime.add(Duration(minutes: newDurationMinutes));
    final existingEndTime = existing.fechaInicio!.add(
      Duration(minutes: existing.duracion ?? 60),
    );

    return (newStartTime.isBefore(existingEndTime) &&
        newEndTime.isAfter(existing.fechaInicio!));
  }

  /// ✅ VERIFICAR DISPONIBILIDAD DE PROFESIONAL
  Future<bool> isProfesionalDisponible({
    required String profesionalId,
    required DateTime fechaHora,
    required int duracionMinutos,
    String? excludeAppointmentId,
  }) async {
    try {
      final existingAppointments = await getCitasPorProfesionalYFecha(
        profesionalId,
        fechaHora,
      );

      // Excluir la cita especificada (útil para movimientos)
      final filteredAppointments = excludeAppointmentId != null
          ? existingAppointments
              .where((apt) => apt.id != excludeAppointmentId)
              .toList()
          : existingAppointments;

      // Verificar conflictos de tiempo
      for (final appointment in filteredAppointments) {
        if (hasTimeConflict(appointment, fechaHora, duracionMinutos)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error verificando disponibilidad: $e');
      return false;
    }
  }

  // ========================================================================
  // 🎯 MÉTODOS BATCH OPERATIONS
  // ========================================================================

  /// ✅ MOVER MÚLTIPLES CITAS
  Future<List<BatchOperationResult>> moverCitasBatch({
    required List<String> appointmentIds,
    required DateTime fechaBase,
    required String profesionalId,
    int intervalMinutos = 60,
  }) async {
    final results = <BatchOperationResult>[];
    var currentTime = fechaBase;

    for (final appointmentId in appointmentIds) {
      try {
        await moverCita(
          appointmentId: appointmentId,
          nuevaFecha: currentTime,
          nuevoProfesionalId: profesionalId,
        );

        results.add(BatchOperationResult(
          appointmentId: appointmentId,
          success: true,
          newDateTime: currentTime,
        ));

        currentTime = currentTime.add(Duration(minutes: intervalMinutos));
      } catch (e) {
        results.add(BatchOperationResult(
          appointmentId: appointmentId,
          success: false,
          error: e.toString(),
        ));
      }
    }

    return results;
  }

  /// ✅ CANCELAR MÚLTIPLES CITAS
  Future<List<BatchOperationResult>> cancelarCitasBatch(
    List<String> appointmentIds,
  ) async {
    final results = <BatchOperationResult>[];

    for (final appointmentId in appointmentIds) {
      try {
        await cancelarCita(appointmentId);
        results.add(BatchOperationResult(
          appointmentId: appointmentId,
          success: true,
        ));
      } catch (e) {
        results.add(BatchOperationResult(
          appointmentId: appointmentId,
          success: false,
          error: e.toString(),
        ));
      }
    }

    return results;
  }

  // ========================================================================
  // 🎯 MÉTODOS HELPER PRIVADOS
  // ========================================================================

  Future<String?> _getProfessionalName(String profesionalId) async {
    try {
      final doc =
          await _db.collection('profesionales').doc(profesionalId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return '${data['nombre'] ?? ''} ${data['apellidos'] ?? ''}'.trim();
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ Error getting professional name: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getServiceData(String servicioId) async {
    try {
      final doc = await _db.collection('services').doc(servicioId).get();

      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ Error getting service data: $e');
      return null;
    }
  }

  /// ✅ FORMATEAR FECHA PARA LOGS
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}

// ============================================================================
// 🎯 DATA CLASSES Y EXCEPCIONES
// ============================================================================

class BookingException implements Exception {
  final String message;
  final String? code;

  BookingException(this.message, [this.code]);

  @override
  String toString() =>
      'BookingException: $message${code != null ? ' (Code: $code)' : ''}';
}

class BatchOperationResult {
  final String appointmentId;
  final bool success;
  final String? error;
  final DateTime? newDateTime;

  BatchOperationResult({
    required this.appointmentId,
    required this.success,
    this.error,
    this.newDateTime,
  });

  @override
  String toString() {
    return 'BatchOperationResult(id: $appointmentId, success: $success, error: $error)';
  }
}

// ============================================================================
// 🎯 EXTENSIONES ÚTILES
// ============================================================================

extension AppointmentModelExtensions on AppointmentModel {
  /// Verifica si la cita está en el pasado
  bool get isPast {
    if (fechaInicio == null) return false;
    return fechaInicio!.isBefore(DateTime.now());
  }

  /// Verifica si la cita es hoy
  bool get isToday {
    if (fechaInicio == null) return false;
    final now = DateTime.now();
    final citaDate = fechaInicio!;
    return citaDate.year == now.year &&
        citaDate.month == now.month &&
        citaDate.day == now.day;
  }

  /// Obtiene la duración formateada
  String get duracionFormateada {
    if (duracion == null) return 'No especificada';
    final hours = duracion! ~/ 60;
    final minutes = duracion! % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Obtiene el color según el estado
  Color getStatusColor() {
    switch (estado?.toLowerCase()) {
      case 'confirmado':
      case 'confirmada':
        return const Color(0xFF4CAF50); // Verde
      case 'reservado':
      case 'reservada':
        return const Color(0xFFFF9800); // Naranja
      case 'cancelado':
      case 'cancelada':
        return const Color(0xFFF44336); // Rojo
      case 'completado':
      case 'completada':
      case 'realizada':
      case 'cita_realizada':
        return const Color(0xFF9C27B0); // Morado
      case 'en camino':
      case 'profesional en camino':
        return const Color(0xFF2196F3); // Azul
      default:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

  /// Verifica si el estado permite edición
  bool get isEditable {
    final estado = this.estado?.toLowerCase();
    return estado != 'cancelada' &&
        estado != 'cancelado' &&
        estado != 'completada' &&
        estado != 'cita_realizada';
  }

  /// Verifica si el estado permite movimiento
  bool get isMovable {
    return isEditable && !isPast;
  }
}
