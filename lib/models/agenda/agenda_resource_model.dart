import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 🏢 MODELO UNIFICADO DE RECURSOS
/// Abstrae profesionales, cabinas y otros recursos para drag & drop
class AgendaResourceModel {
  final String resourceId;
  final String resourceName;
  final ResourceType resourceType;
  final ResourceStatus status;
  final String? avatarUrl;
  final String? photoUrl;
  final List<String> especialidades;
  final List<String> serviciosDisponibles;
  final Map<String, dynamic>? horarios;
  final Map<String, dynamic>? configuracion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ✅ CAMPOS ESPECÍFICOS POR TIPO
  final ProfessionalInfo? professionalInfo;
  final CabinaInfo? cabinaInfo;

  // ✅ CAMPOS CALCULADOS EN TIEMPO REAL
  final int appointmentsToday;
  final double occupancyPercentage;
  final DateTime? nextAvailableSlot;
  final bool isAvailableNow;

  AgendaResourceModel({
    required this.resourceId,
    required this.resourceName,
    required this.resourceType,
    this.status = ResourceStatus.available,
    this.avatarUrl,
    this.photoUrl,
    this.especialidades = const [],
    this.serviciosDisponibles = const [],
    this.horarios,
    this.configuracion,
    this.createdAt,
    this.updatedAt,
    this.professionalInfo,
    this.cabinaInfo,
    this.appointmentsToday = 0,
    this.occupancyPercentage = 0.0,
    this.nextAvailableSlot,
    this.isAvailableNow = false,
  });

