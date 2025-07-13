// [booking_enums.dart] - ENUMS CENTRALIZADOS PARA SISTEMA DE BOOKING
// 📁 Ubicación: /lib/enums/booking_enums.dart
// 🎯 OBJETIVO: Centralizar todos los enums relacionados con booking

import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'booking_types.dart'; // ✅ IMPORT NECESARIO PARA BookingType

/// 🎯 TIPOS DE PASO EN EL FLUJO DE BOOKING
enum BookingStepType {
  clientType('Tipo de Cliente', Icons.person_search, 1),
  serviceSelection('Selección de Servicio', Icons.spa, 2),
  dateTimeSelection('Fecha y Horario', Icons.calendar_today, 3),
  clientInfo('Información del Cliente', Icons.person, 4),
  confirmation('Confirmación', Icons.check_circle, 5);

  const BookingStepType(this.displayName, this.icon, this.order);

  final String displayName;
  final IconData icon;
  final int order;

  /// 🎨 COLOR SEGÚN EL TIPO
  Color getColor(BookingType bookingType) {
    switch (bookingType) {
      case BookingType.particular:
        return kBrandPurple;
      case BookingType.corporate:
        return kAccentBlue;
      case BookingType.enterprise:
        return kAccentGreen;
    }
  }

  /// ✅ VERIFICAR SI ES EL ÚLTIMO PASO
  bool get isLast => this == BookingStepType.confirmation;

  /// ✅ VERIFICAR SI ES EL PRIMER PASO
  bool get isFirst => this == BookingStepType.clientType;

  /// ➡️ SIGUIENTE PASO
  BookingStepType? get next {
    final values = BookingStepType.values;
    final currentIndex = values.indexOf(this);

    if (currentIndex < values.length - 1) {
      return values[currentIndex + 1];
    }
    return null;
  }

  /// ⬅️ PASO ANTERIOR
  BookingStepType? get previous {
    final values = BookingStepType.values;
    final currentIndex = values.indexOf(this);

    if (currentIndex > 0) {
      return values[currentIndex - 1];
    }
    return null;
  }
}

/// 🎛️ ESTADO DEL FLUJO DE BOOKING - ✅ FIX: CON getMessageForUI()
enum BookingFlowState {
  initializing('Inicializando', Icons.hourglass_empty, Colors.grey),
  loadingData('Cargando Datos', Icons.download, Colors.blue),
  ready('Listo', Icons.check_circle, Colors.green),
  validating('Validando', Icons.verified, Colors.orange),
  submitting('Enviando', Icons.send, Colors.purple),
  completed('Completado', Icons.done_all, Colors.green),
  error('Error', Icons.error, Colors.red);

  const BookingFlowState(this.displayName, this.icon, this.color);

  final String displayName;
  final IconData icon;
  final Color color;

  /// 🔄 ESTADOS QUE PERMITEN INTERACCIÓN
  bool get canInteract {
    return this == BookingFlowState.ready;
  }

  /// ⏳ ESTADOS DE CARGA
  bool get isLoading {
    return this == BookingFlowState.initializing ||
        this == BookingFlowState.loadingData ||
        this == BookingFlowState.submitting;
  }

  /// ✅ ESTADOS EXITOSOS
  bool get isSuccess {
    return this == BookingFlowState.ready || this == BookingFlowState.completed;
  }

  /// ❌ ESTADOS DE ERROR
  bool get isError {
    return this == BookingFlowState.error;
  }

  /// 📱 MENSAJE PARA UI - ✅ FIX: MÉTODO REQUERIDO
  String getMessageForUI() {
    switch (this) {
      case BookingFlowState.initializing:
        return 'Preparando el sistema de reservas...';
      case BookingFlowState.loadingData:
        return 'Cargando información disponible...';
      case BookingFlowState.ready:
        return 'Sistema listo para tu reserva';
      case BookingFlowState.validating:
        return 'Verificando información...';
      case BookingFlowState.submitting:
        return 'Procesando tu reserva...';
      case BookingFlowState.completed:
        return '¡Reserva completada exitosamente!';
      case BookingFlowState.error:
        return 'Ha ocurrido un error. Intenta nuevamente.';
    }
  }
}

/// 📝 SEVERIDAD DE VALIDACIÓN
enum ValidationSeverity {
  success('Éxito', Icons.check_circle, Colors.green),
  warning('Advertencia', Icons.warning, Colors.orange),
  error('Error', Icons.error, Colors.red),
  info('Información', Icons.info, Colors.blue);

