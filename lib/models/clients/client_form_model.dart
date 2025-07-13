// [client_form_model.dart] - MODELO ENTERPRISE PARA FORMULARIO DE CLIENTE - ✅ FIX: VALIDACIÓN INTERNACIONAL + MODO SERVICIO + AMBOS + MÉTRICAS + fechaNacimiento
// 📁 Ubicación: /lib/models/clients/client_form_model.dart
// 🎯 OBJETIVO: Modelo robusto para el formulario con validaciones enterprise + modo híbrido + AMBOS + MÉTRICAS INICIALIZADAS + fechaNacimiento
// ✅ FIX: Validación internacional de teléfonos + dirección opcional + modo de servicio + AMBOS + MÉTRICAS COMPLETAS + fechaNacimiento

import 'package:flutter/foundation.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/models/company/company_settings_model.dart';

/// 📋 MODELO PRINCIPAL DEL FORMULARIO - ✅ CON MODO DE SERVICIO + AMBOS
class ClientFormModel {
  final PersonalFormInfo personalInfo;
  final AddressFormInfo addressInfo;
  final TagsFormInfo tagsInfo;
  final ClientFormValidation validation;
  final bool isEditing;
  final String? clientId;
  final ClientServiceMode serviceMode; // ✅ MODO DE SERVICIO + AMBOS

  const ClientFormModel({
    required this.personalInfo,
    required this.addressInfo,
    required this.tagsInfo,
    required this.validation,
    this.isEditing = false,
    this.clientId,
    this.serviceMode = ClientServiceMode.sucursal, // ✅ DEFAULT SEGURO
  });

  /// 🏗️ FACTORY CONSTRUCTOR VACÍO
  factory ClientFormModel.empty() {
    return ClientFormModel(
      personalInfo: PersonalFormInfo.empty(),
      addressInfo: AddressFormInfo.empty(),
      tagsInfo: TagsFormInfo.empty(),
      validation: ClientFormValidation.empty(),
      serviceMode: ClientServiceMode.sucursal, // ✅ DEFAULT SEGURO
    );
  }

  /// 🏗️ FACTORY DESDE CLIENTE EXISTENTE - ✅ FIX: LECTURA CORRECTA DE SERVICEMODE
  factory ClientFormModel.fromClient(ClientModel client) {
    debugPrint(
        '📖 ClientFormModel.fromClient: Cargando cliente ${client.fullName}');
    debugPrint('   - ServiceMode leído: ${client.serviceMode.label}');
    debugPrint('   - isHomeService: ${client.isHomeService}');
    debugPrint('   - isInSiteService: ${client.isInSiteService}');
    debugPrint('   - isHybridService: ${client.isHybridService}');

    return ClientFormModel(
      personalInfo: PersonalFormInfo(
        nombre: client.personalInfo.nombre,
        apellidos: client.personalInfo.apellidos,
        email: client.contactInfo.email,
        telefono: client.contactInfo.telefono,
        empresa: client.personalInfo.empresa,
        fechaNacimiento: client.personalInfo.fechaNacimiento, // ✅ NUEVO
      ),
      addressInfo: AddressFormInfo(
        calle: client.addressInfo.calle,
        numeroExterior: client.addressInfo.numeroExterior,
        numeroInterior: client.addressInfo.numeroInterior,
        colonia: client.addressInfo.colonia,
        codigoPostal: client.addressInfo.codigoPostal,
        alcaldia: client.addressInfo.alcaldia,
      ),
      tagsInfo: TagsFormInfo.fromClientTags(client.tags),
      validation: ClientFormValidation.empty(),
      isEditing: true,
      clientId: client.clientId,
      serviceMode: client.serviceMode, // ✅ FIX: PRESERVAR SERVICEMODE CORRECTO
    );
  }

  /// 🔄 COPYWITH PARA IMMUTABILIDAD - ✅ CON MODO DE SERVICIO + AMBOS
  ClientFormModel copyWith({
    PersonalFormInfo? personalInfo,
    AddressFormInfo? addressInfo,
    TagsFormInfo? tagsInfo,
    ClientFormValidation? validation,
    bool? isEditing,
    String? clientId,
    ClientServiceMode? serviceMode, // ✅ PARÁMETRO + AMBOS
  }) {
    return ClientFormModel(
      personalInfo: personalInfo ?? this.personalInfo,
      addressInfo: addressInfo ?? this.addressInfo,
      tagsInfo: tagsInfo ?? this.tagsInfo,
      validation: validation ?? this.validation,
      isEditing: isEditing ?? this.isEditing,
      clientId: clientId ?? this.clientId,
      serviceMode: serviceMode ?? this.serviceMode, // ✅ + AMBOS
    );
  }

