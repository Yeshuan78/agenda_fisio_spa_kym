// [booking_flow_controller.dart] - ✅ ACTUALIZADO: Controlador apellidos agregado
// 📁 Ubicación: /lib/controllers/booking/booking_flow_controller.dart
// ✅ NUEVO: Controlador de apellidos para mejor estructura de datos cliente
// ✅ MANTIENE: Toda la lógica existente sin cambios

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/evento_model.dart';
import '../../models/empresa_model.dart';
import '../../enums/booking_types.dart';
import '../../enums/booking_enums.dart';

// ✅ SERVICIOS REFACTORIZADOS
import '../../services/booking/booking_configuration_service.dart';
import '../../services/booking/time_slot_generator_service.dart';
import '../../services/booking/booking_data_loader_service.dart';
import '../../services/booking/booking_validation_service.dart';
import '../../services/booking/booking_submission_service.dart';

// ✅ WIDGETS EXTRAÍDOS
import '../../widgets/booking/steps/client_type_selection_step.dart';
import '../../widgets/booking/steps/service_selection_step.dart';
import '../../widgets/booking/steps/datetime_selection_step.dart';
import '../../widgets/booking/steps/client_info_step.dart';

/// 🎛️ CONTROLADOR PRINCIPAL DEL FLUJO DE BOOKING
/// ✅ ACTUALIZADO: Con controlador de apellidos para mejor estructura cliente
/// ✅ MANTIENE: Toda la funcionalidad existente
class BookingFlowController extends ChangeNotifier {
  // 🎯 SERVICIOS
  late final BookingDataLoaderService _dataLoaderService;
  late final BookingSubmissionService _submissionService;

  // 🎯 CONFIGURACIÓN
  late BookingType _bookingType;
  late BookingConfiguration _configuration;

  // 🎯 ESTADO DEL FLUJO
  BookingFlowState _state = BookingFlowState.initializing;
  int _currentStep = 1;
  String? _errorMessage;

  // ✅ FIX: CALLBACK PARA NAVEGACIÓN
  Function(SubmissionResult)? _onSubmissionComplete;

  // 🎯 PARÁMETROS INICIALES
  String? _companyId;
  bool _isParticular = false;
  Map<String, String>? _queryParams;

  // 🎯 SELECCIONES DEL USUARIO
  String? _selectedEventId;
  String? _selectedServiceId;
  String? _selectedProfessionalId;
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _isExistingClient = false;

  // 🎯 CONTROLADORES DE FORMULARIO - ✅ ACTUALIZADO CON APELLIDOS
  late final Map<String, TextEditingController> _controllers;

  // 🎯 DATOS CARGADOS
  List<DocumentSnapshot> _eventos = [];
  List<Map<String, dynamic>> _serviciosDisponibles = [];
  List<DocumentSnapshot> _professionals = [];
  Map<String, dynamic>? _companyData;
  Map<String, dynamic>? _selectedEventData;
  EventoModel? _currentEvento;
  EmpresaModel? _currentEmpresa;

  // ✅ FIX: FLAGS PARA PREVENIR DOBLE ENVÍO
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _hasSubmitted = false;

  // ============================================================================
  // 🎯 CONSTRUCTOR Y INICIALIZACIÓN
  // ============================================================================

  BookingFlowController() {
    _initializeServices();
    _initializeControllers();
  }

  void _initializeServices() {
    _dataLoaderService = BookingDataLoaderService();
    _submissionService = BookingSubmissionService();
  }

  void _initializeControllers() {
    _controllers = {
      'nombre': TextEditingController(),
      'apellidos': TextEditingController(), // 🆕 NUEVO: Controlador apellidos
      'telefono': TextEditingController(),
      'email': TextEditingController(),
      'empleado': TextEditingController(),
      'direccion': TextEditingController(), // ✅ MANTENER PARA COMPATIBILIDAD

      // ✅ CONTROLADORES DE DIRECCIÓN INDEPENDIENTES
      'calle': TextEditingController(),
      'numeroExterior': TextEditingController(),
      'numeroInterior': TextEditingController(),
      'colonia': TextEditingController(),
      'codigoPostal': TextEditingController(),
      'alcaldia': TextEditingController(),
    };
  }

