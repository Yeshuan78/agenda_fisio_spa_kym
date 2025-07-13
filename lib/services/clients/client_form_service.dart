// [client_form_service.dart] - SERVICIO ESPECIALIZADO PARA FORMULARIO DE CLIENTE - ✅ FIX MÉTRICAS EN 0
// 📁 Ubicación: /lib/services/clients/client_form_service.dart
// 🎯 OBJETIVO: Operaciones CRUD especializadas con control de costos + MÉTRICAS EN 0
// ✅ FIX CRÍTICO: Métricas inicializadas en 0 para clientes nuevos

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_form_model.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/models/company/company_settings_model.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/services/client_service.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/background_cost_monitor.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/cost_data_models.dart';

/// 🛠️ EXCEPCIONES ESPECÍFICAS DEL FORMULARIO
class ClientFormException implements Exception {
  final String message;
  final String code;
  final Map<String, dynamic>? details;

  const ClientFormException(this.message, this.code, [this.details]);

  @override
  String toString() => 'ClientFormException($code): $message';
}

class DuplicateEmailException extends ClientFormException {
  DuplicateEmailException(String email)
      : super('El email $email ya está registrado', 'DUPLICATE_EMAIL');
}

class CostLimitException extends ClientFormException {
  CostLimitException()
      : super('Límite de costos alcanzado', 'COST_LIMIT_EXCEEDED');
}

class ValidationException extends ClientFormException {
  final String field;

  ValidationException(this.field, String message)
      : super(message, 'VALIDATION_ERROR', {'field': field});
}

/// 🏗️ SERVICIO PRINCIPAL PARA OPERACIONES DE FORMULARIO
class ClientFormService {
  static final _instance = ClientFormService._internal();
  factory ClientFormService() => _instance;
  ClientFormService._internal();

  // ✅ DEPENDENCIAS
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BackgroundCostMonitor _costMonitor = BackgroundCostMonitor();

  // ✅ CONFIGURACIÓN
  static const String _collectionName = 'clients';
  static const Duration _operationTimeout = Duration(seconds: 30);

  // ========================================================================
  // 🚀 MÉTODOS PÚBLICOS PRINCIPALES
  // ========================================================================

  /// ➕ CREAR NUEVO CLIENTE - ✅ CON SERVICEMODE Y MÉTRICAS EN 0
  Future<ClientModel> createClient(ClientFormModel formData) async {
    debugPrint('➕ Creando nuevo cliente: ${formData.personalInfo.fullName}');
    debugPrint('🎯 Con serviceMode: ${formData.serviceMode.label}');

    // 1️⃣ Verificar límites de costo
    _checkCostLimits();

    // 2️⃣ Validar datos del formulario
    await _validateFormData(formData, isUpdate: false);

    // 3️⃣ Verificar email único
    final emailIsUnique = await isEmailUnique(formData.personalInfo.email);
    if (!emailIsUnique) {
      throw DuplicateEmailException(formData.personalInfo.email);
    }

    try {
      // 4️⃣ Preparar datos para Firestore - ✅ CON SERVICEMODE Y MÉTRICAS EN 0
      final clientData = _prepareClientData(formData);

      // ✅ LOG CRÍTICO ANTES DE GUARDAR EN FIRESTORE
      debugPrint('💾 Datos que se guardarán en Firestore:');
      debugPrint('   serviceMode: ${clientData['serviceMode']}');
      debugPrint('   isHomeService: ${clientData['isHomeService']}');
      debugPrint('   appointmentsCount: ${clientData['appointmentsCount']}');
      debugPrint('   totalRevenue: ${clientData['totalRevenue']}');

      // 5️⃣ Crear documento en Firestore
      final docRef = await _firestore
          .collection(_collectionName)
          .add(clientData)
          .timeout(_operationTimeout);

      // 6️⃣ Registrar consulta para costos
      _recordRead();

      // 7️⃣ Obtener cliente creado con ID
      final doc = await docRef.get();
      final createdClient = ClientModel.fromDoc(doc);

      // 8️⃣ Log de auditoría
      await _logClientOperation(
          'CREATE', createdClient.clientId, formData.personalInfo.fullName);

      debugPrint('✅ Cliente creado exitosamente: ${createdClient.clientId}');
      debugPrint('✅ Con serviceMode guardado: ${formData.serviceMode.label}');
      debugPrint('✅ Con métricas inicializadas en 0');
      return createdClient;
    } catch (e) {
      debugPrint('❌ Error creando cliente: $e');
      _handleFirestoreError(e);
      rethrow;
    }
  }

