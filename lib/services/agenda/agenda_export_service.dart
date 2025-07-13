import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../models/agenda/agenda_resource_model.dart';
import '../../models/agenda/cabina_model.dart';
import '../../models/agenda/calendario_bloqueo_model.dart';

/// 📊 SERVICIO DE EXPORTACIÓN DE DATOS DE AGENDA
/// Maneja exportación a múltiples formatos: CSV, Excel, PDF, JSON
class AgendaExportService {
  static final AgendaExportService _instance = AgendaExportService._internal();
  factory AgendaExportService() => _instance;
  AgendaExportService._internal();

  /// 📈 EXPORTAR CITAS A CSV
  Future<ExportResult> exportAppointmentsToCSV({
    required List<AppointmentModel> appointments,
    required DateRange dateRange,
    ExportConfig? config,
  }) async {
    try {
      final exportConfig = config ?? ExportConfig();
      final csvData = StringBuffer();

      // Headers
      final headers = _getAppointmentHeaders(exportConfig);
      csvData.writeln(headers.join(','));

      // Data rows
      for (final appointment in appointments) {
        final row = _appointmentToCSVRow(appointment, exportConfig);
        csvData.writeln(row.join(','));
      }

      final fileName = _generateFileName('citas', 'csv', dateRange);
      final bytes = utf8.encode(csvData.toString());

      return ExportResult(
        success: true,
        fileName: fileName,
        data: Uint8List.fromList(bytes),
        mimeType: 'text/csv',
        recordCount: appointments.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: 'Error exportando citas a CSV: $e',
      );
    }
  }

  /// 📊 EXPORTAR RECURSOS A CSV
  Future<ExportResult> exportResourcesToCSV({
    required List<AgendaResourceModel> resources,
    ExportConfig? config,
  }) async {
    try {
      final exportConfig = config ?? ExportConfig();
      final csvData = StringBuffer();

      // Headers
      final headers = _getResourceHeaders(exportConfig);
      csvData.writeln(headers.join(','));

      // Data rows
      for (final resource in resources) {
        final row = _resourceToCSVRow(resource, exportConfig);
        csvData.writeln(row.join(','));
      }

      final fileName =
          'recursos_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final bytes = utf8.encode(csvData.toString());

      return ExportResult(
        success: true,
        fileName: fileName,
        data: Uint8List.fromList(bytes),
        mimeType: 'text/csv',
        recordCount: resources.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: 'Error exportando recursos a CSV: $e',
      );
    }
  }

  /// 🏢 EXPORTAR CABINAS A CSV
  Future<ExportResult> exportCabinasToCSV({
    required List<CabinaModel> cabinas,
    ExportConfig? config,
  }) async {
    try {
      final exportConfig = config ?? ExportConfig();
      final csvData = StringBuffer();

      // Headers
      final headers = _getCabinaHeaders(exportConfig);
      csvData.writeln(headers.join(','));

      // Data rows
      for (final cabina in cabinas) {
        final row = _cabinaToCSVRow(cabina, exportConfig);
        csvData.writeln(row.join(','));
      }

      final fileName =
          'cabinas_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final bytes = utf8.encode(csvData.toString());

      return ExportResult(
        success: true,
        fileName: fileName,
        data: Uint8List.fromList(bytes),
        mimeType: 'text/csv',
        recordCount: cabinas.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: 'Error exportando cabinas a CSV: $e',
      );
    }
  }

  /// 🚫 EXPORTAR BLOQUEOS A CSV
  Future<ExportResult> exportBloqueosToCSV({
    required List<CalendarioBloqueoModel> bloqueos,
    required DateRange dateRange,
    ExportConfig? config,
  }) async {
    try {
      final exportConfig = config ?? ExportConfig();
      final csvData = StringBuffer();

      // Headers
      final headers = _getBloqueoHeaders(exportConfig);
      csvData.writeln(headers.join(','));

      // Data rows
      for (final bloqueo in bloqueos) {
        final row = _bloqueoToCSVRow(bloqueo, exportConfig);
        csvData.writeln(row.join(','));
      }

      final fileName = _generateFileName('bloqueos', 'csv', dateRange);
      final bytes = utf8.encode(csvData.toString());

      return ExportResult(
        success: true,
        fileName: fileName,
        data: Uint8List.fromList(bytes),
        mimeType: 'text/csv',
        recordCount: bloqueos.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: 'Error exportando bloqueos a CSV: $e',
      );
    }
  }

