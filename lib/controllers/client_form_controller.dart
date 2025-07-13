// [client_form_controller.dart] - CONTROLADOR ENTERPRISE PARA FORMULARIO DE CLIENTE - ✅ CON FECHA DE NACIMIENTO COMPLETO
// 📁 Ubicación: /lib/controllers/client_form_controller.dart
// 🎯 OBJETIVO: Controlador robusto con gestión de estado y validaciones - CP OPCIONAL + SERVICEMODE SYNC + FECHA NACIMIENTO COMPLETO
// ✅ FIX CRÍTICO: Agregado updateFechaNacimiento() completo + carga desde cliente existente

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_form_model.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_form_state.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/models/company/company_settings_model.dart';
import 'package:agenda_fisio_spa_kym/services/clients/client_form_service.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/background_cost_monitor.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/cost_data_models.dart';

/// 🧠 CONTROLADOR PRINCIPAL DEL FORMULARIO DE CLIENTE
class ClientFormController extends ChangeNotifier {
  // ✅ SERVICIOS Y DEPENDENCIAS
  final ClientFormService _formService;
  final BackgroundCostMonitor _costMonitor;

  // ✅ ESTADO INTERNO
  ClientFormModel _formData;
  ClientFormStateModel _currentState;
  final ClientFormStateMetrics _metrics;

  // ✅ TIMERS Y DEBOUNCING
  Timer? _validationTimer;
  Timer? _stateTimer;
  static const Duration _validationDebounce = Duration(milliseconds: 300);

  // ✅ NOTIFIERS ESPECÍFICOS PARA OPTIMIZACIÓN
  final ValueNotifier<PersonalFormInfo> _personalInfoNotifier;
  final ValueNotifier<AddressFormInfo> _addressInfoNotifier;
  final ValueNotifier<TagsFormInfo> _tagsInfoNotifier;
  final ValueNotifier<ClientFormValidation> _validationNotifier;
  final ValueNotifier<ClientFormStateModel> _stateNotifier;

  ClientFormController({
    required ClientFormService formService,
    BackgroundCostMonitor? costMonitor,
    ClientModel? existingClient,
  })  : _formService = formService,
        _costMonitor = costMonitor ?? BackgroundCostMonitor(),
        _formData = existingClient != null
            ? ClientFormModel.fromClient(existingClient)
            : ClientFormModel.empty(),
        _currentState = ClientFormStateModel.initial(),
        _metrics = ClientFormStateMetrics.empty(),
        // ✅ FIX CRÍTICO 1: CONSTRUCTOR CON fechaNacimiento
        _personalInfoNotifier = ValueNotifier(existingClient != null
            ? PersonalFormInfo(
                nombre: existingClient.personalInfo.nombre,
                apellidos: existingClient.personalInfo.apellidos,
                email: existingClient.contactInfo.email,
                telefono: existingClient.contactInfo.telefono,
                empresa: existingClient.personalInfo.empresa,
                fechaNacimiento:
                    existingClient.personalInfo.fechaNacimiento, // ✅ AGREGADO
              )
            : PersonalFormInfo.empty()),
        _addressInfoNotifier = ValueNotifier(existingClient != null
            ? AddressFormInfo(
                calle: existingClient.addressInfo.calle,
                numeroExterior: existingClient.addressInfo.numeroExterior,
                numeroInterior: existingClient.addressInfo.numeroInterior,
                colonia: existingClient.addressInfo.colonia,
                codigoPostal: existingClient.addressInfo.codigoPostal,
                alcaldia: existingClient.addressInfo.alcaldia,
              )
            : AddressFormInfo.empty()),
        _tagsInfoNotifier = ValueNotifier(existingClient != null
            ? TagsFormInfo.fromClientTags(existingClient.tags)
            : TagsFormInfo.empty()),
        _validationNotifier = ValueNotifier(ClientFormValidation.empty()),
        _stateNotifier = ValueNotifier(ClientFormStateModel.initial()) {
    _initializeController();
  }

  // ========================================================================
  // 🎯 GETTERS PÚBLICOS
  // ========================================================================

  ClientFormModel get formData => _formData;
  ClientFormStateModel get currentState => _currentState;
  ClientFormStateMetrics get metrics => _metrics;

