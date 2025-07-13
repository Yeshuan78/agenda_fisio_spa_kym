// [Sección 1.1] logger_service.dart – Registro centralizado de logs del sistema

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoggerService {
  /// Registra una acción en la colección `profesionales_logs` en Firestore
  static Future<void> registrarLogProfesional({
    required String idProfesional,
    required String accion, // 'creado', 'actualizado', etc.
    required Map<String, dynamic> datos,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('profesionales_logs').add({
        'idProfesional': idProfesional,
        'accion': accion,
        'timestamp': FieldValue.serverTimestamp(),
        'datos': datos,
        'modificadoPor': {
          'email': user?.email ?? 'desconocido',
          'uid': user?.uid ?? 'anonimo',
        },
      });
    } catch (e) {
      // En producción puedes registrar esto en un sistema externo o consola
      print('Error al registrar log del profesional: $e');
    }
  }
}
