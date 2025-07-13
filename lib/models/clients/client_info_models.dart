// [client_info_models.dart] - FIX CRÍTICO: NULL SAFETY + PERFORMANCE
// 📁 Ubicación: /lib/models/clients/client_info_models.dart
// 🎯 OBJETIVO: Fix inmediato para fechaNacimiento null + eliminación de logs infinitos

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// 👤 INFORMACIÓN PERSONAL - ✅ FIX CRÍTICO: NULL SAFETY FECHA NACIMIENTO
class PersonalInfo {
  final String nombre;
  final String apellidos;
  final String? empresa;
  final DateTime? fechaNacimiento;
  final String? genero;
  final String? notas;

  const PersonalInfo({
    required this.nombre,
    required this.apellidos,
    this.empresa,
    this.fechaNacimiento,
    this.genero,
    this.notas,
  });

  /// ✅ FIX CRÍTICO: LECTURA SEGURA SIN CRASHES
  factory PersonalInfo.fromMap(Map<String, dynamic> data) {
    // ✅ FIX: PARSEO SEGURO DE FECHA DE NACIMIENTO
    DateTime? fechaNacimiento;
    try {
      final fechaData = data['fechaNacimiento'];
      if (fechaData != null) {
        if (fechaData is Timestamp) {
          fechaNacimiento = fechaData.toDate();
        } else if (fechaData is String && fechaData.isNotEmpty) {
          fechaNacimiento = DateTime.tryParse(fechaData);
        }
      }
    } catch (e) {
      // ✅ SILENCIOSO: No logs infinitos para datos corruptos
      if (kDebugMode) {
        debugPrint(
            '⚠️ Error parseando fechaNacimiento para ${data['nombre'] ?? 'cliente'}: $e');
      }
      fechaNacimiento = null;
    }

    return PersonalInfo(
      nombre: data['nombre'] ?? '',
      apellidos: data['apellidos'] ?? '',
      empresa: data['empresa'],
      fechaNacimiento: fechaNacimiento,
      genero: data['genero'],
      notas: data['notas'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nombre': nombre,
      'apellidos': apellidos,
      'empresa': empresa,
      'genero': genero,
      'notas': notas,
    };

    // ✅ FIX: MANEJO SEGURO DE FECHA DE NACIMIENTO
    if (fechaNacimiento != null) {
      try {
        map['fechaNacimiento'] = Timestamp.fromDate(fechaNacimiento!);
        map['edad'] = edad;
        map['mesNacimiento'] = fechaNacimiento!.month;
        map['diaNacimiento'] = fechaNacimiento!.day;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Error guardando fechaNacimiento: $e');
        }
        // No incluir campos de fecha si hay error
      }
    }

    return map;
  }

  String get fullName => '$nombre $apellidos'.trim();

  /// ✅ FIX CRÍTICO: GETTER SEGURO PARA EDAD
  int? get edad {
    if (fechaNacimiento == null) return null;

    try {
      final today = DateTime.now();
      int age = today.year - fechaNacimiento!.year;

      // ✅ VERIFICACIÓN ADICIONAL DE SEGURIDAD
      if (today.month < fechaNacimiento!.month ||
          (today.month == fechaNacimiento!.month &&
              today.day < fechaNacimiento!.day)) {
        age--;
      }

      // ✅ VALIDACIÓN: Edad razonable (0-150 años)
      return (age >= 0 && age <= 150) ? age : null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error calculando edad: $e');
      }
      return null;
    }
  }

  /// ✅ FIX CRÍTICO: GETTER SEGURO PARA CUMPLEAÑOS
  bool get esCumpleanosHoy {
    if (fechaNacimiento == null) return false;

    try {
      final today = DateTime.now();
      return fechaNacimiento!.month == today.month &&
          fechaNacimiento!.day == today.day;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error verificando cumpleaños: $e');
      }
      return false;
    }
  }

  PersonalInfo copyWith({
    String? nombre,
    String? apellidos,
    String? empresa,
    DateTime? fechaNacimiento,
    String? genero,
    String? notas,
  }) {
    return PersonalInfo(
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      empresa: empresa ?? this.empresa,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      genero: genero ?? this.genero,
      notas: notas ?? this.notas,
    );
  }

  /// ✅ HELPER SEGURO PARA PARSEAR FECHAS
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    try {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error parseando DateTime: $e');
      }
    }

    return null;
  }
}

/// 📞 INFORMACIÓN DE CONTACTO - ✅ SIN CAMBIOS (FUNCIONANDO BIEN)
class ContactInfo {
  final String email;
  final String telefono;
  final String? telefonoSecundario;
  final List<SocialMedia> redesSociales;
  final String? sitioWeb;
  final ContactPreferences preferences;

  const ContactInfo({
    required this.email,
    required this.telefono,
    this.telefonoSecundario,
    this.redesSociales = const [],
    this.sitioWeb,
    this.preferences = const ContactPreferences(),
  });

