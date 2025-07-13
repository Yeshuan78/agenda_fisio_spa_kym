import 'package:cloud_firestore/cloud_firestore.dart';

class SincronizacionClienteService {
  static Future<void> actualizarDatosClienteEnCitas({
    required String correoAnterior,
    required Map<String, dynamic> nuevosDatos,
  }) async {
    final now = DateTime.now().toIso8601String();

    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('clientEmail', isEqualTo: correoAnterior)
        .where('date', isGreaterThanOrEqualTo: now)
        .get();

    for (final doc in snapshot.docs) {
      final updateData = {
        if (nuevosDatos.containsKey('nombre'))
          'clientName': nuevosDatos['nombre'],
        if (nuevosDatos.containsKey('correo'))
          'clientEmail': nuevosDatos['correo'],
        if (nuevosDatos.containsKey('telefono'))
          'clientPhone': nuevosDatos['telefono'],
        if (nuevosDatos.containsKey('empresa'))
          'clientEmpresa': nuevosDatos['empresa'],
      };

      await doc.reference.update(updateData);
    }

    print(
        '🔄 ${snapshot.docs.length} citas actualizadas con los nuevos datos del cliente');
  }
}
