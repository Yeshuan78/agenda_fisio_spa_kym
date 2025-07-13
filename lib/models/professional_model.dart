class ProfessionalModel {
  final String id;
  final String professionalId; // ✅ NUEVO CAMPO
  final String nombre;
  final String apellidos;
  final String sexo;
  final String cedulaProfesional;
  final String email;
  final String telefono;
  final String fotoUrl;
  final String notas;
  final List<String> especialidades;
  final List<String> idiomas;
  final String sucursalId;
  final List<Map<String, dynamic>> horarios;
  final List<Map<String, dynamic>> disponibilidad;
  final List<Map<String, dynamic>> servicios;
  final bool estado;
  final DateTime fechaAlta;

  ProfessionalModel({
    required this.id,
    required this.professionalId, // ✅ nuevo en constructor
    required this.nombre,
    required this.apellidos,
    required this.sexo,
    required this.cedulaProfesional,
    required this.email,
    required this.telefono,
    required this.fotoUrl,
    required this.notas,
    required this.especialidades,
    required this.idiomas,
    required this.sucursalId,
    required this.horarios,
    required this.disponibilidad,
    required this.servicios,
    required this.estado,
    required this.fechaAlta,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    final rawServicios = json['servicios'] as List? ?? [];

    final parsedServicios = rawServicios.map<Map<String, dynamic>>((item) {
      if (item is Map<String, dynamic>) {
        return {
          'category': item['category'] ?? 'Sin categoría',
          'name': item['name'] ?? '',
          'serviceId': item['serviceId'] ?? '',
          'duracion': item['duracion'] ?? '',
          'notas': item['notas'] ?? '',
        };
      } else if (item is String && item.contains('|')) {
        final parts = item.split('|');
        return {
          'category': parts[0].trim(),
          'name': parts[1].trim(),
          'serviceId': item,
          'duracion': '',
          'notas': '',
        };
      } else if (item is String) {
        return {
          'category': 'Sin categoría',
          'name': item.trim(),
          'serviceId': item,
          'duracion': '',
          'notas': '',
        };
      }
      return {};
    }).toList();

    return ProfessionalModel(
      id: json['id'] ?? '',
      professionalId: json['professionalId'] ?? json['id'] ?? '', // ✅ fallback
      nombre: json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      sexo: json['sexo'] ?? '',
      cedulaProfesional: json['cedulaProfesional'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      fotoUrl: json['fotoUrl'] ?? '',
      notas: json['notas'] ?? '',
      especialidades: List<String>.from(json['especialidades'] ?? []),
      idiomas: List<String>.from(json['idiomas'] ?? []),
      sucursalId: json['sucursalId'] ?? '',
      horarios: List<Map<String, dynamic>>.from(json['horarios'] ?? []),
      disponibilidad:
          List<Map<String, dynamic>>.from(json['disponibilidad'] ?? []),
      servicios: parsedServicios,
      estado: json['estado'] ?? true,
      fechaAlta: DateTime.tryParse(json['fechaAlta'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professionalId': professionalId, // ✅ agregado al mapa
      'nombre': nombre,
      'apellidos': apellidos,
      'sexo': sexo,
      'cedulaProfesional': cedulaProfesional,
      'email': email,
      'telefono': telefono,
      'fotoUrl': fotoUrl,
      'notas': notas,
      'especialidades': especialidades,
      'idiomas': idiomas,
      'sucursalId': sucursalId,
      'horarios': horarios,
      'disponibilidad': disponibilidad,
      'servicios': servicios
          .map((s) => {
                'category': s['category'] ?? 'Sin categoría',
                'name': s['name'] ?? '',
                'serviceId': s['serviceId'] ?? '',
                'duracion': s['duracion'] ?? '',
                'notas': s['notas'] ?? '',
              })
          .toList(),
      'estado': estado,
      'fechaAlta': fechaAlta.toIso8601String(),
    };
  }
}
