// [booking_request_model.dart] - MODELOS ESPECIALIZADOS PARA BOOKING
// 📁 Ubicación: /lib/models/booking/booking_request_model.dart
// 🎯 OBJETIVO: Estructurar mejor los datos del flujo de booking

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../enums/booking_types.dart';
import '../appointment_model.dart';

/// 📋 SOLICITUD COMPLETA DE BOOKING
/// Encapsula toda la información necesaria para crear una cita
class BookingRequest {
  final BookingType type;
  final BookingMetadata metadata;
  final ClientInfo clientInfo;
  final ServiceSelection serviceSelection;
  final DateTimeSelection dateTimeSelection;
  final CompanyInfo? companyInfo;
  final EventInfo? eventInfo;

  const BookingRequest({
    required this.type,
    required this.metadata,
    required this.clientInfo,
    required this.serviceSelection,
    required this.dateTimeSelection,
    this.companyInfo,
    this.eventInfo,
  });

  /// 🏗️ FACTORY DESDE CONTROLADOR
  factory BookingRequest.fromController({
    required BookingType type,
    required Map<String, dynamic> formData,
    required Map<String, dynamic> selectionData,
    Map<String, dynamic>? companyData,
    Map<String, dynamic>? eventData,
    String? source,
  }) {
    return BookingRequest(
      type: type,
      metadata: BookingMetadata(
        source: source ?? 'public_booking_screen',
        platform: 'web',
        timestamp: DateTime.now(),
        userAgent: 'Flutter Web App',
      ),
      clientInfo: ClientInfo.fromMap(formData),
      serviceSelection: ServiceSelection.fromMap(selectionData),
      dateTimeSelection: DateTimeSelection.fromMap(selectionData),
      companyInfo: companyData != null ? CompanyInfo.fromMap(companyData) : null,
      eventInfo: eventData != null ? EventInfo.fromMap(eventData) : null,
    );
  }

  /// 🔄 CONVERSIÓN A APPOINTMENTMODEL
  AppointmentModel toAppointmentModel() {
    return AppointmentModel(
      id: '', // Se asignará después del guardado
      bookingId: null,
      clienteId: clientInfo.clientId,
      nombreCliente: clientInfo.fullName,
      clientEmail: clientInfo.email,
      clientPhone: clientInfo.phone,
      profesionalId: serviceSelection.professionalId,
      profesionalNombre: serviceSelection.professionalName,
      servicioId: serviceSelection.serviceId,
      servicioNombre: serviceSelection.serviceName,
      estado: 'reservado',
      comentarios: _buildComments(),
      fechaInicio: dateTimeSelection.calculatedDateTime,
      fechaFin: null, // Se calculará automáticamente
      duracion: serviceSelection.duration,
      creadoEn: DateTime.now(),
      updatedAt: DateTime.now(),
      recursoTipo: type.name,
      prioridad: _calculatePriority(),
      esRecurrente: false,
      metadatos: _buildMetadata(),
    );
  }

  /// 💬 CONSTRUIR COMENTARIOS
  String _buildComments() {
    final comments = <String>[
      'Reserva desde agenda pública - ${type.name}',
    ];

    if (eventInfo != null) {
      comments.add('Evento: ${eventInfo!.name}');
    }

    if (companyInfo != null) {
      comments.add('Empresa: ${companyInfo!.name}');
    }

    if (clientInfo.additionalComments != null && 
        clientInfo.additionalComments!.trim().isNotEmpty) {
      comments.add('Comentario del cliente: ${clientInfo.additionalComments}');
    }

    return comments.join(' | ');
  }

  /// 🎯 CALCULAR PRIORIDAD
  String _calculatePriority() {
    switch (type) {
      case BookingType.enterprise:
        return 'alta';
      case BookingType.corporate:
        return 'media';
      case BookingType.particular:
        return 'media';
    }
  }

