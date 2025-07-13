// [import_models.dart] - VERSIÓN SEGURA CON CAMBIOS MÍNIMOS
// ✅ SOLO SE CAMBIÓ: requiredFields para incluir apellidos, nuevos validadores
// ✅ TODO LO DEMÁS: Exactamente igual a tu versión original

import 'dart:typed_data';
import 'package:flutter/foundation.dart';

// ========================================================================
// 📊 ENUMS PRINCIPALES - SIN CAMBIOS
// ========================================================================

enum ImportFormat {
  csv('CSV', 'text/csv', ['.csv']),
  excel(
      'Excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ['.xlsx', '.xls']);

  const ImportFormat(this.displayName, this.mimeType, this.extensions);
  final String displayName;
  final String mimeType;
  final List<String> extensions;
}

enum ImportStatus {
  idle('Inactivo', 'Esperando archivo'),
  analyzing('Analizando', 'Procesando archivo'),
  mapping('Mapeando', 'Configurando campos'),
  validating('Validando', 'Verificando datos'),
  importing('Importando', 'Guardando en base de datos'),
  completed('Completado', 'Importación finalizada'),
  failed('Fallido', 'Error en importación'),
  cancelled('Cancelado', 'Proceso cancelado');

  const ImportStatus(this.displayName, this.description);
  final String displayName;
  final String description;
}

enum ValidationLevel {
  error('Error', 'Impide la importación'),
  warning('Advertencia', 'Puede continuar'),
  info('Información', 'Solo informativo');

  const ValidationLevel(this.displayName, this.description);
  final String displayName;
  final String description;
}

enum DuplicateStrategy {
  skip('Omitir', 'No importar duplicados'),
  update('Actualizar', 'Sobrescribir datos existentes'),
  createNew('Crear Nuevo', 'Crear registro adicional');

  const DuplicateStrategy(this.displayName, this.description);
  final String displayName;
  final String description;
}

enum CsvDelimiter {
  comma(',', 'Coma'),
  semicolon(';', 'Punto y coma'),
  tab('\t', 'Tabulación'),
  pipe('|', 'Barra vertical');

  const CsvDelimiter(this.value, this.displayName);
  final String value;
  final String displayName;
}

// ========================================================================
// ⚙️ CLASES SIN CAMBIOS
// ========================================================================

class ImportOptions {
  final ImportFormat format;
  final bool hasHeaders;
  final CsvDelimiter delimiter;
  final String encoding;
  final bool skipEmptyRows;
  final bool trimWhitespace;
  final int maxRecords;
  final int previewRows;
  final DuplicateStrategy duplicateStrategy;

  const ImportOptions({
    required this.format,
    this.hasHeaders = true,
    this.delimiter = CsvDelimiter.comma,
    this.encoding = 'utf-8',
    this.skipEmptyRows = true,
    this.trimWhitespace = true,
    this.maxRecords = 10000,
    this.previewRows = 10,
    this.duplicateStrategy = DuplicateStrategy.skip,
  });

  factory ImportOptions.defaultCsv() {
    return const ImportOptions(
      format: ImportFormat.csv,
      hasHeaders: true,
      delimiter: CsvDelimiter.comma,
      encoding: 'utf-8',
      skipEmptyRows: true,
      trimWhitespace: true,
      maxRecords: 10000,
      previewRows: 10,
      duplicateStrategy: DuplicateStrategy.skip,
    );
  }

  factory ImportOptions.defaultExcel() {
    return const ImportOptions(
      format: ImportFormat.excel,
      hasHeaders: true,
      skipEmptyRows: true,
      trimWhitespace: true,
      maxRecords: 10000,
      previewRows: 10,
      duplicateStrategy: DuplicateStrategy.skip,
    );
  }

