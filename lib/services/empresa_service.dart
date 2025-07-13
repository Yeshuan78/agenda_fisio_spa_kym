import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/empresa_model.dart';

class EmpresaService {
  final _db = FirebaseFirestore.instance;

  Future<List<EmpresaModel>> getEmpresas() async {
    final snapshot = await _db.collection('empresas').orderBy('nombre').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return EmpresaModel.fromMap(data, doc.id);
    }).toList();
  }

  Future<void> crearEmpresa(EmpresaModel empresa) async {
    final ref = _db.collection('empresas').doc(empresa.empresaId);
    await ref.set(empresa.toMap());
  }

  Future<void> updateEmpresa(EmpresaModel empresa) async {
    final ref = _db.collection('empresas').doc(empresa.empresaId);
    await ref.update(empresa.toMap());
  }

  // ✅ CORREGIDO: nombre sincronizado con empresas_screen.dart
  Future<void> deleteEmpresa(String empresaId) async {
    await _db.collection('empresas').doc(empresaId).delete();
  }

  Future<EmpresaModel?> getEmpresaById(String empresaId) async {
    final doc = await _db.collection('empresas').doc(empresaId).get();
    if (!doc.exists) return null;
    return EmpresaModel.fromMap(doc.data()!, doc.id);
  }
}