  /// 📊 CONSTRUIR METADATOS
  Map<String, dynamic> _buildMetadata() {
    final metadataMap = <String, dynamic>{
      // Información del booking
      'tipoBooking': type.name,
      'esClienteRegistrado': clientInfo.isExisting,
      'plataforma': metadata.platform,
      'fechaCreacion': metadata.timestamp.toIso8601String(),
      'version': '2.0',
      'source': metadata.source,

      // Información de precio
      'precio': serviceSelection.finalPrice,
      'precioOriginal': serviceSelection.originalPrice,
      'descuentoAplicado': serviceSelection.finalPrice < serviceSelection.originalPrice,
    };

    // Información de empresa
    if (companyInfo != null) {
      metadataMap.addAll({
        'empresaId': companyInfo!.id,
        'empresaNombre': companyInfo!.name,
        'empresaRFC': companyInfo!.rfc,
      });
    }

    // Información de evento
    if (eventInfo != null) {
      metadataMap.addAll({
        'eventoId': eventInfo!.id,
        'eventoNombre': eventInfo!.name,
        'eventoFecha': eventInfo!.date,
        'eventoUbicacion': eventInfo!.location,
      });
    }

    // Información específica por tipo
    switch (type) {
      case BookingType.enterprise:
        if (clientInfo.employeeNumber != null) {
          metadataMap['numeroEmpleado'] = clientInfo.employeeNumber;
        }
        break;
      case BookingType.corporate:
        if (eventInfo != null) {
          metadataMap['empresaEvento'] = eventInfo!.companyName;
        }
        break;
      case BookingType.particular:
        if (clientInfo.address != null && clientInfo.address!.trim().isNotEmpty) {
          metadataMap['direccion'] = clientInfo.address;
          metadataMap['requiereServicioDomicilio'] = true;
        }
        break;
    }

    return metadataMap;
  }

  /// 📋 CONVERSIÓN A MAP
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'metadata': metadata.toMap(),
      'clientInfo': clientInfo.toMap(),
      'serviceSelection': serviceSelection.toMap(),
      'dateTimeSelection': dateTimeSelection.toMap(),
      'companyInfo': companyInfo?.toMap(),
      'eventInfo': eventInfo?.toMap(),
    };
  }

  /// ✅ VALIDAR COMPLETITUD
  bool get isValid {
    return clientInfo.isValid &&
           serviceSelection.isValid &&
           dateTimeSelection.isValid &&
           (type != BookingType.enterprise || companyInfo != null) &&
           (type == BookingType.particular || eventInfo != null || type == BookingType.particular);
  }

  /// 🔄 COPIAR CON MODIFICACIONES
  BookingRequest copyWith({
    BookingType? type,
    BookingMetadata? metadata,
    ClientInfo? clientInfo,
    ServiceSelection? serviceSelection,
    DateTimeSelection? dateTimeSelection,
    CompanyInfo? companyInfo,
    EventInfo? eventInfo,
  }) {
    return BookingRequest(
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      clientInfo: clientInfo ?? this.clientInfo,
      serviceSelection: serviceSelection ?? this.serviceSelection,
      dateTimeSelection: dateTimeSelection ?? this.dateTimeSelection,
      companyInfo: companyInfo ?? this.companyInfo,
      eventInfo: eventInfo ?? this.eventInfo,
    );
  }
}

/// 👤 INFORMACIÓN DEL CLIENTE
class ClientInfo {
  final String? clientId;
  final String name;
  final String phone;
  final String? email;
  final String? employeeNumber;
  final String? address;
  final bool isExisting;
  final String? additionalComments;

  const ClientInfo({
    this.clientId,
    required this.name,
    required this.phone,
    this.email,
    this.employeeNumber,
    this.address,
    this.isExisting = false,
    this.additionalComments,
  });

  /// 🏗️ FACTORY DESDE MAP
  factory ClientInfo.fromMap(Map<String, dynamic> map) {
    return ClientInfo(
      clientId: map['clienteId'],
      name: map['nombreCliente'] ?? '',
      phone: map['clientPhone'] ?? '',
      email: map['clientEmail'],
      employeeNumber: map['numeroEmpleado'],
      address: map['direccion'],
      isExisting: map['isExistingClient'] ?? false,
      additionalComments: map['comentarios'],
    );
  }

  /// 📋 CONVERSIÓN A MAP
  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'name': name,
      'phone': phone,
      'email': email,
      'employeeNumber': employeeNumber,
      'address': address,
      'isExisting': isExisting,
      'additionalComments': additionalComments,
    };
  }

  /// 📝 NOMBRE COMPLETO
  String get fullName => name.trim();

  /// ✅ VALIDAR
  bool get isValid {
    return name.isNotEmpty && phone.isNotEmpty;
  }

  /// 🔄 COPIAR CON MODIFICACIONES
  ClientInfo copyWith({
    String? clientId,
    String? name,
    String? phone,
    String? email,
    String? employeeNumber,
    String? address,
    bool? isExisting,
    String? additionalComments,
  }) {
    return ClientInfo(
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      address: address ?? this.address,
      isExisting: isExisting ?? this.isExisting,
      additionalComments: additionalComments ?? this.additionalComments,
    );
  }
}

/// 🛍️ SELECCIÓN DE SERVICIO
class ServiceSelection {
  final String serviceId;
  final String serviceName;
  final String? professionalId;
  final String? professionalName;
  final String? eventId;
  final int duration;
  final int originalPrice;
  final int finalPrice;
  final String? category;
  final String? description;