  ImportOptions copyWith({
    ImportFormat? format,
    bool? hasHeaders,
    CsvDelimiter? delimiter,
    String? encoding,
    bool? skipEmptyRows,
    bool? trimWhitespace,
    int? maxRecords,
    int? previewRows,
    DuplicateStrategy? duplicateStrategy,
  }) {
    return ImportOptions(
      format: format ?? this.format,
      hasHeaders: hasHeaders ?? this.hasHeaders,
      delimiter: delimiter ?? this.delimiter,
      encoding: encoding ?? this.encoding,
      skipEmptyRows: skipEmptyRows ?? this.skipEmptyRows,
      trimWhitespace: trimWhitespace ?? this.trimWhitespace,
      maxRecords: maxRecords ?? this.maxRecords,
      previewRows: previewRows ?? this.previewRows,
      duplicateStrategy: duplicateStrategy ?? this.duplicateStrategy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'format': format.name,
      'hasHeaders': hasHeaders,
      'delimiter': delimiter.value,
      'encoding': encoding,
      'skipEmptyRows': skipEmptyRows,
      'trimWhitespace': trimWhitespace,
      'maxRecords': maxRecords,
      'previewRows': previewRows,
      'duplicateStrategy': duplicateStrategy.name,
    };
  }
}

class ImportFileInfo {
  final String name;
  final int sizeBytes;
  final ImportFormat format;
  final Uint8List bytes;
  final DateTime selectedAt;
  final String? detectedEncoding;
  final CsvDelimiter? detectedDelimiter;

  const ImportFileInfo({
    required this.name,
    required this.sizeBytes,
    required this.format,
    required this.bytes,
    required this.selectedAt,
    this.detectedEncoding,
    this.detectedDelimiter,
  });

  String get sizeFormatted {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    }
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isValidSize => sizeBytes <= ImportLimits.maxFileSizeBytes;

  String get extension => name.split('.').last.toLowerCase();

  ImportFileInfo copyWith({
    String? name,
    int? sizeBytes,
    ImportFormat? format,
    Uint8List? bytes,
    DateTime? selectedAt,
    String? detectedEncoding,
    CsvDelimiter? detectedDelimiter,
  }) {
    return ImportFileInfo(
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      format: format ?? this.format,
      bytes: bytes ?? this.bytes,
      selectedAt: selectedAt ?? this.selectedAt,
      detectedEncoding: detectedEncoding ?? this.detectedEncoding,
      detectedDelimiter: detectedDelimiter ?? this.detectedDelimiter,
    );
  }
}

class FieldMapping {
  final String sourceColumn;
  final String targetField;
  final bool isRequired;
  final bool isAutoMapped;
  final List<FieldValidator> validators;
  final String? displayName;

  const FieldMapping({
    required this.sourceColumn,
    required this.targetField,
    required this.isRequired,
    this.isAutoMapped = false,
    this.validators = const [],
    this.displayName,
  });

  String get effectiveDisplayName => displayName ?? targetField;

  FieldMapping copyWith({
    String? sourceColumn,
    String? targetField,
    bool? isRequired,
    bool? isAutoMapped,
    List<FieldValidator>? validators,
    String? displayName,
  }) {
    return FieldMapping(
      sourceColumn: sourceColumn ?? this.sourceColumn,
      targetField: targetField ?? this.targetField,
      isRequired: isRequired ?? this.isRequired,
      isAutoMapped: isAutoMapped ?? this.isAutoMapped,
      validators: validators ?? this.validators,
      displayName: displayName ?? this.displayName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sourceColumn': sourceColumn,
      'targetField': targetField,
      'isRequired': isRequired,
      'isAutoMapped': isAutoMapped,
      'displayName': displayName,
    };
  }
}

class MappingConfiguration {
  final List<FieldMapping> mappings;
  final List<String> unmappedColumns;
  final List<String> missingRequiredFields;
  final int totalColumns;
  final double autoMappingAccuracy;

  const MappingConfiguration({
    required this.mappings,
    required this.unmappedColumns,
    required this.missingRequiredFields,
    required this.totalColumns,
    required this.autoMappingAccuracy,
  });

