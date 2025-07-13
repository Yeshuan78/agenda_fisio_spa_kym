// [booking_configuration_service.dart] - SERVICIO DE CONFIGURACIÓN DE BOOKING
// 📁 Ubicación: /lib/services/booking/booking_configuration_service.dart  
// 🎯 OBJETIVO: Centralizar lógica de configuración, detección de tipos y temas

import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../enums/booking_types.dart';

/// 🎯 SERVICIO DE CONFIGURACIÓN DE BOOKING
/// Centraliza toda la lógica de configuración según el tipo de booking
class BookingConfigurationService {
  
  /// 🔍 DETECTAR TIPO DE BOOKING
  /// Extraído de: public_booking_screen.dart línea ~167
  static BookingType detectBookingType({
    String? companyId,
    Map<String, String>? queryParams,
    bool isParticular = false,
  }) {
    final params = queryParams ?? {};
    final eventId = params['e'] ?? params['eventId'];

    if (companyId != null && eventId != null) {
      return BookingType.enterprise;
    } else if (eventId != null) {
      return BookingType.corporate;
    } else if (isParticular) {
      return BookingType.particular;
    } else {
      return BookingType.particular;
    }
  }

  /// 🎨 OBTENER CONFIGURACIÓN DE TEMA
  /// Extraído de: public_booking_screen.dart línea ~180-220
  static Map<String, dynamic> getThemeConfig(
    BookingType bookingType, {
    Map<String, dynamic>? selectedEventData,
    Map<String, dynamic>? companyData,
  }) {
    switch (bookingType) {
      case BookingType.particular:
        return {
          'title': 'Agenda tu Cita Personal',
          'subtitle': 'Servicios de relajación y bienestar',
          'gradient': kHeaderGradient,
          'accentColor': kBrandPurple,
          'icon': Icons.spa,
          'showPricing': true,
          'requiresAddress': true,
        };

      case BookingType.corporate:
        return {
          'title': 'Evento Corporativo',
          'subtitle': selectedEventData?['nombre'] ?? 'Servicios wellness empresarial',
          'gradient': const LinearGradient(colors: [kAccentBlue, kAccentGreen]),
          'accentColor': kAccentBlue,
          'icon': Icons.business_center,
          'showPricing': true,
          'requiresAddress': false,
        };

      case BookingType.enterprise:
        return {
          'title': 'Beneficio Empresarial',
          'subtitle': '${companyData?['nombre'] ?? 'Tu empresa'} - ${selectedEventData?['nombre'] ?? 'Servicio wellness'}',
          'gradient': const LinearGradient(colors: [kAccentGreen, kAccentBlue]),
          'accentColor': kAccentGreen,
          'icon': Icons.business,
          'showPricing': false,
          'requiresAddress': false,
        };
    }
  }

  /// 💰 CALCULAR PRECIO SEGÚN TIPO DE BOOKING
  /// Extraído de: public_booking_screen.dart línea ~400
  static int getPriceForBookingType(int basePrice, BookingType bookingType) {
    switch (bookingType) {
      case BookingType.enterprise:
        return 0; // Gratis para empresas
      case BookingType.corporate:
        return (basePrice * 0.7).round(); // 30% descuento
      case BookingType.particular:
        return basePrice; // Precio completo
    }
  }

  /// 🎯 DETERMINAR SI MOSTRAR STEP DE TIPO DE CLIENTE
  static bool shouldShowClientTypeStep(BookingType bookingType) {
    return bookingType != BookingType.enterprise;
  }

  /// 🔢 CALCULAR NÚMERO TOTAL DE STEPS
  static int getTotalSteps(BookingType bookingType) {
    return shouldShowClientTypeStep(bookingType) ? 4 : 3;
  }

  /// 📋 OBTENER CAMPOS REQUERIDOS SEGÚN TIPO
  static List<String> getRequiredFields(BookingType bookingType, bool isExistingClient) {
    if (isExistingClient) {
      // Cliente existente
      switch (bookingType) {
        case BookingType.enterprise:
          return ['empleado'];
        case BookingType.corporate:
        case BookingType.particular:
          return ['telefono'];
      }
    } else {
      // Cliente nuevo
      switch (bookingType) {
        case BookingType.enterprise:
          return ['nombre', 'telefono', 'empleado'];
        case BookingType.corporate:
          return ['nombre', 'telefono', 'email'];
        case BookingType.particular:
          return ['nombre', 'telefono', 'email'];
      }
    }
  }

