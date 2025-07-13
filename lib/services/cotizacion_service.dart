// 📁 services/cotizacion_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cotizacion_model.dart';

class CotizacionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'cotizaciones';

  Future<List<CotizacionModel>> getCotizaciones() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => CotizacionModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> crearCotizacion(CotizacionModel cotizacion) async {
    await _firestore
        .collection(_collection)
        .doc(cotizacion.id)
        .set(cotizacion.toMap());
  }

  Future<void> actualizarCotizacion(CotizacionModel cotizacion) async {
    await _firestore
        .collection(_collection)
        .doc(cotizacion.id)
        .update(cotizacion.toMap());
  }

  Future<void> eliminarCotizacion(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