  bool get isComplete => missingRequiredFields.isEmpty;
  int get mappedColumns => mappings.length;
  int get autoMappedColumns => mappings.where((m) => m.isAutoMapped).length;

  double get completionPercentage {
    if (totalColumns == 0) return 0.0;
    return (mappedColumns / totalColumns) * 100;
  }

  String get statusMessage {
    if (isComplete) {
      return 'Mapeo completo - Listo para importar';
    } else if (missingRequiredFields.length == 1) {
      return 'Falta mapear 1 campo requerido';
    } else {
      return 'Faltan mapear ${missingRequiredFields.length} campos requeridos';
    }
  }

  MappingConfiguration copyWith({
    List<FieldMapping>? mappings,
    List<String>? unmappedColumns,
    List<String>? missingRequiredFields,
    int? totalColumns,
    double? autoMappingAccuracy,
  }) {
    return MappingConfiguration(
      mappings: mappings ?? this.mappings,
      unmappedColumns: unmappedColumns ?? this.unmappedColumns,
      missingRequiredFields:
          missingRequiredFields ?? this.missingRequiredFields,
      totalColumns: totalColumns ?? this.totalColumns,
      autoMappingAccuracy: autoMappingAccuracy ?? this.autoMappingAccuracy,
    );
  }
}

// Todas las demás clases permanecen exactamente igual...
class ValidationError {
  final int rowIndex;
  final String columnName;
  final String originalValue;
  final ValidationLevel level;
  final String message;
  final String? suggestedFix;

  const ValidationError({
    required this.rowIndex,
    required this.columnName,
    required this.originalValue,
    required this.level,
    required this.message,
    this.suggestedFix,
  });

  String get displayRowNumber => '${rowIndex + 1}';

  Map<String, dynamic> toMap() {
    return {
      'rowIndex': rowIndex,
      'columnName': columnName,
      'originalValue': originalValue,
      'level': level.name,
      'message': message,
      'suggestedFix': suggestedFix,
    };
  }
}

class ValidationResult {
  final List<ValidationError> errors;
  final List<ValidationError> warnings;
  final List<ValidationError> infos;
  final int totalRows;
  final int validRows;
  final DateTime validatedAt;

