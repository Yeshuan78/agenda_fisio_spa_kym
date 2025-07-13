// [Archivo: lib/widgets/kym_pulse/pulse_dashboard_resumen.dart]
import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class PulseDashboardResumen extends StatelessWidget {
  final int totalRegistros;
  final int totalEventos;
  final int totalProfesionales;
  final int totalServicios;

  const PulseDashboardResumen({
    super.key,
    required this.totalRegistros,
    required this.totalEventos,
    required this.totalProfesionales,
    required this.totalServicios,
  });

  @override
  Widget build(BuildContext context) {
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
            _buildKpiTile(Icons.qr_code_scanner, 'Registros', totalRegistros),
            _buildKpiTile(
                Icons.calendar_today_outlined, 'Eventos', totalEventos),
            _buildKpiTile(
                Icons.person_outline, 'Profesionales', totalProfesionales),
            _buildKpiTile(
                Icons.folder_copy_outlined, 'Servicios', totalServicios),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiTile(IconData icon, String label, int value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: kBrandPurple),
        const SizedBox(height: 8),
        Text(
          value.toString(),
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
