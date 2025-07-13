import 'package:cloud_firestore/cloud_firestore.dart';

class ContratoModel {
  final String id;
  final String empresaId;
  final String clienteId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double montoTotal;
  final String estado; // activo, vencido, cancelado
  final String descripcion;
  final DateTime fechaCreacion;

  ContratoModel({
    required this.id,
    required this.empresaId,
    required this.clienteId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.montoTotal,
    required this.estado,
    required this.descripcion,
    required this.fechaCreacion,
  });

  factory ContratoModel.fromMap(Map<String, dynamic> map, String id) {
    return ContratoModel(
      id: id,
      empresaId: map['empresaId'] ?? '',
      clienteId: map['clienteId'] ?? '',
      fechaInicio:
          (map['fechaInicio'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaFin: (map['fechaFin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      montoTotal: (map['montoTotal'] as num?)?.toDouble() ?? 0.0,
      estado: map['estado'] ?? 'activo',
      descripcion: map['descripcion'] ?? '',
      fechaCreacion:
          (map['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'empresaId': empresaId,
      'clienteId': clienteId,
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFin': Timestamp.fromDate(fechaFin),
      'montoTotal': montoTotal,
      'estado': estado,
      'descripcion': descripcion,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  ContratoModel copyWith({
    String? id,
    String? empresaId,
    String? clienteId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    double? montoTotal,
    String? estado,
    String? descripcion,
    DateTime? fechaCreacion,
  }) {
    return ContratoModel(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      clienteId: clienteId ?? this.clienteId,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      montoTotal: montoTotal ?? this.montoTotal,
      estado: estado ?? this.estado,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return 'ContratoModel(id: $id, empresaId: $empresaId, clienteId: $clienteId, fechaInicio: $fechaInicio, fechaFin: $fechaFin, montoTotal: $montoTotal, estado: $estado, descripcion: $descripcion, fechaCreacion: $fechaCreacion)';
  }
}
