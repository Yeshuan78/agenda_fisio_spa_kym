import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/contrato_model.dart';
import 'package:agenda_fisio_spa_kym/services/contrato_service.dart';
import 'package:uuid/uuid.dart';

class ContratoForm extends StatefulWidget {
  final ContratoModel? contratoExistente;

  const ContratoForm({super.key, this.contratoExistente});

  @override
  State<ContratoForm> createState() => _ContratoFormState();
}

class _ContratoFormState extends State<ContratoForm> {
  final _formKey = GlobalKey<FormState>();
  final _contratoService = ContratoService();

  late TextEditingController _empresaIdCtrl;
  late TextEditingController _clienteIdCtrl;
  late TextEditingController _montoCtrl;
  late TextEditingController _descripcionCtrl;

  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now().add(const Duration(days: 30));
  String _estado = 'activo';

  @override
  void initState() {
    super.initState();
    final contrato = widget.contratoExistente;

    _empresaIdCtrl = TextEditingController(text: contrato?.empresaId ?? '');
    _clienteIdCtrl = TextEditingController(text: contrato?.clienteId ?? '');
    _montoCtrl =
        TextEditingController(text: contrato?.montoTotal.toString() ?? '');
    _descripcionCtrl = TextEditingController(text: contrato?.descripcion ?? '');
    _fechaInicio = contrato?.fechaInicio ?? DateTime.now();
    _fechaFin =
        contrato?.fechaFin ?? DateTime.now().add(const Duration(days: 30));
    _estado = contrato?.estado ?? 'activo';
  }

  @override
  void dispose() {
    _empresaIdCtrl.dispose();
    _clienteIdCtrl.dispose();
    _montoCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context, bool esInicio) async {
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: esInicio ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        if (esInicio) {
          _fechaInicio = fechaSeleccionada;
        } else {
          _fechaFin = fechaSeleccionada;
        }
      });
    }
  }

  Future<void> _guardarContrato() async {
    if (!_formKey.currentState!.validate()) return;

    final contrato = ContratoModel(
      id: widget.contratoExistente?.id ?? const Uuid().v4(),
      empresaId: _empresaIdCtrl.text.trim(),
      clienteId: _clienteIdCtrl.text.trim(),
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
      montoTotal: double.tryParse(_montoCtrl.text) ?? 0.0,
      estado: _estado,
      descripcion: _descripcionCtrl.text.trim(),
      fechaCreacion: widget.contratoExistente?.fechaCreacion ?? DateTime.now(),
    );

    if (widget.contratoExistente == null) {
      await _contratoService.crearContrato(contrato);
    } else {
      await _contratoService.actualizarContrato(contrato);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contratoExistente == null
            ? 'Nuevo Contrato'
            : 'Editar Contrato'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _empresaIdCtrl,
                decoration: const InputDecoration(labelText: 'ID Empresa'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _clienteIdCtrl,
                decoration: const InputDecoration(labelText: 'ID Cliente'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _montoCtrl,
                decoration: const InputDecoration(labelText: 'Monto Total'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _descripcionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'Inicio: ${_fechaInicio.toLocal().toString().split(' ')[0]}'),
                  ),
                  TextButton(
                    onPressed: () => _seleccionarFecha(context, true),
                    child: const Text('Elegir'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'Fin: ${_fechaFin.toLocal().toString().split(' ')[0]}'),
                  ),
                  TextButton(
                    onPressed: () => _seleccionarFecha(context, false),
                    child: const Text('Elegir'),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: _estado,
                items: ['activo', 'vencido', 'cancelado'].map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => setState(() => _estado = val ?? 'activo'),
                decoration: const InputDecoration(labelText: 'Estado'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                onPressed: _guardarContrato,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