  // ValueNotifiers para widgets específicos
  ValueNotifier<PersonalFormInfo> get personalInfoNotifier =>
      _personalInfoNotifier;
  ValueNotifier<AddressFormInfo> get addressInfoNotifier =>
      _addressInfoNotifier;
  ValueNotifier<TagsFormInfo> get tagsInfoNotifier => _tagsInfoNotifier;
  ValueNotifier<ClientFormValidation> get validationNotifier =>
      _validationNotifier;
  ValueNotifier<ClientFormStateModel> get stateNotifier => _stateNotifier;

  // Getters de conveniencia
  bool get isEditing => _formData.isEditing;
  bool get canSave => _formData.isValid && _currentState.canEdit;
  bool get hasChanges => !_isFormEmpty();
  bool get isProcessing => _currentState.isProcessing;

  // ✅ AGREGADOS: Getters faltantes
  bool get isEditMode => _formData.isEditing;
  String? get currentClientId => _formData.clientId;
  ClientFormState get state => _currentState.state;
  bool get hasUnsavedChanges => hasChanges;

  // ✅ NUEVO: Getter para serviceMode
  ClientServiceMode get currentServiceMode => _formData.serviceMode;

  // ========================================================================
  // 🚀 MÉTODOS PÚBLICOS - INFORMACIÓN PERSONAL
  // ========================================================================

  /// 📝 ACTUALIZAR NOMBRE
  void updateNombre(String nombre) {
    if (_currentState.canEdit) {
      _updatePersonalInfo(_formData.personalInfo.copyWith(nombre: nombre));
      _scheduleValidation('nombre');
    }
  }

  /// 📝 ACTUALIZAR APELLIDOS
  void updateApellidos(String apellidos) {
    if (_currentState.canEdit) {
      _updatePersonalInfo(
          _formData.personalInfo.copyWith(apellidos: apellidos));
      _scheduleValidation('apellidos');
    }
  }

  /// 📧 ACTUALIZAR EMAIL
  void updateEmail(String email) {
    if (_currentState.canEdit) {
      _updatePersonalInfo(_formData.personalInfo.copyWith(email: email));
      _scheduleValidation('email');
    }
  }

  /// 📱 ACTUALIZAR TELÉFONO
  void updateTelefono(String telefono) {
    if (_currentState.canEdit) {
      // Formatear teléfono automáticamente
      final cleanPhone = _formatPhoneInternational(telefono);
      _updatePersonalInfo(
          _formData.personalInfo.copyWith(telefono: cleanPhone));
      _scheduleValidation('telefono');
    }
  }

  /// 🏢 ACTUALIZAR EMPRESA
  void updateEmpresa(String empresa) {
    if (_currentState.canEdit) {
      _updatePersonalInfo(_formData.personalInfo.copyWith(empresa: empresa));
    }
  }

  /// 🎂 ACTUALIZAR FECHA DE NACIMIENTO - ✅ FIX CRÍTICO: MÉTODO COMPLETO CON LOGS
  void updateFechaNacimiento(DateTime? fecha) {
    if (_currentState.canEdit) {
      debugPrint(
          '🎂 CONTROLLER: Actualizando fechaNacimiento: $fecha'); // ✅ LOG AGREGADO

      _updatePersonalInfo(
          _formData.personalInfo.copyWith(fechaNacimiento: fecha));

      if (_currentState.isInitial) {
        _updateState(ClientFormStateModel.editing());
      }

      debugPrint(
          '🎂 CONTROLLER: PersonalInfo actualizado con fecha: ${_formData.personalInfo.fechaNacimiento}'); // ✅ LOG AGREGADO
      debugPrint(
          '🎂 CONTROLLER: Notifier actualizado con fecha: ${_personalInfoNotifier.value.fechaNacimiento}'); // ✅ LOG EXTRA
    }
  }

  // ========================================================================
  // 🆕 NUEVO MÉTODO CRÍTICO - MODO DE SERVICIO
  // ========================================================================