  /// 🏷️ OBTENER LABELS SEGÚN TIPO
  static Map<String, String> getFieldLabels(BookingType bookingType) {
    switch (bookingType) {
      case BookingType.enterprise:
        return {
          'nombre': 'Nombre (sin apellidos)',
          'telefono': 'Teléfono',
          'empleado': 'Número de empleado',
        };
      case BookingType.corporate:
      case BookingType.particular:
        return {
          'nombre': 'Nombre completo',
          'telefono': 'Teléfono',
          'email': 'Email',
          'direccion': 'Dirección (para servicios a domicilio)',
        };
    }
  }

  /// 🔧 OBTENER PLACEHOLDERS SEGÚN TIPO
  static Map<String, String> getFieldPlaceholders(BookingType bookingType) {
    switch (bookingType) {
      case BookingType.enterprise:
        return {
          'nombre': 'María',
          'telefono': '55 1234 5678',
          'empleado': '12345',
        };
      case BookingType.corporate:
      case BookingType.particular:
        return {
          'nombre': 'María González',
          'telefono': '55 1234 5678',
          'email': 'maria@email.com',
          'direccion': 'Calle, número, colonia, código postal',
        };
    }
  }

  /// 📝 OBTENER MENSAJE DE BIENVENIDA SEGÚN TIPO
  static String getWelcomeMessage(BookingType bookingType) {
    switch (bookingType) {
      case BookingType.enterprise:
        return 'Accede a tu beneficio empresarial de wellness';
      case BookingType.corporate:
        return 'Reserva tu servicio en el evento corporativo';
      case BookingType.particular:
        return 'Agenda tu cita personal de relajación';
    }
  }

  /// 🎉 OBTENER MENSAJE DE CONFIRMACIÓN SEGÚN TIPO
  static String getConfirmationMessage(BookingType bookingType) {
    switch (bookingType) {
      case BookingType.enterprise:
        return 'Tu beneficio empresarial ha sido reservado exitosamente';
      case BookingType.corporate:
        return 'Tu participación en el evento ha sido confirmada';
      case BookingType.particular:
        return 'Tu cita personal ha sido agendada exitosamente';
    }
  }

  /// 📞 OBTENER INSTRUCCIONES DE CONTACTO SEGÚN TIPO
  static List<String> getContactInstructions(BookingType bookingType) {
    switch (bookingType) {
      case BookingType.enterprise:
        return [
          'Te contactaremos vía WhatsApp para confirmar tu servicio.',
          'La coordinación será directa con el área de Recursos Humanos.',
        ];
      case BookingType.corporate:
        return [
          'Te contactaremos vía WhatsApp para confirmar tu participación.',
          'También recibirás información adicional del evento.',
        ];
      case BookingType.particular:
        return [
          'Te contactaremos vía WhatsApp para confirmar tu cita.',
          'También recibirás el enlace de pago una vez confirmada.',
        ];
    }
  }

  /// 🔍 VALIDAR CONFIGURACIÓN DE BOOKING
  static bool validateBookingConfiguration({
    required BookingType bookingType,
    String? companyId,
    String? eventId,
  }) {
    switch (bookingType) {
      case BookingType.enterprise:
        return companyId != null && eventId != null;
      case BookingType.corporate:
        return eventId != null;
      case BookingType.particular:
        return true; // Siempre válido
    }
  }

  /// 🎨 OBTENER COLORES DINÁMICOS SEGÚN TIPO
  static Color getAccentColor(BookingType bookingType) {
    switch (bookingType) {
      case BookingType.particular:
        return kBrandPurple;
      case BookingType.corporate:
        return kAccentBlue;
      case BookingType.enterprise:
        return kAccentGreen;
    }
  }

  /// 🎭 OBTENER GRADIENTE SEGÚN TIPO
  static LinearGradient getGradient(BookingType bookingType) {
    switch (bookingType) {
      case BookingType.particular:
        return kHeaderGradient;
      case BookingType.corporate:
        return const LinearGradient(colors: [kAccentBlue, kAccentGreen]);
      case BookingType.enterprise:
        return const LinearGradient(colors: [kAccentGreen, kAccentBlue]);
    }
  }

