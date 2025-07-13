// [interval_selector_dialog.dart]
// 📁 Ubicación: /lib/widgets/agenda/interval_selector_dialog.dart
// 🎯 SELECTOR DE INTERVALO MEJORADO - 300PX WIDTH CENTRADO
// ✅ Dialog centrado en lugar de bottom sheet
// ✅ Ancho controlado de 300px
// ✅ UX/UI profesional para CRM corporativo

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class IntervalSelectorDialog extends StatelessWidget {
  final int currentInterval;
  final List<int> availableIntervals;
  final Function(int) onIntervalChanged;

  const IntervalSelectorDialog({
    super.key,
    required this.currentInterval,
    required this.availableIntervals,
    required this.onIntervalChanged,
  });

  /// 🎯 MOSTRAR DIALOG CENTRADO CON ANCHO CONTROLADO
  static Future<void> show(
    BuildContext context, {
    required int currentInterval,
    required List<int> availableIntervals,
    required Function(int) onIntervalChanged,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          width: 300, // ✅ ANCHO CONTROLADO - 300PX
          child: IntervalSelectorDialog(
            currentInterval: currentInterval,
            availableIntervals: availableIntervals,
            onIntervalChanged: onIntervalChanged,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ ALTURA AUTOMÁTICA
        children: [
          // 🎨 HEADER CON ÍCONO Y TÍTULO
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kBrandPurple.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: kBrandPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Intervalo de tiempo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Duración de cada slot',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // ❌ BOTÓN CERRAR
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📋 LISTA DE OPCIONES DE INTERVALO
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: availableIntervals
                  .map((interval) => _buildIntervalOption(context, interval))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎛️ CONSTRUIR OPCIÓN DE INTERVALO
  Widget _buildIntervalOption(BuildContext context, int interval) {
    final isSelected = interval == currentInterval;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onIntervalChanged(interval);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color:
                  isSelected ? kBrandPurple.withAlpha(25) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? kBrandPurple : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // 🔘 RADIO BUTTON
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? kBrandPurple : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? kBrandPurple : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),

                const SizedBox(width: 12),

                // 📝 TEXTO DEL INTERVALO
                Expanded(
                  child: Text(
                    '$interval minutos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? kBrandPurple : Colors.grey.shade700,
                    ),
                  ),
                ),

                // ⚡ INDICADOR VISUAL DE SELECCIÓN
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kBrandPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Actual',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
