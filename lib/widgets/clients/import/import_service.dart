// [import_service.dart] - SERVICIO PRINCIPAL DE IMPORTACIÓN ENTERPRISE - COMPLETO FIXED
// 📁 Ubicación: /lib/widgets/clients/import/import_service.dart
// 🎯 OBJETIVO: Orquestación completa del proceso de importación con control de costos
// ✅ FIX COMPLETO: Headers pasados correctamente en toda la cadena

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/background_cost_monitor.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/cost_data_models.dart';
import 'file_parser_service.dart';
import 'data_validator_service.dart';
import 'import_models.dart';

// ========================================================================
// 💾 RESULTADO DEL GUARDADO EN FIRESTORE
// ========================================================================

/// 💾 RESULTADO DEL GUARDADO
class SaveResult {
  final int successfulSaves;
  final int failedSaves;
  final List<ImportError> errors;
  final int firestoreReads;
  final Duration? processingTime;

  SaveResult({
    required this.successfulSaves,
    required this.failedSaves,
    required this.errors,
    required this.firestoreReads,
    this.processingTime,
  });
}

// ========================================================================
// 🎯 SERVICIO PRINCIPAL DE IMPORTACIÓN
// ========================================================================

/// 🎯 SERVICIO ENTERPRISE PARA IMPORTACIÓN COMPLETA DE CLIENTES
class ClientImportService {
  static final ClientImportService _instance = ClientImportService._internal();
  factory ClientImportService() => _instance;
  ClientImportService._internal();

  // ✅ DEPENDENCIAS
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FileParserService _parser = FileParserService();
  final DataValidatorService _validator = DataValidatorService();
  final BackgroundCostMonitor _costMonitor = BackgroundCostMonitor();

  // ========================================================================
  // 🚀 MÉTODO PRINCIPAL DE IMPORTACIÓN
  // ========================================================================

