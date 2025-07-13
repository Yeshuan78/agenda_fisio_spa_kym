// 📁 services/campana_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/campana_model.dart';

class CampanaService {
  final _firestore = FirebaseFirestore.instance;
  final _collection = 'campanas';

  Future<List<CampanaModel>> getCampanas() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => CampanaModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> crearCampana(CampanaModel campana) async {
    await _firestore
        .collection(_collection)
        .doc(campana.id)
        .set(campana.toMap());
  }

  Future<void> actualizarCampana(CampanaModel campana) async {
    await _firestore
        .collection(_collection)
        .doc(campana.id)
        .update(campana.toMap());
  }

  Future<void> eliminarCampana(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
