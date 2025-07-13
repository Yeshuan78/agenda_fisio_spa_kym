// [Sección 1.1] – Modelo para servicios registrados vía QR

import 'package:cloud_firestore/cloud_firestore.dart';

class ServicioRealizadoModel {
  final String id;
  final String profesionalId;
  final String servicioId;
  final String eventoId;
  final String profesionalNombre;
  final String servicioNombre;
  final String numeroEmpleado;
  final String comentario;
  final DateTime timestamp;
  final DateTime fecha;
  final Map<String, dynamic>? encuesta;
  final String? userAgent;
  final String? plataforma;

  ServicioRealizadoModel({
    required this.id,
    required this.profesionalId,
    required this.servicioId,
    required this.eventoId,
    required this.profesionalNombre,
    required this.servicioNombre,
    required this.numeroEmpleado,
    required this.comentario,
    required this.timestamp,
    required this.fecha,
    this.encuesta,
    this.userAgent,
    this.plataforma,
  });

  // [Sección 1.2] – Convertir desde Firestore (con protección de timestamp)
  factory ServicioRealizadoModel.fromMap(Map<String, dynamic> map, String id) {
    final rawTimestamp = map['timestamp'];
    DateTime timestampParsed = DateTime.now();

    if (rawTimestamp is Timestamp) {
      timestampParsed = rawTimestamp.toDate();
    }

    final rawFecha = map['fecha'];
    DateTime fechaParsed = DateTime.now();

    if (rawFecha is Timestamp) {
      fechaParsed = rawFecha.toDate();
    }

    return ServicioRealizadoModel(
      id: id,
      profesionalId: map['profesionalId'] ?? '',
      servicioId: map['servicioId'] ?? '',
      eventoId: map['eventoId'] ?? '',
      profesionalNombre: map['profesionalNombre'] ?? '',
      servicioNombre: map['servicioNombre'] ?? '',
      numeroEmpleado: map['numeroEmpleado'] ?? '',
      comentario: map['comentario'] ?? '',
      timestamp: timestampParsed,
      fecha: fechaParsed,
      encuesta: map['encuesta'],
      userAgent: map['userAgent'],
      plataforma: map['plataforma'],
    );
  }

  // [Sección 1.3] – Convertir a Firestore
  Map<String, dynamic> toMap() {
    return {
      'profesionalId': profesionalId,
      'servicioId': servicioId,
      'eventoId': eventoId,
      'profesionalNombre': profesionalNombre,
      'servicioNombre': servicioNombre,
      'numeroEmpleado': numeroEmpleado,
      'comentario': comentario,
      'timestamp': Timestamp.fromDate(timestamp),
      'fecha': Timestamp.fromDate(fecha),
      'encuesta': encuesta,
      'userAgent': userAgent,
      'plataforma': plataforma,
    };
  }
}
