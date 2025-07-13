import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/tratamiento_model.dart';

class TratamientoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> crearTratamiento(TratamientoModel tratamiento) async {
    await _db
        .collection('tratamientos')
        .doc(tratamiento.tratamientoId)
        .set(tratamiento.toMap());
  }

  Future<void> actualizarTratamiento(TratamientoModel tratamiento) async {
    await _db
        .collection('tratamientos')
        .doc(tratamiento.tratamientoId)
        .update(tratamiento.toMap());
  }

  Future<void> eliminarTratamiento(String tratamientoId) async {
    await _db.collection('tratamientos').doc(tratamientoId).delete();
  }

  Future<TratamientoModel?> getTratamientoById(String tratamientoId) async {
    final doc = await _db.collection('tratamientos').doc(tratamientoId).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['tratamientoId'] = doc.id;
      return TratamientoModel.fromMap(data);
    }
    return null;
  }

  // ✅ CAMBIO: Obtener todos los tratamientos desde Firestore
  Future<List<TratamientoModel>> getTratamientos() async {
    try {
      final snapshot = await _db.collection('tratamientos').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['tratamientoId'] = doc.id;
        return TratamientoModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error al cargar tratamientos: \$e');
      return [];
    }
  }
}
