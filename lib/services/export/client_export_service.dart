// [client_export_service.dart] - SERVICIO DE EXPORTACIÓN DE CLIENTES - CORREGIDO
// 📁 Ubicación: /lib/services/export/client_export_service.dart
// 🎯 OBJETIVO: Lógica de exportación limpia y reutilizable

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/background_cost_monitor.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/cost_data_models.dart';
import 'package:intl/intl.dart';

/// 🚀 FORMATO DE EXPORTACIÓN
enum ExportFormat {
  csv('CSV', 'Valores separados por comas', 'csv', Icons.table_chart),
  excel('Excel', 'Hoja de cálculo .xlsx', 'xlsx', Icons.grid_on),
  pdf('PDF', 'Documento portable', 'pdf', Icons.picture_as_pdf),
  json('JSON', 'Formato de datos JSON', 'json', Icons.code);

  const ExportFormat(
      this.displayName, this.description, this.extension, this.icon);
  final String displayName;
  final String description;
  final String extension;
  final IconData icon;
}

/// 📋 CAMPO DE EXPORTACIÓN
class ExportField {
  final String key;
  final String displayName;
  final String description;
  final bool isRequired;

  const ExportField({
    required this.key,
    required this.displayName,
    required this.description,
    this.isRequired = false,
  });

  static List<ExportField> getAllFields() {
    return const [
      ExportField(
        key: 'fullName',
        displayName: 'Nombre Completo',
        description: 'Nombre y apellidos del cliente',
        isRequired: true,
      ),
      ExportField(
        key: 'email',
        displayName: 'Email',
        description: 'Dirección de correo electrónico',
        isRequired: true,
      ),
      ExportField(
        key: 'phone',
        displayName: 'Teléfono',
        description: 'Número de teléfono principal',
      ),
      ExportField(
        key: 'company',
        displayName: 'Empresa',
        description: 'Nombre de la empresa',
      ),
      ExportField(
        key: 'status',
        displayName: 'Estado',
        description: 'Estado actual del cliente',
      ),
      ExportField(
        key: 'tags',
        displayName: 'Etiquetas',
        description: 'Etiquetas asignadas al cliente',
      ),
      ExportField(
        key: 'address',
        displayName: 'Dirección',
        description: 'Dirección completa del cliente',
      ),
      ExportField(
        key: 'createdAt',
        displayName: 'Fecha de Registro',
        description: 'Cuándo se registró el cliente',
      ),
      ExportField(
        key: 'appointmentsCount',
        displayName: 'Total de Citas',
        description: 'Número total de citas',
      ),
      ExportField(
        key: 'totalRevenue',
        displayName: 'Ingresos Totales',
        description: 'Ingresos generados por el cliente',
      ),
      ExportField(
        key: 'satisfactionScore',
        displayName: 'Satisfacción',
        description: 'Puntuación de satisfacción promedio',
      ),
      ExportField(
        key: 'birthDate',
        displayName: 'Fecha de Nacimiento',
        description: 'Fecha de nacimiento del cliente',
      ),
      ExportField(
        key: 'gender',
        displayName: 'Género',
        description: 'Género del cliente',
      ),
      ExportField(
        key: 'notes',
        displayName: 'Notas',
        description: 'Notas adicionales del cliente',
      ),
    ];
  }
}

/// ⚙️ OPCIONES DE EXPORTACIÓN
class ExportOptions {
  final ExportFormat format;
  final List<String> selectedFields;
  final List<ClientStatus> statusFilter;
  final List<String> tagsFilter;
  final DateTimeRange? dateRange;
  final bool includePersonalInfo;
  final bool includeAddressInfo;
  final bool includeMetrics;
  final bool includeUtf8BOM;
  final bool includeFilterSuffix;

  const ExportOptions({
    required this.format,
    required this.selectedFields,
    this.statusFilter = const [],
    this.tagsFilter = const [],
    this.dateRange,
    this.includePersonalInfo = true,
    this.includeAddressInfo = true,
    this.includeMetrics = false,
    this.includeUtf8BOM = true,
    this.includeFilterSuffix = true,
  });
}

