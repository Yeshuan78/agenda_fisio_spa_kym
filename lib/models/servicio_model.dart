class ServicioModel {
  final String servicioId;
  final String name;
  final String category;
  final String description;
  final int duration;
  final int price;
  final String tipo;
  final bool activo;
  final int bufferMin;
  final String nivelEnergia;
  final int capacidad;
  final List<String> professionalIds;
  final String image;

  // ✅ Constructor restaurado con todos los campos requeridos
  ServicioModel({
    required String
        serviceId, // Se usa serviceId para compatibilidad con el form
    required this.name,
    required this.category,
    required this.description,
    required this.duration,
    required this.price,
    required this.tipo,
    required this.activo,
    required this.bufferMin,
    required this.nivelEnergia,
    required this.capacidad,
    required this.professionalIds,
    required this.image,
  }) : servicioId = serviceId;

  // ✅ Getter alias para usar tanto serviceId como servicioId
  String get serviceId => servicioId;

  factory ServicioModel.fromMap(Map<String, dynamic> map, String docId) {
    return ServicioModel(
      serviceId: docId,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      duration: int.tryParse(map['duration'].toString()) ?? 0,
      price: int.tryParse(map['price'].toString()) ?? 0,
      tipo: map['tipo'] ?? 'domicilio',
      activo: map['activo'] ?? true,
      bufferMin: int.tryParse(map['bufferMin'].toString()) ?? 0,
      nivelEnergia: map['nivelEnergia'] ?? 'media',
      capacidad: int.tryParse(map['capacidad'].toString()) ?? 1,
      professionalIds: List<String>.from(map['professionalIds'] ?? []),
      image: map['image'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'duration': duration,
      'price': price,
      'tipo': tipo,
      'activo': activo,
      'bufferMin': bufferMin,
      'nivelEnergia': nivelEnergia,
      'capacidad': capacidad,
      'professionalIds': professionalIds,
      'image': image,
    };
  }
}