  /// 🏢 OBTENER ICONO SEGÚN TIPO
  static IconData getIcon(BookingType bookingType) {
    switch (bookingType) {
      case BookingType.particular:
        return Icons.spa;
      case BookingType.corporate:
        return Icons.business_center;
      case BookingType.enterprise:
        return Icons.business;
    }
  }

  /// 📊 OBTENER CONFIGURACIÓN COMPLETA COMO OBJETO
  static BookingConfiguration getConfiguration(
    BookingType bookingType, {
    Map<String, dynamic>? selectedEventData,
    Map<String, dynamic>? companyData,
  }) {
    final config = getThemeConfig(
      bookingType,
      selectedEventData: selectedEventData,
      companyData: companyData,
    );

    return BookingConfiguration(
      type: bookingType,
      title: config['title'],
      subtitle: config['subtitle'],
      icon: config['icon'],
      gradient: config['gradient'],
      accentColor: config['accentColor'],
      showPricing: config['showPricing'],
      requiresAddress: config['requiresAddress'],
      showClientTypeStep: shouldShowClientTypeStep(bookingType),
      totalSteps: getTotalSteps(bookingType),
      welcomeMessage: getWelcomeMessage(bookingType),
      confirmationMessage: getConfirmationMessage(bookingType),
      contactInstructions: getContactInstructions(bookingType),
      requiredFields: {},
      fieldLabels: getFieldLabels(bookingType),
      fieldPlaceholders: getFieldPlaceholders(bookingType),
    );
  }
}

/// 📋 MODELO DE CONFIGURACIÓN DE BOOKING
class BookingConfiguration {
  final BookingType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final Color accentColor;
  final bool showPricing;
  final bool requiresAddress;
  final bool showClientTypeStep;
  final int totalSteps;
  final String welcomeMessage;
  final String confirmationMessage;
  final List<String> contactInstructions;
  final Map<String, List<String>> requiredFields;
  final Map<String, String> fieldLabels;
  final Map<String, String> fieldPlaceholders;

  const BookingConfiguration({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accentColor,
    required this.showPricing,
    required this.requiresAddress,
    required this.showClientTypeStep,
    required this.totalSteps,
    required this.welcomeMessage,
    required this.confirmationMessage,
    required this.contactInstructions,
    required this.requiredFields,
    required this.fieldLabels,
    required this.fieldPlaceholders,
  });

  /// 🔄 COPIAR CON MODIFICACIONES
  BookingConfiguration copyWith({
    BookingType? type,
    String? title,
    String? subtitle,
    IconData? icon,
    LinearGradient? gradient,
    Color? accentColor,
    bool? showPricing,
    bool? requiresAddress,
    bool? showClientTypeStep,
    int? totalSteps,
    String? welcomeMessage,
    String? confirmationMessage,
    List<String>? contactInstructions,
    Map<String, List<String>>? requiredFields,
    Map<String, String>? fieldLabels,
    Map<String, String>? fieldPlaceholders,
  }) {
    return BookingConfiguration(
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      gradient: gradient ?? this.gradient,
      accentColor: accentColor ?? this.accentColor,
      showPricing: showPricing ?? this.showPricing,
      requiresAddress: requiresAddress ?? this.requiresAddress,
      showClientTypeStep: showClientTypeStep ?? this.showClientTypeStep,
      totalSteps: totalSteps ?? this.totalSteps,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      confirmationMessage: confirmationMessage ?? this.confirmationMessage,
      contactInstructions: contactInstructions ?? this.contactInstructions,
      requiredFields: requiredFields ?? this.requiredFields,
      fieldLabels: fieldLabels ?? this.fieldLabels,
      fieldPlaceholders: fieldPlaceholders ?? this.fieldPlaceholders,
    );
  }

  /// 📋 CONVERSIÓN A MAP
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'showPricing': showPricing,
      'requiresAddress': requiresAddress,
      'showClientTypeStep': showClientTypeStep,
      'totalSteps': totalSteps,
      'welcomeMessage': welcomeMessage,
      'confirmationMessage': confirmationMessage,
      'contactInstructions': contactInstructions,
      'requiredFields': requiredFields,
      'fieldLabels': fieldLabels,
      'fieldPlaceholders': fieldPlaceholders,
    };
  }

  @override
  String toString() {
    return 'BookingConfiguration{type: ${type.name}, title: $title, totalSteps: $totalSteps}';
  }
}