// [booking_validation_service.dart] - SERVICIO DE VALIDACIÓN DE BOOKING - ✅ FIX CLIENTE EXISTENTE COMPLETO
// 📁 Ubicación: /lib/services/booking/booking_validation_service.dart
// 🎯 OBJETIVO: Centralizar toda la lógica de validación de forms y datos

import 'package:flutter/material.dart';
import '../../enums/booking_types.dart';

/// ✅ SERVICIO DE VALIDACIÓN DE BOOKING
/// Centraliza toda la lógica de validación de formularios y datos
class BookingValidationService {
  /// 📋 VALIDAR FORMULARIO PRINCIPAL - ✅ FIX APLICADO
  /// Extraído de: public_booking_screen.dart línea ~750-800
  static ValidationResult validateBookingForm({
    required BookingType bookingType,
    required bool isExistingClient,
    required Map<String, TextEditingController> controllers,
    String? selectedServiceId,
    String? selectedTime,
    DateTime? selectedDate,
    Map<String, dynamic>? selectedEventData,
  }) {
    try {
      debugPrint('📋 Validando formulario de booking:');
      debugPrint('   - Booking type: ${bookingType.name}');
      debugPrint('   - Cliente existente: $isExistingClient');
      debugPrint('   - Servicio: $selectedServiceId');
      debugPrint('   - Fecha: $selectedDate');
      debugPrint('   - Hora: $selectedTime');
      debugPrint('   - Evento: ${selectedEventData?['nombre'] ?? 'N/A'}');

      // 🎯 Validar selecciones básicas
      if (selectedServiceId == null || selectedServiceId.isEmpty) {
        return ValidationResult.error('Por favor selecciona un servicio');
      }

      if (selectedTime == null || selectedTime.isEmpty) {
        return ValidationResult.error('Por favor selecciona un horario');
      }

      if (!isValidTimeSlot(selectedTime)) {
        return ValidationResult.error('Formato de horario inválido');
      }

      // 📅 Validar fecha (solo si no es evento específico)
      if (selectedEventData == null && selectedDate == null) {
        return ValidationResult.error('Por favor selecciona una fecha');
      }

      // ✅ Validar fecha si está disponible
      if (selectedDate != null && !isValidBookingDate(selectedDate)) {
        return ValidationResult.error('Fecha seleccionada inválida');
      }

      // 👤 Validar información del cliente
      final clientValidation = validateClientInfo(
        bookingType: bookingType,
        isExistingClient: isExistingClient,
        controllers: controllers,
      );

      if (!clientValidation.isValid) {
        debugPrint(
            '❌ Validación de cliente fallida: ${clientValidation.message}');
        return clientValidation;
      }

      debugPrint('✅ Formulario de booking válido');
      return ValidationResult.success('Formulario válido');
    } catch (e) {
      debugPrint('❌ Error en validación del formulario: $e');
      return ValidationResult.error('Error de validación interno: $e');
    }
  }

  /// 👤 VALIDAR INFORMACIÓN DEL CLIENTE
  static ValidationResult validateClientInfo({
    required BookingType bookingType,
    required bool isExistingClient,
    required Map<String, TextEditingController> controllers,
  }) {
    try {
      if (isExistingClient) {
        // 🔍 Validación para clientes existentes
        return _validateExistingClient(bookingType, controllers);
      } else {
        // 🆕 Validación para clientes nuevos
        return _validateNewClient(bookingType, controllers);
      }
    } catch (e) {
      debugPrint('❌ Error validando información de cliente: $e');
      return ValidationResult.error('Error de validación de cliente');
    }
  }

