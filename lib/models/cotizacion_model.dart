// 📁 models/cotizacion_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CotizacionModel {
  final String id;
  final String empresaId;
  final String clienteId;
  final double montoPropuesto;
  final String estado; // pendiente, aceptada, rechazada
  final DateTime fechaEmision;
  final String observaciones;

  CotizacionModel({
    required this.id,
    required this.empresaId,
    required this.clienteId,
    required this.montoPropuesto,
    required this.estado,
    required this.fechaEmision,
    required this.observaciones,
  });

  factory CotizacionModel.fromMap(Map<String, dynamic> map, String id) {
    return CotizacionModel(
      id: id,
      empresaId: map['empresaId'] ?? '',
      clienteId: map['clienteId'] ?? '',
      montoPropuesto: (map['montoPropuesto'] as num?)?.toDouble() ?? 0.0,
      estado: map['estado'] ?? 'pendiente',
      fechaEmision: (map['fechaEmision'] as Timestamp).toDate(),
      observaciones: map['observaciones'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'empresaId': empresaId,
      'clienteId': clienteId,
      'montoPropuesto': montoPropuesto,
      'estado': estado,
      'fechaEmision': Timestamp.fromDate(fechaEmision),
      'observaciones': observaciones,
    };
  }
}