  factory ContactInfo.fromMap(Map<String, dynamic> data) {
    return ContactInfo(
      email: data['correo'] ?? '',
      telefono: data['telefono'] ?? '',
      telefonoSecundario: data['telefonoSecundario'],
      redesSociales: _parseSocialMedia(data['redesSociales']),
      sitioWeb: data['sitioWeb'],
      preferences: ContactPreferences.fromMap(data['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'correo': email,
      'telefono': telefono,
      'telefonoSecundario': telefonoSecundario,
      'redesSociales': redesSociales.map((sm) => sm.toMap()).toList(),
      'sitioWeb': sitioWeb,
      'preferences': preferences.toMap(),
    };
  }

  bool get hasValidEmail => email.contains('@') && email.contains('.');
  bool get hasValidPhone => telefono.length >= 8;

  ContactInfo copyWith({
    String? email,
    String? telefono,
    String? telefonoSecundario,
    List<SocialMedia>? redesSociales,
    String? sitioWeb,
    ContactPreferences? preferences,
  }) {
    return ContactInfo(
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      telefonoSecundario: telefonoSecundario ?? this.telefonoSecundario,
      redesSociales: redesSociales ?? this.redesSociales,
      sitioWeb: sitioWeb ?? this.sitioWeb,
      preferences: preferences ?? this.preferences,
    );
  }

  static List<SocialMedia> _parseSocialMedia(dynamic data) {
    if (data is! List) return [];

    try {
      return data
          .map((item) => SocialMedia.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error parseando redes sociales: $e');
      }
      return [];
    }
  }
}

/// 🏠 INFORMACIÓN DE DIRECCIÓN - ✅ SIN CAMBIOS (FUNCIONANDO BIEN)
class AddressInfo {
  final String calle;
  final String numeroExterior;
  final String? numeroInterior;
  final String colonia;
  final String codigoPostal;
  final String alcaldia;
  final String? referencias;

  const AddressInfo({
    required this.calle,
    required this.numeroExterior,
    this.numeroInterior,
    required this.colonia,
    required this.codigoPostal,
    required this.alcaldia,
    this.referencias,
  });

  factory AddressInfo.fromMap(Map<String, dynamic> data) {
    return AddressInfo(
      calle: data['calle'] ?? '',
      numeroExterior: data['numeroExterior'] ?? '',
      numeroInterior: data['numeroInterior'],
      colonia: data['colonia'] ?? '',
      codigoPostal: data['codigoPostal'] ?? '',
      alcaldia: data['alcaldia'] ?? '',
      referencias: data['referencias'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calle': calle,
      'numeroExterior': numeroExterior,
      'numeroInterior': numeroInterior,
      'colonia': colonia,
      'codigoPostal': codigoPostal,
      'alcaldia': alcaldia,
      'referencias': referencias,
    };
  }

  String get fullAddress {
    final parts = <String>[];
    if (calle.isNotEmpty) parts.add(calle);
    if (numeroExterior.isNotEmpty) parts.add('No. $numeroExterior');
    if (numeroInterior != null && numeroInterior!.isNotEmpty)
      parts.add('Int. $numeroInterior');
    if (colonia.isNotEmpty) parts.add(colonia);
    if (alcaldia.isNotEmpty) parts.add(alcaldia);
    if (codigoPostal.isNotEmpty) parts.add('CP $codigoPostal');
    return parts.join(', ');
  }

  bool get isComplete {
    return calle.isNotEmpty &&
        numeroExterior.isNotEmpty &&
        colonia.isNotEmpty &&
        codigoPostal.isNotEmpty &&
        alcaldia.isNotEmpty;
  }

  AddressInfo copyWith({
    String? calle,
    String? numeroExterior,
    String? numeroInterior,
    String? colonia,
    String? codigoPostal,
    String? alcaldia,
    String? referencias,
  }) {
    return AddressInfo(
      calle: calle ?? this.calle,
      numeroExterior: numeroExterior ?? this.numeroExterior,
      numeroInterior: numeroInterior ?? this.numeroInterior,
      colonia: colonia ?? this.colonia,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      alcaldia: alcaldia ?? this.alcaldia,
      referencias: referencias ?? this.referencias,
    );
  }
}

/// 📱 REDES SOCIALES - ✅ SIN CAMBIOS
class SocialMedia {
  final String platform;
  final String username;
  final String? url;

  const SocialMedia({
    required this.platform,
    required this.username,
    this.url,
  });

  factory SocialMedia.fromMap(Map<String, dynamic> data) {
    return SocialMedia(
      platform: data['platform'] ?? '',
      username: data['username'] ?? '',
      url: data['url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'platform': platform,
      'username': username,
      'url': url,
    };
  }
}

/// 📞 PREFERENCIAS DE CONTACTO - ✅ SIN CAMBIOS
class ContactPreferences {
  final bool allowEmail;
  final bool allowSMS;
  final bool allowWhatsApp;
  final bool allowCalls;
  final List<String> preferredDays;
  final String? preferredTimeSlot;

  const ContactPreferences({
    this.allowEmail = true,
    this.allowSMS = true,
    this.allowWhatsApp = true,
    this.allowCalls = true,
    this.preferredDays = const [],
    this.preferredTimeSlot,
  });

  factory ContactPreferences.fromMap(Map<String, dynamic> data) {
    return ContactPreferences(
      allowEmail: data['allowEmail'] ?? true,
      allowSMS: data['allowSMS'] ?? true,
      allowWhatsApp: data['allowWhatsApp'] ?? true,
      allowCalls: data['allowCalls'] ?? true,
      preferredDays: List<String>.from(data['preferredDays'] ?? []),
      preferredTimeSlot: data['preferredTimeSlot'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'allowEmail': allowEmail,
      'allowSMS': allowSMS,
      'allowWhatsApp': allowWhatsApp,
      'allowCalls': allowCalls,
      'preferredDays': preferredDays,
      'preferredTimeSlot': preferredTimeSlot,
    };
  }
}
