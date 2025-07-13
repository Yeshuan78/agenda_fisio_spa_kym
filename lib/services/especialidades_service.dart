import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/models/especialidad_model.dart';

class EspecialidadesService {
  final _db = FirebaseFirestore.instance;

  Future<List<EspecialidadModel>> getEspecialidadesActivas() async {
    final snap = await _db
        .collection('especialidades')
        .where('activo', isEqualTo: true)
        .orderBy('orden')
        .get();

    return snap.docs
        .map((doc) => EspecialidadModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
