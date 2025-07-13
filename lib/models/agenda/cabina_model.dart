import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 🏢 MODELO ESPECIALIZADO DE CABINAS
/// Gestiona recursos físicos, equipamiento y disponibilidad
class CabinaModel {
  final String cabinaId;
  final String nombre;
  final String? descripcion;
  final CabinaTipo tipo;
  final CabinaEstado estado;
  final int capacidad;
  final double area; // En metros cuadrados
  final String? ubicacion; // Piso, edificio, etc.

  // ✅ EQUIPAMIENTO Y CARACTERÍSTICAS
  final List<String> equipamiento;
  final List<String> caracteristicas;
  final List<String> serviciosPermitidos;
  final Map<String, dynamic>? especificacionesTecnicas;

  // ✅ CONFIGURACIÓN OPERATIVA
  final double tarifaPorHora;
  final double tarifaDiaria;
  final bool requiereAprobacion;
  final bool permiteSobrelapamiento;
  final int tiempoLimpieza; // Minutos entre citas
  final int tiempoPreparacion; // Minutos antes de cada cita

  // ✅ HORARIOS Y DISPONIBILIDAD
  final Map<String, dynamic>? horariosOperativos;
  final List<DateTime> fechasNoDisponibles;
  final DateTime? proximoMantenimiento;
  final List<String> usuariosAutorizados;

  // ✅ METADATOS Y GESTIÓN
  final String? imagenUrl;
  final List<String> imagenesAdicionales;
  final String? responsable; // ID del encargado
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final Map<String, dynamic>? configuracionPersonalizada;
  final bool isActive;

  // ✅ CAMPOS CALCULADOS (NO PERSISTIDOS)
  final int citasHoy;
  final double porcentajeOcupacion;
  final DateTime? proximaCitaDisponible;
  final bool requiereMantenimiento;

  CabinaModel({
    required this.cabinaId,
    required this.nombre,
    this.descripcion,
    this.tipo = CabinaTipo.standard,
    this.estado = CabinaEstado.disponible,
    this.capacidad = 1,
    this.area = 0.0,
    this.ubicacion,
    this.equipamiento = const [],
    this.caracteristicas = const [],
    this.serviciosPermitidos = const [],
    this.especificacionesTecnicas,
    this.tarifaPorHora = 0.0,
    this.tarifaDiaria = 0.0,
    this.requiereAprobacion = false,
    this.permiteSobrelapamiento = false,
    this.tiempoLimpieza = 15,
    this.tiempoPreparacion = 5,
    this.horariosOperativos,
    this.fechasNoDisponibles = const [],
    this.proximoMantenimiento,
    this.usuariosAutorizados = const [],
    this.imagenUrl,
    this.imagenesAdicionales = const [],
    this.responsable,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.configuracionPersonalizada,
    this.isActive = true,
    this.citasHoy = 0,
    this.porcentajeOcupacion = 0.0,
    this.proximaCitaDisponible,
    this.requiereMantenimiento = false,
  });