  /// ✅ VALIDACIÓN COMPLETA DEL FORMULARIO - ✅ CON VALIDACIÓN CONDICIONAL + AMBOS
  bool get isValid {
    final basicValidation = validation.isValid && personalInfo.isValid;

    // ✅ NUEVA LÓGICA: Validación de dirección basada en modo de servicio + AMBOS
    if (serviceMode == ClientServiceMode.domicilio) {
      // Para servicios a domicilio, validar dirección básica
      return basicValidation && _isAddressValidForHomeService;
    }

    // ✅ NUEVO: Para modo ambos, dirección opcional pero válida si se proporciona
    if (serviceMode == ClientServiceMode.ambos) {
      // Para clientes híbridos: validación básica + dirección opcional válida
      return basicValidation && addressInfo.isValid;
    }

    // Para servicios en sucursal, dirección es opcional
    return basicValidation && addressInfo.isValid;
  }

  /// ✅ VALIDACIÓN DE DIRECCIÓN PARA SERVICIOS A DOMICILIO
  bool get _isAddressValidForHomeService {
    return addressInfo.calle.trim().isNotEmpty &&
        addressInfo.numeroExterior.trim().isNotEmpty &&
        addressInfo.colonia.trim().isNotEmpty &&
        addressInfo.alcaldia.trim().isNotEmpty &&
        (addressInfo.codigoPostal.trim().isEmpty ||
            _isValidCP(addressInfo.codigoPostal));
  }

  /// ✅ GETTERS DE CONVENIENCIA PARA MODO DE SERVICIO + AMBOS
  bool get isHomeService =>
      serviceMode == ClientServiceMode.domicilio ||
      serviceMode == ClientServiceMode.ambos;
  bool get isInSiteService =>
      serviceMode == ClientServiceMode.sucursal ||
      serviceMode == ClientServiceMode.ambos;
  bool get isHybridService => serviceMode == ClientServiceMode.ambos; // ✅ NUEVO
  String get serviceModeLabel => serviceMode.label;
  String get serviceModeIcon => serviceMode.icon;

