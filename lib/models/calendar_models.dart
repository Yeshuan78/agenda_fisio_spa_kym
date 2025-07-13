import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 📅 MODELO PRINCIPAL DE CALENDARIO
/// Compatible con estructura Firestore: calendarios/{profesionalId}
class CalendarModel {
  final String calendarId;
  final String calendarName;
  final String profesionalId;
  final List<AvailableDayModel> availableDays;
  final Map<String, dynamic>? configuracion;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  CalendarModel({
    required this.calendarId,
    required this.calendarName,
    required this.profesionalId,
    this.availableDays = const [],
    this.configuracion,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// 🏗️ FACTORY DESDE FIRESTORE
  factory CalendarModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CalendarModel.fromMap(data, doc.id);
  }

  factory CalendarModel.fromMap(Map<String, dynamic> data, String id) {
    // Parse available days
    final availableDaysData = data['availableDays'] as List<dynamic>? ?? [];
    final availableDays = availableDaysData
        .map((dayData) =>
            AvailableDayModel.fromMap(dayData as Map<String, dynamic>))
        .toList();

    return CalendarModel(
      calendarId: id,
      calendarName: data['calendarName'] ?? 'Calendario',
      profesionalId: data['profesionalId'] ?? id,
      availableDays: availableDays,
      configuracion: data['configuracion'],
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      isActive: data['isActive'] ?? true,
    );
  }

  /// 💾 CONVERSIÓN A MAP PARA FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'calendarName': calendarName,
      'profesionalId': profesionalId,
      'availableDays': availableDays.map((day) => day.toMap()).toList(),
      'configuracion': configuracion,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': isActive,
    };
  }

  /// 🔍 MÉTODOS DE CONSULTA
  AvailableDayModel? getDayConfig(String dayName) {
    try {
      return availableDays.firstWhere(
        (day) => day.dia.toLowerCase() == dayName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  bool isAvailableOnDay(String dayName) {
    final dayConfig = getDayConfig(dayName);
    return dayConfig != null && dayConfig.isActive;
  }

  List<String> get activeDays {
    return availableDays
        .where((day) => day.isActive)
        .map((day) => day.dia)
        .toList();
  }

  /// 📅 GENERADOR DE SLOTS DISPONIBLES
  List<DateTime> generateAvailableSlots({
    required DateTime date,
    required int intervalMinutes,
    int? serviceDurationMinutes,
  }) {
    final dayName = _getDayName(date);
    final dayConfig = getDayConfig(dayName);

    if (dayConfig == null || !dayConfig.isActive) return [];

    final slots = <DateTime>[];
    final serviceMinutes = serviceDurationMinutes ?? 60;

    DateTime current = DateTime(
      date.year,
      date.month,
      date.day,
      dayConfig.inicioHour,
      dayConfig.inicioMinute,
    );

    final endTime = DateTime(
      date.year,
      date.month,
      date.day,
      dayConfig.finHour,
      dayConfig.finMinute,
    );

    while (current.add(Duration(minutes: serviceMinutes)).isBefore(endTime) ||
        current
            .add(Duration(minutes: serviceMinutes))
            .isAtSameMomentAs(endTime)) {
      // Verificar que no esté en un bloqueo
      if (!dayConfig.isTimeBlocked(current)) {
        slots.add(current);
      }

      current = current.add(Duration(minutes: intervalMinutes));
    }

    return slots;
  }

  /// 🔄 COPYWIHT
  CalendarModel copyWith({
    String? calendarId,
    String? calendarName,
    String? profesionalId,
    List<AvailableDayModel>? availableDays,
    Map<String, dynamic>? configuracion,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return CalendarModel(
      calendarId: calendarId ?? this.calendarId,
      calendarName: calendarName ?? this.calendarName,
      profesionalId: profesionalId ?? this.profesionalId,
      availableDays: availableDays ?? this.availableDays,
      configuracion: configuracion ?? this.configuracion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
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
}

/// 📅 MODELO DE DÍA DISPONIBLE
/// Compatible con estructura: availableDays[].dia, inicio, fin, etc.
class AvailableDayModel {
  final String dia; // lunes, martes, etc.
  final int inicioHour;
  final int inicioMinute;
  final int finHour;
  final int finMinute;
  final String nombre;
  final List<BlockModel> bloques;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  AvailableDayModel({
    required this.dia,
    this.inicioHour = 9,
    this.inicioMinute = 0,
    this.finHour = 18,
    this.finMinute = 0,
    this.nombre = 'Disponible',
    this.bloques = const [],
    this.isActive = true,
    this.metadata,
  });

  factory AvailableDayModel.fromMap(Map<String, dynamic> data) {
    // Parse inicio/fin time
    final inicioTime = _parseTimeString(data['inicio'] ?? '09:00');
    final finTime = _parseTimeString(data['fin'] ?? '18:00');

    // Parse bloques
    final bloquesData = data['bloques'] as List<dynamic>? ?? [];
    final bloques = bloquesData
        .map((blockData) =>
            BlockModel.fromMap(blockData as Map<String, dynamic>))
        .toList();

    return AvailableDayModel(
      dia: data['dia'] ?? '',
      inicioHour: inicioTime.hour,
      inicioMinute: inicioTime.minute,
      finHour: finTime.hour,
      finMinute: finTime.minute,
      nombre: data['nombre'] ?? 'Disponible',
      bloques: bloques,
      isActive: data['isActive'] ?? true,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dia': dia,
      'inicio':
          '${inicioHour.toString().padLeft(2, '0')}:${inicioMinute.toString().padLeft(2, '0')}',
      'fin':
          '${finHour.toString().padLeft(2, '0')}:${finMinute.toString().padLeft(2, '0')}',
      'nombre': nombre,
      'bloques': bloques.map((block) => block.toMap()).toList(),
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  /// 🕐 GETTERS DE TIEMPO
  TimeOfDay get inicioTime => TimeOfDay(hour: inicioHour, minute: inicioMinute);
  TimeOfDay get finTime => TimeOfDay(hour: finHour, minute: finMinute);

  String get inicioFormatted =>
      '${inicioHour.toString().padLeft(2, '0')}:${inicioMinute.toString().padLeft(2, '0')}';
  String get finFormatted =>
      '${finHour.toString().padLeft(2, '0')}:${finMinute.toString().padLeft(2, '0')}';

  Duration get workingHours {
    final inicio = Duration(hours: inicioHour, minutes: inicioMinute);
    final fin = Duration(hours: finHour, minutes: finMinute);
    return fin - inicio;
  }

  /// 🚫 VALIDACIÓN DE BLOQUEOS
  bool isTimeBlocked(DateTime dateTime) {
    final timeToCheck = TimeOfDay.fromDateTime(dateTime);

    for (final bloque in bloques) {
      if (bloque.isTimeInBlock(timeToCheck)) {
        return true;
      }
    }
    return false;
  }

  bool isTimeAvailable(DateTime dateTime) {
    final timeToCheck = TimeOfDay.fromDateTime(dateTime);

    // Verificar que esté dentro del horario laboral
    final timeMinutes = timeToCheck.hour * 60 + timeToCheck.minute;
    final inicioMinutes = inicioHour * 60 + inicioMinute;
    final finMinutes = finHour * 60 + finMinute;

    if (timeMinutes < inicioMinutes || timeMinutes >= finMinutes) {
      return false;
    }

    // Verificar que no esté bloqueado
    return !isTimeBlocked(dateTime);
  }

  /// 🔄 COPYWIHT
  AvailableDayModel copyWith({
    String? dia,
    int? inicioHour,
    int? inicioMinute,
    int? finHour,
    int? finMinute,
    String? nombre,
    List<BlockModel>? bloques,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return AvailableDayModel(
      dia: dia ?? this.dia,
      inicioHour: inicioHour ?? this.inicioHour,
      inicioMinute: inicioMinute ?? this.inicioMinute,
      finHour: finHour ?? this.finHour,
      finMinute: finMinute ?? this.finMinute,
      nombre: nombre ?? this.nombre,
      bloques: bloques ?? this.bloques,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  static TimeOfDay _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 9, minute: 0); // Default
    }
  }
}

/// 🚫 MODELO DE BLOQUEO
/// Compatible con estructura: bloques[].inicio, fin, nombre, etc.
class BlockModel {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String nombre;
  final String? motivo;
  final String tipo; // 'almuerzo', 'mantenimiento', 'personal', 'evento'
  final bool isRecurrent;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  BlockModel({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.nombre,
    this.motivo,
    this.tipo = 'personal',
    this.isRecurrent = false,
    this.createdAt,
    this.metadata,
  });

  factory BlockModel.fromMap(Map<String, dynamic> data) {
    // Compatibilidad con estructura existente
    final startTime = _parseTimeString(data['inicio'] ?? '12:00');
    final endTime = _parseTimeString(data['fin'] ?? '13:00');

    return BlockModel(
      startHour: data['startHour'] ?? startTime.hour,
      startMinute: data['startMinute'] ?? startTime.minute,
      endHour: data['endHour'] ?? endTime.hour,
      endMinute: data['endMinute'] ?? endTime.minute,
      nombre: data['nombre'] ?? 'Bloqueo',
      motivo: data['motivo'],
      tipo: data['tipo'] ?? 'personal',
      isRecurrent: data['isRecurrent'] ?? false,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'inicio': startFormatted, // Compatibilidad con estructura existente
      'fin': endFormatted,
      'nombre': nombre,
      'motivo': motivo,
      'tipo': tipo,
      'isRecurrent': isRecurrent,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'metadata': metadata,
    };
  }

  /// 🕐 GETTERS DE TIEMPO
  TimeOfDay get startTime => TimeOfDay(hour: startHour, minute: startMinute);
  TimeOfDay get endTime => TimeOfDay(hour: endHour, minute: endMinute);

  String get startFormatted =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  String get endFormatted =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  Duration get duration {
    final start = Duration(hours: startHour, minutes: startMinute);
    final end = Duration(hours: endHour, minutes: endMinute);
    return end - start;
  }

  /// 🎨 COLOR BASADO EN TIPO
  Color get color {
    switch (tipo.toLowerCase()) {
      case 'almuerzo':
        return Colors.orange.shade400;
      case 'mantenimiento':
        return Colors.red.shade400;
      case 'personal':
        return Colors.blue.shade400;
      case 'evento':
        return Colors.purple.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  /// 🔍 VALIDACIONES
  bool isTimeInBlock(TimeOfDay time) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    return timeMinutes >= startMinutes && timeMinutes < endMinutes;
  }

  bool overlapsWithTime(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final blockStartMinutes = startHour * 60 + startMinute;
    final blockEndMinutes = endHour * 60 + endMinute;

    return !(endMinutes <= blockStartMinutes ||
        startMinutes >= blockEndMinutes);
  }

  /// 🔄 COPYWIHT
  BlockModel copyWith({
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    String? nombre,
    String? motivo,
    String? tipo,
    bool? isRecurrent,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return BlockModel(
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      nombre: nombre ?? this.nombre,
      motivo: motivo ?? this.motivo,
      tipo: tipo ?? this.tipo,
      isRecurrent: isRecurrent ?? this.isRecurrent,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  static TimeOfDay _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 12, minute: 0); // Default
    }
  }
}

/// ⚙️ MODELO DE CONFIGURACIÓN DE CALENDARIO
class CalendarConfigModel {
  final int defaultSlotDuration; // Duración default de slots en minutos
  final int defaultServiceDuration; // Duración default de servicios
  final List<int> availableSlotDurations; // [15, 30, 45, 60] minutos
  final TimeOfDay defaultStartTime;
  final TimeOfDay defaultEndTime;
  final List<String> workingDays;
  final String timezone;
  final bool allowOverlapping;
  final bool autoConfirmBookings;
  final int maxAdvanceBookingDays;
  final Map<String, dynamic>? customSettings;

  CalendarConfigModel({
    this.defaultSlotDuration = 30,
    this.defaultServiceDuration = 60,
    this.availableSlotDurations = const [15, 30, 45, 60],
    this.defaultStartTime = const TimeOfDay(hour: 9, minute: 0),
    this.defaultEndTime = const TimeOfDay(hour: 18, minute: 0),
    this.workingDays = const [
      'lunes',
      'martes',
      'miercoles',
      'jueves',
      'viernes'
    ],
    this.timezone = 'America/Mexico_City',
    this.allowOverlapping = false,
    this.autoConfirmBookings = false,
    this.maxAdvanceBookingDays = 30,
    this.customSettings,
  });

  factory CalendarConfigModel.fromMap(Map<String, dynamic> data) {
    return CalendarConfigModel(
      defaultSlotDuration: data['defaultSlotDuration'] ?? 30,
      defaultServiceDuration: data['defaultServiceDuration'] ?? 60,
      availableSlotDurations:
          List<int>.from(data['availableSlotDurations'] ?? [15, 30, 45, 60]),
      defaultStartTime: _parseTimeFromMap(data['defaultStartTime']) ??
          const TimeOfDay(hour: 9, minute: 0),
      defaultEndTime: _parseTimeFromMap(data['defaultEndTime']) ??
          const TimeOfDay(hour: 18, minute: 0),
      workingDays: List<String>.from(data['workingDays'] ??
          ['lunes', 'martes', 'miercoles', 'jueves', 'viernes']),
      timezone: data['timezone'] ?? 'America/Mexico_City',
      allowOverlapping: data['allowOverlapping'] ?? false,
      autoConfirmBookings: data['autoConfirmBookings'] ?? false,
      maxAdvanceBookingDays: data['maxAdvanceBookingDays'] ?? 30,
      customSettings: data['customSettings'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'defaultSlotDuration': defaultSlotDuration,
      'defaultServiceDuration': defaultServiceDuration,
      'availableSlotDurations': availableSlotDurations,
      'defaultStartTime': {
        'hour': defaultStartTime.hour,
        'minute': defaultStartTime.minute
      },
      'defaultEndTime': {
        'hour': defaultEndTime.hour,
        'minute': defaultEndTime.minute
      },
      'workingDays': workingDays,
      'timezone': timezone,
      'allowOverlapping': allowOverlapping,
      'autoConfirmBookings': autoConfirmBookings,
      'maxAdvanceBookingDays': maxAdvanceBookingDays,
      'customSettings': customSettings,
    };
  }

  static TimeOfDay? _parseTimeFromMap(dynamic timeData) {
    if (timeData is Map<String, dynamic>) {
      return TimeOfDay(
        hour: timeData['hour'] ?? 9,
        minute: timeData['minute'] ?? 0,
      );
    }
    return null;
  }
}

/// 📊 EXTENSIÓN PARA ESTADÍSTICAS DE CALENDARIO
extension CalendarModelStats on CalendarModel {
  int get totalWorkingHours {
    return availableDays.where((day) => day.isActive).fold(0, (sum, day) {
      return sum + day.workingHours.inHours;
    });
  }

  int get totalBlocks {
    return availableDays.fold(0, (sum, day) => sum + day.bloques.length);
  }

  List<String> get availableDayNames {
    return availableDays
        .where((day) => day.isActive)
        .map((day) => day.dia)
        .toList();
  }

  double get averageWorkingHoursPerDay {
    final activeDays = availableDays.where((day) => day.isActive).toList();
    if (activeDays.isEmpty) return 0.0;

    final totalHours = activeDays.fold(
        0.0, (sum, day) => sum + day.workingHours.inMinutes / 60.0);
    return totalHours / activeDays.length;
  }
}
