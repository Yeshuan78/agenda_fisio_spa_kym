// [Sección 2.1] – Modelo de resumen de masajes por evento

import 'package:cloud_firestore/cloud_firestore.dart';

class MasajeResumenModel {
  final String id;
  final String eventoId;
  final String profesionalId;
  final DateTime fecha;
  final int total;
  final double promedioSatisfaccion;
  final double promedioComodidad;
  final double porcentajeDuracionOk;

  MasajeResumenModel({
    required this.id,
    required this.eventoId,
    required this.profesionalId,
    required this.fecha,
    required this.total,
    required this.promedioSatisfaccion,
    required this.promedioComodidad,
    required this.porcentajeDuracionOk,
  });

  factory MasajeResumenModel.fromMap(Map<String, dynamic> map, String id) {
    return MasajeResumenModel(
      id: id,
      eventoId: map['eventoId'],
      profesionalId: map['profesionalId'],
      fecha: (map['fecha'] as Timestamp).toDate(),
      total: map['total'],
      promedioSatisfaccion: (map['promedioSatisfaccion'] as num).toDouble(),
      promedioComodidad: (map['promedioComodidad'] as num).toDouble(),
      porcentajeDuracionOk: (map['porcentajeDuracionOk'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventoId': eventoId,
      'profesionalId': profesionalId,
      'fecha': Timestamp.fromDate(fecha),
      'total': total,
      'promedioSatisfaccion': promedioSatisfaccion,
      'promedioComodidad': promedioComodidad,
      'porcentajeDuracionOk': porcentajeDuracionOk,
    };
  }
}
