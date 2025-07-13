// [booking_submission_service.dart] - ✅ CORREGIDO: Todos los errores de tipos solucionados
// 📁 Ubicación: /lib/services/booking/booking_submission_service.dart
// 🎯 OBJETIVO: Una consulta inteligente + auto-creación de clientes nuevos
// ✅ CORREGIDO: Imports, enums y definiciones faltantes

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/appointment_model.dart';
import '../../models/clients/client_model.dart';
import '../../enums/booking_types.dart';
import 'booking_validation_service.dart';

// ============================================================================
// 🔧 DEFINICIONES REQUERIDAS (TEMPORALES HASTA QUE ESTÉN EN SUS ARCHIVOS)
// ============================================================================

/// 🏷️ ENUM PARA TIPO DE TAG
enum TagType {
  base('Base'),
  custom('Personalizado'),
  system('Sistema');

  const TagType(this.displayName);
  final String displayName;
}

/// 🚗 ENUM PARA MODO DE SERVICIO
enum ClientServiceMode {
  sucursal('Sucursal', 'local_hospital', 'Servicio en nuestras instalaciones'),
  domicilio('Domicilio', 'home', 'Servicio a domicilio del cliente'),
  ambos('Ambos', 'sync_alt', 'Servicio mixto: sucursal y domicilio');

  const ClientServiceMode(this.label, this.icon, this.description);

  final String label;
  final String icon;
  final String description;
}

/// 🏷️ CLASE PARA TAGS DE CLIENTE
class ClientTag {
  final String label;
  final TagType type;
  final DateTime createdAt;
  final String? color;
  final String? description;

  const ClientTag({
    required this.label,
    required this.type,
    required this.createdAt,
    this.color,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'color': color,
      'description': description,
    };
  }

  factory ClientTag.fromMap(Map<String, dynamic> map) {
    return ClientTag(
      label: map['label'] ?? '',
      type: TagType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => TagType.custom,
      ),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      color: map['color'],
      description: map['description'],
    );
  }
}

/// 👤 INFORMACIÓN PERSONAL SIMPLIFICADA
class PersonalInfo {
  final String nombre;
  final String apellidos;
  final String? empresa;

  const PersonalInfo({
    required this.nombre,
    required this.apellidos,
    this.empresa,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellidos': apellidos,
      'empresa': empresa,
    };
  }

  factory PersonalInfo.fromMap(Map<String, dynamic> map) {
    return PersonalInfo(
      nombre: map['nombre'] ?? '',
      apellidos: map['apellidos'] ?? '',
      empresa: map['empresa'],
    );
  }
}

/// 📞 INFORMACIÓN DE CONTACTO SIMPLIFICADA
class ContactInfo {
  final String telefono;
  final String? email;

  const ContactInfo({
    required this.telefono,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'telefono': telefono,
      'email': email,
    };
  }

  factory ContactInfo.fromMap(Map<String, dynamic> map) {
    return ContactInfo(
      telefono: map['telefono'] ?? '',
      email: map['email'],
    );
  }
}

/// 🏠 INFORMACIÓN DE DIRECCIÓN SIMPLIFICADA
class AddressInfo {
  final String? calle;
  final String? numeroExterior;
  final String? numeroInterior;
  final String? colonia;
  final String? codigoPostal;
  final String? alcaldia;

  const AddressInfo({
    this.calle,
    this.numeroExterior,
    this.numeroInterior,
    this.colonia,
    this.codigoPostal,
    this.alcaldia,
  });

  String get fullAddress {
    final parts = <String>[];
    if (calle != null && calle!.isNotEmpty) parts.add(calle!);
    if (numeroExterior != null && numeroExterior!.isNotEmpty)
      parts.add(numeroExterior!);
    if (numeroInterior != null && numeroInterior!.isNotEmpty)
      parts.add(numeroInterior!);
    if (colonia != null && colonia!.isNotEmpty) parts.add(colonia!);
    if (codigoPostal != null && codigoPostal!.isNotEmpty)
      parts.add(codigoPostal!);
    if (alcaldia != null && alcaldia!.isNotEmpty) parts.add(alcaldia!);
    return parts.join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'calle': calle,
      'numeroExterior': numeroExterior,
      'numeroInterior': numeroInterior,
      'colonia': colonia,
      'codigoPostal': codigoPostal,
      'alcaldia': alcaldia,
    };
  }

  factory AddressInfo.fromMap(Map<String, dynamic> map) {
    return AddressInfo(
      calle: map['calle'],
      numeroExterior: map['numeroExterior'],
      numeroInterior: map['numeroInterior'],
      colonia: map['colonia'],
      codigoPostal: map['codigoPostal'],
      alcaldia: map['alcaldia'],
    );
  }
}

