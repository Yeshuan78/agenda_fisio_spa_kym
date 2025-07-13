import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // ✅ Para debugPrint

class FirestoreAgendaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<DateTime, List<DocumentSnapshot>>> loadCitas(
      String? profesionalId) async {
    Query<Map<String, dynamic>> query =
        _db.collection('bookings').orderBy('fecha');

    if (profesionalId != null) {
      query = query.where('profesionalId', isEqualTo: profesionalId);
    }

    final snapshot = await query.get();

    final Map<DateTime, List<DocumentSnapshot>> result = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (!data.containsKey('fecha') || data['fecha'] == null) continue;

      DateTime fecha;

      if (data['fecha'] is Timestamp) {
        fecha = (data['fecha'] as Timestamp).toDate();
      } else if (data['fecha'] is String) {
        fecha = DateTime.tryParse(data['fecha']) ?? DateTime.now();
      } else {
        continue;
      }

      final fechaKey = DateTime(fecha.year, fecha.month, fecha.day);
      result.putIfAbsent(fechaKey, () => []).add(doc);
    }

    return result;
  }

  Future<List<DocumentSnapshot>> loadClients() async {
    final snapshot = await _db.collection('clients').orderBy('nombre').get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> loadServicesFromCategories() async {
    final snapshot = await _db.collection('services').orderBy('nombre').get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> loadProfesionalesForm() async {
    final snapshot =
        await _db.collection('profesionales').orderBy('nombre').get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> loadProfesionalesFiltro() async {
    final snapshot =
        await _db.collection('profesionales').orderBy('nombre').get();
    return snapshot.docs;
  }

  Future<DocumentSnapshot?> buscarClientePorTelefono(String telefono) async {
    final query = await _db
        .collection('clients')
        .where('telefono', isEqualTo: telefono)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first;
    }
    return null;
  }

  Future<void> actualizarEstadoCita(
      String bookingId, String nuevoEstado) async {
    await _db.collection('bookings').doc(bookingId).update({
      'estado': nuevoEstado,
    });
  }

  // ✅ Método para cancelar cita (estado = 'cancelado')
  Future<void> cancelarCita(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'estado': 'cancelado',
    });
  }

  // ✅ Método original usado por professional_calendar_loader
  Future<Map<String, dynamic>> loadProfesionalCalendar(
      String profesionalId) async {
    final doc = await _db.collection('profesionales').doc(profesionalId).get();
    return doc.data()?['disponibilidad'] ?? {};
  }

  Future<String?> loadProfesionalPhoto(String profesionalId) async {
    final doc = await _db.collection('profesionales').doc(profesionalId).get();
    return doc.data()?['fotoUrl'];
  }

  // ✅ MÉTODO EXISTENTE - ACTUALIZADO para mejor compatibilidad
  Future<Map<DateTime, List<Map<String, dynamic>>>> loadBloqueos(
      String? profesionalId) async {
    try {
      Query<Map<String, dynamic>> query = _db
          .collection('bloqueos')
          .where('estado', isEqualTo: 'activo') // ✅ Solo bloqueos activos
          .orderBy('fecha');

      if (profesionalId != null) {
        query = query.where('profesionalId', isEqualTo: profesionalId);
      }

      final snapshot = await query.get();
      final Map<DateTime, List<Map<String, dynamic>>> result = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (!data.containsKey('fecha') || data['fecha'] == null) continue;

        DateTime fecha;
        if (data['fecha'] is Timestamp) {
          fecha = (data['fecha'] as Timestamp).toDate();
        } else if (data['fecha'] is String) {
          fecha = DateTime.tryParse(data['fecha']) ?? DateTime.now();
        } else {
          continue;
        }

        final fechaKey = DateTime(fecha.year, fecha.month, fecha.day);

        // ✅ AGREGAR ID DEL DOCUMENTO para operaciones futuras
        final bloqueoData = Map<String, dynamic>.from(data);
        bloqueoData['id'] = doc.id;

        result.putIfAbsent(fechaKey, () => []).add(bloqueoData);
      }

      // ✅ DEBUG mejorado
      debugPrint('🚫 Bloqueos cargados: ${result.length} días con bloqueos');
      result.forEach((date, blocks) {
        debugPrint('   ${date.day}/${date.month}: ${blocks.length} bloqueos');
      });

      return result;
    } catch (e) {
      debugPrint('❌ Error cargando bloqueos: $e');
      return {};
    }
  }

  // ✅ MÉTODO EXISTENTE - Sin cambios
  Future<bool> isTimeBlocked(String profesionalId, DateTime dateTime) async {
    try {
      final bloqueos = await loadBloqueos(profesionalId);
      final dateKey = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final dayBloqueos = bloqueos[dateKey] ?? [];

      for (final bloqueo in dayBloqueos) {
        if (bloqueo['estado'] != 'activo') continue;

        final horaInicio = bloqueo['horaInicio'] as String?;
        final horaFin = bloqueo['horaFin'] as String?;

        if (horaInicio != null && horaFin != null) {
          final inicioTime = _parseTimeString(horaInicio, dateTime);
          final finTime = _parseTimeString(horaFin, dateTime);

          if (dateTime.isAfter(inicioTime) && dateTime.isBefore(finTime)) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error verificando bloqueos: $e');
      return false;
    }
  }

  // ✅ MÉTODO EXISTENTE - Sin cambios
  DateTime _parseTimeString(String timeStr, DateTime baseDate) {
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

  // ✅ NUEVOS MÉTODOS AGREGADOS para funcionalidad completa de bloqueos

  /// Eliminar un bloqueo específico por ID
  Future<void> eliminarBloqueo(String bloqueoId) async {
    try {
      await _db.collection('bloqueos').doc(bloqueoId).delete();
      debugPrint('✅ Bloqueo eliminado: $bloqueoId');
    } catch (e) {
      debugPrint('❌ Error eliminando bloqueo: $e');
      throw Exception('Error eliminando bloqueo: $e');
    }
  }

  /// Actualizar estado de un bloqueo (activo/inactivo)
  Future<void> actualizarEstadoBloqueo(
      String bloqueoId, String nuevoEstado) async {
    try {
      await _db.collection('bloqueos').doc(bloqueoId).update({
        'estado': nuevoEstado,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Estado de bloqueo actualizado: $bloqueoId -> $nuevoEstado');
    } catch (e) {
      debugPrint('❌ Error actualizando estado del bloqueo: $e');
      throw Exception('Error actualizando bloqueo: $e');
    }
  }

  /// Crear un nuevo bloqueo de horario
  Future<String> crearBloqueo({
    required String profesionalId,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required String motivo,
    String tipo = 'manual',
    String creadoPor = 'Sistema',
  }) async {
    try {
      final docRef = await _db.collection('bloqueos').add({
        'profesionalId': profesionalId,
        'fecha':
            Timestamp.fromDate(DateTime(fecha.year, fecha.month, fecha.day)),
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'motivo': motivo,
        'tipo': tipo,
        'estado': 'activo',
        'creadoPor': creadoPor,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Bloqueo creado: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creando bloqueo: $e');
      throw Exception('Error creando bloqueo: $e');
    }
  }

  /// Obtener bloqueos de un profesional para un día específico
  Future<List<Map<String, dynamic>>> getBloqueosDelDia(
    String profesionalId,
    DateTime fecha,
  ) async {
    try {
      final fechaKey = DateTime(fecha.year, fecha.month, fecha.day);
      final query = await _db
          .collection('bloqueos')
          .where('profesionalId', isEqualTo: profesionalId)
          .where('fecha', isEqualTo: Timestamp.fromDate(fechaKey))
          .where('estado', isEqualTo: 'activo')
          .get();

      return query.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo bloqueos del día: $e');
      return [];
    }
  }

  /// Verificar si un rango de tiempo está bloqueado
  Future<bool> isRangeBlocked(
    String profesionalId,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    try {
      final bloqueos = await getBloqueosDelDia(profesionalId, fechaInicio);

      for (final bloqueo in bloqueos) {
        final horaInicio = bloqueo['horaInicio'] as String?;
        final horaFinBloqueo = bloqueo['horaFin'] as String?;

        if (horaInicio != null && horaFinBloqueo != null) {
          final inicioBloqueo = _parseTimeString(horaInicio, fechaInicio);
          final finBloqueo = _parseTimeString(horaFinBloqueo, fechaInicio);

          // Verificar solapamiento
          if (fechaInicio.isBefore(finBloqueo) &&
              fechaFin.isAfter(inicioBloqueo)) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error verificando rango bloqueado: $e');
      return false;
    }
  }

  /// Obtener información de un bloqueo específico
  Future<Map<String, dynamic>?> getBloqueoInfo(String bloqueoId) async {
    try {
      final doc = await _db.collection('bloqueos').doc(bloqueoId).get();
      if (doc.exists) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error obteniendo info del bloqueo: $e');
      return null;
    }
  }
}