  const ValidationSeverity(this.displayName, this.icon, this.color);

  final String displayName;
  final IconData icon;
  final Color color;

  /// 🎨 COLOR CON OPACIDAD
  Color getColorWithOpacity(double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// 📱 SNACKBAR COLOR
  Color get snackBarColor {
    switch (this) {
      case ValidationSeverity.success:
        return Colors.green.shade600;
      case ValidationSeverity.warning:
        return Colors.orange.shade600;
      case ValidationSeverity.error:
        return Colors.red.shade600;
      case ValidationSeverity.info:
        return Colors.blue.shade600;
    }
  }
}

/// 📊 PRIORIDAD DE BOOKING
enum BookingPriority {
  low('Baja', Colors.green, 1),
  normal('Normal', Colors.blue, 2),
  high('Alta', Colors.orange, 3),
  urgent('Urgente', Colors.red, 4);

  const BookingPriority(this.displayName, this.color, this.level);

  final String displayName;
  final Color color;
  final int level;

  /// 🎯 OBTENER PRIORIDAD POR TIPO DE BOOKING
  static BookingPriority getForBookingType(BookingType bookingType) {
    switch (bookingType) {
      case BookingType.enterprise:
        return BookingPriority.high;
      case BookingType.corporate:
        return BookingPriority.normal;
      case BookingType.particular:
        return BookingPriority.normal;
    }
  }

  /// 🎨 BADGE COLOR
  Color get badgeColor {
    switch (this) {
      case BookingPriority.low:
        return Colors.green.shade100;
      case BookingPriority.normal:
        return Colors.blue.shade100;
      case BookingPriority.high:
        return Colors.orange.shade100;
      case BookingPriority.urgent:
        return Colors.red.shade100;
    }
  }

  /// 📝 TEXT COLOR
  Color get textColor {
    switch (this) {
      case BookingPriority.low:
        return Colors.green.shade800;
      case BookingPriority.normal:
        return Colors.blue.shade800;
      case BookingPriority.high:
        return Colors.orange.shade800;
      case BookingPriority.urgent:
        return Colors.red.shade800;
    }
  }
}

/// 🔄 ESTADO DE ENVÍO
enum SubmissionState {
  idle('En Espera', Icons.hourglass_empty),
  preparing('Preparando', Icons.build),
  validating('Validando', Icons.verified),
  sending('Enviando', Icons.send),
  processing('Procesando', Icons.sync),
  success('Exitoso', Icons.check_circle),
  failed('Fallido', Icons.error),
  retrying('Reintentando', Icons.refresh);

  const SubmissionState(this.displayName, this.icon);

  final String displayName;
  final IconData icon;

  /// 🔄 PUEDE REINTENTAR
  bool get canRetry {
    return this == SubmissionState.failed;
  }

  /// ⏳ ESTÁ EN PROGRESO
  bool get inProgress {
    return this == SubmissionState.preparing ||
        this == SubmissionState.validating ||
        this == SubmissionState.sending ||
        this == SubmissionState.processing ||
        this == SubmissionState.retrying;
  }

  /// ✅ ES FINAL
  bool get isFinal {
    return this == SubmissionState.success || this == SubmissionState.failed;
  }

  /// 🎨 COLOR SEGÚN ESTADO
  Color get color {
    switch (this) {
      case SubmissionState.idle:
        return Colors.grey;
      case SubmissionState.preparing:
      case SubmissionState.validating:
      case SubmissionState.sending:
      case SubmissionState.processing:
      case SubmissionState.retrying:
        return Colors.blue;
      case SubmissionState.success:
        return Colors.green;
      case SubmissionState.failed:
        return Colors.red;
    }
  }
}

/// 📱 TIPO DE DISPOSITIVO
enum DeviceType {
  mobile('Móvil', Icons.smartphone),
  tablet('Tablet', Icons.tablet),
  desktop('Escritorio', Icons.computer),
  web('Web', Icons.web);

  const DeviceType(this.displayName, this.icon);

  final String displayName;
  final IconData icon;

  /// 📱 DETECTAR DESDE CONTEXT
  static DeviceType detect(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return DeviceType.mobile;
    } else if (screenWidth < 1024) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// 📐 ES MÓVIL
  bool get isMobile => this == DeviceType.mobile;