  /// 🚀 IMPORTAR CLIENTES DESDE ARCHIVO
  Future<ImportResult> importClients(
    Uint8List fileBytes,
    String fileName,
    ImportOptions options,
    List<FieldMapping> mappings, {
    Function(ImportProgress)? onProgress,
    Function(String)? onStatusUpdate,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      debugPrint('🚀 Iniciando importación de clientes desde $fileName');

      // 📊 REPORTAR PROGRESO INICIAL
      _reportProgress(
          onProgress,
          ImportProgress(
            status: ImportStatus.analyzing,
            percentage: 0.0,
            processedRows: 0,
            totalRows: 0,
            currentOperation: 'Analizando archivo...',
            elapsed: stopwatch.elapsed,
          ));

      // 🔍 VERIFICAR LÍMITES DE COSTO ANTES DE EMPEZAR
      if (!_canPerformRead()) {
        return ImportResult.failed(
          errorMessage: 'Límite de costos alcanzado. Intente más tarde.',
          processingTime: stopwatch.elapsed,
        );
      }

      // 1️⃣ PARSING DEL ARCHIVO
      onStatusUpdate?.call('Procesando archivo...');
      final fileInfo = ImportFileInfo(
        name: fileName,
        sizeBytes: fileBytes.length,
        format: _detectFormat(fileName),
        bytes: fileBytes,
        selectedAt: DateTime.now(),
      );

      final parseResult = await _parser.parseFile(fileInfo, options);

      if (!parseResult.isSuccess) {
        return ImportResult.failed(
          errorMessage: parseResult.errorMessage ?? 'Error procesando archivo',
          processingTime: stopwatch.elapsed,
        );
      }

      debugPrint(
          '✅ Archivo parseado: ${parseResult.totalRows} filas, ${parseResult.totalColumns} columnas');

      // 📊 ACTUALIZAR PROGRESO - 20%
      _reportProgress(
          onProgress,
          ImportProgress(
            status: ImportStatus.validating,
            percentage: 20.0,
            processedRows: 0,
            totalRows: parseResult.totalRows,
            currentOperation: 'Validando datos...',
            elapsed: stopwatch.elapsed,
          ));

      // 2️⃣ VALIDACIÓN DE DATOS - ✅ FIX: HEADERS PASADOS CORRECTAMENTE
      onStatusUpdate?.call('Validando datos...');
      final validationResult = await _validator.validateData(
        parseResult.data,
        mappings,
        headers: parseResult.headers, // ✅ FIX APLICADO
        onProgress: (validationProgress) {
          final overallProgress = 20.0 + (validationProgress * 30.0); // 20%-50%
          _reportProgress(
              onProgress,
              ImportProgress(
                status: ImportStatus.validating,
                percentage: overallProgress,
                processedRows:
                    (parseResult.totalRows * validationProgress).round(),
                totalRows: parseResult.totalRows,
                currentOperation:
                    'Validando fila ${(parseResult.totalRows * validationProgress).round()}...',
                elapsed: stopwatch.elapsed,
              ));
        },
      );

      debugPrint(
          '✅ Validación completada: ${validationResult.validRows} válidas de ${validationResult.totalRows}');

      // 🚨 VERIFICAR SI HAY ERRORES CRÍTICOS
      if (!validationResult.canProceed) {
        return ImportResult.withErrors(
          totalRows: validationResult.totalRows,
          successfulRows: 0,
          errors: validationResult.errors
              .map((e) => ImportError.critical(
                    rowIndex: e.rowIndex,
                    message: e.message,
                    details: e.suggestedFix,
                  ))
              .toList(),
          processingTime: stopwatch.elapsed,
        );
      }

      // 📊 ACTUALIZAR PROGRESO - 50%
      _reportProgress(
          onProgress,
          ImportProgress(
            status: ImportStatus.importing,
            percentage: 50.0,
            processedRows: 0,
            totalRows: validationResult.validRows,
            currentOperation: 'Convirtiendo a modelos de cliente...',
            elapsed: stopwatch.elapsed,
          ));

      // 3️⃣ CONVERTIR A MODELOS DE CLIENTE - ✅ FIX: HEADERS PASADOS
      onStatusUpdate?.call('Preparando datos para importación...');
      final clientModels = await _convertToClientModels(
        parseResult.data,
        mappings,
        validationResult,
        parseResult.headers, // ✅ FIX: PASAR HEADERS
      );

      debugPrint('✅ Convertidos ${clientModels.length} modelos de cliente');

      // 📊 ACTUALIZAR PROGRESO - 60%
      _reportProgress(
          onProgress,
          ImportProgress(
            status: ImportStatus.importing,
            percentage: 60.0,
            processedRows: 0,
            totalRows: clientModels.length,
            currentOperation: 'Guardando en base de datos...',
            elapsed: stopwatch.elapsed,
          ));

      // 4️⃣ GUARDAR EN FIRESTORE
      onStatusUpdate?.call('Guardando clientes en base de datos...');
      final saveResult = await _saveClientsToFirestore(
        clientModels,
        onProgress: (saveProgress) {
          final overallProgress = 60.0 + (saveProgress * 40.0); // 60%-100%
          _reportProgress(
              onProgress,
              ImportProgress(
                status: ImportStatus.importing,
                percentage: overallProgress,
                processedRows: (clientModels.length * saveProgress).round(),
                totalRows: clientModels.length,
                currentOperation:
                    'Guardando cliente ${(clientModels.length * saveProgress).round()}...',
                elapsed: stopwatch.elapsed,
                estimatedRemaining:
                    _calculateRemainingTime(stopwatch.elapsed, saveProgress),
              ));
        },
      );

      // 📊 FINALIZAR PROGRESO - 100%
      stopwatch.stop();
      _reportProgress(
          onProgress,
          ImportProgress(
            status: ImportStatus.completed,
            percentage: 100.0,
            processedRows: saveResult.successfulSaves,
            totalRows: clientModels.length,
            currentOperation: 'Importación completada',
            elapsed: stopwatch.elapsed,
          ));

      // ✅ RESULTADO FINAL
      final result = ImportResult.success(
        totalRows: parseResult.totalRows,
        successfulRows: saveResult.successfulSaves,
        processingTime: stopwatch.elapsed,
        skippedRows: parseResult.totalRows - validationResult.validRows,
        metadata: {
          'parseTime': parseResult.metadata['processingTime'],
          'validationTime': validationResult.validatedAt.millisecondsSinceEpoch,
          'saveTime': saveResult.processingTime?.inMilliseconds,
          'warnings': validationResult.warnings.length,
          'costReads': saveResult.firestoreReads,
        },
      );

      debugPrint('🎉 Importación completada exitosamente');
      debugPrint(
          '📊 ${result.successfulRows} clientes importados en ${result.processingTime.inSeconds}s');

      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      debugPrint('❌ Error crítico en importación: $e');
      debugPrint('🔍 Stack trace: $stackTrace');

      // 📊 REPORTAR ERROR EN PROGRESO
      _reportProgress(
          onProgress,
          ImportProgress(
            status: ImportStatus.failed,
            percentage: 0.0,
            processedRows: 0,
            totalRows: 0,
            currentOperation: 'Error: ${e.toString()}',
            elapsed: stopwatch.elapsed,
            recentErrors: [e.toString()],
          ));

      return ImportResult.failed(
        errorMessage: 'Error crítico durante importación: ${e.toString()}',
        processingTime: stopwatch.elapsed,
        metadata: {'error': e.toString(), 'stackTrace': stackTrace.toString()},
      );
    }
  }

