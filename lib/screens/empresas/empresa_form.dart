import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/empresa_model.dart';
import '../../services/empresa_service.dart';
import '../../theme/theme.dart';

class EmpresaForm extends StatefulWidget {
  final EmpresaModel? empresa;
  final VoidCallback onSaved;

  const EmpresaForm({
    super.key,
    this.empresa,
    required this.onSaved,
  });

  @override
  State<EmpresaForm> createState() => _EmpresaFormState();
}

class _EmpresaFormState extends State<EmpresaForm> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _rfcCtrl = TextEditingController();
  final _razonCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _cpCtrl = TextEditingController();
  final _coloniaCtrl = TextEditingController();
  final _alcaldiaCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  final _contactoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();

  String _estado = 'activo';
  List<Map<String, String>> _contactos = [];

  @override
  void initState() {
    super.initState();
    final empresa = widget.empresa;
    if (empresa != null) {
      _nombreCtrl.text = empresa.nombre;
      _rfcCtrl.text = empresa.rfc;
      _razonCtrl.text = empresa.razonSocial ?? '';
      _direccionCtrl.text = empresa.direccion ?? '';
      _cpCtrl.text = empresa.codigoPostal ?? '';
      _coloniaCtrl.text = empresa.colonia ?? '';
      _alcaldiaCtrl.text = empresa.alcaldia ?? '';
      _ciudadCtrl.text = empresa.ciudad ?? '';
      _contactoCtrl.text = empresa.contacto;
      _telefonoCtrl.text = empresa.telefono;
      _correoCtrl.text = empresa.correo;
      _estado = empresa.estado;
      _contactos = List.from(empresa.contactos);
    } else {
      _contactos = [
        {'nombre': '', 'correo': '', 'area': ''}
      ];
    }
  }

  void _agregarContacto() {
    setState(() {
      _contactos.add({'nombre': '', 'correo': '', 'area': ''});
    });
  }

  void _eliminarContacto(int index) {
    setState(() {
      _contactos.removeAt(index);
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.empresa?.empresaId ?? const Uuid().v4();

    final nuevaEmpresa = EmpresaModel(
      empresaId: id,
      nombre: _nombreCtrl.text.trim(),
      rfc: _rfcCtrl.text.trim(),
      razonSocial: _razonCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      codigoPostal: _cpCtrl.text.trim(),
      colonia: _coloniaCtrl.text.trim(),
      alcaldia: _alcaldiaCtrl.text.trim(),
      ciudad: _ciudadCtrl.text.trim(),
      contacto: _contactoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      correo: _correoCtrl.text.trim(),
      estado: _estado,
      contactos: _contactos,
      fechaCreacion: widget.empresa?.fechaCreacion ?? DateTime.now(),
    );

    final service = EmpresaService();
    if (widget.empresa == null) {
      await service.crearEmpresa(nuevaEmpresa);
    } else {
      await service.updateEmpresa(nuevaEmpresa); // ✅ CORREGIDO
    }

    widget.onSaved();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.empresa == null ? 'Nueva Empresa' : 'Editar Empresa',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Nombre empresa'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _rfcCtrl,
                  decoration: const InputDecoration(labelText: 'RFC'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _razonCtrl,
                  decoration: const InputDecoration(labelText: 'Razón social'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _estado,
                  items: const [
                    DropdownMenuItem(value: 'activo', child: Text('Activo')),
                    DropdownMenuItem(
                        value: 'inactivo', child: Text('Inactivo')),
                  ],
                  decoration: const InputDecoration(labelText: 'Estado'),
                  onChanged: (value) {
                    if (value != null) setState(() => _estado = value);
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _direccionCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Calle y número'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _cpCtrl,
                  decoration: const InputDecoration(labelText: 'Código postal'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _coloniaCtrl,
                  decoration: const InputDecoration(labelText: 'Colonia'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _alcaldiaCtrl,
                  decoration: const InputDecoration(labelText: 'Alcaldía'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _ciudadCtrl,
                  decoration: const InputDecoration(labelText: 'Ciudad'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _contactoCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Contacto principal'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _telefonoCtrl,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _correoCtrl,
                  decoration: const InputDecoration(labelText: 'Correo'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Contactos',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._contactos.asMap().entries.map((entry) {
                  final i = entry.key;
                  final contacto = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      color: kBackgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: contacto['nombre'],
                                    decoration: const InputDecoration(
                                        labelText: 'Nombre'),
                                    onChanged: (v) =>
                                        _contactos[i]['nombre'] = v,
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Requerido'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _eliminarContacto(i),
                                )
                              ],
                            ),
                            TextFormField(
                              initialValue: contacto['correo'],
                              decoration:
                                  const InputDecoration(labelText: 'Correo'),
                              onChanged: (v) => _contactos[i]['correo'] = v,
                            ),
                            TextFormField(
                              initialValue: contacto['area'],
                              decoration:
                                  const InputDecoration(labelText: 'Área'),
                              onChanged: (v) => _contactos[i]['area'] = v,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: _agregarContacto,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar contacto'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar empresa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrandPurple,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
