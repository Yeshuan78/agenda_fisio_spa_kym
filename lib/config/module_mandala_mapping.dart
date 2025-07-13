// [module_mandala_mapping.dart] - MAPEO MÓDULO->MANDALA
// 📁 Ubicación: /lib/config/module_mandala_mapping.dart
// 🎯 OBJETIVO: Configuración centralizada del mapeo módulos a patrones mandala

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/widgets/mandala/mandala_painters.dart';

/// 🌀 ENUMS PARA TIPOS DE MANDALA
enum MandalaPattern {
  fibonacci,
  flowerOfLife,
  molecular,
  vortex,
  crystalline,
  penrose,
}

/// 📊 ENUMS DE CONFIGURACIÓN
enum ComplexityLevel { low, medium, high }

enum AnimationSpeed { slow, normal, fast }

/// 🗺️ MAPEO CENTRALIZADO DE MÓDULOS A MANDALAS
/// Cada módulo del CRM tiene su patrón matemático único
class ModuleMandalaMapping {
  // 🚫 Constructor privado
  ModuleMandalaMapping._();

  /// 🌀 MAPEO PRINCIPAL: MÓDULO -> PATRÓN
  static const Map<String, MandalaPattern> _modulePatterns = {
    // 📅 AGENDA - Fibonacci (Espiral áurea, crecimiento orgánico del tiempo)
    'agenda': MandalaPattern.fibonacci,

    // 👥 CLIENTES - Flower of Life (Conexiones humanas, red de relaciones)
    'clientes': MandalaPattern.flowerOfLife,

    // 👨‍⚕️ PROFESIONALES - Molecular (Estructura de equipo, conexiones especializadas)
    'profesionales': MandalaPattern.molecular,

    // 🛍️ SERVICIOS - Vortex (Flujo de energía, oferta de tratamientos)
    'servicios': MandalaPattern.vortex,

    // 🔔 RECORDATORIOS - Crystalline (Estructura ordenada, precisión temporal)
    'recordatorios': MandalaPattern.crystalline,

    // 🏢 CORPORATIVO - Penrose (Geometría compleja, estructuras empresariales)
    'corporativo': MandalaPattern.penrose,
    'empresas': MandalaPattern.penrose,
    'contratos': MandalaPattern.penrose,
    'facturacion': MandalaPattern.penrose,

    // 📊 KYM PULSE - Fibonacci (Datos en tiempo real, crecimiento exponencial)
    'kympulse': MandalaPattern.fibonacci,
    'eventos': MandalaPattern.fibonacci,
    'encuestas': MandalaPattern.fibonacci,

    // 💰 VENTAS - Vortex (Energía comercial, flujo de oportunidades)
    'ventas': MandalaPattern.vortex,
    'campanas': MandalaPattern.vortex,
    'cotizaciones': MandalaPattern.vortex,

    // ⚙️ ADMIN - Molecular (Sistema complejo, administración estructurada)
    'admin': MandalaPattern.molecular,
    'configuracion': MandalaPattern.molecular,
    'usuarios': MandalaPattern.molecular,

    // 📈 REPORTES - Crystalline (Datos estructurados, análisis ordenado)
    'reportes': MandalaPattern.crystalline,
    'analytics': MandalaPattern.crystalline,
    'dashboard': MandalaPattern.crystalline,
  };

