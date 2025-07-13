// [view_mode_toggle.dart] - FIX ESTADO Y REFRESH - ✅ SIN INTERFERENCIA
// 📁 Ubicación: /lib/widgets/clients/view_mode_toggle.dart
// 🎯 OBJETIVO: Toggle que no interfiera con refresh + estado limpio

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/enums/view_mode.dart';

/// 🎛️ TOGGLE PRO PARA SELECCIÓN DE MODO DE VISTA - ✅ FIX REFRESH
class ViewModeToggle extends StatefulWidget {
  final ViewMode currentMode;
  final Function(ViewMode) onModeChanged;
  final bool showLabels;
  final bool isCompact;

  const ViewModeToggle({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    this.showLabels = true,
    this.isCompact = false,
  });

  @override
  State<ViewModeToggle> createState() => _ViewModeToggleState();
}

class _ViewModeToggleState extends State<ViewModeToggle>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  ViewMode? _hoveredMode;

  // ✅ FIX: NO CACHEAR ESTADO - SIEMPRE USAR WIDGET.CURRENTMODE
  ViewMode get _currentMode => widget.currentMode;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );

    // Inicializar posición del slider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSliderPosition();
    });
  }

  @override
  void didUpdateWidget(ViewModeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ FIX: SIEMPRE ACTUALIZAR SI CAMBIA EL MODO DESDE PARENT
    if (oldWidget.currentMode != widget.currentMode) {
      debugPrint(
          '🎛️ ViewModeToggle: Modo actualizado desde parent ${oldWidget.currentMode.name} → ${widget.currentMode.name}');
      _updateSliderPosition();

      // ✅ FIX: FORZAR REBUILD SIN INTERFERIR CON REFRESH
      if (mounted) {
        setState(() {
          // Rebuild para reflejar cambio
        });
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _updateSliderPosition() {
    final targetPosition =
        ViewMode.values.indexOf(_currentMode) / (ViewMode.values.length - 1);
    _slideController.animateTo(targetPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56, // ✅ ALTURA FIJA IGUAL AL SEARCH BAR
      decoration: _buildToggleDecoration(),
      child: widget.isCompact ? _buildCompactToggle() : _buildFullToggle(),
    );
  }

  BoxDecoration _buildToggleDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.9),
          Colors.white.withValues(alpha: 0.7),
          kAccentGreen.withValues(alpha: 0.03),
        ],
        stops: const [0.0, 0.7, 1.0],
      ),
      borderRadius: BorderRadius.circular(20), // ✅ MISMO RADIO QUE SEARCH BAR
      border: Border.all(
        color: kAccentGreen.withValues(alpha: 0.15),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: kAccentGreen.withValues(alpha: 0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.8),
          blurRadius: 8,
          spreadRadius: -2,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }

  Widget _buildFullToggle() {
    return Container(
      padding: const EdgeInsets.all(4), // ✅ PADDING INTERNO
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            ViewMode.values.map((mode) => _buildModeButton(mode)).toList(),
      ),
    );
  }

  Widget _buildCompactToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ViewMode.values
            .map((mode) => _buildCompactModeButton(mode))
            .toList(),
      ),
    );
  }

  // ✅ FIX: BOTÓN QUE NO INTERFIERE CON REFRESH
  Widget _buildModeButton(ViewMode mode) {
    final isActive = _currentMode == mode;
    final isHovered = _hoveredMode == mode;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredMode = mode),
      onExit: (_) => setState(() => _hoveredMode = null),
      child: GestureDetector(
        onTap: () => _handleModeChange(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 72, // ✅ ANCHO AJUSTADO
          height: 48, // ✅ ALTURA AJUSTADA PARA SIMETRÍA
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            // ✅ NUEVO EFECTO PRO: Fondo sólido para activo
            color: isActive
                ? kAccentGreen
                : isHovered
                    ? kAccentGreen.withValues(alpha: 0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(16), // ✅ BORDES REDONDEADOS PRO
            border: isActive
                ? null
                : Border.all(
                    color:
                        kAccentGreen.withValues(alpha: isHovered ? 0.3 : 0.1),
                    width: 1,
                  ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: kAccentGreen.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isHovered ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  mode.icon,
                  size: 18, // ✅ TAMAÑO AJUSTADO
                  color: isActive
                      ? Colors.white
                      : kAccentGreen, // ✅ BLANCO PARA ACTIVO
                ),
              ),
              if (widget.showLabels) ...[
                const SizedBox(height: 4),
                Text(
                  mode.displayName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? Colors.white
                        : kAccentGreen, // ✅ BLANCO PARA ACTIVO
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ✅ FIX: VERSIÓN COMPACTA SIN INTERFERENCIA
  Widget _buildCompactModeButton(ViewMode mode) {
    final isActive = _currentMode == mode;

    return GestureDetector(
      onTap: () => _handleModeChange(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(12), // ✅ PADDING AJUSTADO
        decoration: BoxDecoration(
          color: isActive ? kAccentGreen : kAccentGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: kAccentGreen.withValues(alpha: isActive ? 1.0 : 0.3),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: kAccentGreen.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          mode.icon,
          size: 16,
          color: isActive ? Colors.white : kAccentGreen, // ✅ BLANCO PARA ACTIVO
        ),
      ),
    );
  }

  /// ✅ FIX CRÍTICO: HANDLE CHANGE SIN INTERFERIR CON REFRESH
  void _handleModeChange(ViewMode newMode) {
    if (newMode == _currentMode) return;

    debugPrint(
        '🎛️ ViewModeToggle: Cambiando modo ${_currentMode.name} → ${newMode.name}');

    // Feedback háptico diferenciado por modo
    switch (newMode) {
      case ViewMode.compact:
        HapticFeedback.lightImpact();
        break;
      case ViewMode.comfortable:
        HapticFeedback.mediumImpact();
        break;
      case ViewMode.table:
        HapticFeedback.heavyImpact();
        break;
    }

    // Animación de pulso sutil
    _pulseController.forward().then((_) => _pulseController.reverse());

    // ✅ FIX: CALLBACK AL PARENT SIN DELAY NI INTERFERENCIA
    try {
      widget.onModeChanged(newMode);
      debugPrint('✅ ViewModeToggle: Callback ejecutado exitosamente');
    } catch (e) {
      debugPrint('❌ ViewModeToggle: Error en callback: $e');
    }

    debugPrint(
        '🎛️ ViewModeToggle: Cambio completado a ${newMode.displayName}');
  }
}