  // ============================================================================
  // 🎯 GETTERS PÚBLICOS (SIN CAMBIOS)
  // ============================================================================

  // Estado general
  BookingFlowState get state => _state;
  BookingType get bookingType => _bookingType;
  BookingConfiguration get configuration => _configuration;
  int get currentStep => _currentStep;
  String? get errorMessage => _errorMessage;

  // Datos
  List<DocumentSnapshot> get eventos => _eventos;
  List<Map<String, dynamic>> get serviciosDisponibles => _serviciosDisponibles;
  Map<String, dynamic>? get companyData => _companyData;
  Map<String, dynamic>? get selectedEventData => _selectedEventData;

  // Selecciones
  String? get selectedEventId => _selectedEventId;
  String? get selectedServiceId => _selectedServiceId;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedTime => _selectedTime;
  bool get isExistingClient => _isExistingClient;

  // Controladores
  Map<String, TextEditingController> get controllers => _controllers;

  // Estados
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get canGoBack => _currentStep > 1;
  bool get isInitialized => _state != BookingFlowState.initializing;

  // ✅ FIX: SETTER PARA CALLBACK DE NAVEGACIÓN
  void setSubmissionCallback(Function(SubmissionResult) callback) {
    _onSubmissionComplete = callback;
  }

  // ============================================================================
  // 🎯 MÉTODOS PRINCIPALES (SIN CAMBIOS)
  // ============================================================================

  /// 🚀 INICIALIZAR CONTROLADOR
  Future<void> initialize({
    String? companyId,
    bool isParticular = false,
    Map<String, String>? queryParams,
  }) async {
    try {
      debugPrint('🎛️ Inicializando BookingFlowController');

      _companyId = companyId;
      _isParticular = isParticular;
      _queryParams = queryParams;

      _updateState(BookingFlowState.loadingData);

      // Detectar y configurar tipo de booking
      _bookingType = BookingConfigurationService.detectBookingType(
        companyId: companyId,
        queryParams: queryParams,
        isParticular: isParticular,
      );

      _configuration =
          BookingConfigurationService.getConfiguration(_bookingType);
      debugPrint('🎯 Booking type configurado: ${_bookingType.name}');

      // Cargar datos iniciales
      await _loadInitialData();

      _updateState(BookingFlowState.ready);
      debugPrint('✅ BookingFlowController inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error inicializando BookingFlowController: $e');
      _updateState(BookingFlowState.error);
      _errorMessage = 'Error inicializando: $e';
    }
  }

  /// 📥 CARGAR DATOS INICIALES
  Future<void> _loadInitialData() async {
    _setLoading(true);

    try {
      final result = await _dataLoaderService.loadInitialData(
        bookingType: _bookingType,
        companyId: _companyId,
        queryParams: _queryParams,
      );

      if (result.isSuccess) {
        _currentEmpresa = result.empresa;
        _companyData = result.companyData;
        _currentEvento = result.evento;
        _selectedEventData = result.selectedEventData;
        _eventos = result.eventos;
        _serviciosDisponibles = result.serviciosDisponibles;
        _professionals = result.professionals;

        // Actualizar configuración con datos cargados
        _configuration = BookingConfigurationService.getConfiguration(
          _bookingType,
          selectedEventData: _selectedEventData,
          companyData: _companyData,
        );

        debugPrint('✅ Datos iniciales cargados correctamente');
      } else {
        throw Exception(result.error ?? 'Error cargando datos');
      }
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================================
  // 🎯 NAVEGACIÓN ENTRE PASOS (SIN CAMBIOS)
  // ============================================================================

  /// ➡️ SIGUIENTE PASO
  void nextStep() {
    if (_currentStep < _configuration.totalSteps) {
      _currentStep++;
      notifyListeners();
      debugPrint('📱 Navegando al paso $_currentStep');
    }
  }

  /// ⬅️ PASO ANTERIOR
  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
      debugPrint('📱 Regresando al paso $_currentStep');
    }
  }