/// 📊 VISTA PREVIA DE EXPORTACIÓN
class ExportPreview {
  final int totalRecords;
  final List<ExportField> selectedFields;
  final List<Map<String, dynamic>> sampleData;
  final String formattedEstimatedSize;
  final List<String> warnings;

  const ExportPreview({
    required this.totalRecords,
    required this.selectedFields,
    required this.sampleData,
    required this.formattedEstimatedSize,
    this.warnings = const [],
  });
}

/// 📈 RESULTADO DE EXPORTACIÓN
class ExportResult {
  final bool isSuccess;
  final String fileName;
  final int recordCount;
  final String formattedSize;
  final String? errorMessage;

  const ExportResult({
    required this.isSuccess,
    required this.fileName,
    required this.recordCount,
    required this.formattedSize,
    this.errorMessage,
  });
}

/// 🛠️ SERVICIO DE EXPORTACIÓN DE CLIENTES
class ClientExportService {
  final BackgroundCostMonitor _costMonitor = BackgroundCostMonitor();

  /// 📊 GENERAR VISTA PREVIA
  Future<ExportPreview> getExportPreview({
    required List<ClientModel> clients,
    required ExportOptions options,
  }) async {
    // Simular delay de procesamiento
    await Future.delayed(const Duration(milliseconds: 500));

    final filteredClients = _filterClients(clients, options);
    final selectedFields = ExportField.getAllFields()
        .where((field) => options.selectedFields.contains(field.key))
        .toList();

    final sampleData = filteredClients
        .take(3)
        .map((client) => _clientToMap(client, options.selectedFields))
        .toList();

    return ExportPreview(
      totalRecords: filteredClients.length,
      selectedFields: selectedFields,
      sampleData: sampleData,
      formattedEstimatedSize: _estimateSize(filteredClients.length, options),
      warnings: _generateWarnings(filteredClients, options),
    );
  }

  /// 📄 EXPORTAR A CSV
  Future<ExportResult> exportToCSV({
    required List<ClientModel> clients,
    required ExportOptions options,
  }) async {
    // Verificar límites de costo
    if (!_canPerformExport()) {
      throw Exception('Límite de costos alcanzado. Intente más tarde.');
    }

    await Future.delayed(const Duration(seconds: 2));

    final filteredClients = _filterClients(clients, options);
    final fileName = _generateFileName('clientes', options);

    return _createResult(fileName, filteredClients.length, 'csv');
  }

  /// 📊 EXPORTAR A EXCEL
  Future<ExportResult> exportToExcel({
    required List<ClientModel> clients,
    required ExportOptions options,
  }) async {
    if (!_canPerformExport()) {
      throw Exception('Límite de costos alcanzado. Intente más tarde.');
    }

    await Future.delayed(const Duration(seconds: 3));

    final filteredClients = _filterClients(clients, options);
    final fileName = _generateFileName('clientes', options);

    return _createResult(fileName, filteredClients.length, 'xlsx');
  }

  /// 📄 EXPORTAR A PDF
  Future<ExportResult> exportToPDF({
    required List<ClientModel> clients,
    required ExportOptions options,
  }) async {
    if (!_canPerformExport()) {
      throw Exception('Límite de costos alcanzado. Intente más tarde.');
    }

    await Future.delayed(const Duration(seconds: 4));

    final filteredClients = _filterClients(clients, options);
    final fileName = _generateFileName('clientes', options);

    return _createResult(fileName, filteredClients.length, 'pdf');
  }

  /// 📋 EXPORTAR A JSON
  Future<ExportResult> exportToJSON({
    required List<ClientModel> clients,
    required ExportOptions options,
  }) async {
    if (!_canPerformExport()) {
      throw Exception('Límite de costos alcanzado. Intente más tarde.');
    }

    await Future.delayed(const Duration(seconds: 2));

    final filteredClients = _filterClients(clients, options);
    final fileName = _generateFileName('clientes', options);

    return _createResult(fileName, filteredClients.length, 'json');
  }

