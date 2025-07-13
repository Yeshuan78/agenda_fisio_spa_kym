import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/models/factura_model.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/factura/factura_card.dart';
import 'package:agenda_fisio_spa_kym/widgets/factura/resumen_financiero_empresa.dart';

class FacturasPorEmpresaFolder extends StatefulWidget {
  final String empresa;
  final List<FacturaModel> facturas;

  const FacturasPorEmpresaFolder({
    super.key,
    required this.empresa,
    required this.facturas,
  });

  @override
  State<FacturasPorEmpresaFolder> createState() =>
      _FacturasPorEmpresaFolderState();
}

class _FacturasPorEmpresaFolderState extends State<FacturasPorEmpresaFolder> {
  bool _expandido = false;

  void _exportarResumenPDF(String empresa, String anio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exportando resumen $empresa $anio...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final partes = widget.empresa.trim().split(' ');
    final anio = partes.last;
    final nombreEmpresa = partes.sublist(0, partes.length - 1).join(' ');

    final esAnioActual = anio == DateTime.now().year.toString();
    final iconoColor = esAnioActual ? kBrandPurple : Colors.grey[600];

    final cantidad = widget.facturas.length;
    final total =
        widget.facturas.fold<double>(0, (sum, factura) => sum + factura.monto);
    final totalFormateado = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    ).format(total);

    final resumenTooltip =
        'Este año tiene $cantidad factura${cantidad > 1 ? 's' : ''} · Total: $totalFormateado';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kSombraSuperior,
        border: Border.all(color: kBorderColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expandido = !_expandido),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.folder, size: 32, color: iconoColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      nombreEmpresa.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Descargar resumen PDF $anio',
                    child: GestureDetector(
                      onTap: () => _exportarResumenPDF(nombreEmpresa, anio),
                      child: Chip(
                        label: Text(
                          anio,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.grey[100],
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expandido ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),

          // 🔽 Contenido expandido
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            crossFadeState: _expandido
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: ResumenFinancieroEmpresa(facturas: widget.facturas),
                  ),
                ),
                ...widget.facturas.map((factura) => FacturaCard(
                      factura: factura,
                      onEditar: () {
                        // Delegado externo
                      },
                    )),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
