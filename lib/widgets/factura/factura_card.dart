import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:agenda_fisio_spa_kym/models/factura_model.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/services/factura_service.dart';
import 'package:agenda_fisio_spa_kym/widgets/factura/factura_archivos_toolbar.dart';

class FacturaCard extends StatefulWidget {
  final FacturaModel factura;
  final VoidCallback? onEditar;

  const FacturaCard({
    super.key,
    required this.factura,
    this.onEditar,
  });

  @override
  State<FacturaCard> createState() => _FacturaCardState();
}

class _FacturaCardState extends State<FacturaCard> {
  late String estadoPago;
  final dateFormat = DateFormat('dd/MM/yyyy');
  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void initState() {
    super.initState();
    estadoPago = widget.factura.estadoPago;
  }

  void _toggleEstado() async {
    final nuevoEstado = estadoPago == 'Pagado' ? 'Pendiente' : 'Pagado';
    await FacturaService().actualizarEstadoPago(widget.factura.id, nuevoEstado);
    setState(() {
      estadoPago = nuevoEstado;
    });
  }

  List<Widget> _buildEtiquetasInteligentes() {
    final now = DateTime.now();
    final List<Widget> chips = [];

    if (widget.factura.estadoPago == 'Pendiente' &&
        widget.factura.fechaPagoEstimado.isBefore(now)) {
      chips.add(_chipEtiqueta('Vencida', tooltip: 'La fecha estimada ya pasó'));
    }

    if (widget.factura.estadoPago == 'Pagado' &&
        widget.factura.fechaPagoReal != null &&
        widget.factura.fechaPagoReal!
            .isBefore(widget.factura.fechaPagoEstimado)) {
      chips.add(_chipEtiqueta('Pagado a tiempo',
          tooltip: 'Se pagó antes de la fecha estimada'));
    }

    if (widget.factura.descripcionServicios.toLowerCase().contains('masaje')) {
      chips.add(_chipEtiqueta('Masajes',
          tooltip: 'Servicios relacionados con masaje'));
    }

    if (widget.factura.complementoEnviado == true) {
      chips.add(_chipEtiqueta('Complemento enviado',
          tooltip: 'El complemento de pago fue emitido'));
    }

    return chips;
  }

  Widget _chipEtiqueta(String texto, {String? tooltip}) {
    final chip = Chip(
      label: Text(
        texto,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.grey[200],
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );

    return tooltip != null ? Tooltip(message: tooltip, child: chip) : chip;
  }

  Future<void> _abrirUrl(String? url) async {
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 800,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: kSombraSuperior,
          border: Border.all(color: kBorderColor.withAlpha(76)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📌 Columna izquierda
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.factura.empresaId.toUpperCase(),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                            'Ingreso: ${dateFormat.format(widget.factura.fechaIngreso)}'),
                        Text(
                            'Fecha de pago: ${widget.factura.fechaPagoReal != null ? dateFormat.format(widget.factura.fechaPagoReal!) : '-'}'),
                        Text(
                            'Fecha estimada de pago: ${dateFormat.format(widget.factura.fechaPagoEstimado)}'),
                        Text('OC: ${widget.factura.ordenCompra}'),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            currencyFormat.format(widget.factura.monto),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (widget.factura.descripcionServicios.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Descripción de servicios:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: kBackgroundColor.withAlpha(50),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.factura.descripcionServicios,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // ✅ Columna derecha: factura + toolbar + editar
                  SizedBox(
                    width: 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Factura: ${widget.factura.numeroFactura}',
                          style: const TextStyle(
                            color: kBrandPurple,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FacturaArchivosToolbar(factura: widget.factura),
                        if (widget.onEditar != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Editar',
                              onPressed: widget.onEditar,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                GestureDetector(
                  onTap: _toggleEstado,
                  child: Chip(
                    label: Text(estadoPago),
                    backgroundColor:
                        estadoPago == 'Pagado' ? Colors.green : Colors.orange,
                    labelStyle: const TextStyle(color: Colors.white),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                ..._buildEtiquetasInteligentes(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
