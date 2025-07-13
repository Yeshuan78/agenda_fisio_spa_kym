// [appointment_model.dart] - VERSIÓN COMPLETA: TODO LO EXISTENTE + CABINAS
// 📁 Ubicación: /lib/models/appointment_model.dart
// 🔧 MIGRACIÓN QUIRÚRGICA: Mantener 100% compatibilidad + nuevas funcionalidades

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 📅 MODELO DE CITA ACTUALIZADO PARA AGENDA PREMIUM
/// Compatible con estructura Firestore existente + nuevas funcionalidades
class AppointmentModel {
  // ✅ CAMPOS PRINCIPALES (FIRESTORE MAPPING) - ORIGINALES
  final String id;
  final String? bookingId;
  final String? clienteId;
  final String? nombreCliente;
  final String? clientEmail;
  final String? clientPhone;
  final String? profesionalId;
  final String? profesionalNombre;
  final String? servicioId;
  final String? servicioNombre;
  final String? estado;
  final String? comentarios;

  // 🆕 NUEVOS CAMPOS PARA CABINAS Y EQUIPOS
  final String? cabinaId; // ID de cabina
  final String? cabinaNombre; // Nombre de cabina
  final String? equipoId; // ID de equipo/instrumento
  final String? equipoNombre; // Nombre de equipo

  // ✅ CAMPOS DE FECHA Y TIEMPO - ORIGINALES
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int? duracion; // En minutos

  // ✅ CAMPOS DE AUDITORÍA - ORIGINALES
  final DateTime? creadoEn;
  final DateTime? updatedAt;

  // ✅ CAMPOS ADICIONALES PARA DRAG & DROP - ORIGINALES
  final String? recursoTipo; // 'profesional', 'cabina', 'mixto'
  final String? prioridad; // 'alta', 'media', 'baja'
  final bool? esRecurrente;
  final Map<String, dynamic>? metadatos; // Datos adicionales flexibles

  // ✅ CAMPOS CALCULADOS (NO ALMACENADOS) - ORIGINALES
  final Color? colorCita; // Color dinámico basado en estado
  final bool? tieneConflicto; // Detectado en tiempo real

  AppointmentModel({
    required this.id,
    this.bookingId,
    this.clienteId,
    this.nombreCliente,
    this.clientEmail,
    this.clientPhone,
    this.profesionalId,
    this.profesionalNombre,
    this.cabinaId, // 🆕 NUEVO
    this.cabinaNombre, // 🆕 NUEVO
    this.servicioId,
    this.servicioNombre,
    this.equipoId, // 🆕 NUEVO
    this.equipoNombre, // 🆕 NUEVO
    this.estado,
    this.comentarios,
    this.fechaInicio,
    this.fechaFin,
    this.duracion,
    this.creadoEn,
    this.updatedAt,
    this.recursoTipo,
    this.prioridad,
    this.esRecurrente,
    this.metadatos,
    this.colorCita,
    this.tieneConflicto,
  });

