import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/models/servicio_model.dart';

class ServicioService {
  final _serviciosRef = FirebaseFirestore.instance.collection('services');

  Future<void> crearServicio(ServicioModel servicio) async {
    try {
      final id = servicio.serviceId.isNotEmpty
          ? servicio.serviceId
          : _serviciosRef.doc().id;

      final data = servicio.toMap();
      data['serviceId'] = id;

      await _serviciosRef.doc(id).set(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ServicioModel>> getServicios() async {
    final snapshot = await _serviciosRef.get();
    return snapshot.docs
        .map((doc) => ServicioModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateServicio(ServicioModel servicio) async {
    if (servicio.serviceId.isEmpty) return;
    await _serviciosRef.doc(servicio.serviceId).update(servicio.toMap());
  }

  Future<void> deleteServicio(String serviceId) async {
    await _serviciosRef.doc(serviceId).delete();
  }
}