  /// 📊 CONVERSIÓN A CLIENT MODEL - ✅ FIX COMPLETO: MÉTRICAS + SERVICEMODE
  ClientModel toClientModel() {
    return ClientModel(
      clientId: clientId ?? '',
      personalInfo: PersonalInfo(
        nombre: personalInfo.nombre,
        apellidos: personalInfo.apellidos,
        empresa: personalInfo.empresa?.isNotEmpty == true
            ? personalInfo.empresa
            : null,
        fechaNacimiento: personalInfo.fechaNacimiento, // ✅ NUEVO
      ),
      contactInfo: ContactInfo(
        email: personalInfo.email,
        telefono: personalInfo.telefono,
      ),
      addressInfo: AddressInfo(
        calle: addressInfo.calle,
        numeroExterior: addressInfo.numeroExterior,
        numeroInterior: addressInfo.numeroInterior?.isNotEmpty == true
            ? addressInfo.numeroInterior
            : null,
        colonia: addressInfo.colonia,
        codigoPostal: addressInfo.codigoPostal,
        alcaldia: addressInfo.alcaldia,
      ),
      tags: _generateTagsWithServiceMode(),

      // ✅ FIX CRÍTICO: MÉTRICAS COMPLETAS INICIALIZADAS
      metrics: ClientMetrics(
        appointmentsCount: 0,
        attendedAppointments: 0,
        cancelledAppointments: 0,
        noShowAppointments: 0,
        totalRevenue: 0.0,
        averageTicket: 0.0,
        satisfactionScore: 0.0,
        lastAppointment: null,
        nextAppointment: null,
        loyaltyPoints: 0,
      ),

      // ✅ FIX: AUDITINFO COMPLETO
      auditInfo: AuditInfo(
        createdBy: 'wizard_form',
        lastModifiedBy: null,
        logs: [],
        metadata: {
          'source': 'client_wizard',
          'form_version': '1.0',
          'serviceMode': serviceMode.name,
          'createdVia': 'client_form_modal',
        },
      ),

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),

      // ✅ SERVICEMODE PRESERVADO
      serviceMode: serviceMode,
      isHomeService: isHomeService,
      isInSiteService: isInSiteService,
      isHybridService: isHybridService,

      // ✅ CAMPOS CALCULADOS INICIALIZADOS
      appointmentsCount: 0,
      totalRevenue: 0.0,
      lastAppointment: null,
    );
  }

  /// ✅ ACTUALIZADO: GENERAR TAGS INCLUYENDO MODO DE SERVICIO + AMBOS
  List<ClientTag> _generateTagsWithServiceMode() {
    final tags = tagsInfo.getAllTags();

    // Agregar tag automático según modo de servicio + AMBOS
    final serviceModeTag = ClientTag(
      label: serviceMode == ClientServiceMode.domicilio
          ? 'Domicilio'
          : (serviceMode == ClientServiceMode.ambos
              ? 'Híbrido' // ✅ NUEVO
              : 'Sucursal'),
      color: serviceMode == ClientServiceMode.domicilio
          ? '#2196F3'
          : (serviceMode == ClientServiceMode.ambos
              ? '#9C27B0' // ✅ NUEVO - Morado para híbrido
              : '#4CAF50'),
      type: TagType.custom,
      createdAt: DateTime.now(),
    );

    // Verificar que no existe ya este tag para evitar duplicados + AMBOS
    final existingModeTag = tags.any((tag) =>
        tag.label == 'Domicilio' ||
        tag.label == 'Sucursal' ||
        tag.label == 'Híbrido'); // ✅ NUEVO

    if (!existingModeTag) {
      tags.add(serviceModeTag);
    }

    return tags;
  }

  /// 📋 DATOS PARA FIRESTORE - ✅ CON MODO DE SERVICIO + AMBOS
  Map<String, dynamic> toFirestoreMap() {
    final client = toClientModel();
    final map = client.toMap();

    // ✅ AGREGAR MODO DE SERVICIO A FIRESTORE + AMBOS
    map['serviceMode'] = serviceMode.name;
    map['isHomeService'] = isHomeService;
    map['isInSiteService'] = isInSiteService; // ✅ NUEVO
    map['isHybridService'] = isHybridService; // ✅ NUEVO

    return map;
  }

  /// ✅ ACTUALIZADO: DETECTAR MODO DESDE CLIENTE EXISTENTE + AMBOS
  static ClientServiceMode _detectServiceModeFromClient(ClientModel client) {
    // Buscar en las tags si hay indicador de modo de servicio + AMBOS
    final hasHybridTag = client.tags.any((tag) =>
        tag.label.toLowerCase().contains('híbrido') ||
        tag.label.toLowerCase().contains('ambos') ||
        tag.label.toLowerCase().contains('hybrid'));

    if (hasHybridTag) {
      return ClientServiceMode.ambos; // ✅ NUEVO
    }

    final hasHomeServiceTag = client.tags.any((tag) =>
        tag.label.toLowerCase().contains('domicilio') ||
        tag.label.toLowerCase().contains('home') ||
        tag.label.toLowerCase().contains('móvil'));

    if (hasHomeServiceTag) {
      return ClientServiceMode.domicilio;
    }

    // Si tiene dirección completa, es probable que sea servicio a domicilio
    final hasCompleteAddress = client.addressInfo.calle.isNotEmpty &&
        client.addressInfo.numeroExterior.isNotEmpty &&
        client.addressInfo.colonia.isNotEmpty;

    if (hasCompleteAddress) {
      return ClientServiceMode.domicilio;
    }

    // Por defecto, asumir sucursal
    return ClientServiceMode.sucursal;
  }

  /// ✅ HELPER PARA VALIDAR CP
  bool _isValidCP(String cp) {
    final cleaned = cp.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length == 5;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientFormModel &&
          runtimeType == other.runtimeType &&
          personalInfo == other.personalInfo &&
          addressInfo == other.addressInfo &&
          tagsInfo == other.tagsInfo &&
          serviceMode == other.serviceMode; // ✅ INCLUIR EN COMPARACIÓN

  @override
  int get hashCode =>
      personalInfo.hashCode ^
      addressInfo.hashCode ^
      tagsInfo.hashCode ^
      serviceMode.hashCode; // ✅ INCLUIR EN HASH

  @override
  String toString() {
    return 'ClientFormModel{nombre: ${personalInfo.nombre}, mode: ${serviceMode.label}, isValid: $isValid, isEditing: $isEditing}';
  }
}