/// 📊 MÉTRICAS DE CLIENTE SIMPLIFICADAS
class ClientMetrics {
  final int appointmentsCount;
  final int attendedAppointments;
  final int cancelledAppointments;
  final int noShowAppointments;
  final double totalRevenue;
  final double averageTicket;
  final double satisfactionScore;
  final DateTime? lastAppointment;
  final DateTime? nextAppointment;
  final int loyaltyPoints;

  const ClientMetrics({
    required this.appointmentsCount,
    required this.attendedAppointments,
    required this.cancelledAppointments,
    required this.noShowAppointments,
    required this.totalRevenue,
    required this.averageTicket,
    required this.satisfactionScore,
    this.lastAppointment,
    this.nextAppointment,
    required this.loyaltyPoints,
  });

  /// 🏗️ CONSTRUCTOR INICIAL
  factory ClientMetrics.initial() {
    return const ClientMetrics(
      appointmentsCount: 0,
      attendedAppointments: 0,
      cancelledAppointments: 0,
      noShowAppointments: 0,
      totalRevenue: 0.0,
      averageTicket: 0.0,
      satisfactionScore: 0.0,
      loyaltyPoints: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentsCount': appointmentsCount,
      'attendedAppointments': attendedAppointments,
      'cancelledAppointments': cancelledAppointments,
      'noShowAppointments': noShowAppointments,
      'totalRevenue': totalRevenue,
      'averageTicket': averageTicket,
      'satisfactionScore': satisfactionScore,
      'lastAppointment': lastAppointment?.toIso8601String(),
      'nextAppointment': nextAppointment?.toIso8601String(),
      'loyaltyPoints': loyaltyPoints,
    };
  }

  factory ClientMetrics.fromMap(Map<String, dynamic> map) {
    return ClientMetrics(
      appointmentsCount: map['appointmentsCount'] ?? 0,
      attendedAppointments: map['attendedAppointments'] ?? 0,
      cancelledAppointments: map['cancelledAppointments'] ?? 0,
      noShowAppointments: map['noShowAppointments'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
      averageTicket: (map['averageTicket'] ?? 0.0).toDouble(),
      satisfactionScore: (map['satisfactionScore'] ?? 0.0).toDouble(),
      lastAppointment: map['lastAppointment'] != null
          ? DateTime.tryParse(map['lastAppointment'])
          : null,
      nextAppointment: map['nextAppointment'] != null
          ? DateTime.tryParse(map['nextAppointment'])
          : null,
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
    );
  }

  ClientMetrics copyWith({
    int? appointmentsCount,
    int? attendedAppointments,
    int? cancelledAppointments,
    int? noShowAppointments,
    double? totalRevenue,
    double? averageTicket,
    double? satisfactionScore,
    DateTime? lastAppointment,
    DateTime? nextAppointment,
    int? loyaltyPoints,
  }) {
    return ClientMetrics(
      appointmentsCount: appointmentsCount ?? this.appointmentsCount,
      attendedAppointments: attendedAppointments ?? this.attendedAppointments,
      cancelledAppointments:
          cancelledAppointments ?? this.cancelledAppointments,
      noShowAppointments: noShowAppointments ?? this.noShowAppointments,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      averageTicket: averageTicket ?? this.averageTicket,
      satisfactionScore: satisfactionScore ?? this.satisfactionScore,
      lastAppointment: lastAppointment ?? this.lastAppointment,
      nextAppointment: nextAppointment ?? this.nextAppointment,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
    );
  }
}

/// 📋 INFORMACIÓN DE AUDITORÍA SIMPLIFICADA
class AuditInfo {
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final String source;
  final String? ipAddress;
  final String? userAgent;
  final String? sessionId;
  final String version;

  const AuditInfo({
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    required this.source,
    this.ipAddress,
    this.userAgent,
    this.sessionId,
    required this.version,
  });

  /// 🏗️ CONSTRUCTOR CREATE
  factory AuditInfo.create({
    required String source,
    String? createdBy,
  }) {
    final now = DateTime.now();
    final user = createdBy ?? 'sistema_automatico';

    return AuditInfo(
      createdBy: user,
      createdAt: now,
      updatedBy: user,
      updatedAt: now,
      source: source,
      ipAddress: null,
      userAgent: 'Flutter Web App',
      sessionId: null,
      version: '2.0',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedBy': updatedBy,
      'updatedAt': updatedAt.toIso8601String(),
      'source': source,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'sessionId': sessionId,
      'version': version,
    };
  }

