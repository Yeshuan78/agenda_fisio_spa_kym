// [company_settings_service.dart] - SERVICIO DE CONFIGURACIÓN SIMPLE - ACTUALIZADO CON MODO AMBOS
// 📁 Ubicación: /lib/services/company/company_settings_service.dart
// 🎯 OBJETIVO: Servicio singleton para configuración empresarial + MODO AMBOS

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:agenda_fisio_spa_kym/models/company/company_settings_model.dart';

/// 🏢 SERVICIO SINGLETON DE CONFIGURACIÓN EMPRESARIAL + MODO AMBOS
class CompanySettingsService extends ChangeNotifier {
  static final CompanySettingsService _instance =
      CompanySettingsService._internal();
  factory CompanySettingsService() => _instance;
  CompanySettingsService._internal();

  // ✅ CONFIGURACIÓN ACTUAL (DEFAULT: HÍBRIDO COMPLETO CON AMBOS)
  CompanySettings _currentSettings = CompanySettings.hibridoCompleto();
  bool _isInitialized = false;

  // ✅ GETTERS PÚBLICOS
  CompanySettings get currentSettings => _currentSettings;
  bool get isInitialized => _isInitialized;

  // ✅ GETTERS DE CONVENIENCIA (PARA USO RÁPIDO EN WIDGETS)
  static CompanySettings get settings => _instance._currentSettings;
  static bool get showServiceToggle =>
      _instance._currentSettings.showServiceModeToggle;
  static bool get enableHomeServices =>
      _instance._currentSettings.enableHomeServices;
  static BusinessType get businessType =>
      _instance._currentSettings.businessType;
  static ClientServiceMode get defaultServiceMode =>
      _instance._currentSettings.defaultServiceMode;

  /// 🚀 INICIALIZAR SERVICIO
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('🏢 Inicializando CompanySettingsService...');

