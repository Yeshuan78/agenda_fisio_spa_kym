// [Archivo: lib/models/evento_model.dart]
// ✅ TU MODELO ACTUAL + CAMPOS NUEVOS OPCIONALES
import 'package:cloud_firestore/cloud_firestore.dart';

class EventoModel {
  final String id;
  final String? eventoId;
  final String nombre;
  final String empresa;
  final String? empresaId;
  final String ubicacion;
  final DateTime fecha;
  final String estado;
  final String observaciones;
  final dynamic fechaCreacion;
  final List<Map<String, dynamic>> serviciosAsignados;

  // ✅ NUEVOS CAMPOS OPCIONALES PARA PULSE PREMIUM
  final bool? esActivo;
  final DateTime? fechaUltimaActividad;
  final Map<String, dynamic>? metricas;
  final Map<String, dynamic>? configuracionPulse;

  EventoModel({
    required this.id,
    this.eventoId,
    required this.nombre,
    required this.empresa,
    this.empresaId,
    required this.ubicacion,
    required this.fecha,
    required this.estado,
    required this.observaciones,
    required this.serviciosAsignados,
    this.fechaCreacion,
    // ✅ NUEVOS CAMPOS OPCIONALES (no rompen código existente)
    this.esActivo,
    this.fechaUltimaActividad,
    this.metricas,
    this.configuracionPulse,
  });

  // ✅ TU MÉTODO ACTUAL + SOPORTE PARA CAMPOS NUEVOS
  factory EventoModel.fromMap(Map<String, dynamic> map, String id) {
    final List<Map<String, String>> servicios = [];

    if (map['serviciosAsignados'] != null) {
      for (var item in (map['serviciosAsignados'] as List)) {
        servicios.add({
          'servicioId': item['servicioId']?.toString() ?? '',
          'profesionalId': item['profesionalId']?.toString() ?? '',
          'servicioNombre': item['servicioNombre']?.toString() ?? '',
          'fechaAsignada': item['fechaAsignada']?.toString() ?? '',
          'profesionalNombre': item['profesionalNombre']?.toString() ?? '',
          'horaInicio': item['horaInicio'] ?? '09:00',
          'horaFin': item['horaFin'] ?? '15:00',
          'ubicacion': item['ubicacion'] ?? '',
        });
      }
    }

    return EventoModel(
      id: id,
      eventoId: map['eventoId']?.toString(),
      nombre: map['nombre'] ?? '',
      empresa: map['empresa'] ?? '',
      empresaId: map['empresaId']?.toString(),
      ubicacion: map['ubicacion'] ?? '',
      fecha: (map['fecha'] is Timestamp)
          ? (map['fecha'] as Timestamp).toDate()
          : DateTime.now(),
      estado: map['estado'] ?? 'activo',
      observaciones: map['observaciones'] ?? '',
      serviciosAsignados: servicios,
      fechaCreacion: map['fechaCreacion'],

      // ✅ NUEVOS CAMPOS OPCIONALES (solo si existen en Firestore)
      esActivo: map['esActivo'],
      fechaUltimaActividad: map['fechaUltimaActividad'] is Timestamp
          ? (map['fechaUltimaActividad'] as Timestamp).toDate()
          : null,
      metricas: map['metricas'] != null
          ? Map<String, dynamic>.from(map['metricas'])
          : null,
      configuracionPulse: map['configuracionPulse'] != null
          ? Map<String, dynamic>.from(map['configuracionPulse'])
          : null,
    );
  }

  // ✅ TU MÉTODO ACTUAL + CAMPOS NUEVOS OPCIONALES
  Map<String, dynamic> toMap() {
    final mapData = {
      'eventoId': eventoId,
      'nombre': nombre,
      'empresa': empresa,
      'empresaId': empresaId,
      'ubicacion': ubicacion,
      'fecha': Timestamp.fromDate(fecha),
      'estado': estado,
      'observaciones': observaciones,
      'fechaCreacion': fechaCreacion,
      'serviciosAsignados': serviciosAsignados
          .map((e) => {
                'servicioId': e['servicioId'] ?? '',
                'servicioNombre': e['servicioNombre'] ?? '',
                'profesionalId': e['profesionalId'] ?? '',
                'profesionalNombre': e['profesionalNombre'] ?? '',
                'ubicacion': e['ubicacion'] ?? '',
                'fechaAsignada': e['fechaAsignada'] ?? '',
              })
          .toList(),
    };

    // ✅ SOLO AGREGAR CAMPOS NUEVOS SI TIENEN VALOR
    if (esActivo != null) {
      mapData['esActivo'] = esActivo;
    }

    if (fechaUltimaActividad != null) {
      mapData['fechaUltimaActividad'] =
          Timestamp.fromDate(fechaUltimaActividad!);
    }

    if (metricas != null) {
      mapData['metricas'] = metricas;
    }

    if (configuracionPulse != null) {
      mapData['configuracionPulse'] = configuracionPulse;
    }

    return mapData;
  }