  factory AuditInfo.fromMap(Map<String, dynamic> map) {
    return AuditInfo(
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedBy: map['updatedBy'] ?? '',
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      source: map['source'] ?? '',
      ipAddress: map['ipAddress'],
      userAgent: map['userAgent'],
      sessionId: map['sessionId'],
      version: map['version'] ?? '1.0',
    );
  }
}

/// 👤 MODELO DE CLIENTE SIMPLIFICADO PARA CREACIÓN
class ClientModel {
  final String clientId;
  final PersonalInfo personalInfo;
  final ContactInfo contactInfo;
  final AddressInfo addressInfo;
  final List<ClientTag> tags;
  final ClientMetrics metrics;
  final AuditInfo auditInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
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
    required this.serviceMode,
    required this.isHomeService,
    required this.isInSiteService,
    required this.isHybridService,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      // Campos compatibles con estructura existente
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

      // Tags en formato compatible
      'tiposCliente': tags.map((tag) => tag.toMap()).toList(),

      // Métricas en root level para compatibilidad
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

      // Métricas también como objeto
      'metrics': metrics.toMap(),

      // Campos enterprise
      'auditInfo': auditInfo.toMap(),
      'status': 'active',

      // Campos de serviceMode
      'serviceMode': serviceMode.name,
      'isHomeService': isHomeService,
      'isInSiteService': isInSiteService,
      'isHybridService': isHybridService,

      // Timestamps
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Agregar campos específicos
    map.addAll(personalInfo.toMap());
    map.addAll(contactInfo.toMap());
    map.addAll(addressInfo.toMap());

    // Remover campos null excepto serviceMode
    map.removeWhere((key, value) =>
        value == null &&
        !['serviceMode', 'isHomeService', 'isInSiteService', 'isHybridService']
            .contains(key));

    return map;
  }

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
      serviceMode: serviceMode ?? this.serviceMode,
      isHomeService: isHomeService ?? this.isHomeService,
      isInSiteService: isInSiteService ?? this.isInSiteService,
      isHybridService: isHybridService ?? this.isHybridService,
    );
  }
}

// ============================================================================
// 📤 SERVICIO DE ENVÍO DE BOOKING OPTIMIZADO
// ============================================================================

/// 📤 SERVICIO DE ENVÍO DE BOOKING OPTIMIZADO
/// ✅ Auto-creación inteligente de clientes + consulta única
class BookingSubmissionService {
  final FirebaseFirestore _firestore;

  BookingSubmissionService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 📤 ENVIAR BOOKING PRINCIPAL - ✅ OPTIMIZADO CON AUTO-CREACIÓN
  Future<SubmissionResult> submitBooking({
    required BookingType bookingType,
    required Map<String, dynamic> formData,
    required Map<String, dynamic> selectionData,
    Map<String, dynamic>? eventData,
    Map<String, dynamic>? companyData,
  }) async {
    try {
      debugPrint('📤 Iniciando envío de booking tipo: ${bookingType.name}');

      // 🔍 Validaciones locales primero (sin Firestore)
      final validation = BookingValidationService.validateBeforeSubmission(
        bookingType: bookingType,
        bookingData: {...formData, ...selectionData},
      );

      if (!validation.isValid) {
        return SubmissionResult.error(validation.message);
      }

      // 🎯 NUEVA ESTRATEGIA: UNA CONSULTA INTELIGENTE + AUTO-CREACIÓN
      final clientResult = await _handleClientCreationOrValidation(
        phone: formData['clientPhone'],
        bookingType: bookingType,
        formData: formData,
        companyData: companyData,
      );

      if (!clientResult.isSuccess) {
        return SubmissionResult.error(
            clientResult.error ?? 'Error procesando cliente');
      }

      // 🏗️ Construir AppointmentModel con cliente correcto
      final appointmentModel = await buildAppointmentData(
        bookingType: bookingType,
        formData: formData,
        selectionData: selectionData,
        eventData: eventData,
        companyData: companyData,
        clientId: clientResult.clientId, // ✅ USAR CLIENTE EXISTENTE O NUEVO
      );

      // 💾 Guardar cita en Firestore
      final docRef =
          await _firestore.collection('bookings').add(appointmentModel.toMap());

      debugPrint('✅ Booking guardado exitosamente: ${docRef.id}');
      debugPrint(
          '   - Cliente utilizado: ${clientResult.clientId} (${clientResult.wasCreated ? 'NUEVO' : 'EXISTENTE'})');

      // 📊 Registrar métricas de envío
      await _recordSubmissionMetrics(
          bookingType, docRef.id, clientResult.wasCreated);

      return SubmissionResult.success(
        bookingId: docRef.id,
        appointmentModel: appointmentModel.copyWith(id: docRef.id),
        message: 'Reserva creada exitosamente',
      );
    } catch (e) {
      debugPrint('❌ Error enviando booking: $e');
      return SubmissionResult.error('Error al crear la reserva: $e');
    }
  }

