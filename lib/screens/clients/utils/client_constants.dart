// [client_constants.dart] - CONSTANTES COMPLETAS ENTERPRISE
// 📁 Ubicación: /lib/screens/clients/utils/client_constants.dart
// 🎯 OBJETIVO: Todas las constantes necesarias para el módulo + las faltantes

import 'package:flutter/material.dart';

/// 🎯 CONSTANTES PRINCIPALES DEL MÓDULO CLIENTES
class ClientConstants {
  // 🚫 Constructor privado para evitar instanciación
  ClientConstants._();

  // ====================================================================
  // 📊 CONFIGURACIÓN DE PERFORMANCE Y PAGINACIÓN
  // ====================================================================

  /// Número de clientes a cargar por página
  static const int CLIENTS_PER_PAGE = 50;

  /// Número máximo de clientes en una operación masiva
  static const int MAX_BULK_OPERATIONS = 100;

  /// Tiempo de espera para debounce en búsqueda (ms)
  static const Duration SEARCH_DEBOUNCE = Duration(milliseconds: 500);

  /// Tiempo máximo para animaciones (ms)
  static const Duration ANIMATION_DURATION = Duration(milliseconds: 300);

  /// Duración de animaciones micro (hover, etc)
  static const Duration MICRO_ANIMATION_DURATION = Duration(milliseconds: 150);

  // ====================================================================
  // ⚡ CONFIGURACIÓN DE PERFORMANCE MONITORING - 🆕 AGREGADAS
  // ====================================================================

  /// Tiempo máximo aceptable para carga inicial (ms)
  static const int MAX_INITIAL_LOAD_TIME_MS = 2000;

  /// Tiempo máximo aceptable para búsqueda (ms)
  static const int MAX_SEARCH_TIME_MS = 500;

  /// Tiempo máximo aceptable para filtro (ms)
  static const int MAX_FILTER_TIME_MS = 300;

  /// FPS mínimo aceptable para animaciones
  static const int MIN_ANIMATION_FPS = 45;

  /// Memoria máxima aceptable para el módulo (MB)
  static const int MAX_MODULE_MEMORY_MB = 150;

  // ====================================================================
  // 🔧 CONFIGURACIÓN DE DEBUG Y LOGGING - 🆕 AGREGADAS
  // ====================================================================

  /// Nivel de logging por defecto
  static const String DEFAULT_LOG_LEVEL = 'info';

  /// Prefijo para logs del módulo de clientes
  static const String LOG_PREFIX = '👥 CLIENT_MODULE';

  /// Habilitar logs detallados de performance
  static const bool ENABLE_PERFORMANCE_LOGS = true;

  /// Habilitar logs de cache
  static const bool ENABLE_CACHE_LOGS = true;

  /// Habilitar logs de costos
  static const bool ENABLE_COST_LOGS = true;

  // ====================================================================
  // 💾 CONFIGURACIÓN DE CACHE
  // ====================================================================

  /// Duración del cache antes de considerarse expirado (horas)
  static const int CACHE_EXPIRY_HOURS = 6;

  /// Número máximo de elementos en memoria cache
  static const int MAX_CACHE_SIZE = 1000;

  /// Tamaño máximo del cache en bytes (10MB)
  static const int MAX_CACHE_SIZE_BYTES = 10 * 1024 * 1024;

  /// Intervalo para limpieza automática del cache (horas)
  static const int CACHE_CLEANUP_INTERVAL_HOURS = 24;

  // ====================================================================
  // 📤 CONFIGURACIÓN DE EXPORT/IMPORT
  // ====================================================================

  /// Número máximo de registros para exportar
  static const int MAX_EXPORT_RECORDS = 5000;

  /// Tamaño máximo de archivo para importar (MB)
  static const int MAX_IMPORT_FILE_SIZE_MB = 50;

  /// Extensiones de archivo permitidas para importar
  static const List<String> ALLOWED_IMPORT_EXTENSIONS = ['csv', 'xlsx', 'xls'];

  // ====================================================================
  // 🏷️ ETIQUETAS PREDEFINIDAS
  // ====================================================================