  /// 🎯 IR A PASO ESPECÍFICO
  void goToStep(int step) {
    if (step >= 1 && step <= _configuration.totalSteps) {
      _currentStep = step;
      notifyListeners();
      debugPrint('📱 Navegando al paso $_currentStep');
    }
  }

  // ============================================================================
  // 🎯 HANDLERS DE SELECCIONES (SIN CAMBIOS)
  // ============================================================================

  /// 👤 SELECCIONAR TIPO DE CLIENTE
  void selectClientType(bool isExisting) {
    _isExistingClient = isExisting;
    nextStep();
    debugPrint(
        '👤 Tipo de cliente seleccionado: ${isExisting ? 'Existente' : 'Nuevo'}');
  }

  /// 🛍️ SELECCIONAR SERVICIO
  void selectService(String serviceId) {
    _selectedServiceId = serviceId;

    // Buscar datos del servicio seleccionado
    final service = _serviciosDisponibles.firstWhere(
      (s) => s['id'] == serviceId,
      orElse: () => {},
    );

    if (service['profesionalAsignado'] != null) {
      _selectedProfessionalId = service['profesionalAsignado'];
    }

    // Navegar al siguiente paso
    nextStep();

    debugPrint('🛍️ Servicio seleccionado: $serviceId');
    notifyListeners();
  }

  /// 📅 SELECCIONAR EVENTO
  void selectEvent(String eventId) {
    _selectedEventId = eventId;
    _selectedServiceId = null;
    _serviciosDisponibles = [];

    debugPrint('📅 Evento seleccionado: $eventId');

    // Cargar servicios del evento
    _loadServicesFromEvent(eventId);
    notifyListeners();
  }

  /// 📅 SELECCIONAR FECHA
  void selectDate(DateTime date) {
    _selectedDate = date;
    debugPrint('📅 Fecha seleccionada: ${date.toIso8601String()}');
    notifyListeners();
  }

  /// ⏰ SELECCIONAR HORARIO
  void selectTime(String time) {
    _selectedTime = time;
    nextStep();
    debugPrint('⏰ Horario seleccionado: $time');
    notifyListeners();
  }

  // ============================================================================
  // 🎯 GENERACIÓN DE DATOS DINÁMICOS (SIN CAMBIOS)
  // ============================================================================

  /// ⏰ GENERAR TIME SLOTS - ✅ FIX CRÍTICO PARA ACTIVAR PESTAÑAS EN PARTICULAR
  List<String> generateTimeSlots() {
    // ✅ FIX CRÍTICO: Si es PARTICULAR, DEVOLVER LISTA VACÍA para activar pestañas
    if (_bookingType == BookingType.particular) {
      debugPrint('🏠 Modo PARTICULAR: Lista vacía = ACTIVA PESTAÑAS PREMIUM');
      return []; // ✅ Lista vacía = usar pestañas en datetime_selection_step
    }

    // ✅ Para EMPRESA/EVENTO: generar time slots tradicionales
    debugPrint('🏢 Modo EMPRESA/EVENTO: Generando time slots tradicionales');
    final slots = TimeSlotGeneratorService.generateTimeSlots(
      currentEvento: _currentEvento,
      selectedServiceId: _selectedServiceId,
      serviciosDisponibles: _serviciosDisponibles,
      date: _selectedDate,
    );

    debugPrint('🕒 Time slots generados: ${slots.length} - $slots');
    return slots;
  }

  /// 🔍 HELPER: Verificar si es modo PARTICULAR
  bool get isParticularMode => _bookingType == BookingType.particular;

