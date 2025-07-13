// [export_models.dart] - MODELOS DE EXPORTACIÓN SEPARADOS
// 📁 Ubicación: /lib/widgets/clients/export/export_models.dart
// 🎯 OBJETIVO: Modelos limpios y reutilizables

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';

/// 🚀 FORMATO DE EXPORTACIÓN
enum ExportFormat {
  csv('CSV', 'Valores separados por comas', Icons.table_chart),
  excel('Excel', 'Hoja de cálculo .xlsx', Icons.grid_on),
  pdf('PDF', 'Documento portable', Icons.picture_as_pdf),
  json('JSON', 'Formato de datos JSON', Icons.code);

  const ExportFormat(this.displayName, this.description, this.icon);
  final String displayName;
  final String description;
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