  /// 🎨 CONFIGURACIONES PERSONALIZADAS POR MÓDULO
  static final Map<String, ModuleVisualConfig> _moduleConfigs = {
    'agenda': const ModuleVisualConfig(
      primaryColor: Color(0xFF4CAF50),
      secondaryColor: Color(0xFF8BC34A),
      description:
          'Espiral áurea que representa el crecimiento orgánico del tiempo',
      complexity: ComplexityLevel.medium,
      animationSpeed: AnimationSpeed.normal,
    ),
    'clientes': const ModuleVisualConfig(
      primaryColor: Color(0xFF2196F3),
      secondaryColor: Color(0xFF03DAC6),
      description: 'Patrón sagrado de conexiones humanas y relaciones',
      complexity: ComplexityLevel.high,
      animationSpeed: AnimationSpeed.slow,
    ),
    'profesionales': const ModuleVisualConfig(
      primaryColor: Color(0xFF9C27B0),
      secondaryColor: Color(0xFFE1BEE7),
      description: 'Estructura molecular que simboliza el equipo especializado',
      complexity: ComplexityLevel.medium,
      animationSpeed: AnimationSpeed.normal,
    ),
    'servicios': const ModuleVisualConfig(
      primaryColor: Color(0xFFFF9800),
      secondaryColor: Color(0xFFFFCC02),
      description: 'Vórtices de energía que fluyen como tratamientos',
      complexity: ComplexityLevel.medium,
      animationSpeed: AnimationSpeed.fast,
    ),
    'recordatorios': const ModuleVisualConfig(
      primaryColor: Color(0xFFF44336),
      secondaryColor: Color(0xFFFFAB91),
      description: 'Red cristalina de precisión temporal y orden',
      complexity: ComplexityLevel.low,
      animationSpeed: AnimationSpeed.normal,
    ),
    'corporativo': const ModuleVisualConfig(
      primaryColor: Color(0xFF607D8B),
      secondaryColor: Color(0xFFCFD8DC),
      description: 'Teselado de Penrose, geometría empresarial compleja',
      complexity: ComplexityLevel.high,
      animationSpeed: AnimationSpeed.slow,
    ),
    'kympulse': const ModuleVisualConfig(
      primaryColor: Color(0xFF00BCD4),
      secondaryColor: Color(0xFFB2EBF2),
      description:
          'Fibonacci de datos en tiempo real y crecimiento exponencial',
      complexity: ComplexityLevel.high,
      animationSpeed: AnimationSpeed.fast,
    ),
    'ventas': const ModuleVisualConfig(
      primaryColor: Color(0xFF4CAF50),
      secondaryColor: Color(0xFFC8E6C9),
      description: 'Espirales de oportunidades comerciales y energía de ventas',
      complexity: ComplexityLevel.medium,
      animationSpeed: AnimationSpeed.fast,
    ),
    'admin': const ModuleVisualConfig(
      primaryColor: Color(0xFF795548),
      secondaryColor: Color(0xFFD7CCC8),
      description: 'Estructura molecular de administración y control',
      complexity: ComplexityLevel.low,
      animationSpeed: AnimationSpeed.slow,
    ),
    'reportes': const ModuleVisualConfig(
      primaryColor: Color(0xFF3F51B5),
      secondaryColor: Color(0xFFC5CAE9),
      description: 'Cristales de datos estructurados y análisis ordenado',
      complexity: ComplexityLevel.medium,
      animationSpeed: AnimationSpeed.normal,
    ),
  };

  /// 🔍 OBTENER PATRÓN PARA MÓDULO
  static MandalaPattern getPatternForModule(String moduleName) {
    final pattern = _modulePatterns[moduleName.toLowerCase()];

    if (pattern == null) {
      debugPrint(
          '⚠️ Patrón no encontrado para módulo: $moduleName, usando Fibonacci por defecto');
      return MandalaPattern.fibonacci;
    }

    return pattern;
  }

  /// 🎨 OBTENER CONFIGURACIÓN VISUAL PARA MÓDULO
  static ModuleVisualConfig getConfigForModule(String moduleName) {
    return _moduleConfigs[moduleName.toLowerCase()] ??
        const ModuleVisualConfig.defaultConfig();
  }

  /// 📋 OBTENER TODOS LOS MÓDULOS DISPONIBLES
  static List<String> getAllModules() {
    return _modulePatterns.keys.toList();
  }

  /// 🔢 OBTENER ESTADÍSTICAS DE PATRONES
  static Map<MandalaPattern, int> getPatternUsageStats() {
    final stats = <MandalaPattern, int>{};

    for (final pattern in _modulePatterns.values) {
      stats[pattern] = (stats[pattern] ?? 0) + 1;
    }

    return stats;
  }

  /// 🎯 VERIFICAR SI MÓDULO EXISTE
  static bool hasModule(String moduleName) {
    return _modulePatterns.containsKey(moduleName.toLowerCase());
  }

