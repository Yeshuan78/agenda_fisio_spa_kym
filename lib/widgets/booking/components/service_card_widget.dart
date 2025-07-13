// [service_card_widget.dart] - ✨ PREMIUM RESPONSIVE FIX + SOMBRAS PROFUNDAS
// 📁 Ubicación: /lib/widgets/booking/components/service_card_widget.dart
// 🎯 OBJETIVO: Card elegante, responsive, centrado, CON SOMBRAS PROFUNDAS PREMIUM

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class ServiceCardWidget extends StatelessWidget {
  final Map<String, dynamic> service;
  final bool isSelected;
  final Color accentColor;
  final bool showPricing;
  final VoidCallback onTap;

  const ServiceCardWidget({
    super.key,
    required this.service,
    required this.isSelected,
    required this.accentColor,
    required this.showPricing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: _getCardSpacing(context)),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(_getCardPadding(context)),
          decoration: _buildCardDecoration(context),
          child: _buildCardContent(context),
        ),
      ),
    );
  }

  /// 🎨 DECORACIÓN PREMIUM CON GLASSMORPHISM + SOMBRAS PROFUNDAS
  BoxDecoration _buildCardDecoration(BuildContext context) {
    return BoxDecoration(
      // ✅ GRADIENTE SUTIL DE FONDO
      gradient: isSelected
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withValues(alpha: 0.08),
                accentColor.withValues(alpha: 0.12),
                Colors.white,
              ],
              stops: const [0.0, 0.3, 1.0],
            )
          : const LinearGradient(
              colors: [Colors.white, Colors.white],
            ),
      borderRadius: BorderRadius.circular(_getBorderRadius(context)),
      border: Border.all(
        color: isSelected
            ? accentColor.withValues(alpha: 0.4)
            : kBorderSoft.withValues(alpha: 0.3),
        width: isSelected ? 2 : 1,
      ),
      boxShadow: _buildDeepCardShadows(context), // ✅ NUEVO: SOMBRAS PROFUNDAS
    );
  }

  /// 🌟 SOMBRAS PROFUNDAS PREMIUM - ✅ NUEVA IMPLEMENTACIÓN
  List<BoxShadow> _buildDeepCardShadows(BuildContext context) {
    if (isSelected) {
      return [
        // ✅ SOMBRA PRINCIPAL MÁS PROFUNDA - ACCENT COLOR
        BoxShadow(
          color: accentColor.withValues(alpha: 0.25), // ✅ MÁS OPACA
          offset: const Offset(0, 8), // ✅ MÁS SEPARADA
          blurRadius: 24, // ✅ MÁS DIFUSA
          spreadRadius: 2, // ✅ MÁS EXTENDIDA
        ),
        // ✅ SOMBRA SECUNDARIA PROFUNDA
        BoxShadow(
          color: accentColor.withValues(alpha: 0.15), // ✅ MÁS OPACA
          offset: const Offset(0, 16), // ✅ MÁS SEPARADA
          blurRadius: 32, // ✅ MÁS DIFUSA
          spreadRadius: -2, // ✅ CONTRACCIÓN PARA FORMA
        ),
        // ✅ SOMBRA BASE OSCURA PARA PROFUNDIDAD
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12), // ✅ SOMBRA NEGRA
          offset: const Offset(0, 4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
        // ✅ GLOW EFECTO MÁS INTENSO
        BoxShadow(
          color: accentColor.withValues(alpha: 0.1),
          offset: const Offset(0, 0),
          blurRadius: 12, // ✅ MÁS DIFUSO
          spreadRadius: 3, // ✅ MÁS EXTENDIDO
        ),
      ];
    } else {
      return [
        // ✅ SOMBRA NEUTRA PROFUNDA PARA CARDS NO SELECCIONADOS
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08), // ✅ MÁS OPACA
          offset: const Offset(0, 6), // ✅ MÁS SEPARADA
          blurRadius: 20, // ✅ MÁS DIFUSA
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05), // ✅ MÁS OPACA
          offset: const Offset(0, 12), // ✅ MÁS SEPARADA
          blurRadius: 28, // ✅ MÁS DIFUSA
          spreadRadius: -4,
        ),
        // ✅ SOMBRA ADICIONAL PARA MÁS PROFUNDIDAD
        BoxShadow(
          color: kBorderSoft.withValues(alpha: 0.15), // ✅ TOQUE DE COLOR SUTIL
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    }
  }

  /// 📱 CONTENIDO RESPONSIVE
  Widget _buildCardContent(BuildContext context) {
    return Row(
      children: [
        // 🎯 ÍCONO CON GRADIENTE
        _buildServiceIcon(context),
        SizedBox(width: _getContentSpacing(context)),

        // 📝 INFORMACIÓN PRINCIPAL
        Expanded(child: _buildServiceInfo(context)),

        // 💰 PRECIO (SI CORRESPONDE)
        if (showPricing && service['price'] != null)
          _buildPriceSection(context),

        // ✅ INDICADOR DE SELECCIÓN
        if (isSelected) _buildSelectionIndicator(context),
      ],
    );
  }

  /// 🎯 ÍCONO CON GRADIENTE PREMIUM + SOMBRA PROFUNDA
  Widget _buildServiceIcon(BuildContext context) {
    final iconSize = _getIconContainerSize(context);

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accentColor, accentColor.withValues(alpha: 0.8)],
              )
            : LinearGradient(
                colors: [
                  kBorderSoft.withValues(alpha: 0.3),
                  kBorderSoft.withValues(alpha: 0.5),
                ],
              ),
        borderRadius: BorderRadius.circular(_getIconRadius(context)),
        boxShadow: isSelected
            ? [
                // ✅ SOMBRA PROFUNDA PARA ÍCONO SELECCIONADO
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.4), // ✅ MÁS OPACA
                  blurRadius: 12, // ✅ MÁS DIFUSA
                  offset: const Offset(0, 4),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                // ✅ SOMBRA SUTIL PARA ÍCONO NO SELECCIONADO
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Icon(
        _getServiceIcon(),
        color: isSelected ? Colors.white : kTextSecondary,
        size: _getIconSize(context),
      ),
    );
  }

  /// 📝 INFORMACIÓN DEL SERVICIO
  Widget _buildServiceInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🏷️ NOMBRE DEL SERVICIO
        Text(
          service['name'] ?? 'Servicio',
          style: TextStyle(
            fontSize: _getTitleFontSize(context),
            fontWeight: FontWeight.w600,
            color: isSelected ? accentColor : Colors.black87,
            fontFamily: kFontFamily,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: _getTextSpacing(context)),

        // ⏱️ DURACIÓN Y DETALLES
        _buildServiceDetails(context),
      ],
    );
  }

  /// ⏱️ DETALLES DEL SERVICIO (DURACIÓN + PROFESIONAL)
  Widget _buildServiceDetails(BuildContext context) {
    return Wrap(
      spacing: _getDetailSpacing(context),
      runSpacing: 4,
      children: [
        // Duración
        _buildDetailChip(
          context: context,
          icon: Icons.access_time,
          text: '${service['duration'] ?? 60} min',
        ),

        // Profesional (si existe)
        if (service['profesionalNombre'] != null)
          _buildDetailChip(
            context: context,
            icon: Icons.person_outline,
            text: service['profesionalNombre'],
            maxWidth: 120,
          ),
      ],
    );
  }

  /// 🏷️ CHIP DE DETALLE ELEGANTE CON SOMBRA
  Widget _buildDetailChip({
    required BuildContext context,
    required IconData icon,
    required String text,
    double? maxWidth,
  }) {
    return Container(
      constraints: maxWidth != null ? BoxConstraints(maxWidth: maxWidth) : null,
      padding: EdgeInsets.symmetric(
        horizontal: _getChipPadding(context),
        vertical: _getChipPadding(context) * 0.6,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.8)
            : kBackgroundColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(_getChipRadius(context)),
        border: Border.all(
          color: isSelected
              ? accentColor.withValues(alpha: 0.2)
              : kBorderSoft.withValues(alpha: 0.4),
          width: 0.5,
        ),
        // ✅ SOMBRA SUTIL PARA CHIPS
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _getDetailIconSize(context),
            color: isSelected ? accentColor : kTextSecondary,
          ),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: _getDetailFontSize(context),
                color: isSelected ? accentColor : kTextSecondary,
                fontWeight: FontWeight.w500,
                fontFamily: kFontFamily,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 💰 SECCIÓN DE PRECIO PREMIUM CON SOMBRA PROFUNDA
  Widget _buildPriceSection(BuildContext context) {
    final price = service['price'] ?? 0;
    final isGratuito = price == 0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getPricePadding(context),
        vertical: _getPricePadding(context) * 0.8,
      ),
      decoration: BoxDecoration(
        gradient: isGratuito
            ? LinearGradient(
                colors: [kAccentGreen, kAccentGreen.withValues(alpha: 0.8)])
            : LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(_getPriceRadius(context)),
        boxShadow: [
          // ✅ SOMBRA PROFUNDA PARA PRECIO
          BoxShadow(
            color: (isGratuito ? kAccentGreen : accentColor)
                .withValues(alpha: 0.4), // ✅ MÁS OPACA
            blurRadius: 12, // ✅ MÁS DIFUSA
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
          // ✅ SOMBRA ADICIONAL PARA MÁS PROFUNDIDAD
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        isGratuito ? 'Gratis' : '\$$price',
        style: TextStyle(
          fontSize: _getPriceFontSize(context),
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: kFontFamily,
        ),
      ),
    );
  }

  /// ✅ INDICADOR DE SELECCIÓN CON SOMBRA PROFUNDA
  Widget _buildSelectionIndicator(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: _getContentSpacing(context)),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: accentColor,
        shape: BoxShape.circle,
        boxShadow: [
          // ✅ SOMBRA PROFUNDA PARA CHECK
          BoxShadow(
            color: accentColor.withValues(alpha: 0.5), // ✅ MÁS OPACA
            blurRadius: 12, // ✅ MÁS DIFUSA
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: _getCheckIconSize(context),
      ),
    );
  }

  /// 🎨 OBTENER ÍCONO DEL SERVICIO
  IconData _getServiceIcon() {
    final category = service['category']?.toString().toLowerCase() ?? '';
    final name = service['name']?.toString().toLowerCase() ?? '';

    if (category.contains('masaje') || name.contains('masaje')) {
      return Icons.spa_outlined;
    } else if (category.contains('facial') || name.contains('facial')) {
      return Icons.face_outlined;
    } else if (category.contains('terapia') || name.contains('terapia')) {
      return Icons.healing_outlined;
    } else if (category.contains('relajaci') || name.contains('relax')) {
      return Icons.self_improvement_outlined;
    }

    return Icons.spa_outlined; // Default
  }

  // ============================================================================
  // 📐 SISTEMA RESPONSIVO INTELIGENTE
  // ============================================================================

  /// 📦 ESPACIADO DE CARDS - ✅ INCREMENTADO PARA SOMBRAS PROFUNDAS
  double _getCardSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12; // iPhone SE - ✅ MÁS ESPACIO
    if (width <= 375) return 16; // iPhone pequeño - ✅ MÁS ESPACIO
    if (width <= 768) return 20; // Móvil normal - ✅ MÁS ESPACIO
    return 24; // Desktop - ✅ MÁS ESPACIO
  }

  /// 📦 PADDING INTERNO
  double _getCardPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12; // iPhone SE
    if (width <= 375) return 16; // iPhone pequeño
    if (width <= 768) return 20; // Móvil normal
    return 24; // Desktop
  }

  /// 📐 RADIO DE BORDES
  double _getBorderRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12;
    if (width <= 768) return 16;
    return 20;
  }

  /// 🎯 TAMAÑO CONTENEDOR ÍCONO
  double _getIconContainerSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 40; // iPhone SE
    if (width <= 375) return 44; // iPhone pequeño
    if (width <= 768) return 48; // Móvil normal
    return 52; // Desktop
  }

  /// 🎯 RADIO ÍCONO
  double _getIconRadius(BuildContext context) {
    final containerSize = _getIconContainerSize(context);
    return containerSize * 0.25; // 25% del tamaño
  }

  /// 🎯 TAMAÑO ÍCONO
  double _getIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 20;
    if (width <= 375) return 22;
    if (width <= 768) return 24;
    return 26;
  }

  /// 📝 FONT SIZE TÍTULO
  double _getTitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 14;
    if (width <= 375) return 15;
    if (width <= 768) return 16;
    return 17;
  }

  /// 📝 FONT SIZE DETALLES
  double _getDetailFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 11;
    if (width <= 375) return 12;
    if (width <= 768) return 13;
    return 14;
  }

  /// 💰 FONT SIZE PRECIO
  double _getPriceFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 14;
    if (width <= 375) return 16;
    if (width <= 768) return 18;
    return 20;
  }

  /// 📏 ESPACIADO CONTENIDO
  double _getContentSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 10;
    if (width <= 375) return 12;
    if (width <= 768) return 16;
    return 20;
  }

  /// 📏 ESPACIADO TEXTO
  double _getTextSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 4;
    if (width <= 768) return 6;
    return 8;
  }

  /// 📏 ESPACIADO DETALLES
  double _getDetailSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 6;
    if (width <= 768) return 8;
    return 12;
  }

  /// 🏷️ PADDING CHIPS
  double _getChipPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 6;
    if (width <= 768) return 8;
    return 10;
  }

  /// 🏷️ RADIO CHIPS
  double _getChipRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 8;
    if (width <= 768) return 10;
    return 12;
  }

  /// 🎯 TAMAÑO ÍCONO DETALLES
  double _getDetailIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12;
    if (width <= 768) return 14;
    return 16;
  }

  /// 💰 PADDING PRECIO
  double _getPricePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 8;
    if (width <= 768) return 10;
    return 12;
  }

  /// 💰 RADIO PRECIO
  double _getPriceRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 10;
    if (width <= 768) return 12;
    return 14;
  }

  /// ✅ TAMAÑO ÍCONO CHECK
  double _getCheckIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 14;
    if (width <= 768) return 16;
    return 18;
  }
}
