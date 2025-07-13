// [Parte 1 de 3] – factura_form_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:agenda_fisio_spa_kym/models/factura_model.dart';
import 'package:agenda_fisio_spa_kym/services/factura_service.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/factura/factura_uploader_dialog.dart';

class FacturaFormScreen extends StatefulWidget {
  final ArchivosFactura? archivos; // Solo se usa en modo creación
  final FacturaModel? factura; // Si se pasa, es modo edición

  const FacturaFormScreen({
    super.key,
    this.archivos,
    this.factura,
  });

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
  final _fechaIngresoController = TextEditingController();
  final _descripcionController = TextEditingController();

  bool _modoEdicion = false;
  String estadoPago = 'Pendiente';
  late DateTime fechaIngreso;
  late DateTime fechaEstimadoPago;

  @override
  void initState() {
    super.initState();
    _modoEdicion = widget.factura != null;

    if (_modoEdicion) {
      final f = widget.factura!;
      _empresaController.text = f.empresaId;
      _ordenCompraController.text = f.ordenCompra;
      _numeroFacturaController.text = f.numeroFactura;
      _montoController.text = f.monto.toStringAsFixed(2);
      _condicionesPagoController.text = f.condicionesPagoDias.toString();
      _fechaIngresoController.text =
          f.fechaIngreso.toIso8601String().substring(0, 10);
      _fechaPagoRealController.text = f.fechaPagoReal != null
          ? f.fechaPagoReal!.toIso8601String().substring(0, 10)
          : '';
      _descripcionController.text = f.descripcionServicios;
      estadoPago = f.estadoPago;

      fechaIngreso = f.fechaIngreso;
      fechaEstimadoPago =
          f.fechaIngreso.add(Duration(days: f.condicionesPagoDias));
    } else {
      final datos = widget.archivos!.datosXml;
      final ahora = DateTime.now();

      _empresaController.text = datos['nombreReceptor'] ?? '';
      _ordenCompraController.text = widget.archivos!.ordenCompra;
      _numeroFacturaController.text =
          '${datos['serie'] ?? ''}${datos['folio'] ?? ''}';
      _montoController.text = (datos['montoTotal'] ?? 0.0).toStringAsFixed(2);

      final condicionesXml = datos['condicionesDePago'] ?? '';
      final match = RegExp(r'(\d{1,3})').firstMatch(condicionesXml);
      final diasCondiciones = match != null ? match.group(1) : '30';
      _condicionesPagoController.text = diasCondiciones ?? '30';

      fechaIngreso = ahora;
      _fechaIngresoController.text =
          fechaIngreso.toIso8601String().substring(0, 10);
      fechaEstimadoPago = fechaIngreso.add(
        Duration(days: int.tryParse(diasCondiciones!) ?? 30),
      );
    }
  }

  void _actualizarFechaEstimado() {
    setState(() {
      final parsed = DateTime.tryParse(_fechaIngresoController.text);
      final dias = int.tryParse(_condicionesPagoController.text) ?? 30;
      if (parsed != null) {
        fechaIngreso = parsed;
        fechaEstimadoPago = parsed.add(Duration(days: dias));
      }
    });
  }