  /// 🔍 VALIDAR CLIENTE EXISTENTE
  static ValidationResult _validateExistingClient(
    BookingType bookingType,
    Map<String, TextEditingController> controllers,
  ) {
    switch (bookingType) {
      case BookingType.enterprise:
        // Enterprise: Solo número de empleado
        final empleado = controllers['empleado']?.text.trim() ?? '';
        if (empleado.isEmpty) {
          return ValidationResult.error('Ingresa tu número de empleado');
        }
        if (!isValidEmployeeNumber(empleado)) {
          return ValidationResult.error('Número de empleado inválido');
        }
        break;

      case BookingType.corporate:
      case BookingType.particular:
        // Corporate/Particular: Teléfono registrado
        final telefono = controllers['telefono']?.text.trim() ?? '';
        if (telefono.isEmpty) {
          return ValidationResult.error('Ingresa tu teléfono registrado');
        }
        if (!isValidPhoneNumber(telefono)) {
          return ValidationResult.error('Formato de teléfono inválido');
        }
        break;
    }

    return ValidationResult.success('Cliente existente válido');
  }

  /// 🆕 VALIDAR CLIENTE NUEVO
  static ValidationResult _validateNewClient(
    BookingType bookingType,
    Map<String, TextEditingController> controllers,
  ) {
    // 📝 Campos básicos requeridos
    final nombre = controllers['nombre']?.text.trim() ?? '';
    final telefono = controllers['telefono']?.text.trim() ?? '';

    if (nombre.isEmpty) {
      return ValidationResult.error('El nombre es requerido');
    }

    if (!isValidName(nombre)) {
      return ValidationResult.error('Formato de nombre inválido');
    }

    if (telefono.isEmpty) {
      return ValidationResult.error('El teléfono es requerido');
    }

    if (!isValidPhoneNumber(telefono)) {
      return ValidationResult.error('Formato de teléfono inválido');
    }

    // 🎯 Validaciones específicas por tipo
    switch (bookingType) {
      case BookingType.enterprise:
        // Enterprise: Número de empleado requerido
        final empleado = controllers['empleado']?.text.trim() ?? '';
        if (empleado.isEmpty) {
          return ValidationResult.error('El número de empleado es requerido');
        }
        if (!isValidEmployeeNumber(empleado)) {
          return ValidationResult.error('Número de empleado inválido');
        }
        break;

      case BookingType.corporate:
      case BookingType.particular:
        // Corporate/Particular: Email requerido
        final email = controllers['email']?.text.trim() ?? '';
        if (email.isEmpty) {
          return ValidationResult.error('El email es requerido');
        }
        if (!isValidEmail(email)) {
          return ValidationResult.error('Formato de email inválido');
        }
        break;
    }

    // 🏠 Validar dirección para particulares (si se requiere)
    if (bookingType == BookingType.particular) {
      final direccion = controllers['direccion']?.text.trim() ?? '';
      // La dirección es opcional para particulares, pero si se proporciona debe ser válida
      if (direccion.isNotEmpty && !isValidAddress(direccion)) {
        return ValidationResult.error('Formato de dirección inválido');
      }
    }

    return ValidationResult.success('Cliente nuevo válido');
  }

  /// 📱 VALIDAR NÚMERO DE TELÉFONO
  static bool isValidPhoneNumber(String phone) {
    if (phone.isEmpty) return false;

    // Remover espacios y caracteres especiales
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Debe tener entre 10 y 15 dígitos
    return cleanPhone.length >= 10 && cleanPhone.length <= 15;
  }