    try {
      // Cargar configuración guardada
      await _loadSettingsFromStorage();

      _isInitialized = true;
      notifyListeners();

      debugPrint(
          '✅ CompanySettingsService inicializado: ${_currentSettings.businessType.label}');
    } catch (e) {
      debugPrint('❌ Error inicializando CompanySettingsService: $e');
      // Usar configuración por defecto en caso de error
      _currentSettings = CompanySettings.hibridoCompleto(); // ✅ NUEVO DEFAULT
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// ⚙️ ACTUALIZAR CONFIGURACIÓN
  Future<void> updateSettings(CompanySettings newSettings) async {
    if (!newSettings.isValidConfiguration()) {
      throw Exception('Configuración inválida: ${newSettings.toString()}');
    }

    final oldSettings = _currentSettings;
    _currentSettings = newSettings;

    try {
      await _saveSettingsToStorage();
      notifyListeners();

      debugPrint(
          '✅ Configuración actualizada: ${oldSettings.businessType.label} → ${newSettings.businessType.label}');
    } catch (e) {
      // Revertir en caso de error
      _currentSettings = oldSettings;
      debugPrint('❌ Error guardando configuración: $e');
      rethrow;
    }
  }

  /// 🔄 CAMBIAR TIPO DE NEGOCIO RÁPIDO + MODO AMBOS
  Future<void> setBusinessType(BusinessType type, {String? companyName}) async {
    CompanySettings newSettings;

    switch (type) {
      case BusinessType.spa_tradicional:
        newSettings = CompanySettings.spaTradicional(companyName: companyName);
        break;
      case BusinessType.servicios_domicilio:
        newSettings =
            CompanySettings.serviciosDomicilio(companyName: companyName);
        break;
      case BusinessType.hibrido:
        newSettings = CompanySettings.hibridoCompleto(
            companyName: companyName); // ✅ USAR HÍBRIDO COMPLETO
        break;
    }

    await updateSettings(newSettings);
  }

  /// 🎯 VERIFICAR SI MODO DE SERVICIO ES VÁLIDO + MODO AMBOS
  bool isServiceModeValid(ClientServiceMode mode) {
    switch (_currentSettings.businessType) {
      case BusinessType.spa_tradicional:
        return mode == ClientServiceMode.sucursal;
      case BusinessType.servicios_domicilio:
        return mode == ClientServiceMode.domicilio;
      case BusinessType.hibrido:
        return true; // ✅ TODOS los modos válidos incluyendo AMBOS
    }
  }

  /// 🔍 OBTENER MODO DE SERVICIO RECOMENDADO + MODO AMBOS
  ClientServiceMode getRecommendedServiceMode() {
    return _currentSettings.defaultServiceMode;
  }

  /// 📋 VALIDAR SI DIRECCIÓN ES REQUERIDA PARA MODO + MODO AMBOS
  bool isAddressRequiredForMode(ClientServiceMode mode) {
    switch (mode) {
      case ClientServiceMode.sucursal:
        return false; // Siempre opcional para sucursal
      case ClientServiceMode.domicilio:
        return true; // Siempre requerida para domicilio
      case ClientServiceMode.ambos: // ✅ NUEVO
        return false; // Opcional pero recomendada para híbrido // ✅ NUEVO
    }
  }

  /// ✅ NUEVO: VERIFICAR SI DIRECCIÓN ES RECOMENDADA PARA MODO
  bool isAddressRecommendedForMode(ClientServiceMode mode) {
    switch (mode) {
      case ClientServiceMode.sucursal:
        return false; // No recomendada para sucursal
      case ClientServiceMode.domicilio:
        return true; // Requerida (más que recomendada)
      case ClientServiceMode.ambos:
        return true; // Recomendada para híbrido
    }
  }

  /// 🎨 OBTENER CONFIGURACIÓN PARA EL WIZARD + MODO AMBOS
  WizardConfiguration getWizardConfiguration() {
    return WizardConfiguration(
      showServiceModeToggle: _currentSettings.showServiceModeToggle,
      defaultServiceMode: _currentSettings.defaultServiceMode,
      enableHomeServices: _currentSettings.enableHomeServices,
      businessType: _currentSettings.businessType,
      supportHybridClients: _currentSettings.supportHybridClients, // ✅ NUEVO
    );
  }

  /// ✅ NUEVO: OBTENER MODOS SOPORTADOS
  List<ClientServiceMode> getSupportedServiceModes() {
    return _currentSettings.businessType.supportedModes;
  }

  /// ✅ NUEVO: VERIFICAR SI SOPORTA CLIENTES HÍBRIDOS
  bool get supportsHybridClients {
    return _currentSettings.supportHybridClients;
  }

  /// 💾 CARGAR CONFIGURACIÓN DESDE STORAGE
  Future<void> _loadSettingsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('company_settings');

      if (settingsJson != null) {
        final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
        _currentSettings = CompanySettings.fromMap(settingsMap);
        debugPrint('📁 Configuración cargada desde storage');
      } else {
        // Primera vez - usar configuración híbrida completa por defecto
        _currentSettings = CompanySettings.hibridoCompleto(); // ✅ NUEVO DEFAULT
        await _saveSettingsToStorage();
        debugPrint(
            '🆕 Primera vez - configuración híbrida completa por defecto');
      }
    } catch (e) {
      debugPrint('❌ Error cargando configuración: $e');
      _currentSettings = CompanySettings.hibridoCompleto(); // ✅ NUEVO DEFAULT
    }
  }

  /// 💾 GUARDAR CONFIGURACIÓN EN STORAGE
  Future<void> _saveSettingsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(_currentSettings.toMap());
      await prefs.setString('company_settings', settingsJson);
      debugPrint('💾 Configuración guardada en storage');
    } catch (e) {
      debugPrint('❌ Error guardando configuración: $e');
      rethrow;
    }
  }

  /// 🔄 RESETEAR A CONFIGURACIÓN POR DEFECTO + MODO AMBOS
  Future<void> resetToDefault() async {
    await updateSettings(CompanySettings.hibridoCompleto()); // ✅ NUEVO DEFAULT
  }

  /// ✅ NUEVO: CAMBIAR A CONFIGURACIÓN HÍBRIDA COMPLETA
  Future<void> enableHybridMode({String? companyName}) async {
    await updateSettings(
        CompanySettings.hibridoCompleto(companyName: companyName));
  }

  /// ✅ NUEVO: CAMBIAR A CONFIGURACIÓN HÍBRIDA BÁSICA (SIN AMBOS)
  Future<void> enableBasicHybridMode({String? companyName}) async {
    await updateSettings(CompanySettings.hibrido(companyName: companyName));
  }

  /// 📊 OBTENER ESTADÍSTICAS DE USO + MODO AMBOS
  Map<String, dynamic> getUsageStats() {
    return {
      'businessType': _currentSettings.businessType.name,
      'enableHomeServices': _currentSettings.enableHomeServices,
      'showServiceModeToggle': _currentSettings.showServiceModeToggle,
      'defaultServiceMode': _currentSettings.defaultServiceMode.name,
      'supportHybridClients': _currentSettings.supportHybridClients, // ✅ NUEVO
      'supportedModes': _currentSettings.businessType.supportedModes
          .map((m) => m.name)
          .toList(), // ✅ NUEVO
      'isInitialized': _isInitialized,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 🧹 CLEANUP
  void dispose() {
    // Este es un singleton, no se debería llamar dispose
    debugPrint(
        '⚠️ CompanySettingsService es singleton - no se debe hacer dispose');
  }
}

/// 🎛️ CONFIGURACIÓN ESPECÍFICA PARA EL WIZARD + MODO AMBOS
class WizardConfiguration {
  final bool showServiceModeToggle;
  final ClientServiceMode defaultServiceMode;
  final bool enableHomeServices;
  final BusinessType businessType;
  final bool supportHybridClients; // ✅ NUEVO

  const WizardConfiguration({
    required this.showServiceModeToggle,
    required this.defaultServiceMode,
    required this.enableHomeServices,
    required this.businessType,
    this.supportHybridClients = false, // ✅ NUEVO
  });

  /// 📋 VALIDAR SI EL WIZARD DEBE MOSTRAR TOGGLE + MODO AMBOS
  bool get shouldShowToggleInWizard =>
      showServiceModeToggle && enableHomeServices;

  /// ✅ NUEVO: VERIFICAR SI DEBE MOSTRAR OPCIÓN AMBOS
  bool get shouldShowHybridOption => supportHybridClients;

  /// ✅ NUEVO: OBTENER OPCIONES DISPONIBLES
  List<ClientServiceMode> get availableServiceModes {
    return businessType.supportedModes;
  }

  /// 🏷️ OBTENER LABEL PARA EL BOTÓN DE CREAR + MODO AMBOS
  String getCreateButtonLabel(ClientServiceMode mode) {
    switch (mode) {
      case ClientServiceMode.sucursal:
        return 'Crear Cliente';
      case ClientServiceMode.domicilio:
        return 'Crear Cliente a Domicilio';
      case ClientServiceMode.ambos: // ✅ NUEVO
        return 'Crear Cliente Híbrido'; // ✅ NUEVO
    }
  }

  /// 📝 OBTENER DESCRIPCIÓN PARA EL PASO DE DIRECCIÓN + MODO AMBOS
  String getAddressStepDescription(ClientServiceMode mode) {
    switch (mode) {
      case ClientServiceMode.sucursal:
        return 'Dirección opcional para contacto';
      case ClientServiceMode.domicilio:
        return 'Dirección requerida para servicios a domicilio';
      case ClientServiceMode.ambos: // ✅ NUEVO
        return 'Dirección recomendada para servicios a domicilio'; // ✅ NUEVO
    }
  }

  /// ✅ VALIDAR SI DIRECCIÓN ES REQUERIDA + MODO AMBOS
  bool isAddressRequired(ClientServiceMode mode) {
    switch (mode) {
      case ClientServiceMode.sucursal:
        return false;
      case ClientServiceMode.domicilio:
        return true;
      case ClientServiceMode.ambos: // ✅ AGREGADO CASO FALTANTE
        return false; // Opcional pero recomendada // ✅ AGREGADO CASO FALTANTE
    }
  }

  /// ✅ NUEVO: VALIDAR SI DIRECCIÓN ES RECOMENDADA
  bool isAddressRecommended(ClientServiceMode mode) {
    switch (mode) {
      case ClientServiceMode.sucursal:
        return false;
      case ClientServiceMode.domicilio:
        return true; // Requerida (más que recomendada)
      case ClientServiceMode.ambos: // ✅ AGREGADO CASO FALTANTE
        return true; // Recomendada para híbrido // ✅ AGREGADO CASO FALTANTE
    }
  }

  /// ✅ NUEVO: OBTENER HINT TEXT PARA CAMPOS DE DIRECCIÓN
  String getAddressHintText(String fieldName, ClientServiceMode mode) {
    final baseHints = {
      'calle': 'Av. Insurgentes Sur',
      'colonia': 'Del Valle',
      'numeroExterior': '457',
      'codigoPostal': '03610',
    };

    final baseHint = baseHints[fieldName] ?? '';

    switch (mode) {
      case ClientServiceMode.sucursal:
        return '$baseHint (opcional)';
      case ClientServiceMode.domicilio:
        return baseHint;
      case ClientServiceMode.ambos: // ✅ AGREGADO CASO FALTANTE
        return '$baseHint (recomendada)'; // ✅ AGREGADO CASO FALTANTE
    }
  }

  @override
  String toString() {
    return 'WizardConfiguration{toggle: $showServiceModeToggle, default: $defaultServiceMode, homeServices: $enableHomeServices, hybridClients: $supportHybridClients}';
  }
}