/// 👤 INFORMACIÓN PERSONAL DEL FORMULARIO - ✅ CON FECHA DE NACIMIENTO
class PersonalFormInfo {
  final String nombre;
  final String apellidos;
  final String email;
  final String telefono;
  final String? empresa;
  final DateTime? fechaNacimiento; // ✅ NUEVO CAMPO AGREGADO

  const PersonalFormInfo({
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.telefono,
    this.empresa,
    this.fechaNacimiento, // ✅ NUEVO PARÁMETRO
  });

  factory PersonalFormInfo.empty() {
    return const PersonalFormInfo(
      nombre: '',
      apellidos: '',
      email: '',
      telefono: '',
      empresa: '',
      fechaNacimiento: null, // ✅ NULL POR DEFECTO
    );
  }

  PersonalFormInfo copyWith({
    String? nombre,
    String? apellidos,
    String? email,
    String? telefono,
    String? empresa,
    DateTime? fechaNacimiento, // ✅ NUEVO PARÁMETRO EN COPYWITH
  }) {
    return PersonalFormInfo(
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      empresa: empresa ?? this.empresa,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento, // ✅ NUEVO
    );
  }

  /// ✅ VALIDACIÓN CON TELÉFONO INTERNACIONAL
  bool get isValid {
    return nombre.trim().isNotEmpty &&
        apellidos.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        telefono.trim().isNotEmpty &&
        _isValidEmail(email) &&
        _isValidInternationalPhone(telefono);
  }

  String get fullName => '$nombre $apellidos'.trim();

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim());
  }

  /// ✅ VALIDACIÓN INTERNACIONAL DE TELÉFONOS
  bool _isValidInternationalPhone(String phone) {
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalFormInfo &&
          runtimeType == other.runtimeType &&
          nombre == other.nombre &&
          apellidos == other.apellidos &&
          email == other.email &&
          telefono == other.telefono &&
          empresa == other.empresa &&
          fechaNacimiento == other.fechaNacimiento; // ✅ INCLUIR EN EQUALS

  @override
  int get hashCode =>
      nombre.hashCode ^
      apellidos.hashCode ^
      email.hashCode ^
      telefono.hashCode ^
      empresa.hashCode ^
      fechaNacimiento.hashCode; // ✅ INCLUIR EN HASH
}

/// 🏠 INFORMACIÓN DE DIRECCIÓN DEL FORMULARIO - ✅ CON VALIDACIÓN CONDICIONAL + AMBOS
class AddressFormInfo {
  final String calle;
  final String numeroExterior;
  final String? numeroInterior;
  final String colonia;
  final String codigoPostal;
  final String alcaldia;

  const AddressFormInfo({
    required this.calle,
    required this.numeroExterior,
    this.numeroInterior,
    required this.colonia,
    required this.codigoPostal,
    required this.alcaldia,
  });

  factory AddressFormInfo.empty() {
    return const AddressFormInfo(
      calle: '',
      numeroExterior: '',
      numeroInterior: '',
      colonia: '',
      codigoPostal: '',
      alcaldia: '',
    );
  }

  AddressFormInfo copyWith({
    String? calle,
    String? numeroExterior,
    String? numeroInterior,
    String? colonia,
    String? codigoPostal,
    String? alcaldia,
  }) {
    return AddressFormInfo(
      calle: calle ?? this.calle,
      numeroExterior: numeroExterior ?? this.numeroExterior,
      numeroInterior: numeroInterior ?? this.numeroInterior,
      colonia: colonia ?? this.colonia,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      alcaldia: alcaldia ?? this.alcaldia,
    );
  }

  /// ✅ VALIDACIÓN ORIGINAL (DIRECCIÓN OPCIONAL)
  bool get isValid {
    // Dirección es completamente opcional por defecto
    if (codigoPostal.trim().isNotEmpty && !_isValidCP(codigoPostal)) {
      return false;
    }
    return true;
  }