  /// 📐 ES TABLET
  bool get isTablet => this == DeviceType.tablet;

  /// 📐 ES DESKTOP
  bool get isDesktop => this == DeviceType.desktop;

  /// 📐 ES COMPACTO (mobile o tablet)
  bool get isCompact => isMobile || isTablet;
}

/// 🌐 ORIGEN DEL BOOKING
enum BookingSource {
  publicScreen('Pantalla Pública', Icons.public),
  adminPanel('Panel Admin', Icons.admin_panel_settings),
  mobileApp('App Móvil', Icons.phone_android),
  whatsapp('WhatsApp', Icons.chat),
  phone('Teléfono', Icons.phone),
  walkIn('Llegada Directa', Icons.directions_walk),
  api('API Externa', Icons.api),
  import('Importación', Icons.upload_file);

  const BookingSource(this.displayName, this.icon);

  final String displayName;
  final IconData icon;

  /// 🎨 COLOR SEGÚN ORIGEN
  Color get color {
    switch (this) {
      case BookingSource.publicScreen:
        return kBrandPurple;
      case BookingSource.adminPanel:
        return kAccentBlue;
      case BookingSource.mobileApp:
        return kAccentGreen;
      case BookingSource.whatsapp:
        return const Color(0xFF25D366);
      case BookingSource.phone:
        return Colors.orange;
      case BookingSource.walkIn:
        return Colors.brown;
      case BookingSource.api:
        return Colors.purple;
      case BookingSource.import:
        return Colors.grey;
    }
  }

  /// 🤖 ES AUTOMÁTICO
  bool get isAutomated {
    return this == BookingSource.api ||
        this == BookingSource.import ||
        this == BookingSource.publicScreen;
  }

  /// 👤 REQUIERE INTERVENCIÓN HUMANA
  bool get requiresHumanIntervention {
    return this == BookingSource.phone ||
        this == BookingSource.walkIn ||
        this == BookingSource.whatsapp;
  }
}

/// 📝 MODO DE FORMULARIO
enum FormMode {
  create('Crear', Icons.add, Colors.green),
  edit('Editar', Icons.edit, Colors.blue),
  view('Ver', Icons.visibility, Colors.grey),
  duplicate('Duplicar', Icons.copy, Colors.orange);

  const FormMode(this.displayName, this.icon, this.color);

  final String displayName;
  final IconData icon;
  final Color color;

  /// ✏️ PERMITE EDICIÓN
  bool get allowsEditing {
    return this == FormMode.create ||
        this == FormMode.edit ||
        this == FormMode.duplicate;
  }

  /// 👁️ SOLO LECTURA
  bool get isReadOnly {
    return this == FormMode.view;
  }

  /// 🆕 ES NUEVO
  bool get isNew {
    return this == FormMode.create || this == FormMode.duplicate;
  }
}

/// 🔔 TIPO DE NOTIFICACIÓN
enum NotificationType {
  success('Éxito', Icons.check_circle, Colors.green),
  info('Información', Icons.info, Colors.blue),
  warning('Advertencia', Icons.warning, Colors.orange),
  error('Error', Icons.error, Colors.red),
  loading('Cargando', Icons.hourglass_empty, Colors.grey);

  const NotificationType(this.displayName, this.icon, this.color);

  final String displayName;
  final IconData icon;
  final Color color;

  /// 📱 DURACIÓN EN PANTALLA
  Duration get duration {
    switch (this) {
      case NotificationType.success:
        return const Duration(seconds: 3);
      case NotificationType.info:
        return const Duration(seconds: 4);
      case NotificationType.warning:
        return const Duration(seconds: 5);
      case NotificationType.error:
        return const Duration(seconds: 6);
      case NotificationType.loading:
        return const Duration(seconds: 10); // Hasta que se cancele manualmente
    }
  }

  /// 🎨 BACKGROUND COLOR
  Color get backgroundColor {
    switch (this) {
      case NotificationType.success:
        return Colors.green.shade50;
      case NotificationType.info:
        return Colors.blue.shade50;
      case NotificationType.warning:
        return Colors.orange.shade50;
      case NotificationType.error:
        return Colors.red.shade50;
      case NotificationType.loading:
        return Colors.grey.shade50;
    }
  }
}

/// 🔄 ESTADO DE SINCRONIZACIÓN
enum SyncState {
  idle('En Espera', Icons.cloud_off),
  syncing('Sincronizando', Icons.cloud_sync),
  synced('Sincronizado', Icons.cloud_done),
  error('Error de Sync', Icons.cloud_off),
  offline('Sin Conexión', Icons.wifi_off);

