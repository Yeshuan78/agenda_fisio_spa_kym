class EspecialidadModel {
  final String id;
  final String nombre;
  final String icono;
  final bool activo;
  final int orden;

  EspecialidadModel({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.activo,
    required this.orden,
  });

  factory EspecialidadModel.fromMap(Map<String, dynamic> map, String id) {
    return EspecialidadModel(
      id: id,
      nombre: map['nombre'] ?? '',
      icono: map['icono'] ?? 'work',
      activo: map['activo'] ?? true,
      orden: map['orden'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'icono': icono,
      'activo': activo,
      'orden': orden,
    };
  }

  EspecialidadModel copyWith({
    String? id,
    String? nombre,
    String? icono,
    bool? activo,
    int? orden,
  }) {
    return EspecialidadModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      icono: icono ?? this.icono,
      activo: activo ?? this.activo,
      orden: orden ?? this.orden,
    );
  }

  @override
  String toString() {
    return 'EspecialidadModel(nombre: $nombre, icono: $icono)';
  }
}
