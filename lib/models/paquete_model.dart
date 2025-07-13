// 📦 Modelo: PaqueteModel

// ✅ CAMBIO: función de parseo seguro
double safeParseDouble(dynamic value) {
  try {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final clean = value.replaceAll(",", "");
      return double.tryParse(clean) ?? 0.0;
    }
    return 0.0;
  } catch (e) {
    return 0.0;
  }
}

class PaqueteModel {
  final String paqueteId;
  final String nombre;
  final List<ServicioPaquete> servicios;
  final double precioTotal;
  final int duracionTotal;

  PaqueteModel({
    required this.paqueteId,
    required this.nombre,
    required this.servicios,
    required this.precioTotal,
    required this.duracionTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'paqueteId': paqueteId,
      'nombre': nombre,
      'servicios': servicios.map((s) => s.toMap()).toList(),
      'precioTotal': precioTotal,
      'duracionTotal': duracionTotal,
    };
  }

  factory PaqueteModel.fromMap(Map<String, dynamic> map) {
    return PaqueteModel(
      paqueteId: map['paqueteId'],
      nombre: map['nombre'],
      servicios: (map['servicios'] as List<dynamic>)
          .map((s) => ServicioPaquete.fromMap(s))
          .toList(),
      precioTotal: safeParseDouble(map['precioTotal']), // ✅ CAMBIO
      duracionTotal: map['duracionTotal'],
    );
  }
}

class ServicioPaquete {
  final String servicioId;
  final String? nombre; // ✅ CAMBIO: restaurado como opcional
  int cantidadProfesionales; // ✅ CAMBIO: ahora declarado como campo
  final int duracion;

  ServicioPaquete({
    required this.servicioId,
    this.nombre,
    required this.cantidadProfesionales,
    required this.duracion,
  });

  Map<String, dynamic> toMap() {
    return {
      'servicioId': servicioId,
      if (nombre != null) 'nombre': nombre, // ✅ CAMBIO
      'cantidadProfesionales': cantidadProfesionales,
      'duracion': duracion,
    };
  }

  factory ServicioPaquete.fromMap(Map<String, dynamic> map) {
    return ServicioPaquete(
      servicioId: map['servicioId'],
      nombre: map['nombre'],
      cantidadProfesionales: map['cantidadProfesionales'] ?? 1,
      duracion: map['duracion'] ?? 0,
    );
  }
}
