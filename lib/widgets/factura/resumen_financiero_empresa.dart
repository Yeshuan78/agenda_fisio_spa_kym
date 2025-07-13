import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/models/factura_model.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class ResumenFinancieroEmpresa extends StatelessWidget {
  final List<FacturaModel> facturas;

  const ResumenFinancieroEmpresa({super.key, required this.facturas});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    final pagadas = facturas.where((f) => f.estadoPago == 'Pagado').toList();
    final pendientes =
        facturas.where((f) => f.estadoPago == 'Pendiente').toList();
    final vencidas = pendientes
        .where((f) => f.fechaPagoEstimado.isBefore(DateTime.now()))
        .toList();

    final totalPagado = pagadas.fold(0.0, (sum, f) => sum + f.monto);
    final totalPendiente = pendientes.fold(0.0, (sum, f) => sum + f.monto);
    final totalVencido = vencidas.fold(0.0, (sum, f) => sum + f.monto);
    final totalFacturas = facturas.length;

    final porcentajePagado =
        totalFacturas > 0 ? (pagadas.length / totalFacturas * 100).round() : 0;

    final ultimaFecha =
        facturas.map((f) => f.fechaIngreso).fold<DateTime?>(null, (prev, curr) {
      if (prev == null) return curr;
      return curr.isAfter(prev) ? curr : prev;
    });

    String formatearFecha(DateTime? f) =>
        f == null ? '-' : DateFormat('dd/MM/yyyy').format(f);

    final tooltipBarra =
        '${pagadas.length} de $totalFacturas cobradas – ${currencyFormat.format(totalPagado)} de ${currencyFormat.format(totalPagado + totalPendiente)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 32,
                  runSpacing: 16,
                  children: [
                    _itemResumen(
                      icon: Icons.calendar_today,
                      color: Colors.grey[800],
                      title: 'Última factura',
                      value: formatearFecha(ultimaFecha),
                    ),
                    _itemResumen(
                      icon: Icons.check_circle,
                      color: kAccentGreen,
                      title: 'Pagadas',
                      value:
                          '${pagadas.length} · ${currencyFormat.format(totalPagado)}',
                    ),
                    _itemResumen(
                      icon: Icons.schedule,
                      color: Colors.orange.shade600,
                      title: 'Pendientes',
                      value:
                          '${pendientes.length} · ${currencyFormat.format(totalPendiente)}',
                    ),
                    _itemResumen(
                      icon: Icons.error_outline,
                      color: Colors.redAccent,
                      title: 'Vencidas',
                      value:
                          '${vencidas.length} · ${currencyFormat.format(totalVencido)}',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.bar_chart, size: 18, color: kBrandPurple),
              const SizedBox(width: 8),
              Text(
                'Avance de cobro: $porcentajePagado%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Tooltip(
            message: tooltipBarra,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: porcentajePagado / 100,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(kBrandPurple),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemResumen({
    required IconData icon,
    required Color? color,
    required String title,
    required String value,
  }) {
    return SizedBox(
      width: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