  const SyncState(this.displayName, this.icon);

  final String displayName;
  final IconData icon;

  /// 🎨 COLOR SEGÚN ESTADO
  Color get color {
    switch (this) {
      case SyncState.idle:
        return Colors.grey;
      case SyncState.syncing:
        return Colors.blue;
      case SyncState.synced:
        return Colors.green;
      case SyncState.error:
        return Colors.red;
      case SyncState.offline:
        return Colors.orange;
    }
  }

  /// 🔄 NECESITA SINCRONIZACIÓN
  bool get needsSync {
    return this == SyncState.idle || this == SyncState.error;
  }

  /// 📱 ESTÁ CONECTADO
  bool get isOnline {
    return this != SyncState.offline;
  }
}

/// 📊 TIPO DE MÉTRICA
enum MetricType {
  count('Contador', Icons.numbers),
  percentage('Porcentaje', Icons.percent),
  currency('Moneda', Icons.attach_money),
  duration('Duración', Icons.timer),
  rating('Calificación', Icons.star),
  temperature('Temperatura', Icons.thermostat);

  const MetricType(this.displayName, this.icon);

  final String displayName;
  final IconData icon;

  /// 📝 FORMATEAR VALOR
  String formatValue(dynamic value) {
    switch (this) {
      case MetricType.count:
        return value.toString();
      case MetricType.percentage:
        return '${value.toStringAsFixed(1)}%';
      case MetricType.currency:
        return '\${value.toStringAsFixed(2)}';
      case MetricType.duration:
        if (value is Duration) {
          final minutes = value.inMinutes;
          final hours = minutes ~/ 60;
          final remainingMinutes = minutes % 60;

          if (hours > 0) {
            return '${hours}h ${remainingMinutes}m';
          } else {
            return '${remainingMinutes}m';
          }
        }
        return '${value}min';
      case MetricType.rating:
        return '${value.toStringAsFixed(1)}/5';
      case MetricType.temperature:
        return '${value}°C';
    }
  }
}

/// 🎨 TEMA DE BOOKING
enum BookingTheme {
  default_('Por Defecto', kBrandPurple),
  particular('Particular', kBrandPurple),
  corporate('Corporativo', kAccentBlue),
  enterprise('Empresarial', kAccentGreen),
  premium('Premium', Colors.amber),
  dark('Oscuro', Colors.black87);

  const BookingTheme(this.displayName, this.primaryColor);

  final String displayName;
  final Color primaryColor;

  /// 🎨 GRADIENTE PRINCIPAL
  LinearGradient get gradient {
    switch (this) {
      case BookingTheme.default_:
      case BookingTheme.particular:
        return kHeaderGradient;
      case BookingTheme.corporate:
        return const LinearGradient(colors: [kAccentBlue, kAccentGreen]);
      case BookingTheme.enterprise:
        return const LinearGradient(colors: [kAccentGreen, kAccentBlue]);
      case BookingTheme.premium:
        return LinearGradient(colors: [Colors.amber, Colors.orange]);
      case BookingTheme.dark:
        return LinearGradient(colors: [Colors.black87, Colors.grey.shade800]);
    }
  }

  /// 🎨 COLOR SECUNDARIO
  Color get secondaryColor {
    switch (this) {
      case BookingTheme.default_:
      case BookingTheme.particular:
        return kAccentBlue;
      case BookingTheme.corporate:
        return kAccentGreen;
      case BookingTheme.enterprise:
        return kAccentBlue;
      case BookingTheme.premium:
        return Colors.orange;
      case BookingTheme.dark:
        return Colors.grey.shade600;
    }
  }

  /// 🎨 COLOR DE TEXTO
  Color get textColor {
    switch (this) {
      case BookingTheme.dark:
        return Colors.white;
      default:
        return Colors.black87;
    }
  }