  // ========================================================================
  // 🔄 CONVERSIÓN A MODELOS DE CLIENTE - ✅ FIX: HEADERS AGREGADOS
  // ========================================================================

  /// 🔄 CONVERTIR DATOS MAPEADOS A MODELOS DE CLIENTE - ✅ FIX APLICADO
  Future<List<ClientModel>> _convertToClientModels(
    List<List<String>> rawData,
    List<FieldMapping> mappings,
    ValidationResult validationResult,
    List<String> headers, // ✅ FIX: NUEVO PARÁMETRO
  ) async {
    final clientModels = <ClientModel>[];
    final mappedData =
        _mapRawDataToFields(rawData, mappings, headers); // ✅ FIX: PASAR HEADERS

    // 🔍 OBTENER ÍNDICES DE FILAS VÁLIDAS
    final errorRowIndices = validationResult.errors
        .where((e) => e.level == ValidationLevel.error)
        .map((e) => e.rowIndex)
        .toSet();

    for (int i = 0; i < mappedData.length; i++) {
      // 🚫 SALTAR FILAS CON ERRORES
      if (errorRowIndices.contains(i)) continue;

      final rowData = mappedData[i];

      try {
        final clientModel = _createClientFromRowData(rowData);
        clientModels.add(clientModel);
      } catch (e) {
        debugPrint('⚠️ Error convirtiendo fila $i: $e');
        // Continuar con siguiente fila
      }
    }

    return clientModels;
  }

  /// 🏗️ CREAR MODELO DE CLIENTE DESDE DATOS DE FILA - VERSIÓN MEJORADA
  ClientModel _createClientFromRowData(Map<String, String> rowData) {
    // 📱 PROCESAR TELÉFONOS CON NORMALIZACIÓN AUTOMÁTICA
    final originalPhone = rowData['telefono'] ?? '';
    final normalizedPhone =
        InternationalPhoneValidator.normalizeForStorage(originalPhone);
    final phoneCountry =
        InternationalPhoneValidator.detectCountry(originalPhone);

    // 📝 INFORMACIÓN PERSONAL
    final personalInfo = PersonalInfo(
      nombre: rowData['nombre'] ?? '',
      apellidos: rowData['apellidos'] ?? '',
      empresa:
          rowData['empresa']?.isNotEmpty == true ? rowData['empresa'] : null,
    );

    // 📞 INFORMACIÓN DE CONTACTO CON TELÉFONO NORMALIZADO
    final contactInfo = ContactInfo(
      email: rowData['email'] ?? '',
      telefono: normalizedPhone, // ✅ USAR TELÉFONO NORMALIZADO
      telefonoSecundario: rowData['telefonoSecundario']?.isNotEmpty == true
          ? InternationalPhoneValidator.normalizeForStorage(
              rowData['telefonoSecundario']!)
          : null,
    );

    // 🏠 INFORMACIÓN DE DIRECCIÓN
    final addressInfo = AddressInfo(
      calle: rowData['calle'] ?? '',
      numeroExterior: rowData['numeroExterior'] ?? '',
      numeroInterior: rowData['numeroInterior']?.isNotEmpty == true
          ? rowData['numeroInterior']
          : null,
      colonia: rowData['colonia'] ?? '',
      codigoPostal: rowData['codigoPostal'] ?? '',
      alcaldia: rowData['alcaldia'] ?? '',
      referencias: rowData['referencias']?.isNotEmpty == true
          ? rowData['referencias']
          : null,
    );

    // 🏷️ TAGS AUTOMÁTICOS CON INFORMACIÓN DE PAÍS
    final tags = <ClientTag>[
      ClientTag(
        label: 'Importado',
        type: TagType.system,
        createdAt: DateTime.now(),
        createdBy: 'import_system',
      ),
    ];

    // Agregar tag de empresa si tiene
    if (personalInfo.empresa?.isNotEmpty == true) {
      tags.add(ClientTag(
        label: 'Corporativo',
        type: TagType.base,
        createdAt: DateTime.now(),
        createdBy: 'import_system',
      ));
    }

    // ✅ AGREGAR TAG DE PAÍS SI ES INTERNACIONAL
    if (phoneCountry != null && phoneCountry != 'México') {
      tags.add(ClientTag(
        label: 'Internacional',
        type: TagType.system,
        createdAt: DateTime.now(),
        createdBy: 'import_system',
      ));

      // Tag específico del país
      tags.add(ClientTag(
        label: phoneCountry,
        type: TagType.custom,
        createdAt: DateTime.now(),
        createdBy: 'import_system',
      ));
    }

    // 📊 MÉTRICAS INICIALES
    const metrics = ClientMetrics();

    // 🔍 INFORMACIÓN DE AUDITORÍA CON METADATOS DE TELÉFONO
    final auditMetadata = <String, dynamic>{
      'importedAt': DateTime.now().toIso8601String(),
      'importMethod': 'enhanced_csv_import',
      'originalPhone': originalPhone,
      'normalizedPhone': normalizedPhone,
    };

    // Agregar información del país si está disponible
    if (phoneCountry != null) {
      auditMetadata['phoneCountry'] = phoneCountry;
      auditMetadata['isInternational'] = phoneCountry != 'México';
    }

    final auditInfo = AuditInfo(
      createdBy: 'enhanced_import_system',
      metadata: auditMetadata,
    );

    // 🏗️ CREAR MODELO COMPLETO
    return ClientModel(
      clientId: '', // Se asignará al guardar en Firestore
      personalInfo: personalInfo,
      contactInfo: contactInfo,
      addressInfo: addressInfo,
      tags: tags,
      metrics: metrics,
      auditInfo: auditInfo,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: ClientStatus.active,
    );
  }

