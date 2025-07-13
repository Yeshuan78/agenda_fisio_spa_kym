// [mandala_sliver_bar.dart] - WIDGET REUTILIZABLE DE MANDALA
// 📁 Ubicación: /lib/widgets/mandala/mandala_sliver_bar.dart
// 🎯 OBJETIVO: Widget especializado y reutilizable para SliverAppBar con mandala

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/mandala/mandala_painters.dart';
import 'package:agenda_fisio_spa_kym/widgets/mandala/mandala_performance.dart';
import 'package:agenda_fisio_spa_kym/config/module_mandala_mapping.dart'
    as mapping;

/// 🌀 WIDGET ESPECIALIZADO PARA SLIVER APP BAR CON MANDALA
/// Proporciona máximo control y customización para cada módulo
class MandalaeSliverBar extends StatefulWidget {
  final String moduleName;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;
  final List<Widget>? actions;
  final double expandedHeight;
  final bool pinned;
  final bool floating;
  final Color? backgroundColor;
  final VoidCallback? onIconTap;
  final bool enableAnimation;
  final MandalaConfig? customConfig;

  const MandalaeSliverBar({
    super.key,
    required this.moduleName,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    this.actions,
    this.expandedHeight = 220,
    this.pinned = true,
    this.floating = false,
    this.backgroundColor,
    this.onIconTap,
    this.enableAnimation = true,
    this.customConfig,
  });

  @override
  State<MandalaeSliverBar> createState() => _MandalaeSliverBarState();
}

