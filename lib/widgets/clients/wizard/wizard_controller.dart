// [wizard_controller.dart] - CONTROLADOR PRINCIPAL DEL WIZARD MODAL - ✅ FIX SERVICEMODE SYNC
// 📁 Ubicación: /lib/widgets/clients/wizard/wizard_controller.dart
// 🎯 OBJETIVO: Lógica de navegación, validación SOLO cuando el usuario intenta avanzar + modo híbrido
// ✅ FIX CRÍTICO: Sincronización correcta con ClientFormController

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:agenda_fisio_spa_kym/controllers/client_form_controller.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_form_model.dart';
import 'package:agenda_fisio_spa_kym/services/clients/client_form_service.dart';
import 'package:agenda_fisio_spa_kym/models/company/company_settings_model.dart';
import 'package:agenda_fisio_spa_kym/services/company/company_settings_service.dart';

/// 🧠 CONTROLADOR PRINCIPAL DEL WIZARD MODAL - VALIDACIÓN INTELIGENTE + MODO HÍBRIDO
/// Maneja navegación, validación SOLO cuando necesario y estados de los 3 pasos + servicios
class WizardController extends ChangeNotifier {
  // ✅ CONFIGURACIÓN DEL WIZARD
  static const int totalSteps = 3;
  static const List<String> stepTitles = [
    'Información Personal',
    'Dirección en CDMX',
    'Etiquetas y Confirmación',
  ];
  static const List<String> stepSubtitles = [
    'Datos básicos de identificación',
    'Dirección completa del cliente',
    'Categorización y resumen final',
  ];

  // ✅ ESTADO INTERNO
  int _currentStep = 0;
  late ClientFormController _formController;
  bool _isInitialized = false;
  bool _isNavigating = false;
  ClientModel? _existingClient;

  // ✅ NUEVAS VARIABLES PARA MODO DE SERVICIO HÍBRIDO
  ClientServiceMode _currentServiceMode = ClientServiceMode.sucursal;
  WizardConfiguration? _wizardConfiguration;
  bool _serviceConfigLoaded = false;

  // ✅ VALIDACIÓN INTELIGENTE - SOLO MOSTRAR ERRORES CUANDO EL USUARIO INTENTA AVANZAR
  bool _hasUserTriedToAdvance = false;
  final List<bool> _stepValidationStatus = [false, false, false];
  final Map<int, List<String>> _stepErrors = {};
  final Set<int> _stepsAttemptedToValidate = {};

  // ✅ CONSTRUCTOR
  WizardController({ClientModel? existingClient}) {
    _existingClient = existingClient;
    _initializeFormController();
  }

  // ========================================================================
  // 🎯 GETTERS PÚBLICOS
  // ========================================================================

  /// Estado actual del wizard
  int get currentStep => _currentStep;
  bool get isInitialized => _isInitialized;
  bool get isNavigating => _isNavigating;

  /// Información del paso actual
  String get currentStepTitle => stepTitles[_currentStep];
  String get currentStepSubtitle => stepSubtitles[_currentStep];
  double get progress => (_currentStep + 1) / totalSteps;
  int get stepNumber => _currentStep + 1;

  /// Estados de navegación
  bool get isFirstStep => _currentStep == 0;
  bool get isLastStep => _currentStep == totalSteps - 1;
  bool get canGoNext => !_isNavigating && !isLastStep;
  bool get canGoPrevious => _currentStep > 0 && !_isNavigating;
  bool get canFinish => isLastStep && !_isNavigating;

  /// ✅ NUEVOS GETTERS PARA MODO DE SERVICIO HÍBRIDO
  ClientServiceMode get currentServiceMode => _currentServiceMode;
  WizardConfiguration? get wizardConfiguration => _wizardConfiguration;
  bool get serviceConfigLoaded => _serviceConfigLoaded;

  /// ✅ NUEVO: VERIFICAR SI DEBE MOSTRAR TOGGLE
  bool get shouldShowServiceToggle {
    return _wizardConfiguration?.shouldShowToggleInWizard ?? false;
  }

  /// ✅ NUEVO: OBTENER LABEL PARA BOTÓN DE CREAR
  String get createButtonLabel {
    return _wizardConfiguration?.getCreateButtonLabel(_currentServiceMode) ??
        'Crear Cliente';
  }

