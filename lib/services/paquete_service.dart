import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/paquete_model.dart';

class PaqueteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> crearPaquete(PaqueteModel paquete) async {
    await _db
        .collection('paquetes')
        .doc(paquete.paqueteId)
        .set(paquete.toMap());
  }

  Future<void> actualizarPaquete(PaqueteModel paquete) async {
    await _db
        .collection('paquetes')
        .doc(paquete.paqueteId)
        .update(paquete.toMap());
  }

  Future<void> eliminarPaquete(String paqueteId) async {
    await _db.collection('paquetes').doc(paqueteId).delete();
  }

  Future<PaqueteModel?> getPaqueteById(String paqueteId) async {
    final doc = await _db.collection('paquetes').doc(paqueteId).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['paqueteId'] = doc.id;
      return PaqueteModel.fromMap(data);
    }
    return null;
  }

  // ✅ CAMBIO: Obtener todos los paquetes desde Firestore
  Future<List<PaqueteModel>> getPaquetes() async {
    try {
      final snapshot = await _db.collection('paquetes').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['paqueteId'] = doc.id;
        return PaqueteModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error al cargar paquetes: \$e');
      return [];
    }
  }
}