  const ServiceSelection({
    required this.serviceId,
    required this.serviceName,
    this.professionalId,
    this.professionalName,
    this.eventId,
    required this.duration,
    required this.originalPrice,
    required this.finalPrice,
    this.category,
    this.description,
  });

  /// 🏗️ FACTORY DESDE MAP
  factory ServiceSelection.fromMap(Map<String, dynamic> map) {
    return ServiceSelection(
      serviceId: map['selectedServiceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      professionalId: map['selectedProfessionalId'],
      professionalName: map['professionalName'],
      eventId: map['selectedEventId'],
      duration: map['duration'] ?? 60,
      originalPrice: map['originalPrice'] ?? 0,
      finalPrice: map['finalPrice'] ?? map['originalPrice'] ?? 0,
      category: map['category'],
      description: map['description'],
    );
  }

  /// 📋 CONVERSIÓN A MAP
  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'professionalId': professionalId,
      'professionalName': professionalName,
      'eventId': eventId,
      'duration': duration,
      'originalPrice': originalPrice,
      'finalPrice': finalPrice,
      'category': category,
      'description': description,
    };
  }

  /// ✅ VALIDAR
  bool get isValid {
    return serviceId.isNotEmpty && serviceName.isNotEmpty && duration > 0;
  }

  /// 💰 TIENE DESCUENTO
  bool get hasDiscount => finalPrice < originalPrice;

  /// 💰 PORCENTAJE DE DESCUENTO
  double get discountPercentage {
    if (originalPrice == 0) return 0.0;
    return ((originalPrice - finalPrice) / originalPrice) * 100;
  }

  /// 🔄 COPIAR CON MODIFICACIONES
  ServiceSelection copyWith({
    String? serviceId,
    String? serviceName,
    String? professionalId,
    String? professionalName,
    String? eventId,
    int? duration,
    int? originalPrice,
    int? finalPrice,
    String? category,
    String? description,
  }) {
    return ServiceSelection(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      professionalId: professionalId ?? this.professionalId,
      professionalName: professionalName ?? this.professionalName,
      eventId: eventId ?? this.eventId,
      duration: duration ?? this.duration,
      originalPrice: originalPrice ?? this.originalPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }
}

/// 📅 SELECCIÓN DE FECHA Y HORA
class DateTimeSelection {
  final DateTime date;
  final String timeSlot;
  final DateTime calculatedDateTime;

  const DateTimeSelection({
    required this.date,
    required this.timeSlot,
    required this.calculatedDateTime,
  });

  /// 🏗️ FACTORY DESDE MAP
  factory DateTimeSelection.fromMap(Map<String, dynamic> map) {
    final date = map['selectedDate'] as DateTime? ?? DateTime.now();
    final timeSlot = map['selectedTime'] as String? ?? '09:00';
    
    return DateTimeSelection(
      date: date,
      timeSlot: timeSlot,
      calculatedDateTime: _calculateDateTime(date, timeSlot),
    );
  }

  /// 🏗️ FACTORY CON CÁLCULO AUTOMÁTICO
  factory DateTimeSelection.create({
    required DateTime date,
    required String timeSlot,
  }) {
    return DateTimeSelection(
      date: date,
      timeSlot: timeSlot,
      calculatedDateTime: _calculateDateTime(date, timeSlot),
    );
  }

  /// ⏰ CALCULAR DATETIME COMBINADO
  static DateTime _calculateDateTime(DateTime date, String timeSlot) {
    final timeParts = timeSlot.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 9;
    final minute = int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;

    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  /// 📋 CONVERSIÓN A MAP
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'calculatedDateTime': calculatedDateTime.toIso8601String(),
    };
  }

  /// ✅ VALIDAR
  bool get isValid {
    return timeSlot.isNotEmpty && 
           calculatedDateTime.isAfter(DateTime.now().subtract(Duration(hours: 1)));
  }

  /// 📅 FORMATEO AMIGABLE
  String get formattedDate => '${date.day}/${date.month}/${date.year}';
  String get formattedTime => timeSlot;
  String get formattedDateTime => '$formattedDate $formattedTime';

  /// 🔄 COPIAR CON MODIFICACIONES
  DateTimeSelection copyWith({
    DateTime? date,
    String? timeSlot,
  }) {
    final newDate = date ?? this.date;
    final newTimeSlot = timeSlot ?? this.timeSlot;
    
    return DateTimeSelection(
      date: newDate,
      timeSlot: newTimeSlot,
      calculatedDateTime: _calculateDateTime(newDate, newTimeSlot),
    );
  }
}

/// 🏢 INFORMACIÓN DE EMPRESA
class CompanyInfo {
  final String id;
  final String name;
  final String? rfc;
  final String? legalName;
  final String? phone;
  final String? email;
  final String? address;

