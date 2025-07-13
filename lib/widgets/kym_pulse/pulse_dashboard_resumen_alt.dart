// [Archivo: lib/widgets/kym_pulse/pulse_dashboard_resumen_alt.dart]
import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class PulseDashboardResumenAlt extends StatelessWidget {
  final int totalEventos;
  final int totalRegistros;
  final int totalCombinaciones;
  final int eventosSinRegistros;

  const PulseDashboardResumenAlt({
    super.key,
    required this.totalEventos,
    required this.totalRegistros,
    required this.totalCombinaciones,
    required this.eventosSinRegistros,
  });

  @override
  Widget build(BuildContext context) {
    final promedio = totalEventos > 0
        ? (totalRegistros / totalEventos).toStringAsFixed(1)
        : '0';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kBorderColor.withValues(alpha: 0.01)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKpiTile(Icons.layers, 'Combinaciones', totalCombinaciones),
            _buildKpiTile(Icons.warning_amber_outlined, 'Sin registros',
                eventosSinRegistros),
            _buildKpiTile(Icons.bar_chart, 'Promedio / evento', promedio),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiTile(IconData icon, String label, dynamic valor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: kBrandPurple),
        const SizedBox(height: 8),
        Text(
          valor.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
