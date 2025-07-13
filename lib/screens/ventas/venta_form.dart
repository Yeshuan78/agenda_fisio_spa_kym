// 📁 screens/ventas/venta_form.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/venta_model.dart';
import 'package:agenda_fisio_spa_kym/services/venta_service.dart';
import 'package:uuid/uuid.dart';

class VentaForm extends StatefulWidget {
  final VentaModel? ventaExistente;

  const VentaForm({super.key, this.ventaExistente});

  @override
  State<VentaForm> createState() => _VentaFormState();
}

class _VentaFormState extends State<VentaForm> {
  final _formKey = GlobalKey<FormState>();
  final _ventaService = VentaService();

  late TextEditingController _clienteIdCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _montoCtrl;
  String _metodoPago = 'efectivo';
  DateTime _fecha = DateTime.now();

  @override
  void initState() {
    super.initState();
    final v = widget.ventaExistente;
    _clienteIdCtrl = TextEditingController(text: v?.clienteId ?? '');
    _descripcionCtrl = TextEditingController(text: v?.descripcion ?? '');
    _montoCtrl = TextEditingController(text: v?.monto.toString() ?? '');
    _metodoPago = v?.metodoPago ?? 'efectivo';
    _fecha = v?.fecha ?? DateTime.now();
  }

  @override
  void dispose() {
    _clienteIdCtrl.dispose();
    _descripcionCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (seleccionada != null) {
      setState(() {
        _fecha = seleccionada;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final venta = VentaModel(
      id: widget.ventaExistente?.id ?? const Uuid().v4(),
      clienteId: _clienteIdCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      monto: double.tryParse(_montoCtrl.text.trim()) ?? 0.0,
      fecha: _fecha,
      metodoPago: _metodoPago,
    );

    if (widget.ventaExistente == null) {
      await _ventaService.crearVenta(venta);
    } else {
      await _ventaService.actualizarVenta(venta);
    }

    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.ventaExistente == null ? 'Nueva Venta' : 'Editar Venta'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _clienteIdCtrl,
                decoration: const InputDecoration(labelText: 'ID Cliente'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _descripcionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _montoCtrl,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              DropdownButtonFormField<String>(
                value: _metodoPago,
                items: const [
                  DropdownMenuItem(value: 'efectivo', child: Text('Efectivo')),
                  DropdownMenuItem(value: 'tarjeta', child: Text('Tarjeta')),
                  DropdownMenuItem(
                      value: 'transferencia', child: Text('Transferencia')),
                ],
                onChanged: (value) =>
                    setState(() => _metodoPago = value ?? 'efectivo'),
                decoration: const InputDecoration(labelText: 'Método de pago'),
              ),
              TextButton.icon(
                onPressed: _seleccionarFecha,
                icon: const Icon(Icons.date_range),
                label:
                    Text('Fecha: ${_fecha.toLocal().toString().split(' ')[0]}'),
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
