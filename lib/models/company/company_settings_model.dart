// [company_settings_model.dart] - CONFIGURACIÓN EMPRESARIAL CON SOPORTE "AMBOS"
// 📁 Ubicación: /lib/models/company/company_settings_model.dart
// 🎯 OBJETIVO: Configuración simple por empresa sin afectar código existente
// ✅ NUEVO: Soporte para clientes híbridos que usan ambos servicios

import 'package:flutter/foundation.dart';

/// 🏢 TIPOS DE NEGOCIO SOPORTADOS
enum BusinessType {
  spa_tradicional, // Solo en sucursal
  servicios_domicilio, // Solo a domicilio
  hibrido // Ambos modos
}

/// 🎯 MODO DE SERVICIO DEL CLIENTE - ✅ CON OPCIÓN "AMBOS"
enum ClientServiceMode {
  sucursal, // 🏢 Cliente viene al spa
  domicilio, // 🏠 Servicio a domicilio
  ambos // 🔄 NUEVO: Cliente híbrido - Usa ambos servicios
}

/// ⚙️ CONFIGURACIÓN MAESTRA DE LA EMPRESA
class CompanySettings {
  final BusinessType businessType;
  final bool enableHomeServices;
  final bool showServiceModeToggle;
  final String companyName;
  final Map<String, dynamic> additionalSettings;

  const CompanySettings({
    required this.businessType,
    required this.enableHomeServices,
    required this.showServiceModeToggle,
    this.companyName = 'Fisio Spa KYM',
    this.additionalSettings = const {},
  });

  /// 🏢 FACTORY: SPA TRADICIONAL
  /// Solo servicios en sucursal, sin toggle
  factory CompanySettings.spaTradicional({String? companyName}) {
    return CompanySettings(
      businessType: BusinessType.spa_tradicional,
      enableHomeServices: false,
      showServiceModeToggle: false,
      companyName: companyName ?? 'Fisio Spa KYM',
      additionalSettings: {
        'defaultServiceMode': ClientServiceMode.sucursal,
        'addressRequired': false,
        'description': 'Spa tradicional - Solo servicios en sucursal',
      },
    );
  }

  /// 🏠 FACTORY: SERVICIOS A DOMICILIO
  /// Solo servicios a domicilio, sin toggle
  factory CompanySettings.serviciosDomicilio({String? companyName}) {
    return CompanySettings(
      businessType: BusinessType.servicios_domicilio,
      enableHomeServices: true,
      showServiceModeToggle: false, // Siempre domicilio
      companyName: companyName ?? 'Fisio Spa KYM Mobile',
      additionalSettings: {
        'defaultServiceMode': ClientServiceMode.domicilio,
        'addressRequired': true,
        'description': 'Servicios móviles - Solo a domicilio',
      },
    );
  }

  /// 🔄 FACTORY: MODELO HÍBRIDO (DEFAULT)
  /// Ambos servicios, usuario elige con toggle
  factory CompanySettings.hibrido({String? companyName}) {
    return CompanySettings(
      businessType: BusinessType.hibrido,
      enableHomeServices: true,
      showServiceModeToggle: true, // Usuario decide
      companyName: companyName ?? 'Fisio Spa KYM',
      additionalSettings: {
        'defaultServiceMode': ClientServiceMode.sucursal,
        'addressRequired': false, // Depende del modo
        'description': 'Modelo híbrido - Sucursal y domicilio',
      },
    );
  }

  /// 🔄 FACTORY: MODELO HÍBRIDO COMPLETO - ✅ NUEVO
  /// Tres servicios: sucursal, domicilio y ambos, usuario elige con toggle
  factory CompanySettings.hibridoCompleto({String? companyName}) {
    return CompanySettings(
      businessType: BusinessType.hibrido,
      enableHomeServices: true,
      showServiceModeToggle: true, // Usuario decide entre 3 opciones
      companyName: companyName ?? 'Fisio Spa KYM',
      additionalSettings: {
        'defaultServiceMode': ClientServiceMode.ambos, // ✅ NUEVO DEFAULT
        'addressRequired': false, // Depende del modo
        'description': 'Modelo híbrido completo - Sucursal, domicilio y ambos',
        'supportHybridClients': true, // ✅ NUEVO FLAG
      },
    );
  }

