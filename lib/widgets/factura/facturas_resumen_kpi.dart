import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/factura_model.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/factura/kpi_resumen_card.dart';
import 'package:agenda_fisio_spa_kym/widgets/factura/dashboard_resumen_card.dart';

class FacturasResumenKPI extends StatefulWidget {
  final List<FacturaModel> facturas;

  const FacturasResumenKPI({super.key, required this.facturas});

  @override
  State<FacturasResumenKPI> createState() => _FacturasResumenKPIState();
}

class _FacturasResumenKPIState extends State<FacturasResumenKPI> {
  bool _mostrarDashboard = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: kBorderColor.withAlpha(80)),
          ),
          child: AnimatedCrossFade(
            crossFadeState: _mostrarDashboard
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 400),
            firstChild: KpiResumenCard(facturas: widget.facturas),
            secondChild: DashboardResumenCard(facturas: widget.facturas),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Tooltip(
            message: _mostrarDashboard
                ? 'Ver KPIs principales'
                : 'Ver dashboard ejecutivo',
            child: GestureDetector(
              onTap: () {
                setState(() => _mostrarDashboard = !_mostrarDashboard);
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[100],
                child: Icon(
                  _mostrarDashboard ? Icons.close : Icons.bar_chart,
                  size: 18,
                  color: kBrandPurple,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