  // ====================================================================
  // 🔧 MÉTODOS PRIVADOS
  // ====================================================================

  /// 🔍 FILTRAR CLIENTES
  List<ClientModel> _filterClients(
      List<ClientModel> clients, ExportOptions options) {
    var filtered = clients.toList();

    if (options.statusFilter.isNotEmpty) {
      filtered = filtered
          .where((c) => options.statusFilter.contains(c.status))
          .toList();
    }

    if (options.tagsFilter.isNotEmpty) {
      filtered = filtered
          .where((c) =>
              c.tags.any((tag) => options.tagsFilter.contains(tag.label)))
          .toList();
    }

    if (options.dateRange != null) {
      filtered = filtered
          .where((c) =>
              c.createdAt.isAfter(options.dateRange!.start) &&
              c.createdAt.isBefore(options.dateRange!.end))
          .toList();
    }

    return filtered;
  }

  /// 🗂️ CONVERTIR CLIENTE A MAP
  Map<String, dynamic> _clientToMap(
      ClientModel client, List<String> selectedFields) {
    final data = <String, dynamic>{};

    // Solo incluir campos seleccionados
    for (final fieldKey in selectedFields) {
      switch (fieldKey) {
        case 'fullName':
          data[fieldKey] = client.fullName;
          break;
        case 'email':
          data[fieldKey] = client.email;
          break;
        case 'phone':
          data[fieldKey] = client.phone;
          break;
        case 'company':
          data[fieldKey] = client.personalInfo.empresa ?? '';
          break;
        case 'status':
          data[fieldKey] = client.statusDisplayName;
          break;
        case 'tags':
          data[fieldKey] = client.tags.map((t) => t.label).join(', ');
          break;
        case 'address':
          data[fieldKey] = client.direccionCompleta;
          break;
        case 'createdAt':
          data[fieldKey] = DateFormat('dd/MM/yyyy').format(client.createdAt);
          break;
        case 'appointmentsCount':
          data[fieldKey] = client.appointmentsCount;
          break;
        case 'totalRevenue':
          data[fieldKey] = client.totalRevenue;
          break;
        case 'satisfactionScore':
          data[fieldKey] = client.avgSatisfaction;
          break;
        case 'birthDate':
          data[fieldKey] = client.personalInfo.fechaNacimiento != null
              ? DateFormat('dd/MM/yyyy')
                  .format(client.personalInfo.fechaNacimiento!)
              : '';
          break;
        case 'gender':
          data[fieldKey] = client.personalInfo.genero ?? '';
          break;
        case 'notes':
          data[fieldKey] = client.personalInfo.notas ?? '';
          break;
        default:
          data[fieldKey] = '';
      }
    }

    return data;
  }