  /// ⚙️ ACTUALIZAR MODO DE SERVICIO - ✅ FIX CRÍTICO AGREGADO
  void updateServiceMode(ClientServiceMode mode) {
    if (!_currentState.canEdit) return;

    debugPrint('🔄 FormController: Actualizando serviceMode a ${mode.label}');

    // Actualizar el formData con el nuevo modo
    _formData = _formData.copyWith(serviceMode: mode);

    // Marcar como editando si estaba en estado inicial
    if (_currentState.isInitial) {
      _updateState(ClientFormStateModel.editing());
    }

    notifyListeners();

    debugPrint(
        '✅ FormController: ServiceMode actualizado a ${_formData.serviceMode.label}');
  }

  // ========================================================================
  // 🚀 MÉTODOS PÚBLICOS - DIRECCIÓN
  // ========================================================================

  /// 🛣️ ACTUALIZAR CALLE
  void updateCalle(String calle) {
    if (_currentState.canEdit) {
      _updateAddressInfo(_formData.addressInfo.copyWith(calle: calle));
      _scheduleValidation('calle');
    }
  }

  /// 🏠 ACTUALIZAR NÚMERO EXTERIOR
  void updateNumeroExterior(String numero) {
    if (_currentState.canEdit) {
      _updateAddressInfo(
          _formData.addressInfo.copyWith(numeroExterior: numero));
      _scheduleValidation('numeroExterior');
    }
  }

  /// 🏠 ACTUALIZAR NÚMERO INTERIOR
  void updateNumeroInterior(String numero) {
    if (_currentState.canEdit) {
      _updateAddressInfo(
          _formData.addressInfo.copyWith(numeroInterior: numero));
    }
  }

  /// 🏘️ ACTUALIZAR COLONIA
  void updateColonia(String colonia) {
    if (_currentState.canEdit) {
      _updateAddressInfo(_formData.addressInfo.copyWith(colonia: colonia));
      _scheduleValidation('colonia');
    }
  }

  /// 📮 ACTUALIZAR CÓDIGO POSTAL
  void updateCodigoPostal(String cp) {
    if (_currentState.canEdit) {
      _updateAddressInfo(_formData.addressInfo.copyWith(codigoPostal: cp));
      _scheduleValidation('codigoPostal');
    }
  }

  /// 🏛️ ACTUALIZAR ALCALDÍA
  void updateAlcaldia(String alcaldia) {
    if (_currentState.canEdit) {
      _updateAddressInfo(_formData.addressInfo.copyWith(alcaldia: alcaldia));
      _scheduleValidation('alcaldia');
    }
  }

  // ========================================================================
  // 🚀 MÉTODOS PÚBLICOS - ETIQUETAS
  // ========================================================================

  /// 🏷️ AGREGAR/QUITAR ETIQUETA BASE
  void toggleBaseTag(String tag) {
    if (!_currentState.canEdit) return;

    final TagsFormInfo newTagsInfo;
    if (_formData.tagsInfo.baseTags.contains(tag)) {
      newTagsInfo = _formData.tagsInfo.removeBaseTag(tag);
      HapticFeedback.lightImpact();
    } else {
      newTagsInfo = _formData.tagsInfo.addBaseTag(tag);
      HapticFeedback.mediumImpact();
    }
    _updateTagsInfo(newTagsInfo);
  }

  /// 🏷️ AGREGAR ETIQUETA PERSONALIZADA
  void addCustomTag(String tag) {
    if (!_currentState.canEdit || tag.trim().isEmpty) return;

    final newTagsInfo = _formData.tagsInfo.addCustomTag(tag.trim());
    if (newTagsInfo != _formData.tagsInfo) {
      _updateTagsInfo(newTagsInfo);
      HapticFeedback.mediumImpact();
    }
  }

  /// 🗑️ ELIMINAR ETIQUETA PERSONALIZADA
  void removeCustomTag(String tag) {
    if (!_currentState.canEdit) return;

    final newTagsInfo = _formData.tagsInfo.removeCustomTag(tag);
    _updateTagsInfo(newTagsInfo);
    HapticFeedback.lightImpact();
  }

  // ========================================================================
  // 🚀 MÉTODOS PÚBLICOS - ACCIONES PRINCIPALES
  // ========================================================================