  // ✅ MÉTODOS HELPER PARA PULSE PREMIUM (opcional usar)

  /// Verifica si el evento está activo (basado en registros o campo esActivo)
  bool get estaActivo {
    return esActivo ?? false;
  }

  /// Obtiene métricas calculadas o por defecto
  Map<String, dynamic> get metricasCalculadas {
    return metricas ??
        {
          'totalRegistros': 0,
          'totalEncuestas': 0,
          'promedioSatisfaccion': 0.0,
          'serviciosCount': <String, int>{},
          'comentariosRecientes': <String>[],
        };
  }

  /// Configuración de Pulse o valores por defecto
  Map<String, dynamic> get configPulse {
    return configuracionPulse ??
        {
          'mostrarAnimaciones': true,
          'mostrarIndicadorEnVivo': true,
          'limiteComentarios': 3,
          'actualizacionTiempoReal': true,
        };
  }

  /// Crea una copia con métricas actualizadas (para PulseCard Premium)
  EventoModel copyWithMetricas({
    int? totalRegistros,
    int? totalEncuestas,
    double? promedioSatisfaccion,
    Map<String, int>? serviciosCount,
    List<String>? comentariosRecientes,
    bool? activo,
  }) {
    final nuevasMetricas = Map<String, dynamic>.from(metricasCalculadas);

    if (totalRegistros != null)
      nuevasMetricas['totalRegistros'] = totalRegistros;
    if (totalEncuestas != null)
      nuevasMetricas['totalEncuestas'] = totalEncuestas;
    if (promedioSatisfaccion != null)
      nuevasMetricas['promedioSatisfaccion'] = promedioSatisfaccion;
    if (serviciosCount != null)
      nuevasMetricas['serviciosCount'] = serviciosCount;
    if (comentariosRecientes != null)
      nuevasMetricas['comentariosRecientes'] = comentariosRecientes;

    return EventoModel(
      id: id,
      eventoId: eventoId,
      nombre: nombre,
      empresa: empresa,
      empresaId: empresaId,
      ubicacion: ubicacion,
      fecha: fecha,
      estado: estado,
      observaciones: observaciones,
      serviciosAsignados: serviciosAsignados,
      fechaCreacion: fechaCreacion,
      esActivo: activo ?? (totalRegistros != null && totalRegistros > 0),
      fechaUltimaActividad: DateTime.now(),
      metricas: nuevasMetricas,
      configuracionPulse: configuracionPulse,
    );
  }

  /// Crea una copia con configuración de Pulse actualizada
  EventoModel copyWithConfigPulse({
    bool? mostrarAnimaciones,
    bool? mostrarIndicadorEnVivo,
    int? limiteComentarios,
    bool? actualizacionTiempoReal,
  }) {
    final nuevaConfig = Map<String, dynamic>.from(configPulse);

    if (mostrarAnimaciones != null)
      nuevaConfig['mostrarAnimaciones'] = mostrarAnimaciones;
    if (mostrarIndicadorEnVivo != null)
      nuevaConfig['mostrarIndicadorEnVivo'] = mostrarIndicadorEnVivo;
    if (limiteComentarios != null)
      nuevaConfig['limiteComentarios'] = limiteComentarios;
    if (actualizacionTiempoReal != null)
      nuevaConfig['actualizacionTiempoReal'] = actualizacionTiempoReal;

    return EventoModel(
      id: id,
      eventoId: eventoId,
      nombre: nombre,
      empresa: empresa,
      empresaId: empresaId,
      ubicacion: ubicacion,
      fecha: fecha,
      estado: estado,
      observaciones: observaciones,
      serviciosAsignados: serviciosAsignados,
      fechaCreacion: fechaCreacion,
      esActivo: esActivo,
      fechaUltimaActividad: fechaUltimaActividad,
      metricas: metricas,
      configuracionPulse: nuevaConfig,
    );
  }
}