  /// 🏗️ FACTORY PARA PROFESIONALES
  factory AgendaResourceModel.fromProfessional(
      Map<String, dynamic> data, String id) {
    final serviciosData = data['servicios'] as List<dynamic>? ?? [];
    final servicios = serviciosData
        .map((s) {
          if (s is Map<String, dynamic>) {
            return s['name'] ?? s['serviceId'] ?? '';
          }
          return s.toString();
        })
        .where((s) => s.isNotEmpty)
        .toList()
        .cast<String>();

    return AgendaResourceModel(
      resourceId: id,
      resourceName: _buildFullName(data['nombre'], data['apellidos']),
      resourceType: ResourceType.professional,
      status: _parseStatus(data['estado']),
      avatarUrl: data['fotoUrl'],
      photoUrl: data['fotoUrl'],
      especialidades: List<String>.from(data['especialidades'] ?? []),
      serviciosDisponibles: servicios,
      horarios: data['horarios'],
      configuracion: data['configuracion'],
      createdAt: _parseTimestamp(data['fechaAlta'] ?? data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      professionalInfo: ProfessionalInfo.fromMap(data),
    );
  }

  /// 🏗️ FACTORY PARA CABINAS
  factory AgendaResourceModel.fromCabina(Map<String, dynamic> data, String id) {
    return AgendaResourceModel(
      resourceId: id,
      resourceName: data['nombre'] ?? 'Cabina ${id.substring(0, 4)}',
      resourceType: ResourceType.cabina,
      status: _parseCabinaStatus(data['estado']),
      photoUrl: data['imagen'],
      especialidades: List<String>.from(data['especialidades'] ?? []),
      serviciosDisponibles:
          List<String>.from(data['serviciosPermitidos'] ?? []),
      horarios: data['horarios'],
      configuracion: data['configuracion'],
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      cabinaInfo: CabinaInfo.fromMap(data),
    );
  }

  /// 🏗️ FACTORY GENÉRICO
  factory AgendaResourceModel.fromMap(Map<String, dynamic> data, String id) {
    final type = _parseResourceType(data['resourceType'] ?? data['tipo']);

    switch (type) {
      case ResourceType.professional:
        return AgendaResourceModel.fromProfessional(data, id);
      case ResourceType.cabina:
        return AgendaResourceModel.fromCabina(data, id);
      default:
        return AgendaResourceModel.fromGeneric(data, id);
    }
  }

  /// 🏗️ FACTORY GENÉRICO PARA RECURSOS PERSONALIZADOS
  factory AgendaResourceModel.fromGeneric(
      Map<String, dynamic> data, String id) {
    return AgendaResourceModel(
      resourceId: id,
      resourceName: data['nombre'] ?? 'Recurso $id',
      resourceType: _parseResourceType(data['tipo']),
      status: _parseGenericStatus(data['estado']),
      photoUrl: data['imagen'] ?? data['fotoUrl'],
      especialidades: List<String>.from(data['especialidades'] ?? []),
      serviciosDisponibles: List<String>.from(data['servicios'] ?? []),
      horarios: data['horarios'],
      configuracion: data['configuracion'],
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  /// 💾 CONVERSIÓN A MAP
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'resourceId': resourceId,
      'nombre': resourceName,
      'resourceType': resourceType.name,
      'tipo': resourceType.name,
      'estado': status.name,
      'especialidades': especialidades,
      'servicios': serviciosDisponibles,
      'horarios': horarios,
      'configuracion': configuracion,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Agregar campos específicos por tipo
    if (professionalInfo != null) {
      map.addAll(professionalInfo!.toMap());
    }

    if (cabinaInfo != null) {
      map.addAll(cabinaInfo!.toMap());
    }

    // Agregar URLs de imagen
    if (avatarUrl != null) map['fotoUrl'] = avatarUrl;
    if (photoUrl != null) map['imagen'] = photoUrl;

    map.removeWhere((key, value) => value == null);
    return map;
  }

  /// 🎨 GETTERS PARA UI
  String get displayName => resourceName;

  String get subtitle {
    switch (resourceType) {
      case ResourceType.professional:
        return especialidades.isNotEmpty ? especialidades.first : 'Profesional';
      case ResourceType.cabina:
        return cabinaInfo?.tipo ?? 'Cabina';
      default:
        return resourceType.displayName;
    }
  }

  String get imageUrl => avatarUrl ?? photoUrl ?? '';

  Color get statusColor {
    switch (status) {
      case ResourceStatus.available:
        return Colors.green.shade600;
      case ResourceStatus.busy:
        return Colors.orange.shade600;
      case ResourceStatus.unavailable:
        return Colors.red.shade600;
      case ResourceStatus.maintenance:
        return Colors.purple.shade600;
      case ResourceStatus.offline:
        return Colors.grey.shade600;
    }
  }

  IconData get typeIcon {
    switch (resourceType) {
      case ResourceType.professional:
        return Icons.person;
      case ResourceType.cabina:
        return Icons.room;
      case ResourceType.equipment:
        return Icons.medical_services;
      case ResourceType.vehicle:
        return Icons.directions_car;
      case ResourceType.other:
        return Icons.category;
    }
  }

  /// 📊 MÉTODOS DE CONSULTA
  bool get isActive =>
      status != ResourceStatus.offline && status != ResourceStatus.unavailable;

  bool get canAcceptAppointments {
    return isActive &&
        status != ResourceStatus.maintenance &&
        serviciosDisponibles.isNotEmpty;
  }

  bool canProvideService(String servicioId) {
    return canAcceptAppointments &&
        (serviciosDisponibles.contains(servicioId) ||
            serviciosDisponibles.isEmpty);
  }

  List<String> get availableServices {
    return serviciosDisponibles.where((s) => s.isNotEmpty).toList();
  }

  /// 📅 MÉTODOS DE HORARIOS
  bool isAvailableAt(DateTime dateTime) {
    if (!canAcceptAppointments) return false;

    // TODO: Implementar lógica de horarios específica
    final dayName = _getDayName(dateTime);
    final dayConfig = horarios?[dayName];

    if (dayConfig == null) return false;

    // Lógica básica de horarios (extender según necesidades)
    return true;
  }

  List<DateTime> getAvailableSlots({
    required DateTime date,
    required int serviceDurationMinutes,
    int intervalMinutes = 30,
  }) {
    if (!canAcceptAppointments) return [];

    // TODO: Integrar con CalendarModel para lógica completa
    final slots = <DateTime>[];

    // Implementación básica (expandir con CalendarModel)
    final workStart = DateTime(date.year, date.month, date.day, 9, 0);
    final workEnd = DateTime(date.year, date.month, date.day, 18, 0);

    DateTime current = workStart;
    while (current
        .add(Duration(minutes: serviceDurationMinutes))
        .isBefore(workEnd)) {
      if (isAvailableAt(current)) {
        slots.add(current);
      }
      current = current.add(Duration(minutes: intervalMinutes));
    }

    return slots;
  }

  /// 🔍 BÚSQUEDA Y FILTROS
  bool matchesSearchQuery(String query) {
    if (query.isEmpty) return true;

    final searchText = '''
      $resourceName 
      ${especialidades.join(' ')} 
      ${serviciosDisponibles.join(' ')}
      ${status.displayName}
      ${resourceType.displayName}
      ${professionalInfo?.telefono ?? ''}
      ${professionalInfo?.email ?? ''}
    '''
        .toLowerCase();

    return query
        .toLowerCase()
        .split(' ')
        .every((term) => searchText.contains(term));
  }

  bool matchesFilters({
    List<ResourceType>? types,
    List<ResourceStatus>? statuses,
    List<String>? especialidadesFilter,
    List<String>? serviciosFilter,
  }) {
    if (types != null && !types.contains(resourceType)) return false;
    if (statuses != null && !statuses.contains(status)) return false;

    if (especialidadesFilter != null && especialidadesFilter.isNotEmpty) {
      if (!especialidadesFilter.any((e) => especialidades.contains(e)))
        return false;
    }

    if (serviciosFilter != null && serviciosFilter.isNotEmpty) {
      if (!serviciosFilter.any((s) => serviciosDisponibles.contains(s)))
        return false;
    }

    return true;
  }

  /// 🔄 COPYWIHT
  AgendaResourceModel copyWith({
    String? resourceId,
    String? resourceName,
    ResourceType? resourceType,
    ResourceStatus? status,
    String? avatarUrl,
    String? photoUrl,
    List<String>? especialidades,
    List<String>? serviciosDisponibles,
    Map<String, dynamic>? horarios,
    Map<String, dynamic>? configuracion,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProfessionalInfo? professionalInfo,
    CabinaInfo? cabinaInfo,
    int? appointmentsToday,
    double? occupancyPercentage,
    DateTime? nextAvailableSlot,
    bool? isAvailableNow,
  }) {
    return AgendaResourceModel(
      resourceId: resourceId ?? this.resourceId,
      resourceName: resourceName ?? this.resourceName,
      resourceType: resourceType ?? this.resourceType,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      especialidades: especialidades ?? this.especialidades,
      serviciosDisponibles: serviciosDisponibles ?? this.serviciosDisponibles,
      horarios: horarios ?? this.horarios,
      configuracion: configuracion ?? this.configuracion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      professionalInfo: professionalInfo ?? this.professionalInfo,
      cabinaInfo: cabinaInfo ?? this.cabinaInfo,
      appointmentsToday: appointmentsToday ?? this.appointmentsToday,
      occupancyPercentage: occupancyPercentage ?? this.occupancyPercentage,
      nextAvailableSlot: nextAvailableSlot ?? this.nextAvailableSlot,
      isAvailableNow: isAvailableNow ?? this.isAvailableNow,
    );
  }

  /// 🔧 MÉTODOS HELPER ESTÁTICOS
  static String _buildFullName(dynamic nombre, dynamic apellidos) {
    final nombreStr = nombre?.toString() ?? '';
    final apellidosStr = apellidos?.toString() ?? '';
    return '$nombreStr $apellidosStr'.trim();
  }

  static ResourceStatus _parseStatus(dynamic estado) {
    if (estado is bool)
      return estado ? ResourceStatus.available : ResourceStatus.unavailable;

    switch (estado?.toString().toLowerCase()) {
      case 'true':
      case 'activo':
      case 'disponible':
      case 'available':
        return ResourceStatus.available;
      case 'ocupado':
      case 'busy':
        return ResourceStatus.busy;
      case 'mantenimiento':
      case 'maintenance':
        return ResourceStatus.maintenance;
      case 'false':
      case 'inactivo':
      case 'offline':
        return ResourceStatus.offline;
      default:
        return ResourceStatus.unavailable;
    }
  }

  static ResourceStatus _parseCabinaStatus(dynamic estado) {
    switch (estado?.toString().toLowerCase()) {
      case 'disponible':
        return ResourceStatus.available;
      case 'ocupada':
        return ResourceStatus.busy;
      case 'mantenimiento':
        return ResourceStatus.maintenance;
      default:
        return ResourceStatus.unavailable;
    }
  }

  static ResourceStatus _parseGenericStatus(dynamic estado) {
    return _parseStatus(estado);
  }

  static ResourceType _parseResourceType(dynamic tipo) {
    switch (tipo?.toString().toLowerCase()) {
      case 'professional':
      case 'profesional':
      case 'therapist':
      case 'terapeuta':
        return ResourceType.professional;
      case 'cabina':
      case 'room':
      case 'sala':
        return ResourceType.cabina;
      case 'equipment':
      case 'equipo':
        return ResourceType.equipment;
      case 'vehicle':
      case 'vehiculo':
        return ResourceType.vehicle;
      default:
        return ResourceType.other;
    }
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgendaResourceModel &&
          runtimeType == other.runtimeType &&
          resourceId == other.resourceId;

  @override
  int get hashCode => resourceId.hashCode;

  @override
  String toString() {
    return 'AgendaResourceModel{id: $resourceId, name: $resourceName, type: ${resourceType.name}, status: ${status.name}}';
  }
}

/// 👨‍⚕️ INFORMACIÓN ESPECÍFICA DE PROFESIONALES
class ProfessionalInfo {
  final String? apellidos;
  final String? telefono;
  final String? email;
  final List<String> idiomas;
  final String? notas;
  final List<Map<String, dynamic>> certificaciones;
  final int experienciaAnios;
  final double calificacionPromedio;
  final String? professionalId; // Campo legacy

  ProfessionalInfo({
    this.apellidos,
    this.telefono,
    this.email,
    this.idiomas = const [],
    this.notas,
    this.certificaciones = const [],
    this.experienciaAnios = 0,
    this.calificacionPromedio = 0.0,
    this.professionalId,
  });

  factory ProfessionalInfo.fromMap(Map<String, dynamic> data) {
    return ProfessionalInfo(
      apellidos: data['apellidos'],
      telefono: data['telefono'],
      email: data['email'],
      idiomas: List<String>.from(data['idiomas'] ?? []),
      notas: data['notas'],
      certificaciones:
          List<Map<String, dynamic>>.from(data['certificaciones'] ?? []),
      experienciaAnios: data['experienciaAnios'] ?? 0,
      calificacionPromedio: (data['calificacionPromedio'] ?? 0.0).toDouble(),
      professionalId: data['professionalId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'apellidos': apellidos,
      'telefono': telefono,
      'email': email,
      'idiomas': idiomas,
      'notas': notas,
      'certificaciones': certificaciones,
      'experienciaAnios': experienciaAnios,
      'calificacionPromedio': calificacionPromedio,
      'professionalId': professionalId,
    };
  }
}

/// 🏢 INFORMACIÓN ESPECÍFICA DE CABINAS
class CabinaInfo {
  final String tipo; // 'vip', 'premium', 'standard', 'grupal'
  final int capacidad;
  final List<String> equipamiento;
  final double tarifaPorHora;
  final bool requiereAprobacion;
  final Map<String, dynamic>? caracteristicas;

  CabinaInfo({
    this.tipo = 'standard',
    this.capacidad = 1,
    this.equipamiento = const [],
    this.tarifaPorHora = 0.0,
    this.requiereAprobacion = false,
    this.caracteristicas,
  });

  factory CabinaInfo.fromMap(Map<String, dynamic> data) {
    return CabinaInfo(
      tipo: data['tipo'] ?? 'standard',
      capacidad: data['capacidad'] ?? 1,
      equipamiento: List<String>.from(data['equipamiento'] ?? []),
      tarifaPorHora: (data['tarifaPorHora'] ?? 0.0).toDouble(),
      requiereAprobacion: data['requiereAprobacion'] ?? false,
      caracteristicas: data['caracteristicas'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'capacidad': capacidad,
      'equipamiento': equipamiento,
      'tarifaPorHora': tarifaPorHora,
      'requiereAprobacion': requiereAprobacion,
      'caracteristicas': caracteristicas,
    };
  }

  Color get tipoColor {
    switch (tipo.toLowerCase()) {
      case 'vip':
        return Colors.purple.shade600;
      case 'premium':
        return Colors.orange.shade600;
      case 'grupal':
        return Colors.blue.shade600;
      default:
        return Colors.green.shade600;
    }
  }
}

/// 📋 ENUMS
enum ResourceType {
  professional('Profesional'),
  cabina('Cabina'),
  equipment('Equipo'),
  vehicle('Vehículo'),
  other('Otro');

  const ResourceType(this.displayName);
  final String displayName;
}

enum ResourceStatus {
  available('Disponible'),
  busy('Ocupado'),
  unavailable('No Disponible'),
  maintenance('Mantenimiento'),
  offline('Desconectado');

  const ResourceStatus(this.displayName);
  final String displayName;
}

/// 📊 EXTENSIONES PARA LISTAS DE RECURSOS
extension AgendaResourceListExtensions on List<AgendaResourceModel> {
  List<AgendaResourceModel> get professionals =>
      where((r) => r.resourceType == ResourceType.professional).toList();

  List<AgendaResourceModel> get cabinas =>
      where((r) => r.resourceType == ResourceType.cabina).toList();

  List<AgendaResourceModel> get available =>
      where((r) => r.status == ResourceStatus.available).toList();

  List<AgendaResourceModel> get busy =>
      where((r) => r.status == ResourceStatus.busy).toList();

  List<AgendaResourceModel> filterByType(ResourceType type) =>
      where((r) => r.resourceType == type).toList();

  List<AgendaResourceModel> filterByStatus(ResourceStatus status) =>
      where((r) => r.status == status).toList();

  List<AgendaResourceModel> filterByService(String servicioId) =>
      where((r) => r.canProvideService(servicioId)).toList();

  List<AgendaResourceModel> search(String query) =>
      where((r) => r.matchesSearchQuery(query)).toList();

  Map<ResourceType, int> get countByType {
    final counts = <ResourceType, int>{};
    for (final resource in this) {
      counts[resource.resourceType] = (counts[resource.resourceType] ?? 0) + 1;
    }
    return counts;
  }

  Map<ResourceStatus, int> get countByStatus {
    final counts = <ResourceStatus, int>{};
    for (final resource in this) {
      counts[resource.status] = (counts[resource.status] ?? 0) + 1;
    }
    return counts;
  }

  double get averageOccupancy {
    if (isEmpty) return 0.0;
    final total = fold(0.0, (sum, r) => sum + r.occupancyPercentage);
    return total / length;
  }
}