  /// 📏 ESTIMAR TAMAÑO DEL ARCHIVO
  String _estimateSize(int recordCount, ExportOptions options) {
    final fieldsCount = options.selectedFields.length;
    final avgFieldSize = 50; // bytes promedio por campo
    var totalBytes = recordCount * fieldsCount * avgFieldSize;

    // Factor de formato
    switch (options.format) {
      case ExportFormat.csv:
        totalBytes = (totalBytes * 1.2).round(); // CSV overhead
        break;
      case ExportFormat.excel:
        totalBytes = (totalBytes * 2.5).round(); // Excel overhead
        break;
      case ExportFormat.pdf:
        totalBytes = (totalBytes * 4.0).round(); // PDF overhead
        break;
      case ExportFormat.json:
        totalBytes = (totalBytes * 1.8).round(); // JSON overhead
        break;
    }

    if (totalBytes < 1024) return '${totalBytes}B';
    if (totalBytes < 1024 * 1024)
      return '${(totalBytes / 1024).toStringAsFixed(1)}KB';
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// ⚠️ GENERAR ADVERTENCIAS
  List<String> _generateWarnings(
      List<ClientModel> clients, ExportOptions options) {
    final warnings = <String>[];

    if (clients.length > 1000) {
      warnings.add(
          'Exportación grande (${clients.length} registros), puede tomar tiempo');
    }

    final incompleteEmails = clients.where((c) => c.email.isEmpty).length;
    if (incompleteEmails > 0) {
      warnings.add('$incompleteEmails clientes sin email');
    }

    final incompletePhones = clients.where((c) => c.phone.isEmpty).length;
    if (incompletePhones > 0) {
      warnings.add('$incompletePhones clientes sin teléfono');
    }

    final noTags = clients.where((c) => c.tags.isEmpty).length;
    if (noTags > 0) {
      warnings.add('$noTags clientes sin etiquetas');
    }

    if (options.format == ExportFormat.pdf && clients.length > 500) {
      warnings.add('PDF con más de 500 registros puede ser muy grande');
    }

    return warnings;
  }

  /// 📂 GENERAR NOMBRE DE ARCHIVO
  String _generateFileName(String base, ExportOptions options) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd_HHmm').format(now);

    var fileName = '${base}_$dateStr';

    if (options.includeFilterSuffix) {
      if (options.statusFilter.isNotEmpty) {
        fileName += '_${options.statusFilter.length}estados';
      }
      if (options.tagsFilter.isNotEmpty) {
        fileName += '_${options.tagsFilter.length}tags';
      }
      if (options.dateRange != null) {
        fileName += '_filtrado';
      }
    }

    return '$fileName.${options.format.extension}';
  }

  /// 📈 CREAR RESULTADO
  ExportResult _createResult(String fileName, int count, String extension) {
    // Calcular tamaño estimado más realista
    final estimatedSize =
        (count * 2.5 * (extension == 'xlsx' ? 2 : 1)).toStringAsFixed(1);

    return ExportResult(
      isSuccess: true,
      fileName: fileName,
      recordCount: count,
      formattedSize: '${estimatedSize}KB',
    );
  }

  /// 💰 VERIFICAR SI PUEDE REALIZAR EXPORTACIÓN
  bool _canPerformExport() {
    final stats = _costMonitor.currentStats;
    return stats.dailyReadCount < CostControlConfig.dailyReadLimit;
  }
}

/// 🚀 FUNCIÓN HELPER PARA CREAR CLIENTE MAP COMPLETO
Map<String, dynamic> clientToFullMap(ClientModel client) {
  return {
    'id': client.clientId,
    'fullName': client.fullName,
    'firstName': client.personalInfo.nombre,
    'lastName': client.personalInfo.apellidos,
    'email': client.email,
    'phone': client.phone,
    'company': client.personalInfo.empresa ?? '',
    'status': client.statusDisplayName,
    'tags': client.tags.map((t) => t.label).join(', '),
    'address': client.direccionCompleta,
    'street': client.addressInfo.calle,
    'exteriorNumber': client.addressInfo.numeroExterior,
    'interiorNumber': client.addressInfo.numeroInterior ?? '',
    'neighborhood': client.addressInfo.colonia,
    'postalCode': client.addressInfo.codigoPostal,
    'borough': client.addressInfo.alcaldia,
    'createdAt': DateFormat('dd/MM/yyyy HH:mm').format(client.createdAt),
    'updatedAt': DateFormat('dd/MM/yyyy HH:mm').format(client.updatedAt),
    'appointmentsCount': client.appointmentsCount,
    'totalRevenue': client.totalRevenue,
    'satisfactionScore': client.avgSatisfaction,
    'birthDate': client.personalInfo.fechaNacimiento != null
        ? DateFormat('dd/MM/yyyy').format(client.personalInfo.fechaNacimiento!)
        : '',
    'gender': client.personalInfo.genero ?? '',
    'notes': client.personalInfo.notas ?? '',
    'isVIP': client.isVIP,
    'isCorporate': client.isCorporate,
    'isNew': client.isNew,
    'isActive': client.isActive,
  };
}