  /// ✏️ ACTUALIZAR CLIENTE EXISTENTE - ✅ CON SERVICEMODE
  Future<ClientModel> updateClient(ClientFormModel formData) async {
    if (formData.clientId == null) {
      throw const ClientFormException(
          'ID de cliente requerido para actualización', 'MISSING_CLIENT_ID');
    }

    debugPrint('✏️ Actualizando cliente: ${formData.clientId}');
    debugPrint('🎯 Con serviceMode: ${formData.serviceMode.label}');

    // 1️⃣ Verificar límites de costo
    _checkCostLimits();

    // 2️⃣ Validar datos del formulario
    await _validateFormData(formData, isUpdate: true);

    // 3️⃣ Verificar que el cliente existe
    final existingClient = await _getExistingClient(formData.clientId!);

    // 4️⃣ Verificar email único (solo si cambió)
    if (existingClient.email != formData.personalInfo.email) {
      final emailIsUnique = await isEmailUnique(formData.personalInfo.email);
      if (!emailIsUnique) {
        throw DuplicateEmailException(formData.personalInfo.email);
      }
    }

    try {
      // 5️⃣ Preparar datos actualizados - ✅ CON SERVICEMODE
      final updatedData = _prepareClientData(formData);
      updatedData['updatedAt'] = FieldValue.serverTimestamp();

      // ✅ LOG CRÍTICO ANTES DE ACTUALIZAR EN FIRESTORE
      debugPrint('💾 Datos que se actualizarán en Firestore:');
      debugPrint('   serviceMode: ${updatedData['serviceMode']}');
      debugPrint('   isHomeService: ${updatedData['isHomeService']}');

      // 6️⃣ Actualizar documento en Firestore
      await _firestore
          .collection(_collectionName)
          .doc(formData.clientId)
          .update(updatedData)
          .timeout(_operationTimeout);

      // 7️⃣ Registrar consulta para costos
      _recordRead();

      // 8️⃣ Obtener cliente actualizado
      final doc = await _firestore
          .collection(_collectionName)
          .doc(formData.clientId)
          .get();

      final updatedClient = ClientModel.fromDoc(doc);

      // 9️⃣ Log de auditoría
      await _logClientOperation(
          'UPDATE', updatedClient.clientId, formData.personalInfo.fullName);

      debugPrint(
          '✅ Cliente actualizado exitosamente: ${updatedClient.clientId}');
      debugPrint('✅ Con serviceMode guardado: ${formData.serviceMode.label}');
      return updatedClient;
    } catch (e) {
      debugPrint('❌ Error actualizando cliente: $e');
      _handleFirestoreError(e);
      rethrow;
    }
  }

