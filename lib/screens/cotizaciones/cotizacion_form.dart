// 📁 screens/cotizaciones/cotizacion_form.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/cotizacion_model.dart';
import 'package:agenda_fisio_spa_kym/services/cotizacion_service.dart';
import 'package:uuid/uuid.dart';

class CotizacionForm extends StatefulWidget {
  final CotizacionModel? cotizacionExistente;

  const CotizacionForm({super.key, this.cotizacionExistente});

  @override
  State<CotizacionForm> createState() => _CotizacionFormState();
}

class _CotizacionFormState extends State<CotizacionForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = CotizacionService();

  late TextEditingController _empresaIdCtrl;
  late TextEditingController _clienteIdCtrl;
  late TextEditingController _montoCtrl;
  late TextEditingController _observacionesCtrl;
  String _estado = 'pendiente';
  DateTime _fechaEmision = DateTime.now();

  @override
  void initState() {
    super.initState();
    final c = widget.cotizacionExistente;
    _empresaIdCtrl = TextEditingController(text: c?.empresaId ?? '');
    _clienteIdCtrl = TextEditingController(text: c?.clienteId ?? '');
    _montoCtrl =
        TextEditingController(text: c?.montoPropuesto.toString() ?? '');
    _observacionesCtrl = TextEditingController(text: c?.observaciones ?? '');
    _estado = c?.estado ?? 'pendiente';
    _fechaEmision = c?.fechaEmision ?? DateTime.now();
  }

  @override
  void dispose() {
    _empresaIdCtrl.dispose();
    _clienteIdCtrl.dispose();
    _montoCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final f = await showDatePicker(
      context: context,
      initialDate: _fechaEmision,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (f != null) setState(() => _fechaEmision = f);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final nueva = CotizacionModel(
      id: widget.cotizacionExistente?.id ?? const Uuid().v4(),
      empresaId: _empresaIdCtrl.text.trim(),
      clienteId: _clienteIdCtrl.text.trim(),
      montoPropuesto: double.tryParse(_montoCtrl.text.trim()) ?? 0.0,
      estado: _estado,
      fechaEmision: _fechaEmision,
      observaciones: _observacionesCtrl.text.trim(),
    );

    if (widget.cotizacionExistente == null) {
      await _service.crearCotizacion(nueva);
    } else {
      await _service.actualizarCotizacion(nueva);
    }

    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.cotizacionExistente == null
          ? 'Nueva Cotización'
          : 'Editar Cotización'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _empresaIdCtrl,
                decoration: const InputDecoration(labelText: 'ID Empresa'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _clienteIdCtrl,
                decoration: const InputDecoration(labelText: 'ID Cliente'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _montoCtrl,
                decoration: const InputDecoration(labelText: 'Monto Propuesto'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: const [
                  DropdownMenuItem(
                      value: 'pendiente', child: Text('Pendiente')),
                  DropdownMenuItem(value: 'aceptada', child: Text('Aceptada')),
                  DropdownMenuItem(
                      value: 'rechazada', child: Text('Rechazada')),
                ],
                onChanged: (v) => setState(() => _estado = v ?? 'pendiente'),
              ),
              TextFormField(
                controller: _observacionesCtrl,
                decoration: const InputDecoration(labelText: 'Observaciones'),
                maxLines: 3,
              ),
              TextButton.icon(
                onPressed: _seleccionarFecha,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                    'Fecha: ${_fechaEmision.toLocal().toString().split(' ')[0]}'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _guardar, child: const Text('Guardar')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