  const CompanyInfo({
    required this.id,
    required this.name,
    this.rfc,
    this.legalName,
    this.phone,
    this.email,
    this.address,
  });

  /// 🏗️ FACTORY DESDE MAP
  factory CompanyInfo.fromMap(Map<String, dynamic> map) {
    return CompanyInfo(
      id: map['empresaId'] ?? '',
      name: map['nombre'] ?? '',
      rfc: map['rfc'],
      legalName: map['razonSocial'],
      phone: map['telefono'],
      email: map['correo'],
      address: map['direccion'],
    );
  }

  /// 📋 CONVERSIÓN A MAP
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rfc': rfc,
      'legalName': legalName,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }

  /// ✅ VALIDAR
  bool get isValid => id.isNotEmpty && name.isNotEmpty;
}

/// 📅 INFORMACIÓN DE EVENTO
class EventInfo {
  final String id;
  final String name;
  final String? companyName;
  final DateTime date;
  final String? location;
  final String? status;

  const EventInfo({
    required this.id,
    required this.name,
    this.companyName,
    required this.date,
    this.location,
    this.status,
  });

  /// 🏗️ FACTORY DESDE MAP
  factory EventInfo.fromMap(Map<String, dynamic> map) {
    return EventInfo(
      id: map['eventoId'] ?? '',
      name: map['nombre'] ?? '',
      companyName: map['empresa'],
      date: map['fecha'] is Timestamp 
          ? (map['fecha'] as Timestamp).toDate()
          : DateTime.tryParse(map['fecha'].toString()) ?? DateTime.now(),
      location: map['ubicacion'],
      status: map['estado'],
    );
  }

  /// 📋 CONVERSIÓN A MAP
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'companyName': companyName,
      'date': date.toIso8601String(),
      'location': location,
      'status': status,
    };
  }

  /// ✅ VALIDAR
  bool get isValid => id.isNotEmpty && name.isNotEmpty;
}

/// 📊 METADATOS DEL BOOKING
class BookingMetadata {
  final String source;
  final String platform;
  final DateTime timestamp;
  final String? userAgent;
  final String? ipAddress;
  final String version;

  const BookingMetadata({
    required this.source,
    required this.platform,
    required this.timestamp,
    this.userAgent,
    this.ipAddress,
    this.version = '2.0',
  });

  /// 📋 CONVERSIÓN A MAP
  Map<String, dynamic> toMap() {
    return {
      'source': source,
      'platform': platform,
      'timestamp': timestamp.toIso8601String(),
      'userAgent': userAgent,
      'ipAddress': ipAddress,
      'version': version,
    };
  }

  /// 🔄 COPIAR CON MODIFICACIONES
  BookingMetadata copyWith({
    String? source,
    String? platform,
    DateTime? timestamp,
    String? userAgent,
    String? ipAddress,
    String? version,
  }) {
    return BookingMetadata(
      source: source ?? this.source,
      platform: platform ?? this.platform,
      timestamp: timestamp ?? this.timestamp,
      userAgent: userAgent ?? this.userAgent,
      ipAddress: ipAddress ?? this.ipAddress,
      version: version ?? this.version,
    );
  }
}

/// 📊 RESUMEN DE BOOKING
class BookingSummary {
  final BookingRequest request;
  final DateTime createdAt;
  final double processingTime;

  const BookingSummary({
    required this.request,
    required this.createdAt,
    required this.processingTime,
  });

  /// 📋 INFORMACIÓN RESUMIDA
  Map<String, dynamic> get summary => {
    'bookingType': request.type.name,
    'clientName': request.clientInfo.name,
    'serviceName': request.serviceSelection.serviceName,
    'dateTime': request.dateTimeSelection.formattedDateTime,
    'finalPrice': request.serviceSelection.finalPrice,
    'createdAt': createdAt.toIso8601String(),
    'processingTimeMs': processingTime,
  };

  /// 💰 INFORMACIÓN DE PRECIO
  Map<String, dynamic> get priceInfo => {
    'originalPrice': request.serviceSelection.originalPrice,
    'finalPrice': request.serviceSelection.finalPrice,
    'hasDiscount': request.serviceSelection.hasDiscount,
    'discountPercentage': request.serviceSelection.discountPercentage,
  };

  /// 📊 MÉTRICAS
  Map<String, dynamic> get metrics => {
    'isValid': request.isValid,
    'hasCompany': request.companyInfo != null,
    'hasEvent': request.eventInfo != null,
    'isExistingClient': request.clientInfo.isExisting,
    'serviceCategory': request.serviceSelection.category,
    'processingTimeMs': processingTime,
  };
}