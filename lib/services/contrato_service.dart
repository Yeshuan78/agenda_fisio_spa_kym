import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/models/contrato_model.dart';

class ContratoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'contratos';

  Future<List<ContratoModel>> getContratos() async {
    try {
      final snapshot = await _firestore.collection(_collectionPath).get();
      return snapshot.docs.map((doc) {
        return ContratoModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> crearContrato(ContratoModel contrato) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(contrato.id)
          .set(contrato.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> actualizarContrato(ContratoModel contrato) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(contrato.id)
          .update(contrato.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminarContrato(String contratoId) async {
    try {
      await _firestore.collection(_collectionPath).doc(contratoId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
