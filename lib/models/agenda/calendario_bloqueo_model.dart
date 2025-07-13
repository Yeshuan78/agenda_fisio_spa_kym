import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 🚫 MODELO ESPECIALIZADO DE BLOQUEOS DE CALENDARIO
/// Maneja bloqueos complejos, recurrentes y temporales
class CalendarioBloqueoModel {
  final String bloqueoId;
  final String nombre;
  final String? descripcion;
  final BloqueoType tipo;
  final BloqueoScope scope;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final TimeOfDay horaInicio;
  final TimeOfDay horaFin;

  // ✅ RECURSOS AFECTADOS
  final List<String> recursosAfectados; // IDs de profesionales/cabinas
  final List<ResourceType> tiposRecursosAfectados;

  // ✅ CONFIGURACIÓN DE RECURRENCIA
  final RecurrencePattern? recurrencia;
  final List<DateTime> fechasExcluidas;
  final DateTime? fechaFinRecurrencia;

  // ✅ CONFIGURACIÓN AVANZADA
  final BloqueoSeverity severidad;
  final bool permiteCitasExistentes;
  final bool notificarUsuarios;
  final List<String> usuariosNotificados;

  // ✅ METADATOS
  final String creadoPor;
  final DateTime creadoEn;
  final DateTime? actualizadoEn;
  final Map<String, dynamic>? metadatos;
  final bool isActive;

  CalendarioBloqueoModel({
    required this.bloqueoId,
    required this.nombre,
    this.descripcion,
    required this.tipo,
    this.scope = BloqueoScope.resource,
    required this.fechaInicio,
    required this.fechaFin,
    required this.horaInicio,
    required this.horaFin,
    this.recursosAfectados = const [],
    this.tiposRecursosAfectados = const [],
    this.recurrencia,
    this.fechasExcluidas = const [],
    this.fechaFinRecurrencia,
    this.severidad = BloqueoSeverity.medium,
    this.permiteCitasExistentes = false,
    this.notificarUsuarios = true,
    this.usuariosNotificados = const [],
    required this.creadoPor,
    required this.creadoEn,
    this.actualizadoEn,
    this.metadatos,
    this.isActive = true,
  });