  /// Etiquetas base del sistema
  static const List<String> DEFAULT_TAGS = [
    'VIP',
    'Corporativo',
    'Nuevo',
    'Recurrente',
    'Promoción',
    'Consentido',
    'Especial',
  ];

  /// Colores para etiquetas base (hex)
  static const Map<String, String> TAG_COLORS = {
    'VIP': '#9920A7', // kBrandPurple
    'Corporativo': '#4DB1E0', // kAccentBlue
    'Nuevo': '#4CAF50', // Verde
    'Recurrente': '#FF9800', // Naranja
    'Promoción': '#FF5722', // Rojo-naranja
    'Consentido': '#E91E63', // Rosa
    'Especial': '#F44336', // Rojo
  };

  /// Colores para etiquetas personalizadas
  static const List<String> CUSTOM_TAG_COLORS = [
    '#7c4dff',
    '#009688',
    '#795548',
    '#3f51b5',
    '#00bcd4',
    '#ff5722',
    '#cddc39',
    '#607d8b',
    '#e91e63',
    '#ffc107',
    '#9c27b0',
    '#2196f3',
    '#4caf50',
    '#ff9800',
    '#673ab7',
  ];

  // ====================================================================
  // 📍 DATOS GEOGRÁFICOS (CDMX)
  // ====================================================================

  /// Alcaldías de la Ciudad de México
  static const List<String> ALCALDIAS_CDMX = [
    'Álvaro Obregón',
    'Azcapotzalco',
    'Benito Juárez',
    'Coyoacán',
    'Cuajimalpa de Morelos',
    'Cuauhtémoc',
    'Gustavo A. Madero',
    'Iztacalco',
    'Iztapalapa',
    'La Magdalena Contreras',
    'Miguel Hidalgo',
    'Milpa Alta',
    'Tláhuac',
    'Tlalpan',
    'Venustiano Carranza',
    'Xochimilco',
  ];

  // ====================================================================
  // 🎨 CONFIGURACIÓN DE UI
  // ====================================================================

  /// Radio de bordes para cards
  static const double CARD_BORDER_RADIUS = 16.0;

  /// Espaciado estándar
  static const double STANDARD_SPACING = 16.0;

  /// Espaciado pequeño
  static const double SMALL_SPACING = 8.0;

  /// Espaciado grande
  static const double LARGE_SPACING = 24.0;

  /// Altura mínima para cards de cliente
  static const double MIN_CLIENT_CARD_HEIGHT = 120.0;

  /// Ancho máximo para el panel de filtros
  static const double FILTERS_PANEL_WIDTH = 320.0;

  /// Altura de la toolbar de acciones masivas
  static const double BULK_TOOLBAR_HEIGHT = 60.0;

  // ====================================================================
  // 📱 RESPONSIVE DESIGN
  // ====================================================================

  /// Breakpoint para móvil
  static const double MOBILE_BREAKPOINT = 600.0;

  /// Breakpoint para tablet
  static const double TABLET_BREAKPOINT = 900.0;

  /// Breakpoint para desktop
  static const double DESKTOP_BREAKPOINT = 1200.0;

  /// Ancho máximo del contenido principal
  static const double MAX_CONTENT_WIDTH = 1400.0;

  // ====================================================================
  // 🔍 CONFIGURACIÓN DE BÚSQUEDA Y FILTROS
  // ====================================================================

  /// Número mínimo de caracteres para activar búsqueda
  static const int MIN_SEARCH_CHARS = 2;

  /// Número máximo de filtros guardados por usuario
  static const int MAX_SAVED_FILTERS = 10;

  /// Tipos de ordenamiento disponibles
  static const List<String> SORT_OPTIONS = [
    'Nombre A-Z',
    'Nombre Z-A',
    'Fecha creación (reciente)',
    'Fecha creación (antigua)',
    'Ingresos (mayor)',
    'Ingresos (menor)',
    'Citas (más)',
    'Citas (menos)',
    'Satisfacción (mayor)',
    'Satisfacción (menor)',
  ];

  // ====================================================================
  // 📊 CONFIGURACIÓN DE ANALYTICS
  // ====================================================================

  /// Período por defecto para analytics (días)
  static const int DEFAULT_ANALYTICS_PERIOD_DAYS = 30;

