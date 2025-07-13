import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/models/factura_model.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class DashboardResumenCard extends StatefulWidget {
  final List<FacturaModel> facturas;

  const DashboardResumenCard({super.key, required this.facturas});

  @override
  State<DashboardResumenCard> createState() => _DashboardResumenCardState();
}

class _DashboardResumenCardState extends State<DashboardResumenCard> {
  int _anioSeleccionado = DateTime.now().year;
  bool _usarFlChart = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    final pagadas = widget.facturas.where((f) =>
        f.estadoPago == 'Pagado' &&
        f.fechaPagoReal != null &&
        f.fechaPagoReal!.year == _anioSeleccionado);

    final porMes = List.generate(12, (index) {
      final mes = index + 1;
      final montoMes = pagadas
          .where((f) => f.fechaPagoReal!.month == mes)
          .fold(0.0, (sum, f) => sum + f.monto);
      return montoMes;
    });

    final deudores = <String, double>{};
    for (var f in widget.facturas.where((f) => f.estadoPago == 'Pendiente')) {
      deudores[f.empresaId] = (deudores[f.empresaId] ?? 0) + f.monto;
    }
    final topEmpresas = deudores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = topEmpresas.take(5).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: kBrandPurple),
              const SizedBox(width: 8),
              const Text(
                'Monto cobrado por mes',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const Spacer(),
              DropdownButton<int>(
                value: _anioSeleccionado,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _anioSeleccionado = value);
                  }
                },
                items: List.generate(
                  3,
                  (index) {
                    final year = DateTime.now().year - index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text('$year'),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Tooltip(
                message: _usarFlChart
                    ? 'Ver gráfico simplificado'
                    : 'Ver gráfico profesional',
                child: IconButton(
                  icon: Icon(
                    _usarFlChart ? Icons.auto_graph : Icons.bar_chart,
                    color: kBrandPurple,
                  ),
                  onPressed: () => setState(() => _usarFlChart = !_usarFlChart),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: Row(
              children: List.generate(12, (index) {
                final valor = porMes[index];
                final max = porMes.reduce((a, b) => a > b ? a : b);
                final altura = max > 0 ? (valor / max * 60).toDouble() : 4.0;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: altura,
                        width: 12,
                        decoration: BoxDecoration(
                          color: kBrandPurple,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          'E',
                          'F',
                          'M',
                          'A',
                          'M',
                          'J',
                          'J',
                          'A',
                          'S',
                          'O',
                          'N',
                          'D'
                        ][index],
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Top empresas con adeudo',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...top5.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        e.key,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currencyFormat.format(e.value),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