  /// ✅ NUEVO: OBTENER DESCRIPCIÓN PARA PASO DE DIRECCIÓN
  String get addressStepDescription {
    return _wizardConfiguration
            ?.getAddressStepDescription(_currentServiceMode) ??
        'Dirección opcional';
  }

  /// ✅ NUEVO: VERIFICAR SI DIRECCIÓN ES REQUERIDA
  bool get isAddressRequired {
    return _wizardConfiguration?.isAddressRequired(_currentServiceMode) ??
        false;
  }

  /// ✅ VALIDACIÓN INTELIGENTE: Solo mostrar errores si el usuario YA INTENTÓ avanzar
  bool get currentStepValid =>
      !_shouldShowErrors || (_stepErrors[_currentStep]?.isEmpty ?? true);
  bool get _shouldShowErrors =>
      _hasUserTriedToAdvance &&
      _stepsAttemptedToValidate.contains(_currentStep);

  List<String> get currentStepErrors =>
      _shouldShowErrors ? (_stepErrors[_currentStep] ?? []) : [];
  bool get hasStepErrors => currentStepErrors.isNotEmpty;

  /// Datos del formulario
  ClientFormController get formController => _formController;
  ClientFormModel get formData => _formController.formData;
  bool get isEditMode => _existingClient != null;

  // ========================================================================
  // 🚀 MÉTODOS DE INICIALIZACIÓN
  // ========================================================================

  /// Inicializar controlador del formulario
  void _initializeFormController() {
    final formService = ClientFormService();
    _formController = ClientFormController(formService: formService);

    _formController.addListener(_onFormDataChangedSilently);

    if (_existingClient != null) {
      // ✅ FIX: USAR DIRECTAMENTE EL SERVICEMODE DEL CLIENTE
      _currentServiceMode = _existingClient!.serviceMode;
      debugPrint(
          '🔧 ServiceMode del cliente existente: ${_currentServiceMode.label}');

      _formController.loadExistingClient(_existingClient!);
    } else {
      _formController.initializeNewClient();
      _initializeServiceConfigurationAsync();
    }

    _isInitialized = true;
    notifyListeners();

    debugPrint(
        '🧠 WizardController inicializado ${isEditMode ? "(modo edición)" : "(nuevo cliente)"}');
  }