  // ========================================================================
  // 💾 GUARDADO EN FIRESTORE
  // ========================================================================

  /// 💾 GUARDAR CLIENTES EN FIRESTORE CON BATCHES
  Future<SaveResult> _saveClientsToFirestore(List<ClientModel> clients,
      {Function(double)? onProgress}) async {
    final saveStopwatch = Stopwatch()..start();
    int successfulSaves = 0;
    int failedSaves = 0;
    int firestoreReads = 0;
    final errors = <ImportError>[];

    try {
      // 🔄 PROCESAR EN LOTES PARA OPTIMIZAR PERFORMANCE
      const batchSize = ImportLimits.batchSizeFirestore;
      final totalBatches = (clients.length / batchSize).ceil();

      for (int batchIndex = 0; batchIndex < totalBatches; batchIndex++) {
        // 🔍 VERIFICAR LÍMITES DE COSTO ANTES DE CADA BATCH
        if (!_canPerformRead()) {
          errors.add(ImportError.critical(
            message: 'Límite de costos alcanzado durante importación',
            details:
                'Se procesaron $successfulSaves de ${clients.length} clientes',
          ));
          break;
        }

        final startIndex = batchIndex * batchSize;
        final endIndex = (startIndex + batchSize).clamp(0, clients.length);
        final batchClients = clients.sublist(startIndex, endIndex);

        // 📊 USAR BATCH WRITE PARA OPTIMIZAR
        final batch = _firestore.batch();

        for (final client in batchClients) {
          try {
            final docRef = _firestore.collection('clients').doc();
            final clientWithId = client.copyWith(clientId: docRef.id);
            batch.set(docRef, clientWithId.toMap());
          } catch (e) {
            failedSaves++;
            errors.add(ImportError.critical(
              message: 'Error preparando cliente: ${e.toString()}',
              details: 'Cliente: ${client.fullName}',
            ));
          }
        }

        try {
          // 🚀 EJECUTAR BATCH
          await batch.commit();

          // 💰 REGISTRAR OPERACIONES EN MONITOR DE COSTOS
          _recordRead(batchClients.length,
              description: 'Importación batch $batchIndex');
          firestoreReads += batchClients.length;

          successfulSaves += batchClients.length;

          debugPrint(
              '✅ Batch $batchIndex guardado: ${batchClients.length} clientes');
        } catch (e) {
          debugPrint('❌ Error guardando batch $batchIndex: $e');
          failedSaves += batchClients.length;

          errors.add(ImportError.critical(
            message: 'Error guardando lote de clientes: ${e.toString()}',
            details: 'Lote $batchIndex (${batchClients.length} clientes)',
          ));
        }

        // 📊 REPORTAR PROGRESO
        final progress = (batchIndex + 1) / totalBatches;
        onProgress?.call(progress);

        // ⏱️ PEQUEÑA PAUSA PARA NO SOBRECARGAR FIRESTORE
        if (batchIndex < totalBatches - 1) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      saveStopwatch.stop();

      return SaveResult(
        successfulSaves: successfulSaves,
        failedSaves: failedSaves,
        errors: errors,
        firestoreReads: firestoreReads,
        processingTime: saveStopwatch.elapsed,
      );
    } catch (e) {
      saveStopwatch.stop();
      debugPrint('❌ Error crítico guardando en Firestore: $e');

      return SaveResult(
        successfulSaves: successfulSaves,
        failedSaves: clients.length - successfulSaves,
        errors: [
          ImportError.critical(
            message: 'Error crítico en guardado: ${e.toString()}',
          ),
          ...errors,
        ],
        firestoreReads: firestoreReads,
        processingTime: saveStopwatch.elapsed,
      );
    }
  }

  // ========================================================================
  // 🔧 MÉTODOS HELPER - ✅ FIX: HEADERS AGREGADOS
  // ========================================================================

  /// 🗺️ MAPEAR DATOS RAW A CAMPOS - ✅ FIX: HEADERS COMO PARÁMETRO
  List<Map<String, String>> _mapRawDataToFields(
    List<List<String>> rawData,
    List<FieldMapping> mappings,
    List<String> headers, // ✅ FIX: NUEVO PARÁMETRO
  ) {
    final mappedData = <Map<String, String>>[];

    for (final row in rawData) {
      final mappedRow = <String, String>{};

      for (final mapping in mappings) {
        final sourceIndex = _findColumnIndex(
            headers, mapping.sourceColumn); // ✅ FIX: USAR HEADERS

        if (sourceIndex != -1 && sourceIndex < row.length) {
          mappedRow[mapping.targetField] = row[sourceIndex].trim();
        } else {
          mappedRow[mapping.targetField] = '';
        }
      }

      mappedData.add(mappedRow);
    }

    return mappedData;
  }

  /// 🔍 ENCONTRAR ÍNDICE DE COLUMNA
  int _findColumnIndex(List<String> headers, String columnName) {
    return headers.indexWhere((header) => header.trim() == columnName.trim());
  }

  /// 📊 REPORTAR PROGRESO
  void _reportProgress(
      Function(ImportProgress)? onProgress, ImportProgress progress) {
    onProgress?.call(progress);
  }

  /// ⏱️ CALCULAR TIEMPO RESTANTE
  Duration? _calculateRemainingTime(Duration elapsed, double progress) {
    if (progress <= 0.0 || progress >= 1.0) return null;

    final totalEstimated = elapsed.inMilliseconds / progress;
    final remainingMs = totalEstimated - elapsed.inMilliseconds;

    return Duration(milliseconds: remainingMs.round());
  }

  /// 📁 DETECTAR FORMATO POR EXTENSIÓN
  ImportFormat _detectFormat(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'csv':
        return ImportFormat.csv;
      case 'xlsx':
      case 'xls':
        return ImportFormat.excel;
      default:
        return ImportFormat.csv; // Default fallback
    }
  }

