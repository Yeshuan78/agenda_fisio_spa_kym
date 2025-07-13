class CategoriaModel {
  final String categoriaId;
  final String nombre;
  final String colorHex;
  final String icono;
  final int orden;

  CategoriaModel({
    required this.categoriaId,
    required this.nombre,
    required this.colorHex,
    required this.icono,
    required this.orden,
  });

  factory CategoriaModel.fromMap(Map<String, dynamic> map, String docId) {
    return CategoriaModel(
      categoriaId: docId,
      nombre: map['nombre'] ?? '',
      colorHex: map['colorHex'] ?? '#CCCCCC',
      icono: map['icono'] ?? 'folder',
      orden: int.tryParse(map['orden'].toString()) ?? 0, // ✅ FIX aplicado
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'colorHex': colorHex,
      'icono': icono,
      'orden': orden,
    };
  }
}
