// [data_validator_service.dart] - VALIDADOR ENTERPRISE DE DATOS DE IMPORTACIÓN - FIX NIVELES
// 📁 Ubicación: /lib/widgets/clients/import/data_validator_service.dart
// 🎯 OBJETIVO: Validación robusta con detección de duplicados y sugerencias de corrección
// ✅ FIX CRÍTICO: Solo nombre es error bloqueante, apellidos es warning

import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'import_models.dart';

// ========================================================================
// 🛡️ SERVICIO PRINCIPAL DE VALIDACIÓN
// ========================================================================

/// 🛡️ VALIDADOR ENTERPRISE PARA DATOS DE IMPORTACIÓN - ✅ FIX CRÍTICO
class DataValidatorService {
  static final DataValidatorService _instance =
      DataValidatorService._internal();
  factory DataValidatorService() => _instance;
  DataValidatorService._internal();

  // ========================================================================
  // 🎯 MÉTODO PRINCIPAL DE VALIDACIÓN - ✅ FIX CRÍTICO
  // ========================================================================

  /// 🎯 VALIDAR DATOS COMPLETOS CON MAPEO - ✅ FIX: HEADERS COMO PARÁMETRO
  Future<ValidationResult> validateData(
    List<List<String>> rawData,
    List<FieldMapping> mappings, {
    List<String>? headers, // ✅ NUEVO: Headers como parámetro opcional
    Function(double)? onProgress,
  }) async {
    final stackTrace = StackTrace.current.toString();
    debugPrint('🚨 === VALIDACIÓN LLAMADA ===');
    debugPrint('🚨 Filas: ${rawData.length}');
    debugPrint('🚨 Headers: ${headers?.length ?? 0}');
    debugPrint('🚨 Mappings: ${mappings.length}');
    debugPrint('🚨 Headers reales: ${headers?.take(5).join(", ")}...');
    debugPrint(
        '🚨 Primera fila: ${rawData.isNotEmpty ? rawData.first.take(5).join(", ") : "vacía"}...');
    debugPrint('🚨 STACK TRACE:');
    final stopwatch = Stopwatch()..start();

    try {
      debugPrint('🛡️ Iniciando validación de ${rawData.length} filas');

      final errors = <ValidationError>[];
      final warnings = <ValidationError>[];
      final infos = <ValidationError>[];

      // ✅ FIX CRÍTICO: Usar headers pasados como parámetro
      final actualHeaders =
          headers ?? (rawData.isNotEmpty ? rawData.first : <String>[]);

      debugPrint('🔧 Headers recibidos para validación: $actualHeaders');

      // 📊 CONVERTIR DATOS A FORMATO MAPEADO - ✅ CON HEADERS CORRECTOS
      final mappedData = _mapRawDataToFields(rawData, mappings, actualHeaders);

      int validRows = 0;

      // 🔍 VALIDAR CADA FILA
      for (int rowIndex = 0; rowIndex < mappedData.length; rowIndex++) {
        final rowData = mappedData[rowIndex];
        bool rowIsValid = true;

        // 📊 REPORTE DE PROGRESO
        if (onProgress != null && rowIndex % 100 == 0) {
          final progress = (rowIndex / mappedData.length) *
              0.8; // 80% para validación individual
          onProgress(progress);
        }

        // 🛡️ VALIDAR CADA CAMPO MAPEADO
        for (final mapping in mappings) {
          final value = rowData[mapping.targetField] ?? '';
          final fieldErrors = _validateField(
            value,
            mapping,
            rowIndex,
          );

          for (final error in fieldErrors) {
            switch (error.level) {
              case ValidationLevel.error:
                errors.add(error);
                rowIsValid = false;
                break;
              case ValidationLevel.warning:
                warnings.add(error);
                break;
              case ValidationLevel.info:
                infos.add(error);
                break;
            }
          }
        }

        if (rowIsValid) validRows++;

        // 🚨 LÍMITE DE ERRORES PARA PERFORMANCE
        if (errors.length > ImportLimits.MAX_VALIDATION_ERRORS_DISPLAY) {
          debugPrint(
              '⚠️ Límite de errores alcanzado, deteniendo validación detallada');
          break;
        }
      }

      // 📊 ACTUALIZAR PROGRESO A 80%
      onProgress?.call(0.8);

      // 🔍 VALIDACIONES GLOBALES
      await _performGlobalValidations(
        mappedData,
        mappings,
        errors,
        warnings,
        infos,
      );

      // 📊 ACTUALIZAR PROGRESO A 100%
      onProgress?.call(1.0);

      stopwatch.stop();
      debugPrint(
          '✅ Validación completada en ${stopwatch.elapsed.inMilliseconds}ms');
      debugPrint(
          '📊 Resultado: $validRows válidas, ${errors.length} errores, ${warnings.length} advertencias');

      return ValidationResult(
        errors: errors,
        warnings: warnings,
        infos: infos,
        totalRows: rawData.length,
        validRows: validRows,
        validatedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      stopwatch.stop();
      debugPrint('❌ Error en validación: $e');
      debugPrint('🔍 Stack trace: $stackTrace');

      return ValidationResult(
        errors: [
          ValidationError(
            rowIndex: -1,
            columnName: 'Sistema',
            originalValue: '',
            level: ValidationLevel.error,
            message: 'Error interno de validación: ${e.toString()}',
          ),
        ],
        warnings: [],
        infos: [],
        totalRows: rawData.length,
        validRows: 0,
        validatedAt: DateTime.now(),
      );
    }
  }

  // ========================================================================
  // 🗺️ MAPEO DE DATOS - ✅ FIX CRÍTICO COMPLETO
  // ========================================================================

  /// 🗺️ MAPEAR DATOS RAW A CAMPOS - ✅ FIX CRÍTICO: DEBUG COMPLETO
  List<Map<String, String>> _mapRawDataToFields(
    List<List<String>> rawData,
    List<FieldMapping> mappings,
    List<String> headers,
  ) {
    final mappedData = <Map<String, String>>[];

    // ✅ FIX: DEBUG COMPLETO DE ENTRADA
    debugPrint('🗺️ FIX: === MAPEO INICIADO ===');
    debugPrint('🗺️ FIX: Raw data filas: ${rawData.length}');
    debugPrint('🗺️ FIX: Headers recibidos (${headers.length}): $headers');
    debugPrint('🗺️ FIX: Mappings (${mappings.length}):');
    for (final mapping in mappings) {
      debugPrint(
          '  FIX: ${mapping.targetField} -> "${mapping.sourceColumn}" (required: ${mapping.isRequired})');
    }

    for (int rowIndex = 0; rowIndex < rawData.length; rowIndex++) {
      final row = rawData[rowIndex];
      final mappedRow = <String, String>{};

      if (rowIndex == 0) {
        debugPrint('🗺️ FIX: Primera fila (${row.length} columnas): $row');
      }

      for (final mapping in mappings) {
        final sourceIndex =
            _findColumnIndexByHeader(headers, mapping.sourceColumn);

        if (sourceIndex != -1 && sourceIndex < row.length) {
          final value = row[sourceIndex].trim();
          mappedRow[mapping.targetField] = value;

          // ✅ FIX: DEBUG DETALLADO PARA CAMPOS CRÍTICOS
          if (mapping.targetField == 'apellidos' || mapping.isRequired) {
            debugPrint(
                '✅ FIX: Campo "${mapping.targetField}": header "${mapping.sourceColumn}" -> índice $sourceIndex = "$value"');
          }
        } else {
          mappedRow[mapping.targetField] = '';

          // ✅ FIX: DEBUG PARA CAMPOS NO ENCONTRADOS
          if (mapping.isRequired) {
            debugPrint(
                '❌ FIX: Campo obligatorio "${mapping.targetField}" NO ENCONTRÓ header "${mapping.sourceColumn}"');
            debugPrint(
                '    FIX: sourceIndex=$sourceIndex, row.length=${row.length}');
          }
        }
      }

      mappedData.add(mappedRow);
    }

    debugPrint('🗺️ FIX: === MAPEO COMPLETADO ===');
    return mappedData;
  }

  /// 🔍 ENCONTRAR ÍNDICE DE COLUMNA POR HEADER EXACTO - ✅ FIX COMPLETO
  int _findColumnIndexByHeader(List<String> headers, String columnName) {
    if (headers.isEmpty || columnName.isEmpty) {
      debugPrint('⚠️ Headers vacíos o columnName vacío');
      return -1;
    }

    debugPrint('🔍 FIX: Buscando "$columnName" en headers: ${headers.asMap()}');

    // ✅ FIX CRÍTICO: Búsqueda exacta case-sensitive primero
    for (int i = 0; i < headers.length; i++) {
      if (headers[i] == columnName) {
        debugPrint(
            '✅ FIX: Header "$columnName" encontrado EXACTAMENTE en índice $i');
        return i;
      }
    }

    // ✅ FIX: Búsqueda case-insensitive como fallback
    for (int i = 0; i < headers.length; i++) {
      if (headers[i].toLowerCase().trim() == columnName.toLowerCase().trim()) {
        debugPrint(
            '✅ FIX: Header "$columnName" encontrado (case-insensitive) en índice $i');
        return i;
      }
    }

    // ✅ FIX: Búsqueda parcial (contiene) como último recurso
    for (int i = 0; i < headers.length; i++) {
      if (headers[i].toLowerCase().contains(columnName.toLowerCase()) &&
          columnName.toLowerCase().contains(headers[i].toLowerCase())) {
        debugPrint(
            '✅ FIX: Header "$columnName" encontrado (parcial) en índice $i');
        return i;
      }
    }

    // 🔧 DEBUG COMPLETO: Si no encuentra, mostrar headers disponibles
    debugPrint('❌ FIX: No se encontró header "$columnName"');
    debugPrint('📋 FIX: Headers disponibles con índices:');
    for (int i = 0; i < headers.length; i++) {
      debugPrint('    [$i]: "${headers[i]}"');
    }

    return -1;
  }

  /// 🔍 ENCONTRAR ÍNDICE DE COLUMNA - MÉTODO LEGACY (MANTENER COMPATIBILIDAD)
  int _findColumnIndex(List<String> headers, String columnName) {
    return headers.indexWhere((header) => header.trim() == columnName.trim());
  }

  // ========================================================================
  // 🛡️ VALIDACIÓN POR CAMPO - SIN CAMBIOS
  // ========================================================================

  /// 🛡️ VALIDAR CAMPO INDIVIDUAL
  List<ValidationError> _validateField(
    String value,
    FieldMapping mapping,
    int rowIndex,
  ) {
    final errors = <ValidationError>[];

    // 🔍 VALIDAR CON CADA VALIDADOR CONFIGURADO
    for (final validator in mapping.validators) {
      if (!validator.validate(value)) {
        final level = _determineValidationLevel(validator, mapping);

        errors.add(ValidationError(
          rowIndex: rowIndex,
          columnName: mapping.sourceColumn,
          originalValue: value,
          level: level,
          message: validator.errorMessage,
          suggestedFix: validator.suggestedFix,
        ));

        // Si es error crítico, no seguir validando este campo
        if (level == ValidationLevel.error) break;
      }
    }

    return errors;
  }

  /// 🎯 DETERMINAR NIVEL DE VALIDACIÓN - ✅ FIX CRÍTICO
  ValidationLevel _determineValidationLevel(
    FieldValidator validator,
    FieldMapping mapping,
  ) {
    // ✅ FIX CRÍTICO: SOLO NOMBRE ES ERROR BLOQUEANTE
    if (validator is RequiredValidator && mapping.targetField == 'nombre') {
      return ValidationLevel.error;
    }

    // ✅ FIX: APELLIDOS VACÍOS SON WARNING, NO ERROR
    if (validator is RequiredValidator && mapping.targetField == 'apellidos') {
      return ValidationLevel.warning;
    }

    // ✅ EMAIL: warning si formato incorrecto, no error crítico
    if (validator is FlexibleEmailValidator) {
      return ValidationLevel.warning;
    }

    // ✅ TELÉFONO: siempre warning, nunca bloquea importación
    if (validator is InternationalPhoneValidator) {
      return ValidationLevel.warning;
    }

    // ✅ CÓDIGO POSTAL: warning para formatos incorrectos
    if (validator is FlexiblePostalCodeValidator) {
      return ValidationLevel.warning;
    }

    // ✅ VALIDADORES DE LONGITUD: warning para campos opcionales
    if (validator is LengthValidator) {
      return ValidationLevel.warning;
    }

    // ✅ POR DEFECTO: warning (no bloquea importación)
    return ValidationLevel.warning;
  }

  // ========================================================================
  // 🌍 VALIDACIONES GLOBALES - SIN CAMBIOS
  // ========================================================================

  /// 🌍 REALIZAR VALIDACIONES GLOBALES
  Future<void> _performGlobalValidations(
    List<Map<String, String>> mappedData,
    List<FieldMapping> mappings,
    List<ValidationError> errors,
    List<ValidationError> warnings,
    List<ValidationError> infos,
  ) async {
    // 🔍 VALIDAR DUPLICADOS POR EMAIL
    if (_hasMappingForField(mappings, 'email')) {
      await _validateDuplicateEmails(mappedData, errors, warnings);
    }

    // 🔍 VALIDAR DUPLICADOS POR TELÉFONO
    if (_hasMappingForField(mappings, 'telefono')) {
      await _validateDuplicatePhones(mappedData, warnings, infos);
    }

    // 🔍 VALIDAR CÓDIGOS POSTALES CONSISTENTES
    if (_hasMappingForField(mappings, 'codigoPostal') &&
        _hasMappingForField(mappings, 'alcaldia')) {
      await _validatePostalCodeConsistency(mappedData, warnings);
    }

    // 📊 VALIDAR DISTRIBUCIÓN DE DATOS
    await _validateDataDistribution(mappedData, infos);

    // ✅ NUEVA: VALIDAR COMBINACIONES NOMBRE+APELLIDOS DUPLICADAS
    if (_hasMappingForField(mappings, 'nombre') &&
        _hasMappingForField(mappings, 'apellidos')) {
      await _validateDuplicateNames(mappedData, warnings);
    }
  }

  /// 🔍 VERIFICAR SI HAY MAPEO PARA UN CAMPO
  bool _hasMappingForField(List<FieldMapping> mappings, String fieldName) {
    return mappings.any((mapping) => mapping.targetField == fieldName);
  }

  // ========================================================================
  // 📧 VALIDACIÓN DE DUPLICADOS EMAIL
  // ========================================================================

  /// 📧 VALIDAR EMAILS DUPLICADOS
  Future<void> _validateDuplicateEmails(
    List<Map<String, String>> mappedData,
    List<ValidationError> errors,
    List<ValidationError> warnings,
  ) async {
    final emailCounts = <String, List<int>>{};

    // 📊 CONTABILIZAR EMAILS
    for (int i = 0; i < mappedData.length; i++) {
      final email = mappedData[i]['email']?.trim().toLowerCase() ?? '';
      if (email.isNotEmpty && email.contains('@')) {
        emailCounts.putIfAbsent(email, () => []).add(i);
      }
    }

    // 🔍 REPORTAR DUPLICADOS COMO WARNING (no bloquear)
    for (final entry in emailCounts.entries) {
      if (entry.value.length > 1) {
        for (final rowIndex in entry.value) {
          warnings.add(ValidationError(
            rowIndex: rowIndex,
            columnName: 'email',
            originalValue: entry.key,
            level: ValidationLevel.warning,
            message:
                'Email duplicado encontrado en ${entry.value.length} filas',
            suggestedFix:
                'Verificar si son clientes diferentes o actualizar email',
          ));
        }
      }
    }
  }

  // ========================================================================
  // 📱 VALIDACIÓN DE DUPLICADOS TELÉFONO
  // ========================================================================

  /// 📱 VALIDAR TELÉFONOS DUPLICADOS
  Future<void> _validateDuplicatePhones(
    List<Map<String, String>> mappedData,
    List<ValidationError> warnings,
    List<ValidationError> infos,
  ) async {
    final phoneCounts = <String, List<int>>{};

    // 📊 NORMALIZAR Y CONTABILIZAR TELÉFONOS
    for (int i = 0; i < mappedData.length; i++) {
      final phone = _normalizePhone(mappedData[i]['telefono'] ?? '');
      if (phone.isNotEmpty) {
        phoneCounts.putIfAbsent(phone, () => []).add(i);
      }
    }

    // 🔍 REPORTAR DUPLICADOS
    for (final entry in phoneCounts.entries) {
      if (entry.value.length > 1) {
        for (final rowIndex in entry.value) {
          infos.add(ValidationError(
            rowIndex: rowIndex,
            columnName: 'telefono',
            originalValue: entry.key,
            level: ValidationLevel.info,
            message: 'Teléfono duplicado en ${entry.value.length} registros',
            suggestedFix: 'Verificar si pertenecen a la misma persona',
          ));
        }
      }
    }
  }

  /// 📱 NORMALIZAR TELÉFONO PARA COMPARACIÓN
  String _normalizePhone(String phone) {
    // Remover todo excepto dígitos y +
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Manejar diferentes formatos internacionales
    if (cleaned.startsWith('+52') && cleaned.length == 13) {
      return cleaned.substring(3); // Remover +52
    } else if (cleaned.startsWith('52') && cleaned.length == 12) {
      return cleaned.substring(2); // Remover 52
    } else if (cleaned.startsWith('+1') && cleaned.length == 12) {
      return cleaned; // Mantener formato US
    } else if (cleaned.startsWith('+57') && cleaned.length >= 12) {
      return cleaned; // Mantener formato CO
    } else if (cleaned.startsWith('+34') && cleaned.length == 12) {
      return cleaned; // Mantener formato ES
    } else if (cleaned.length == 10) {
      return cleaned; // Formato local
    }

    return cleaned;
  }

  // ========================================================================
  // 👥 VALIDACIÓN DE NOMBRES DUPLICADOS
  // ========================================================================

  /// 👥 VALIDAR COMBINACIONES NOMBRE+APELLIDOS DUPLICADAS
  Future<void> _validateDuplicateNames(
    List<Map<String, String>> mappedData,
    List<ValidationError> warnings,
  ) async {
    final nameCounts = <String, List<int>>{};

    // 📊 CONTABILIZAR COMBINACIONES NOMBRE+APELLIDOS
    for (int i = 0; i < mappedData.length; i++) {
      final nombre = mappedData[i]['nombre']?.trim().toLowerCase() ?? '';
      final apellidos = mappedData[i]['apellidos']?.trim().toLowerCase() ?? '';

      if (nombre.isNotEmpty && apellidos.isNotEmpty) {
        final fullName = '$nombre $apellidos';
        nameCounts.putIfAbsent(fullName, () => []).add(i);
      }
    }

    // 🔍 REPORTAR DUPLICADOS COMO WARNING
    for (final entry in nameCounts.entries) {
      if (entry.value.length > 1) {
        for (final rowIndex in entry.value) {
          warnings.add(ValidationError(
            rowIndex: rowIndex,
            columnName: 'nombre',
            originalValue: entry.key,
            level: ValidationLevel.warning,
            message: 'Nombre completo duplicado en ${entry.value.length} filas',
            suggestedFix:
                'Verificar si son personas diferentes o agregar información adicional',
          ));
        }
      }
    }
  }

  // ========================================================================
  // 🏷️ VALIDACIÓN DE CÓDIGOS POSTALES
  // ========================================================================

  /// 🏷️ VALIDAR CONSISTENCIA DE CÓDIGOS POSTALES
  Future<void> _validatePostalCodeConsistency(
    List<Map<String, String>> mappedData,
    List<ValidationError> warnings,
  ) async {
    // 📊 MAPEAR CP A ALCALDÍAS
    final cpAlcaldiaMap = <String, Set<String>>{};

    for (int i = 0; i < mappedData.length; i++) {
      final cp = mappedData[i]['codigoPostal']?.trim() ?? '';
      final alcaldia = mappedData[i]['alcaldia']?.trim() ?? '';

      if (cp.isNotEmpty && alcaldia.isNotEmpty) {
        cpAlcaldiaMap.putIfAbsent(cp, () => {}).add(alcaldia);
      }
    }

    // 🔍 DETECTAR INCONSISTENCIAS
    for (final entry in cpAlcaldiaMap.entries) {
      if (entry.value.length > 1) {
        // Buscar filas con este CP inconsistente
        for (int i = 0; i < mappedData.length; i++) {
          final cp = mappedData[i]['codigoPostal']?.trim() ?? '';
          if (cp == entry.key) {
            warnings.add(ValidationError(
              rowIndex: i,
              columnName: 'codigoPostal',
              originalValue: cp,
              level: ValidationLevel.warning,
              message:
                  'CP $cp aparece con múltiples alcaldías: ${entry.value.join(", ")}',
              suggestedFix:
                  'Verificar la alcaldía correcta para este código postal',
            ));
          }
        }
      }
    }
  }

  // ========================================================================
  // 📊 VALIDACIÓN DE DISTRIBUCIÓN
  // ========================================================================

  /// 📊 VALIDAR DISTRIBUCIÓN DE DATOS
  Future<void> _validateDataDistribution(
    List<Map<String, String>> mappedData,
    List<ValidationError> infos,
  ) async {
    if (mappedData.isEmpty) return;

    // 📊 ANÁLISIS DE COMPLETITUD POR CAMPO
    final fieldCompleteness = <String, double>{};

    for (final field in mappedData.first.keys) {
      final nonEmptyCount = mappedData
          .where((row) => (row[field] ?? '').trim().isNotEmpty)
          .length;

      fieldCompleteness[field] = (nonEmptyCount / mappedData.length) * 100;
    }

    // 🔍 REPORTAR CAMPOS CON BAJA COMPLETITUD (solo info)
    for (final entry in fieldCompleteness.entries) {
      if (entry.value < 30.0 &&
          entry.key != 'numeroInterior' &&
          entry.key != 'referencias') {
        infos.add(ValidationError(
          rowIndex: -1,
          columnName: entry.key,
          originalValue: '',
          level: ValidationLevel.info,
          message:
              'Campo "${entry.key}" tiene solo ${entry.value.toStringAsFixed(1)}% de datos completos',
          suggestedFix:
              'Considerar si este campo es necesario o completar datos faltantes',
        ));
      }
    }

    // 📊 REPORTAR ESTADÍSTICAS GENERALES
    infos.add(ValidationError(
      rowIndex: -1,
      columnName: 'General',
      originalValue: '',
      level: ValidationLevel.info,
      message: 'Se procesaron ${mappedData.length} registros para importación',
    ));
  }

  // ========================================================================
  // 🎯 MÉTODOS DE UTILIDAD PÚBLICA
  // ========================================================================

  /// 🎯 VALIDAR FILA INDIVIDUAL
  Future<List<ValidationError>> validateSingleRow(
    Map<String, String> rowData,
    List<FieldMapping> mappings,
    int rowIndex,
  ) async {
    final errors = <ValidationError>[];

    for (final mapping in mappings) {
      final value = rowData[mapping.targetField] ?? '';
      errors.addAll(_validateField(value, mapping, rowIndex));
    }

    return errors;
  }

  /// 📊 OBTENER ESTADÍSTICAS DE VALIDACIÓN
  Map<String, dynamic> getValidationStatistics(ValidationResult result) {
    if (result.totalRows == 0) return {};

    return {
      'totalRows': result.totalRows,
      'validRows': result.validRows,
      'errorRows': result.errors.map((e) => e.rowIndex).toSet().length,
      'warningRows': result.warnings.map((e) => e.rowIndex).toSet().length,
      'successRate': result.successRate,
      'totalErrors': result.errors.length,
      'totalWarnings': result.warnings.length,
      'totalInfos': result.infos.length,
      'canProceed': result.canProceed,
      'validatedAt': result.validatedAt.toIso8601String(),
    };
  }

  /// 🔍 AGRUPAR ERRORES POR TIPO
  Map<String, List<ValidationError>> groupErrorsByType(
      ValidationResult result) {
    final grouped = <String, List<ValidationError>>{};

    // Agrupar errores
    for (final error in result.errors) {
      final key = '${error.columnName}: ${error.message}';
      grouped.putIfAbsent(key, () => []).add(error);
    }

    // Agrupar advertencias
    for (final warning in result.warnings) {
      final key = '${warning.columnName}: ${warning.message}';
      grouped.putIfAbsent(key, () => []).add(warning);
    }

    return grouped;
  }

  /// 🔍 OBTENER ERRORES MÁS FRECUENTES
  List<MapEntry<String, int>> getMostFrequentErrors(ValidationResult result,
      {int limit = 10}) {
    final errorCounts = <String, int>{};

    for (final error in [...result.errors, ...result.warnings]) {
      final key = error.message;
      errorCounts[key] = (errorCounts[key] ?? 0) + 1;
    }

    final sortedErrors = errorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedErrors.take(limit).toList();
  }

  /// 🧹 LIMPIAR RECURSOS
  void dispose() {
    debugPrint('🧹 DataValidatorService disposed');
  }
}
