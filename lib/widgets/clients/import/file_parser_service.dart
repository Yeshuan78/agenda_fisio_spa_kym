// [file_parser_service.dart] - PARSER ENTERPRISE PARA CSV Y EXCEL - FIX CRÍTICO HEADERS
// 📁 Ubicación: /lib/widgets/clients/import/file_parser_service.dart
// 🎯 OBJETIVO: Análisis robusto de archivos con detección automática y manejo de errores
// ✅ FIX CRÍTICO: Detección correcta de headers en Excel

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'import_models.dart';

// ========================================================================
// 📊 RESULTADO DEL PARSING
// ========================================================================

/// 📊 RESULTADO COMPLETO DEL PARSING
class ParseResult {
  final bool isSuccess;
  final List<List<String>> data;
  final List<String> headers;
  final ImportFileInfo fileInfo;
  final ImportOptions detectedOptions;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  const ParseResult({
    required this.isSuccess,
    required this.data,
    required this.headers,
    required this.fileInfo,
    required this.detectedOptions,
    this.errorMessage,
    this.metadata = const {},
  });

  /// 🏭 FACTORY: Resultado exitoso
  factory ParseResult.success({
    required List<List<String>> data,
    required List<String> headers,
    required ImportFileInfo fileInfo,
    required ImportOptions detectedOptions,
    Map<String, dynamic> metadata = const {},
  }) {
    return ParseResult(
      isSuccess: true,
      data: data,
      headers: headers,
      fileInfo: fileInfo,
      detectedOptions: detectedOptions,
      metadata: metadata,
    );
  }

  /// 🏭 FACTORY: Resultado fallido
  factory ParseResult.error({
    required String errorMessage,
    required ImportFileInfo fileInfo,
    Map<String, dynamic> metadata = const {},
  }) {
    return ParseResult(
      isSuccess: false,
      data: [],
      headers: [],
      fileInfo: fileInfo,
      detectedOptions: ImportOptions.defaultCsv(),
      errorMessage: errorMessage,
      metadata: metadata,
    );
  }

  /// 📊 PROPIEDADES CALCULADAS
  int get totalRows => data.length;
  int get totalColumns => headers.length;
  bool get hasData => data.isNotEmpty;

  List<List<String>> get previewData {
    if (data.length <= ImportLimits.previewRowsCount) return data;
    return data.take(ImportLimits.previewRowsCount).toList();
  }

  Map<String, dynamic> get statistics => {
        'totalRows': totalRows,
        'totalColumns': totalColumns,
        'hasHeaders': detectedOptions.hasHeaders,
        'detectedDelimiter': detectedOptions.delimiter.value,
        'detectedEncoding': detectedOptions.encoding,
        'fileSize': fileInfo.sizeFormatted,
        'processingTime': metadata['processingTime'],
      };
}

// ========================================================================
// 🔧 SERVICIO PRINCIPAL DE PARSING
// ========================================================================

/// 🔧 SERVICIO ENTERPRISE PARA PARSING DE ARCHIVOS
class FileParserService {
  static final FileParserService _instance = FileParserService._internal();
  factory FileParserService() => _instance;
  FileParserService._internal();

  // ========================================================================
  // 🚀 MÉTODO PRINCIPAL DE PARSING
  // ========================================================================