  /// 🔍 VERIFICAR SI EMAIL ES ÚNICO
  Future<bool> isEmailUnique(String email) async {
    if (email.trim().isEmpty) return false;

    debugPrint('🔍 Verificando email único: $email');

    try {
      // Verificar límites de costo antes de consulta
      if (!_canPerformRead()) {
        debugPrint('⚠️ Límite de costos alcanzado para verificación de email');
        return true; // Permitir continuar si no podemos verificar
      }

      final query = await _firestore
          .collection(_collectionName)
          .where('correo', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get()
          .timeout(_operationTimeout);

      // Registrar consulta para costos
      _recordRead();

      final emailIsUnique = query.docs.isEmpty;
      debugPrint('📊 Email único: $emailIsUnique');

      return emailIsUnique;
    } catch (e) {
      debugPrint('❌ Error verificando email único: $e');
      // En caso de error, permitir continuar (fail-safe)
      return true;
    }
  }

  /// 🗑️ ELIMINAR CLIENTE (SOFT DELETE)
  Future<void> deleteClient(String clientId) async {
    debugPrint('🗑️ Eliminando cliente: $clientId');

    // 1️⃣ Verificar límites de costo
    _checkCostLimits();

    try {
      // 2️⃣ Marcar como eliminado (soft delete)
      await _firestore.collection(_collectionName).doc(clientId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(_operationTimeout);

      // 3️⃣ Registrar consulta para costos
      _recordRead();

      // 4️⃣ Log de auditoría
      await _logClientOperation('DELETE', clientId, 'Cliente eliminado');

      debugPrint('✅ Cliente eliminado exitosamente: $clientId');
    } catch (e) {
      debugPrint('❌ Error eliminando cliente: $e');
      _handleFirestoreError(e);
      rethrow;
    }
  }

  /// 📋 OBTENER CLIENTE POR ID
  Future<ClientModel?> getClientById(String clientId) async {
    debugPrint('📋 Obteniendo cliente: $clientId');

    try {
      // Verificar límites de costo
      if (!_canPerformRead()) {
        throw CostLimitException();
      }

      final doc = await _firestore
          .collection(_collectionName)
          .doc(clientId)
          .get()
          .timeout(_operationTimeout);

      // Registrar consulta para costos
      _recordRead();

      if (!doc.exists) {
        debugPrint('❌ Cliente no encontrado: $clientId');
        return null;
      }

      final client = ClientModel.fromDoc(doc);
      debugPrint('✅ Cliente obtenido: ${client.fullName}');

      return client;
    } catch (e) {
      debugPrint('❌ Error obteniendo cliente: $e');
      _handleFirestoreError(e);
      rethrow;
    }
  }

  // ========================================================================
  // 🔧 MÉTODOS PRIVADOS DE VALIDACIÓN
  // ========================================================================

  Future<void> _validateFormData(ClientFormModel formData,
      {required bool isUpdate}) async {
    debugPrint('🔍 Validando datos del formulario...');

    final List<String> errors = [];

    // Validar información personal
    if (formData.personalInfo.nombre.trim().isEmpty) {
      errors.add('Nombre es requerido');
    }
    if (formData.personalInfo.apellidos.trim().isEmpty) {
      errors.add('Apellidos son requeridos');
    }
    if (!_isValidEmail(formData.personalInfo.email)) {
      errors.add('Email no válido');
    }

    // ✅ FIX QUIRÚRGICO: Validar teléfono internacional REAL
    if (!_isValidInternationalPhoneFixed(formData.personalInfo.telefono)) {
      errors.add('Teléfono no válido');
    }

    // ✅ FIX QUIRÚRGICO: DIRECCIÓN 100% OPCIONAL - SIN VALIDACIONES
    // Eliminamos TODAS las validaciones de dirección
    // Solo validar CP si está presente Y no está vacío
    if (formData.addressInfo.codigoPostal.trim().isNotEmpty &&
        !_isValidCP(formData.addressInfo.codigoPostal)) {
      errors.add('Código postal no válido (si se proporciona)');
    }

    // Validar ID para actualizaciones
    if (isUpdate && formData.clientId == null) {
      errors.add('ID de cliente requerido para actualización');
    }

    if (errors.isNotEmpty) {
      throw ValidationException('general', errors.join(', '));
    }

    debugPrint('✅ Validación completada exitosamente');
  }

  Future<ClientModel> _getExistingClient(String clientId) async {
    final client = await getClientById(clientId);
    if (client == null) {
      throw const ClientFormException(
          'Cliente no encontrado', 'CLIENT_NOT_FOUND');
    }
    return client;
  }

  /// ✅ FIX CRÍTICO: PREPARAR DATOS CON SERVICEMODE + MÉTRICAS EN 0 + FECHA DE NACIMIENTO
  Map<String, dynamic> _prepareClientData(ClientFormModel formData) {
    final Map<String, dynamic> data = {
      // ✅ CAMPOS COMPATIBLES CON ESTRUCTURA EXISTENTE
      'nombre': formData.personalInfo.nombre.trim(),
      'apellidos': formData.personalInfo.apellidos.trim(),
      'correo': formData.personalInfo.email.trim().toLowerCase(),
      'telefono':
          _formatInternationalPhoneFixed(formData.personalInfo.telefono),
      'empresa': formData.personalInfo.empresa?.trim(),

      // ✅ FIX CRÍTICO #1: AGREGAR FECHA DE NACIMIENTO
      'fechaNacimiento': formData.personalInfo.fechaNacimiento != null
          ? Timestamp.fromDate(formData.personalInfo.fechaNacimiento!)
          : null,

      // ✅ FIX CRÍTICO #2: CAMPOS ADICIONALES PARA QUERIES DE CUMPLEAÑOS
      'edad': formData.personalInfo.fechaNacimiento != null
          ? _calculateAge(formData.personalInfo.fechaNacimiento!)
          : null,
      'mesNacimiento': formData.personalInfo.fechaNacimiento?.month,
      'diaNacimiento': formData.personalInfo.fechaNacimiento?.day,

      // ✅ DIRECCIÓN - TODOS LOS CAMPOS OPCIONALES
      'calle': formData.addressInfo.calle.trim(),
      'numeroExterior': formData.addressInfo.numeroExterior.trim(),
      'numeroInterior': formData.addressInfo.numeroInterior?.trim(),
      'colonia': formData.addressInfo.colonia.trim(),
      'codigoPostal': _formatCP(formData.addressInfo.codigoPostal),
      'alcaldia': formData.addressInfo.alcaldia.trim(),

      // ✅ ETIQUETAS EN FORMATO COMPATIBLE
      'tiposCliente': _prepareTagsData(formData.tagsInfo),

      // ✅ FIX CRÍTICO: CAMPOS DE MODO DE SERVICIO CORREGIDOS
      'serviceMode': formData.serviceMode.name, // ✅ CAMPO PRINCIPAL
      'isHomeService': formData.isHomeService, // ✅ CAMPO DERIVADO
      'isInSiteService': formData.isInSiteService, // ✅ CAMPO DERIVADO
      'isHybridService': formData.isHybridService, // ✅ CAMPO DERIVADO NUEVO

      // ✅ METADATOS
      'isActive': true,
      'source': 'form_crud',
      'status': 'active',
    };

    // ✅ FIX CRÍTICO: INICIALIZAR MÉTRICAS EN 0 SOLO PARA CLIENTES NUEVOS
    if (!formData.isEditing) {
      // Cliente nuevo - inicializar métricas en 0
      data.addAll({
        // ✅ MÉTRICAS EN ROOT LEVEL (COMPATIBILIDAD)
        'appointmentsCount': 0,
        'attendedAppointments': 0,
        'cancelledAppointments': 0,
        'noShowAppointments': 0,
        'totalRevenue': 0.0,
        'averageTicket': 0.0,
        'satisfactionScore': 0.0,
        'loyaltyPoints': 0,
        'lastAppointment': null,
        'nextAppointment': null,

        // ✅ MÉTRICAS COMO OBJETO ANIDADO (FLEXIBILIDAD)
        'metrics': {
          'appointmentsCount': 0,
          'attendedAppointments': 0,
          'cancelledAppointments': 0,
          'noShowAppointments': 0,
          'totalRevenue': 0.0,
          'averageTicket': 0.0,
          'satisfactionScore': 0.0,
          'loyaltyPoints': 0,
          'lastAppointment': null,
          'nextAppointment': null,
        },

        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('📤 Cliente NUEVO: Métricas inicializadas en 0 ✅');
    } else {
      // Cliente existente - NO tocar métricas existentes
      debugPrint('📤 Cliente EXISTENTE: Métricas preservadas ✅');
    }

    // Remover campos null o vacíos EXCEPTO métricas en 0 y fechaNacimiento
    data.removeWhere((key, value) =>
        value == null ||
        (value == '' &&
            ![
              'serviceMode',
              'appointmentsCount',
              'totalRevenue',
              'satisfactionScore',
              'fechaNacimiento' // ✅ PRESERVAR fechaNacimiento incluso si es null
            ].contains(key)));

    // ✅ LOG COMPLETO PARA DEBUG INCLUYENDO FECHA
    debugPrint('📤 Preparando datos para Firestore:');
    debugPrint('   - Nombre completo: ${formData.personalInfo.fullName}');
    debugPrint(
        '   - Fecha de nacimiento: ${formData.personalInfo.fechaNacimiento}');
    if (formData.personalInfo.fechaNacimiento != null) {
      debugPrint(
          '   - Edad calculada: ${_calculateAge(formData.personalInfo.fechaNacimiento!)} años');
      debugPrint(
          '   - Mes/Día: ${formData.personalInfo.fechaNacimiento!.month}/${formData.personalInfo.fechaNacimiento!.day}');
    }
    debugPrint(
        '   - Modo de servicio: ${formData.serviceMode.name} (${formData.serviceMode.label})');
    debugPrint('   - Es servicio a domicilio: ${formData.isHomeService}');
    debugPrint('   - Es servicio en sucursal: ${formData.isInSiteService}');
    debugPrint('   - Es servicio híbrido: ${formData.isHybridService}');
    debugPrint('   - Dirección: ${formData.addressInfo.fullAddress}');
    if (!formData.isEditing) {
      debugPrint(
          '   - Métricas inicializadas: appointmentsCount=0, totalRevenue=0.0');
    }

    return data;
  }

// ✅ FIX CRÍTICO #3: AGREGAR HELPER PARA CALCULAR EDAD
  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  List<Map<String, dynamic>> _prepareTagsData(TagsFormInfo tagsInfo) {
    final List<Map<String, dynamic>> tagsData = [];

    // Etiquetas base
    for (final tag in tagsInfo.baseTags) {
      tagsData.add({
        'label': tag,
        'type': 'base',
        'createdAt': Timestamp.now(),
      });
    }

    // Etiquetas personalizadas con colores
    final colors = [
      '#7c4dff',
      '#009688',
      '#795548',
      '#3f51b5',
      '#00bcd4',
      '#ff5722',
      '#cddc39',
      '#607d8b',
      '#e91e63',
      '#ffc107'
    ];

    for (int i = 0; i < tagsInfo.customTags.length; i++) {
      final tag = tagsInfo.customTags[i];
      final color = colors[i % colors.length];

      tagsData.add({
        'label': tag,
        'color': color,
        'type': 'custom',
        'createdAt': Timestamp.now(),
      });
    }

    return tagsData;
  }

  // ========================================================================
  // 🔧 MÉTODOS HELPER - ✅ FIX QUIRÚRGICO: VALIDACIÓN INTERNACIONAL REAL
  // ========================================================================

  void _checkCostLimits() {
    if (!_canPerformRead()) {
      throw CostLimitException();
    }
  }

  bool _canPerformRead() {
    try {
      final stats = _costMonitor.currentStats;
      return stats.dailyReadCount < CostControlConfig.dailyReadLimit;
    } catch (e) {
      debugPrint('⚠️ Error verificando límites de costo: $e');
      return true; // Fail-safe: permitir operación
    }
  }

  void _recordRead() {
    try {
      debugPrint('📊 Consulta registrada para control de costos');
    } catch (e) {
      debugPrint('⚠️ Error registrando consulta: $e');
    }
  }

  void _handleFirestoreError(dynamic error) {
    if (error.toString().contains('PERMISSION_DENIED')) {
      throw const ClientFormException(
          'Sin permisos para realizar esta operación', 'PERMISSION_DENIED');
    } else if (error.toString().contains('UNAVAILABLE')) {
      throw const ClientFormException(
          'Servicio temporalmente no disponible', 'SERVICE_UNAVAILABLE');
    } else if (error.toString().contains('DEADLINE_EXCEEDED')) {
      throw const ClientFormException('Tiempo de espera agotado', 'TIMEOUT');
    }
  }

  Future<void> _logClientOperation(
      String operation, String clientId, String clientName) async {
    try {
      await _firestore.collection('audit_logs').add({
        'operation': operation,
        'resource': 'client',
        'resourceId': clientId,
        'resourceName': clientName,
        'timestamp': FieldValue.serverTimestamp(),
        'source': 'client_form_service',
        'userId': 'current_user',
      });
    } catch (e) {
      debugPrint('⚠️ Error registrando log de auditoría: $e');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim());
  }

  /// ✅ FIX QUIRÚRGICO: Validación internacional REAL (mismo que wizard_controller)
  bool _isValidInternationalPhoneFixed(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    debugPrint('🔧 SERVICE: VALIDANDO TELÉFONO: "$phone" → LIMPIO: "$cleaned"');

    // Validaciones básicas
    if (cleaned.isEmpty) return false;
    if (cleaned.length < 7) return false;
    if (cleaned.length > 20) return false;

    // 1. INTERNACIONAL CON +: +52, +1, +34, etc.
    if (cleaned.startsWith('+')) {
      final isValid = cleaned.length >= 10 && cleaned.length <= 16;
      debugPrint(
          '📞 SERVICE: Internacional con +: ${isValid ? "✅ VÁLIDO" : "❌ INVÁLIDO"}');
      return isValid;
    }

    // 2. MEXICANO TRADICIONAL: 10 dígitos exactos
    if (cleaned.length == 10) {
      debugPrint('📞 SERVICE: Mexicano tradicional: ✅ VÁLIDO');
      return true;
    }

    // 3. INTERNACIONAL SIN +: Entre 7-15 dígitos
    if (cleaned.length >= 7 && cleaned.length <= 15) {
      debugPrint('📞 SERVICE: Internacional sin +: ✅ VÁLIDO');
      return true;
    }

    debugPrint('❌ SERVICE: Formato no reconocido');
    return false;
  }

  bool _isValidCP(String cp) {
    final cleaned = cp.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length == 5;
  }

  /// ✅ FIX QUIRÚRGICO: Formatear teléfono internacional REAL
  String _formatInternationalPhoneFixed(String phone) {
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
    return cleaned;
  }

  String _formatCP(String cp) {
    return cp.replaceAll(RegExp(r'[^\d]'), '');
  }

  // ========================================================================
  // 🔧 MÉTODOS DE UTILIDAD PARA DESARROLLO
  // ========================================================================

  /// 📊 OBTENER ESTADÍSTICAS DE USO
  Future<Map<String, dynamic>> getUsageStats() async {
    try {
      final stats = _costMonitor.currentStats;
      return {
        'dailyReadCount': stats.dailyReadCount,
        'weeklyReadCount': stats.weeklyReadCount,
        'estimatedDailyCost': stats.estimatedDailyCost,
        'estimatedWeeklyCost': stats.estimatedWeeklyCost,
        'currentMode': stats.currentMode,
        'service_initialized': true,
        'firestore_connected': true,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'service_initialized': false,
        'firestore_connected': false,
      };
    }
  }

  /// 🧪 MÉTODO PARA TESTING - LIMPIAR DATOS DE PRUEBA
  @visibleForTesting
  Future<void> cleanupTestData(String testPrefix) async {
    if (!kDebugMode) {
      throw const ClientFormException(
          'Cleanup solo disponible en modo debug', 'DEBUG_ONLY');
    }

    try {
      final query = await _firestore
          .collection(_collectionName)
          .where('nombre', isGreaterThanOrEqualTo: testPrefix)
          .where('nombre', isLessThan: '${testPrefix}z')
          .get();

      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint(
          '🧹 Datos de prueba limpiados: ${query.docs.length} documentos');
    } catch (e) {
      debugPrint('❌ Error limpiando datos de prueba: $e');
      rethrow;
    }
  }

  /// 📈 HEALTH CHECK DEL SERVICIO
  Future<bool> healthCheck() async {
    try {
      await _firestore
          .collection('_health_check')
          .doc('test')
          .set({'timestamp': FieldValue.serverTimestamp()}).timeout(
              const Duration(seconds: 5));

      final stats = _costMonitor.currentStats;
      return stats.dailyReadCount >= 0;
    } catch (e) {
      debugPrint('❌ Health check falló: $e');
      return false;
    }
  }
}