  /// 📧 VALIDAR EMAIL
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    return emailRegex.hasMatch(email);
  }

  /// 👤 VALIDAR NOMBRE
  static bool isValidName(String name) {
    if (name.isEmpty) return false;

    // Debe tener al menos 2 caracteres y solo letras y espacios
    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]{2,}$');

    return nameRegex.hasMatch(name.trim());
  }

  /// 🏢 VALIDAR NÚMERO DE EMPLEADO
  static bool isValidEmployeeNumber(String employeeNumber) {
    if (employeeNumber.isEmpty) return false;

    // Debe ser numérico y tener entre 3 y 10 dígitos
    final cleanNumber = employeeNumber.replaceAll(RegExp(r'[^\d]'), '');

    return cleanNumber.length >= 3 && cleanNumber.length <= 10;
  }

  /// 🏠 VALIDAR DIRECCIÓN
  static bool isValidAddress(String address) {
    if (address.isEmpty) return false;

    // Debe tener al menos 10 caracteres y contener letras y números
    return address.trim().length >= 10 &&
        address.contains(RegExp(r'[a-zA-Z]')) &&
        address.contains(RegExp(r'[0-9]'));
  }

  /// ⏰ VALIDAR HORARIO
  static bool isValidTimeSlot(String timeSlot) {
    if (timeSlot.isEmpty) return false;

    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return timeRegex.hasMatch(timeSlot);
  }

  /// 📅 VALIDAR FECHA
  static bool isValidBookingDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    // No puede ser en el pasado
    if (selectedDate.isBefore(today)) {
      return false;
    }

    // No puede ser más de 60 días en el futuro
    final maxDate = today.add(const Duration(days: 60));
    if (selectedDate.isAfter(maxDate)) {
      return false;
    }

    return true;
  }

  /// 📅 VALIDAR FECHA Y HORA DE BOOKING - ✅ NUEVO MÉTODO
  static bool isValidBookingDateTime(DateTime dateTime) {
    final now = DateTime.now();

    // No puede ser en el pasado (con 1 hora de tolerancia)
    if (dateTime.isBefore(now.subtract(const Duration(hours: 1)))) {
      debugPrint('❌ Fecha en el pasado: $dateTime vs $now');
      return false;
    }

    // No puede ser más de 60 días en el futuro
    final maxDate = now.add(const Duration(days: 60));
    if (dateTime.isAfter(maxDate)) {
      debugPrint('❌ Fecha muy lejana: $dateTime vs $maxDate');
      return false;
    }

    // Validar horario de trabajo (opcional)
    final hour = dateTime.hour;
    if (hour < 7 || hour > 22) {
      debugPrint('⚠️ Horario fuera de rango laboral: $hour');
      // No es error fatal, solo advertencia
    }

    debugPrint('✅ Fecha y hora válida: $dateTime');
    return true;
  }

  /// 🔒 VALIDAR CONFIGURACIÓN DE BOOKING
  static ValidationResult validateBookingConfiguration({
    required BookingType bookingType,
    String? companyId,
    String? eventId,
    Map<String, String>? queryParams,
  }) {
    switch (bookingType) {
      case BookingType.enterprise:
        if (companyId == null || companyId.isEmpty) {
          return ValidationResult.error(
              'ID de empresa requerido para booking enterprise');
        }
        if (eventId == null || eventId.isEmpty) {
          return ValidationResult.error(
              'ID de evento requerido para booking enterprise');
        }
        break;

      case BookingType.corporate:
        if (eventId == null || eventId.isEmpty) {
          return ValidationResult.error(
              'ID de evento requerido para booking corporate');
        }
        break;

      case BookingType.particular:
        // No requiere validaciones específicas
        break;
    }

    return ValidationResult.success('Configuración de booking válida');
  }

  /// 🎯 VALIDAR PASO ESPECÍFICO
  static ValidationResult validateStep({
    required int currentStep,
    required BookingType bookingType,
    required Map<String, dynamic> stepData,
  }) {
    switch (currentStep) {
      case 1:
        return _validateStepOne(bookingType, stepData);
      case 2:
        return _validateStepTwo(bookingType, stepData);
      case 3:
        return _validateStepThree(bookingType, stepData);
      case 4:
        return _validateStepFour(bookingType, stepData);
      default:
        return ValidationResult.error('Paso inválido');
    }
  }

  /// 1️⃣ VALIDAR PASO 1: TIPO DE CLIENTE
  static ValidationResult _validateStepOne(
    BookingType bookingType,
    Map<String, dynamic> stepData,
  ) {
    // Para enterprise no hay selección de tipo de cliente
    if (bookingType == BookingType.enterprise) {
      return ValidationResult.success('Paso 1 válido (enterprise)');
    }

    final isExistingClient = stepData['isExistingClient'] as bool?;
    if (isExistingClient == null) {
      return ValidationResult.error(
          'Selecciona si eres cliente registrado o nuevo');
    }

    return ValidationResult.success('Tipo de cliente seleccionado');
  }

  /// 2️⃣ VALIDAR PASO 2: SELECCIÓN DE SERVICIO
  static ValidationResult _validateStepTwo(
    BookingType bookingType,
    Map<String, dynamic> stepData,
  ) {
    final selectedServiceId = stepData['selectedServiceId'] as String?;

    if (selectedServiceId == null || selectedServiceId.isEmpty) {
      return ValidationResult.error('Selecciona un servicio');
    }

    // Para eventos corporativos, validar que se haya seleccionado evento
    if (bookingType == BookingType.corporate) {
      final selectedEventId = stepData['selectedEventId'] as String?;
      if (selectedEventId == null || selectedEventId.isEmpty) {
        return ValidationResult.error('Selecciona un evento');
      }
    }

    return ValidationResult.success('Servicio seleccionado');
  }

  /// 3️⃣ VALIDAR PASO 3: FECHA Y HORARIO
  static ValidationResult _validateStepThree(
    BookingType bookingType,
    Map<String, dynamic> stepData,
  ) {
    final selectedTime = stepData['selectedTime'] as String?;

    if (selectedTime == null || selectedTime.isEmpty) {
      return ValidationResult.error('Selecciona un horario');
    }

    if (!isValidTimeSlot(selectedTime)) {
      return ValidationResult.error('Horario inválido');
    }

    // Para particulares, validar fecha seleccionada
    if (bookingType == BookingType.particular) {
      final selectedDate = stepData['selectedDate'] as DateTime?;
      if (selectedDate == null) {
        return ValidationResult.error('Selecciona una fecha');
      }
      if (!isValidBookingDate(selectedDate)) {
        return ValidationResult.error('Fecha inválida');
      }
    }

    return ValidationResult.success('Fecha y horario válidos');
  }

  /// 4️⃣ VALIDAR PASO 4: INFORMACIÓN DEL CLIENTE
  static ValidationResult _validateStepFour(
    BookingType bookingType,
    Map<String, dynamic> stepData,
  ) {
    final isExistingClient = stepData['isExistingClient'] as bool? ?? false;
    final controllers =
        stepData['controllers'] as Map<String, TextEditingController>? ?? {};

    return validateClientInfo(
      bookingType: bookingType,
      isExistingClient: isExistingClient,
      controllers: controllers,
    );
  }

  /// 🛡️ SANITIZAR ENTRADA DE TEXTO
  static String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'''[<>"']'''), '') // Remover caracteres peligrosos
        .replaceAll(RegExp(r'\s+'), ' '); // Normalizar espacios
  }

  /// 📱 FORMATEAR NÚMERO DE TELÉFONO
  static String formatPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length == 10) {
      return '${cleanPhone.substring(0, 2)} ${cleanPhone.substring(2, 6)} ${cleanPhone.substring(6)}';
    } else if (cleanPhone.length == 12 && cleanPhone.startsWith('52')) {
      return '+52 ${cleanPhone.substring(2, 4)} ${cleanPhone.substring(4, 8)} ${cleanPhone.substring(8)}';
    }

    return phone; // Retornar original si no se puede formatear
  }

  /// 📧 NORMALIZAR EMAIL
  static String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// 👤 CAPITALIZAR NOMBRE
  static String capitalizeName(String name) {
    return name
        .trim()
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' '); // Remover espacios extra
  }

  /// 🔍 VALIDAR DATOS ANTES DE ENVÍO - ✅ FIX CLIENTE EXISTENTE APLICADO
  static ValidationResult validateBeforeSubmission({
    required BookingType bookingType,
    required Map<String, dynamic> bookingData,
  }) {
    try {
      debugPrint('🔍 Validando datos antes de envío:');
      debugPrint('   - Booking type: ${bookingType.name}');
      debugPrint('   - Datos disponibles: ${bookingData.keys.toList()}');
      debugPrint(
          '   - Es cliente existente: ${bookingData['isExistingClient']}');

      // ✅ FIX: Validar fechaInicio con múltiples fuentes
      final fechaInicio = bookingData['fechaInicio'] as DateTime?;

      if (fechaInicio == null) {
        // ✅ Intentar construir fechaInicio desde selectedDate y selectedTime
        final selectedDate = bookingData['selectedDate'] as DateTime?;
        final selectedTime = bookingData['selectedTime'] as String?;

        if (selectedDate != null && selectedTime != null) {
          debugPrint(
              '⚠️ fechaInicio null, pero se puede construir desde selectedDate y selectedTime');
          // No es error fatal si se puede construir
        } else {
          debugPrint('❌ fechaInicio faltante y no se puede construir');
          return ValidationResult.error('Fecha y hora de la cita requeridas');
        }
      } else {
        debugPrint('✅ fechaInicio encontrada: $fechaInicio');
      }

      // ✅ FIX CRÍTICO: Obtener campos requeridos con lógica de cliente existente
      final isExistingClient =
          bookingData['isExistingClient'] as bool? ?? false;
      final requiredFields = _getRequiredFieldsForSubmission(bookingType,
          isExistingClient: isExistingClient);
      debugPrint('📋 Campos requeridos: $requiredFields');
      debugPrint('📋 Es cliente existente: $isExistingClient');

      for (final field in requiredFields) {
        // ✅ FIX: Skip fechaInicio si se puede construir
        if (field == 'fechaInicio' && fechaInicio == null) {
          final selectedDate = bookingData['selectedDate'] as DateTime?;
          final selectedTime = bookingData['selectedTime'] as String?;
          if (selectedDate != null && selectedTime != null) {
            debugPrint(
                '✅ fechaInicio se puede construir - skipping validation');
            continue;
          }
        }

        final value = bookingData[field];
        if (value == null || (value is String && value.trim().isEmpty)) {
          debugPrint('❌ Campo requerido faltante: $field (valor: $value)');
          return ValidationResult.error('Campo requerido faltante: $field');
        } else {
          debugPrint(
              '✅ Campo $field válido: ${value.toString().length > 50 ? value.toString().substring(0, 50) + '...' : value}');
        }
      }

      // Validaciones específicas de formato
      if (bookingData['clientPhone'] != null) {
        if (!isValidPhoneNumber(bookingData['clientPhone'])) {
          return ValidationResult.error('Formato de teléfono inválido');
        }
      }

      if (bookingData['clientEmail'] != null &&
          bookingData['clientEmail'].toString().trim().isNotEmpty) {
        if (!isValidEmail(bookingData['clientEmail'])) {
          return ValidationResult.error('Formato de email inválido');
        }
      }

      // ✅ Validar fecha si está disponible
      if (fechaInicio != null) {
        if (!isValidBookingDateTime(fechaInicio)) {
          return ValidationResult.error('Fecha y hora de cita inválida');
        }
      }

      debugPrint('✅ Validación antes de envío exitosa');
      return ValidationResult.success('Datos válidos para envío');
    } catch (e) {
      debugPrint('❌ Error validando datos antes de envío: $e');
      return ValidationResult.error('Error de validación interno: $e');
    }
  }

  /// 📋 OBTENER CAMPOS REQUERIDOS PARA ENVÍO - ✅ FIX CLIENTE EXISTENTE APLICADO
  static List<String> _getRequiredFieldsForSubmission(
    BookingType bookingType, {
    bool isExistingClient = false,
  }) {
    debugPrint('📋 Determinando campos requeridos:');
    debugPrint('   - Booking type: ${bookingType.name}');
    debugPrint('   - Es cliente existente: $isExistingClient');

    // ✅ FIX CRÍTICO: LÓGICA DIFERENTE PARA CLIENTES EXISTENTES
    if (isExistingClient) {
      debugPrint('👤 Cliente existente - campos mínimos requeridos');
      // Para clientes existentes, solo necesitamos identificación y servicio
      switch (bookingType) {
        case BookingType.enterprise:
          return [
            'numeroEmpleado', // Solo número de empleado
            'selectedServiceId',
          ];
        case BookingType.corporate:
        case BookingType.particular:
          return [
            'clientPhone', // Solo teléfono registrado
            'selectedServiceId',
          ];
      }
    } else {
      debugPrint('🆕 Cliente nuevo - campos completos requeridos');
      // Para clientes nuevos, necesitamos información completa
      final baseFields = [
        'nombreCliente',
        'clientPhone',
        'selectedServiceId',
      ];

      switch (bookingType) {
        case BookingType.enterprise:
          return [...baseFields, 'numeroEmpleado'];
        case BookingType.corporate:
        case BookingType.particular:
          return [...baseFields, 'clientEmail'];
      }
    }
  }

  /// ⚠️ OBTENER MENSAJE DE ERROR AMIGABLE
  static String getFriendlyErrorMessage(String technicalError) {
    final errorMappings = {
      'required': 'Este campo es obligatorio',
      'invalid_email': 'El formato del email no es válido',
      'invalid_phone': 'El formato del teléfono no es válido',
      'invalid_name': 'El nombre debe tener al menos 2 caracteres',
      'invalid_employee':
          'El número de empleado debe tener entre 3 y 10 dígitos',
      'invalid_date': 'La fecha seleccionada no es válida',
      'invalid_time': 'El horario seleccionado no es válido',
      'missing_service': 'Debes seleccionar un servicio',
      'missing_event': 'Debes seleccionar un evento',
    };

    for (final key in errorMappings.keys) {
      if (technicalError.toLowerCase().contains(key)) {
        return errorMappings[key]!;
      }
    }

    return 'Verifica la información ingresada';
  }
}