  Future<void> _guardarFactura() async {
    if (!_formKey.currentState!.validate()) return;

    final condicionesDias =
        int.tryParse(_condicionesPagoController.text.trim()) ?? 30;
    final fechaCarga = DateTime.tryParse(_fechaIngresoController.text.trim()) ??
        DateTime.now();

    final nuevaFactura = FacturaModel(
      id: _modoEdicion ? widget.factura!.id : const Uuid().v4(),
      empresaId: _modoEdicion
          ? widget.factura!.empresaId
          : _empresaController.text.trim(),
      ordenCompra: _ordenCompraController.text.trim(),
      numeroFactura: _modoEdicion
          ? widget.factura!.numeroFactura
          : _numeroFacturaController.text.trim(),
      monto: double.tryParse(_montoController.text.trim()) ?? 0,
      fechaIngreso: fechaCarga,
      condicionesPagoDias: condicionesDias,
      fechaPagoEstimado: fechaCarga.add(Duration(days: condicionesDias)),
      fechaPagoReal: _fechaPagoRealController.text.isEmpty
          ? null
          : DateTime.tryParse(_fechaPagoRealController.text),
      estadoPago: estadoPago,
      complementoEnviado:
          _modoEdicion ? widget.factura!.complementoEnviado : false,
      descripcionServicios: _descripcionController.text.trim(),
      uuid: _modoEdicion
          ? widget.factura!.uuid
          : widget.archivos?.datosXml['uuid'],
      usoCFDI: _modoEdicion
          ? widget.factura!.usoCFDI
          : widget.archivos?.datosXml['usoCFDI'],
      metodoPago: _modoEdicion
          ? widget.factura!.metodoPago
          : widget.archivos?.datosXml['metodoPago'],
      formaPago: _modoEdicion
          ? widget.factura!.formaPago
          : widget.archivos?.datosXml['formaPago'],
      rfcReceptor: _modoEdicion
          ? widget.factura!.rfcReceptor
          : widget.archivos?.datosXml['rfcReceptor'],
      pdfUrl: _modoEdicion ? widget.factura!.pdfUrl : null,
      xmlUrl: _modoEdicion ? widget.factura!.xmlUrl : null,
    );

    if (nuevaFactura.monto <= 0 ||
        nuevaFactura.ordenCompra.isEmpty ||
        nuevaFactura.descripcionServicios.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verifica que todos los campos estén completos.'),
        ),
      );
      return;
    }

    if (_modoEdicion) {
      await FacturaService().actualizarFactura(nuevaFactura);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Factura actualizada con éxito')),
      );
    } else {
      await FacturaService().crearFactura(nuevaFactura);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Factura registrada con éxito')),
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modoEdicion
            ? 'Editar factura existente'
            : 'Formulario de factura'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 700,
            margin: const EdgeInsets.only(top: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: kSombraSuperior,
              border: Border.all(color: kBorderColor.withValues(alpha: 0.3)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _empresaController,
                    enabled: !_modoEdicion,
                    decoration: const InputDecoration(
                      labelText: 'Empresa',
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ordenCompraController,
                    decoration: const InputDecoration(
                      labelText: 'Orden de compra',
                      prefixIcon: Icon(Icons.confirmation_number),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _numeroFacturaController,
                    enabled: !_modoEdicion,
                    decoration: const InputDecoration(
                      labelText: 'Número de factura',
                      prefixIcon: Icon(Icons.receipt),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _montoController,
                    decoration: const InputDecoration(
                      labelText: 'Monto (\$ MXN)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fechaIngresoController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de carga al sistema',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: fechaIngreso,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        _fechaIngresoController.text =
                            date.toIso8601String().substring(0, 10);
                        _actualizarFechaEstimado();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _condicionesPagoController,
                    decoration: const InputDecoration(
                      labelText: 'Condiciones de pago (días)',
                      prefixIcon: Icon(Icons.timelapse),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _actualizarFechaEstimado(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: kBorderColor.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade100,
                    ),
                    child: Text(
                      'Fecha estimada de pago: ${fechaEstimadoPago.toString().substring(0, 10)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: estadoPago,
                    decoration: const InputDecoration(
                      labelText: 'Estado del pago',
                      prefixIcon: Icon(Icons.sync),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Pendiente', child: Text('Pendiente')),
                      DropdownMenuItem(value: 'Pagado', child: Text('Pagado')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => estadoPago = val);
                    },
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fechaPagoRealController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de pago real',
                      prefixIcon: Icon(Icons.event),
                    ),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción de servicios',
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: _guardarFactura,
                        child: Text(_modoEdicion ? 'Actualizar' : 'Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
