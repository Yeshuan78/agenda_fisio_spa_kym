import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/models/factura_model.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class KpiResumenCard extends StatelessWidget {
  final List<FacturaModel> facturas;

  const KpiResumenCard({super.key, required this.facturas});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    final totalPendiente = facturas
        .where((f) => f.estadoPago == 'Pendiente')
        .fold(0.0, (sum, f) => sum + f.monto);

    final totalPagado = facturas
        .where((f) => f.estadoPago == 'Pagado')
        .fold(0.0, (sum, f) => sum + f.monto);

    final empresasConAdeudo = facturas
        .where((f) => f.estadoPago == 'Pendiente')
        .map((f) => f.empresaId)
        .toSet()
        .length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem(
            icon: Icons.money_off_csred_rounded,
            label: 'Total pendiente',
            value: currencyFormat.format(totalPendiente),
            color: Colors.orange,
          ),
          _buildItem(
            icon: Icons.check_circle,
            label: 'Total cobrado',
            value: currencyFormat.format(totalPagado),
            color: Colors.green,
          ),
          _buildItem(
            icon: Icons.business,
            label: 'Empresas con adeudo',
            value: empresasConAdeudo.toString(),
            color: kBrandPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