  /// 🔄 COPYWITH PARA MODIFICACIONES
  CompanySettings copyWith({
    BusinessType? businessType,
    bool? enableHomeServices,
    bool? showServiceModeToggle,
    String? companyName,
    Map<String, dynamic>? additionalSettings,
  }) {
    return CompanySettings(
      businessType: businessType ?? this.businessType,
      enableHomeServices: enableHomeServices ?? this.enableHomeServices,
      showServiceModeToggle:
          showServiceModeToggle ?? this.showServiceModeToggle,
      companyName: companyName ?? this.companyName,
      additionalSettings: additionalSettings ?? this.additionalSettings,
    );
  }

  /// 📊 GETTERS DE CONVENIENCIA
  ClientServiceMode get defaultServiceMode =>
      additionalSettings['defaultServiceMode'] as ClientServiceMode? ??
      ClientServiceMode.sucursal;

  bool get isAddressRequired =>
      additionalSettings['addressRequired'] as bool? ?? false;

  String get description =>
      additionalSettings['description'] as String? ?? 'Sin descripción';

  bool get isSpaTradicional => businessType == BusinessType.spa_tradicional;
  bool get isServiciosDomicilio =>
      businessType == BusinessType.servicios_domicilio;
  bool get isHibrido => businessType == BusinessType.hibrido;

  /// ✅ NUEVO: GETTER PARA SOPORTE DE CLIENTES HÍBRIDOS
  bool get supportHybridClients =>
      additionalSettings['supportHybridClients'] as bool? ?? false;

  /// 📋 VALIDACIONES DE CONFIGURACIÓN
  bool isValidConfiguration() {
    // Spa tradicional no debe tener servicios a domicilio
    if (isSpaTradicional && enableHomeServices) return false;

    // Servicios domicilio debe tener servicios habilitados
    if (isServiciosDomicilio && !enableHomeServices) return false;

    // Híbrido debe mostrar toggle si tiene servicios habilitados
    if (isHibrido && enableHomeServices && !showServiceModeToggle) return false;

    return true;
  }

  /// 📄 SERIALIZACIÓN
  Map<String, dynamic> toMap() {
    return {
      'businessType': businessType.name,
      'enableHomeServices': enableHomeServices,
      'showServiceModeToggle': showServiceModeToggle,
      'companyName': companyName,
      'additionalSettings': additionalSettings,
    };
  }