  /// 🌀 OBTENER MÓDULOS POR PATRÓN
  static List<String> getModulesByPattern(MandalaPattern pattern) {
    return _modulePatterns.entries
        .where((entry) => entry.value == pattern)
        .map((entry) => entry.key)
        .toList();
  }

  /// 📊 OBTENER INFORMACIÓN COMPLETA DEL MÓDULO
  static ModuleInfo getModuleInfo(String moduleName) {
    final cleanName = moduleName.toLowerCase();
    final pattern = getPatternForModule(cleanName);
    final config = getConfigForModule(cleanName);

    return ModuleInfo(
      name: moduleName,
      pattern: pattern,
      config: config,
      icon: _getDefaultIconForModule(cleanName),
      displayName: _getDisplayNameForModule(cleanName),
    );
  }

  /// 🎨 CREAR PAINTER PARA MÓDULO
  static CustomPainter createPainterForModule(
    String moduleName,
    double animationValue, {
    Color? customColor,
    double? customStrokeWidth,
  }) {
    final pattern = getPatternForModule(moduleName);
    final config = getConfigForModule(moduleName);
    final color = customColor ?? config.primaryColor;
    final strokeWidth = customStrokeWidth ?? _getStrokeWidthForPattern(pattern);

    switch (pattern) {
      case MandalaPattern.fibonacci:
        return FibonacciPainter(
          animationValue: animationValue,
          color: color,
          strokeWidth: strokeWidth,
        );
      case MandalaPattern.flowerOfLife:
        return FlowerOfLifePainter(
          animationValue: animationValue,
          color: color,
          strokeWidth: strokeWidth,
        );
      case MandalaPattern.molecular:
        return MolecularPainter(
          animationValue: animationValue,
          color: color,
          strokeWidth: strokeWidth,
        );
      case MandalaPattern.vortex:
        return VortexPainter(
          animationValue: animationValue,
          color: color,
          strokeWidth: strokeWidth,
        );
      case MandalaPattern.crystalline:
        return CrystallinePainter(
          animationValue: animationValue,
          color: color,
          strokeWidth: strokeWidth,
        );
      case MandalaPattern.penrose:
        return PenrosePainter(
          animationValue: animationValue,
          color: color,
          strokeWidth: strokeWidth,
        );
    }
  }

  // ========================================
  // 🔧 MÉTODOS HELPER PRIVADOS
  // ========================================

  static IconData _getDefaultIconForModule(String moduleName) {
    const iconMap = {
      'agenda': Icons.calendar_view_week,
      'clientes': Icons.people_outline,
      'profesionales': Icons.medical_services_outlined,
      'servicios': Icons.spa_outlined,
      'recordatorios': Icons.notifications_outlined,
      'corporativo': Icons.business_outlined,
      'empresas': Icons.business_outlined,
      'contratos': Icons.description_outlined,
      'kympulse': Icons.show_chart_outlined,
      'eventos': Icons.event_outlined,
      'ventas': Icons.trending_up_outlined,
      'campanas': Icons.campaign_outlined,
      'admin': Icons.admin_panel_settings_outlined,
      'reportes': Icons.assessment_outlined,
    };

    return iconMap[moduleName] ?? Icons.dashboard_outlined;
  }

  static String _getDisplayNameForModule(String moduleName) {
    const displayNames = {
      'agenda': 'Agenda',
      'clientes': 'Clientes',
      'profesionales': 'Profesionales',
      'servicios': 'Servicios',
      'recordatorios': 'Recordatorios',
      'corporativo': 'Corporativo',
      'empresas': 'Empresas',
      'contratos': 'Contratos',
      'kympulse': 'KYM Pulse',
      'eventos': 'Eventos',
      'ventas': 'Ventas',
      'campanas': 'Campañas',
      'admin': 'Administración',
      'reportes': 'Reportes',
    };

    return displayNames[moduleName] ?? moduleName.toUpperCase();
  }

  static double _getStrokeWidthForPattern(MandalaPattern pattern) {
    switch (pattern) {
      case MandalaPattern.fibonacci:
        return 1.5;
      case MandalaPattern.flowerOfLife:
        return 1.0;
      case MandalaPattern.molecular:
        return 1.2;
      case MandalaPattern.vortex:
        return 1.0;
      case MandalaPattern.crystalline:
        return 1.1;
      case MandalaPattern.penrose:
        return 1.0;
    }
  }
}

