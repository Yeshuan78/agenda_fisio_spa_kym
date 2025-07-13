// [Sección 1.1] – Modelo KYM Pulse: MasajeModel

import 'package:cloud_firestore/cloud_firestore.dart';

class MasajeModel {
  final String id; // ID del documento en Firestore
  final String profesionalId; // ID del terapeuta que portaba el QR
  final String? eventoId; // Opcional: campaña o jornada a la que pertenece
  final DateTime timestamp; // Fecha y hora exacta del escaneo
  final String? userAgent; // Info del navegador que escaneó
  final String? plataforma; // "web", "android", etc.

  final Map<String, dynamic>? encuesta; // Respuestas rápidas, opcional

  MasajeModel({
    required this.id,
    required this.profesionalId,
    required this.timestamp,
    this.eventoId,
    this.userAgent,
    this.plataforma,
    this.encuesta,
  });

  factory MasajeModel.fromMap(Map<String, dynamic> map, String id) {
    return MasajeModel(
      id: id,
      profesionalId: map['profesionalId'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      eventoId: map['eventoId'],
      userAgent: map['userAgent'],
      plataforma: map['plataforma'],
      encuesta: map['encuesta'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profesionalId': profesionalId,
      'timestamp': Timestamp.fromDate(timestamp),
      'eventoId': eventoId,
      'userAgent': userAgent,
      'plataforma': plataforma,
      'encuesta': encuesta,
    };
  }
}