  /// ✅ VALIDACIÓN PARA SERVICIOS A DOMICILIO
  bool get isValidForHomeService {
    // Para servicios a domicilio: campos básicos requeridos
    return calle.trim().isNotEmpty &&
        numeroExterior.trim().isNotEmpty &&
        colonia.trim().isNotEmpty &&
        alcaldia.trim().isNotEmpty &&
        (codigoPostal.trim().isEmpty || _isValidCP(codigoPostal));
  }

  /// ✅ ACTUALIZADO: VALIDACIÓN CONDICIONAL BASADA EN MODO + AMBOS
  bool isValidForServiceMode(ClientServiceMode mode) {
    switch (mode) {
      case ClientServiceMode.sucursal:
        return isValid; // Dirección opcional
      case ClientServiceMode.domicilio:
        return isValidForHomeService; // Dirección requerida
      case ClientServiceMode.ambos: // ✅ NUEVO
        return isValid; // Dirección opcional pero recomendada // ✅ NUEVO
    }
  }

  /// ✅ VERIFICAR SI HAY DATOS DE DIRECCIÓN
  bool get hasAddressData {
    return calle.trim().isNotEmpty ||
        numeroExterior.trim().isNotEmpty ||
        colonia.trim().isNotEmpty ||
        codigoPostal.trim().isNotEmpty ||
        alcaldia.trim().isNotEmpty;
  }

  /// ✅ VERIFICAR SI LA DIRECCIÓN ESTÁ COMPLETA PARA DOMICILIO
  bool get isCompleteForHomeService {
    return calle.trim().isNotEmpty &&
        numeroExterior.trim().isNotEmpty &&
        colonia.trim().isNotEmpty &&
        alcaldia.trim().isNotEmpty;
  }

  /// ✅ NUEVO: VERIFICAR SI LA DIRECCIÓN ESTÁ RECOMENDADA PARA AMBOS
  bool get isRecommendedForHybridService {
    // Para clientes híbridos: dirección útil pero no obligatoria
    return calle.trim().isNotEmpty || colonia.trim().isNotEmpty;
  }

  String get fullAddress {
    final parts = <String>[];
    if (calle.isNotEmpty) parts.add(calle);
    if (numeroExterior.isNotEmpty) parts.add('No. $numeroExterior');
    if (numeroInterior != null && numeroInterior!.isNotEmpty) {
      parts.add('Int. $numeroInterior');
    }
    if (colonia.isNotEmpty) parts.add(colonia);
    if (alcaldia.isNotEmpty) parts.add(alcaldia);
    if (codigoPostal.isNotEmpty) parts.add('CP $codigoPostal');
    return parts.join(', ');
  }

  bool _isValidCP(String cp) {
    final cleaned = cp.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length == 5;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressFormInfo &&
          runtimeType == other.runtimeType &&
          calle == other.calle &&
          numeroExterior == other.numeroExterior &&
          numeroInterior == other.numeroInterior &&
          colonia == other.colonia &&
          codigoPostal == other.codigoPostal &&
          alcaldia == other.alcaldia;

  @override
  int get hashCode =>
      calle.hashCode ^
      numeroExterior.hashCode ^
      numeroInterior.hashCode ^
      colonia.hashCode ^
      codigoPostal.hashCode ^
      alcaldia.hashCode;
}

/// 🏷️ INFORMACIÓN DE ETIQUETAS DEL FORMULARIO
class TagsFormInfo {
  final Set<String> baseTags;
  final List<String> customTags;

  const TagsFormInfo({
    required this.baseTags,
    required this.customTags,
  });

  factory TagsFormInfo.empty() {
    return const TagsFormInfo(
      baseTags: <String>{},
      customTags: <String>[],
    );
  }

  factory TagsFormInfo.fromClientTags(List<ClientTag> clientTags) {
    final Set<String> baseTags = {};
    final List<String> customTags = [];

    const baseTagLabels = [
      'VIP',
      'Corporativo',
      'Nuevo',
      'Recurrente',
      'Promoción',
      'Consentido',
      'Especial'
    ];

    for (final tag in clientTags) {
      if (baseTagLabels.contains(tag.label)) {
        baseTags.add(tag.label);
      } else if (tag.label != 'Domicilio' &&
          tag.label != 'Sucursal' &&
          tag.label != 'Híbrido') {
        // ✅ FILTRAR TAGS DE MODO DE SERVICIO + AMBOS
        customTags.add(tag.label);
      }
    }

    return TagsFormInfo(
      baseTags: baseTags,
      customTags: customTags,
    );
  }