  /// 💾 GUARDAR CLIENTE - ✅ CON LOG MEJORADO PARA SERVICEMODE
  Future<bool> saveClient() async {
    if (!canSave) {
      debugPrint('⚠️ No se puede guardar: formulario inválido o procesando');
      return false;
    }

    // Verificar límites de costo
    if (_costMonitor.currentStats.dailyReadCount >=
        CostControlConfig.dailyReadLimit) {
      _updateState(ClientFormStateModel.error(
        message: 'Límite de costos alcanzado. Intente más tarde.',
        errorCode: 'COST_LIMIT_EXCEEDED',
      ));
      return false;
    }

    try {
      _updateState(ClientFormStateModel.saving());

      // ✅ LOG CRÍTICO PARA DEBUGGING
      debugPrint(
          '💾 Guardando cliente con serviceMode: ${_formData.serviceMode.label}');
      debugPrint(
          '💾 FormData completo: isHomeService=${_formData.isHomeService}, isInSiteService=${_formData.isInSiteService}');
      debugPrint(
          '🎂 Guardando cliente con fechaNacimiento: ${_formData.personalInfo.fechaNacimiento}'); // ✅ LOG FECHA

      // Validación final
      await _performFullValidation();

      if (!_formData.validation.isValid) {
        _updateState(ClientFormStateModel.error(
          message: 'Corrija los errores antes de guardar',
          errorCode: 'VALIDATION_FAILED',
          details: {'errors': _formData.validation.fieldErrors},
        ));
        return false;
      }

      // Guardar en base de datos
      final ClientModel savedClient;
      if (_formData.isEditing) {
        savedClient = await _formService.updateClient(_formData);
      } else {
        savedClient = await _formService.createClient(_formData);
      }

      _updateState(ClientFormStateModel.success(
        message: _formData.isEditing
            ? 'Cliente actualizado exitosamente'
            : 'Cliente creado exitosamente',
        clientId: savedClient.clientId,
      ));

      debugPrint(
          '✅ Cliente guardado exitosamente con serviceMode: ${_formData.serviceMode.label}');
      debugPrint(
          '✅ Cliente guardado con fechaNacimiento: ${savedClient.personalInfo.fechaNacimiento}'); // ✅ LOG FECHA

      HapticFeedback.heavyImpact();
      return true;
    } catch (e) {
      debugPrint('❌ Error guardando cliente: $e');

      String errorMessage = 'Error inesperado al guardar';
      String errorCode = 'UNKNOWN_ERROR';

      if (e.toString().contains('email')) {
        errorMessage = 'El email ya está registrado';
        errorCode = 'DUPLICATE_EMAIL';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Error de conexión';
        errorCode = 'NETWORK_ERROR';
      } else if (e.toString().contains('firestore')) {
        errorMessage = 'Error en base de datos';
        errorCode = 'FIRESTORE_ERROR';
      }

      _updateState(ClientFormStateModel.error(
        message: errorMessage,
        errorCode: errorCode,
        details: {'exception': e.toString()},
      ));

      HapticFeedback.heavyImpact();
      return false;
    }
  }

  /// 🔄 RESETEAR FORMULARIO
  void resetForm() {
    _validationTimer?.cancel();

    final newFormData = ClientFormModel.empty();
    _formData = newFormData;

    _personalInfoNotifier.value = newFormData.personalInfo;
    _addressInfoNotifier.value = newFormData.addressInfo;
    _tagsInfoNotifier.value = newFormData.tagsInfo;
    _validationNotifier.value = newFormData.validation;

    _updateState(ClientFormStateModel.initial());

    notifyListeners();
  }

  /// ✅ VALIDAR FORMULARIO COMPLETO
  Future<void> validateForm() async {
    _updateState(ClientFormStateModel.validating());
    await _performFullValidation();
    _updateState(ClientFormStateModel.editing());
  }

  // ✅ AGREGADOS: Métodos faltantes que usa el screen