  /// Número máximo de elementos en gráficos
  static const int MAX_CHART_ITEMS = 10;

  /// Colores para gráficos (status)
  static const Map<String, Color> CHART_COLORS = {
    'active': Color(0xFF4CAF50), // Verde
    'inactive': Color(0xFFFF9800), // Naranja
    'suspended': Color(0xFFF44336), // Rojo
    'prospect': Color(0xFF2196F3), // Azul
    'vip': Color(0xFF9C27B0), // Morado
  };

  // ====================================================================
  // 💰 CONFIGURACIÓN DE CONTROL DE COSTOS
  // ====================================================================

  /// Modo de analytics por defecto (para control de costos)
  static const String DEFAULT_ANALYTICS_MODE = 'lowCost';

  /// Número máximo de consultas por hora en modo low-cost
  static const int MAX_QUERIES_PER_HOUR_LOW_COST = 10;

  /// Número máximo de consultas por día en modo standard
  static const int MAX_QUERIES_PER_DAY_STANDARD = 100;

  // ====================================================================
  // 📝 VALIDACIONES Y REGLAS DE NEGOCIO
  // ====================================================================

  /// Longitud mínima para nombres
  static const int MIN_NAME_LENGTH = 2;

  /// Longitud máxima para nombres
  static const int MAX_NAME_LENGTH = 50;

  /// Longitud mínima para teléfonos
  static const int MIN_PHONE_LENGTH = 8;

  /// Longitud máxima para teléfonos
  static const int MAX_PHONE_LENGTH = 15;

  /// Patrón para validación de email
  static const String EMAIL_PATTERN =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  /// Patrón para validación de teléfono (números y espacios)
  static const String PHONE_PATTERN = r'^[0-9\s\-\+\(\)]+$';

  /// Patrón para código postal (México)
  static const String POSTAL_CODE_PATTERN = r'^\d{5}$';

  // ====================================================================
  // 🎯 CONFIGURACIÓN DE MÉTRICAS Y KPIs
  // ====================================================================

  /// Valores mínimos para considerarse "cliente activo"
  static const int MIN_APPOINTMENTS_ACTIVE_CLIENT = 1;

  /// Días sin actividad para considerar cliente inactivo
  static const int DAYS_WITHOUT_ACTIVITY_INACTIVE = 90;

  /// Puntaje mínimo de satisfacción para ser considerado "satisfecho"
  static const double MIN_SATISFACTION_SCORE = 4.0;

  /// Ingresos mínimos para considerarse "cliente VIP"
  static const double MIN_REVENUE_VIP_CLIENT = 5000.0;

  // ====================================================================
  // 🔄 CONFIGURACIÓN DE SINCRONIZACIÓN
  // ====================================================================

  /// Intervalo para sincronización automática (minutos)
  static const int AUTO_SYNC_INTERVAL_MINUTES = 30;

  /// Número máximo de reintentos para operaciones fallidas
  static const int MAX_RETRY_ATTEMPTS = 3;

  /// Tiempo de espera entre reintentos (segundos)
  static const int RETRY_DELAY_SECONDS = 2;

  // ====================================================================
  // 📄 CONFIGURACIÓN DE PAGINACIÓN
  // ====================================================================

  /// Opciones de elementos por página
  static const List<int> PAGE_SIZE_OPTIONS = [25, 50, 100, 200];

  /// Número máximo de páginas a mostrar en paginador
  static const int MAX_PAGINATION_PAGES = 10;

  // ====================================================================
  // 🎨 CONFIGURACIÓN DE TEMAS Y ESTILOS
  // ====================================================================

  /// Opacidad para elementos deshabilitados
  static const double DISABLED_OPACITY = 0.6;

  /// Opacidad para elementos en hover
  static const double HOVER_OPACITY = 0.8;

  /// Elevación para cards normales
  static const double CARD_ELEVATION = 2.0;

  /// Elevación para cards en hover
  static const double CARD_HOVER_ELEVATION = 6.0;

  /// Elevación para elementos flotantes
  static const double FLOATING_ELEVATION = 8.0;

  // ====================================================================
  // 📱 CONFIGURACIÓN DE NOTIFICACIONES
  // ====================================================================