  TagsFormInfo copyWith({
    Set<String>? baseTags,
    List<String>? customTags,
  }) {
    return TagsFormInfo(
      baseTags: baseTags ?? this.baseTags,
      customTags: customTags ?? this.customTags,
    );
  }

  TagsFormInfo addBaseTag(String tag) {
    final newBaseTags = Set<String>.from(baseTags)..add(tag);
    return copyWith(baseTags: newBaseTags);
  }

  TagsFormInfo removeBaseTag(String tag) {
    final newBaseTags = Set<String>.from(baseTags)..remove(tag);
    return copyWith(baseTags: newBaseTags);
  }

  TagsFormInfo addCustomTag(String tag) {
    if (tag.trim().isEmpty ||
        customTags.contains(tag) ||
        baseTags.contains(tag)) {
      return this;
    }
    final newCustomTags = List<String>.from(customTags)..add(tag.trim());
    return copyWith(customTags: newCustomTags);
  }

  TagsFormInfo removeCustomTag(String tag) {
    final newCustomTags = List<String>.from(customTags)..remove(tag);
    return copyWith(customTags: newCustomTags);
  }

  List<ClientTag> getAllTags() {
    final List<ClientTag> allTags = [];
    final now = DateTime.now();

    // Etiquetas base
    for (final tag in baseTags) {
      allTags.add(ClientTag(
        label: tag,
        type: TagType.base,
        createdAt: now,
      ));
    }

    // Etiquetas personalizadas
    for (int i = 0; i < customTags.length; i++) {
      final tag = customTags[i];
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
      final color = colors[i % colors.length];

      allTags.add(ClientTag(
        label: tag,
        color: color,
        type: TagType.custom,
        createdAt: now,
      ));
    }

    return allTags;
  }

  int get totalTags => baseTags.length + customTags.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagsFormInfo &&
          runtimeType == other.runtimeType &&
          setEquals(baseTags, other.baseTags) &&
          listEquals(customTags, other.customTags);

  @override
  int get hashCode => baseTags.hashCode ^ customTags.hashCode;
}

/// ✅ VALIDACIÓN DEL FORMULARIO
class ClientFormValidation {
  final Map<String, String?> fieldErrors;
  final List<String> globalErrors;
  final bool isValidating;

  const ClientFormValidation({
    required this.fieldErrors,
    required this.globalErrors,
    this.isValidating = false,
  });

  factory ClientFormValidation.empty() {
    return const ClientFormValidation(
      fieldErrors: {},
      globalErrors: [],
    );
  }

  ClientFormValidation copyWith({
    Map<String, String?>? fieldErrors,
    List<String>? globalErrors,
    bool? isValidating,
  }) {
    return ClientFormValidation(
      fieldErrors: fieldErrors ?? this.fieldErrors,
      globalErrors: globalErrors ?? this.globalErrors,
      isValidating: isValidating ?? this.isValidating,
    );
  }

  ClientFormValidation setFieldError(String field, String? error) {
    final newErrors = Map<String, String?>.from(fieldErrors);
    if (error == null) {
      newErrors.remove(field);
    } else {
      newErrors[field] = error;
    }
    return copyWith(fieldErrors: newErrors);
  }

  ClientFormValidation addGlobalError(String error) {
    final newGlobalErrors = List<String>.from(globalErrors)..add(error);
    return copyWith(globalErrors: newGlobalErrors);
  }

  ClientFormValidation clearErrors() {
    return ClientFormValidation.empty();
  }

  bool get isValid => fieldErrors.isEmpty && globalErrors.isEmpty;
  bool get hasErrors => fieldErrors.isNotEmpty || globalErrors.isNotEmpty;

  String? getFieldError(String field) => fieldErrors[field];
  bool hasFieldError(String field) => fieldErrors.containsKey(field);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientFormValidation &&
          runtimeType == other.runtimeType &&
          mapEquals(fieldErrors, other.fieldErrors) &&
          listEquals(globalErrors, other.globalErrors) &&
          isValidating == other.isValidating;

  @override
  int get hashCode =>
      fieldErrors.hashCode ^ globalErrors.hashCode ^ isValidating.hashCode;
}