  /// 🎯 ESTRATEGIA HÍBRIDA: UNA CONSULTA + AUTO-CREACIÓN INTELIGENTE
  Future<ClientOperationResult> _handleClientCreationOrValidation({
    required String phone,
    required BookingType bookingType,
    required Map<String, dynamic> formData,
    Map<String, dynamic>? companyData,
  }) async {
    try {
      debugPrint('🔍 Procesando cliente con teléfono: $phone');

      // ✅ UNA SOLA QUERY PARA VERIFICAR EXISTENCIA
      final existingClientQuery = await _firestore
          .collection('clients')
          .where('telefono', isEqualTo: phone)
          .limit(1)
          .get();

      if (existingClientQuery.docs.isNotEmpty) {
        // 🎯 CLIENTE EXISTE - USAR EXISTENTE
        final clientDoc = existingClientQuery.docs.first;
        final clientData = clientDoc.data();

        debugPrint(
            '✅ Cliente existente encontrado: ${clientData['nombre']} ${clientData['apellidos'] ?? ''}');

        return ClientOperationResult.existing(
          clientId: clientDoc.id,
          clientData: clientData,
        );
      } else {
        // 🎯 CLIENTE NUEVO - AUTO-CREAR CON ESTRUCTURA COMPLETA
        debugPrint('🆕 Cliente nuevo detectado, creando automáticamente...');

        final newClientId = await _createNewClientWithStructure(
          formData: formData,
          bookingType: bookingType,
          companyData: companyData,
        );

        return ClientOperationResult.created(
          clientId: newClientId,
          clientData: formData,
        );
      }
    } catch (e) {
      debugPrint('❌ Error procesando cliente: $e');
      return ClientOperationResult.error('Error procesando cliente: $e');
    }
  }