  /// 🏗️ FACTORY DESDE FIRESTORE
  factory CalendarioBloqueoModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CalendarioBloqueoModel.fromMap(data, doc.id);
  }

  factory CalendarioBloqueoModel.fromMap(Map<String, dynamic> data, String id) {
    return CalendarioBloqueoModel(
      bloqueoId: id,
      nombre: data['nombre'] ?? 'Bloqueo',
      descripcion: data['descripcion'],
      tipo: _parseBloqueoType(data['tipo']),
      scope: _parseBloqueoScope(data['scope']),
      fechaInicio: _parseDateTime(data['fechaInicio'])!,
      fechaFin: _parseDateTime(data['fechaFin'])!,
      horaInicio: _parseTimeOfDay(data['horaInicio']),
      horaFin: _parseTimeOfDay(data['horaFin']),
      recursosAfectados: List<String>.from(data['recursosAfectados'] ?? []),
      tiposRecursosAfectados:
          _parseResourceTypes(data['tiposRecursosAfectados']),
      recurrencia: data['recurrencia'] != null
          ? RecurrencePattern.fromMap(data['recurrencia'])
          : null,
      fechasExcluidas: _parseDateTimeList(data['fechasExcluidas']),
      fechaFinRecurrencia: _parseDateTime(data['fechaFinRecurrencia']),
      severidad: _parseBloqueoSeverity(data['severidad']),
      permiteCitasExistentes: data['permiteCitasExistentes'] ?? false,
      notificarUsuarios: data['notificarUsuarios'] ?? true,
      usuariosNotificados: List<String>.from(data['usuariosNotificados'] ?? []),
      creadoPor: data['creadoPor'] ?? 'sistema',
      creadoEn: _parseDateTime(data['creadoEn']) ?? DateTime.now(),
      actualizadoEn: _parseDateTime(data['actualizadoEn']),
      metadatos: data['metadatos'],
      isActive: data['isActive'] ?? true,
    );
  }

  /// 💾 CONVERSIÓN A MAP PARA FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'tipo': tipo.name,
      'scope': scope.name,
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFin': Timestamp.fromDate(fechaFin),
      'horaInicio': _timeOfDayToMap(horaInicio),
      'horaFin': _timeOfDayToMap(horaFin),
      'recursosAfectados': recursosAfectados,
      'tiposRecursosAfectados':
          tiposRecursosAfectados.map((t) => t.name).toList(),
      'recurrencia': recurrencia?.toMap(),
      'fechasExcluidas':
          fechasExcluidas.map((d) => Timestamp.fromDate(d)).toList(),
      'fechaFinRecurrencia': fechaFinRecurrencia != null
          ? Timestamp.fromDate(fechaFinRecurrencia!)
          : null,
      'severidad': severidad.name,
      'permiteCitasExistentes': permiteCitasExistentes,
      'notificarUsuarios': notificarUsuarios,
      'usuariosNotificados': usuariosNotificados,
      'creadoPor': creadoPor,
      'creadoEn': Timestamp.fromDate(creadoEn),
      'actualizadoEn':
          actualizadoEn != null ? Timestamp.fromDate(actualizadoEn!) : null,
      'metadatos': metadatos,
      'isActive': isActive,
    };
  }

  /// 🎨 GETTERS PARA UI
  String get fechaInicioFormatted =>
      DateFormat('dd/MM/yyyy').format(fechaInicio);
  String get fechaFinFormatted => DateFormat('dd/MM/yyyy').format(fechaFin);
  String get horaInicioFormatted =>
      '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}';
  String get horaFinFormatted =>
      '${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}';

  Duration get duracion {
    final inicio = Duration(hours: horaInicio.hour, minutes: horaInicio.minute);
    final fin = Duration(hours: horaFin.hour, minutes: horaFin.minute);
    return fin - inicio;
  }

  String get duracionFormatted {
    final hours = duracion.inHours;
    final minutes = duracion.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  Color get color {
    switch (tipo) {
      case BloqueoType.maintenance:
        return Colors.red.shade600;
      case BloqueoType.lunch:
        return Colors.orange.shade600;
      case BloqueoType.meeting:
        return Colors.blue.shade600;
      case BloqueoType.training:
        return Colors.purple.shade600;
      case BloqueoType.vacation:
        return Colors.green.shade600;
      case BloqueoType.sick:
        return Colors.yellow.shade700;
      case BloqueoType.emergency:
        return Colors.red.shade800;
      case BloqueoType.personal:
        return Colors.grey.shade600;
      case BloqueoType.custom:
        return Colors.indigo.shade600;
    }
  }

  IconData get icon {
    switch (tipo) {
      case BloqueoType.maintenance:
        return Icons.build;
      case BloqueoType.lunch:
        return Icons.restaurant;
      case BloqueoType.meeting:
        return Icons.meeting_room;
      case BloqueoType.training:
        return Icons.school;
      case BloqueoType.vacation:
        return Icons.beach_access;
      case BloqueoType.sick:
        return Icons.sick;
      case BloqueoType.emergency:
        return Icons.emergency;
      case BloqueoType.personal:
        return Icons.person;
      case BloqueoType.custom:
        return Icons.block;
    }
  }

  String get severityText {
    switch (severidad) {
      case BloqueoSeverity.low:
        return 'Baja';
      case BloqueoSeverity.medium:
        return 'Media';
      case BloqueoSeverity.high:
        return 'Alta';
      case BloqueoSeverity.critical:
        return 'Crítica';
    }
  }

  Color get severityColor {
    switch (severidad) {
      case BloqueoSeverity.low:
        return Colors.green;
      case BloqueoSeverity.medium:
        return Colors.orange;
      case BloqueoSeverity.high:
        return Colors.red;
      case BloqueoSeverity.critical:
        return Colors.red.shade900;
    }
  }

  /// 🔍 MÉTODOS DE VALIDACIÓN
  bool afectaRecurso(String resourceId) {
    return recursosAfectados.contains(resourceId);
  }

  bool afectaTipoRecurso(ResourceType resourceType) {
    return tiposRecursosAfectados.contains(resourceType);
  }

  bool isActiveOnDate(DateTime date) {
    if (!isActive) return false;

    // Verificar si la fecha está en el rango
    if (date.isBefore(fechaInicio) || date.isAfter(fechaFin)) return false;

    // Verificar si está en fechas excluidas
    if (fechasExcluidas.any((excluded) => _isSameDate(excluded, date)))
      return false;

    // Si no hay recurrencia, verificar si está en el rango simple
    if (recurrencia == null) {
      return !date.isBefore(fechaInicio) && !date.isAfter(fechaFin);
    }

    // Verificar recurrencia
    return recurrencia!.matchesDate(date, fechaInicio);
  }

  bool conflictsWithTimeSlot(DateTime dateTime, Duration slotDuration) {
    if (!isActiveOnDate(dateTime)) return false;

    final slotStart = TimeOfDay.fromDateTime(dateTime);
    final slotEnd = TimeOfDay.fromDateTime(dateTime.add(slotDuration));

    return _timeRangesOverlap(
      horaInicio,
      horaFin,
      slotStart,
      slotEnd,
    );
  }

  bool conflictsWithAppointment(
      DateTime appointmentStart, Duration appointmentDuration) {
    return conflictsWithTimeSlot(appointmentStart, appointmentDuration);
  }

  /// 📅 MÉTODOS DE RECURRENCIA
  List<DateTime> getOccurrencesBetween(DateTime start, DateTime end) {
    if (!isActive) return [];

    final occurrences = <DateTime>[];

    if (recurrencia == null) {
      // Bloqueo simple (no recurrente)
      if (fechaInicio.isAfter(start) && fechaInicio.isBefore(end)) {
        occurrences.add(fechaInicio);
      }
    } else {
      // Bloqueo recurrente
      DateTime current = fechaInicio.isAfter(start) ? fechaInicio : start;
      final effectiveEnd = fechaFinRecurrencia != null
          ? (fechaFinRecurrencia!.isBefore(end) ? fechaFinRecurrencia! : end)
          : end;

      while (!current.isAfter(effectiveEnd)) {
        if (recurrencia!.matchesDate(current, fechaInicio) &&
            !fechasExcluidas
                .any((excluded) => _isSameDate(excluded, current))) {
          occurrences.add(current);
        }
        current = current.add(const Duration(days: 1));
      }
    }

    return occurrences;
  }

  /// 📝 MÉTODOS DE MODIFICACIÓN
  CalendarioBloqueoModel copyWith({
    String? bloqueoId,
    String? nombre,
    String? descripcion,
    BloqueoType? tipo,
    BloqueoScope? scope,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    TimeOfDay? horaInicio,
    TimeOfDay? horaFin,
    List<String>? recursosAfectados,
    List<ResourceType>? tiposRecursosAfectados,
    RecurrencePattern? recurrencia,
    List<DateTime>? fechasExcluidas,
    DateTime? fechaFinRecurrencia,
    BloqueoSeverity? severidad,
    bool? permiteCitasExistentes,
    bool? notificarUsuarios,
    List<String>? usuariosNotificados,
    String? creadoPor,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
    Map<String, dynamic>? metadatos,
    bool? isActive,
  }) {
    return CalendarioBloqueoModel(
      bloqueoId: bloqueoId ?? this.bloqueoId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      scope: scope ?? this.scope,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      recursosAfectados: recursosAfectados ?? this.recursosAfectados,
      tiposRecursosAfectados:
          tiposRecursosAfectados ?? this.tiposRecursosAfectados,
      recurrencia: recurrencia ?? this.recurrencia,
      fechasExcluidas: fechasExcluidas ?? this.fechasExcluidas,
      fechaFinRecurrencia: fechaFinRecurrencia ?? this.fechaFinRecurrencia,
      severidad: severidad ?? this.severidad,
      permiteCitasExistentes:
          permiteCitasExistentes ?? this.permiteCitasExistentes,
      notificarUsuarios: notificarUsuarios ?? this.notificarUsuarios,
      usuariosNotificados: usuariosNotificados ?? this.usuariosNotificados,
      creadoPor: creadoPor ?? this.creadoPor,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? DateTime.now(),
      metadatos: metadatos ?? this.metadatos,
      isActive: isActive ?? this.isActive,
    );
  }

  CalendarioBloqueoModel addExcludedDate(DateTime date) {
    final newExcluded = List<DateTime>.from(fechasExcluidas);
    if (!newExcluded.any((d) => _isSameDate(d, date))) {
      newExcluded.add(date);
    }
    return copyWith(fechasExcluidas: newExcluded);
  }

  CalendarioBloqueoModel removeExcludedDate(DateTime date) {
    final newExcluded =
        fechasExcluidas.where((d) => !_isSameDate(d, date)).toList();
    return copyWith(fechasExcluidas: newExcluded);
  }

  /// 🔧 MÉTODOS HELPER ESTÁTICOS
  static BloqueoType _parseBloqueoType(dynamic tipo) {
    return BloqueoType.values.firstWhere(
      (t) => t.name == tipo,
      orElse: () => BloqueoType.custom,
    );
  }

  static BloqueoScope _parseBloqueoScope(dynamic scope) {
    return BloqueoScope.values.firstWhere(
      (s) => s.name == scope,
      orElse: () => BloqueoScope.resource,
    );
  }

  static BloqueoSeverity _parseBloqueoSeverity(dynamic severidad) {
    return BloqueoSeverity.values.firstWhere(
      (s) => s.name == severidad,
      orElse: () => BloqueoSeverity.medium,
    );
  }

  static List<ResourceType> _parseResourceTypes(dynamic types) {
    if (types is! List) return [];
    return types
        .map((t) => ResourceType.values
            .firstWhere((rt) => rt.name == t, orElse: () => ResourceType.other))
        .toList();
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
        hour: timeData['hour'] ?? 0,
        minute: timeData['minute'] ?? 0,
      );
    }
    if (timeData is String) {
      final parts = timeData.split(':');
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      );
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  static Map<String, dynamic> _timeOfDayToMap(TimeOfDay time) {
    return {
      'hour': time.hour,
      'minute': time.minute,
    };
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool _timeRangesOverlap(
    TimeOfDay start1,
    TimeOfDay end1,
    TimeOfDay start2,
    TimeOfDay end2,
  ) {
    final start1Minutes = start1.hour * 60 + start1.minute;
    final end1Minutes = end1.hour * 60 + end1.minute;
    final start2Minutes = start2.hour * 60 + start2.minute;
    final end2Minutes = end2.hour * 60 + end2.minute;

    return !(end1Minutes <= start2Minutes || start1Minutes >= end2Minutes);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarioBloqueoModel &&
          runtimeType == other.runtimeType &&
          bloqueoId == other.bloqueoId;

  @override
  int get hashCode => bloqueoId.hashCode;

  @override
  String toString() {
    return 'CalendarioBloqueoModel{id: $bloqueoId, nombre: $nombre, tipo: ${tipo.name}, activo: $isActive}';
  }
}

/// 🔄 PATRÓN DE RECURRENCIA
class RecurrencePattern {
  final RecurrenceType type;
  final int interval; // Cada N días/semanas/meses
  final List<int> daysOfWeek; // 1=Lunes, 7=Domingo
  final List<int> daysOfMonth; // 1-31
  final List<int> monthsOfYear; // 1-12
  final int? count; // Número máximo de ocurrencias
  final Map<String, dynamic>? customPattern;

  RecurrencePattern({
    required this.type,
    this.interval = 1,
    this.daysOfWeek = const [],
    this.daysOfMonth = const [],
    this.monthsOfYear = const [],
    this.count,
    this.customPattern,
  });

  factory RecurrencePattern.fromMap(Map<String, dynamic> data) {
    return RecurrencePattern(
      type: RecurrenceType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => RecurrenceType.none,
      ),
      interval: data['interval'] ?? 1,
      daysOfWeek: List<int>.from(data['daysOfWeek'] ?? []),
      daysOfMonth: List<int>.from(data['daysOfMonth'] ?? []),
      monthsOfYear: List<int>.from(data['monthsOfYear'] ?? []),
      count: data['count'],
      customPattern: data['customPattern'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'daysOfMonth': daysOfMonth,
      'monthsOfYear': monthsOfYear,
      'count': count,
      'customPattern': customPattern,
    };
  }

  bool matchesDate(DateTime date, DateTime startDate) {
    switch (type) {
      case RecurrenceType.none:
        return false;
      case RecurrenceType.daily:
        return _matchesDaily(date, startDate);
      case RecurrenceType.weekly:
        return _matchesWeekly(date, startDate);
      case RecurrenceType.monthly:
        return _matchesMonthly(date, startDate);
      case RecurrenceType.yearly:
        return _matchesYearly(date, startDate);
      case RecurrenceType.custom:
        return _matchesCustom(date, startDate);
    }
  }

  bool _matchesDaily(DateTime date, DateTime startDate) {
    final daysDiff = date.difference(startDate).inDays;
    return daysDiff >= 0 && daysDiff % interval == 0;
  }

  bool _matchesWeekly(DateTime date, DateTime startDate) {
    if (daysOfWeek.isEmpty) return false;

    final weeksDiff = date.difference(startDate).inDays ~/ 7;
    if (weeksDiff % interval != 0) return false;

    return daysOfWeek.contains(date.weekday);
  }

  bool _matchesMonthly(DateTime date, DateTime startDate) {
    final monthsDiff =
        (date.year - startDate.year) * 12 + (date.month - startDate.month);
    if (monthsDiff % interval != 0) return false;

    if (daysOfMonth.isNotEmpty) {
      return daysOfMonth.contains(date.day);
    }

    return date.day == startDate.day;
  }

  bool _matchesYearly(DateTime date, DateTime startDate) {
    final yearsDiff = date.year - startDate.year;
    if (yearsDiff % interval != 0) return false;

    return date.month == startDate.month && date.day == startDate.day;
  }

  bool _matchesCustom(DateTime date, DateTime startDate) {
    // Implementar lógica personalizada según customPattern
    return false;
  }

  String get description {
    switch (type) {
      case RecurrenceType.none:
        return 'Sin recurrencia';
      case RecurrenceType.daily:
        return interval == 1 ? 'Diario' : 'Cada $interval días';
      case RecurrenceType.weekly:
        return interval == 1 ? 'Semanal' : 'Cada $interval semanas';
      case RecurrenceType.monthly:
        return interval == 1 ? 'Mensual' : 'Cada $interval meses';
      case RecurrenceType.yearly:
        return interval == 1 ? 'Anual' : 'Cada $interval años';
      case RecurrenceType.custom:
        return 'Personalizado';
    }
  }
}

/// 📋 ENUMS
enum BloqueoType {
  maintenance('Mantenimiento'),
  lunch('Almuerzo'),
  meeting('Reunión'),
  training('Capacitación'),
  vacation('Vacaciones'),
  sick('Enfermedad'),
  emergency('Emergencia'),
  personal('Personal'),
  custom('Personalizado');

  const BloqueoType(this.displayName);
  final String displayName;
}

enum BloqueoScope {
  global('Global'),
  resource('Recurso Específico'),
  resourceType('Tipo de Recurso');

  const BloqueoScope(this.displayName);
  final String displayName;
}

enum BloqueoSeverity {
  low('Baja'),
  medium('Media'),
  high('Alta'),
  critical('Crítica');

  const BloqueoSeverity(this.displayName);
  final String displayName;
}

enum RecurrenceType {
  none('Sin recurrencia'),
  daily('Diario'),
  weekly('Semanal'),
  monthly('Mensual'),
  yearly('Anual'),
  custom('Personalizado');

  const RecurrenceType(this.displayName);
  final String displayName;
}

// Import necesario para ResourceType
enum ResourceType {
  professional('Profesional'),
  cabina('Cabina'),
  equipment('Equipo'),
  vehicle('Vehículo'),
  other('Otro');

  const ResourceType(this.displayName);
  final String displayName;
}

/// 📊 EXTENSIONES PARA LISTAS DE BLOQUEOS
extension CalendarioBloqueoListExtensions on List<CalendarioBloqueoModel> {
  List<CalendarioBloqueoModel> get active => where((b) => b.isActive).toList();

  List<CalendarioBloqueoModel> get recurring =>
      where((b) => b.recurrencia != null).toList();

  List<CalendarioBloqueoModel> forResource(String resourceId) =>
      where((b) => b.afectaRecurso(resourceId)).toList();

  List<CalendarioBloqueoModel> forResourceType(ResourceType type) =>
      where((b) => b.afectaTipoRecurso(type)).toList();

  List<CalendarioBloqueoModel> forDate(DateTime date) =>
      where((b) => b.isActiveOnDate(date)).toList();

  List<CalendarioBloqueoModel> byType(BloqueoType type) =>
      where((b) => b.tipo == type).toList();

  List<CalendarioBloqueoModel> bySeverity(BloqueoSeverity severity) =>
      where((b) => b.severidad == severity).toList();

  Map<BloqueoType, int> get countByType {
    final counts = <BloqueoType, int>{};
    for (final bloqueo in this) {
      counts[bloqueo.tipo] = (counts[bloqueo.tipo] ?? 0) + 1;
    }
    return counts;
  }

  List<CalendarioBloqueoModel> conflictingWithTimeSlot(
      DateTime dateTime, Duration duration) {
    return where((b) => b.conflictsWithTimeSlot(dateTime, duration)).toList();
  }
}