// ============================================================================
// 📋 MODELO DE RESULTADO DE VALIDACIÓN
// ============================================================================

/// ✅ RESULTADO DE VALIDACIÓN
class ValidationResult {
  final bool isValid;
  final String message;
  final ValidationSeverity severity;
  final Map<String, String>? fieldErrors;

  const ValidationResult._({
    required this.isValid,
    required this.message,
    required this.severity,
    this.fieldErrors,
  });

  /// ✅ CREAR RESULTADO EXITOSO
  factory ValidationResult.success(String message) {
    return ValidationResult._(
      isValid: true,
      message: message,
      severity: ValidationSeverity.success,
    );
  }

  /// ❌ CREAR RESULTADO DE ERROR
  factory ValidationResult.error(String message) {
    return ValidationResult._(
      isValid: false,
      message: message,
      severity: ValidationSeverity.error,
    );
  }

  /// ⚠️ CREAR RESULTADO DE ADVERTENCIA
  factory ValidationResult.warning(String message) {
    return ValidationResult._(
      isValid: true,
      message: message,
      severity: ValidationSeverity.warning,
    );
  }

  /// 📋 CREAR RESULTADO CON ERRORES DE CAMPOS
  factory ValidationResult.withFieldErrors(
    String message,
    Map<String, String> fieldErrors,
  ) {
    return ValidationResult._(
      isValid: false,
      message: message,
      severity: ValidationSeverity.error,
      fieldErrors: fieldErrors,
    );
  }

  /// 🎨 OBTENER COLOR SEGÚN SEVERIDAD
  Color get color {
    switch (severity) {
      case ValidationSeverity.success:
        return Colors.green;
      case ValidationSeverity.warning:
        return Colors.orange;
      case ValidationSeverity.error:
        return Colors.red;
    }
  }

  /// 🔗 COMBINAR CON OTRO RESULTADO
  ValidationResult combine(ValidationResult other) {
    if (!isValid || !other.isValid) {
      return ValidationResult.error(
        '$message\n${other.message}',
      );
    }
    return this;
  }

  @override
  String toString() {
    return 'ValidationResult{isValid: $isValid, message: $message, severity: ${severity.name}}';
  }
}

/// 🎯 SEVERIDAD DE VALIDACIÓN
enum ValidationSeverity {
  success,
  warning,
  error,
}