  /// ✅ NUEVO: INICIALIZAR CONFIGURACIÓN DE FORMA ASÍNCRONA
  void _initializeServiceConfigurationAsync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeServiceConfiguration();
    });
  }

  /// ✅ LISTENER SILENCIOSO - Solo actualiza datos, NO valida automáticamente
  void _onFormDataChangedSilently() {
    notifyListeners();

    if (_stepsAttemptedToValidate.contains(_currentStep) &&
        _hasUserTriedToAdvance) {
      _validateCurrentStepSilently();
    }
  }

  /// ✅ VALIDACIÓN SILENCIOSA - No muestra errores, solo actualiza estado interno
  Future<void> _validateCurrentStepSilently() async {
    final wasValid = await _performStepValidation(_currentStep);
    _stepValidationStatus[_currentStep] = wasValid;

    if (wasValid) {
      _stepErrors.remove(_currentStep);
      notifyListeners();
    }
  }

  // ========================================================================
  // 🆕 MÉTODOS PARA MODO DE SERVICIO HÍBRIDO - ✅ FIX CRÍTICO
  // ========================================================================

  /// ✅ NUEVO: INICIALIZAR CONFIGURACIÓN DE SERVICIO
  Future<void> initializeServiceConfiguration() async {
    try {
      final settingsService = CompanySettingsService();
      await settingsService.initialize();

      _wizardConfiguration = settingsService.getWizardConfiguration();
      _currentServiceMode = _wizardConfiguration?.defaultServiceMode ??
          ClientServiceMode.sucursal;

      // ✅ FIX CRÍTICO: SINCRONIZAR CON FORMCONTROLLER AL INICIALIZAR
      if (_isInitialized) {
        updateServiceMode(_currentServiceMode);
        debugPrint(
            '🔄 WizardController: Sincronizando serviceMode inicial: ${_currentServiceMode.label}');
      }

      _serviceConfigLoaded = true;
      notifyListeners();

      debugPrint(
          '✅ Configuración de servicio cargada: ${_currentServiceMode.label}');
    } catch (e) {
      debugPrint('❌ Error cargando configuración de servicio: $e');
      _currentServiceMode = ClientServiceMode.sucursal;

      // ✅ FIX CRÍTICO: SINCRONIZAR INCLUSO EN CASO DE ERROR
      if (_isInitialized) {
        updateServiceMode(_currentServiceMode);
      }

      _serviceConfigLoaded = true;
      notifyListeners();
    }
  }

  /// ✅ FIX CRÍTICO: CAMBIAR MODO DE SERVICIO CON SINCRONIZACIÓN
  void setServiceMode(ClientServiceMode mode) {
    if (_currentServiceMode == mode) return;

    debugPrint(
        '🔄 WizardController: Cambiando modo de servicio: ${_currentServiceMode.label} → ${mode.label}');

    _currentServiceMode = mode;

    // ✅ FIX CRÍTICO: SINCRONIZAR CON FORMCONTROLLER INMEDIATAMENTE
    if (_isInitialized) {
      updateServiceMode(mode);
      debugPrint('✅ WizardController: Modo sincronizado con FormController');
    }

    // Limpiar validación del paso de dirección cuando cambie el modo
    if (mode == ClientServiceMode.domicilio ||
        mode == ClientServiceMode.ambos) {
      _stepsAttemptedToValidate.remove(1);
    }

    notifyListeners();
  }

  /// ✅ MEJORA #1: SINCRONIZACIÓN AUTOMÁTICA SERVICEMODE
  void updateServiceMode(ClientServiceMode mode) {
    // Actualizar el formData con el nuevo serviceMode usando método existente
    try {
      _formController.updateServiceMode(mode);
      debugPrint('🔄 ServiceMode sincronizado: ${mode.label}');
    } catch (e) {
      debugPrint('⚠️ Error sincronizando ServiceMode: $e');
    }
  }

  /// ✅ NUEVO: ESTABLECER CONFIGURACIÓN POR DEFECTO
  void setDefaultServiceMode(CompanySettings settings) {
    // ✅ FIX CRÍTICO: NO SOBREESCRIBIR SI YA HAY UN CLIENTE CARGADO
    if (isEditMode) {
      debugPrint('⚠️ EVITANDO sobreescribir ServiceMode de cliente existente');
      debugPrint('   - Cliente actual: ${_existingClient?.fullName}');
      debugPrint('   - ServiceMode actual: ${_currentServiceMode.label}');
      debugPrint('   - Settings default: ${settings.defaultServiceMode.label}');

      // Solo actualizar la configuración, NO el serviceMode actual
      _wizardConfiguration = WizardConfiguration(
        showServiceModeToggle: settings.showServiceModeToggle,
        defaultServiceMode: settings.defaultServiceMode,
        enableHomeServices: settings.enableHomeServices,
        businessType: settings.businessType,
      );

      _serviceConfigLoaded = true;
      notifyListeners();
      return;
    }

    // ✅ SOLO PARA CLIENTES NUEVOS: usar configuración por defecto
    _wizardConfiguration = WizardConfiguration(
      showServiceModeToggle: settings.showServiceModeToggle,
      defaultServiceMode: settings.defaultServiceMode,
      enableHomeServices: settings.enableHomeServices,
      businessType: settings.businessType,
    );

    _currentServiceMode = settings.defaultServiceMode;

    // ✅ FIX CRÍTICO: SINCRONIZAR CON FORMCONTROLLER
    if (_isInitialized) {
      updateServiceMode(_currentServiceMode);
      debugPrint(
          '🔄 WizardController: Sincronizando configuración por defecto: ${_currentServiceMode.label}');
    }

    _serviceConfigLoaded = true;

    notifyListeners();
  }

  /// ✅ NUEVO: DETECTAR MODO DE SERVICIO DE CLIENTE EXISTENTE
  ClientServiceMode _detectServiceModeFromExistingClient(ClientModel client) {
    debugPrint('🔍 DEBUGGING: Detectando ServiceMode de cliente existente');
    debugPrint(
        '   - client.serviceMode (directo): ${client.serviceMode.name} (${client.serviceMode.label})');
    debugPrint('   - client.isHomeService: ${client.isHomeService}');
    debugPrint('   - client.isInSiteService: ${client.isInSiteService}');
    debugPrint('   - client.isHybridService: ${client.isHybridService}');

    // ✅ FIX: USAR DIRECTAMENTE EL SERVICEMODE DEL CLIENTE SIN DETECCIÓN
    final directServiceMode = client.serviceMode;
    debugPrint(
        '   - ServiceMode directo del modelo: ${directServiceMode.name}');

    // ✅ VERIFICAR SI ES DIFERENTE DE SUCURSAL
    if (directServiceMode != ClientServiceMode.sucursal) {
      debugPrint(
          '✅ Usando ServiceMode directo (no es sucursal): ${directServiceMode.label}');
      return directServiceMode;
    }

    // ✅ SI ES SUCURSAL, VERIFICAR QUE REALMENTE LO SEA
    debugPrint('🔍 Es sucursal, verificando tags...');

    // Buscar en las tags si hay indicador de modo de servicio
    final hasHomeServiceTag = client.tags.any((tag) =>
        tag.label.toLowerCase().contains('domicilio') ||
        tag.label.toLowerCase().contains('home') ||
        tag.label.toLowerCase().contains('móvil'));

    final hasHybridTag = client.tags.any((tag) =>
        tag.label.toLowerCase().contains('híbrido') ||
        tag.label.toLowerCase().contains('ambos'));

    debugPrint('   - hasHybridTag: $hasHybridTag');
    debugPrint('   - hasHomeServiceTag: $hasHomeServiceTag');

    if (hasHybridTag) {
      debugPrint('✅ Detectado por tag híbrido → ambos');
      return ClientServiceMode.ambos;
    }

    if (hasHomeServiceTag) {
      debugPrint('✅ Detectado por tag domicilio → domicilio');
      return ClientServiceMode.domicilio;
    }

    // Si tiene dirección completa, es probable que sea servicio a domicilio
    final hasCompleteAddress = client.addressInfo.calle.isNotEmpty &&
        client.addressInfo.numeroExterior.isNotEmpty &&
        client.addressInfo.colonia.isNotEmpty;

    debugPrint('   - hasCompleteAddress: $hasCompleteAddress');

    if (hasCompleteAddress) {
      debugPrint('✅ Detectado por dirección completa → domicilio');
      return ClientServiceMode.domicilio;
    }

    // Por defecto, confirmar sucursal
    debugPrint('✅ Confirmado como sucursal (default)');
    return ClientServiceMode.sucursal;
  }

  // ========================================================================
  // 🎮 MÉTODOS DE NAVEGACIÓN
  // ========================================================================

  /// ✅ IR AL SIGUIENTE PASO - AQUÍ ES DONDE SE VALIDA
  Future<void> nextStep() async {
    if (!canGoNext || _isNavigating) return;

    debugPrint(
        '🎮 Usuario intenta avanzar al paso ${_currentStep + 1} → ${_currentStep + 2}');

    _hasUserTriedToAdvance = true;
    _stepsAttemptedToValidate.add(_currentStep);

    _isNavigating = true;
    notifyListeners();

    try {
      final isValid = await _validateCurrentStep();

      if (!isValid) {
        debugPrint('❌ Validación falló. Mostrando errores al usuario.');
        notifyListeners();
        return;
      }

      HapticFeedback.lightImpact();
      _currentStep++;

      debugPrint(
          '✅ Navegación completada. Paso actual: $stepNumber/$totalSteps');
    } catch (e) {
      debugPrint('❌ Error en navegación: $e');
      _addStepError(_currentStep, 'Error de navegación: $e');
      notifyListeners();
    } finally {
      _isNavigating = false;
      notifyListeners();
    }
  }

  /// Ir al paso anterior
  Future<void> previousStep() async {
    if (!canGoPrevious || _isNavigating) return;

    debugPrint('🎮 Navegando al paso ${_currentStep + 1} → $_currentStep');

    _isNavigating = true;
    notifyListeners();

    try {
      HapticFeedback.lightImpact();
      _currentStep--;
      debugPrint(
          '✅ Navegación hacia atrás completada. Paso actual: $stepNumber/$totalSteps');
    } finally {
      _isNavigating = false;
      notifyListeners();
    }
  }

  /// Ir directamente a un paso específico
  Future<void> goToStep(int stepIndex) async {
    if (stepIndex < 0 || stepIndex >= totalSteps || stepIndex == _currentStep)
      return;

    debugPrint('🎮 Navegación directa al paso ${stepIndex + 1}');

    _isNavigating = true;
    notifyListeners();

    try {
      _currentStep = stepIndex;
      HapticFeedback.lightImpact();
    } finally {
      _isNavigating = false;
      notifyListeners();
    }
  }

  // ========================================================================
  // ✅ MÉTODOS DE VALIDACIÓN - FIX COMPLETO APLICADO + MODO SERVICIO HÍBRIDO + AMBOS
  // ========================================================================

  /// ✅ VALIDAR EL PASO ACTUAL - Solo cuando el usuario intenta avanzar
  Future<bool> _validateCurrentStep() async {
    debugPrint(
        '🔍 Validando paso ${_currentStep + 1} (usuario intentó avanzar)...');

    _clearStepErrors(_currentStep);

    try {
      final isValid = await _performStepValidation(_currentStep);
      _stepValidationStatus[_currentStep] = isValid;

      debugPrint(
          '📊 Validación paso ${_currentStep + 1}: ${isValid ? "✅ VÁLIDO" : "❌ INVÁLIDO"}');

      return isValid;
    } catch (e) {
      debugPrint('❌ Error validando paso ${_currentStep + 1}: $e');
      _addStepError(_currentStep, 'Error de validación: $e');
      _stepValidationStatus[_currentStep] = false;
      return false;
    }
  }

  /// ✅ REALIZAR VALIDACIÓN REAL DEL PASO
  Future<bool> _performStepValidation(int stepIndex) async {
    switch (stepIndex) {
      case 0:
        return await _validatePersonalInfoStep();
      case 1:
        return await _validateAddressInfoStep();
      case 2:
        return await _validateTagsAndSummaryStep();
      default:
        return false;
    }
  }

  /// ✅ FIX: Validar paso 1: Información Personal - VALIDACIÓN INTERNACIONAL
  Future<bool> _validatePersonalInfoStep() async {
    final personalInfo = _formController.formData.personalInfo;
    final errors = <String>[];

    if (personalInfo.nombre.trim().isEmpty) {
      errors.add('Nombre es requerido');
    }

    if (personalInfo.apellidos.trim().isEmpty) {
      errors.add('Apellidos son requeridos');
    }

    if (personalInfo.email.trim().isEmpty) {
      errors.add('Email es requerido');
    } else if (!_isValidEmail(personalInfo.email)) {
      errors.add('Email no tiene formato válido');
    } else if (!isEditMode) {
      try {
        final formService = ClientFormService();
        final isUnique = await formService.isEmailUnique(personalInfo.email);
        if (!isUnique) {
          errors.add('Este email ya está registrado');
        }
      } catch (e) {
        debugPrint('⚠️ No se pudo validar email único: $e');
      }
    }

    if (personalInfo.telefono.trim().isEmpty) {
      errors.add('Teléfono es requerido');
    } else if (!_isValidInternationalPhone(personalInfo.telefono)) {
      errors.add(
          'Formato de teléfono no válido (use formato internacional: +52 55 1234 5678 o nacional: 5512345678)');
    }

    if (errors.isNotEmpty) {
      _stepErrors[_currentStep] = errors;
    }

    return errors.isEmpty;
  }

  /// ✅ ACTUALIZADO: Validar paso 2 basado en modo de servicio HÍBRIDO + AMBOS
  Future<bool> _validateAddressInfoStep() async {
    final addressInfo = _formController.formData.addressInfo;
    final errors = <String>[];

    debugPrint(
        '🔍 Validando dirección para modo: ${_currentServiceMode.label}');

    if (_currentServiceMode == ClientServiceMode.sucursal) {
      debugPrint('✅ Modo sucursal: Dirección opcional - paso válido');

      // Solo validar CP si se proporciona
      if (addressInfo.codigoPostal.trim().isNotEmpty &&
          !_isValidCP(addressInfo.codigoPostal)) {
        errors.add('Código postal debe tener 5 dígitos');
      }

      if (errors.isNotEmpty) {
        _stepErrors[_currentStep] = errors;
        return false;
      }

      return true;
    }

    // ✅ NUEVO: VALIDACIÓN PARA MODO AMBOS
    if (_currentServiceMode == ClientServiceMode.ambos) {
      debugPrint('🔄 Modo ambos: Dirección opcional pero recomendada');

      // Para clientes híbridos: dirección opcional pero si se proporciona debe ser válida
      if (addressInfo.codigoPostal.trim().isNotEmpty &&
          !_isValidCP(addressInfo.codigoPostal)) {
        errors.add('Código postal debe tener 5 dígitos');
      }

      // Si proporciona dirección parcial, validar consistencia básica
      final hasPartialAddress = addressInfo.calle.trim().isNotEmpty ||
          addressInfo.colonia.trim().isNotEmpty ||
          addressInfo.alcaldia.trim().isNotEmpty;

      if (hasPartialAddress) {
        if (addressInfo.calle.trim().isNotEmpty &&
            addressInfo.colonia.trim().isEmpty) {
          errors.add('Si proporciona calle, la colonia es recomendada');
        }
      }

      if (errors.isNotEmpty) {
        _stepErrors[_currentStep] = errors;
        return false;
      }

      debugPrint('✅ Dirección válida para modo ambos (híbrido)');
      return true;
    }

    if (_currentServiceMode == ClientServiceMode.domicilio) {
      debugPrint('🏠 Modo domicilio: Validando dirección requerida');

      // Para servicios a domicilio: dirección básica requerida
      if (addressInfo.calle.trim().isEmpty) {
        errors.add('Calle es requerida para servicios a domicilio');
      }
      if (addressInfo.numeroExterior.trim().isEmpty) {
        errors.add('Número exterior es requerido para servicios a domicilio');
      }
      if (addressInfo.colonia.trim().isEmpty) {
        errors.add('Colonia es requerida para servicios a domicilio');
      }
      if (addressInfo.alcaldia.trim().isEmpty) {
        errors.add('Alcaldía es requerida para servicios a domicilio');
      }

      // CP opcional pero si se proporciona debe ser válido
      if (addressInfo.codigoPostal.trim().isNotEmpty &&
          !_isValidCP(addressInfo.codigoPostal)) {
        errors.add('Código postal debe tener 5 dígitos');
      }

      if (errors.isNotEmpty) {
        _stepErrors[_currentStep] = errors;
        return false;
      }

      debugPrint('✅ Dirección válida para servicios a domicilio');
      return true;
    }

    return true;
  }

  /// Validar paso 3: Etiquetas y Confirmación
  Future<bool> _validateTagsAndSummaryStep() async {
    final errors = <String>[];

    // Validar pasos anteriores
    for (int i = 0; i < 2; i++) {
      final isValid = await _performStepValidation(i);
      if (!isValid) {
        errors.add('Información incompleta en paso ${i + 1}');
      }
    }

    final personalInfo = _formController.formData.personalInfo;
    if (personalInfo.fullName.trim().length < 3) {
      errors.add('Nombre completo muy corto');
    }

    if (errors.isNotEmpty) {
      _stepErrors[_currentStep] = errors;
    }

    return errors.isEmpty;
  }

  // ========================================================================
  // 🎯 MÉTODOS DE FINALIZACIÓN
  // ========================================================================

  /// ✅ FINALIZAR WIZARD Y GUARDAR CLIENTE - ✅ CON LOG MEJORADO PARA SERVICEMODE
  Future<bool> finishWizard() async {
    debugPrint('🎯 Finalizando wizard y guardando cliente...');
    debugPrint('🎯 ServiceMode final: ${_currentServiceMode.label}');

    _hasUserTriedToAdvance = true;
    for (int i = 0; i < totalSteps; i++) {
      _stepsAttemptedToValidate.add(i);
    }

    try {
      bool allValid = true;
      for (int i = 0; i < totalSteps; i++) {
        final isValid = await _performStepValidation(i);
        _stepValidationStatus[i] = isValid;

        if (!isValid) {
          allValid = false;
          debugPrint('❌ Paso ${i + 1} no válido durante validación final');
        }
      }

      if (!allValid) {
        for (int i = 0; i < totalSteps; i++) {
          if ((_stepErrors[i]?.isNotEmpty ?? false)) {
            _currentStep = i;
            break;
          }
        }
        notifyListeners();
        return false;
      }

      // ✅ LOG CRÍTICO ANTES DE GUARDAR
      debugPrint('💾 Datos del FormController antes de guardar:');
      debugPrint(
          '   - ServiceMode: ${_formController.formData.serviceMode.label}');
      debugPrint(
          '   - IsHomeService: ${_formController.formData.isHomeService}');
      debugPrint(
          '   - IsInSiteService: ${_formController.formData.isInSiteService}');
      debugPrint(
          '   - IsHybridService: ${_formController.formData.isHybridService}');

      final success = await _formController.saveClient();

      if (success == true) {
        debugPrint(
            '✅ Cliente guardado exitosamente con modo: ${_currentServiceMode.label}');
        HapticFeedback.mediumImpact();
        return true;
      } else {
        debugPrint('❌ Error guardando cliente');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error finalizando wizard: $e');
      _addStepError(_currentStep, 'Error guardando: $e');
      return false;
    }
  }

  // ========================================================================
  // 🚀 MÉTODOS DE GUARDADO RÁPIDO - ✅ ACTUALIZADO CON MODO HÍBRIDO + AMBOS
  // ========================================================================

  /// 🚀 GUARDAR CLIENTE RÁPIDO - ✅ ACTUALIZADO PARA MODO DE SERVICIO + AMBOS
  Future<bool> saveQuickClient() async {
    debugPrint(
        '🚀 Guardando cliente rápido (modo: ${_currentServiceMode.label})...');

    try {
      // Validar información personal (siempre requerida)
      final personalValid = await _performStepValidation(0);

      if (!personalValid) {
        _hasUserTriedToAdvance = true;
        _stepsAttemptedToValidate.add(0);
        notifyListeners();
        return false;
      }

      // Para servicios a domicilio, validar dirección también
      if (_currentServiceMode == ClientServiceMode.domicilio) {
        final addressValid = await _performStepValidation(1);
        if (!addressValid) {
          _hasUserTriedToAdvance = true;
          _stepsAttemptedToValidate.add(1);
          notifyListeners();
          return false;
        }
      }

      // ✅ NUEVO: Para modo ambos, validar dirección solo si se proporcionó
      if (_currentServiceMode == ClientServiceMode.ambos) {
        final addressInfo = _formController.formData.addressInfo;
        final hasAddressData = addressInfo.calle.trim().isNotEmpty ||
            addressInfo.colonia.trim().isNotEmpty;

        if (hasAddressData) {
          final addressValid = await _performStepValidation(1);
          if (!addressValid) {
            _hasUserTriedToAdvance = true;
            _stepsAttemptedToValidate.add(1);
            notifyListeners();
            return false;
          }
        }
      }

      final success = await _formController.saveClient();

      if (success == true) {
        debugPrint(
            '✅ Cliente rápido guardado exitosamente (${_currentServiceMode.label})');
        HapticFeedback.mediumImpact();
        return true;
      } else {
        debugPrint('❌ Error guardando cliente rápido');
        _addStepError(0, 'Error guardando cliente');
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error en guardado rápido: $e');
      _addStepError(0, 'Error guardando: $e');
      notifyListeners();
      return false;
    }
  }

  // ========================================================================
  // 🔧 MÉTODOS HELPER PRIVADOS - ✅ FIX: VALIDACIÓN INTERNACIONAL
  // ========================================================================

  void _addStepError(int stepIndex, String error) {
    if (!_stepErrors.containsKey(stepIndex)) {
      _stepErrors[stepIndex] = <String>[];
    }
    _stepErrors[stepIndex]!.add(error);
    _stepValidationStatus[stepIndex] = false;
  }

  void _clearStepErrors(int stepIndex) {
    _stepErrors.remove(stepIndex);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim());
  }

  bool _isValidInternationalPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    debugPrint('🔧 WIZARD: VALIDANDO TELÉFONO: "$phone" → LIMPIO: "$cleaned"');

    // Validaciones básicas
    if (cleaned.isEmpty) return false;
    if (cleaned.length < 7) return false;
    if (cleaned.length > 20) return false;

    // 1. INTERNACIONAL CON +: +52, +1, +34, etc.
    if (cleaned.startsWith('+')) {
      final isValid = cleaned.length >= 10 && cleaned.length <= 16;
      debugPrint(
          '📞 WIZARD: Internacional con +: ${isValid ? "✅ VÁLIDO" : "❌ INVÁLIDO"}');
      return isValid;
    }

    // 2. MEXICANO TRADICIONAL: 10 dígitos exactos
    if (cleaned.length == 10) {
      debugPrint('📞 WIZARD: Mexicano tradicional: ✅ VÁLIDO');
      return true;
    }

    // 3. INTERNACIONAL SIN +: Entre 7-15 dígitos
    if (cleaned.length >= 7 && cleaned.length <= 15) {
      debugPrint('📞 WIZARD: Internacional sin +: ✅ VÁLIDO');
      return true;
    }

    debugPrint('❌ WIZARD: Formato no reconocido');
    return false;
  }

  bool _isValidCP(String cp) {
    final cleaned = cp.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length == 5;
  }

  // ========================================================================
  // 🔄 MÉTODOS DE CLIENTE EXISTENTE - ✅ FIX #3 DEL PLAN APLICADO
  // ========================================================================

  /// 🔄 CARGAR CLIENTE EXISTENTE - ✅ FIX CRÍTICO: SERVICEMODE PRESERVATION COMPLETO
  void loadExistingClient(ClientModel client) {
    debugPrint('🔄 WizardController.loadExistingClient: ${client.fullName}');
    debugPrint('   - ServiceMode del cliente: ${client.serviceMode.label}');
    debugPrint('   - isHomeService: ${client.isHomeService}');
    debugPrint('   - isInSiteService: ${client.isInSiteService}');
    debugPrint('   - isHybridService: ${client.isHybridService}');

    // ✅ FIX CRÍTICO: ESTABLECER SERVICEMODE EN WIZARD CONTROLLER PRIMERO
    _currentServiceMode = client.serviceMode;
    debugPrint(
        '   - ServiceMode establecido en wizard: ${_currentServiceMode.label}');

    // ✅ CARGAR EN FORMCONTROLLER
    _formController.loadExistingClient(client);

    // ✅ FIX CRÍTICO: FORZAR SINCRONIZACIÓN DESPUÉS DE CARGAR
    updateServiceMode(_currentServiceMode);

    // ✅ LOG DE VERIFICACIÓN FINAL
    debugPrint('📊 Estado final después de loadExistingClient:');
    debugPrint('   - _currentServiceMode: ${_currentServiceMode.label}');
    debugPrint(
        '   - formController.serviceMode: ${_formController.formData.serviceMode.label}');

    notifyListeners(); // ✅ CRÍTICO: Notificar cambios para UI
  }

  /// 🆕 INICIALIZAR CLIENTE NUEVO
  void initializeNewClient() {
    _formController.initializeNewClient();
    _currentServiceMode = ClientServiceMode.sucursal;
    notifyListeners();
  }

  /// 🔍 CARGAR CLIENTE POR ID
  Future<void> loadClientById(String clientId) async {
    try {
      await _formController.loadClientById(clientId);

      if (_formController.isEditMode) {
        final formData = _formController.formData;
        _currentServiceMode = formData.serviceMode;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error cargando cliente por ID: $e');
      _addStepError(_currentStep, 'Error cargando cliente: $e');
    }
  }

  /// 🎛️ ESTABLECER CONTROLADOR DE VALIDACIÓN
  void setValidationController(dynamic validationController) {
    debugPrint('🎛️ Validation controller set');
  }

  // ========================================================================
  // 📊 MÉTODOS DE DEBUG Y ANALYTICS - ✅ AGREGADO INFO DE SERVICIO
  // ========================================================================

  void logCurrentState() {
    debugPrint('📊 WizardController State:');
    debugPrint('   currentStep: ${_currentStep + 1}/$totalSteps');
    debugPrint('   serviceMode: ${_currentServiceMode.label}');
    debugPrint('   showServiceToggle: $shouldShowServiceToggle');
    debugPrint('   addressRequired: $isAddressRequired');
    debugPrint('   hasUserTriedToAdvance: $_hasUserTriedToAdvance');
    debugPrint('   stepsAttemptedToValidate: $_stepsAttemptedToValidate');
    debugPrint('   shouldShowErrors: $_shouldShowErrors');
    debugPrint('   currentStepErrors: ${currentStepErrors.length}');
    debugPrint('   canGoNext: $canGoNext');
    debugPrint('   canFinish: $canFinish');

    // ✅ LOG CRÍTICO PARA DEBUGGING SERVICEMODE
    debugPrint('🔧 ServiceMode Debug:');
    debugPrint('   _currentServiceMode: ${_currentServiceMode.label}');
    debugPrint(
        '   formData.serviceMode: ${_formController.formData.serviceMode.label}');
  }

  // ========================================================================
  // 🧹 CLEANUP
  // ========================================================================

  @override
  void dispose() {
    _formController.removeListener(_onFormDataChangedSilently);
    _formController.dispose();
    super.dispose();
    debugPrint('🧹 WizardController disposed');
  }
}