  /// 🆕 CREAR CLIENTE NUEVO CON ESTRUCTURA CLIENTMODEL COMPLETA
  Future<String> _createNewClientWithStructure({
    required Map<String, dynamic> formData,
    required BookingType bookingType,
    Map<String, dynamic>? companyData,
  }) async {
    try {
      debugPrint('🏗️ Construyendo ClientModel completo para nuevo cliente');

      // 📝 EXTRAER NOMBRE Y APELLIDOS DEL FORMULARIO
      final nombreCompleto = formData['nombreCliente']?.toString() ?? '';
      final (nombre, apellidos) = _extractNameParts(nombreCompleto);

      // 🏗️ CONSTRUIR CLIENTMODEL CON ESTRUCTURA REAL DE TU SISTEMA
      final clientModel = ClientModel(
        clientId: '', // Se asignará después
        personalInfo: PersonalInfo(
          nombre: nombre,
          apellidos: apellidos,
          empresa: _determineCompanyName(bookingType, formData, companyData),
        ),
        contactInfo: ContactInfo(
          telefono: formData['clientPhone']?.toString() ?? '',
          email: formData['clientEmail']?.toString(),
        ),
        addressInfo: AddressInfo(
          calle: formData['calle']?.toString(),
          numeroExterior: formData['numeroExterior']?.toString(),
          numeroInterior: formData['numeroInterior']?.toString(),
          colonia: formData['colonia']?.toString(),
          codigoPostal: formData['codigoPostal']?.toString(),
          alcaldia: formData['alcaldia']?.toString(),
        ),
        tags: _generateInitialTags(bookingType),
        metrics: ClientMetrics.initial(), // Métricas iniciales
        auditInfo: AuditInfo.create(
          source: 'public_booking_screen',
          createdBy: 'sistema_automatico',
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // 🆕 SERVICE MODE SEGÚN TIPO DE BOOKING
        serviceMode: _determineServiceMode(bookingType, formData),
        isHomeService: _calculateIsHomeService(bookingType, formData),
        isInSiteService: _calculateIsInSiteService(bookingType),
        isHybridService: false, // Por defecto no híbrido para nuevos
      );

      // ✅ CREAR EN FIRESTORE CON ESTRUCTURA CORRECTA
      final docRef = _firestore.collection('clients').doc();
      final finalClientModel = clientModel.copyWith(clientId: docRef.id);

      await docRef.set(finalClientModel.toMap());

      debugPrint('✅ Cliente nuevo creado automáticamente: ${docRef.id}');
      debugPrint('   - Nombre completo: $nombre $apellidos');
      debugPrint('   - Teléfono: ${formData['clientPhone']}');
      debugPrint('   - Service Mode: ${finalClientModel.serviceMode.name}');
      debugPrint('   - Tags iniciales: ${finalClientModel.tags.length}');

      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creando cliente nuevo: $e');
      rethrow;
    }
  }

  /// 🏗️ CONSTRUIR APPOINTMENT DATA - ✅ ACTUALIZADO PARA USAR clientId
  Future<AppointmentModel> buildAppointmentData({
    required BookingType bookingType,
    required Map<String, dynamic> formData,
    required Map<String, dynamic> selectionData,
    Map<String, dynamic>? eventData,
    Map<String, dynamic>? companyData,
    String? clientId, // ✅ NUEVO: clientId ya resuelto
  }) async {
    try {
      debugPrint('🏗️ Construyendo AppointmentModel');

      // ✅ OBTENER serviceId con fallback
      final serviceId = selectionData['selectedServiceId'] ??
          selectionData['servicioId'] ??
          selectionData['serviceId'];

      if (serviceId == null || serviceId.toString().isEmpty) {
        throw Exception(
            'ServiceId requerido para construcción de AppointmentModel');
      }

      // 📅 Calcular fecha y hora del booking
      final bookingDateTime = _calculateBookingDateTime(
        selectionData: selectionData,
        eventData: eventData,
      );

      // 🎯 Obtener datos del servicio seleccionado
      final serviceData = await _getServiceData(serviceId);

      // 👨‍⚕️ Obtener datos del profesional
      final professionalData = await _getProfessionalData(
        selectionData['selectedProfessionalId'] ??
            serviceData?['profesionalAsignado'],
      );

      // 💰 Calcular precio según tipo de booking
      final finalPrice = _calculateFinalPrice(
        serviceData?['price'] ?? 0,
        bookingType,
      );

      // 🏗️ Construir modelo completo
      final appointmentModel = AppointmentModel(
        id: '', // Se asignará después del guardado
        bookingId: null,
        clienteId: clientId, // ✅ USAR clientId resuelto
        nombreCliente: _sanitizeClientName(formData['nombreCliente']),
        clientEmail: _sanitizeEmail(formData['clientEmail']),
        clientPhone: _sanitizePhone(formData['clientPhone']),
        profesionalId:
            professionalData?['id'] ?? selectionData['selectedProfessionalId'],
        profesionalNombre:
            professionalData?['fullName'] ?? serviceData?['profesionalNombre'],
        servicioId: serviceId,
        servicioNombre: serviceData?['name'] ?? 'Servicio no especificado',
        estado: 'reservado',
        comentarios:
            _buildComments(bookingType, formData, eventData, companyData),
        fechaInicio: bookingDateTime,
        fechaFin: null, // Se calculará automáticamente
        duracion: serviceData?['duration'] ?? 60,
        creadoEn: DateTime.now(),
        updatedAt: DateTime.now(),
        recursoTipo: bookingType.name,
        prioridad: _calculatePriority(bookingType),
        esRecurrente: false,
        metadatos: _buildMetadata(
          bookingType: bookingType,
          formData: formData,
          selectionData: selectionData,
          eventData: eventData,
          companyData: companyData,
          finalPrice: finalPrice,
          clientId: clientId,
        ),
      );

      debugPrint('✅ AppointmentModel construido exitosamente');
      debugPrint('   - Cliente: ${appointmentModel.nombreCliente}');
      debugPrint('   - Cliente ID: ${appointmentModel.clienteId}');
      debugPrint('   - Servicio: ${appointmentModel.servicioNombre}');
      debugPrint('   - Fecha: ${appointmentModel.fechaInicio}');

      return appointmentModel;
    } catch (e) {
      debugPrint('❌ Error construyendo AppointmentModel: $e');
      rethrow;
    }
  }

  // ============================================================================
  // 🔧 MÉTODOS HELPER PARA CLIENTE NUEVO
  // ============================================================================

  /// 📝 EXTRAER PARTES DEL NOMBRE
  (String nombre, String apellidos) _extractNameParts(String nombreCompleto) {
    final parts = nombreCompleto.trim().split(' ');
    if (parts.length == 1) {
      return (parts[0], '');
    } else if (parts.length == 2) {
      return (parts[0], parts[1]);
    } else {
      // Más de 2 partes: primer parte = nombre, resto = apellidos
      final nombre = parts[0];
      final apellidos = parts.sublist(1).join(' ');
      return (nombre, apellidos);
    }
  }

  /// 🏢 DETERMINAR NOMBRE DE EMPRESA
  String? _determineCompanyName(
    BookingType bookingType,
    Map<String, dynamic> formData,
    Map<String, dynamic>? companyData,
  ) {
    switch (bookingType) {
      case BookingType.enterprise:
        return companyData?['nombre'] ?? 'Empresa Enterprise';
      case BookingType.corporate:
        return companyData?['nombre'] ?? 'Empresa Corporativa';
      case BookingType.particular:
        return null; // Particulares no tienen empresa
    }
  }

  /// 🏷️ GENERAR TAGS INICIALES SEGÚN TIPO DE BOOKING
  List<ClientTag> _generateInitialTags(BookingType bookingType) {
    final tags = <ClientTag>[];
    final now = DateTime.now();

    // Tag obligatorio: Nuevo
    tags.add(ClientTag(
      label: 'Nuevo',
      type: TagType.system,
      createdAt: now,
    ));

    // Tags según tipo de booking
    switch (bookingType) {
      case BookingType.enterprise:
        tags.add(ClientTag(
          label: 'Corporativo',
          type: TagType.base,
          createdAt: now,
        ));
        tags.add(ClientTag(
          label: 'Enterprise',
          type: TagType.system,
          createdAt: now,
        ));
        break;
      case BookingType.corporate:
        tags.add(ClientTag(
          label: 'Corporativo',
          type: TagType.base,
          createdAt: now,
        ));
        tags.add(ClientTag(
          label: 'Evento',
          type: TagType.system,
          createdAt: now,
        ));
        break;
      case BookingType.particular:
        tags.add(ClientTag(
          label: 'Particular',
          type: TagType.base,
          createdAt: now,
        ));
        tags.add(ClientTag(
          label: 'Agenda Pública',
          type: TagType.system,
          createdAt: now,
        ));
        break;
    }

    return tags;
  }

  /// 🚗 DETERMINAR SERVICE MODE
  ClientServiceMode _determineServiceMode(
    BookingType bookingType,
    Map<String, dynamic> formData,
  ) {
    switch (bookingType) {
      case BookingType.enterprise:
      case BookingType.corporate:
        return ClientServiceMode.sucursal; // Empresas en sucursal
      case BookingType.particular:
        // Verificar si tiene dirección completa
        final tieneDir = _hasCompleteAddress(formData);
        return tieneDir
            ? ClientServiceMode.domicilio
            : ClientServiceMode.sucursal;
    }
  }

  /// 🏠 CALCULAR isHomeService
  bool _calculateIsHomeService(
      BookingType bookingType, Map<String, dynamic> formData) {
    return bookingType == BookingType.particular &&
        _hasCompleteAddress(formData);
  }

  /// 🏢 CALCULAR isInSiteService
  bool _calculateIsInSiteService(BookingType bookingType) {
    return true; // Todos pueden tener servicio en sucursal
  }

  /// 🏠 VERIFICAR DIRECCIÓN COMPLETA
  bool _hasCompleteAddress(Map<String, dynamic> formData) {
    final calle = formData['calle']?.toString();
    final numero = formData['numeroExterior']?.toString();
    final colonia = formData['colonia']?.toString();

    return calle != null &&
        calle.isNotEmpty &&
        numero != null &&
        numero.isNotEmpty &&
        colonia != null &&
        colonia.isNotEmpty;
  }

  // ============================================================================
  // 🎯 MÉTODOS EXISTENTES MANTENIDOS (SIN CAMBIOS)
  // ============================================================================

  /// 📅 CALCULAR FECHA Y HORA DEL BOOKING
  DateTime _calculateBookingDateTime({
    required Map<String, dynamic> selectionData,
    Map<String, dynamic>? eventData,
  }) {
    final selectedTime = selectionData['selectedTime'] as String;
    final timeParts = selectedTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    if (eventData != null) {
      // Usar fecha del evento
      final eventDate = (eventData['fecha'] as Timestamp).toDate();
      return DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        hour,
        minute,
      );
    } else {
      // Usar fecha seleccionada por el usuario
      final selectedDate = selectionData['selectedDate'] as DateTime;
      return DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        hour,
        minute,
      );
    }
  }

  /// 🎯 OBTENER DATOS DEL SERVICIO
  Future<Map<String, dynamic>?> _getServiceData(String? serviceId) async {
    if (serviceId == null) return null;

    try {
      final doc = await _firestore.collection('services').doc(serviceId).get();

      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data()!,
        };
      }
    } catch (e) {
      debugPrint('❌ Error obteniendo datos del servicio: $e');
    }

    return null;
  }

  /// 👨‍⚕️ OBTENER DATOS DEL PROFESIONAL
  Future<Map<String, dynamic>?> _getProfessionalData(
      String? professionalId) async {
    if (professionalId == null) return null;

    try {
      final doc = await _firestore
          .collection('profesionales')
          .doc(professionalId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return {
          'id': doc.id,
          'fullName':
              '${data['nombre'] ?? ''} ${data['apellidos'] ?? ''}'.trim(),
          ...data,
        };
      }
    } catch (e) {
      debugPrint('❌ Error obteniendo datos del profesional: $e');
    }

    return null;
  }

  /// 💰 CALCULAR PRECIO FINAL
  int _calculateFinalPrice(int basePrice, BookingType bookingType) {
    switch (bookingType) {
      case BookingType.enterprise:
        return 0; // Gratis para empresas
      case BookingType.corporate:
        return (basePrice * 0.7).round(); // 30% descuento
      case BookingType.particular:
        return basePrice; // Precio completo
    }
  }

  /// 🎯 CALCULAR PRIORIDAD
  String _calculatePriority(BookingType bookingType) {
    switch (bookingType) {
      case BookingType.enterprise:
        return 'alta'; // Alta prioridad para empresas
      case BookingType.corporate:
        return 'media'; // Media para eventos corporativos
      case BookingType.particular:
        return 'media'; // Media para particulares
    }
  }

  /// 💬 CONSTRUIR COMENTARIOS
  String _buildComments(
    BookingType bookingType,
    Map<String, dynamic> formData,
    Map<String, dynamic>? eventData,
    Map<String, dynamic>? companyData,
  ) {
    final comments = <String>[
      'Reserva desde agenda pública - ${bookingType.name}',
      'Cliente procesado automáticamente',
    ];

    if (eventData != null) {
      comments.add('Evento: ${eventData['nombre']}');
    }

    if (companyData != null) {
      comments.add('Empresa: ${companyData['nombre']}');
    }

    if (formData['comentarios'] != null &&
        formData['comentarios'].toString().trim().isNotEmpty) {
      comments.add('Comentario del cliente: ${formData['comentarios']}');
    }

    return comments.join(' | ');
  }

  /// 📊 CONSTRUIR METADATOS - ✅ ACTUALIZADO CON clientId
  Map<String, dynamic> _buildMetadata({
    required BookingType bookingType,
    required Map<String, dynamic> formData,
    required Map<String, dynamic> selectionData,
    Map<String, dynamic>? eventData,
    Map<String, dynamic>? companyData,
    required int finalPrice,
    String? clientId,
  }) {
    final metadata = <String, dynamic>{
      // 🎯 Información del booking
      'tipoBooking': bookingType.name,
      'clienteAutocreado': clientId != null,
      'clienteId': clientId,
      'plataforma': 'web_booking',
      'fechaCreacion': DateTime.now().toIso8601String(),
      'version': '2.0', // ✅ Versión con auto-creación

      // 💰 Información de precio
      'precio': finalPrice,
      'precioOriginal': selectionData['originalPrice'],
      'descuentoAplicado': finalPrice < (selectionData['originalPrice'] ?? 0),

      // 📊 Información de fuente
      'source': 'public_booking_screen_optimized',
      'userAgent': 'Flutter Web App',
      'autocreationStrategy': 'hybrid_validation',
    };

    // 🏢 Información de empresa
    if (companyData != null) {
      metadata.addAll({
        'empresaId': companyData['empresaId'],
        'empresaNombre': companyData['nombre'],
        'empresaRFC': companyData['rfc'],
      });
    }

    // 📅 Información de evento
    if (eventData != null) {
      metadata.addAll({
        'eventoId': selectionData['selectedEventId'],
        'eventoNombre': eventData['nombre'],
        'eventoFecha': eventData['fecha'],
        'eventoUbicacion': eventData['ubicacion'],
      });
    }

    // 👤 Información específica por tipo
    switch (bookingType) {
      case BookingType.enterprise:
        metadata['numeroEmpleado'] = formData['numeroEmpleado'];
        break;
      case BookingType.corporate:
        metadata['empresaEvento'] = eventData?['empresa'];
        break;
      case BookingType.particular:
        if (_hasCompleteAddress(formData)) {
          metadata['tieneServicioDomicilio'] = true;
          metadata['serviceModeDetectado'] = 'domicilio';
        } else {
          metadata['serviceModeDetectado'] = 'sucursal';
        }
        break;
    }

    return metadata;
  }

  /// 🧹 SANITIZAR NOMBRE DEL CLIENTE
  String _sanitizeClientName(String? name) {
    if (name == null || name.isEmpty) return 'Cliente sin nombre';
    return BookingValidationService.capitalizeName(
        BookingValidationService.sanitizeInput(name));
  }

  /// 📧 SANITIZAR EMAIL
  String? _sanitizeEmail(String? email) {
    if (email == null || email.isEmpty) return null;
    return BookingValidationService.normalizeEmail(
        BookingValidationService.sanitizeInput(email));
  }

  /// 📱 SANITIZAR TELÉFONO
  String _sanitizePhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    return BookingValidationService.formatPhoneNumber(
        BookingValidationService.sanitizeInput(phone));
  }

  /// 📊 REGISTRAR MÉTRICAS DE ENVÍO - ✅ ACTUALIZADO
  Future<void> _recordSubmissionMetrics(
    BookingType bookingType,
    String bookingId,
    bool clientWasCreated,
  ) async {
    try {
      await _firestore.collection('booking_metrics').add({
        'bookingId': bookingId,
        'bookingType': bookingType.name,
        'submissionTime': FieldValue.serverTimestamp(),
        'platform': 'web',
        'success': true,
        'clientAutoCreated': clientWasCreated, // ✅ NUEVA MÉTRICA
        'strategy': 'hybrid_validation',
      });
    } catch (e) {
      debugPrint('⚠️ Error registrando métricas: $e');
      // No fallar el envío por error de métricas
    }
  }
}

