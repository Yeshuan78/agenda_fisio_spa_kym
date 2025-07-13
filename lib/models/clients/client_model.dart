// [client_model.dart] - COMPATIBILIDAD COMPLETA - REEXPORTA TODO
// 📁 Ubicación: /lib/models/clients/client_model.dart
// 🎯 OBJETIVO: Mantener compatibilidad total con código existente
// ✅ STRATEGY: Re-exportar todas las clases para que imports existentes funcionen

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/models/company/company_settings_model.dart';

// ✅ IMPORTS DE MÓDULOS REFACTORIZADOS
import 'client_info_models.dart';
import 'client_tag_model.dart';
import 'client_metrics_model.dart';
import 'client_audit_model.dart';
import 'client_filter_model.dart';
import 'client_extensions.dart';
import 'client_enums.dart';

// ========================================================================
// 🔄 RE-EXPORTACIONES PARA COMPATIBILIDAD TOTAL
// ========================================================================

// ✅ RE-EXPORT: ENUMS
export 'client_enums.dart';

// ✅ RE-EXPORT: MODELOS DE INFORMACIÓN
export 'client_info_models.dart';

// ✅ RE-EXPORT: SISTEMA DE ETIQUETAS
export 'client_tag_model.dart';

// ✅ RE-EXPORT: MÉTRICAS
export 'client_metrics_model.dart';

// ✅ RE-EXPORT: AUDITORÍA
export 'client_audit_model.dart';

// ✅ RE-EXPORT: FILTROS
export 'client_filter_model.dart';

// ✅ RE-EXPORT: EXTENSIONES
export 'client_extensions.dart';

// ========================================================================
// 👥 MODELO PRINCIPAL DE CLIENTE ENTERPRISE - ✅ REFACTORIZADO CON FIXES
// ========================================================================

/// Compatible con estructura Firestore existente + funcionalidades premium + serviceMode
class ClientModel {
  // ✅ IDENTIFICADORES PRINCIPALES
  final String clientId;
  final PersonalInfo personalInfo;
  final ContactInfo contactInfo;
  final AddressInfo addressInfo;
  final List<ClientTag> tags;
  final ClientMetrics metrics;
  final AuditInfo auditInfo;

  // ✅ TIMESTAMPS PARA AUDITORÍA
  final DateTime createdAt;
  final DateTime updatedAt;

  // ✅ CAMPOS CALCULADOS (NO PERSISTIDOS)
  final ClientStatus status;
  final int appointmentsCount;
  final double totalRevenue;
  final DateTime? lastAppointment;

  // ✅ CAMPOS DE MODO DE SERVICIO + AMBOS
  final ClientServiceMode serviceMode;
  final bool isHomeService;
  final bool isInSiteService;
  final bool isHybridService;

  const ClientModel({
    required this.clientId,
    required this.personalInfo,
    required this.contactInfo,
    required this.addressInfo,
    required this.tags,
    required this.metrics,
    required this.auditInfo,
    required this.createdAt,
    required this.updatedAt,
    this.status = ClientStatus.active,
    this.appointmentsCount = 0,
    this.totalRevenue = 0.0,
    this.lastAppointment,
    // ✅ NUEVOS CAMPOS CON DEFAULTS SEGUROS
    this.serviceMode = ClientServiceMode.sucursal,
    this.isHomeService = false,
    this.isInSiteService = true,
    this.isHybridService = false,
  });