  /// Duración por defecto para SnackBars (segundos)
  static const int SNACKBAR_DURATION_SECONDS = 4;

  /// Duración para SnackBars de error (segundos)
  static const int ERROR_SNACKBAR_DURATION_SECONDS = 6;

  /// Duración para SnackBars de éxito (segundos)
  static const int SUCCESS_SNACKBAR_DURATION_SECONDS = 3;

  // ====================================================================
  // 🔐 CONFIGURACIÓN DE SEGURIDAD
  // ====================================================================

  /// Campos sensibles que requieren log de auditoría
  static const List<String> AUDIT_REQUIRED_FIELDS = [
    'email',
    'telefono',
    'totalRevenue',
    'tags',
    'status',
  ];

  /// Tiempo de retención para logs de auditoría (días)
  static const int AUDIT_LOG_RETENTION_DAYS = 365;

  // ====================================================================
  // 🎮 MÉTODOS HELPER ESTÁTICOS
  // ====================================================================

  /// Obtener color para etiqueta base
  static Color getBaseTagColor(String tagLabel) {
    final colorHex = TAG_COLORS[tagLabel];
    if (colorHex != null) {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    }
    return const Color(0xFF9920A7); // Default: kBrandPurple
  }

  /// Obtener color para etiqueta personalizada basado en índice
  static Color getCustomTagColor(int index) {
    final colorHex = CUSTOM_TAG_COLORS[index % CUSTOM_TAG_COLORS.length];
    return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
  }

  /// Verificar si es una etiqueta base
  static bool isBaseTag(String tagLabel) {
    return DEFAULT_TAGS.any(
      (baseTag) => baseTag.toLowerCase() == tagLabel.toLowerCase(),
    );
  }

  /// Obtener breakpoint actual basado en ancho de pantalla
  static String getCurrentBreakpoint(double screenWidth) {
    if (screenWidth < MOBILE_BREAKPOINT) return 'mobile';
    if (screenWidth < TABLET_BREAKPOINT) return 'tablet';
    if (screenWidth < DESKTOP_BREAKPOINT) return 'desktop';
    return 'large';
  }

  /// Verificar si es dispositivo móvil
  static bool isMobile(double screenWidth) {
    return screenWidth < MOBILE_BREAKPOINT;
  }

  /// Verificar si es tablet
  static bool isTablet(double screenWidth) {
    return screenWidth >= MOBILE_BREAKPOINT && screenWidth < DESKTOP_BREAKPOINT;
  }

  /// Verificar si es desktop
  static bool isDesktop(double screenWidth) {
    return screenWidth >= DESKTOP_BREAKPOINT;
  }

  /// Obtener número de columnas para grid basado en breakpoint
  static int getGridColumns(double screenWidth) {
    if (isMobile(screenWidth)) return 1;
    if (isTablet(screenWidth)) return 2;
    return 3;
  }

  /// Obtener padding responsivo
  static EdgeInsets getResponsivePadding(double screenWidth) {
    if (isMobile(screenWidth)) {
      return const EdgeInsets.all(SMALL_SPACING);
    } else if (isTablet(screenWidth)) {
      return const EdgeInsets.all(STANDARD_SPACING);
    } else {
      return const EdgeInsets.all(LARGE_SPACING);
    }
  }

  /// Formatear número con separadores de miles
  static String formatNumber(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toString();
    }
  }

  /// Formatear moneda (pesos mexicanos)
  static String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  /// Formatear porcentaje
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Obtener mensaje de validación para campo requerido
  static String getRequiredFieldMessage(String fieldName) {
    return '$fieldName es requerido';
  }

  /// Obtener mensaje de validación para email inválido
  static String getInvalidEmailMessage() {
    return 'Ingrese un email válido';
  }

  /// Obtener mensaje de validación para teléfono inválido
  static String getInvalidPhoneMessage() {
    return 'Ingrese un teléfono válido (8-15 dígitos)';
  }

  /// Obtener mensaje de validación para código postal inválido
  static String getInvalidPostalCodeMessage() {
    return 'Ingrese un código postal válido (5 dígitos)';
  }
}
