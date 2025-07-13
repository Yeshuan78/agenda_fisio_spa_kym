import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/evento_model.dart';

class EventoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ Nombre corregido
  Future<void> createEvento(EventoModel evento) async {
    final ref = _db.collection('eventos').doc(evento.id);
    await ref.set(evento.toMap());
  }

  // ✅ Nombre corregido
  Future<void> updateEvento(EventoModel evento) async {
    final ref = _db.collection('eventos').doc(evento.id);
    await ref.update(evento.toMap());
  }

  // ✅ Nombre corregido
  Future<void> deleteEvento(String eventoId) async {
    final ref = _db.collection('eventos').doc(eventoId);
    await ref.delete();
  }

  // ✅ Nombre corregido
  Future<List<EventoModel>> getEventos() async {
    final querySnapshot = await _db.collection('eventos').get();
    return querySnapshot.docs.map((doc) {
      return EventoModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Stream<List<EventoModel>> getEventosStream() {
    return _db.collection('eventos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventoModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<EventoModel?> getEventoById(String eventoId) async {
    final doc = await _db.collection('eventos').doc(eventoId).get();
    if (doc.exists) {
      return EventoModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // ✅ CAMBIO BLINDADO: Actualizar horario de una asignación específica
  Future<void> actualizarHorarioAsignado({
    required String eventoId,
    required int index,
    required String nuevaHoraInicio,
    required String nuevaHoraFin,
  }) async {
    final docRef = _db.collection('eventos').doc(eventoId);
    final doc = await docRef.get();

    if (!doc.exists) return;

    final data = doc.data()!;

    // Conversión segura blindada
    final asignaciones = (data['serviciosAsignados'] as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    if (index >= asignaciones.length) return;

    asignaciones[index]['horaInicio'] = nuevaHoraInicio;
    asignaciones[index]['horaFin'] = nuevaHoraFin;

    await docRef.update({'serviciosAsignados': asignaciones});
  }
}