  /// 🏗️ FACTORY DESDE FIRESTORE
  factory CabinaModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CabinaModel.fromMap(data, doc.id);
  }

  factory CabinaModel.fromMap(Map<String, dynamic> data, String id) {
    return CabinaModel(
      cabinaId: id,
      nombre: data['nombre'] ?? 'Cabina $id',
      descripcion: data['descripcion'],
      tipo: _parseCabinaTipo(data['tipo']),
      estado: _parseCabinaEstado(data['estado']),
      capacidad: data['capacidad'] ?? 1,
      area: (data['area'] ?? 0.0).toDouble(),
      ubicacion: data['ubicacion'],
      equipamiento: List<String>.from(data['equipamiento'] ?? []),
      caracteristicas: List<String>.from(data['caracteristicas'] ?? []),
      serviciosPermitidos: List<String>.from(data['serviciosPermitidos'] ?? []),
      especificacionesTecnicas: data['especificacionesTecnicas'],
      tarifaPorHora: (data['tarifaPorHora'] ?? 0.0).toDouble(),
      tarifaDiaria: (data['tarifaDiaria'] ?? 0.0).toDouble(),
      requiereAprobacion: data['requiereAprobacion'] ?? false,
      permiteSobrelapamiento: data['permiteSobrelapamiento'] ?? false,
      tiempoLimpieza: data['tiempoLimpieza'] ?? 15,
      tiempoPreparacion: data['tiempoPreparacion'] ?? 5,
      horariosOperativos: data['horariosOperativos'],
      fechasNoDisponibles: _parseDateTimeList(data['fechasNoDisponibles']),
      proximoMantenimiento: _parseDateTime(data['proximoMantenimiento']),
      usuariosAutorizados: List<String>.from(data['usuariosAutorizados'] ?? []),
      imagenUrl: data['imagenUrl'],
      imagenesAdicionales: List<String>.from(data['imagenesAdicionales'] ?? []),
      responsable: data['responsable'],
      fechaCreacion: _parseDateTime(data['fechaCreacion']) ?? DateTime.now(),
      fechaActualizacion: _parseDateTime(data['fechaActualizacion']),
      configuracionPersonalizada: data['configuracionPersonalizada'],
      isActive: data['isActive'] ?? true,
    );
  }

  /// 💾 CONVERSIÓN A MAP PARA FIRESTORE
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nombre': nombre,
      'descripcion': descripcion,
      'tipo': tipo.name,
      'estado': estado.name,
      'capacidad': capacidad,
      'area': area,
      'ubicacion': ubicacion,
      'equipamiento': equipamiento,
      'caracteristicas': caracteristicas,
      'serviciosPermitidos': serviciosPermitidos,
      'especificacionesTecnicas': especificacionesTecnicas,
      'tarifaPorHora': tarifaPorHora,
      'tarifaDiaria': tarifaDiaria,
      'requiereAprobacion': requiereAprobacion,
      'permiteSobrelapamiento': permiteSobrelapamiento,
      'tiempoLimpieza': tiempoLimpieza,
      'tiempoPreparacion': tiempoPreparacion,
      'horariosOperativos': horariosOperativos,
      'fechasNoDisponibles':
          fechasNoDisponibles.map((d) => Timestamp.fromDate(d)).toList(),
      'proximoMantenimiento': proximoMantenimiento != null
          ? Timestamp.fromDate(proximoMantenimiento!)
          : null,
      'usuariosAutorizados': usuariosAutorizados,
      'imagenUrl': imagenUrl,
      'imagenesAdicionales': imagenesAdicionales,
      'responsable': responsable,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaActualizacion': fechaActualizacion != null
          ? Timestamp.fromDate(fechaActualizacion!)
          : null,
      'configuracionPersonalizada': configuracionPersonalizada,
      'isActive': isActive,
    };

    // Remover campos null
    map.removeWhere((key, value) => value == null);
    return map;
  }

  /// 🎨 GETTERS PARA UI
  String get displayName => nombre;

  String get tipoDisplayName => tipo.displayName;

  String get estadoDisplayName => estado.displayName;

  Color get tipoColor {
    switch (tipo) {
      case CabinaTipo.vip:
        return Colors.purple.shade600;
      case CabinaTipo.premium:
        return Colors.orange.shade600;
      case CabinaTipo.standard:
        return Colors.blue.shade600;
      case CabinaTipo.grupal:
        return Colors.green.shade600;
      case CabinaTipo.terapeutica:
        return Colors.teal.shade600;
      case CabinaTipo.consultorio:
        return Colors.indigo.shade600;
      case CabinaTipo.spa:
        return Colors.pink.shade600;
    }
  }

  Color get estadoColor {
    switch (estado) {
      case CabinaEstado.disponible:
        return Colors.green.shade600;
      case CabinaEstado.ocupada:
        return Colors.orange.shade600;
      case CabinaEstado.mantenimiento:
        return Colors.red.shade600;
      case CabinaEstado.limpieza:
        return Colors.blue.shade600;
      case CabinaEstado.reservada:
        return Colors.purple.shade600;
      case CabinaEstado.fuera_servicio:
        return Colors.grey.shade600;
    }
  }

  IconData get tipoIcon {
    switch (tipo) {
      case CabinaTipo.vip:
        return Icons.star;
      case CabinaTipo.premium:
        return Icons.diamond;
      case CabinaTipo.standard:
        return Icons.room;
      case CabinaTipo.grupal:
        return Icons.groups;
      case CabinaTipo.terapeutica:
        return Icons.healing;
      case CabinaTipo.consultorio:
        return Icons.medical_services;
      case CabinaTipo.spa:
        return Icons.spa;
    }
  }

  String get capacidadText {
    return capacidad == 1 ? '1 persona' : '$capacidad personas';
  }

  String get areaText {
    return area > 0 ? '${area.toStringAsFixed(1)} m²' : 'Área no especificada';
  }

  String get tarifaFormatted {
    if (tarifaPorHora > 0) {
      return '\$${tarifaPorHora.toStringAsFixed(0)}/hora';
    } else if (tarifaDiaria > 0) {
      return '\$${tarifaDiaria.toStringAsFixed(0)}/día';
    }
    return 'Tarifa no especificada';
  }

  String get proximoMantenimientoFormatted {
    if (proximoMantenimiento == null) return 'No programado';
    return DateFormat('dd/MM/yyyy').format(proximoMantenimiento!);
  }

  /// 🔍 MÉTODOS DE VALIDACIÓN Y CONSULTA
  bool get isDisponible => isActive && estado == CabinaEstado.disponible;

  bool get puedeRecibirCitas => isDisponible && !requiereMantenimientoUrgente;

  bool get requiereMantenimientoUrgente {
    if (proximoMantenimiento == null) return false;
    final diasRestantes =
        proximoMantenimiento!.difference(DateTime.now()).inDays;
    return diasRestantes <= 7; // Alerta si queda menos de una semana
  }

  bool puedeProveerServicio(String servicioId) {
    return puedeRecibirCitas &&
        (serviciosPermitidos.isEmpty ||
            serviciosPermitidos.contains(servicioId));
  }

  bool tieneEquipamiento(String equipo) {
    return equipamiento.contains(equipo);
  }

  bool tieneCaracteristica(String caracteristica) {
    return caracteristicas.contains(caracteristica);
  }

  bool usuarioAutorizado(String usuarioId) {
    return usuariosAutorizados.isEmpty ||
        usuariosAutorizados.contains(usuarioId);
  }

  bool estaDisponibleEnFecha(DateTime fecha) {
    if (!isActive) return false;
    if (fechasNoDisponibles.any((d) => _isSameDate(d, fecha))) return false;

    // Verificar horarios operativos
    if (horariosOperativos != null) {
      final dayName = _getDayName(fecha);
      final dayConfig = horariosOperativos![dayName];
      return dayConfig != null && dayConfig['disponible'] == true;
    }

    return true;
  }

  /// 📅 MÉTODOS DE HORARIOS
  List<TimeOfDay> getHorariosDisponibles(DateTime fecha) {
    if (!estaDisponibleEnFecha(fecha)) return [];

    final horarios = <TimeOfDay>[];

    if (horariosOperativos != null) {
      final dayName = _getDayName(fecha);
      final dayConfig = horariosOperativos![dayName];

      if (dayConfig != null) {
        final inicio = _parseTimeOfDay(dayConfig['inicio']);
        final fin = _parseTimeOfDay(dayConfig['fin']);

        // Generar slots cada 30 minutos
        TimeOfDay current = inicio;
        while (_timeOfDayInMinutes(current) < _timeOfDayInMinutes(fin)) {
          horarios.add(current);
          current = _addMinutesToTimeOfDay(current, 30);
        }
      }
    }

    return horarios;
  }

  Duration getTiempoTotalRequerido(Duration duracionServicio) {
    return Duration(
      minutes: tiempoPreparacion + duracionServicio.inMinutes + tiempoLimpieza,
    );
  }

  /// 📊 MÉTODOS DE ESTADÍSTICAS
  double calcularPorcentajeOcupacion(List<dynamic> citasDelDia) {
    if (citasDelDia.isEmpty) return 0.0;

    final horasDisponibles = 8; // 8 horas por día típico
    final horasOcupadas =
        citasDelDia.length * 1; // Asumiendo 1 hora por cita promedio

    return (horasOcupadas / horasDisponibles) * 100;
  }

  Map<String, dynamic> getEstadisticasUso() {
    return {
      'citasHoy': citasHoy,
      'porcentajeOcupacion': porcentajeOcupacion,
      'tiempoLimpiezaTotal': citasHoy * tiempoLimpieza,
      'requiereMantenimiento': requiereMantenimientoUrgente,
      'proximoMantenimiento': proximoMantenimientoFormatted,
    };
  }

  /// 🔄 MÉTODOS DE MODIFICACIÓN
  CabinaModel copyWith({
    String? cabinaId,
    String? nombre,
    String? descripcion,
    CabinaTipo? tipo,
    CabinaEstado? estado,
    int? capacidad,
    double? area,
    String? ubicacion,
    List<String>? equipamiento,
    List<String>? caracteristicas,
    List<String>? serviciosPermitidos,
    Map<String, dynamic>? especificacionesTecnicas,
    double? tarifaPorHora,
    double? tarifaDiaria,
    bool? requiereAprobacion,
    bool? permiteSobrelapamiento,
    int? tiempoLimpieza,
    int? tiempoPreparacion,
    Map<String, dynamic>? horariosOperativos,
    List<DateTime>? fechasNoDisponibles,
    DateTime? proximoMantenimiento,
    List<String>? usuariosAutorizados,
    String? imagenUrl,
    List<String>? imagenesAdicionales,
    String? responsable,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    Map<String, dynamic>? configuracionPersonalizada,
    bool? isActive,
    int? citasHoy,
    double? porcentajeOcupacion,
    DateTime? proximaCitaDisponible,
    bool? requiereMantenimiento,
  }) {
    return CabinaModel(
      cabinaId: cabinaId ?? this.cabinaId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      capacidad: capacidad ?? this.capacidad,
      area: area ?? this.area,
      ubicacion: ubicacion ?? this.ubicacion,
      equipamiento: equipamiento ?? this.equipamiento,
      caracteristicas: caracteristicas ?? this.caracteristicas,
      serviciosPermitidos: serviciosPermitidos ?? this.serviciosPermitidos,
      especificacionesTecnicas:
          especificacionesTecnicas ?? this.especificacionesTecnicas,
      tarifaPorHora: tarifaPorHora ?? this.tarifaPorHora,
      tarifaDiaria: tarifaDiaria ?? this.tarifaDiaria,
      requiereAprobacion: requiereAprobacion ?? this.requiereAprobacion,
      permiteSobrelapamiento:
          permiteSobrelapamiento ?? this.permiteSobrelapamiento,
      tiempoLimpieza: tiempoLimpieza ?? this.tiempoLimpieza,
      tiempoPreparacion: tiempoPreparacion ?? this.tiempoPreparacion,
      horariosOperativos: horariosOperativos ?? this.horariosOperativos,
      fechasNoDisponibles: fechasNoDisponibles ?? this.fechasNoDisponibles,
      proximoMantenimiento: proximoMantenimiento ?? this.proximoMantenimiento,
      usuariosAutorizados: usuariosAutorizados ?? this.usuariosAutorizados,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      imagenesAdicionales: imagenesAdicionales ?? this.imagenesAdicionales,
      responsable: responsable ?? this.responsable,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? DateTime.now(),
      configuracionPersonalizada:
          configuracionPersonalizada ?? this.configuracionPersonalizada,
      isActive: isActive ?? this.isActive,
      citasHoy: citasHoy ?? this.citasHoy,
      porcentajeOcupacion: porcentajeOcupacion ?? this.porcentajeOcupacion,
      proximaCitaDisponible:
          proximaCitaDisponible ?? this.proximaCitaDisponible,
      requiereMantenimiento:
          requiereMantenimiento ?? this.requiereMantenimiento,
    );
  }

  CabinaModel agregarEquipamiento(String equipo) {
    final newEquipamiento = List<String>.from(equipamiento);
    if (!newEquipamiento.contains(equipo)) {
      newEquipamiento.add(equipo);
    }
    return copyWith(equipamiento: newEquipamiento);
  }

  CabinaModel removerEquipamiento(String equipo) {
    final newEquipamiento = equipamiento.where((e) => e != equipo).toList();
    return copyWith(equipamiento: newEquipamiento);
  }

  CabinaModel cambiarEstado(CabinaEstado nuevoEstado) {
    return copyWith(estado: nuevoEstado, fechaActualizacion: DateTime.now());
  }

  CabinaModel programarMantenimiento(DateTime fecha) {
    return copyWith(proximoMantenimiento: fecha);
  }

  /// 🔧 MÉTODOS HELPER ESTÁTICOS
  static CabinaTipo _parseCabinaTipo(dynamic tipo) {
    return CabinaTipo.values.firstWhere(
      (t) => t.name == tipo,
      orElse: () => CabinaTipo.standard,
    );
  }

  static CabinaEstado _parseCabinaEstado(dynamic estado) {
    return CabinaEstado.values.firstWhere(
      (e) => e.name == estado,
      orElse: () => CabinaEstado.disponible,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static List<DateTime> _parseDateTimeList(dynamic list) {
    if (list is! List) return [];
    return list
        .map((item) => _parseDateTime(item))
        .where((date) => date != null)
        .cast<DateTime>()
        .toList();
  }

  static TimeOfDay _parseTimeOfDay(dynamic timeData) {
    if (timeData is Map<String, dynamic>) {
      return TimeOfDay(
        hour: timeData['hour'] ?? 9,
        minute: timeData['minute'] ?? 0,
      );
    }
    if (timeData is String) {
      final parts = timeData.split(':');
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 9,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      );
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getDayName(DateTime date) {
    const days = [
      'lunes',
      'martes',
      'miercoles',
      'jueves',
      'viernes',
      'sabado',
      'domingo'
    ];
    return days[date.weekday - 1];
  }

  int _timeOfDayInMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  TimeOfDay _addMinutesToTimeOfDay(TimeOfDay time, int minutes) {
    final totalMinutes = _timeOfDayInMinutes(time) + minutes;
    return TimeOfDay(
      hour: (totalMinutes ~/ 60) % 24,
      minute: totalMinutes % 60,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CabinaModel &&
          runtimeType == other.runtimeType &&
          cabinaId == other.cabinaId;

  @override
  int get hashCode => cabinaId.hashCode;

  @override
  String toString() {
    return 'CabinaModel{id: $cabinaId, nombre: $nombre, tipo: ${tipo.name}, estado: ${estado.name}}';
  }
}

/// 📋 ENUMS PARA CABINAS
enum CabinaTipo {
  vip('VIP'),
  premium('Premium'),
  standard('Estándar'),
  grupal('Grupal'),
  terapeutica('Terapéutica'),
  consultorio('Consultorio'),
  spa('Spa');

  const CabinaTipo(this.displayName);
  final String displayName;
}

enum CabinaEstado {
  disponible('Disponible'),
  ocupada('Ocupada'),
  mantenimiento('Mantenimiento'),
  limpieza('Limpieza'),
  reservada('Reservada'),
  fuera_servicio('Fuera de Servicio');

  const CabinaEstado(this.displayName);
  final String displayName;
}

/// 📊 EXTENSIONES PARA LISTAS DE CABINAS
extension CabinaModelListExtensions on List<CabinaModel> {
  List<CabinaModel> get disponibles => where((c) => c.isDisponible).toList();

  List<CabinaModel> get activas => where((c) => c.isActive).toList();

  List<CabinaModel> get requierenMantenimiento =>
      where((c) => c.requiereMantenimientoUrgente).toList();

  List<CabinaModel> porTipo(CabinaTipo tipo) =>
      where((c) => c.tipo == tipo).toList();

  List<CabinaModel> porEstado(CabinaEstado estado) =>
      where((c) => c.estado == estado).toList();

  List<CabinaModel> conEquipamiento(String equipo) =>
      where((c) => c.tieneEquipamiento(equipo)).toList();

  List<CabinaModel> conCapacidad(int minCapacidad) =>
      where((c) => c.capacidad >= minCapacidad).toList();

  List<CabinaModel> paraServicio(String servicioId) =>
      where((c) => c.puedeProveerServicio(servicioId)).toList();

  Map<CabinaTipo, int> get countByTipo {
    final counts = <CabinaTipo, int>{};
    for (final cabina in this) {
      counts[cabina.tipo] = (counts[cabina.tipo] ?? 0) + 1;
    }
    return counts;
  }

  Map<CabinaEstado, int> get countByEstado {
    final counts = <CabinaEstado, int>{};
    for (final cabina in this) {
      counts[cabina.estado] = (counts[cabina.estado] ?? 0) + 1;
    }
    return counts;
  }

  double get ocupacionPromedio {
    if (isEmpty) return 0.0;
    final total = fold(0.0, (sum, c) => sum + c.porcentajeOcupacion);
    return total / length;
  }

  int get capacidadTotal {
    return fold(0, (sum, c) => sum + c.capacidad);
  }

  List<String> get todosLosEquipamientos {
    final equipos = <String>{};
    for (final cabina in this) {
      equipos.addAll(cabina.equipamiento);
    }
    return equipos.toList();
  }
}