  /// 📋 EXPORTAR REPORTE COMPLETO A JSON
  Future<ExportResult> exportCompleteReportToJSON({
    required List<AppointmentModel> appointments,
    required List<AgendaResourceModel> resources,
    required List<CabinaModel> cabinas,
    required List<CalendarioBloqueoModel> bloqueos,
    required DateRange dateRange,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final report = {
        'exportInfo': {
          'timestamp': DateTime.now().toIso8601String(),
          'dateRange': {
            'start': dateRange.start.toIso8601String(),
            'end': dateRange.end.toIso8601String(),
          },
          'version': '1.0',
          'source': 'Agenda Fisio Spa KYM',
        },
        'summary': {
          'totalAppointments': appointments.length,
          'totalResources': resources.length,
          'totalCabinas': cabinas.length,
          'totalBloqueos': bloqueos.length,
          'dateRangeDays': dateRange.days,
        },
        'data': {
          'appointments': appointments.map((a) => a.toMap()).toList(),
          'resources': resources.map((r) => r.toMap()).toList(),
          'cabinas': cabinas.map((c) => c.toMap()).toList(),
          'bloqueos': bloqueos.map((b) => b.toMap()).toList(),
        },
        'statistics':
            _generateStatistics(appointments, resources, cabinas, bloqueos),
        'metadata': metadata ?? {},
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(report);
      final fileName = _generateFileName('reporte_completo', 'json', dateRange);
      final bytes = utf8.encode(jsonString);

      return ExportResult(
        success: true,
        fileName: fileName,
        data: Uint8List.fromList(bytes),
        mimeType: 'application/json',
        recordCount: appointments.length +
            resources.length +
            cabinas.length +
            bloqueos.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: 'Error generando reporte completo: $e',
      );
    }
  }

  /// 📊 EXPORTAR ESTADÍSTICAS A JSON
  Future<ExportResult> exportStatisticsToJSON({
    required List<AppointmentModel> appointments,
    required List<AgendaResourceModel> resources,
    required List<CabinaModel> cabinas,
    required DateRange dateRange,
  }) async {
    try {
      final statistics = _generateDetailedStatistics(
          appointments, resources, cabinas, dateRange);

      final jsonString = const JsonEncoder.withIndent('  ').convert(statistics);
      final fileName = _generateFileName('estadisticas', 'json', dateRange);
      final bytes = utf8.encode(jsonString);

      return ExportResult(
        success: true,
        fileName: fileName,
        data: Uint8List.fromList(bytes),
        mimeType: 'application/json',
        recordCount: 1, // Un objeto de estadísticas
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: 'Error generando estadísticas: $e',
      );
    }
  }

  /// 🎯 EXPORTAR DATOS PERSONALIZADOS
  Future<ExportResult> exportCustomData({
    required Map<String, dynamic> data,
    required String fileName,
    required ExportFormat format,
    ExportConfig? config,
  }) async {
    try {
      switch (format) {
        case ExportFormat.json:
          return _exportToJSON(data, fileName);
        case ExportFormat.csv:
          return _exportToCSV(data, fileName, config);
        default:
          return ExportResult(
            success: false,
            error: 'Formato no soportado: $format',
          );
      }
    } catch (e) {
      return ExportResult(
        success: false,
        error: 'Error en exportación personalizada: $e',
      );
    }
  }

  /// 📋 GENERAR HEADERS PARA CITAS
  List<String> _getAppointmentHeaders(ExportConfig config) {
    final headers = <String>[
      'ID',
      'Cliente',
      'Profesional',
      'Servicio',
      'Fecha',
      'Hora Inicio',
      'Hora Fin',
      'Duración (min)',
      'Estado',
    ];

    if (config.includeContactInfo) {
      headers.addAll(['Email Cliente', 'Teléfono Cliente']);
    }

    if (config.includeMetadata) {
      headers.addAll(['Creado En', 'Actualizado En', 'Comentarios']);
    }

    return headers;
  }

  /// 🏢 GENERAR HEADERS PARA RECURSOS
  List<String> _getResourceHeaders(ExportConfig config) {
    final headers = <String>[
      'ID',
      'Nombre',
      'Tipo',
      'Estado',
      'Especialidades',
      'Servicios Disponibles',
    ];

    if (config.includeContactInfo) {
      headers.addAll(['Email', 'Teléfono']);
    }

    if (config.includeMetadata) {
      headers.addAll(['Citas Hoy', 'Ocupación %', 'Creado En']);
    }

    return headers;
  }

  /// 🏠 GENERAR HEADERS PARA CABINAS
  List<String> _getCabinaHeaders(ExportConfig config) {
    final headers = <String>[
      'ID',
      'Nombre',
      'Tipo',
      'Estado',
      'Capacidad',
      'Área (m²)',
      'Ubicación',
      'Equipamiento',
      'Tarifa/Hora',
    ];

    if (config.includeMetadata) {
      headers
          .addAll(['Tiempo Limpieza', 'Próximo Mantenimiento', 'Responsable']);
    }

    return headers;
  }

  /// 🚫 GENERAR HEADERS PARA BLOQUEOS
  List<String> _getBloqueoHeaders(ExportConfig config) {
    final headers = <String>[
      'ID',
      'Nombre',
      'Tipo',
      'Severidad',
      'Fecha Inicio',
      'Fecha Fin',
      'Hora Inicio',
      'Hora Fin',
      'Recursos Afectados',
      'Recurrente',
    ];

    if (config.includeMetadata) {
      headers.addAll(['Creado Por', 'Creado En', 'Descripción']);
    }

    return headers;
  }

  /// 📊 CONVERTIR CITA A FILA CSV
  List<String> _appointmentToCSVRow(
      AppointmentModel appointment, ExportConfig config) {
    final row = <String>[
      _escapeCsv(appointment.id),
      _escapeCsv(appointment.nombreCliente ?? ''),
      _escapeCsv(appointment.profesionalNombre ?? ''),
      _escapeCsv(appointment.servicioNombre ?? ''),
      _escapeCsv(appointment.fechaFormateada),
      _escapeCsv(appointment.horaCita),
      _escapeCsv(appointment.fechaFin != null
          ? DateFormat.Hm().format(appointment.fechaFin!)
          : ''),
      _escapeCsv((appointment.duracion ?? 0).toString()),
      _escapeCsv(appointment.estado ?? ''),
    ];

    if (config.includeContactInfo) {
      row.addAll([
        _escapeCsv(appointment.clientEmail ?? ''),
        _escapeCsv(appointment.clientPhone ?? ''),
      ]);
    }

    if (config.includeMetadata) {
      row.addAll([
        _escapeCsv(appointment.creadoEn != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(appointment.creadoEn!)
            : ''),
        _escapeCsv(appointment.updatedAt != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(appointment.updatedAt!)
            : ''),
        _escapeCsv(appointment.comentarios ?? ''),
      ]);
    }

    return row;
  }

  /// 🏢 CONVERTIR RECURSO A FILA CSV
  List<String> _resourceToCSVRow(
      AgendaResourceModel resource, ExportConfig config) {
    final row = <String>[
      _escapeCsv(resource.resourceId),
      _escapeCsv(resource.resourceName),
      _escapeCsv(resource.resourceType.displayName),
      _escapeCsv(resource.status.displayName),
      _escapeCsv(resource.especialidades.join('; ')),
      _escapeCsv(resource.serviciosDisponibles.join('; ')),
    ];

    if (config.includeContactInfo) {
      row.addAll([
        _escapeCsv(resource.professionalInfo?.email ?? ''),
        _escapeCsv(resource.professionalInfo?.telefono ?? ''),
      ]);
    }

    if (config.includeMetadata) {
      row.addAll([
        _escapeCsv(resource.appointmentsToday.toString()),
        _escapeCsv(resource.occupancyPercentage.toStringAsFixed(1)),
        _escapeCsv(resource.createdAt != null
            ? DateFormat('dd/MM/yyyy').format(resource.createdAt!)
            : ''),
      ]);
    }

    return row;
  }

  /// 🏠 CONVERTIR CABINA A FILA CSV
  List<String> _cabinaToCSVRow(CabinaModel cabina, ExportConfig config) {
    final row = <String>[
      _escapeCsv(cabina.cabinaId),
      _escapeCsv(cabina.nombre),
      _escapeCsv(cabina.tipo.displayName),
      _escapeCsv(cabina.estado.displayName),
      _escapeCsv(cabina.capacidad.toString()),
      _escapeCsv(cabina.area.toString()),
      _escapeCsv(cabina.ubicacion ?? ''),
      _escapeCsv(cabina.equipamiento.join('; ')),
      _escapeCsv(cabina.tarifaPorHora.toString()),
    ];

    if (config.includeMetadata) {
      row.addAll([
        _escapeCsv(cabina.tiempoLimpieza.toString()),
        _escapeCsv(cabina.proximoMantenimientoFormatted),
        _escapeCsv(cabina.responsable ?? ''),
      ]);
    }

    return row;
  }

  /// 🚫 CONVERTIR BLOQUEO A FILA CSV
  List<String> _bloqueoToCSVRow(
      CalendarioBloqueoModel bloqueo, ExportConfig config) {
    final row = <String>[
      _escapeCsv(bloqueo.bloqueoId),
      _escapeCsv(bloqueo.nombre),
      _escapeCsv(bloqueo.tipo.displayName),
      _escapeCsv(bloqueo.severidad.displayName),
      _escapeCsv(bloqueo.fechaInicioFormatted),
      _escapeCsv(bloqueo.fechaFinFormatted),
      _escapeCsv(bloqueo.horaInicioFormatted),
      _escapeCsv(bloqueo.horaFinFormatted),
      _escapeCsv(bloqueo.recursosAfectados.join('; ')),
      _escapeCsv(bloqueo.recurrencia != null ? 'Sí' : 'No'),
    ];

    if (config.includeMetadata) {
      row.addAll([
        _escapeCsv(bloqueo.creadoPor),
        _escapeCsv(DateFormat('dd/MM/yyyy HH:mm').format(bloqueo.creadoEn)),
        _escapeCsv(bloqueo.descripcion ?? ''),
      ]);
    }

    return row;
  }

  /// 📊 GENERAR ESTADÍSTICAS BÁSICAS
  Map<String, dynamic> _generateStatistics(
    List<AppointmentModel> appointments,
    List<AgendaResourceModel> resources,
    List<CabinaModel> cabinas,
    List<CalendarioBloqueoModel> bloqueos,
  ) {
    final appointmentStats = appointments.estadisticasPorEstado;
    final resourceStats = resources.countByType;
    final cabinaStats = cabinas.countByTipo;

    return {
      'appointments': {
        'total': appointments.length,
        'byStatus': appointmentStats,
        'averageDuration': appointments.duracionPromedio,
      },
      'resources': {
        'total': resources.length,
        'byType': resourceStats.map((k, v) => MapEntry(k.name, v)),
        'averageOccupancy': resources.averageOccupancy,
      },
      'cabinas': {
        'total': cabinas.length,
        'byType': cabinaStats.map((k, v) => MapEntry(k.name, v)),
        'totalCapacity': cabinas.capacidadTotal,
        'averageOccupancy': cabinas.ocupacionPromedio,
      },
      'bloqueos': {
        'total': bloqueos.length,
        'active': bloqueos.active.length,
        'recurring': bloqueos.recurring.length,
      },
    };
  }

  /// 📈 GENERAR ESTADÍSTICAS DETALLADAS
  Map<String, dynamic> _generateDetailedStatistics(
    List<AppointmentModel> appointments,
    List<AgendaResourceModel> resources,
    List<CabinaModel> cabinas,
    DateRange dateRange,
  ) {
    final now = DateTime.now();
    final citasHoy = appointments.citasHoy;
    final citasManana = appointments.citasManana;

    return {
      'period': {
        'start': dateRange.start.toIso8601String(),
        'end': dateRange.end.toIso8601String(),
        'days': dateRange.days,
        'generatedAt': now.toIso8601String(),
      },
      'appointments': {
        'total': appointments.length,
        'today': citasHoy.length,
        'tomorrow': citasManana.length,
        'byStatus': appointments.estadisticasPorEstado,
        'averageDuration': appointments.duracionPromedio,
        'totalDuration':
            appointments.fold(0, (sum, a) => sum + (a.duracion ?? 60)),
      },
      'resources': {
        'total': resources.length,
        'available': resources.available.length,
        'busy': resources.busy.length,
        'professionals': resources.professionals.length,
        'cabinas': resources.cabinas.length,
        'averageOccupancy': resources.averageOccupancy,
      },
      'cabinas': {
        'total': cabinas.length,
        'available': cabinas.disponibles.length,
        'totalCapacity': cabinas.capacidadTotal,
        'averageOccupancy': cabinas.ocupacionPromedio,
        'requireMaintenance': cabinas.requierenMantenimiento.length,
      },
      'efficiency': {
        'appointmentsPerResource':
            resources.isNotEmpty ? appointments.length / resources.length : 0,
        'occupancyRate': resources.averageOccupancy,
        'utilizationRate': cabinas.ocupacionPromedio,
      },
    };
  }

  /// 🔧 MÉTODOS HELPER
  Future<ExportResult> _exportToJSON(
      Map<String, dynamic> data, String fileName) async {
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final bytes = utf8.encode(jsonString);

    return ExportResult(
      success: true,
      fileName: fileName.endsWith('.json') ? fileName : '$fileName.json',
      data: Uint8List.fromList(bytes),
      mimeType: 'application/json',
      recordCount: 1,
    );
  }

  Future<ExportResult> _exportToCSV(
      Map<String, dynamic> data, String fileName, ExportConfig? config) async {
    // Implementación básica para datos planos
    final csvData = StringBuffer();

    if (data.isNotEmpty) {
      final keys = data.keys.toList();
      csvData.writeln(keys.join(','));

      final values =
          keys.map((key) => _escapeCsv(data[key]?.toString() ?? '')).toList();
      csvData.writeln(values.join(','));
    }

    final bytes = utf8.encode(csvData.toString());

    return ExportResult(
      success: true,
      fileName: fileName.endsWith('.csv') ? fileName : '$fileName.csv',
      data: Uint8List.fromList(bytes),
      mimeType: 'text/csv',
      recordCount: 1,
    );
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _generateFileName(
      String prefix, String extension, DateRange dateRange) {
    final startDate = DateFormat('yyyyMMdd').format(dateRange.start);
    final endDate = DateFormat('yyyyMMdd').format(dateRange.end);
    final timestamp = DateFormat('HHmmss').format(DateTime.now());
    return '${prefix}_${startDate}_${endDate}_$timestamp.$extension';
  }
}

/// 📊 RESULTADO DE EXPORTACIÓN
class ExportResult {
  final bool success;
  final String? fileName;
  final Uint8List? data;
  final String? mimeType;
  final int? recordCount;
  final String? error;
  final Map<String, dynamic>? metadata;

  ExportResult({
    required this.success,
    this.fileName,
    this.data,
    this.mimeType,
    this.recordCount,
    this.error,
    this.metadata,
  });

  bool get hasData => data != null && data!.isNotEmpty;
  int get fileSizeBytes => data?.length ?? 0;
  String get fileSizeFormatted {
    final bytes = fileSizeBytes;
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// ⚙️ CONFIGURACIÓN DE EXPORTACIÓN
class ExportConfig {
  final bool includeContactInfo;
  final bool includeMetadata;
  final bool includeStatistics;
  final String dateFormat;
  final String timeFormat;
  final String encoding;
  final String csvDelimiter;
  final List<String>? columnsToInclude;
  final List<String>? columnsToExclude;

  ExportConfig({
    this.includeContactInfo = true,
    this.includeMetadata = false,
    this.includeStatistics = true,
    this.dateFormat = 'dd/MM/yyyy',
    this.timeFormat = 'HH:mm',
    this.encoding = 'utf-8',
    this.csvDelimiter = ',',
    this.columnsToInclude,
    this.columnsToExclude,
  });
}

/// 📋 FORMATOS DE EXPORTACIÓN
enum ExportFormat {
  csv('CSV'),
  json('JSON'),
  excel('Excel'),
  pdf('PDF');

  const ExportFormat(this.displayName);
  final String displayName;
}

/// 📅 RANGO DE FECHAS PARA EXPORTACIÓN
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);

  int get days => end.difference(start).inDays + 1;

  bool contains(DateTime date) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  @override
  String toString() {
    return '${DateFormat('dd/MM/yyyy').format(start)} - ${DateFormat('dd/MM/yyyy').format(end)}';
  }
}