  /// 🎨 OBTENER WIDGET DEL PASO ACTUAL - ✅ ACTUALIZADO CON APELLIDOS
  Widget getCurrentStepWidget() {
    if (_configuration.showClientTypeStep && _currentStep == 1) {
      return ClientTypeSelectionStep(
        accentColor: _configuration.accentColor,
        onClientTypeSelected: selectClientType,
      );
    }

    final adjustedStep =
        _configuration.showClientTypeStep ? _currentStep - 1 : _currentStep;

    switch (adjustedStep) {
      case 1:
        return ServiceSelectionStep(
          accentColor: _configuration.accentColor,
          showPricing: _configuration.showPricing,
          selectedEventData: _selectedEventData,
          eventos: _eventos,
          selectedEventId: _selectedEventId,
          selectedServiceId: _selectedServiceId,
          serviciosDisponibles: _serviciosDisponibles,
          onEventSelected: selectEvent,
          onServiceSelected: selectService,
        );
      case 2:
        // ✅ FIX CRÍTICO: Pasar time slots (vacío para particular = activa pestañas)
        final timeSlots = generateTimeSlots();
        debugPrint(
            '🎛️ Pasando time slots al DateTimeSelectionStep: ${timeSlots.length}');

        return DateTimeSelectionStep(
          accentColor: _configuration.accentColor,
          selectedEventData: _selectedEventData,
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          timeSlots: timeSlots, // ✅ FIX: Lista vacía para particular
          onDateSelected: selectDate,
          onTimeSelected: selectTime,
        );
      case 3:
        return ClientInfoStep(
          accentColor: _configuration.accentColor,
          isExistingClient: _isExistingClient,
          bookingType: _bookingType,
          requiresAddress: _configuration.requiresAddress,
          isSubmitting: _isSubmitting,
          nombreController: _controllers['nombre']!,
          telefonoController: _controllers['telefono']!,
          emailController: _controllers['email']!,
          empleadoController: _controllers['empleado']!,

          // ✅ CONTROLADORES DE DIRECCIÓN INDEPENDIENTES
          calleController: _controllers['calle']!,
          numeroExteriorController: _controllers['numeroExterior']!,
          numeroInteriorController: _controllers['numeroInterior']!,
          coloniaController: _controllers['colonia']!,
          codigoPostalController: _controllers['codigoPostal']!,
          alcaldiaController: _controllers['alcaldia']!,

          onSubmit: submitBooking,
        );
      default:
        return Container(
          child: Text('Paso no definido: $adjustedStep'),
        );
    }
  }

  // ============================================================================
  // 🎯 VALIDACIÓN Y ENVÍO (SIN CAMBIOS EN LÓGICA)
  // ============================================================================

  /// ✅ VALIDAR FORMULARIO
  bool validateCurrentStep() {
    // ✅ Construir datos completos para validación
    final formData = _buildFormData();
    final selectionData = _buildSelectionData();

    final validation = BookingValidationService.validateBookingForm(
      bookingType: _bookingType,
      isExistingClient: _isExistingClient,
      controllers: _controllers,
      selectedServiceId: _selectedServiceId,
      selectedTime: _selectedTime,
      selectedDate: _selectedDate,
      selectedEventData: _selectedEventData,
    );

    if (!validation.isValid) {
      _errorMessage = validation.message;
      notifyListeners();
      debugPrint('❌ Validación fallida: ${validation.message}');
      return false;
    }

    // ✅ Validación adicional con datos completos
    final completeData = {...formData, ...selectionData};
    final submissionValidation =
        BookingValidationService.validateBeforeSubmission(
      bookingType: _bookingType,
      bookingData: completeData,
    );

    if (!submissionValidation.isValid) {
      _errorMessage = submissionValidation.message;
      notifyListeners();
      debugPrint(
          '❌ Validación de envío fallida: ${submissionValidation.message}');
      return false;
    }

    _errorMessage = null;
    debugPrint('✅ Validación completa exitosa');
    return true;
  }