  /// 🔄 CARGAR CLIENTE EXISTENTE - ✅ FIX CRÍTICO 2: CON fechaNacimiento
  void loadExistingClient(ClientModel client) {
    debugPrint('🔄 LOADING CLIENT: ${client.fullName}'); // ✅ LOG AGREGADO
    debugPrint(
        '🎂 LOADING CLIENT fechaNacimiento: ${client.personalInfo.fechaNacimiento}'); // ✅ LOG FECHA

    _formData = ClientFormModel.fromClient(client);

    // ✅ FIX CRÍTICO: INCLUIR fechaNacimiento EN NOTIFIER
    _personalInfoNotifier.value = PersonalFormInfo(
      nombre: client.personalInfo.nombre,
      apellidos: client.personalInfo.apellidos,
      email: client.contactInfo.email,
      telefono: client.contactInfo.telefono,
      empresa: client.personalInfo.empresa,
      fechaNacimiento:
          client.personalInfo.fechaNacimiento, // ✅ AGREGADO LÍNEA FALTANTE
    );

    _addressInfoNotifier.value = AddressFormInfo(
      calle: client.addressInfo.calle,
      numeroExterior: client.addressInfo.numeroExterior,
      numeroInterior: client.addressInfo.numeroInterior,
      colonia: client.addressInfo.colonia,
      codigoPostal: client.addressInfo.codigoPostal,
      alcaldia: client.addressInfo.alcaldia,
    );
    _tagsInfoNotifier.value = TagsFormInfo.fromClientTags(client.tags);
    _updateState(ClientFormStateModel.editing());

    debugPrint(
        '🔄 Cliente existente cargado con serviceMode: ${_formData.serviceMode.label}');
    debugPrint(
        '🎂 PersonalInfoNotifier cargado con fecha: ${_personalInfoNotifier.value.fechaNacimiento}'); // ✅ LOG VERIFICACIÓN
    notifyListeners();
  }

  /// 🆕 INICIALIZAR CLIENTE NUEVO
  void initializeNewClient() {
    _formData = ClientFormModel.empty();
    _personalInfoNotifier.value = PersonalFormInfo.empty();
    _addressInfoNotifier.value = AddressFormInfo.empty();
    _tagsInfoNotifier.value = TagsFormInfo.empty();
    _validationNotifier.value = ClientFormValidation.empty();
    _updateState(ClientFormStateModel.initial());

    debugPrint(
        '🆕 Nuevo cliente inicializado con serviceMode: ${_formData.serviceMode.label}');
    notifyListeners();
  }

  /// 🔍 CARGAR CLIENTE POR ID
  Future<void> loadClientById(String clientId) async {
    _updateState(ClientFormStateModel.loading());
    try {
      final client = await _formService.getClientById(clientId);
      if (client != null) {
        loadExistingClient(client);
      } else {
        _updateState(ClientFormStateModel.error(
          message: 'Cliente no encontrado',
          errorCode: 'CLIENT_NOT_FOUND',
        ));
      }
    } catch (e) {
      _updateState(ClientFormStateModel.error(
        message: 'Error cargando cliente: $e',
        errorCode: 'LOAD_ERROR',
      ));
    }
  }

  /// 🎛️ ESTABLECER CONTROLADOR DE VALIDACIÓN
  void setValidationController(dynamic validationController) {
    // Placeholder - implementar si es necesario
    debugPrint('🎛️ Validation controller set');
  }

  // ========================================================================
  // 🔧 MÉTODOS PRIVADOS
  // ========================================================================

  void _initializeController() {
    if (_formData.isEditing) {
      _updateState(ClientFormStateModel.editing());
    }

    // Configurar listeners para métricas
    _stateNotifier.addListener(_trackStateMetrics);
  }

  void _updatePersonalInfo(PersonalFormInfo newInfo) {
    _formData = _formData.copyWith(personalInfo: newInfo);
    _personalInfoNotifier.value = newInfo;

    if (_currentState.isInitial) {
      _updateState(ClientFormStateModel.editing());
    }

    notifyListeners();
  }

  void _updateAddressInfo(AddressFormInfo newInfo) {
    _formData = _formData.copyWith(addressInfo: newInfo);
    _addressInfoNotifier.value = newInfo;

    if (_currentState.isInitial) {
      _updateState(ClientFormStateModel.editing());
    }

    notifyListeners();
  }

  void _updateTagsInfo(TagsFormInfo newInfo) {
    _formData = _formData.copyWith(tagsInfo: newInfo);
    _tagsInfoNotifier.value = newInfo;

    if (_currentState.isInitial) {
      _updateState(ClientFormStateModel.editing());
    }

    notifyListeners();
  }

