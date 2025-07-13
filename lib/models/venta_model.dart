// 📁 models/venta_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class VentaModel {
  final String id;
  final String clienteId;
  final String descripcion;
  final double monto;
  final DateTime fecha;
  final String metodoPago;

  VentaModel({
    required this.id,
    required this.clienteId,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.metodoPago,
  });

  factory VentaModel.fromMap(Map<String, dynamic> map, String id) {
    return VentaModel(
      id: id,
      clienteId: map['clienteId'] ?? '',
      descripcion: map['descripcion'] ?? '',
      monto: (map['monto'] as num?)?.toDouble() ?? 0.0,
      fecha: (map['fecha'] as Timestamp).toDate(),
      metodoPago: map['metodoPago'] ?? 'efectivo',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'descripcion': descripcion,
      'monto': monto,
      'fecha': Timestamp.fromDate(fecha),
      'metodoPago': metodoPago,
    };
  }
}