  const ValidationResult({
    required this.errors,
    required this.warnings,
    required this.infos,
    required this.totalRows,
    required this.validRows,
    required this.validatedAt,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get canProceed => !hasErrors;

  int get errorRows => errors.map((e) => e.rowIndex).toSet().length;
  int get warningRows => warnings.map((e) => e.rowIndex).toSet().length;

  double get successRate {
    if (totalRows == 0) return 0.0;
    return (validRows / totalRows) * 100;
  }

  String get summaryMessage {
    if (!hasErrors && !hasWarnings) {
      return 'Todos los datos son válidos';
    } else if (hasErrors) {
      return '$errorRows filas con errores críticos';
    } else {
      return '$warningRows filas con advertencias';
    }
  }

  ValidationResult copyWith({
    List<ValidationError>? errors,
    List<ValidationError>? warnings,
    List<ValidationError>? infos,
    int? totalRows,
    int? validRows,
    DateTime? validatedAt,
  }) {
    return ValidationResult(
      errors: errors ?? this.errors,
      warnings: warnings ?? this.warnings,
      infos: infos ?? this.infos,
      totalRows: totalRows ?? this.totalRows,
      validRows: validRows ?? this.validRows,
      validatedAt: validatedAt ?? this.validatedAt,
    );
  }
}

// ========================================================================
// ✅ SOLO ESTOS VALIDADORES SON NUEVOS - EL RESTO SIN CAMBIOS
// ========================================================================

abstract class FieldValidator {
  bool validate(String value);
  String get errorMessage;
  String? get suggestedFix => null;
}

class FlexibleEmailValidator extends FieldValidator {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  bool validate(String value) {
    if (value.trim().isEmpty) return true;
    return _emailRegex.hasMatch(value.trim().toLowerCase());
  }

  @override
  String get errorMessage => 'Formato de email inválido';

  @override
  String get suggestedFix => 'Verificar formato: usuario@dominio.com';
}

class InternationalPhoneValidator extends FieldValidator {
  @override
  bool validate(String value) {
    if (value.trim().isEmpty) return true; // ✅ OPCIONAL

    try {
      final phoneInfo = _parseAndValidatePhone(value);
      return phoneInfo['isValid'] as bool;
    } catch (e) {
      return false;
    }
  }

  @override
  String get errorMessage => 'Formato de teléfono inválido';

  @override
  String get suggestedFix =>
      'Formatos válidos: +52 55 1234 5678, +1 555 123 4567, 5512345678';

  /// 🔧 PARSEAR Y VALIDAR TELÉFONO (NIVEL PROFESIONAL)
  static Map<String, dynamic> _parseAndValidatePhone(String input) {
    // 1️⃣ LIMPIAR INPUT
    String cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');

    // 2️⃣ MANEJAR PREFIJOS MEXICANOS
    if (cleaned.startsWith('044') || cleaned.startsWith('045')) {
      cleaned = cleaned.substring(3);
    }

    // 3️⃣ VALIDAR LONGITUD BÁSICA
    if (cleaned.length < 7 || cleaned.length > 20) {
      return {
        'isValid': false,
        'normalized': cleaned,
        'error': 'Invalid length'
      };
    }

    String normalized;
    String? countryCode;
    String? countryName;
    String localNumber;
    bool isValid = true;

    // 4️⃣ PROCESAR SEGÚN FORMATO
    if (cleaned.startsWith('+')) {
      // FORMATO INTERNACIONAL: +52, +34, +1, etc.
      final result = _processInternationalPhone(cleaned);
      normalized = result['normalized'];
      countryCode = result['countryCode'];
      countryName = result['countryName'];
      localNumber = result['localNumber'];
      isValid = result['isValid'];
    } else if (cleaned.length >= 10) {
      // FORMATO NACIONAL - ASUMIR MÉXICO
      countryCode = '+52';
      countryName = 'México';
      localNumber = cleaned;
      normalized = '+52$cleaned';
      isValid = cleaned.length == 10; // México: exactamente 10 dígitos
    } else {
      // NÚMERO CORTO
      localNumber = cleaned;
      normalized = cleaned;
      isValid = cleaned.length >= 7; // Mínimo 7 dígitos
    }

    return {
      'isValid': isValid,
      'normalized': normalized,
      'originalValue': input,
      'countryCode': countryCode,
      'countryName': countryName,
      'localNumber': localNumber,
    };
  }

  /// 🌍 PROCESAR TELÉFONO INTERNACIONAL
  static Map<String, dynamic> _processInternationalPhone(String phoneWithPlus) {
    // CÓDIGOS DE PAÍS PRINCIPALES
    const countryCodes = {
      '+1': {'name': 'Estados Unidos/Canadá', 'length': 10},
      '+52': {'name': 'México', 'length': 10},
      '+34': {'name': 'España', 'length': 9},
      '+33': {'name': 'Francia', 'length': 9},
      '+49': {'name': 'Alemania', 'length': 11},
      '+44': {'name': 'Reino Unido', 'length': 10},
      '+39': {'name': 'Italia', 'length': 10},
      '+55': {'name': 'Brasil', 'length': 11},
      '+54': {'name': 'Argentina', 'length': 10},
      '+56': {'name': 'Chile', 'length': 9},
      '+57': {'name': 'Colombia', 'length': 10},
      '+51': {'name': 'Perú', 'length': 9},
    };

    // BUSCAR CÓDIGO CONOCIDO
    for (final entry in countryCodes.entries) {
      final code = entry.key;
      final info = entry.value;

      if (phoneWithPlus.startsWith(code)) {
        final localNumber = phoneWithPlus.substring(code.length);
        final expectedLength = info['length'] as int;

        return {
          'normalized': phoneWithPlus,
          'countryCode': code,
          'countryName': info['name'],
          'localNumber': localNumber,
          'isValid': localNumber.length == expectedLength,
        };
      }
    }

    // CÓDIGO NO CONOCIDO - VALIDACIÓN GENÉRICA
    final match = RegExp(r'^\+(\d{1,4})(\d{7,15})$').firstMatch(phoneWithPlus);
    if (match != null) {
      return {
        'normalized': phoneWithPlus,
        'countryCode': '+${match.group(1)}',
        'countryName': 'Internacional',
        'localNumber': match.group(2),
        'isValid': true,
      };
    }

    return {
      'normalized': phoneWithPlus,
      'countryCode': null,
      'countryName': null,
      'localNumber': phoneWithPlus.substring(1),
      'isValid': false,
    };
  }

  /// 📱 NORMALIZAR TELÉFONO PARA STORAGE (MÉTODO PÚBLICO)
  static String normalizeForStorage(String input) {
    final result = _parseAndValidatePhone(input);
    return result['normalized'] as String;
  }

  /// 🎨 FORMATEAR PARA DISPLAY (MÉTODO PÚBLICO)
  static String formatForDisplay(String input) {
    final result = _parseAndValidatePhone(input);
    final normalized = result['normalized'] as String;

    if (!result['isValid'] || normalized.isEmpty) {
      return input; // Devolver original si no es válido
    }

    // FORMATEAR SEGÚN PAÍS
    if (normalized.startsWith('+52') && normalized.length == 13) {
      // México: +52 55 1234 5678
      final local = normalized.substring(3);
      return '+52 ${local.substring(0, 2)} ${local.substring(2, 6)} ${local.substring(6)}';
    } else if (normalized.startsWith('+1') && normalized.length == 12) {
      // US/CA: +1 (555) 123-4567
      final local = normalized.substring(2);
      return '+1 (${local.substring(0, 3)}) ${local.substring(3, 6)}-${local.substring(6)}';
    } else if (normalized.startsWith('+34') && normalized.length == 12) {
      // España: +34 91 234 56 78
      final local = normalized.substring(3);
      return '+34 ${local.substring(0, 2)} ${local.substring(2, 5)} ${local.substring(5)}';
    }

    // FORMATO GENÉRICO INTERNACIONAL
    final match = RegExp(r'^\+(\d{1,4})(\d+)$').firstMatch(normalized);
    if (match != null) {
      return '+${match.group(1)} ${match.group(2)}';
    }

    return normalized;
  }

  /// 🌍 DETECTAR PAÍS (MÉTODO PÚBLICO)
  static String? detectCountry(String input) {
    final result = _parseAndValidatePhone(input);
    return result['countryName'] as String?;
  }
}

class RequiredValidator extends FieldValidator {
  @override
  bool validate(String value) {
    return value.trim().isNotEmpty;
  }

  @override
  String get errorMessage => 'Este campo es requerido';

  @override
  String get suggestedFix => 'Proporcionar un valor válido';
}

class LengthValidator extends FieldValidator {
  final int? minLength;
  final int? maxLength;

  LengthValidator({this.minLength, this.maxLength});

  @override
  bool validate(String value) {
    final length = value.trim().length;
    if (minLength != null && length < minLength!) return false;
    if (maxLength != null && length > maxLength!) return false;
    return true;
  }

  @override
  String get errorMessage {
    if (minLength != null && maxLength != null) {
      return 'Debe tener entre $minLength y $maxLength caracteres';
    } else if (minLength != null) {
      return 'Debe tener al menos $minLength caracteres';
    } else {
      return 'Debe tener máximo $maxLength caracteres';
    }
  }
}

class FlexiblePostalCodeValidator extends FieldValidator {
  @override
  bool validate(String value) {
    if (value.trim().isEmpty) return true;
    return RegExp(r'^[\d\w\s-]{3,10}$').hasMatch(value.trim());
  }

  @override
  String get errorMessage => 'Formato de código postal inválido';

  @override
  String get suggestedFix => 'Ejemplos: 06700, 10001, M5V 3L9';
}

// ========================================================================
// ✅ SOLO ESTOS CAMBIOS EN TARGETFIELDS
// ========================================================================

class ImportLimits {
  static const int maxFileSizeMb = 50;
  static const int maxFileSizeBytes = maxFileSizeMb * 1024 * 1024;
  static const int maxRecordsPerImport = 10000;
  static const int batchSizeFirestore = 500;
  static const Duration operationTimeout = Duration(minutes: 10);
  static const int previewRowsCount = 10;
  static const int maxValidationErrorsDisplay = 100;
  static const double minAutoMappingConfidence = 0.7;

  static const int MAX_FILE_SIZE_MB = maxFileSizeMb;
  static const int MAX_FILE_SIZE_BYTES = maxFileSizeBytes;
  static const int MAX_RECORDS_PER_IMPORT = maxRecordsPerImport;
  static const int BATCH_SIZE_FIRESTORE = batchSizeFirestore;
  static const int PREVIEW_ROWS_COUNT = previewRowsCount;
  static const int MAX_VALIDATION_ERRORS_DISPLAY = maxValidationErrorsDisplay;
}

class TargetFields {
  // ✅ ÚNICO CAMBIO: nombre + apellidos obligatorios
  static const Map<String, String> requiredFields = {
    'nombre': 'Nombre',
    'apellidos': 'Apellidos',
  };

  // ✅ ÚNICO CAMBIO: email movido aquí
  static const Map<String, String> optionalFields = {
    'email': 'Email',
    'telefono': 'Teléfono',
    'empresa': 'Empresa',
    'calle': 'Calle',
    'numeroExterior': 'Número Exterior',
    'numeroInterior': 'Número Interior',
    'colonia': 'Colonia',
    'codigoPostal': 'Código Postal',
    'alcaldia': 'Alcaldía/Municipio',
    'referencias': 'Referencias',
    'notas': 'Notas',
  };

  static const Map<String, String> allFields = {
    ...requiredFields,
    ...optionalFields,
  };

  static const Map<String, String> REQUIRED_FIELDS = requiredFields;

  static const Map<String, List<String>> fieldPatterns = {
    'nombre': [
      'nombre', 'name', 'first_name', 'primer_nombre', 'nombres',
      'Nombre', 'NOMBRE' // ✅ Tu Excel usa "Nombre"
    ],
    'apellidos': [
      'apellidos', 'apellido', 'last_name', 'surname', 'familia',
      'Apellidos', 'APELLIDOS' // ✅ Tu Excel usa "Apellidos"
    ],
    'email': [
      'email', 'correo', 'mail', 'e-mail', 'correo_electronico',
      'Email', 'EMAIL', 'Email' // ✅ Tu Excel usa "Email"
    ],
    'telefono': [
      'telefono', 'phone', 'tel', 'celular', 'movil', 'whatsapp', 'teléfono',
      'Teléfono', 'TELÉFONO', 'Telefono',
      'TELEFONO' // ✅ Tu Excel usa "Teléfono"
    ],
    'empresa': [
      'empresa',
      'company',
      'organizacion',
      'negocio',
      'corporacion',
      'Empresa',
      'EMPRESA'
    ],
    'calle': [
      'calle', 'street', 'direccion', 'address', 'via',
      'Dirección', 'DIRECCIÓN', 'Direccion',
      'DIRECCION' // ✅ Tu Excel usa "Dirección"
    ],
    'numeroExterior': [
      'numero_exterior', 'num_ext', 'number', 'numero', '#',
      'numero ext', 'Numero ext', 'NUMERO EXT' // ✅ Tu Excel usa "numero ext"
    ],
    'numeroInterior': [
      'numero_interior', 'num_int', 'interior', 'depto', 'apt',
      'numero int', 'Numero int', 'NUMERO INT' // ✅ Tu Excel usa "numero int"
    ],
    'colonia': [
      'colonia', 'neighborhood', 'barrio', 'fraccionamiento',
      'Colonia', 'COLONIA' // ✅ Tu Excel usa "colonia"
    ],
    'codigoPostal': [
      'codigo_postal', 'cp', 'zip', 'postal_code', 'zip_code',
      'codigo postal', 'Codigo postal',
      'CODIGO POSTAL' // ✅ Tu Excel usa "codigo postal"
    ],
    'alcaldia': [
      'alcaldia', 'municipio', 'delegacion', 'city', 'ciudad',
      'Ciudad', 'CIUDAD' // ✅ Tu Excel usa "Ciudad"
    ],
    'referencias': [
      'referencias',
      'reference',
      'observaciones',
      'instrucciones',
      'Referencias',
      'REFERENCIAS'
    ],
    'notas': [
      'notas',
      'notes',
      'comentarios',
      'comments',
      'observaciones',
      'Notas',
      'NOTAS'
    ],
  };

  // ✅ ÚNICO CAMBIO: nuevos validadores
  static List<FieldValidator> getValidators(String field) {
    switch (field) {
      case 'nombre':
        return [
          RequiredValidator(),
          LengthValidator(minLength: 2, maxLength: 50)
        ];
      case 'apellidos':
        return [
          RequiredValidator(),
          LengthValidator(minLength: 2, maxLength: 50)
        ];
      case 'email':
        return [FlexibleEmailValidator()];
      case 'telefono':
        return [InternationalPhoneValidator()];
      case 'codigoPostal':
        return [FlexiblePostalCodeValidator()];
      default:
        return [];
    }
  }
}

// ========================================================================
// TODAS LAS DEMÁS CLASES SIN CAMBIOS (ImportResult, ImportError, etc.)
// ========================================================================

class ImportResult {
  final bool isSuccess;
  final int totalRows;
  final int successfulRows;
  final int errorRows;
  final int skippedRows;
  final List<ImportError> errors;
  final Duration processingTime;
  final DateTime completedAt;
  final Map<String, dynamic>? metadata;

  const ImportResult({
    required this.isSuccess,
    required this.totalRows,
    required this.successfulRows,
    required this.errorRows,
    required this.skippedRows,
    required this.errors,
    required this.processingTime,
    required this.completedAt,
    this.metadata,
  });

  factory ImportResult.success({
    required int totalRows,
    required int successfulRows,
    required Duration processingTime,
    int skippedRows = 0,
    Map<String, dynamic>? metadata,
  }) {
    return ImportResult(
      isSuccess: true,
      totalRows: totalRows,
      successfulRows: successfulRows,
      errorRows: totalRows - successfulRows - skippedRows,
      skippedRows: skippedRows,
      errors: [],
      processingTime: processingTime,
      completedAt: DateTime.now(),
      metadata: metadata,
    );
  }

  factory ImportResult.withErrors({
    required int totalRows,
    required int successfulRows,
    required List<ImportError> errors,
    required Duration processingTime,
    int skippedRows = 0,
    Map<String, dynamic>? metadata,
  }) {
    return ImportResult(
      isSuccess: errors.isEmpty,
      totalRows: totalRows,
      successfulRows: successfulRows,
      errorRows: totalRows - successfulRows - skippedRows,
      skippedRows: skippedRows,
      errors: errors,
      processingTime: processingTime,
      completedAt: DateTime.now(),
      metadata: metadata,
    );
  }

  factory ImportResult.failed({
    required String errorMessage,
    required Duration processingTime,
    Map<String, dynamic>? metadata,
  }) {
    return ImportResult(
      isSuccess: false,
      totalRows: 0,
      successfulRows: 0,
      errorRows: 0,
      skippedRows: 0,
      errors: [ImportError.critical(message: errorMessage)],
      processingTime: processingTime,
      completedAt: DateTime.now(),
      metadata: metadata,
    );
  }

  double get successRate {
    if (totalRows == 0) return 0.0;
    return (successfulRows / totalRows) * 100;
  }

  String get summaryText {
    if (isSuccess && errorRows == 0) {
      return '$successfulRows de $totalRows clientes importados exitosamente';
    } else if (successfulRows > 0) {
      return '$successfulRows exitosos, $errorRows con errores de $totalRows total';
    } else {
      return 'Importación fallida: ${errors.first.message}';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'isSuccess': isSuccess,
      'totalRows': totalRows,
      'successfulRows': successfulRows,
      'errorRows': errorRows,
      'skippedRows': skippedRows,
      'errors': errors.map((e) => e.toMap()).toList(),
      'processingTime': processingTime.inMilliseconds,
      'completedAt': completedAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}

class ImportError {
  final int? rowIndex;
  final String message;
  final String? details;
  final ValidationLevel level;
  final DateTime occurredAt;

  const ImportError({
    this.rowIndex,
    required this.message,
    this.details,
    required this.level,
    required this.occurredAt,
  });

  factory ImportError.critical({
    int? rowIndex,
    required String message,
    String? details,
  }) {
    return ImportError(
      rowIndex: rowIndex,
      message: message,
      details: details,
      level: ValidationLevel.error,
      occurredAt: DateTime.now(),
    );
  }

  factory ImportError.warning({
    int? rowIndex,
    required String message,
    String? details,
  }) {
    return ImportError(
      rowIndex: rowIndex,
      message: message,
      details: details,
      level: ValidationLevel.warning,
      occurredAt: DateTime.now(),
    );
  }

  String get displayRowNumber =>
      rowIndex != null ? '${rowIndex! + 1}' : 'General';

  Map<String, dynamic> toMap() {
    return {
      'rowIndex': rowIndex,
      'message': message,
      'details': details,
      'level': level.name,
      'occurredAt': occurredAt.toIso8601String(),
    };
  }
}

class ImportProgress {
  final ImportStatus status;
  final double percentage;
  final int processedRows;
  final int totalRows;
  final String currentOperation;
  final Duration elapsed;
  final Duration? estimatedRemaining;
  final List<String> recentErrors;

  const ImportProgress({
    required this.status,
    required this.percentage,
    required this.processedRows,
    required this.totalRows,
    required this.currentOperation,
    required this.elapsed,
    this.estimatedRemaining,
    this.recentErrors = const [],
  });

  factory ImportProgress.initial() {
    return const ImportProgress(
      status: ImportStatus.idle,
      percentage: 0.0,
      processedRows: 0,
      totalRows: 0,
      currentOperation: 'Esperando inicio',
      elapsed: Duration.zero,
    );
  }

  bool get isActive =>
      status != ImportStatus.idle &&
      status != ImportStatus.completed &&
      status != ImportStatus.failed &&
      status != ImportStatus.cancelled;

  String get remainingText {
    if (estimatedRemaining == null) return 'Calculando...';
    final minutes = estimatedRemaining!.inMinutes;
    final seconds = estimatedRemaining!.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s restantes';
    } else {
      return '${seconds}s restantes';
    }
  }

  String get progressText => '$processedRows de $totalRows filas procesadas';

  ImportProgress copyWith({
    ImportStatus? status,
    double? percentage,
    int? processedRows,
    int? totalRows,
    String? currentOperation,
    Duration? elapsed,
    Duration? estimatedRemaining,
    List<String>? recentErrors,
  }) {
    return ImportProgress(
      status: status ?? this.status,
      percentage: percentage ?? this.percentage,
      processedRows: processedRows ?? this.processedRows,
      totalRows: totalRows ?? this.totalRows,
      currentOperation: currentOperation ?? this.currentOperation,
      elapsed: elapsed ?? this.elapsed,
      estimatedRemaining: estimatedRemaining ?? this.estimatedRemaining,
      recentErrors: recentErrors ?? this.recentErrors,
    );
  }
}