// ============================================================================
// 📋 MODELOS DE RESULTADO - ✅ CORREGIDOS
// ============================================================================

/// 🎯 RESULTADO DE OPERACIÓN DE CLIENTE
class ClientOperationResult {
  final String? clientId;
  final Map<String, dynamic>? clientData;
  final bool wasCreated;
  final bool isSuccess;
  final String? error;

  const ClientOperationResult._({
    this.clientId,
    this.clientData,
    required this.wasCreated,
    required this.isSuccess,
    this.error,
  });

  /// ✅ CLIENTE EXISTENTE ENCONTRADO
  factory ClientOperationResult.existing({
    required String clientId,
    required Map<String, dynamic> clientData,
  }) {
    return ClientOperationResult._(
      clientId: clientId,
      clientData: clientData,
      wasCreated: false,
      isSuccess: true,
    );
  }

  /// 🆕 CLIENTE NUEVO CREADO
  factory ClientOperationResult.created({
    required String clientId,
    required Map<String, dynamic> clientData,
  }) {
    return ClientOperationResult._(
      clientId: clientId,
      clientData: clientData,
      wasCreated: true,
      isSuccess: true,
    );
  }

  /// ❌ ERROR EN OPERACIÓN
  factory ClientOperationResult.error(String error) {
    return ClientOperationResult._(
      wasCreated: false,
      isSuccess: false,
      error: error,
    );
  }

