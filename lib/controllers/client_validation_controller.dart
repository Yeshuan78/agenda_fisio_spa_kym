// [client_validation_controller.dart] - VALIDACIONES ENTERPRISE EN TIEMPO REAL - ✅ CORREGIDO COMPLETAMENTE
// 📁 Ubicación: /lib/controllers/client_validation_controller.dart
// 🎯 OBJETIVO: Sistema de validaciones dinámicas y robustas para formularios de cliente
// ✅ FIX: Teléfonos internacionales + Dirección opcional + Consistencia total

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/background_cost_monitor.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/cost_data_models.dart';

/// 🛡️ CONTROLADOR DE VALIDACIONES ENTERPRISE
/// Maneja validaciones en tiempo real, unicidad y reglas de negocio
/// ✅ ACTUALIZADO: Soporte internacional + dirección opcional
class ClientValidationController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BackgroundCostMonitor _costMonitor = BackgroundCostMonitor();

  // ✅ ESTADO DE VALIDACIONES
  final Map<String, ValidationResult> _validationResults = {};
  final Map<String, bool> _fieldValidationInProgress = {};

  // ✅ CONFIGURACIÓN
  static const Duration _debounceDelay = Duration(milliseconds: 500);
  final Map<String, Timer?> _debounceTimers = {};

  // ✅ GETTERS PÚBLICOS
  Map<String, ValidationResult> get validationResults =>
      Map.unmodifiable(_validationResults);
  bool get isValidating =>
      _fieldValidationInProgress.values.any((inProgress) => inProgress);
  bool get hasErrors =>
      _validationResults.values.any((result) => !result.isValid);
  bool get isFormValid =>
      _validationResults.isNotEmpty && !hasErrors && !isValidating;

  /// 📧 VALIDAR EMAIL CON UNICIDAD
  Future<void> validateEmail(String email, {String? currentClientId}) async {
    const field = 'email';

    // Limpiar timer anterior
    _debounceTimers[field]?.cancel();

    // Validación inmediata de formato
    final formatResult = _validateEmailFormat(email);
    _setValidationResult(field, formatResult);

    if (!formatResult.isValid || email.trim().isEmpty) {
      return;
    }

    _debounceTimers[field] = Timer(_debounceDelay, () async {
      await _validateEmailUniqueness(email, currentClientId);
    });
  }

  /// 📱 VALIDAR TELÉFONO INTERNACIONAL - ✅ CORREGIDO COMPLETAMENTE
  void validatePhone(String phone) {
    const field = 'phone';

    _debounceTimers[field]?.cancel();
    _debounceTimers[field] = Timer(_debounceDelay, () {
      final result = _validateInternationalPhoneFormat(phone); // ✅ NUEVO MÉTODO
      _setValidationResult(field, result);
    });
  }

  /// 🏠 VALIDAR CÓDIGO POSTAL - ✅ MEJORADO CON FLEXIBILIDAD INTERNACIONAL
  Future<void> validatePostalCode(String postalCode) async {
    const field = 'postalCode';

    _debounceTimers[field]?.cancel();

    // ✅ NUEVO: Validación opcional para CP
    if (postalCode.trim().isEmpty) {
      _removeValidationResult(field); // No es requerido
      return;
    }

    // Validación inmediata de formato
    final formatResult = _validatePostalCodeFormat(postalCode);
    _setValidationResult(field, formatResult);

    if (!formatResult.isValid) {
      return;
    }

    // Debounce para validación con API
    _debounceTimers[field] = Timer(_debounceDelay, () async {
      await _validatePostalCodeWithAPI(postalCode);
    });
  }

  /// 👤 VALIDAR NOMBRE COMPLETO
  void validateFullName(String firstName, String lastName) {
    final nameResult =
        _validateRequiredField(firstName, 'El nombre es requerido');
    final lastNameResult =
        _validateRequiredField(lastName, 'Los apellidos son requeridos');

    _setValidationResult('firstName', nameResult);
    _setValidationResult('lastName', lastNameResult);

    // Validación adicional: longitud mínima
    if (nameResult.isValid && firstName.trim().length < 2) {
      _setValidationResult(
          'firstName',
          const ValidationResult(
            isValid: false,
            errorMessage: 'El nombre debe tener al menos 2 caracteres',
            warningMessage: null,
          ));
    }

    if (lastNameResult.isValid && lastName.trim().length < 2) {
      _setValidationResult(
          'lastName',
          const ValidationResult(
            isValid: false,
            errorMessage: 'Los apellidos deben tener al menos 2 caracteres',
            warningMessage: null,
          ));
    }
  }

  /// 🏢 VALIDAR EMPRESA (OPCIONAL)
  void validateCompany(String company) {
    if (company.trim().isEmpty) {
      _removeValidationResult('company');
      return;
    }

    if (company.trim().length < 2) {
      _setValidationResult(
          'company',
          const ValidationResult(
            isValid: false,
            errorMessage:
                'El nombre de la empresa debe tener al menos 2 caracteres',
            warningMessage: null,
          ));
    } else {
      _setValidationResult(
          'company',
          const ValidationResult(
            isValid: true,
            errorMessage: null,
            warningMessage: null,
          ));
    }
  }

  /// 🗺️ VALIDAR DIRECCIÓN COMPLETA - ✅ AHORA COMPLETAMENTE OPCIONAL
  void validateAddress({
    required String street,
    required String exteriorNumber,
    String? interiorNumber,
    required String neighborhood,
    required String postalCode,
    required String municipality,
  }) {
    // ✅ NUEVO: Detectar si hay datos de dirección
    final hasAddressData = street.trim().isNotEmpty ||
        exteriorNumber.trim().isNotEmpty ||
        neighborhood.trim().isNotEmpty ||
        postalCode.trim().isNotEmpty ||
        municipality.trim().isNotEmpty;

    // ✅ SI NO HAY DATOS DE DIRECCIÓN, LIMPIAR VALIDACIONES
    if (!hasAddressData) {
      _removeValidationResult('street');
      _removeValidationResult('exteriorNumber');
      _removeValidationResult('neighborhood');
      _removeValidationResult('postalCode');
      _removeValidationResult('municipality');
      _removeValidationResult('interiorNumber');
      return;
    }

    // ✅ SI HAY DATOS PARCIALES, VALIDAR CONSISTENCIA
    if (hasAddressData) {
      // Solo validar campos como requeridos si el usuario empezó a llenar la dirección
      _setValidationResult(
          'street',
          _validateOptionalRequiredField(
              street, 'Si proporciona dirección, la calle es requerida'));

      _setValidationResult(
          'exteriorNumber',
          _validateOptionalRequiredField(exteriorNumber,
              'Si proporciona dirección, el número exterior es requerido'));

      _setValidationResult(
          'neighborhood',
          _validateOptionalRequiredField(neighborhood,
              'Si proporciona dirección, la colonia es requerida'));

      // Alcaldía y CP siguen siendo opcionales incluso con dirección parcial
      if (municipality.trim().isNotEmpty && municipality.trim().length < 2) {
        _setValidationResult(
            'municipality',
            const ValidationResult(
              isValid: false,
              errorMessage: 'La alcaldía debe tener al menos 2 caracteres',
              warningMessage: null,
            ));
      } else {
        _removeValidationResult('municipality');
      }
    }

    // Validar formato de números si están presentes
    if (exteriorNumber.trim().isNotEmpty &&
        !RegExp(r'^[0-9A-Za-z\-\s]+$').hasMatch(exteriorNumber)) {
      _setValidationResult(
          'exteriorNumber',
          const ValidationResult(
            isValid: false,
            errorMessage: 'Formato de número exterior inválido',
            warningMessage: null,
          ));
    }

    if (interiorNumber != null &&
        interiorNumber.trim().isNotEmpty &&
        !RegExp(r'^[0-9A-Za-z\-\s]+$').hasMatch(interiorNumber)) {
      _setValidationResult(
          'interiorNumber',
          const ValidationResult(
            isValid: false,
            errorMessage: 'Formato de número interior inválido',
            warningMessage: null,
          ));
    } else if (interiorNumber != null && interiorNumber.trim().isEmpty) {
      _removeValidationResult('interiorNumber');
    }
  }

  /// 🏷️ VALIDAR ETIQUETAS
  void validateTags(List<ClientTag> tags) {
    if (tags.isEmpty) {
      _setValidationResult(
          'tags',
          const ValidationResult(
            isValid: true,
            errorMessage: null,
            warningMessage: 'Se recomienda agregar al menos una etiqueta',
          ));
      return;
    }

    // Validar longitud de etiquetas personalizadas
    for (final tag in tags.where((t) => t.type == TagType.custom)) {
      if (tag.label.length > 20) {
        _setValidationResult(
            'tags',
            const ValidationResult(
              isValid: false,
              errorMessage: 'Las etiquetas no pueden exceder 20 caracteres',
              warningMessage: null,
            ));
        return;
      }
    }

    // Validar número máximo de etiquetas
    if (tags.length > 10) {
      _setValidationResult(
          'tags',
          const ValidationResult(
            isValid: false,
            errorMessage: 'Máximo 10 etiquetas por cliente',
            warningMessage: null,
          ));
      return;
    }

    _setValidationResult(
        'tags',
        const ValidationResult(
          isValid: true,
          errorMessage: null,
          warningMessage: null,
        ));
  }

  /// 🔍 VALIDAR FORMULARIO COMPLETO - ✅ ACTUALIZADO PARA DIRECCIÓN OPCIONAL
  bool validateCompleteForm({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? company,
    required String street,
    required String exteriorNumber,
    String? interiorNumber,
    required String neighborhood,
    required String postalCode,
    required String municipality,
    required List<ClientTag> tags,
    String? currentClientId,
  }) {
    // Ejecutar todas las validaciones
    validateFullName(firstName, lastName);
    validatePhone(phone); // ✅ Ahora usa validación internacional
    validateCompany(company ?? '');
    validateAddress(
      // ✅ Ahora es completamente opcional
      street: street,
      exteriorNumber: exteriorNumber,
      interiorNumber: interiorNumber,
      neighborhood: neighborhood,
      postalCode: postalCode,
      municipality: municipality,
    );
    validateTags(tags);

    // Las validaciones asíncronas (email, CP) deben haberse ejecutado previamente
    return isFormValid && !isValidating;
  }

  /// 🧹 LIMPIAR VALIDACIONES
  void clearValidations() {
    _validationResults.clear();
    _fieldValidationInProgress.clear();

    // Cancelar timers
    for (final timer in _debounceTimers.values) {
      timer?.cancel();
    }
    _debounceTimers.clear();

    notifyListeners();
  }

  /// 🔧 LIMPIAR VALIDACIÓN ESPECÍFICA
  void clearFieldValidation(String field) {
    _validationResults.remove(field);
    _fieldValidationInProgress.remove(field);
    _debounceTimers[field]?.cancel();
    _debounceTimers.remove(field);
    notifyListeners();
  }

  // ========================================================================
  // 🔒 MÉTODOS PRIVADOS DE VALIDACIÓN - ✅ ACTUALIZADOS
  // ========================================================================

  ValidationResult _validateRequiredField(String value, String errorMessage) {
    if (value.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: errorMessage,
        warningMessage: null,
      );
    }

    return const ValidationResult(
      isValid: true,
      errorMessage: null,
      warningMessage: null,
    );
  }

  /// ✅ NUEVO: Validación para campos que solo son requeridos si hay dirección parcial
  ValidationResult _validateOptionalRequiredField(
      String value, String errorMessage) {
    if (value.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: errorMessage,
        warningMessage: null,
      );
    }

    return const ValidationResult(
      isValid: true,
      errorMessage: null,
      warningMessage: null,
    );
  }

  ValidationResult _validateEmailFormat(String email) {
    if (email.trim().isEmpty) {
      return const ValidationResult(
        isValid: false,
        errorMessage: 'El correo electrónico es requerido',
        warningMessage: null,
      );
    }

    // Patrón de email robusto
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(email.trim())) {
      return const ValidationResult(
        isValid: false,
        errorMessage: 'Formato de correo electrónico inválido',
        warningMessage: null,
      );
    }

    return const ValidationResult(
      isValid: true,
      errorMessage: null,
      warningMessage: null,
    );
  }

  Future<void> _validateEmailUniqueness(
      String email, String? currentClientId) async {
    const field = 'email';

    try {
      if (_costMonitor.currentStats.dailyReadCount >=
          CostControlConfig.dailyReadLimit) {
        _setValidationResult(
            field,
            const ValidationResult(
              isValid: true,
              errorMessage: null,
              warningMessage:
                  'No se pudo verificar unicidad (límite de costos)',
            ));
        return;
      }

      _setFieldValidationInProgress(field, true);

      final query = await _firestore
          .collection('clients')
          .where('correo', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      _costMonitor.incrementReadCount(1, description: 'Email validation');

      // Si hay resultados y no es el cliente actual
      if (query.docs.isNotEmpty) {
        final existingClientId = query.docs.first.id;
        if (currentClientId == null || existingClientId != currentClientId) {
          _setValidationResult(
              field,
              const ValidationResult(
                isValid: false,
                errorMessage: 'Este correo ya está registrado por otro cliente',
                warningMessage: null,
              ));
          return;
        }
      }

      _setValidationResult(
          field,
          const ValidationResult(
            isValid: true,
            errorMessage: null,
            warningMessage: null,
          ));
    } catch (e) {
      debugPrint('❌ Error validando unicidad de email: $e');
      _setValidationResult(
          field,
          const ValidationResult(
            isValid: true,
            errorMessage: null,
            warningMessage: 'No se pudo verificar unicidad del correo',
          ));
    } finally {
      _setFieldValidationInProgress(field, false);
    }
  }

  /// ✅ NUEVO MÉTODO: Validación internacional de teléfonos
  ValidationResult _validateInternationalPhoneFormat(String phone) {
    if (phone.trim().isEmpty) {
      return const ValidationResult(
        isValid: false,
        errorMessage: 'El teléfono es requerido',
        warningMessage: null,
      );
    }

    // Limpiar teléfono manteniendo + y dígitos
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Validaciones básicas
    if (cleaned.isEmpty) {
      return const ValidationResult(
        isValid: false,
        errorMessage: 'Número de teléfono inválido',
        warningMessage: null,
      );
    }

    if (cleaned.length < 7) {
      return const ValidationResult(
        isValid: false,
        errorMessage: 'El teléfono debe tener al menos 7 dígitos',
        warningMessage: null,
      );
    }

    if (cleaned.length > 20) {
      return const ValidationResult(
        isValid: false,
        errorMessage: 'El teléfono no puede exceder 20 caracteres',
        warningMessage: null,
      );
    }

    // ✅ NÚMEROS MEXICANOS TRADICIONALES (10 dígitos sin +)
    if (cleaned.length == 10 && !cleaned.startsWith('+')) {
      // Validar que no todos sean el mismo dígito
      if (RegExp(r'^(\d)\1{9}$').hasMatch(cleaned)) {
        return const ValidationResult(
          isValid: false,
          errorMessage: 'Número de teléfono inválido',
          warningMessage: null,
        );
      }
      return const ValidationResult(
        isValid: true,
        errorMessage: null,
        warningMessage: null,
      );
    }

    // ✅ NÚMEROS INTERNACIONALES (con +)
    if (cleaned.startsWith('+') &&
        cleaned.length >= 10 &&
        cleaned.length <= 16) {
      return const ValidationResult(
        isValid: true,
        errorMessage: null,
        warningMessage: null,
      );
    }

    // ✅ OTROS FORMATOS VÁLIDOS (7-15 dígitos sin +)
    if (cleaned.length >= 7 && cleaned.length <= 15) {
      return const ValidationResult(
        isValid: true,
        errorMessage: null,
        warningMessage: null,
      );
    }

    return const ValidationResult(
      isValid: false,
      errorMessage:
          'Formato de teléfono inválido. Use formato internacional (+52 55 1234 5678) o nacional (5512345678)',
      warningMessage: null,
    );
  }

  /// ✅ MÉTODO OBSOLETO REMOVIDO - _validatePhoneFormat()
  /// Reemplazado por _validateInternationalPhoneFormat()

  ValidationResult _validatePostalCodeFormat(String postalCode) {
    if (postalCode.trim().isEmpty) {
      return const ValidationResult(
        isValid: true, // ✅ CAMBIADO: Ahora es opcional
        errorMessage: null,
        warningMessage: null,
      );
    }

    // ✅ MEJORADO: Soporte para códigos postales internacionales
    final cleaned = postalCode.trim().replaceAll(RegExp(r'[^\d\w]'), '');

    // Códigos postales mexicanos (5 dígitos)
    if (RegExp(r'^\d{5}$').hasMatch(cleaned)) {
      return const ValidationResult(
        isValid: true,
        errorMessage: null,
        warningMessage: null,
      );
    }

    // Códigos postales internacionales (3-10 caracteres alfanuméricos)
    if (cleaned.length >= 3 && cleaned.length <= 10) {
      return const ValidationResult(
        isValid: true,
        errorMessage: null,
        warningMessage: 'Formato de código postal internacional detectado',
      );
    }

    return const ValidationResult(
      isValid: false,
      errorMessage:
          'Formato de código postal inválido (ejemplo: 06700 o M5V3L9)',
      warningMessage: null,
    );
  }

  Future<void> _validatePostalCodeWithAPI(String postalCode) async {
    const field = 'postalCode';

    try {
      _setFieldValidationInProgress(field, true);

      // ✅ MEJORADO: Validación más flexible para códigos internacionales
      final cleaned = postalCode.trim().replaceAll(RegExp(r'[^\d\w]'), '');

      // Si es formato mexicano, validar rangos
      if (RegExp(r'^\d{5}$').hasMatch(cleaned)) {
        final code = int.tryParse(cleaned);
        if (code == null || code < 1000 || code > 99999) {
          _setValidationResult(
              field,
              const ValidationResult(
                isValid: false,
                errorMessage: 'Código postal mexicano fuera del rango válido',
                warningMessage: null,
              ));
          return;
        }
      }

      // Simulación de validación exitosa
      await Future.delayed(const Duration(milliseconds: 300));

      _setValidationResult(
          field,
          const ValidationResult(
            isValid: true,
            errorMessage: null,
            warningMessage: null,
          ));
    } catch (e) {
      debugPrint('❌ Error validando código postal: $e');
      _setValidationResult(
          field,
          const ValidationResult(
            isValid: true,
            errorMessage: null,
            warningMessage: 'No se pudo verificar el código postal',
          ));
    } finally {
      _setFieldValidationInProgress(field, false);
    }
  }

  // ========================================================================
  // 🔧 MÉTODOS HELPER
  // ========================================================================

  void _setValidationResult(String field, ValidationResult result) {
    _validationResults[field] = result;
    notifyListeners();
  }

  void _removeValidationResult(String field) {
    _validationResults.remove(field);
    notifyListeners();
  }

  void _setFieldValidationInProgress(String field, bool inProgress) {
    if (inProgress) {
      _fieldValidationInProgress[field] = true;
    } else {
      _fieldValidationInProgress.remove(field);
    }
    notifyListeners();
  }

  /// 📊 OBTENER RESULTADO DE VALIDACIÓN ESPECÍFICO
  ValidationResult? getValidationResult(String field) {
    return _validationResults[field];
  }

  /// 🔍 VERIFICAR SI CAMPO ESTÁ SIENDO VALIDADO
  bool isFieldValidating(String field) {
    return _fieldValidationInProgress[field] ?? false;
  }

  /// 📋 OBTENER RESUMEN DE VALIDACIÓN
  ValidationSummary getValidationSummary() {
    final totalFields = _validationResults.length;
    final validFields =
        _validationResults.values.where((r) => r.isValid).length;
    final fieldsWithErrors =
        _validationResults.values.where((r) => !r.isValid).length;
    final fieldsWithWarnings =
        _validationResults.values.where((r) => r.warningMessage != null).length;

    return ValidationSummary(
      totalFields: totalFields,
      validFields: validFields,
      fieldsWithErrors: fieldsWithErrors,
      fieldsWithWarnings: fieldsWithWarnings,
      isFormValid: isFormValid,
      isValidating: isValidating,
    );
  }

  @override
  void dispose() {
    // Cancelar todos los timers
    for (final timer in _debounceTimers.values) {
      timer?.cancel();
    }
    _debounceTimers.clear();

    super.dispose();
  }
}

// ========================================================================
// 📊 MODELOS DE DATOS
// ========================================================================

/// 🎯 RESULTADO DE VALIDACIÓN
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? warningMessage;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warningMessage,
  });

  bool get hasError => errorMessage != null;
  bool get hasWarning => warningMessage != null;

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, error: $errorMessage, warning: $warningMessage)';
  }
}

/// 📈 RESUMEN DE VALIDACIÓN
class ValidationSummary {
  final int totalFields;
  final int validFields;
  final int fieldsWithErrors;
  final int fieldsWithWarnings;
  final bool isFormValid;
  final bool isValidating;

  const ValidationSummary({
    required this.totalFields,
    required this.validFields,
    required this.fieldsWithErrors,
    required this.fieldsWithWarnings,
    required this.isFormValid,
    required this.isValidating,
  });

  double get validationProgress {
    if (totalFields == 0) return 0.0;
    return validFields / totalFields;
  }

  @override
  String toString() {
    return 'ValidationSummary(total: $totalFields, valid: $validFields, errors: $fieldsWithErrors, warnings: $fieldsWithWarnings)';
  }
}
