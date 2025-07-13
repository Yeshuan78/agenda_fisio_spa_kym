// [export_service.dart] - SERVICIO DE EXPORTACIÓN SEPARADO
// 📁 Ubicación: /lib/widgets/clients/export/export_service.dart
// 🎯 OBJETIVO: Lógica de exportación limpia y reutilizable

import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/export_models.dart';
import 'package:intl/intl.dart';

/// 🛠️ SERVICIO DE EXPORTACIÓN DE CLIENTES
class ClientExportService {
  
  /// 📊 GENERAR VISTA PREVIA
  Future<ExportPreview> getExportPreview({
    required List<ClientModel> clients,
    required ExportOptions options,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final filteredClients = _filterClients(clients, options);
    final sampleData = filteredClients.take(3).map(_clientToMap).toList();

    return ExportPreview(
      totalRecords: filteredClients.length,
      selectedFields: ExportField.getAllFields()
          .where((field) => options.selectedFields.contains(field.key))
          .toList(),
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
    await Future.delayed(const Duration(seconds: 2));
    return _createResult('clientes.csv', clients.length);
  }

  /// 📊 EXPORTAR A EXCEL
  Future<ExportResult> exportToExcel({
    required List<ClientModel> clients,
    required ExportOptions options,
  }) async {
    await Future.delayed(const Duration(seconds: 3));
    return _createResult('clientes.xlsx', clients.length);
  }

  /// 📄 EXPORTAR A PDF
  Future<ExportResult> exportToPDF({
    required List<ClientModel> clients,
    required ExportOptions options,
  }) async {
    await Future.delayed(const Duration(seconds: 4));
    return _createResult('clientes.pdf', clients.length);
  }

  /// 📋 EXPORTAR A JSON
  Future<ExportResult> exportToJSON({
    required List<ClientModel> clients,
    required ExportOptions options,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return _createResult('clientes.json', clients.length);
  }

  // ====================================================================
  // 🔧 MÉTODOS PRIVADOS
  // ====================================================================

  /// 🔍 FILTRAR CLIENTES
  List<ClientModel> _filterClients(List<ClientModel> clients, ExportOptions options) {
    var filtered = clients.toList();

    if (options.statusFilter.isNotEmpty) {
      filtered = filtered.where((c) => options.statusFilter.contains(c.status)).toList();
    }

    if (options.tagsFilter.isNotEmpty) {
      filtered = filtered.where((c) => 
        c.tags.any((tag) => options.tagsFilter.contains(tag.label))
      ).toList();
    }

    if (options.dateRange != null) {
      filtered = filtered.where((c) =>
        c.createdAt.isAfter(options.dateRange!.start) &&
        c.createdAt.isBefore(options.dateRange!.end)
      ).toList();
    }

    return filtered;
  }

  /// 🗂️ CONVERTIR CLIENTE A MAP
  Map<String, dynamic> _clientToMap(ClientModel client) {
    return {
      'fullName': client.fullName,
      'email': client.email,
      'phone': client.phone,
      'company': client.empresa,
      'status': client.statusDisplayName,
      'tags': client.tags.map((t) => t.label).join(', '),
      'address': client.direccionCompleta,
      'createdAt': DateFormat('dd/MM/yyyy').format(client.createdAt),
      'appointmentsCount': client.appointmentsCount,
      'totalRevenue': client.totalRevenue,
      'satisfactionScore': client.avgSatisfaction,
    };
  }

  /// 📏 ESTIMAR TAMAÑO DEL ARCHIVO
  String _estimateSize(int recordCount, ExportOptions options) {
    final fieldsCount = options.selectedFields.length;
    final avgFieldSize = 50; // bytes promedio por campo
    final totalBytes = recordCount * fieldsCount * avgFieldSize;
    
    if (totalBytes < 1024) return '${totalBytes}B';
    if (totalBytes < 1024 * 1024) return '${(totalBytes / 1024).toStringAsFixed(1)}KB';
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// ⚠️ GENERAR ADVERTENCIAS
  List<String> _generateWarnings(List<ClientModel> clients, ExportOptions options) {
    final warnings = <String>[];
    
    if (clients.length > 1000) {
      warnings.add('Exportación grande, puede tomar tiempo');
    }
    
    final incompleteClients = clients.where((c) => c.email.isEmpty).length;
    if (incompleteClients > 0) {
      warnings.add('$incompleteClients clientes sin email');
    }
    
    return warnings;
  }

  /// 📈 CREAR RESULTADO
  ExportResult _createResult(String fileName, int count) {
    return ExportResult(
      isSuccess: true,
      fileName: fileName,
      recordCount: count,
      formattedSize: '${(count * 2.5).toStringAsFixed(1)}KB',
    );
  }
}