import 'package:cloud_firestore/cloud_firestore.dart';

class NotificacionesLogger {
  static Future<void> logEnvioMensaje({
    required String bookingId,
    required String canal,
    required String clienteNombre,
    required String estado,
    required String mensaje,
    required String tipoUsuario,
    String? correo,
    String? telefono,
  }) async {
    final now = DateTime.now().toIso8601String();

    final logData = {
      'bookingId': bookingId,
      'canal': canal,
      'clienteNombre': clienteNombre,
      'estado': estado,
      'mensaje': mensaje,
      'tipoUsuario': tipoUsuario,
      'fechaEnvio': now,
      if (correo != null) 'correo': correo,
      if (telefono != null) 'telefono': telefono,
    };

    await FirebaseFirestore.instance
        .collection('notificaciones_log')
        .add(logData);

    print('📩 Log registrado en notificaciones_log ✅');
  }
}
