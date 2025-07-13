// [export_service.dart] - COMPATIBLE CON TU CÓDIGO EXCEL EXISTENTE
// 📁 Ubicación: /lib/widgets/clients/export/export_service.dart
// 🎯 USANDO LA MISMA API QUE export_evento_excel.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/export_models.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/file_download_helper.dart';

/// 🛠️ SERVICIO DE EXPORTACIÓN - USANDO TU MISMA API DE EXCEL
class ClientExportService {
  final FileDownloadHelper _downloadHelper = FileDownloadHelper();

  /// 📊 GENERAR VISTA PREVIA
  Future<ExportPreview> getExportPreview({
    required List<ClientModel> clients,
    required ExportOptions options,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final filteredClients = _filterClients(clients, options);
    final sampleData = filteredClients
        .take(3)
        .map((client) => _clientToMap(client, options.selectedFields))
        .toList();

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

  /// 📄 EXPORTAR A CSV REAL
  Future<ExportResult> exportToCSV({
    required List<ClientModel> clients,
    required ExportOptions options,
  }) async {
    try {
      debugPrint('🚀 Iniciando exportación CSV real...');

      final filteredClients = _filterClients(clients, options);
      if (filteredClients.isEmpty) {
        throw Exception('No hay clientes para exportar');
      }

      // 1️⃣ GENERAR HEADERS
      final headers = _generateHeaders(options.selectedFields);

      // 2️⃣ GENERAR FILAS DE DATOS
      final rows = <List<String>>[headers];
      for (final client in filteredClients) {
        final clientData = _clientToMap(client, options.selectedFields);
        final row = options.selectedFields
            .map((field) => _formatCellValue(clientData[field]))
            .toList();
        rows.add(row);
      }

      // 3️⃣ CONVERTIR A CSV
      final csvString = const ListToCsvConverter().convert(rows);

      // 4️⃣ AGREGAR BOM UTF-8 SI ES NECESARIO
      final csvBytes = _addUtf8BOM(csvString, options.includeUtf8BOM);

      // 5️⃣ GENERAR NOMBRE DE ARCHIVO
      final fileName = _generateFileName('clientes', 'csv', options);

      // 6️⃣ DESCARGAR ARCHIVO
      await _downloadHelper.downloadFile(
        fileName: fileName,
        bytes: csvBytes,
        mimeType: 'text/csv',
      );

      debugPrint('✅ CSV exportado exitosamente: $fileName');

      return ExportResult(
        isSuccess: true,
        fileName: fileName,
        recordCount: filteredClients.length,
        formattedSize: _formatBytes(csvBytes.length),
      );
    } catch (e) {
      debugPrint('❌ Error en exportación CSV: $e');
      return ExportResult(
        isSuccess: false,
        fileName: '',
        recordCount: 0,
        formattedSize: '0KB',
        errorMessage: 'Error generando CSV: ${e.toString()}',
      );
    }
  }

  /// 📊 EXPORTAR A EXCEL - USANDO TU MISMA API
  Future<ExportResult> exportToExcel({
    required List<ClientModel> clients,
    required ExportOptions options,
  }) async {
    try {
      debugPrint('🚀 Iniciando exportación Excel real...');

      final filteredClients = _filterClients(clients, options);
      if (filteredClients.isEmpty) {
        throw Exception('No hay clientes para exportar');
      }

      // 1️⃣ CREAR EXCEL USANDO TU MISMA API
      final excel = excel_lib.Excel.createExcel();

      // 2️⃣ ELIMINAR HOJAS POR DEFECTO
      final sheetsToDelete = excel.sheets.keys.toList();
      for (String sheetName in sheetsToDelete) {
        excel.delete(sheetName);
      }

      // 3️⃣ CREAR HOJA DE CLIENTES
      final sheet = excel['📋 Clientes'];

      // 4️⃣ AGREGAR HEADERS CON ESTILO
      final headers = _generateHeaders(options.selectedFields);
      for (int i = 0; i < headers.length; i++) {
        _setCell(sheet, _getCellAddress(i, 0), headers[i]);
        _setCellStyle(
          sheet,
          _getCellAddress(i, 0),
          fontSize: 12,
          bold: true,
          textColor: 'FFFFFF',
          bgColor: '4472C4',
        );
      }

      // 5️⃣ AGREGAR DATOS DE CLIENTES
      for (int rowIndex = 0; rowIndex < filteredClients.length; rowIndex++) {
        final client = filteredClients[rowIndex];
        final clientData = _clientToMap(client, options.selectedFields);

        for (int colIndex = 0;
            colIndex < options.selectedFields.length;
            colIndex++) {
          final field = options.selectedFields[colIndex];
          final cellAddress = _getCellAddress(colIndex, rowIndex + 1);
          final value = clientData[field];

          _setCell(sheet, cellAddress, value?.toString() ?? 'N/A');

          // Alternar colores de fila
          if (rowIndex % 2 == 0) {
            _setCellStyle(sheet, cellAddress, bgColor: 'F2F2F2');
          }
        }
      }

      // 6️⃣ GENERAR BYTES
      final List<int>? fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('Error generando archivo Excel');
      }

      // 7️⃣ GENERAR NOMBRE Y DESCARGAR
      final fileName = _generateFileName('clientes', 'xlsx', options);

      await _downloadHelper.downloadFile(
        fileName: fileName,
        bytes: Uint8List.fromList(fileBytes),
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );

      debugPrint('✅ Excel exportado exitosamente: $fileName');

      return ExportResult(
        isSuccess: true,
        fileName: fileName,
        recordCount: filteredClients.length,
        formattedSize: _formatBytes(fileBytes.length),
      );
    } catch (e) {
      debugPrint('❌ Error en exportación Excel: $e');
      return ExportResult(
        isSuccess: false,
        fileName: '',
        recordCount: 0,
        formattedSize: '0KB',
        errorMessage: 'Error generando Excel: ${e.toString()}',
      );
    }
  }

  /// 📄 EXPORTAR A PDF REAL
  Future<ExportResult> exportToPDF({
    required List<ClientModel> clients,
    required ExportOptions options,
  }) async {
    try {
      debugPrint('🚀 Iniciando exportación PDF real...');

      final filteredClients = _filterClients(clients, options);
      if (filteredClients.isEmpty) {
        throw Exception('No hay clientes para exportar');
      }

      // 1️⃣ CREAR DOCUMENTO PDF
      final pdf = pw.Document();

      // 2️⃣ PREPARAR DATOS
      final headers = _generateHeaders(options.selectedFields);
      final tableData = <List<String>>[];

      for (final client in filteredClients) {
        final clientData = _clientToMap(client, options.selectedFields);
        final row = options.selectedFields
            .map((field) => _formatCellValue(clientData[field]))
            .toList();
        tableData.add(row);
      }

      // 3️⃣ CREAR PÁGINAS DEL PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              // HEADER
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Exportación de Clientes - Fisio Spa KYM',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              // METADATA
              pw.Paragraph(
                text:
                    'Fecha de exportación: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}\n'
                    'Total de registros: ${filteredClients.length}\n'
                    'Formato: PDF',
                style: const pw.TextStyle(fontSize: 10),
              ),

              pw.SizedBox(height: 20),

              // TABLA DE DATOS
              pw.Table.fromTextArray(
                context: context,
                data: [headers, ...tableData],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 8,
                ),
                cellStyle: const pw.TextStyle(fontSize: 7),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellHeight: 25,
                cellAlignments: {
                  for (int i = 0; i < headers.length; i++)
                    i: pw.Alignment.centerLeft,
                },
              ),
            ];
          },
        ),
      );

      // 4️⃣ GENERAR BYTES
      final pdfBytes = await pdf.save();

      // 5️⃣ GENERAR NOMBRE Y DESCARGAR
      final fileName = _generateFileName('clientes', 'pdf', options);

      await _downloadHelper.downloadFile(
        fileName: fileName,
        bytes: pdfBytes,
        mimeType: 'application/pdf',
      );

      debugPrint('✅ PDF exportado exitosamente: $fileName');

      return ExportResult(
        isSuccess: true,
        fileName: fileName,
        recordCount: filteredClients.length,
        formattedSize: _formatBytes(pdfBytes.length),
      );
    } catch (e) {
      debugPrint('❌ Error en exportación PDF: $e');
      return ExportResult(
        isSuccess: false,
        fileName: '',
        recordCount: 0,
        formattedSize: '0KB',
        errorMessage: 'Error generando PDF: ${e.toString()}',
      );
    }
  }

  /// 📋 EXPORTAR A JSON REAL
  Future<ExportResult> exportToJSON({
    required List<ClientModel> clients,
    required ExportOptions options,
  }) async {
    try {
      debugPrint('🚀 Iniciando exportación JSON real...');

      final filteredClients = _filterClients(clients, options);
      if (filteredClients.isEmpty) {
        throw Exception('No hay clientes para exportar');
      }

      // 1️⃣ CREAR ESTRUCTURA JSON
      final exportData = {
        'metadata': {
          'exported_at': DateTime.now().toIso8601String(),
          'total_records': filteredClients.length,
          'format': 'JSON',
          'exported_by': 'Fisio Spa KYM',
          'fields': options.selectedFields,
        },
        'clients': filteredClients
            .map((client) => _clientToMap(client, options.selectedFields))
            .toList(),
      };

      // 2️⃣ CONVERTIR A JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final jsonBytes = utf8.encode(jsonString);

      // 3️⃣ GENERAR NOMBRE Y DESCARGAR
      final fileName = _generateFileName('clientes', 'json', options);

      await _downloadHelper.downloadFile(
        fileName: fileName,
        bytes: Uint8List.fromList(jsonBytes),
        mimeType: 'application/json',
      );

      debugPrint('✅ JSON exportado exitosamente: $fileName');

      return ExportResult(
        isSuccess: true,
        fileName: fileName,
        recordCount: filteredClients.length,
        formattedSize: _formatBytes(jsonBytes.length),
      );
    } catch (e) {
      debugPrint('❌ Error en exportación JSON: $e');
      return ExportResult(
        isSuccess: false,
        fileName: '',
        recordCount: 0,
        formattedSize: '0KB',
        errorMessage: 'Error generando JSON: ${e.toString()}',
      );
    }
  }

  // ====================================================================
  // 🔧 MÉTODOS HELPER - COPIADOS DE TU export_evento_excel.dart
  // ====================================================================

  /// 📍 OBTENER DIRECCIÓN DE CELDA (COPIADO DE TU CÓDIGO)
  String _getCellAddress(int col, int row) {
    String colName = '';
    int temp = col;
    while (temp >= 0) {
      colName = String.fromCharCode(65 + (temp % 26)) + colName;
      temp = (temp ~/ 26) - 1;
      if (temp < 0) break;
    }
    return '$colName${row + 1}';
  }

  /// 📝 ESTABLECER VALOR DE CELDA (COPIADO DE TU CÓDIGO)
  void _setCell(excel_lib.Sheet sheet, String address, dynamic value) {
    final cell = sheet.cell(excel_lib.CellIndex.indexByString(address));

    if (value is String) {
      cell.value = value;
    } else if (value is int) {
      cell.value = value;
    } else if (value is double) {
      cell.value = value;
    } else {
      cell.value = value.toString();
    }
  }

  /// 🎨 ESTABLECER ESTILO DE CELDA (COPIADO DE TU CÓDIGO)
  void _setCellStyle(
    excel_lib.Sheet sheet,
    String address, {
    int? fontSize,
    bool? bold,
    String? textColor,
    String? bgColor,
    bool? centered,
  }) {
    final cell = sheet.cell(excel_lib.CellIndex.indexByString(address));

    final style = excel_lib.CellStyle(
      fontSize: fontSize ?? 11,
      bold: bold ?? false,
      fontColorHex: textColor != null ? 'FF$textColor' : 'FF000000',
    );

    if (bgColor != null) {
      final styledCell = excel_lib.CellStyle(
        fontSize: fontSize ?? 11,
        bold: bold ?? false,
        fontColorHex: textColor != null ? 'FF$textColor' : 'FF000000',
        backgroundColorHex: 'FF$bgColor',
      );
      cell.cellStyle = styledCell;
    } else {
      cell.cellStyle = style;
    }
  }

  // ====================================================================
  // 🔧 MÉTODOS PRIVADOS DE UTILIDAD
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
              c.createdAt.isBefore(
                  options.dateRange!.end.add(const Duration(days: 1))))
          .toList();
    }

    debugPrint('🔍 Filtrados: ${filtered.length}/${clients.length} clientes');
    return filtered;
  }

  /// 🗂️ CONVERTIR CLIENTE A MAP
  Map<String, dynamic> _clientToMap(
      ClientModel client, List<String> selectedFields) {
    final allData = {
      'fullName': client.fullName,
      'email': client.email,
      'phone': client.phone,
      'company': client.empresa.isNotEmpty ? client.empresa : 'N/A',
      'status': client.statusDisplayName,
      'tags': client.tags.map((t) => t.label).join(', '),
      'address': client.direccionCompleta.isNotEmpty
          ? client.direccionCompleta
          : 'N/A',
      'createdAt': DateFormat('dd/MM/yyyy').format(client.createdAt),
      'appointmentsCount': client.appointmentsCount.toString(),
      'totalRevenue': '\$${client.totalRevenue.toStringAsFixed(2)}',
      'satisfactionScore': client.avgSatisfaction.toStringAsFixed(1),
    };

    // Retornar solo campos seleccionados
    final filteredData = <String, dynamic>{};
    for (final field in selectedFields) {
      filteredData[field] = allData[field] ?? 'N/A';
    }

    return filteredData;
  }

  /// 📋 GENERAR HEADERS
  List<String> _generateHeaders(List<String> selectedFields) {
    final fieldMap = {
      'fullName': 'Nombre Completo',
      'email': 'Email',
      'phone': 'Teléfono',
      'company': 'Empresa',
      'status': 'Estado',
      'tags': 'Etiquetas',
      'address': 'Dirección',
      'createdAt': 'Fecha de Registro',
      'appointmentsCount': 'Total de Citas',
      'totalRevenue': 'Ingresos Totales',
      'satisfactionScore': 'Satisfacción',
    };

    return selectedFields.map((field) => fieldMap[field] ?? field).toList();
  }

  /// 📝 FORMATEAR VALOR DE CELDA
  String _formatCellValue(dynamic value) {
    if (value == null) return 'N/A';
    return value.toString().replaceAll('\n', ' ').replaceAll('\r', '');
  }

  /// 🔤 AGREGAR BOM UTF-8
  Uint8List _addUtf8BOM(String csvString, bool includeBOM) {
    final stringBytes = utf8.encode(csvString);

    if (includeBOM) {
      // BOM UTF-8: EF BB BF
      final bomBytes = [0xEF, 0xBB, 0xBF];
      return Uint8List.fromList([...bomBytes, ...stringBytes]);
    }

    return Uint8List.fromList(stringBytes);
  }

  /// 📁 GENERAR NOMBRE DE ARCHIVO
  String _generateFileName(
      String base, String extension, ExportOptions options) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    var fileName = '${base}_$timestamp';

    if (options.includeFilterSuffix) {
      final suffixes = <String>[];

      if (options.statusFilter.isNotEmpty) {
        suffixes.add('estado-${options.statusFilter.length}');
      }

      if (options.tagsFilter.isNotEmpty) {
        suffixes.add('tags-${options.tagsFilter.length}');
      }

      if (options.dateRange != null) {
        final start = DateFormat('ddMM').format(options.dateRange!.start);
        final end = DateFormat('ddMM').format(options.dateRange!.end);
        suffixes.add('$start-$end');
      }

      if (suffixes.isNotEmpty) {
        fileName += '_${suffixes.join('_')}';
      }
    }

    return '$fileName.$extension';
  }

  /// 📏 ESTIMAR TAMAÑO
  String _estimateSize(int recordCount, ExportOptions options) {
    final fieldsCount = options.selectedFields.length;
    int avgFieldSize;

    switch (options.format) {
      case ExportFormat.csv:
        avgFieldSize = 30;
        break;
      case ExportFormat.excel:
        avgFieldSize = 50;
        break;
      case ExportFormat.pdf:
        avgFieldSize = 100;
        break;
      case ExportFormat.json:
        avgFieldSize = 80;
        break;
    }

    final totalBytes = recordCount * fieldsCount * avgFieldSize;
    return _formatBytes(totalBytes);
  }

  /// 📊 FORMATEAR BYTES
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// ⚠️ GENERAR ADVERTENCIAS
  List<String> _generateWarnings(
      List<ClientModel> clients, ExportOptions options) {
    final warnings = <String>[];

    if (clients.length > 5000) {
      warnings.add(
          'Exportación muy grande (${clients.length} registros), puede tomar tiempo');
    }

    final incompleteClients = clients.where((c) => c.email.isEmpty).length;
    if (incompleteClients > 0) {
      warnings.add('$incompleteClients clientes sin email');
    }

    final noPhoneClients = clients.where((c) => c.phone.isEmpty).length;
    if (noPhoneClients > 0) {
      warnings.add('$noPhoneClients clientes sin teléfono');
    }

    if (options.format == ExportFormat.pdf && clients.length > 1000) {
      warnings.add('PDF con muchos registros puede ser lento');
    }

    return warnings;
  }
}