  /// 📤 ENVIAR BOOKING - ✅ FIX CRÍTICO APLICADO
  Future<SubmissionResult?> submitBooking() async {
    // ✅ FIX: PREVENIR DOBLE ENVÍO
    if (_hasSubmitted || _isSubmitting) {
      debugPrint('⚠️ Envío ya en progreso o completado, ignorando...');
      return null;
    }

    debugPrint('📤 Iniciando submitBooking()');
    debugPrint('   - Booking type: ${_bookingType.name}');
    debugPrint('   - Current step: $_currentStep');
    debugPrint('   - Selected service: $_selectedServiceId');
    debugPrint('   - Selected date: $_selectedDate');
    debugPrint('   - Selected time: $_selectedTime');

    if (!validateCurrentStep()) {
      debugPrint('❌ Validación fallida en submitBooking');
      return null;
    }

    // ✅ FIX: MARCAR COMO ENVIADO INMEDIATAMENTE
    _hasSubmitted = true;
    _updateState(BookingFlowState.submitting);
    _setSubmitting(true);

    try {
      final formData = _buildFormData();
      final selectionData = _buildSelectionData();

      debugPrint('📋 Datos para envío:');
      debugPrint('   - Form data keys: ${formData.keys.toList()}');
      debugPrint('   - Selection data keys: ${selectionData.keys.toList()}');
      debugPrint('   - fechaInicio calculada: ${selectionData['fechaInicio']}');

      final result = await _submissionService.submitBooking(
        bookingType: _bookingType,
        formData: formData,
        selectionData: selectionData,
        eventData: _selectedEventData,
        companyData: _companyData,
      );

      if (result.isSuccess) {
        _updateState(BookingFlowState.completed);
        debugPrint('✅ Booking enviado exitosamente: ${result.bookingId}');

        // ✅ FIX CRÍTICO: EJECUTAR CALLBACK DE NAVEGACIÓN
        if (_onSubmissionComplete != null) {
          debugPrint('🔄 Ejecutando callback de navegación...');
          _onSubmissionComplete!(result);
        } else {
          debugPrint('⚠️ No hay callback de navegación configurado');
        }
      } else {
        _updateState(BookingFlowState.error);
        _errorMessage = result.error;
        _hasSubmitted = false; // ✅ Permitir reintento
        debugPrint('❌ Error enviando booking: ${result.error}');
      }

      return result;
    } catch (e) {
      _updateState(BookingFlowState.error);
      _errorMessage = 'Error al crear la cita: $e';
      _hasSubmitted = false; // ✅ Permitir reintento
      debugPrint('❌ Excepción enviando booking: $e');
      return null;
    } finally {
      _setSubmitting(false);
    }
  }

  // ============================================================================
  // 🎯 MÉTODOS PRIVADOS
  // ============================================================================

  /// 🔄 ACTUALIZAR ESTADO
  void _updateState(BookingFlowState newState) {
    _state = newState;
    notifyListeners();
  }

  /// ⏳ ESTABLECER LOADING
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 📤 ESTABLECER SUBMITTING
  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  /// 📋 CONSTRUIR DATOS DEL FORMULARIO - ✅ ACTUALIZADO CON APELLIDOS
  Map<String, dynamic> _buildFormData() {
    return {
      'clienteId': null,
      'nombreCliente': _controllers['nombre']?.text.trim(),
      'apellidosCliente': _controllers['apellidos']?.text.trim(), // 🆕 NUEVO
      'clientEmail': _controllers['email']?.text.trim(),
      'clientPhone': _controllers['telefono']?.text.trim(),
      'numeroEmpleado': _controllers['empleado']?.text.trim(),
      'direccion': _controllers['direccion']?.text.trim(),
      'isExistingClient': _isExistingClient,

      // ✅ CAMPOS DE DIRECCIÓN INDEPENDIENTES
      'calle': _controllers['calle']?.text.trim(),
      'numeroExterior': _controllers['numeroExterior']?.text.trim(),
      'numeroInterior': _controllers['numeroInterior']?.text.trim(),
      'colonia': _controllers['colonia']?.text.trim(),
      'codigoPostal': _controllers['codigoPostal']?.text.trim(),
      'alcaldia': _controllers['alcaldia']?.text.trim(),
    };
  }