  factory CompanySettings.fromMap(Map<String, dynamic> map) {
    return CompanySettings(
      businessType: BusinessType.values.firstWhere(
        (e) => e.name == map['businessType'],
        orElse: () => BusinessType.hibrido,
      ),
      enableHomeServices: map['enableHomeServices'] ?? true,
      showServiceModeToggle: map['showServiceModeToggle'] ?? true,
      companyName: map['companyName'] ?? 'Fisio Spa KYM',
      additionalSettings:
          Map<String, dynamic>.from(map['additionalSettings'] ?? {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanySettings &&
          runtimeType == other.runtimeType &&
          businessType == other.businessType &&
          enableHomeServices == other.enableHomeServices &&
          showServiceModeToggle == other.showServiceModeToggle &&
          companyName == other.companyName;

  @override
  int get hashCode =>
      businessType.hashCode ^
      enableHomeServices.hashCode ^
      showServiceModeToggle.hashCode ^
      companyName.hashCode;

  @override
  String toString() {
    return 'CompanySettings{type: $businessType, homeServices: $enableHomeServices, toggle: $showServiceModeToggle}';
  }
}

/// 🎛️ EXTENSIONES HELPER PARA USO FÁCIL - ✅ ACTUALIZADAS CON "AMBOS"
extension ClientServiceModeExtensions on ClientServiceMode {
  /// 🏷️ LABELS PARA UI
  String get label {
    switch (this) {
      case ClientServiceMode.sucursal:
        return 'Sucursal';
      case ClientServiceMode.domicilio:
        return 'Domicilio';
      case ClientServiceMode.ambos: // ✅ NUEVO
        return 'Ambos'; // ✅ NUEVO
    }
  }

  /// 🎨 ICONOS PARA UI
  String get icon {
    switch (this) {
      case ClientServiceMode.sucursal:
        return '🏢';
      case ClientServiceMode.domicilio:
        return '🏠';
      case ClientServiceMode.ambos: // ✅ NUEVO
        return '🔄'; // ✅ NUEVO
    }
  }

  /// 📝 DESCRIPCIÓN
  String get description {
    switch (this) {
      case ClientServiceMode.sucursal:
        return 'Cliente viene al spa';
      case ClientServiceMode.domicilio:
        return 'Servicio a domicilio';
      case ClientServiceMode.ambos: // ✅ NUEVO
        return 'Ambos servicios disponibles'; // ✅ NUEVO
    }
  }

  /// 🎯 ES MODO DOMICILIO - ✅ ACTUALIZADO
  bool get isHomeService =>
      this == ClientServiceMode.domicilio || this == ClientServiceMode.ambos;

  /// 🏢 ES MODO SUCURSAL - ✅ ACTUALIZADO
  bool get isInSiteService =>
      this == ClientServiceMode.sucursal || this == ClientServiceMode.ambos;

  /// ✅ NUEVO: ES MODO HÍBRIDO
  bool get isHybridService => this == ClientServiceMode.ambos;

  /// ✅ NUEVO: REQUIERE DIRECCIÓN
  bool get requiresAddress => this == ClientServiceMode.domicilio;

  /// ✅ NUEVO: DIRECCIÓN RECOMENDADA
  bool get addressRecommended => this == ClientServiceMode.ambos;

  /// ✅ NUEVO: DIRECCIÓN OPCIONAL
  bool get addressOptional =>
      this == ClientServiceMode.sucursal || this == ClientServiceMode.ambos;
}

extension BusinessTypeExtensions on BusinessType {
  /// 🏷️ LABELS PARA UI
  String get label {
    switch (this) {
      case BusinessType.spa_tradicional:
        return 'Spa Tradicional';
      case BusinessType.servicios_domicilio:
        return 'Servicios a Domicilio';
      case BusinessType.hibrido:
        return 'Modelo Híbrido';
    }
  }

  /// 📝 DESCRIPCIÓN COMPLETA
  String get description {
    switch (this) {
      case BusinessType.spa_tradicional:
        return 'Solo servicios en las instalaciones del spa';
      case BusinessType.servicios_domicilio:
        return 'Solo servicios móviles a domicilio del cliente';
      case BusinessType.hibrido:
        return 'Servicios tanto en spa como a domicilio, incluyendo clientes híbridos';
    }
  }

  /// ✅ NUEVO: MODOS SOPORTADOS
  List<ClientServiceMode> get supportedModes {
    switch (this) {
      case BusinessType.spa_tradicional:
        return [ClientServiceMode.sucursal];
      case BusinessType.servicios_domicilio:
        return [ClientServiceMode.domicilio];
      case BusinessType.hibrido:
        return [
          ClientServiceMode.sucursal,
          ClientServiceMode.domicilio,
          ClientServiceMode.ambos, // ✅ INCLUIR MODO HÍBRIDO
        ];
    }
  }

  /// ✅ NUEVO: SOPORTA CLIENTES HÍBRIDOS
  bool get supportsHybridClients => this == BusinessType.hibrido;
}