/// 🎨 CONFIGURACIÓN VISUAL DEL MÓDULO
class ModuleVisualConfig {
  final Color primaryColor;
  final Color secondaryColor;
  final String description;
  final ComplexityLevel complexity;
  final AnimationSpeed animationSpeed;

  const ModuleVisualConfig({
    required this.primaryColor,
    required this.secondaryColor,
    required this.description,
    required this.complexity,
    required this.animationSpeed,
  });

  const ModuleVisualConfig.defaultConfig()
      : primaryColor = Colors.white,
        secondaryColor = Colors.white70,
        description = 'Patrón mandala por defecto',
        complexity = ComplexityLevel.medium,
        animationSpeed = AnimationSpeed.normal;

  LinearGradient get gradient => LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  Duration get animationDuration {
    switch (animationSpeed) {
      case AnimationSpeed.slow:
        return const Duration(seconds: 15);
      case AnimationSpeed.normal:
        return const Duration(seconds: 10);
      case AnimationSpeed.fast:
        return const Duration(seconds: 6);
    }
  }
}

/// 📊 INFORMACIÓN COMPLETA DEL MÓDULO
class ModuleInfo {
  final String name;
  final MandalaPattern pattern;
  final ModuleVisualConfig config;
  final IconData icon;
  final String displayName;

  const ModuleInfo({
    required this.name,
    required this.pattern,
    required this.config,
    required this.icon,
    required this.displayName,
  });

  String get patternName {
    switch (pattern) {
      case MandalaPattern.fibonacci:
        return 'Fibonacci';
      case MandalaPattern.flowerOfLife:
        return 'Flower of Life';
      case MandalaPattern.molecular:
        return 'Molecular';
      case MandalaPattern.vortex:
        return 'Vortex';
      case MandalaPattern.crystalline:
        return 'Crystalline';
      case MandalaPattern.penrose:
        return 'Penrose';
    }
  }

  String get complexityName {
    switch (config.complexity) {
      case ComplexityLevel.low:
        return 'Baja';
      case ComplexityLevel.medium:
        return 'Media';
      case ComplexityLevel.high:
        return 'Alta';
    }
  }
}

/// 🧪 WIDGET DE TESTING Y PREVIEW
class MandalaSystemPreview extends StatelessWidget {
  const MandalaSystemPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌀 Sistema Mandala CRM'),
        backgroundColor: const Color(0xFF9920A7),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCard(),
            const SizedBox(height: 20),
            _buildModulesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final stats = ModuleMandalaMapping.getPatternUsageStats();
    final totalModules = ModuleMandalaMapping.getAllModules().length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Estadísticas del Sistema',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Total de módulos: $totalModules'),
            Text('Patrones únicos: ${stats.length}'),
            const SizedBox(height: 8),
            ...stats.entries.map((entry) => Text(
                  '${entry.key.name}: ${entry.value} módulos',
                  style: const TextStyle(fontSize: 12),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesGrid() {
    final modules = ModuleMandalaMapping.getAllModules();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final moduleName = modules[index];
        final moduleInfo = ModuleMandalaMapping.getModuleInfo(moduleName);

        return _MandalaModuleCard(moduleInfo: moduleInfo);
      },
    );
  }
}

class _MandalaModuleCard extends StatefulWidget {
  final ModuleInfo moduleInfo;

  const _MandalaModuleCard({required this.moduleInfo});

  @override
  State<_MandalaModuleCard> createState() => _MandalaModuleCardState();
}

class _MandalaModuleCardState extends State<_MandalaModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.moduleInfo.config.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: widget.moduleInfo.config.gradient,
        ),
        child: Stack(
          children: [
            // Mandala de fondo
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ModuleMandalaMapping.createPainterForModule(
                      widget.moduleInfo.name,
                      _animation.value,
                      customColor: Colors.white.withOpacity(0.3),
                    ),
                  );
                },
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.moduleInfo.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.moduleInfo.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.moduleInfo.patternName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complejidad: ${widget.moduleInfo.complexityName}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.moduleInfo.config.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
