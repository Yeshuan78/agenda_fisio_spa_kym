// [Sección 1.1] – Imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/models/factura_model.dart';

// [Sección 1.2] – Clase principal
class FacturaService {
  final _ref = FirebaseFirestore.instance.collection('facturas');

  // [Sección 1.3] – Crear nueva factura
  Future<void> crearFactura(FacturaModel factura) async {
    await _ref.doc(factura.id).set(factura.toMap());
  }

  // [Sección 1.4] – Actualizar factura completa
  Future<void> actualizarFactura(FacturaModel factura) async {
    await _ref.doc(factura.id).update(factura.toMap());
  }

  // [Sección 1.5] – Eliminar factura
  Future<void> eliminarFactura(String id) async {
    await _ref.doc(id).delete();
  }

  // [Sección 1.6] – Obtener todas las facturas
  Stream<List<FacturaModel>> obtenerFacturas() {
    return _ref.orderBy('fechaIngreso', descending: true).snapshots().map(
        (snap) => snap.docs
            .map((doc) => FacturaModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // [Sección 1.7] – Obtener por empresa
  Stream<List<FacturaModel>> obtenerFacturasPorEmpresa(String empresaId) {
    return _ref
        .where('empresaId', isEqualTo: empresaId)
        .orderBy('fechaIngreso', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => FacturaModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // [Sección 1.8] – Actualizar estadoPago (usado en Card)
  Future<void> actualizarEstadoPago(String id, String nuevoEstado) async {
    await _ref.doc(id).update({'estadoPago': nuevoEstado});
  }

  // [Sección 1.9] – ✅ Nuevo método: actualizar solo un campo específico de una factura
  Future<void> actualizarCampo(String id, String campo, dynamic valor) async {
    await _ref.doc(id).update({campo: valor});
  }
}
