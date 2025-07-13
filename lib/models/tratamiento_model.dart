// 📦 Modelo: TratamientoModel

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

class TratamientoModel {
  final String tratamientoId;
  final String nombre;
  final List<TratamientoSesion> sesiones;
  final double precioTotal;

  TratamientoModel({
    required this.tratamientoId,
    required this.nombre,
    required this.sesiones,
    required this.precioTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'tratamientoId': tratamientoId,
      'nombre': nombre,
      'sesiones': sesiones.map((s) => s.toMap()).toList(),
      'precioTotal': precioTotal,
    };
  }

  factory TratamientoModel.fromMap(Map<String, dynamic> map) {
    return TratamientoModel(
      tratamientoId: map['tratamientoId'],
      nombre: map['nombre'],
      sesiones: (map['sesiones'] as List<dynamic>)
          .map((s) => TratamientoSesion.fromMap(s))
          .toList(),
      precioTotal: safeParseDouble(map['precioTotal']), // ✅ CAMBIO
    );
  }
}

class TratamientoSesion {
  final int numero;
  final String servicioId;
  final String? nombre; // ✅ CAMBIO: ahora opcional
  final String? profesionalId;
  final DateTime? fecha;
  final String estado;

  TratamientoSesion({
    required this.numero,
    required this.servicioId,
    this.nombre, // ✅ CAMBIO: opcional
    this.profesionalId,
    this.fecha,
    this.estado = 'pendiente',
  });

  Map<String, dynamic> toMap() {
    return {
      'numero': numero,
      'servicioId': servicioId,
      if (nombre != null) 'nombre': nombre, // ✅ CAMBIO
      'profesionalId': profesionalId,
      'fecha': fecha?.toIso8601String(),
      'estado': estado,
    };
  }

  factory TratamientoSesion.fromMap(Map<String, dynamic> map) {
    return TratamientoSesion(
      numero: map['numero'],
      servicioId: map['servicioId'],
      nombre: map['nombre'], // ✅ CAMBIO
      profesionalId: map['profesionalId'],
      fecha: map['fecha'] != null ? DateTime.parse(map['fecha']) : null,
      estado: map['estado'] ?? 'pendiente',
    );
  }
}
