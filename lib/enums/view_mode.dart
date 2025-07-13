// [view_mode.dart] - ENUM SISTEMA DE VISTAS MÚLTIPLES - REORDENADO
// 📁 Ubicación: /lib/enums/view_mode.dart
// 🎯 OBJETIVO: Enum robusto para modos de vista con metadata enterprise - TABLA DEFAULT

import 'package:flutter/material.dart';

/// 🎯 MODOS DE VISTA PARA SISTEMA DE CLIENTES ENTERPRISE - REORDENADO
/// Cada modo optimizado para diferentes casos de uso y densidad de información
enum ViewMode {
  /// 📊 TABLE: Vista tipo spreadsheet - 10+ clientes por pantalla (DEFAULT)
  /// Ideal para: Análisis masivo, comparación, data entry, exports
  table(
    'Tabla',
    Icons.table_rows,
    48.0,
    'Vista densa tipo Excel',
  ),

  /// 📦 COMPACT: Máxima densidad - 6-8 clientes por pantalla
  /// Ideal para: Navegación rápida, búsqueda, selección masiva
  compact(
    'Compacto',
    Icons.view_agenda,
    80.0,
    'Máxima densidad de información',
  ),

  /// 🛋️ COMFORTABLE: Vista original - 2-3 clientes por pantalla
  /// Ideal para: Lectura detallada, análisis individual, primera impresión
  comfortable(
    'Cómodo',
    Icons.view_comfy,
    160.0,
    'Vista completa con glassmorphism',
  );

  const ViewMode(
    this.displayName,
    this.icon,
    this.cardHeight,
    this.description,
  );

  /// 🏷️ PROPIEDADES INMUTABLES
  final String displayName;
  final IconData icon;
  final double cardHeight;
  final String description;

  /// 🎨 COLORES DINÁMICOS POR MODO - REORDENADOS
  Color get themeColor {
    switch (this) {
      case ViewMode.table:
        return const Color(0xFF2196F3); // Azul para datos
      case ViewMode.compact:
        return const Color(0xFF4CAF50); // Verde para eficiencia
      case ViewMode.comfortable:
        return const Color(0xFF9920A7); // Purple brand
    }
  }

  /// 🎯 GETTERS DE CONVENIENCIA
  bool get isTable => this == ViewMode.table;
  bool get isCompact => this == ViewMode.compact;
  bool get isComfortable => this == ViewMode.comfortable;

  /// 📊 MÉTRICS HELPERS
  int getExpectedClientsPerScreen(double screenHeight) {
    // Cálculo real considerando headers, spacing, etc.
    final availableHeight = screenHeight - 400; // Headers + margins + search
    return (availableHeight / (cardHeight + _getSpacing())).floor();
  }

  double _getSpacing() {
    switch (this) {
      case ViewMode.table:
        return 1.0;
      case ViewMode.compact:
        return 8.0;
      case ViewMode.comfortable:
        return 12.0;
    }
  }

  /// 🎨 UI HELPERS
  EdgeInsets get cardMargin {
    switch (this) {
      case ViewMode.table:
        return const EdgeInsets.only(bottom: 1);
      case ViewMode.compact:
        return const EdgeInsets.only(bottom: 8);
      case ViewMode.comfortable:
        return const EdgeInsets.only(bottom: 12);
    }
  }

  BorderRadius get cardBorderRadius {
    switch (this) {
      case ViewMode.table:
        return BorderRadius.circular(0);
      case ViewMode.compact:
        return BorderRadius.circular(12);
      case ViewMode.comfortable:
        return BorderRadius.circular(16);
    }
  }

  /// 🎯 FEATURES SUPPORT MAP
  bool supportsFeature(ViewModeFeature feature) {
    switch (feature) {
      case ViewModeFeature.fullAddress:
        return this == ViewMode.comfortable;
      case ViewModeFeature.allTags:
        return this == ViewMode.comfortable;
      case ViewModeFeature.metricsDisplay:
        return this != ViewMode.table;
      case ViewModeFeature.avatarFull:
        return this == ViewMode.comfortable;
      case ViewModeFeature.hoverAnimations:
        return this != ViewMode.table;
      case ViewModeFeature.glassmorphism:
        return this != ViewMode.table;
      case ViewModeFeature.clickableFields:
        return this != ViewMode.table;
      case ViewModeFeature.bulkSelection:
        return true; // Todos soportan selección
    }
  }

  /// 📈 PERFORMANCE METRICS
  Map<String, dynamic> getPerformanceExpectations() {
    return {
      'cardHeight': cardHeight,
      'expectedClientsPerScreen': {
        'mobile': getExpectedClientsPerScreen(600),
        'tablet': getExpectedClientsPerScreen(800),
        'desktop': getExpectedClientsPerScreen(1000),
      },
      'renderComplexity': _getRenderComplexity(),
      'memoryFootprint': _getMemoryFootprint(),
      'scrollOptimization': _getScrollOptimization(),
    };
  }

  String _getRenderComplexity() {
    switch (this) {
      case ViewMode.table:
        return 'low';
      case ViewMode.compact:
        return 'medium';
      case ViewMode.comfortable:
        return 'high';
    }
  }

  String _getMemoryFootprint() {
    switch (this) {
      case ViewMode.table:
        return 'low';
      case ViewMode.compact:
        return 'medium';
      case ViewMode.comfortable:
        return 'high';
    }
  }

  String _getScrollOptimization() {
    switch (this) {
      case ViewMode.table:
        return 'maximum';
      case ViewMode.compact:
        return 'high';
      case ViewMode.comfortable:
        return 'medium';
    }
  }

  /// 🔄 SERIALIZATION
  static ViewMode fromString(String value) {
    return ViewMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ViewMode.table, // ✅ DEFAULT CAMBIADO A TABLE
    );
  }

  @override
  String toString() => name;
}

/// 🎯 FEATURES ENUM PARA CAPABILITIES
enum ViewModeFeature {
  fullAddress,
  allTags,
  metricsDisplay,
  avatarFull,
  hoverAnimations,
  glassmorphism,
  clickableFields,
  bulkSelection,
}

/// 🎨 EXTENSION PARA UI THEMING
extension ViewModeTheming on ViewMode {
  /// Gradient específico para cada modo
  LinearGradient get gradient {
    return LinearGradient(
      colors: [
        themeColor.withValues(alpha: 0.1),
        themeColor.withValues(alpha: 0.05),
        Colors.white.withValues(alpha: 0.9),
      ],
      stops: const [0.0, 0.3, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Sombra optimizada por modo
  List<BoxShadow> get shadows {
    switch (this) {
      case ViewMode.table:
        return [];
      case ViewMode.compact:
        return [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      case ViewMode.comfortable:
        return [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 15,
            spreadRadius: -5,
            offset: const Offset(0, -5),
          ),
        ];
    }
  }
}