  @override
  String toString() {
    return 'ClientOperationResult{clientId: $clientId, wasCreated: $wasCreated, isSuccess: $isSuccess}';
  }
}

/// 📤 RESULTADO DE ENVÍO
class SubmissionResult {
  final bool isSuccess;
  final String? bookingId;
  final AppointmentModel? appointmentModel;
  final String message;
  final String? error;
  final int? retryCount;
  final DateTime timestamp;

  const SubmissionResult._({
    required this.isSuccess,
    this.bookingId,
    this.appointmentModel,
    required this.message,
    this.error,
    this.retryCount,
    required this.timestamp,
  });

  /// ✅ CREAR RESULTADO EXITOSO
  factory SubmissionResult.success({
    required String bookingId,
    AppointmentModel? appointmentModel,
    String message = 'Envío exitoso',
    int? retryCount,
  }) {
    return SubmissionResult._(
      isSuccess: true,
      bookingId: bookingId,
      appointmentModel: appointmentModel,
      message: message,
      retryCount: retryCount,
      timestamp: DateTime.now(),
    );
  }

  /// ❌ CREAR RESULTADO DE ERROR
  factory SubmissionResult.error(
    String error, {
    int? retryCount,
  }) {
    return SubmissionResult._(
      isSuccess: false,
      message: 'Error en envío',
      error: error,
      retryCount: retryCount,
      timestamp: DateTime.now(),
    );
  }

  /// 🔄 COPIAR CON MODIFICACIONES
  SubmissionResult copyWith({
    bool? isSuccess,
    String? bookingId,
    AppointmentModel? appointmentModel,
    String? message,
    String? error,
    int? retryCount,
  }) {
    return SubmissionResult._(
      isSuccess: isSuccess ?? this.isSuccess,
      bookingId: bookingId ?? this.bookingId,
      appointmentModel: appointmentModel ?? this.appointmentModel,
      message: message ?? this.message,
      error: error ?? this.error,
      retryCount: retryCount ?? this.retryCount,
      timestamp: timestamp,
    );
  }

  @override
  String toString() {
    return 'SubmissionResult{isSuccess: $isSuccess, bookingId: $bookingId, message: $message}';
  }
}
