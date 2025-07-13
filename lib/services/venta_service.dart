// 📁 services/venta_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/venta_model.dart';

class VentaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'ventas';

  Future<List<VentaModel>> getVentas() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => VentaModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> crearVenta(VentaModel venta) async {
    await _firestore.collection(_collection).doc(venta.id).set(venta.toMap());
  }

  Future<void> actualizarVenta(VentaModel venta) async {
    await _firestore
        .collection(_collection)
        .doc(venta.id)
        .update(venta.toMap());
  }

  Future<void> eliminarVenta(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