  /// 🏗️ FACTORY CONSTRUCTOR DESDE FIRESTORE
  factory ClientModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClientModel.fromMap(data, doc.id);
  }

  /// 🏗️ FACTORY CONSTRUCTOR DESDE MAP - ✅ FIX CRÍTICO: LECTURA DE SERVICEMODE
  factory ClientModel.fromMap(Map<String, dynamic> data, String id) {
    // ✅ FIX CRÍTICO: LEER SERVICEMODE DESDE FIRESTORE
    final serviceModeString = data['serviceMode'] as String?;
    final serviceMode = _parseServiceMode(serviceModeString);

    // ✅ CALCULAR CAMPOS DERIVADOS BASADOS EN SERVICEMODE
    final isHomeService = data['isHomeService'] as bool? ??
        (serviceMode == ClientServiceMode.domicilio ||
            serviceMode == ClientServiceMode.ambos);
    final isInSiteService = data['isInSiteService'] as bool? ??
        (serviceMode == ClientServiceMode.sucursal ||
            serviceMode == ClientServiceMode.ambos);
    final isHybridService = data['isHybridService'] as bool? ??
        (serviceMode == ClientServiceMode.ambos);

    // ✅ LOG PARA DEBUGGING
    debugPrint(
        '📖 ClientModel.fromMap: Leyendo cliente ${data['nombre'] ?? 'Sin nombre'}');
    debugPrint('   - serviceMode string: $serviceModeString');
    debugPrint('   - serviceMode parsed: ${serviceMode.label}');
    debugPrint('   - isHomeService: $isHomeService');
    debugPrint('   - isInSiteService: $isInSiteService');
    debugPrint('   - isHybridService: $isHybridService');

    return ClientModel(
      clientId: id,
      personalInfo: PersonalInfo.fromMap(data),
      contactInfo: ContactInfo.fromMap(data),
      addressInfo: AddressInfo.fromMap(data),
      tags: _parseClientTags(data['tiposCliente']),
      metrics:
          ClientMetrics.fromMap(data), // ✅ FIX: Usando métricas con fallbacks
      auditInfo: AuditInfo.fromMap(data),
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(data['updatedAt']) ?? DateTime.now(),
      status: _parseClientStatus(data['status']),
      // ✅ NUEVOS CAMPOS DE SERVICEMODE
      serviceMode: serviceMode,
      isHomeService: isHomeService,
      isInSiteService: isInSiteService,
      isHybridService: isHybridService,
      // ✅ FIX: CAMPOS CALCULADOS DESDE MÉTRICAS
      appointmentsCount: (data['appointmentsCount'] as int?) ??
          (data['metrics'] != null
              ? ClientMetrics.fromMap(data['metrics']).appointmentsCount
              : 0),
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ??
          (data['metrics'] != null
              ? ClientMetrics.fromMap(data['metrics']).totalRevenue
              : 0.0),
      lastAppointment: (data['lastAppointment'] != null
          ? _parseDateTime(data['lastAppointment'])
          : (data['metrics'] != null
              ? ClientMetrics.fromMap(data['metrics']).lastAppointment
              : null)),
    );
  }

  /// ✅ NUEVO: PARSER PARA SERVICEMODE
  static ClientServiceMode _parseServiceMode(String? serviceModeString) {
    if (serviceModeString == null || serviceModeString.isEmpty) {
      debugPrint('⚠️ ServiceMode null/empty, usando default: sucursal');
      return ClientServiceMode.sucursal;
    }

    switch (serviceModeString.toLowerCase()) {
      case 'domicilio':
        return ClientServiceMode.domicilio;
      case 'ambos':
        return ClientServiceMode.ambos;
      case 'sucursal':
      default:
        return ClientServiceMode.sucursal;
    }
  }

  /// 💾 CONVERSIÓN A MAP PARA FIRESTORE - ✅ FIX CRÍTICO: MÉTRICAS EN ROOT + SERVICEMODE
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      // ✅ CAMPOS COMPATIBLES CON ESTRUCTURA EXISTENTE
      'nombre': personalInfo.nombre,
      'apellidos': personalInfo.apellidos,
      'correo': contactInfo.email,
      'telefono': contactInfo.telefono,
      'empresa': personalInfo.empresa,
      'calle': addressInfo.calle,
      'numeroExterior': addressInfo.numeroExterior,
      'numeroInterior': addressInfo.numeroInterior,
      'colonia': addressInfo.colonia,
      'codigoPostal': addressInfo.codigoPostal,
      'alcaldia': addressInfo.alcaldia,

      // ✅ TAGS EN FORMATO COMPATIBLE
      'tiposCliente': tags.map((tag) => tag.toMap()).toList(),

      // ✅ FIX CRÍTICO: MÉTRICAS EN ROOT LEVEL PARA COMPATIBILIDAD
      'appointmentsCount': metrics.appointmentsCount,
      'attendedAppointments': metrics.attendedAppointments,
      'cancelledAppointments': metrics.cancelledAppointments,
      'noShowAppointments': metrics.noShowAppointments,
      'totalRevenue': metrics.totalRevenue,
      'averageTicket': metrics.averageTicket,
      'satisfactionScore': metrics.satisfactionScore,
      'lastAppointment': metrics.lastAppointment != null
          ? Timestamp.fromDate(metrics.lastAppointment!)
          : null,
      'nextAppointment': metrics.nextAppointment != null
          ? Timestamp.fromDate(metrics.nextAppointment!)
          : null,
      'loyaltyPoints': metrics.loyaltyPoints,

      // ✅ MÉTRICAS TAMBIÉN COMO OBJETO (PARA FLEXIBILIDAD)
      'metrics': metrics.toMap(),

      // ✅ CAMPOS ENTERPRISE
      'auditInfo': auditInfo.toMap(),
      'status': status.name,

      // ✅ FIX CRÍTICO: CAMPOS DE SERVICEMODE
      'serviceMode': serviceMode.name,
      'isHomeService': isHomeService,
      'isInSiteService': isInSiteService,
      'isHybridService': isHybridService,

      // ✅ TIMESTAMPS
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Agregar campos específicos de PersonalInfo, ContactInfo, AddressInfo
    map.addAll(personalInfo.toMap());
    map.addAll(contactInfo.toMap());
    map.addAll(addressInfo.toMap());

    // Remover campos null EXCEPTO serviceMode
    map.removeWhere((key, value) =>
        value == null &&
        !['serviceMode', 'isHomeService', 'isInSiteService', 'isHybridService']
            .contains(key));

    // ✅ LOG CRÍTICO PARA VERIFICAR DATOS
    debugPrint('💾 ClientModel.toMap() generado:');
    debugPrint('   - serviceMode: ${map['serviceMode']}');
    debugPrint('   - appointmentsCount: ${map['appointmentsCount']}');
    debugPrint('   - totalRevenue: ${map['totalRevenue']}');
    debugPrint('   - metrics object: ${map['metrics'] != null}');

    return map;
  }

  /// 📋 GETTERS DE COMPATIBILIDAD (Para widgets existentes)
  String get fullName =>
      '${personalInfo.nombre} ${personalInfo.apellidos}'.trim();
  String get displayName => fullName;
  String get email => contactInfo.email;
  String get phone => contactInfo.telefono;
  String get empresa => personalInfo.empresa ?? '';
  String get direccionCompleta => addressInfo.fullAddress;

  /// 🎯 GETTERS ENTERPRISE
  bool get isVIP => hasTag('VIP');
  bool get isCorporate => hasTag('Corporativo');
  bool get isNew => hasTag('Nuevo');
  bool get isActive => status == ClientStatus.active;
  bool get hasAppointments => appointmentsCount > 0;

  double get avgSatisfaction => metrics.satisfactionScore;
  String get statusDisplayName => status.displayName;
  Color get statusColor => status.color;

  /// ✅ NUEVOS GETTERS PARA SERVICEMODE + AMBOS
  String get serviceModeLabel => serviceMode.label;
  String get serviceModeIcon => serviceMode.icon;
  String get serviceModeDescription => serviceMode.description;

  /// 🏷️ MÉTODOS DE TAGS
  bool hasTag(String tagLabel) {
    return tags.any((tag) => tag.label.toLowerCase() == tagLabel.toLowerCase());
  }

  List<ClientTag> get baseTags =>
      tags.where((tag) => tag.type == TagType.base).toList();
  List<ClientTag> get customTags =>
      tags.where((tag) => tag.type == TagType.custom).toList();
  List<ClientTag> get systemTags =>
      tags.where((tag) => tag.type == TagType.system).toList();

  /// 🔍 MÉTODOS DE BÚSQUEDA Y FILTROS
  bool matchesSearchQuery(String query) {
    if (query.isEmpty) return true;

    final searchTerms = query.toLowerCase().split(' ');
    final searchableText = '''
      ${personalInfo.nombre} 
      ${personalInfo.apellidos} 
      ${contactInfo.email} 
      ${contactInfo.telefono} 
      ${personalInfo.empresa ?? ''} 
      ${addressInfo.fullAddress}
      ${tags.map((t) => t.label).join(' ')}
      ${serviceMode.label}
    '''
        .toLowerCase();

    return searchTerms.every((term) => searchableText.contains(term));
  }

  bool matchesFilter(ClientFilterCriteria criteria) {
    // Status filter
    if (criteria.statuses.isNotEmpty && !criteria.statuses.contains(status)) {
      return false;
    }

    // Tag filter
    if (criteria.tags.isNotEmpty) {
      final hasRequiredTag = criteria.tags.any((tag) => hasTag(tag));
      if (!hasRequiredTag) return false;
    }

    // Date range filter
    if (criteria.dateRange != null) {
      if (createdAt.isBefore(criteria.dateRange!.start) ||
          createdAt.isAfter(criteria.dateRange!.end)) {
        return false;
      }
    }

    // Location filter
    if (criteria.alcaldias.isNotEmpty &&
        !criteria.alcaldias.contains(addressInfo.alcaldia)) {
      return false;
    }

    // Metrics filter
    if (criteria.minAppointments != null &&
        appointmentsCount < criteria.minAppointments!) {
      return false;
    }

    return true;
  }

  /// 📊 MÉTODOS DE ANALYTICS - ✅ CON SERVICEMODE
  Map<String, dynamic> getAnalyticsSummary() {
    return {
      'clientId': clientId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'status': status.name,
      'appointmentsCount': appointmentsCount,
      'totalRevenue': totalRevenue,
      'avgSatisfaction': avgSatisfaction,
      'tags': tags.map((t) => t.label).toList(),
      'lastAppointment': lastAppointment?.toIso8601String(),
      'memberSince': createdAt.toIso8601String(),
      'lastUpdated': updatedAt.toIso8601String(),
      // ✅ NUEVOS CAMPOS DE ANALYTICS
      'serviceMode': serviceMode.name,
      'serviceModeLabel': serviceMode.label,
      'isHomeService': isHomeService,
      'isInSiteService': isInSiteService,
      'isHybridService': isHybridService,
    };
  }

  /// 🔄 COPYWITH PARA IMMUTABILIDAD - ✅ CON SERVICEMODE
  ClientModel copyWith({
    String? clientId,
    PersonalInfo? personalInfo,
    ContactInfo? contactInfo,
    AddressInfo? addressInfo,
    List<ClientTag>? tags,
    ClientMetrics? metrics,
    AuditInfo? auditInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
    ClientStatus? status,
    int? appointmentsCount,
    double? totalRevenue,
    DateTime? lastAppointment,
    // ✅ NUEVOS PARÁMETROS
    ClientServiceMode? serviceMode,
    bool? isHomeService,
    bool? isInSiteService,
    bool? isHybridService,
  }) {
    return ClientModel(
      clientId: clientId ?? this.clientId,
      personalInfo: personalInfo ?? this.personalInfo,
      contactInfo: contactInfo ?? this.contactInfo,
      addressInfo: addressInfo ?? this.addressInfo,
      tags: tags ?? this.tags,
      metrics: metrics ?? this.metrics,
      auditInfo: auditInfo ?? this.auditInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      status: status ?? this.status,
      appointmentsCount: appointmentsCount ?? this.appointmentsCount,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      lastAppointment: lastAppointment ?? this.lastAppointment,
      // ✅ NUEVOS CAMPOS
      serviceMode: serviceMode ?? this.serviceMode,
      isHomeService: isHomeService ?? this.isHomeService,
      isInSiteService: isInSiteService ?? this.isInSiteService,
      isHybridService: isHybridService ?? this.isHybridService,
    );
  }

  /// 🔄 MÉTODOS DE MODIFICACIÓN
  ClientModel addTag(ClientTag tag) {
    if (hasTag(tag.label)) return this;
    final newTags = List<ClientTag>.from(tags)..add(tag);
    return copyWith(tags: newTags);
  }

  ClientModel removeTag(String tagLabel) {
    final newTags = tags.where((tag) => tag.label != tagLabel).toList();
    return copyWith(tags: newTags);
  }

  ClientModel updateStatus(ClientStatus newStatus) {
    return copyWith(status: newStatus);
  }

  /// ✅ NUEVO: ACTUALIZAR SERVICEMODE
  ClientModel updateServiceMode(ClientServiceMode newServiceMode) {
    return copyWith(
      serviceMode: newServiceMode,
      isHomeService: newServiceMode == ClientServiceMode.domicilio ||
          newServiceMode == ClientServiceMode.ambos,
      isInSiteService: newServiceMode == ClientServiceMode.sucursal ||
          newServiceMode == ClientServiceMode.ambos,
      isHybridService: newServiceMode == ClientServiceMode.ambos,
    );
  }

  ClientModel updateMetrics({
    int? appointmentsCount,
    double? totalRevenue,
    double? satisfactionScore,
    DateTime? lastAppointment,
  }) {
    final newMetrics = metrics.copyWith(
      appointmentsCount: appointmentsCount,
      totalRevenue: totalRevenue,
      satisfactionScore: satisfactionScore,
      lastAppointment: lastAppointment,
    );
    return copyWith(
      metrics: newMetrics,
      appointmentsCount: appointmentsCount ?? this.appointmentsCount,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      lastAppointment: lastAppointment ?? this.lastAppointment,
    );
  }

  /// 🔧 MÉTODOS HELPER ESTÁTICOS
  static List<ClientTag> _parseClientTags(dynamic tagsData) {
    if (tagsData is! List) return [];

    return tagsData
        .map((tagData) {
          if (tagData is String) {
            return ClientTag(
              label: tagData,
              type: _isBaseTag(tagData) ? TagType.base : TagType.custom,
              createdAt: DateTime.now(),
            );
          } else if (tagData is Map<String, dynamic>) {
            return ClientTag.fromMap(tagData);
          }
          return null;
        })
        .where((tag) => tag != null)
        .cast<ClientTag>()
        .toList();
  }

  static bool _isBaseTag(String label) {
    const baseTags = [
      'VIP',
      'Corporativo',
      'Nuevo',
      'Recurrente',
      'Promoción',
      'Consentido',
      'Especial'
    ];
    return baseTags.any((base) => base.toLowerCase() == label.toLowerCase());
  }

  static ClientStatus _parseClientStatus(dynamic status) {
    if (status == null) return ClientStatus.active;
    return ClientStatus.values.firstWhere(
      (s) => s.name == status.toString(),
      orElse: () => ClientStatus.active,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// ⚖️ COMPARACIÓN PARA ORDENAMIENTO
  int compareTo(ClientModel other) {
    return fullName.toLowerCase().compareTo(other.fullName.toLowerCase());
  }

  /// 🎯 EQUALITY Y HASHCODE
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientModel &&
          runtimeType == other.runtimeType &&
          clientId == other.clientId;

  @override
  int get hashCode => clientId.hashCode;

  /// 🖨️ TO STRING PARA DEBUG - ✅ CON SERVICEMODE
  @override
  String toString() {
    return 'ClientModel{id: $clientId, name: $fullName, status: ${status.name}, serviceMode: ${serviceMode.label}, tags: ${tags.length}}';
  }
}
