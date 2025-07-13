
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/categoria_model.dart';

class CategoriaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'categorias_servicio';

  Future<List<CategoriaModel>> getCategorias() async {
    final snapshot = await _db.collection(_collection).orderBy('orden').get();
    return snapshot.docs
        .map((doc) => CategoriaModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> crearCategoria(CategoriaModel categoria) async {
    await _db.collection(_collection).add(categoria.toMap());
  }

  Future<void> actualizarCategoria(String id, CategoriaModel categoria) async {
    await _db.collection(_collection).doc(id).update(categoria.toMap());
  }

  Future<void> eliminarCategoria(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
