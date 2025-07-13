import 'package:cloud_firestore/cloud_firestore.dart';

class EmpresaModel {
  final String empresaId;
  final String nombre;
  final String rfc;
  final String? razonSocial;

  // ✅ Todos los campos planos como en Firestore
  final String? direccion;
  final String? ciudad;
  final String? colonia;
  final String? codigoPostal;
  final String? alcaldia;

  final List<Map<String, dynamic>> contactos;

  final String contacto;
  final String telefono;
  final String correo;
  final String estado;
  final DateTime fechaCreacion;

  EmpresaModel({
    required this.empresaId,
    required this.nombre,
    required this.rfc,
    this.razonSocial,
    this.direccion,
    this.colonia,
    this.codigoPostal,
    this.ciudad,
    this.alcaldia,
    required this.contactos,
    required this.contacto,
    required this.telefono,
    required this.correo,
    required this.estado,
    required this.fechaCreacion,
  });

  factory EmpresaModel.fromMap(Map<String, dynamic> data, String id) {
    return EmpresaModel(
      empresaId:
          data['empresaId'] ?? id, // 🔐 usa empresaId como fuente principal
      nombre: data['nombre'] ?? '',
      rfc: data['rfc'] ?? '',
      razonSocial: data['razonSocial'],
      direccion: data['direccion'],
      ciudad: data['ciudad'],
      colonia: data['colonia'],
      codigoPostal: data['codigoPostal'],
      alcaldia: data['alcaldia'],
      contactos: (data['contactos'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [],
      contacto: data['contacto'] ?? '',
      telefono: data['telefono'] ?? '',
      correo: data['correo'] ?? '',
      estado: data['estado'] ?? 'activo',
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'empresaId': empresaId,
      'nombre': nombre,
      'rfc': rfc,
      'razonSocial': razonSocial,
      'direccion': direccion,
      'ciudad': ciudad,
      'colonia': colonia,
      'codigoPostal': codigoPostal,
      'alcaldia': alcaldia,
      'contactos': contactos,
      'contacto': contacto,
      'telefono': telefono,
      'correo': correo,
      'estado': estado,
      'fechaCreacion': fechaCreacion,
    };
  }
}