  /// 🚀 PARSEAR ARCHIVO AUTOMÁTICAMENTE SEGÚN FORMATO
  Future<ParseResult> parseFile(
    ImportFileInfo fileInfo,
    ImportOptions options,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      debugPrint(
          '📁 Iniciando parsing de ${fileInfo.name} (${fileInfo.sizeFormatted})');

      // 🔍 VALIDACIONES PREVIAS
      if (!_validateFileSize(fileInfo)) {
        return ParseResult.error(
          errorMessage:
              'Archivo demasiado grande. Máximo ${ImportLimits.maxFileSizeMb}MB',
          fileInfo: fileInfo,
          metadata: {'processingTime': stopwatch.elapsed.inMilliseconds},
        );
      }

      ParseResult result;

      // 🎯 ROUTING POR FORMATO
      switch (fileInfo.format) {
        case ImportFormat.csv:
          result = await _parseCSV(fileInfo, options);
          break;
        case ImportFormat.excel:
          result = await _parseExcel(fileInfo, options);
          break;
      }

      // ✅ AGREGAR METADATA DE TIMING
      stopwatch.stop();
      final updatedMetadata = Map<String, dynamic>.from(result.metadata);
      updatedMetadata['processingTime'] = stopwatch.elapsed.inMilliseconds;

      debugPrint(
          '✅ Parsing completado en ${stopwatch.elapsed.inMilliseconds}ms');
      debugPrint(
          '📊 Resultado: ${result.totalRows} filas, ${result.totalColumns} columnas');

      return ParseResult(
        isSuccess: result.isSuccess,
        data: result.data,
        headers: result.headers,
        fileInfo: result.fileInfo,
        detectedOptions: result.detectedOptions,
        errorMessage: result.errorMessage,
        metadata: updatedMetadata,
      );
    } catch (e, stackTrace) {
      stopwatch.stop();
      debugPrint('❌ Error en parsing: $e');
      debugPrint('🔍 Stack trace: $stackTrace');

      return ParseResult.error(
        errorMessage: 'Error procesando archivo: ${e.toString()}',
        fileInfo: fileInfo,
        metadata: {
          'processingTime': stopwatch.elapsed.inMilliseconds,
          'error': e.toString(),
        },
      );
    }
  }

  // ========================================================================
  // 📄 PARSING CSV ESPECIALIZADO
  // ========================================================================

  /// 📄 PARSING CSV CON DETECCIÓN AUTOMÁTICA
  Future<ParseResult> _parseCSV(
    ImportFileInfo fileInfo,
    ImportOptions options,
  ) async {
    try {
      // 🔍 DETECCIÓN AUTOMÁTICA DE ENCODING
      final encoding = _detectEncoding(fileInfo.bytes);
      String csvContent;

      try {
        csvContent = encoding.decode(fileInfo.bytes);
      } catch (e) {
        // Fallback a UTF-8 si falla la detección
        csvContent = utf8.decode(fileInfo.bytes, allowMalformed: true);
      }

      // 🔍 DETECCIÓN AUTOMÁTICA DE DELIMITADOR
      final detectedDelimiter = _detectDelimiter(csvContent);

      // ⚙️ CREAR OPCIONES OPTIMIZADAS
      final optimizedOptions = options.copyWith(
        delimiter: detectedDelimiter,
        encoding: encoding.name,
      );

      // 📊 PARSING CON CSV PACKAGE
      final csvData = const CsvToListConverter().convert(
        csvContent,
        fieldDelimiter: detectedDelimiter.value,
        textDelimiter: '"',
        textEndDelimiter: '"',
        shouldParseNumbers: false, // Mantener como String para validación
      );

      if (csvData.isEmpty) {
        return ParseResult.error(
          errorMessage: 'El archivo CSV está vacío',
          fileInfo: fileInfo,
        );
      }

      // 🏷️ EXTRAER HEADERS Y DATA
      List<String> headers;
      List<List<String>> data;

      if (optimizedOptions.hasHeaders) {
        headers = csvData.first.map((cell) => cell.toString().trim()).toList();
        data = csvData
            .skip(1)
            .map((row) => row.map((cell) => cell.toString().trim()).toList())
            .toList();
      } else {
        // Generar headers automáticos: Columna 1, Columna 2, etc.
        final columnCount = csvData.first.length;
        headers = List.generate(columnCount, (index) => 'Columna ${index + 1}');
        data = csvData
            .map((row) => row.map((cell) => cell.toString().trim()).toList())
            .toList();
      }

      // 🧹 LIMPIAR DATOS SI ES NECESARIO
      if (optimizedOptions.skipEmptyRows) {
        data = _removeEmptyRows(data);
      }

      if (optimizedOptions.trimWhitespace) {
        data = _trimWhitespace(data);
      }

      // ⚠️ VALIDAR LÍMITES
      if (data.length > ImportLimits.maxRecordsPerImport) {
        return ParseResult.error(
          errorMessage:
              'Demasiados registros. Máximo ${ImportLimits.maxRecordsPerImport}',
          fileInfo: fileInfo,
        );
      }

      // 🔧 NORMALIZAR LONGITUD DE FILAS
      data = _normalizeRowLengths(data, headers.length);
      debugPrint('🔍 === DEBUG PARSE RESULT ===');
      debugPrint('🔍 Headers length: ${headers.length}');
      debugPrint('🔍 Headers: $headers');
      debugPrint('🔍 Data length: ${data.length}');
      debugPrint(
          '🔍 First data row length: ${data.isNotEmpty ? data.first.length : 0}');
      debugPrint('🔍 First data row: ${data.isNotEmpty ? data.first : []}');

      return ParseResult.success(
        data: data,
        headers: headers,
        fileInfo: fileInfo,
        detectedOptions: optimizedOptions,
        metadata: {
          'detectedDelimiter': detectedDelimiter.displayName,
          'detectedEncoding': encoding.name,
          'originalRowCount': csvData.length,
          'cleanedRowCount': data.length,
        },
      );
    } catch (e) {
      return ParseResult.error(
        errorMessage: 'Error procesando CSV: ${e.toString()}',
        fileInfo: fileInfo,
      );
    }
  }

  // ========================================================================
  // 📊 PARSING EXCEL ESPECIALIZADO - ✅ FIX CRÍTICO
  // ========================================================================

  /// 📊 PARSING EXCEL CON DETECCIÓN CORRECTA DE HEADERS - FIX CRÍTICO
  Future<ParseResult> _parseExcel(
    ImportFileInfo fileInfo,
    ImportOptions options,
  ) async {
    try {
      // 📊 ABRIR ARCHIVO EXCEL
      final excel = Excel.decodeBytes(fileInfo.bytes);

      if (excel.sheets.isEmpty) {
        return ParseResult.error(
          errorMessage: 'El archivo Excel no contiene hojas',
          fileInfo: fileInfo,
        );
      }

      // 🎯 SELECCIONAR HOJA PRINCIPAL (primera con datos)
      Sheet? targetSheet;
      String? sheetName;

      for (final entry in excel.sheets.entries) {
        final sheet = entry.value;
        if (sheet.maxRows > 0) {
          targetSheet = sheet;
          sheetName = entry.key;
          break;
        }
      }

      if (targetSheet == null) {
        return ParseResult.error(
          errorMessage: 'No se encontraron hojas con datos',
          fileInfo: fileInfo,
        );
      }

      debugPrint('📊 Procesando hoja: $sheetName');

      // ✅ FIX CRÍTICO: DETECTAR FILA DE HEADERS CORRECTA
      final headerDetectionResult = _detectExcelHeaders(targetSheet);
      final headerRowIndex = headerDetectionResult['headerRowIndex'] as int;
      final maxColumns = headerDetectionResult['maxColumns'] as int;
      final actualHeaders = headerDetectionResult['headers'] as List<String>;
      final totalDataRows = targetSheet.maxRows;

      debugPrint('✅ Headers detectados en fila $headerRowIndex');
      debugPrint(
          '📊 Dimensiones: ${totalDataRows - headerRowIndex - 1} filas de datos, $maxColumns columnas');

      // 🔧 DEBUG: Mostrar headers detectados correctamente
      debugPrint('📋 Headers detectados:');
      for (int i = 0; i < actualHeaders.length; i++) {
        final columnLetter = String.fromCharCode(65 + i);
        debugPrint('  $columnLetter: "${actualHeaders[i]}"');
      }

      // ✅ EXTRAER DATOS DESDE LA FILA SIGUIENTE A LOS HEADERS
      final rawData = <List<String>>[];

      // Comenzar desde la fila DESPUÉS de los headers
      for (int row = headerRowIndex + 1; row < totalDataRows; row++) {
        final rowData = <String>[];

        for (int col = 0; col < maxColumns; col++) {
          final cell = targetSheet.cell(CellIndex.indexByColumnRow(
            columnIndex: col,
            rowIndex: row,
          ));

          // 🔧 CONVERSIÓN MEJORADA DE VALORES
          String cellValue = '';
          if (cell.value != null) {
            if (cell.value is SharedString) {
              cellValue = cell.value.toString();
            } else if (cell.value is double) {
              // Manejar números como enteros si no tienen decimales
              final doubleValue = cell.value as double;
              if (doubleValue == doubleValue.truncateToDouble()) {
                cellValue = doubleValue.toInt().toString();
              } else {
                cellValue = doubleValue.toString();
              }
            } else {
              cellValue = cell.value.toString();
            }
          }

          rowData.add(cellValue.trim());
        }

        rawData.add(rowData);
      }

      if (rawData.isEmpty) {
        return ParseResult.error(
          errorMessage: 'No se encontraron datos después de los headers',
          fileInfo: fileInfo,
        );
      }

      // 🏷️ USAR HEADERS DETECTADOS
      List<String> headers = actualHeaders;
      List<List<String>> data = rawData;

      // 🧹 LIMPIAR DATOS
      if (options.skipEmptyRows) {
        data = _removeEmptyRows(data);
      }

      if (options.trimWhitespace) {
        data = _trimWhitespace(data);
      }

      // ⚠️ VALIDAR LÍMITES
      if (data.length > ImportLimits.maxRecordsPerImport) {
        return ParseResult.error(
          errorMessage:
              'Demasiados registros. Máximo ${ImportLimits.maxRecordsPerImport}',
          fileInfo: fileInfo,
        );
      }

      // 🔧 NORMALIZAR LONGITUD DE FILAS
      data = _normalizeRowLengths(data, headers.length);

      return ParseResult.success(
        data: data,
        headers: headers,
        fileInfo: fileInfo,
        detectedOptions: options,
        metadata: {
          'sheetName': sheetName,
          'totalSheets': excel.sheets.length,
          'headerRowIndex': headerRowIndex,
          'originalRowCount': rawData.length,
          'cleanedRowCount': data.length,
          'maxColumns': maxColumns,
          'detectedHeaders': headers,
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error procesando Excel: $e');
      debugPrint('🔍 Stack trace: $stackTrace');
      return ParseResult.error(
        errorMessage: 'Error procesando Excel: ${e.toString()}',
        fileInfo: fileInfo,
      );
    }
  }

  // ========================================================================
  // ✅ NUEVO MÉTODO: DETECTAR HEADERS EN EXCEL
  // ========================================================================

  /// ✅ FIX CRÍTICO: DETECTAR FILA DE HEADERS EN EXCEL - VERSIÓN CORREGIDA
  Map<String, dynamic> _detectExcelHeaders(Sheet sheet) {
    final maxRowsToCheck = 10;
    final maxColsToCheck = 50;

    int headerRowIndex = 0;
    List<String> bestHeaders = [];
    int maxColumns = 0;

    // 🔍 BUSCAR LA MEJOR FILA DE HEADERS
    for (int row = 0; row < maxRowsToCheck && row < sheet.maxRows; row++) {
      final candidateHeaders = <String>[];
      int nonEmptyCount = 0;
      int actualMaxCols = 0; // ✅ FIX: Detectar columnas reales

      // ✅ FIX CRÍTICO: LEER TODAS LAS COLUMNAS HASTA ENCONTRAR VACÍAS CONSECUTIVAS
      for (int col = 0; col < maxColsToCheck; col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: row,
        ));

        String cellValue = '';
        if (cell.value != null) {
          cellValue = cell.value.toString().trim();
        }

        candidateHeaders.add(cellValue);

        if (cellValue.isNotEmpty) {
          nonEmptyCount++;
          actualMaxCols =
              col + 1; // ✅ FIX: Actualizar columnas reales encontradas
        }
      }

      // ✅ FIX CRÍTICO: USAR COLUMNAS REALES, NO DETECTADAS ERRÓNEAMENTE
      if (actualMaxCols > maxColumns) {
        maxColumns = actualMaxCols;
      }

      // 📊 EVALUAR SI ESTA FILA ES BUENA PARA HEADERS
      final headerScore = _evaluateHeaderQuality(
          candidateHeaders.take(actualMaxCols).toList(), nonEmptyCount);

      debugPrint(
          '🔍 FILA $row: $nonEmptyCount columnas no vacías, $actualMaxCols columnas totales, score: $headerScore');
      debugPrint(
          '   Headers detectados: ${candidateHeaders.take(actualMaxCols).join(", ")}');

      // Si esta fila tiene un buen score de header, usarla
      if (headerScore > 0.6 && nonEmptyCount >= 3) {
        headerRowIndex = row;
        bestHeaders = candidateHeaders.take(actualMaxCols).toList();
        maxColumns = actualMaxCols; // ✅ FIX: Usar columnas reales
        break;
      }

      // Si es la primera fila y tiene datos, usar como fallback
      if (row == 0 && nonEmptyCount >= 3) {
        headerRowIndex = row;
        bestHeaders = candidateHeaders.take(actualMaxCols).toList();
        maxColumns = actualMaxCols; // ✅ FIX: Usar columnas reales
      }
    }

    // ✅ FIX CRÍTICO: LIMPIAR HEADERS SIN ALTERAR ÍNDICES
    final cleanHeaders = <String>[];
    for (int i = 0; i < maxColumns; i++) {
      if (i < bestHeaders.length && bestHeaders[i].trim().isNotEmpty) {
        cleanHeaders.add(bestHeaders[i].trim());
      } else {
        // ✅ FIX: MANTENER HEADERS VACÍOS EN LUGAR DE GENERAR AUTOMÁTICOS
        cleanHeaders.add(''); // ← ESTO EVITA DESPLAZAMIENTO DE ÍNDICES
      }
    }

    // ✅ FIX: REMOVER HEADERS VACÍOS AL FINAL PERO MANTENER ORDEN
    while (cleanHeaders.isNotEmpty && cleanHeaders.last.isEmpty) {
      cleanHeaders.removeLast();
      maxColumns--;
    }

    debugPrint(
        '✅ FIX APLICADO: Headers finales detectados: $headerRowIndex fila, $maxColumns columnas');
    debugPrint('✅ FIX: Headers limpios: $cleanHeaders');

    return {
      'headerRowIndex': headerRowIndex,
      'maxColumns': maxColumns,
      'headers': cleanHeaders,
    };
  }

  /// 📊 EVALUAR CALIDAD DE HEADERS
  double _evaluateHeaderQuality(List<String> headers, int nonEmptyCount) {
    if (nonEmptyCount < 2) return 0.0;

    double score = 0.0;
    int validHeaders = 0;

    for (final header in headers) {
      if (header.trim().isEmpty) continue;

      validHeaders++;

      // Bonus por palabras clave típicas de headers
      final headerLower = header.toLowerCase();
      if (_isTypicalHeaderWord(headerLower)) {
        score += 0.3;
      }

      // Bonus por longitud razonable (3-30 caracteres)
      if (header.length >= 3 && header.length <= 30) {
        score += 0.2;
      }

      // Bonus por contener letras (no solo números)
      if (RegExp(r'[a-zA-Z]').hasMatch(header)) {
        score += 0.2;
      }

      // Penalización por parecer datos (fechas, números largos)
      if (_looksLikeData(header)) {
        score -= 0.3;
      }
    }

    // Normalizar score por número de headers válidos
    return validHeaders > 0 ? (score / validHeaders).clamp(0.0, 1.0) : 0.0;
  }

  /// 🔍 DETECTAR PALABRAS TÍPICAS DE HEADERS
  bool _isTypicalHeaderWord(String word) {
    const commonHeaders = [
      'nombre',
      'name',
      'apellido',
      'email',
      'correo',
      'telefono',
      'phone',
      'direccion',
      'address',
      'ciudad',
      'city',
      'empresa',
      'company',
      'fecha',
      'date',
      'id',
      'codigo',
      'code',
      'tipo',
      'type',
      'numero',
      'number',
      'colonia',
      'estado',
      'pais',
      'country'
    ];

    return commonHeaders.any((header) => word.contains(header));
  }

  /// 🔍 DETECTAR SI PARECE DATO EN LUGAR DE HEADER
  bool _looksLikeData(String value) {
    // Fechas
    if (RegExp(r'\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}').hasMatch(value))
      return true;

    // Números largos (más de 6 dígitos seguidos)
    if (RegExp(r'\d{7,}').hasMatch(value)) return true;

    // Emails
    if (value.contains('@') && value.contains('.')) return true;

    // Solo números
    if (RegExp(r'^\d+$').hasMatch(value.trim()) && value.length > 3)
      return true;

    return false;
  }

  // ========================================================================
  // 🔍 MÉTODOS DE DETECCIÓN AUTOMÁTICA (SIN CAMBIOS)
  // ========================================================================

  /// 🔍 DETECTAR ENCODING DEL ARCHIVO
  Encoding _detectEncoding(Uint8List bytes) {
    try {
      // 🔍 VERIFICAR BOM (Byte Order Mark)
      if (bytes.length >= 3) {
        // UTF-8 BOM: EF BB BF
        if (bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
          debugPrint('🔍 Detected UTF-8 BOM');
          return utf8;
        }
      }

      // 🔍 INTENTAR UTF-8 PRIMERO
      try {
        utf8.decode(bytes);
        debugPrint('🔍 Detected UTF-8 encoding');
        return utf8;
      } catch (e) {
        // Si falla UTF-8, intentar Latin-1
        debugPrint('🔍 UTF-8 failed, trying Latin-1');
        return latin1;
      }
    } catch (e) {
      debugPrint('⚠️ Error detecting encoding, defaulting to UTF-8: $e');
      return utf8;
    }
  }

  /// 🔍 DETECTAR DELIMITADOR CSV
  CsvDelimiter _detectDelimiter(String csvContent) {
    // 📊 TOMAR MUESTRA DE LAS PRIMERAS LÍNEAS
    final lines = csvContent.split('\n').take(10).toList();
    final sampleText = lines.join('\n');

    // 📊 CONTADORES PARA CADA DELIMITADOR
    final delimiterCounts = <CsvDelimiter, int>{};

    for (final delimiter in CsvDelimiter.values) {
      delimiterCounts[delimiter] =
          delimiter.value.allMatches(sampleText).length;
    }

    // 🏆 ENCONTRAR EL DELIMITADOR MÁS FRECUENTE
    CsvDelimiter mostFrequent = CsvDelimiter.comma;
    int maxCount = 0;

    for (final entry in delimiterCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostFrequent = entry.key;
      }
    }

    debugPrint(
        '🔍 Detected delimiter: ${mostFrequent.displayName} (count: $maxCount)');
    return mostFrequent;
  }

  // ========================================================================
  // 🧹 MÉTODOS DE LIMPIEZA DE DATOS (SIN CAMBIOS)
  // ========================================================================

  /// 🧹 REMOVER FILAS VACÍAS
  List<List<String>> _removeEmptyRows(List<List<String>> data) {
    return data
        .where((row) => row.any((cell) => cell.trim().isNotEmpty))
        .toList();
  }

  /// 🧹 RECORTAR ESPACIOS EN BLANCO
  List<List<String>> _trimWhitespace(List<List<String>> data) {
    return data.map((row) => row.map((cell) => cell.trim()).toList()).toList();
  }

  /// 🔧 NORMALIZAR LONGITUD DE FILAS
  List<List<String>> _normalizeRowLengths(
      List<List<String>> data, int expectedLength) {
    return data.map((row) {
      if (row.length == expectedLength) return row;

      if (row.length < expectedLength) {
        // Agregar celdas vacías al final
        final normalized = List<String>.from(row);
        while (normalized.length < expectedLength) {
          normalized.add('');
        }
        return normalized;
      } else {
        // Recortar celdas extra
        return row.take(expectedLength).toList();
      }
    }).toList();
  }

  // ========================================================================
  // 🛡️ MÉTODOS DE VALIDACIÓN (SIN CAMBIOS)
  // ========================================================================

  /// 🛡️ VALIDAR TAMAÑO DE ARCHIVO
  bool _validateFileSize(ImportFileInfo fileInfo) {
    return fileInfo.sizeBytes <= ImportLimits.maxFileSizeBytes;
  }

  /// 🔍 DETECTAR COLUMNAS AUTOMÁTICAMENTE
  List<String> detectColumns(List<List<String>> data, ImportOptions options) {
    if (data.isEmpty) return [];

    if (options.hasHeaders) {
      return data.first;
    } else {
      // Generar nombres de columnas automáticos
      final columnCount = data.first.length;
      return List.generate(columnCount, (index) => 'Columna ${index + 1}');
    }
  }

  /// 📊 OBTENER ESTADÍSTICAS DEL ARCHIVO
  Map<String, dynamic> getFileStatistics(ParseResult result) {
    if (!result.isSuccess) return {};

    final data = result.data;
    final headers = result.headers;

    // 📊 ESTADÍSTICAS BÁSICAS
    final stats = <String, dynamic>{
      'totalRows': data.length,
      'totalColumns': headers.length,
      'fileSize': result.fileInfo.sizeFormatted,
      'format': result.fileInfo.format.displayName,
    };

    // 📊 ANÁLISIS POR COLUMNA
    final columnStats = <String, Map<String, dynamic>>{};

    for (int colIndex = 0; colIndex < headers.length; colIndex++) {
      final columnName = headers[colIndex];
      final columnData = data
          .map((row) => colIndex < row.length ? row[colIndex] : '')
          .toList();

      final nonEmptyValues =
          columnData.where((value) => value.trim().isNotEmpty).toList();

      columnStats[columnName] = {
        'totalValues': columnData.length,
        'nonEmptyValues': nonEmptyValues.length,
        'emptyValues': columnData.length - nonEmptyValues.length,
        'fillRate': columnData.isNotEmpty
            ? (nonEmptyValues.length / columnData.length) * 100
            : 0,
        'sampleValues': nonEmptyValues.take(3).toList(),
      };
    }

    stats['columnStats'] = columnStats;
    return stats;
  }

  /// 🔍 DETECTAR PROBLEMAS POTENCIALES
  List<String> detectPotentialIssues(ParseResult result) {
    final issues = <String>[];

    if (!result.isSuccess) {
      issues.add('Error al procesar el archivo');
      return issues;
    }

    final data = result.data;
    final headers = result.headers;

    // 🔍 VERIFICAR DATOS VACÍOS
    if (data.isEmpty) {
      issues.add('El archivo no contiene datos');
      return issues;
    }

    // 🔍 VERIFICAR HEADERS DUPLICADOS
    final uniqueHeaders = headers.toSet();
    if (uniqueHeaders.length < headers.length) {
      issues.add('Se detectaron headers duplicados');
    }

    // 🔍 VERIFICAR LONGITUD INCONSISTENTE DE FILAS
    final expectedLength = headers.length;
    var inconsistentRows = 0;

    for (int i = 0; i < data.length; i++) {
      if (data[i].length != expectedLength) {
        inconsistentRows++;
      }
    }

    if (inconsistentRows > 0) {
      issues.add('$inconsistentRows filas tienen longitud inconsistente');
    }

    // 🔍 VERIFICAR COLUMNAS COMPLETAMENTE VACÍAS
    for (int colIndex = 0; colIndex < headers.length; colIndex++) {
      final columnValues = data
          .map((row) => colIndex < row.length ? row[colIndex].trim() : '')
          .toList();

      if (columnValues.every((value) => value.isEmpty)) {
        issues
            .add('La columna "${headers[colIndex]}" está completamente vacía');
      }
    }

    // 🔍 VERIFICAR TAMAÑO GRANDE
    if (data.length > 5000) {
      issues.add(
          'Archivo grande (${data.length} filas) - el procesamiento puede tomar tiempo');
    }

    return issues;
  }

  // ========================================================================
  // 🎯 MÉTODOS DE UTILIDAD PÚBLICA (SIN CAMBIOS)
  // ========================================================================

  /// 🎯 OBTENER MUESTRA DE DATOS PARA PREVIEW
  List<List<String>> getPreviewData(ParseResult result, {int maxRows = 10}) {
    if (!result.isSuccess || result.data.isEmpty) return [];

    return result.data.take(maxRows).toList();
  }

  /// 📊 DETECTAR FORMATO DE ARCHIVO POR EXTENSIÓN
  static ImportFormat? detectFormatByExtension(String filename) {
    final extension = filename.split('.').last.toLowerCase();

    for (final format in ImportFormat.values) {
      if (format.extensions.any((ext) => ext.substring(1) == extension)) {
        return format;
      }
    }

    return null;
  }

  /// 📊 DETECTAR FORMATO DE ARCHIVO POR MIME TYPE
  static ImportFormat? detectFormatByMimeType(String mimeType) {
    for (final format in ImportFormat.values) {
      if (format.mimeType == mimeType) {
        return format;
      }
    }

    return null;
  }

  /// 🧹 LIMPIAR RECURSOS
  void dispose() {
    // Limpiar cualquier recurso si es necesario
    debugPrint('🧹 FileParserService disposed');
  }
}