class _MandalaeSliverBarState extends State<MandalaeSliverBar>
    with TickerProviderStateMixin {
  late AnimationController _mandalaController;
  late AnimationController _iconController;
  late Animation<double> _mandalaAnimation;
  late Animation<double> _iconAnimation;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    if (widget.enableAnimation) {
      _startAnimations();
    }
  }

  void _initializeAnimations() {
    // Controlador principal del mandala
    _mandalaController = AnimationController(
      duration: MandalaPerformance.getOptimalDuration(),
      vsync: this,
    );

    // Controlador del ícono
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Animación del mandala
    _mandalaAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mandalaController,
      curve: Curves.easeInOut,
    ));

    // Animación del ícono (escala)
    _iconAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));

    // Rotación sutil del ícono
    _iconRotation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    // Iniciar animación del ícono primero
    _iconController.forward();

    // Luego el mandala con delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _startMandalaLoop();
      }
    });
  }

  void _startMandalaLoop() async {
    if (!widget.enableAnimation || !mounted) return;

    while (mounted) {
      try {
        // Fase activa
        await _mandalaController.forward();
        if (!mounted) break;

        // Pausa inteligente
        await Future.delayed(MandalaPerformance.getIntelligentPause());
        if (!mounted) break;

        // Fase reversa
        await _mandalaController.reverse();
        if (!mounted) break;

        // Pausa corta
        await Future.delayed(MandalaPerformance.getShortPause());
      } catch (e) {
        // Si hay error (widget disposed), salir del ciclo
        debugPrint('🔄 Mandala animation stopped safely');
        break;
      }
    }
  }

  @override
  void dispose() {
    // ⚡ DISPOSE SEGURO PARA EVITAR ERRORES
    if (_mandalaController.isAnimating) {
      _mandalaController.stop();
    }
    if (_iconController.isAnimating) {
      _iconController.stop();
    }

    _mandalaController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: widget.expandedHeight,
      floating: widget.floating,
      pinned: widget.pinned,
      backgroundColor: widget.backgroundColor ?? Colors.transparent,
      actions: widget.actions,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildMandalaBackground(),
      ),
    );
  }

  Widget _buildMandalaBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.customConfig?.gradient ?? kMandalaGradient,
      ),
      child: Stack(
        children: [
          // Mandala de fondo
          if (widget.enableAnimation)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _mandalaAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _createMandalaePainter(_mandalaAnimation.value),
                  );
                },
              ),
            ),

          // Contenido principal
          Container(
            padding:
                EdgeInsets.fromLTRB(24, widget.expandedHeight * 0.4, 24, 24),
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            _buildAnimatedIcon(),
            const SizedBox(width: 20),
            _buildTitleSection(),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([_iconAnimation, _iconRotation]),
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onIconTap ?? () => _performIconTap(),
          child: Transform.scale(
            scale: _iconAnimation.value,
            child: Transform.rotate(
              angle: _iconRotation.value,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    // Glassmorphism inner shadow
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: -4,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedTitle(),
          const SizedBox(height: 8),
          _buildAnimatedSubtitle(),
        ],
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: kFontFamily,
                letterSpacing: -1.0,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSubtitle() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontFamily: kFontFamily,
                fontWeight: FontWeight.w400,
                shadows: [
                  Shadow(
                    color: Colors.black12,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  CustomPainter _createMandalaePainter(double animationValue) {
    final config = widget.customConfig ??
        MandalaConfig.defaultForModule(widget.moduleName);

    switch (config.pattern) {
      case mapping.MandalaPattern.fibonacci:
        return FibonacciPainter(
          animationValue: animationValue,
          color: config.color,
          strokeWidth: config.strokeWidth,
        );
      case mapping.MandalaPattern.flowerOfLife:
        return FlowerOfLifePainter(
          animationValue: animationValue,
          color: config.color,
          strokeWidth: config.strokeWidth,
        );
      case mapping.MandalaPattern.molecular:
        return MolecularPainter(
          animationValue: animationValue,
          color: config.color,
          strokeWidth: config.strokeWidth,
        );
      case mapping.MandalaPattern.vortex:
        return VortexPainter(
          animationValue: animationValue,
          color: config.color,
          strokeWidth: config.strokeWidth,
        );
      case mapping.MandalaPattern.crystalline:
        return CrystallinePainter(
          animationValue: animationValue,
          color: config.color,
          strokeWidth: config.strokeWidth,
        );
      case mapping.MandalaPattern.penrose:
        return PenrosePainter(
          animationValue: animationValue,
          color: config.color,
          strokeWidth: config.strokeWidth,
        );
    }
  }

  void _performIconTap() {
    // Animación de feedback del ícono
    _iconController.reverse().then((_) {
      if (mounted) {
        _iconController.forward();
      }
    });

    // Feedback háptico (si está disponible)
    // HapticFeedback.lightImpact();
  }
}

/// 🎨 CONFIGURACIÓN PERSONALIZADA DEL MANDALA
class MandalaConfig {
  final mapping.MandalaPattern pattern;
  final Color color;
  final double strokeWidth;
  final LinearGradient? gradient;
  final Duration? animationDuration;

  const MandalaConfig({
    required this.pattern,
    this.color = Colors.white,
    this.strokeWidth = 1.0,
    this.gradient,
    this.animationDuration,
  });

  /// Factory para configuración por defecto según módulo
  factory MandalaConfig.defaultForModule(String moduleName) {
    final pattern = _getPatternForModule(moduleName);

    return MandalaConfig(
      pattern: pattern,
      color: Colors.white,
      strokeWidth: _getStrokeWidthForPattern(pattern),
      gradient: kMandalaGradient,
    );
  }

  /// Factory para configuración personalizada
  factory MandalaConfig.custom({
    required mapping.MandalaPattern pattern,
    Color color = Colors.white,
    double strokeWidth = 1.0,
    LinearGradient? gradient,
    Duration? animationDuration,
  }) {
    return MandalaConfig(
      pattern: pattern,
      color: color,
      strokeWidth: strokeWidth,
      gradient: gradient,
      animationDuration: animationDuration,
    );
  }

  static mapping.MandalaPattern _getPatternForModule(String moduleName) {
    const modulePatterns = {
      'agenda': mapping.MandalaPattern.fibonacci,
      'clientes': mapping.MandalaPattern.flowerOfLife,
      'profesionales': mapping.MandalaPattern.molecular,
      'servicios': mapping.MandalaPattern.vortex,
      'recordatorios': mapping.MandalaPattern.crystalline,
      'corporativo': mapping.MandalaPattern.penrose,
      'kympulse': mapping.MandalaPattern.fibonacci,
      'ventas': mapping.MandalaPattern.vortex,
      'admin': mapping.MandalaPattern.molecular,
      'reportes': mapping.MandalaPattern.crystalline,
    };

    return modulePatterns[moduleName.toLowerCase()] ??
        mapping.MandalaPattern.fibonacci;
  }

  static double _getStrokeWidthForPattern(mapping.MandalaPattern pattern) {
    switch (pattern) {
      case mapping.MandalaPattern.fibonacci:
        return 1.5;
      case mapping.MandalaPattern.flowerOfLife:
        return 1.0;
      case mapping.MandalaPattern.molecular:
        return 1.2;
      case mapping.MandalaPattern.vortex:
        return 1.0;
      case mapping.MandalaPattern.crystalline:
        return 1.1;
      case mapping.MandalaPattern.penrose:
        return 1.0;
    }
  }
}

/// 🎯 WIDGET FACTORY PARA CASOS COMUNES
class MandalaQuickFactory {
  /// 📅 Agenda
  static Widget agenda({
    String title = 'Agenda',
    String subtitle = 'Sistema inteligente de gestión de citas',
    Widget? trailing,
    List<Widget>? actions,
  }) {
    return MandalaeSliverBar(
      moduleName: 'agenda',
      title: title,
      subtitle: subtitle,
      icon: Icons.calendar_view_week,
      trailing: trailing,
      actions: actions,
    );
  }

  /// 👥 Clientes
  static Widget clientes({
    String title = 'Clientes',
    String subtitle = 'Red de conexiones y relaciones',
    Widget? trailing,
    List<Widget>? actions,
  }) {
    return MandalaeSliverBar(
      moduleName: 'clientes',
      title: title,
      subtitle: subtitle,
      icon: Icons.people_outline,
      trailing: trailing,
      actions: actions,
    );
  }

  /// 👨‍⚕️ Profesionales
  static Widget profesionales({
    String title = 'Profesionales',
    String subtitle = 'Equipo especializado y certificado',
    Widget? trailing,
    List<Widget>? actions,
  }) {
    return MandalaeSliverBar(
      moduleName: 'profesionales',
      title: title,
      subtitle: subtitle,
      icon: Icons.medical_services_outlined,
      trailing: trailing,
      actions: actions,
    );
  }

  /// 🛍️ Servicios
  static Widget servicios({
    String title = 'Servicios',
    String subtitle = 'Catálogo completo de tratamientos',
    Widget? trailing,
    List<Widget>? actions,
  }) {
    return MandalaeSliverBar(
      moduleName: 'servicios',
      title: title,
      subtitle: subtitle,
      icon: Icons.spa_outlined,
      trailing: trailing,
      actions: actions,
    );
  }

  /// 🔔 Recordatorios
  static Widget recordatorios({
    String title = 'Recordatorios',
    String subtitle = 'Sistema automatizado de notificaciones',
    Widget? trailing,
    List<Widget>? actions,
  }) {
    return MandalaeSliverBar(
      moduleName: 'recordatorios',
      title: title,
      subtitle: subtitle,
      icon: Icons.notifications_outlined,
      trailing: trailing,
      actions: actions,
    );
  }

  /// 🏢 Corporativo
  static Widget corporativo({
    String title = 'Corporativo',
    String subtitle = 'Gestión empresarial y contratos B2B',
    Widget? trailing,
    List<Widget>? actions,
  }) {
    return MandalaeSliverBar(
      moduleName: 'corporativo',
      title: title,
      subtitle: subtitle,
      icon: Icons.business_outlined,
      trailing: trailing,
      actions: actions,
    );
  }

  /// 📊 KYM Pulse
  static Widget kymPulse({
    String title = 'KYM Pulse',
    String subtitle = 'Analytics avanzados y métricas en tiempo real',
    Widget? trailing,
    List<Widget>? actions,
  }) {
    return MandalaeSliverBar(
      moduleName: 'kympulse',
      title: title,
      subtitle: subtitle,
      icon: Icons.show_chart_outlined,
      trailing: trailing,
      actions: actions,
    );
  }

  /// 💰 Ventas
  static Widget ventas({
    String title = 'Ventas',
    String subtitle = 'Pipeline y oportunidades comerciales',
    Widget? trailing,
    List<Widget>? actions,
  }) {
    return MandalaeSliverBar(
      moduleName: 'ventas',
      title: title,
      subtitle: subtitle,
      icon: Icons.trending_up_outlined,
      trailing: trailing,
      actions: actions,
    );
  }

  /// ⚙️ Admin
  static Widget admin({
    String title = 'Administración',
    String subtitle = 'Herramientas de control y configuración',
    Widget? trailing,
    List<Widget>? actions,
  }) {
    return MandalaeSliverBar(
      moduleName: 'admin',
      title: title,
      subtitle: subtitle,
      icon: Icons.admin_panel_settings_outlined,
      trailing: trailing,
      actions: actions,
    );
  }

  /// 📈 Reportes
  static Widget reportes({
    String title = 'Reportes',
    String subtitle = 'Análisis de datos y exportación',
    Widget? trailing,
    List<Widget>? actions,
  }) {
    return MandalaeSliverBar(
      moduleName: 'reportes',
      title: title,
      subtitle: subtitle,
      icon: Icons.assessment_outlined,
      trailing: trailing,
      actions: actions,
    );
  }
}
