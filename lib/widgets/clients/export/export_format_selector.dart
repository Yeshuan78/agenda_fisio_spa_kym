// [export_format_selector.dart] - SELECTOR VERDADERAMENTE COMPACTO
// 📁 Ubicación: /lib/widgets/clients/export/export_format_selector.dart
// 🎯 OBJETIVO: Badges realmente pequeños que quepan sin scroll

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/export_models.dart';

/// 📋 SELECTOR DE FORMATO VERDADERAMENTE COMPACTO
class ExportFormatSelector extends StatelessWidget {
  final ExportFormat selectedFormat;
  final Function(ExportFormat) onFormatChanged;

  const ExportFormatSelector({
    super.key,
    required this.selectedFormat,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona el formato de exportación',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Elige el formato que mejor se adapte a tus necesidades',
            style: TextStyle(
              fontSize: 14,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // ✅ CAMBIO RADICAL: USAR WRAP EN LUGAR DE GRID
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: ExportFormat.values.map((format) {
                  return _buildCompactFormatCard(format);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFormatCard(ExportFormat format) {
    final isSelected = selectedFormat == format;
    final color = _getFormatColor(format);

    return InkWell(
      onTap: () {
        onFormatChanged(format);
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 146, // ✅ ANCHO AJUSTADO (+6px)
        height: 126, // ✅ ALTURA AJUSTADA (+6px)
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : kBorderSoft,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: kCardShadow.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ ICONO PEQUEÑO
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                format.icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),

            // ✅ TÍTULO COMPACTO
            Text(
              format.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),

            // ✅ DESCRIPCIÓN MUY CORTA
            Text(
              _getShortDescription(format),
              style: TextStyle(
                fontSize: 10,
                color:
                    isSelected ? color.withValues(alpha: 0.8) : kTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // ✅ UNA SOLA FEATURE PRINCIPAL
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 10,
                  color: isSelected ? color : kAccentGreen,
                ),
                const SizedBox(width: 3),
                Text(
                  _getMainFeature(format),
                  style: TextStyle(
                    fontSize: 9,
                    color: isSelected
                        ? color.withValues(alpha: 0.9)
                        : kTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getFormatColor(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return kAccentGreen;
      case ExportFormat.excel:
        return kAccentBlue;
      case ExportFormat.pdf:
        return Colors.red;
      case ExportFormat.json:
        return kBrandPurple;
    }
  }

  String _getShortDescription(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'Separado por comas';
      case ExportFormat.excel:
        return 'Hoja de cálculo';
      case ExportFormat.pdf:
        return 'Documento';
      case ExportFormat.json:
        return 'Datos JSON';
    }
  }

  String _getMainFeature(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'Universal';
      case ExportFormat.excel:
        return 'Rico';
      case ExportFormat.pdf:
        return 'Portable';
      case ExportFormat.json:
        return 'APIs';
    }
  }
}