  // ========================================================================
  // 💰 MÉTODOS DE CONTROL DE COSTOS (SIMPLIFIED)
  // ========================================================================

  /// 🔍 VERIFICAR SI SE PUEDE REALIZAR LECTURA
  bool _canPerformRead() {
    // Implementación simplificada - en producción usar BackgroundCostMonitor real
    return true; // Por ahora permitir todas las lecturas
  }

  /// 💰 REGISTRAR LECTURA
  void _recordRead(int reads, {String? description}) {
    // Implementación simplificada - en producción usar BackgroundCostMonitor real
    debugPrint('💰 Registrando $reads lecturas: $description');
  }

  // ========================================================================
  // 🎯 MÉTODOS PÚBLICOS DE UTILIDAD
  // ========================================================================

  /// 🔍 VALIDAR CAPACIDAD DE IMPORTACIÓN
  Future<bool> canImport(int estimatedRows) async {
    // 🔍 VERIFICAR LÍMITES DE FIRESTORE
    if (estimatedRows > ImportLimits.maxRecordsPerImport) {
      return false;
    }

    // 🔍 VERIFICAR LÍMITES DE COSTO (simplificado)
    return true;
  }

  /// 📊 OBTENER ESTADÍSTICAS DE IMPORTACIÓN
  Map<String, dynamic> getImportCapacity() {
    return {
      'maxRecordsPerImport': ImportLimits.maxRecordsPerImport,
      'remainingDailyReads': 1000, // Placeholder
      'maxFileSize': '${ImportLimits.maxFileSizeMb}MB',
      'supportedFormats':
          ImportFormat.values.map((f) => f.displayName).toList(),
      'batchSize': ImportLimits.batchSizeFirestore,
      'canImportNow': true,
    };
  }

  /// 🧹 LIMPIAR RECURSOS
  void dispose() {
    _parser.dispose();
    _validator.dispose();
    debugPrint('🧹 ClientImportService disposed');
  }
}