  /// 🎨 OBTENER TEMA POR BOOKING TYPE
  static BookingTheme getForBookingType(BookingType bookingType) {
    switch (bookingType) {
      case BookingType.particular:
        return BookingTheme.particular;
      case BookingType.corporate:
        return BookingTheme.corporate;
      case BookingType.enterprise:
        return BookingTheme.enterprise;
    }
  }
}

/// 🔔 CANAL DE NOTIFICACIÓN
enum NotificationChannel {
  system('Sistema', Icons.notifications),
  email('Email', Icons.email),
  sms('SMS', Icons.sms),
  whatsapp('WhatsApp', Icons.chat),
  push('Push', Icons.notifications_active);

  const NotificationChannel(this.displayName, this.icon);

  final String displayName;
  final IconData icon;

  /// 🚀 ES INSTANTÁNEO
  bool get isInstant {
    return this == NotificationChannel.system ||
        this == NotificationChannel.push ||
        this == NotificationChannel.whatsapp;
  }

  /// 📱 REQUIERE CONFIGURACIÓN EXTERNA
  bool get requiresExternalConfig {
    return this == NotificationChannel.email ||
        this == NotificationChannel.sms ||
        this == NotificationChannel.whatsapp;
  }
}

// ============================================================================
// 🎯 EXTENSIONES ÚTILES PARA ENUMS
// ============================================================================

/// 🎯 EXTENSIONES PARA BOOKING STEP TYPE
extension BookingStepTypeExtensions on BookingStepType {
  /// 🎯 OBTENER STEPS PARA TIPO DE BOOKING
  static List<BookingStepType> getStepsForBookingType(BookingType bookingType) {
    switch (bookingType) {
      case BookingType.enterprise:
        // Enterprise no muestra selección de tipo de cliente
        return [
          BookingStepType.serviceSelection,
          BookingStepType.dateTimeSelection,
          BookingStepType.clientInfo,
          BookingStepType.confirmation,
        ];
      case BookingType.corporate:
      case BookingType.particular:
        return BookingStepType.values;
    }
  }

  /// 🔢 OBTENER NÚMERO DE STEP PARA TIPO
  int getStepNumberForBookingType(BookingType bookingType) {
    final steps = BookingStepTypeExtensions.getStepsForBookingType(bookingType);
    return steps.indexOf(this) + 1;
  }

  /// 📊 TOTAL DE STEPS PARA TIPO
  static int getTotalStepsForBookingType(BookingType bookingType) {
    return getStepsForBookingType(bookingType).length;
  }
}

/// 🎛️ EXTENSIONES PARA BOOKING FLOW STATE
extension BookingFlowStateExtensions on BookingFlowState {
  /// 🎨 OBTENER WIDGET DE LOADING
  Widget getLoadingWidget({String? customMessage}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: color),
        const SizedBox(height: 16),
        Text(
          customMessage ?? getMessageForUI(),
          style: TextStyle(color: color),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 🔔 MOSTRAR SNACKBAR SEGÚN ESTADO
  void showSnackBar(BuildContext context, {String? customMessage}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(customMessage ?? getMessageForUI()),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// 📊 EXTENSIONES PARA MEJOR UX
extension ValidationSeverityExtensions on ValidationSeverity {
  /// 🎨 OBTENER STYLED CONTAINER
  Widget getStyledContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: getColorWithOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: getColorWithOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ============================================================================
// 🎨 UTILIDADES DE TEMA
// ============================================================================

class BookingThemeUtils {
  /// 🎨 OBTENER TEMA COMPLETO PARA BOOKING TYPE
  static Map<String, dynamic> getThemeConfig(BookingType bookingType) {
    final theme = BookingTheme.getForBookingType(bookingType);

    return {
      'theme': theme,
      'primaryColor': theme.primaryColor,
      'secondaryColor': theme.secondaryColor,
      'gradient': theme.gradient,
      'textColor': theme.textColor,
      'displayName': theme.displayName,
    };
  }

  /// 🎨 OBTENER COLORES SEGÚN PRIORIDAD
  static Map<String, Color> getPriorityColors(BookingPriority priority) {
    return {
      'primary': priority.color,
      'background': priority.badgeColor,
      'text': priority.textColor,
    };
  }

  /// 🎨 OBTENER COLORES SEGÚN ESTADO
  static Map<String, Color> getStateColors(BookingFlowState state) {
    return {
      'primary': state.color,
      'background': state.color.withValues(alpha: 0.1),
      'border': state.color.withValues(alpha: 0.3),
    };
  }
}

// ✅ BookingType se importa desde booking_types.dart
// No duplicar la definición aquí
