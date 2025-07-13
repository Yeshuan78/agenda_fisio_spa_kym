// [service_mode_toggle.dart] - TOGGLE SERVICEMODE CON FIX OVERFLOW - ✅ HEIGHT INCREASED +10px
// 📁 Ubicación: /lib/widgets/clients/wizard/components/service_mode_toggle.dart
// 🎯 OBJETIVO: Fix overflow + altura optimizada + espaciado quirúrgico

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/company/company_settings_model.dart';

/// 🎛️ SERVICE MODE TOGGLE - ✅ FIX OVERFLOW: 65px → 75px (+10px)
class ServiceModeToggle extends StatefulWidget {
  final ClientServiceMode currentMode;
  final Function(ClientServiceMode) onModeChanged;
  final bool enabled;
  final String? description;

  const ServiceModeToggle({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    this.enabled = true,
    this.description,
  });

  @override
  State<ServiceModeToggle> createState() => _ServiceModeToggleState();
}

class _ServiceModeToggleState extends State<ServiceModeToggle> {
  late ClientServiceMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.currentMode;
    debugPrint(
        '🎛️ ServiceModeToggle inicializado con: ${_selectedMode.label}');
  }

  @override
  void didUpdateWidget(ServiceModeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ FIX CRÍTICO: Actualizar cuando cambie currentMode desde parent
    if (oldWidget.currentMode != widget.currentMode) {
      debugPrint(
          '🔄 ServiceModeToggle: Modo cambiado de ${oldWidget.currentMode.label} a ${widget.currentMode.label}');
      setState(() {
        _selectedMode = widget.currentMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildHorizontalModeButtons(),
        if (widget.description != null) ...[
          const SizedBox(height: 8),
          _buildDescription(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.settings_suggest,
          color: kBrandPurple,
          size: 16,
        ),
        const SizedBox(width: 8),
        const Text(
          'Tipo de Servicio',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kBrandPurple,
          ),
        ),
      ],
    );
  }

  /// ✅ TOGGLE BUTTONS HORIZONTALES CON GLASSMORPHISM - HEIGHT FIXED
  Widget _buildHorizontalModeButtons() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // ✅ GLASSMORPHISM IGUAL AL CARD PRINCIPAL
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.93),
            Colors.white.withValues(alpha: 0.83),
            kAccentBlue.withValues(alpha: 0.04),
            kAccentBlue.withValues(alpha: 0.03),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kAccentBlue.withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: kAccentBlue.withValues(alpha: 0.15),
            blurRadius: 25,
            spreadRadius: 3,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.75),
            blurRadius: 16,
            spreadRadius: -6,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ BOTÓN 1: SUCURSAL
          Expanded(
            child: _buildModeButton(
              mode: ClientServiceMode.sucursal,
              emoji: '🏢',
              title: 'Sucursal',
              subtitle: 'Cliente acude al spa',
            ),
          ),

          const SizedBox(width: 6),

          // ✅ BOTÓN 2: DOMICILIO
          Expanded(
            child: _buildModeButton(
              mode: ClientServiceMode.domicilio,
              emoji: '🏠',
              title: 'Domicilio',
              subtitle: 'Servicio en casa del cliente',
            ),
          ),

          const SizedBox(width: 6),

          // ✅ BOTÓN 3: AMBOS
          Expanded(
            child: _buildModeButton(
              mode: ClientServiceMode.ambos,
              emoji: '🔄',
              title: 'Ambos',
              subtitle: 'Sucursal y domicilio',
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ FIX CRÍTICO: ALTURA AUMENTADA 65px → 75px + ESPACIADO OPTIMIZADO
  Widget _buildModeButton({
    required ClientServiceMode mode,
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedMode == mode;

    return GestureDetector(
      onTap: widget.enabled ? () => _handleModeChange(mode) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 75, // ✅ FIX: 65px → 75px (+10px para evitar overflow)
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 10), // ✅ AJUSTADO: vertical 8 → 10
        decoration: BoxDecoration(
          color: isSelected
              ? mode.color.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? mode.color.withValues(alpha: 0.4)
                : kBorderSoft.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: mode.color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ EMOJI + INDICADOR DE SELECCIÓN
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emoji,
                  style: TextStyle(
                    fontSize: isSelected ? 16 : 14,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.check_circle,
                    size: 12,
                    color: mode.color,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 3), // ✅ AJUSTADO: 4 → 3

            // ✅ TÍTULO
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? mode.color : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 2), // ✅ MANTENIDO: 2px está bien

            // ✅ SUBTÍTULO COMPACTO CON MEJOR CONSTRAINT
            Flexible(
              // ✅ NUEVO: Usar Flexible en lugar de Text directo
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 8,
                  color: isSelected
                      ? mode.color.withValues(alpha: 0.8)
                      : kTextSecondary,
                  height: 1.1,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kBrandPurple.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: kBrandPurple.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: kBrandPurple.withValues(alpha: 0.7),
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.description!,
              style: TextStyle(
                fontSize: 11,
                color: kBrandPurple.withValues(alpha: 0.8),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ FIX CRÍTICO: MANEJAR CAMBIO DE MODO CON LOGS
  void _handleModeChange(ClientServiceMode newMode) {
    if (newMode == _selectedMode || !widget.enabled) return;

    debugPrint('🎛️ ServiceModeToggle: Usuario seleccionó ${newMode.label}');
    debugPrint('   - Modo anterior: ${_selectedMode.label}');

    HapticFeedback.lightImpact();

    setState(() {
      _selectedMode = newMode;
    });

    // ✅ NOTIFICAR AL PARENT INMEDIATAMENTE
    widget.onModeChanged(newMode);

    debugPrint('✅ ServiceModeToggle: Cambio notificado al parent');
  }
}

/// ✅ EXTENSIÓN PARA COLORES POR MODO
extension ClientServiceModeColors on ClientServiceMode {
  Color get color {
    switch (this) {
      case ClientServiceMode.sucursal:
        return kAccentBlue;
      case ClientServiceMode.domicilio:
        return kAccentGreen;
      case ClientServiceMode.ambos:
        return kBrandPurple;
    }
  }
}

/// 🎨 VARIANTE ULTRA COMPACTA - RADIO BUTTONS HORIZONTALES (ALTERNATIVA)
class CompactServiceModeToggle extends StatelessWidget {
  final ClientServiceMode currentMode;
  final Function(ClientServiceMode) onModeChanged;
  final bool enabled;

  const CompactServiceModeToggle({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorderSoft, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRadioOption(
              mode: ClientServiceMode.sucursal,
              title: '🏢 Sucursal',
            ),
          ),
          Expanded(
            child: _buildRadioOption(
              mode: ClientServiceMode.domicilio,
              title: '🏠 Domicilio',
            ),
          ),
          Expanded(
            child: _buildRadioOption(
              mode: ClientServiceMode.ambos,
              title: '🔄 Ambos',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required ClientServiceMode mode,
    required String title,
  }) {
    final isSelected = currentMode == mode;

    return GestureDetector(
      onTap: enabled ? () => _handleChange(mode) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<ClientServiceMode>(
            value: mode,
            groupValue: currentMode,
            onChanged: enabled ? (value) => _handleChange(value!) : null,
            activeColor: kBrandPurple,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? kBrandPurple : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleChange(ClientServiceMode newMode) {
    if (newMode == currentMode || !enabled) return;
    HapticFeedback.lightImpact();
    onModeChanged(newMode);
  }
}