  void _updateValidation(ClientFormValidation newValidation) {
    _formData = _formData.copyWith(validation: newValidation);
    _validationNotifier.value = newValidation;
    notifyListeners();
  }

  void _updateState(ClientFormStateModel newState) {
    // Validar transición de estado
    try {
      ClientFormStateTransitions.validateTransition(
          _currentState.state, newState.state);
    } catch (e) {
      debugPrint('⚠️ Transición de estado inválida: $e');
      return;
    }

    final previousState = _currentState;
    _currentState = newState;
    _stateNotifier.value = newState;

    // Logging para debug
    debugPrint(
        '🔄 Estado: ${previousState.state.name} → ${newState.state.name}');
    if (newState.message != null) {
      debugPrint('💬 Mensaje: ${newState.message}');
    }

    notifyListeners();
  }

  void _scheduleValidation(String field) {
    _validationTimer?.cancel();
    _validationTimer = Timer(_validationDebounce, () {
      _performFieldValidation(field);
    });
  }

  Future<void> _performFieldValidation(String field) async {
    _updateState(ClientFormStateModel.validating(field: field));

    ClientFormValidation validation = _formData.validation;

    try {
      switch (field) {
        case 'nombre':
          if (_formData.personalInfo.nombre.trim().isEmpty) {
            validation =
                validation.setFieldError('nombre', 'Nombre es requerido');
          } else {
            validation = validation.setFieldError('nombre', null);
          }
          break;

        case 'apellidos':
          if (_formData.personalInfo.apellidos.trim().isEmpty) {
            validation = validation.setFieldError(
                'apellidos', 'Apellidos son requeridos');
          } else {
            validation = validation.setFieldError('apellidos', null);
          }
          break;

        case 'email':
          final email = _formData.personalInfo.email.trim();
          if (email.isEmpty) {
            validation =
                validation.setFieldError('email', 'Email es requerido');
          } else if (!_isValidEmail(email)) {
            validation = validation.setFieldError('email', 'Email no válido');
          } else {
            // Validar email único en background
            _validateEmailUnique(email);
            validation = validation.setFieldError('email', null);
          }
          break;

        case 'telefono':
          final phone = _formData.personalInfo.telefono;
          if (phone.isEmpty) {
            validation =
                validation.setFieldError('telefono', 'Teléfono es requerido');
          } else if (!_isValidInternationalPhone(phone)) {
            validation = validation.setFieldError(
                'telefono', 'Formato de teléfono no válido');
          } else {
            validation = validation.setFieldError('telefono', null);
          }
          break;

        case 'codigoPostal':
          // ✅ FIX CRÍTICO: CP OPCIONAL
          final cp = _formData.addressInfo.codigoPostal.trim();
          if (cp.isNotEmpty && !_isValidCP(cp)) {
            validation = validation.setFieldError('codigoPostal',
                'Código postal debe tener 5 dígitos (opcional)');
          } else {
            validation = validation.setFieldError('codigoPostal', null);
          }
          break;

        // Agregar más validaciones según necesidad
      }

      _updateValidation(validation);
    } catch (e) {
      debugPrint('❌ Error en validación de campo $field: $e');
    }

    _updateState(ClientFormStateModel.editing());
  }