  /// 🎯 CONSTRUIR DATOS DE SELECCIÓN (SIN CAMBIOS)
  Map<String, dynamic> _buildSelectionData() {
    // ✅ FIX: Calcular fechaInicio ANTES de enviar
    DateTime? fechaInicio;

    if (_selectedDate != null && _selectedTime != null) {
      final timeParts = _selectedTime!.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 9;
      final minute =
          int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;

      fechaInicio = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        hour,
        minute,
      );
    } else if (_selectedEventData != null && _selectedTime != null) {
      // Para eventos, usar fecha del evento
      final eventDate = (_selectedEventData!['fecha'] as Timestamp).toDate();
      final timeParts = _selectedTime!.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 9;
      final minute =
          int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;

      fechaInicio = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        hour,
        minute,
      );
    }

    return {
      // ✅ Datos de selección principales
      'selectedServiceId': _selectedServiceId,
      'servicioId': _selectedServiceId,
      'selectedProfessionalId': _selectedProfessionalId,
      'selectedTime': _selectedTime,
      'selectedDate': _selectedDate,
      'selectedEventId': _selectedEventId,
      'originalPrice': _getOriginalPrice(),

      // ✅ FIX: Incluir fechaInicio calculada
      'fechaInicio': fechaInicio,

      // ✅ Datos adicionales para compatibilidad
      'servicioNombre': _getSelectedServiceName(),
      'profesionalNombre': _getSelectedProfessionalName(),
      'duracion': _getSelectedServiceDuration(),
    };
  }

  /// 💰 OBTENER PRECIO ORIGINAL
  int _getOriginalPrice() {
    final service = _serviciosDisponibles.firstWhere(
      (s) => s['id'] == _selectedServiceId,
      orElse: () => {'price': 0},
    );
    return service['price'] ?? 0;
  }

  /// 🎯 OBTENER NOMBRE DEL SERVICIO SELECCIONADO
  String? _getSelectedServiceName() {
    if (_selectedServiceId == null) return null;

    final service = _serviciosDisponibles.firstWhere(
      (s) => s['id'] == _selectedServiceId,
      orElse: () => {},
    );

    return service['name'];
  }

  /// 👨‍⚕️ OBTENER NOMBRE DEL PROFESIONAL SELECCIONADO
  String? _getSelectedProfessionalName() {
    if (_selectedProfessionalId == null) return null;

    // Buscar en servicios asignados primero
    final service = _serviciosDisponibles.firstWhere(
      (s) => s['profesionalAsignado'] == _selectedProfessionalId,
      orElse: () => {},
    );

    if (service['profesionalNombre'] != null) {
      return service['profesionalNombre'];
    }

    // Buscar en lista de profesionales
    try {
      final professional = _professionals.firstWhere(
        (p) => p.id == _selectedProfessionalId,
      );

      if (professional.data() != null) {
        final data = professional.data() as Map<String, dynamic>;
        return '${data['nombre'] ?? ''} ${data['apellidos'] ?? ''}'.trim();
      }
    } catch (e) {
      // No encontrado, continuar
    }

    return null;
  }

  /// ⏱️ OBTENER DURACIÓN DEL SERVICIO SELECCIONADO
  int _getSelectedServiceDuration() {
    if (_selectedServiceId == null) return 60;

    final service = _serviciosDisponibles.firstWhere(
      (s) => s['id'] == _selectedServiceId,
      orElse: () => {'duration': 60},
    );

    return service['duration'] ?? 60;
  }

  /// 📅 CARGAR SERVICIOS DEL EVENTO
  Future<void> _loadServicesFromEvent(String eventId) async {
    try {
      final event = await _dataLoaderService.loadSpecificEvent(eventId);
      if (event.isSuccess) {
        _serviciosDisponibles = event.serviciosDisponibles;
        notifyListeners();
        debugPrint(
            '✅ Servicios del evento cargados: ${_serviciosDisponibles.length}');
      }
    } catch (e) {
      debugPrint('❌ Error cargando servicios del evento: $e');
    }
  }

  /// 🔄 REINICIAR CONTROLADOR
  void reset() {
    _currentStep = 1;
    _state = BookingFlowState.initializing;
    _selectedEventId = null;
    _selectedServiceId = null;
    _selectedDate = null;
    _selectedTime = null;
    _isExistingClient = false;
    _errorMessage = null;
    _hasSubmitted = false; // ✅ FIX: Reiniciar flag

    // Limpiar controladores
    for (final controller in _controllers.values) {
      controller.clear();
    }

    notifyListeners();
    debugPrint('🔄 BookingFlowController reiniciado');
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
    debugPrint('🧹 BookingFlowController disposed');
  }
}
