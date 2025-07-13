import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:agenda_fisio_spa_kym/models/factura_model.dart';
import 'package:agenda_fisio_spa_kym/services/factura_service.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/factura/factura_uploader_dialog.dart';

class FacturaFormScreen extends StatefulWidget {
  final ArchivosFactura archivos;

  const FacturaFormScreen({super.key, required this.archivos});

  @override
  State<FacturaFormScreen> createState() => _FacturaFormScreenState();
}

class _FacturaFormScreenState extends State<FacturaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _empresaController = TextEditingController();
  final _ordenCompraController = TextEditingController();
  final _numeroFacturaController = TextEditingController();
  final _montoController = TextEditingController();
  final _condicionesPagoController = TextEditingController(text: '30');
  final _fechaPagoRealController = TextEditingController();
  final _descripcionController = TextEditingController();

  String estadoPago = 'Pendiente';
  late DateTime fechaIngreso;
  late DateTime fechaEstimadoPago;

  @override
  void initState() {
    super.initState();
    final datos = widget.archivos.datosXml;
    final ahora = DateTime.now();

    _empresaController.text = datos['nombreReceptor'] ?? '';
    _ordenCompraController.text = widget.archivos.ordenCompra;
    _numeroFacturaController.text =
        '${datos['serie'] ?? ''}${datos['folio'] ?? ''}';
    _montoController.text = (datos['montoTotal'] ?? 0.0).toStringAsFixed(2);

    fechaIngreso = ahora;
    fechaEstimadoPago = ahora.add(
        Duration(days: int.tryParse(_condicionesPagoController.text) ?? 30));
  }

  void _guardarFactura() async {
    if (!_formKey.currentState!.validate()) return;

    final condicionesDias =
        int.tryParse(_condicionesPagoController.text.trim()) ?? 30;

    final factura = FacturaModel(
      id: const Uuid().v4(),
      empresaId: _empresaController.text.trim(),
      ordenCompra: _ordenCompraController.text.trim(),
      numeroFactura: _numeroFacturaController.text.trim(),
      monto: double.tryParse(_montoController.text.trim()) ?? 0,
      fechaIngreso: fechaIngreso,
      condicionesPagoDias: condicionesDias,
      fechaPagoEstimado: fechaIngreso.add(Duration(days: condicionesDias)),
      fechaPagoReal: _fechaPagoRealController.text.isEmpty
          ? null
          : DateTime.tryParse(_fechaPagoRealController.text),
      estadoPago: estadoPago,
      complementoEnviado: false,
      descripcionServicios: _descripcionController.text.trim(),
      uuid: widget.archivos.datosXml['uuid'],
      usoCFDI: widget.archivos.datosXml['usoCFDI'],
      metodoPago: widget.archivos.datosXml['metodoPago'],
      formaPago: widget.archivos.datosXml['formaPago'],
      rfcReceptor: widget.archivos.datosXml['rfcReceptor'],
      pdfUrl: null,
      xmlUrl: null,
    );

    await FacturaService().crearFactura(factura);
    Navigator.pop(context); // cerrar formulario
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulario de factura')),
      body: Center(
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderColor.withValues(alpha: 0.04)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _empresaController,
                  decoration: const InputDecoration(labelText: 'Empresa'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: _ordenCompraController,
                  decoration:
                      const InputDecoration(labelText: 'Orden de compra'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: _numeroFacturaController,
                  decoration:
                      const InputDecoration(labelText: 'Número de factura'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: _montoController,
                  decoration:
                      const InputDecoration(labelText: 'Monto (\$ MXN)'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _condicionesPagoController,
                  decoration: const InputDecoration(
                      labelText: 'Condiciones de pago (días)'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) {
                    setState(() {
                      final dias =
                          int.tryParse(_condicionesPagoController.text) ?? 30;
                      fechaEstimadoPago =
                          fechaIngreso.add(Duration(days: dias));
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText:
                        'Fecha estimada de pago: ${fechaEstimadoPago.toString().substring(0, 10)}',
                    enabled: false,
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: estadoPago,
                  decoration:
                      const InputDecoration(labelText: 'Estado del pago'),
                  items: const [
                    DropdownMenuItem(
                        value: 'Pendiente', child: Text('Pendiente')),
                    DropdownMenuItem(value: 'Pagado', child: Text('Pagado')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => estadoPago = val);
                    }
                  },
                ),
                TextFormField(
                  controller: _fechaPagoRealController,
                  decoration:
                      const InputDecoration(labelText: 'Fecha de pago real'),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      _fechaPagoRealController.text =
                          date.toIso8601String().substring(0, 10);
                    }
                  },
                ),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Descripción de servicios'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: _guardarFactura,
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
