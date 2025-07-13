import 'package:cloud_firestore/cloud_firestore.dart';

class ConfiguracionGlobalService {
  static Future<void> verificarOCrearConfiguracionGlobal() async {
    final docRef = FirebaseFirestore.instance
        .collection('notificaciones_config')
        .doc('global');

    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'horaEnvio': '08:00',
        'horasAntes': 2,
        'whatsappActivo': true,
        'correoActivo': true,
      });
      print('✅ Documento global creado con valores por defecto');
    } else {
      print('✔️ Documento global ya existe');
    }
  }
}