  /// 🏗️ FACTORY CONSTRUCTOR DESDE FIRESTORE
  factory AppointmentModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel.fromMap(data, doc.id);
  }

  /// 🏗️ FACTORY CONSTRUCTOR DESDE MAP
  static AppointmentModel fromMap(Map<String, dynamic> data, String id) {
    return AppointmentModel(
      id: id,
      bookingId: data['bookingId'],
      clienteId: data['clienteId'],
      nombreCliente:
          data['clienteNombre'] ?? data['clientName'], // Compatibilidad
      clientEmail: data['clientEmail'],
      clientPhone: data['clientPhone'],
      profesionalId: data['profesionalId'],
      profesionalNombre: data['profesionalNombre'],
      cabinaId: data['cabinaId'], // 🆕 NUEVO
      cabinaNombre: data['cabinaNombre'], // 🆕 NUEVO
      servicioId: data['servicioId'],
      servicioNombre:
          data['servicioNombre'] ?? data['serviceName'], // Compatibilidad
      equipoId: data['equipoId'], // 🆕 NUEVO
      equipoNombre: data['equipoNombre'], // 🆕 NUEVO
      estado: data['estado'] ?? data['status'], // Compatibilidad
      comentarios: data['comentarios'] ?? data['notes'],
      fechaInicio: _parseDateTime(data['fecha'] ?? data['date']),
      fechaFin: _parseDateTime(data['fechaFin'] ?? data['endDate']),
      duracion: data['duracion'] ?? data['duration'] ?? 60, // Default 60 min
      creadoEn: _parseDateTime(data['creadoEn'] ?? data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      recursoTipo: data['recursoTipo'] ?? 'profesional',
      prioridad: data['prioridad'] ?? 'media',
      esRecurrente: data['esRecurrente'] ?? false,
      metadatos: data['metadatos'] ?? {},
      // Campos calculados se asignan después
      colorCita: null,
      tieneConflicto: null,
    );
  }

  /// 🕒 PARSER DE FECHA/HORA ROBUSTO
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    try {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        // Intentar múltiples formatos
        return DateTime.tryParse(value) ??
            DateFormat('yyyy-MM-dd HH:mm').tryParse(value) ??
            DateFormat('dd/MM/yyyy HH:mm').tryParse(value);
      }
    } catch (e) {
      print('⚠️ Error parsing date: $value - $e');
    }

    return null;
  }

  /// 💾 CONVERSIÓN A MAP PARA FIRESTORE
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      // Campos principales
      'bookingId': bookingId ?? id,
      'clienteId': clienteId,
      'clienteNombre': nombreCliente,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'profesionalId': profesionalId,
      'profesionalNombre': profesionalNombre,
      'cabinaId': cabinaId, // 🆕 NUEVO
      'cabinaNombre': cabinaNombre, // 🆕 NUEVO
      'servicioId': servicioId,
      'servicioNombre': servicioNombre,
      'equipoId': equipoId, // 🆕 NUEVO
      'equipoNombre': equipoNombre, // 🆕 NUEVO
      'estado': estado,
      'comentarios': comentarios,

      // Fechas como Timestamp para Firestore
      'fecha': fechaInicio != null ? Timestamp.fromDate(fechaInicio!) : null,
      'fechaFin': fechaFin != null ? Timestamp.fromDate(fechaFin!) : null,
      'duracion': duracion,

      // Auditoría
      'creadoEn': creadoEn != null
          ? Timestamp.fromDate(creadoEn!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),

      // Campos adicionales
      'recursoTipo': recursoTipo,
      'prioridad': prioridad,
      'esRecurrente': esRecurrente,
      'metadatos': metadatos,
    };

    // Remover campos null para mantener Firestore limpio
    map.removeWhere((key, value) => value == null);
    return map;
  }

  /// 📋 GETTERS DE COMPATIBILIDAD (Para widgets existentes) - TODOS LOS ORIGINALES
  String get clientName => nombreCliente ?? '';
  String get servicio => servicioNombre ?? '';
  String get profesional => profesionalNombre ?? '';
  String get estadoCita => estado ?? 'Desconocido';
  String get comentariosTexto => comentarios ?? '';
  String get nombreProfesional => profesionalNombre ?? '';
  String get date => fechaInicio?.toIso8601String() ?? '';
  String get appointmentId => id;

  /// 🕐 FORMATEO DE HORA - ORIGINALES
  String get horaCita {
    if (fechaInicio == null) return '';
    return DateFormat.Hm().format(fechaInicio!);
  }

  String get hora => horaCita;

  /// 📅 FORMATEO DE FECHA - ORIGINALES
  String get fechaFormateada {
    if (fechaInicio == null) return '';
    return DateFormat('dd/MM/yyyy').format(fechaInicio!);
  }

  /// 📝 RESUMEN COMPLETO - ORIGINAL + CABINAS
  String get resumen => '''
Cliente: $clientName
Profesional: $profesional
${cabinaNombre != null ? 'Cabina: $cabinaNombre' : ''}
${equipoNombre != null ? 'Equipo: $equipoNombre' : ''}
Servicio: $servicio
Fecha: $fechaFormateada
Hora: $horaCita
Duración: ${duracion ?? 60} min
Estado: $estadoCita
${comentariosTexto.isNotEmpty ? 'Notas: $comentariosTexto' : ''}
''';

  /// ⏱️ CÁLCULO DE FECHA FIN AUTOMÁTICA - ORIGINAL
  DateTime? get fechaFinCalculada {
    if (fechaInicio == null) return null;
    return fechaInicio!.add(Duration(minutes: duracion ?? 60));
  }

  /// 🎨 COLOR DINÁMICO BASADO EN ESTADO - ORIGINAL
  Color get colorEstado {
    switch (estado?.toLowerCase()) {
      case 'confirmado':
      case 'confirmada':
        return const Color(0xFF4CAF50); // Verde
      case 'reservado':
      case 'reservada':
      case 'pendiente':
        return const Color(0xFFFF9800); // Naranja
      case 'cancelado':
      case 'cancelada':
        return const Color(0xFFF44336); // Rojo
      case 'en camino':
        return const Color(0xFF2196F3); // Azul
      case 'realizada':
      case 'completada':
        return const Color(0xFF9C27B0); // Morado
      case 'no_asistio':
        return const Color(0xFF795548); // Marrón
      default:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

  /// 🆕 NUEVOS GETTERS PARA CABINAS Y EQUIPOS
  String get recursosAsignados {
    final recursos = <String>[];
    if (profesionalNombre != null) recursos.add(profesionalNombre!);
    if (cabinaNombre != null) recursos.add('Cabina: $cabinaNombre');
    if (equipoNombre != null) recursos.add('Equipo: $equipoNombre');
    if (servicioNombre != null) recursos.add(servicioNombre!);
    return recursos.join(' • ');
  }

  bool get usaCabina => cabinaId != null && cabinaId!.isNotEmpty;
  bool get usaEquipo => equipoId != null && equipoId!.isNotEmpty;
  bool get esReservaMixta =>
      [profesionalId, cabinaId, equipoId]
          .where((id) => id != null && id.isNotEmpty)
          .length >
      1;

  String? get recursoPrincipal =>
      profesionalId ?? cabinaId ?? equipoId ?? servicioId;

  bool usaRecurso(String resourceId) {
    return profesionalId == resourceId ||
        cabinaId == resourceId ||
        equipoId == resourceId ||
        servicioId == resourceId;
  }

  /// 🔍 MÉTODO DE BÚSQUEDA - ORIGINAL + CABINAS
  bool matchesSearchQuery(String query) {
    if (query.isEmpty) return true;

    final searchTerms = query.toLowerCase().split(' ');
    final searchableText = '''
      ${nombreCliente ?? ''} 
      ${profesionalNombre ?? ''} 
      ${cabinaNombre ?? ''} 
      ${equipoNombre ?? ''} 
      ${servicioNombre ?? ''} 
      ${estado ?? ''} 
      ${comentarios ?? ''}
    '''
        .toLowerCase();

    return searchTerms.every((term) => searchableText.contains(term));
  }

  /// 🔄 MÉTODO COPYWIHT PARA IMMUTABILIDAD - ORIGINAL + CABINAS
  AppointmentModel copyWith({
    String? id,
    String? bookingId,
    String? clienteId,
    String? nombreCliente,
    String? clientEmail,
    String? clientPhone,
    String? profesionalId,
    String? profesionalNombre,
    String? cabinaId, // 🆕 NUEVO
    String? cabinaNombre, // 🆕 NUEVO
    String? servicioId,
    String? servicioNombre,
    String? equipoId, // 🆕 NUEVO
    String? equipoNombre, // 🆕 NUEVO
    String? estado,
    String? comentarios,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? duracion,
    DateTime? creadoEn,
    DateTime? updatedAt,
    String? recursoTipo,
    String? prioridad,
    bool? esRecurrente,
    Map<String, dynamic>? metadatos,
    Color? colorCita,
    bool? tieneConflicto,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      clienteId: clienteId ?? this.clienteId,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      profesionalId: profesionalId ?? this.profesionalId,
      profesionalNombre: profesionalNombre ?? this.profesionalNombre,
      cabinaId: cabinaId ?? this.cabinaId, // 🆕 NUEVO
      cabinaNombre: cabinaNombre ?? this.cabinaNombre, // 🆕 NUEVO
      servicioId: servicioId ?? this.servicioId,
      servicioNombre: servicioNombre ?? this.servicioNombre,
      equipoId: equipoId ?? this.equipoId, // 🆕 NUEVO
      equipoNombre: equipoNombre ?? this.equipoNombre, // 🆕 NUEVO
      estado: estado ?? this.estado,
      comentarios: comentarios ?? this.comentarios,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      duracion: duracion ?? this.duracion,
      creadoEn: creadoEn ?? this.creadoEn,
      updatedAt: updatedAt ?? this.updatedAt,
      recursoTipo: recursoTipo ?? this.recursoTipo,
      prioridad: prioridad ?? this.prioridad,
      esRecurrente: esRecurrente ?? this.esRecurrente,
      metadatos: metadatos ?? this.metadatos,
      colorCita: colorCita ?? this.colorCita,
      tieneConflicto: tieneConflicto ?? this.tieneConflicto,
    );
  }

  /// 🔍 VALIDACIONES DE NEGOCIO - ORIGINALES
  bool get esValida {
    return nombreCliente != null &&
        nombreCliente!.isNotEmpty &&
        (profesionalId != null ||
            cabinaId != null ||
            equipoId != null) && // 🆕 Incluir cabinas
        fechaInicio != null;
  }

  bool get esPasada {
    return fechaInicio != null && fechaInicio!.isBefore(DateTime.now());
  }

  bool get esHoy {
    if (fechaInicio == null) return false;
    final now = DateTime.now();
    final appointmentDate = fechaInicio!;
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }

  bool get esManana {
    if (fechaInicio == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final appointmentDate = fechaInicio!;
    return appointmentDate.year == tomorrow.year &&
        appointmentDate.month == tomorrow.month &&
        appointmentDate.day == tomorrow.day;
  }

  /// ⚖️ COMPARACIÓN PARA ORDENAMIENTO - ORIGINAL
  int compareTo(AppointmentModel other) {
    if (fechaInicio == null && other.fechaInicio == null) return 0;
    if (fechaInicio == null) return 1;
    if (other.fechaInicio == null) return -1;
    return fechaInicio!.compareTo(other.fechaInicio!);
  }

  /// 🎯 EQUALITY Y HASHCODE - ORIGINALES
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// 🖨️ TO STRING PARA DEBUG - ORIGINAL + CABINAS
  @override
  String toString() {
    return 'AppointmentModel{id: $id, cliente: $nombreCliente, profesional: $profesional, cabina: $cabinaNombre, fecha: $fechaFormateada $horaCita, estado: $estado}';
  }
}

/// 📊 EXTENSIÓN PARA ESTADÍSTICAS - ORIGINALES
extension AppointmentModelStats on List<AppointmentModel> {
  List<AppointmentModel> get citasHoy {
    final now = DateTime.now();
    return where((apt) =>
        apt.fechaInicio != null &&
        apt.fechaInicio!.year == now.year &&
        apt.fechaInicio!.month == now.month &&
        apt.fechaInicio!.day == now.day).toList();
  }

  List<AppointmentModel> get citasManana {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return where((apt) =>
        apt.fechaInicio != null &&
        apt.fechaInicio!.year == tomorrow.year &&
        apt.fechaInicio!.month == tomorrow.month &&
        apt.fechaInicio!.day == tomorrow.day).toList();
  }

  Map<String, int> get estadisticasPorEstado {
    final stats = <String, int>{};
    for (final apt in this) {
      final estado = apt.estado ?? 'Sin estado';
      stats[estado] = (stats[estado] ?? 0) + 1;
    }
    return stats;
  }

  double get duracionPromedio {
    if (isEmpty) return 0.0;
    final totalDuracion =
        fold<int>(0, (sum, apt) => sum + (apt.duracion ?? 60));
    return totalDuracion / length;
  }

  // 🆕 NUEVAS ESTADÍSTICAS PARA CABINAS
  Map<String, int> get estadisticasPorCabina {
    final stats = <String, int>{};
    for (final apt in this) {
      if (apt.cabinaNombre != null) {
        final cabina = apt.cabinaNombre!;
        stats[cabina] = (stats[cabina] ?? 0) + 1;
      }
    }
    return stats;
  }

  List<AppointmentModel> get citasConCabina {
    return where((apt) => apt.usaCabina).toList();
  }

  List<AppointmentModel> get citasMixtas {
    return where((apt) => apt.esReservaMixta).toList();
  }
}