  Future<void> _performFullValidation() async {
    // Validar todos los campos requeridos
    ClientFormValidation validation = ClientFormValidation.empty();

    // Validar información personal
    if (_formData.personalInfo.nombre.trim().isEmpty) {
      validation = validation.setFieldError('nombre', 'Nombre es requerido');
    }
    if (_formData.personalInfo.apellidos.trim().isEmpty) {
      validation =
          validation.setFieldError('apellidos', 'Apellidos son requeridos');
    }
    if (!_isValidEmail(_formData.personalInfo.email)) {
      validation = validation.setFieldError('email', 'Email no válido');
    }
    if (!_isValidInternationalPhone(_formData.personalInfo.telefono)) {
      validation = validation.setFieldError('telefono', 'Teléfono no válido');
    }

    // ✅ FIX CRÍTICO: DIRECCIÓN COMPLETAMENTE OPCIONAL
    final hasAddressData = _formData.addressInfo.calle.trim().isNotEmpty ||
        _formData.addressInfo.numeroExterior.trim().isNotEmpty ||
        _formData.addressInfo.colonia.trim().isNotEmpty ||
        _formData.addressInfo.codigoPostal.trim().isNotEmpty ||
        _formData.addressInfo.alcaldia.trim().isNotEmpty;

    // Solo validar dirección si hay datos parciales
    if (hasAddressData) {
      if (_formData.addressInfo.calle.trim().isEmpty) {
        validation = validation.setFieldError(
            'calle', 'Si proporciona dirección, la calle es requerida');
      }
      if (_formData.addressInfo.numeroExterior.trim().isEmpty) {
        validation = validation.setFieldError('numeroExterior',
            'Si proporciona dirección, el número exterior es requerido');
      }
      if (_formData.addressInfo.colonia.trim().isEmpty) {
        validation = validation.setFieldError(
            'colonia', 'Si proporciona dirección, la colonia es requerida');
      }

      // ✅ FIX CRÍTICO: CP OPCIONAL INCLUSO CON DIRECCIÓN PARCIAL
      if (_formData.addressInfo.codigoPostal.trim().isNotEmpty &&
          !_isValidCP(_formData.addressInfo.codigoPostal)) {
        validation = validation.setFieldError(
            'codigoPostal', 'Código postal no válido (opcional)');
      }
    }

    _updateValidation(validation);
  }

  Future<void> _validateEmailUnique(String email) async {
    try {
      if (!_formData.isEditing) {
        final isUnique = await _formService.isEmailUnique(email);
        if (!isUnique) {
          final validation = _formData.validation
              .setFieldError('email', 'Este email ya está registrado');
          _updateValidation(validation);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error validando email único: $e');
    }
  }

  void _trackStateMetrics() {
    // Implementar tracking de métricas para analytics
    // Esto se puede usar para optimizar UX basado en comportamiento real
  }

  // ========================================================================
  // 🔧 MÉTODOS HELPER - ✅ FIX: SINTAXIS CORREGIDA
  // ========================================================================

  String _formatPhoneInternational(String phone) {
    // ✅ NUEVO: Mantener formato internacional
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Si es internacional (empieza con +), mantener formato
    if (cleaned.startsWith('+')) {
      return cleaned;
    }

    // Si es número mexicano de 10 dígitos, mantener sin +
    if (cleaned.length == 10) {
      return cleaned;
    }

    // Para otros casos, devolver limpio
    return cleaned.length <= 20 ? cleaned : cleaned.substring(0, 20);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim());
  }

  bool _isValidInternationalPhone(String phone) {
    // ✅ NUEVO: Validación internacional
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Validaciones básicas
    if (cleaned.isEmpty) return false;
    if (cleaned.length < 7) return false; // Mínimo 7 dígitos
    if (cleaned.length > 20) return false; // Máximo 20 dígitos

    // Números mexicanos tradicionales (10 dígitos)
    if (cleaned.length == 10 && !cleaned.startsWith('+')) {
      return true;
    }

    // Números internacionales (con +)
    if (cleaned.startsWith('+') &&
        cleaned.length >= 10 &&
        cleaned.length <= 15) {
      return true;
    }

    // Otros formatos válidos (7-15 dígitos sin +)
    if (cleaned.length >= 7 && cleaned.length <= 15) {
      return true;
    }

    return false;
  }

  bool _isValidCP(String cp) {
    final cleaned = cp.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length == 5;
  }

  bool _isFormEmpty() {
    return _formData.personalInfo.nombre.isEmpty &&
        _formData.personalInfo.apellidos.isEmpty &&
        _formData.personalInfo.email.isEmpty &&
        _formData.personalInfo.telefono.isEmpty &&
        _formData.addressInfo.calle.isEmpty &&
        _formData.tagsInfo.totalTags == 0;
  }

  @override
  void dispose() {
    _validationTimer?.cancel();
    _stateTimer?.cancel();

    _personalInfoNotifier.dispose();
    _addressInfoNotifier.dispose();
    _tagsInfoNotifier.dispose();
    _validationNotifier.dispose();
    _stateNotifier.removeListener(_trackStateMetrics);
    _stateNotifier.dispose();

    super.dispose();
  }
}
