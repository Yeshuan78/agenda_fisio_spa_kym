// 📁 screens/campanas/campana_form.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/campana_model.dart';
import 'package:agenda_fisio_spa_kym/services/campana_service.dart';
import 'package:uuid/uuid.dart';

class CampanaForm extends StatefulWidget {
  final CampanaModel? campanaExistente;

  const CampanaForm({super.key, this.campanaExistente});

  @override
  State<CampanaForm> createState() => _CampanaFormState();
}

class _CampanaFormState extends State<CampanaForm> {
  final _formKey = GlobalKey<FormState>();
  final _campanaService = CampanaService();

  late TextEditingController _tituloCtrl;
  late TextEditingController _mensajeCtrl;
  late TextEditingController _destinatariosCtrl;

  String _tipo = 'whatsapp';

  @override
  void initState() {
    super.initState();
    final c = widget.campanaExistente;
    _tituloCtrl = TextEditingController(text: c?.titulo ?? '');
    _mensajeCtrl = TextEditingController(text: c?.mensaje ?? '');
    _destinatariosCtrl = TextEditingController(
      text: c?.destinatarios.join(', ') ?? '',
    );
    _tipo = c?.tipo ?? 'whatsapp';
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _mensajeCtrl.dispose();
    _destinatariosCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final nuevo = CampanaModel(
      id: widget.campanaExistente?.id ?? const Uuid().v4(),
      titulo: _tituloCtrl.text.trim(),
      mensaje: _mensajeCtrl.text.trim(),
      tipo: _tipo,
      destinatarios: _destinatariosCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      fechaCreacion: DateTime.now(),
      fechaEnvio: null,
      estado: 'pendiente',
    );

    if (widget.campanaExistente == null) {
      await _campanaService.crearCampana(nuevo);
    } else {
      await _campanaService.actualizarCampana(nuevo);
    }

    if (context.mounted) Navigator.of(context).pop();
  }

  void _simularEnvio() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Simulando envío de ${_tipo.toUpperCase()}...'),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.campanaExistente == null ? 'Nueva Campaña' : 'Editar Campaña'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _mensajeCtrl,
                decoration: const InputDecoration(labelText: 'Mensaje'),
                maxLines: 4,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              DropdownButtonFormField<String>(
                value: _tipo,
                items: const [
                  DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                  DropdownMenuItem(value: 'correo', child: Text('Correo')),
                ],
                onChanged: (value) =>
                    setState(() => _tipo = value ?? 'whatsapp'),
                decoration: const InputDecoration(labelText: 'Tipo de campaña'),
              ),
              TextFormField(
                controller: _destinatariosCtrl,
                decoration: const InputDecoration(
                    labelText: 'Destinatarios (separados por coma)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _simularEnvio,
          child: const Text('Simular Envío'),
        ),
        TextButton(
          onPressed: _guardar,
          child: const Text('Guardar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
