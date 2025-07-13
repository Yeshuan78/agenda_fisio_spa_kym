// 📁 models/campana_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CampanaModel {
  final String id;
  final String titulo;
  final String mensaje;
  final String tipo; // whatsapp o correo
  final List<String> destinatarios; // IDs de clientes o emails
  final DateTime fechaCreacion;
  final DateTime? fechaEnvio;
  final String estado; // pendiente, enviado, error

  CampanaModel({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.destinatarios,
    required this.fechaCreacion,
    this.fechaEnvio,
    required this.estado,
  });

  factory CampanaModel.fromMap(Map<String, dynamic> map, String id) {
    return CampanaModel(
      id: id,
      titulo: map['titulo'] ?? '',
      mensaje: map['mensaje'] ?? '',
      tipo: map['tipo'] ?? 'whatsapp',
      destinatarios: List<String>.from(map['destinatarios'] ?? []),
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
      fechaEnvio: map['fechaEnvio'] != null
          ? (map['fechaEnvio'] as Timestamp).toDate()
          : null,
      estado: map['estado'] ?? 'pendiente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'destinatarios': destinatarios,
      'fechaCreacion': fechaCreacion,
      'fechaEnvio': fechaEnvio,
      'estado': estado,
    };
  }
}
