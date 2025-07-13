import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/evento_model.dart';
import '../../models/empresa_model.dart';
import '../../services/evento_service.dart';

class EventoCrudDialog extends StatefulWidget {
  final EventoModel? evento;

  const EventoCrudDialog({super.key, this.evento});

  @override
  State<EventoCrudDialog> createState() => _EventoCrudDialogState();
}

class _EventoCrudDialogState extends State<EventoCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  final _eventoService = EventoService();

  late TextEditingController _nombreCtrl;
  late TextEditingController _direccionCtrl;
  late TextEditingController _observacionesCtrl;

  EmpresaModel? _empresaSeleccionada;
  bool usarDireccionEmpresa = false;

  List<Map<String, dynamic>> asignaciones = [];

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _empresas = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _profesionales = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _servicios = [];

  @override
  void initState() {
    print("DEBUG: EventoCrudDialog se está construyendo");
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.evento?.nombre ?? '');
    _direccionCtrl =
        TextEditingController(text: widget.evento?.ubicacion ?? '');
    _observacionesCtrl =
        TextEditingController(text: widget.evento?.observaciones ?? '');

    if (widget.evento != null && widget.evento!.serviciosAsignados.isNotEmpty) {
      for (final asignacion in widget.evento!.serviciosAsignados) {
        asignaciones.add({
          'fecha': widget.evento!.fecha,
          'servicioId': asignacion['servicioId'],
          'profesionalId': asignacion['profesionalId'],
        });
      }
    }

    _loadFirestoreData(); // ✅ CAMBIO MILITAR: llamado limpio
  }

  Future<void> _loadFirestoreData() async {
    try {
      final snapEmp =
          await FirebaseFirestore.instance.collection('empresas').get();
      final snapProfes =
          await FirebaseFirestore.instance.collection('profesionales').get();
      final snapServs =
          await FirebaseFirestore.instance.collection('services').get();

      // ✅ CAMBIO: solo servicios con categoría 'corporativo' (case-insensitive)
      final filteredServices = snapServs.docs
          .where((doc) => (doc.data()['category']?.toString().toLowerCase() ==
              'corporativo'))
          .toList();

      setState(() {
        _empresas = snapEmp.docs;
        _autoseleccionarEmpresa(); // ✅ CAMBIO MILITAR FINAL
        _profesionales = snapProfes.docs;
        _servicios = filteredServices; // ✅ CAMBIO aplicado correctamente
      });
    } catch (e) {
      debugPrint('Error cargando datos de Firestore: $e');
    }
  }

  void _toggleDireccionEmpresa(bool? value) {
    if (value == null) return;
    setState(() {
      usarDireccionEmpresa = value;
      if (usarDireccionEmpresa && _empresaSeleccionada != null) {
        _direccionCtrl.text = _empresaSeleccionada!.direccion ?? '';
      } else {
        _direccionCtrl.clear();
      }
    });
  }

  void _addAsignacion() {
    setState(() {
      asignaciones.add({'fecha': null, 'servicioId': '', 'profesionalId': ''});
    });
  }

  void _removeAsignacion(int index) {
    setState(() {
      asignaciones.removeAt(index);
    });
  }

  bool get _campoDireccionDeshabilitado => usarDireccionEmpresa;

  void _autoseleccionarEmpresa() {
    if (widget.evento != null && (widget.evento!.empresaId ?? '').isNotEmpty) {
      QueryDocumentSnapshot<Map<String, dynamic>>? empDoc;

      if (_empresas.any((e) => e.id == widget.evento!.empresaId)) {
        empDoc = _empresas.firstWhere((e) => e.id == widget.evento!.empresaId);
      } else if (_empresas.isNotEmpty) {
        empDoc = _empresas.first;
      } else {
        throw Exception("Empresa no encontrada");
      }

      setState(() {
        _empresaSeleccionada = EmpresaModel.fromMap(empDoc!.data(), empDoc.id);
        final direccionEmpresa = _empresaSeleccionada?.direccion?.trim();
        final direccionEvento = widget.evento!.ubicacion.trim();
        if (direccionEmpresa != null && direccionEmpresa == direccionEvento) {
          usarDireccionEmpresa = true;
          _direccionCtrl.text = direccionEmpresa;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 720,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Formulario de Evento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nombreCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _empresaSeleccionada?.empresaId,
                        decoration: const InputDecoration(labelText: 'Empresa'),
                        items: _empresas
                            .map((emp) => DropdownMenuItem(
                                  value: emp.id,
                                  child: Text(emp.data().containsKey('nombre')
                                      ? emp['nombre']
                                      : emp.id),
                                ))
                            .toList(),
                        onChanged: (value) {
                          final empresa =
                              _empresas.firstWhere((e) => e.id == value);
                          setState(() {
                            _empresaSeleccionada = EmpresaModel.fromMap(
                                empresa.data(), empresa.id);
                            if (usarDireccionEmpresa) {
                              _direccionCtrl.text =
                                  _empresaSeleccionada!.direccion ?? '';
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _direccionCtrl,
                        enabled: !_campoDireccionDeshabilitado,
                        decoration: const InputDecoration(
                          labelText: 'Dirección del evento',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: const Text(
                          'Usar dirección de la empresa',
                          style: TextStyle(fontSize: 13),
                        ),
                        value: usarDireccionEmpresa,
                        onChanged: _toggleDireccionEmpresa,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Asignaciones por fecha:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: List.generate(asignaciones.length, (index) {
                    final asignacion = asignaciones[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: asignacion['fecha'] ??
                                            DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          asignacion['fecha'] = picked;
                                        });
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                          labelText: 'Fecha'),
                                      child: Text(
                                        asignacion['fecha'] != null
                                            ? '${asignacion['fecha'].day.toString().padLeft(2, '0')}/${asignacion['fecha'].month.toString().padLeft(2, '0')}/${asignacion['fecha'].year}'
                                            : 'Seleccionar fecha',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.miscellaneous_services,
                                    size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _servicios.any((s) =>
                                            s.id == asignacion['servicioId'])
                                        ? asignacion['servicioId']
                                        : null,
                                    decoration: const InputDecoration(
                                        labelText: 'Servicio'),
                                    items: _servicios
                                        .map((s) => DropdownMenuItem(
                                              value: s.id,
                                              child: Text(
                                                s.data()['name'] ?? '',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        asignacion['servicioId'] = value!;
                                      });
                                    },
                                    menuMaxHeight: 300,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _profesionales.any((p) =>
                                            p.id == asignacion['profesionalId'])
                                        ? asignacion['profesionalId']
                                        : null,
                                    decoration: const InputDecoration(
                                        labelText: 'Profesional'),
                                    items: _profesionales
                                        .map((p) => DropdownMenuItem(
                                              value: p.id,
                                              child: Text(
                                                p.data()['nombre'] ?? '',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        asignacion['profesionalId'] = value!;
                                      });
                                    },
                                    menuMaxHeight: 300,
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () => _removeAsignacion(index),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addAsignacion,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar asignación'),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _observacionesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Observaciones'),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _guardarEvento();
                        Navigator.of(context).pop(
                            true); // ✅ CORREGIDO  // ✅ CAMBIO: cierre con recarga
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _guardarEvento() async {
    debugPrint('🧩 MÉTODO _guardarEvento INVOCADO');

    if (_empresaSeleccionada == null) return;

    final asignacionesValidas = asignaciones.where((a) {
      return a['fecha'] != null &&
          a['servicioId'].toString().isNotEmpty &&
          a['profesionalId'].toString().isNotEmpty;
    }).toList();

    if (asignacionesValidas.isEmpty) return;

    final id = widget.evento?.id ??
        FirebaseFirestore.instance.collection('eventos').doc().id;
    final fechaPrincipal = asignacionesValidas.first['fecha'] as DateTime;

    final serviciosAsignados = asignacionesValidas.map((a) {
      final servicio = _servicios.firstWhere((s) => s.id == a['servicioId']);
      final profesional =
          _profesionales.firstWhere((p) => p.id == a['profesionalId']);

      return {
        'servicioId': a['servicioId'].toString(),
        'servicioNombre': servicio.data()['name'] ?? '',
        'profesionalId': a['profesionalId'].toString(),
        'profesionalNombre': profesional.data()['nombre'] ?? '',
        'fechaAsignada': (a['fecha'] as DateTime).toIso8601String(),
        // ✅ SÓLO incluir si existen: evita sobrescribir horarios al editar
        if (a['horaInicio'] != null) 'horaInicio': a['horaInicio'],
        if (a['horaFin'] != null) 'horaFin': a['horaFin'],
        if (a['ubicacion'] != null) 'ubicacion': a['ubicacion'],
      };
    }).toList();

    debugPrint("🔥 SERVICIOS ASIGNADOS ANTES DE GUARDAR:");
    for (var s in serviciosAsignados) {
      debugPrint(s.toString());
    }

    final evento = EventoModel(
      id: id,
      eventoId: id,
      nombre: _nombreCtrl.text.trim(),
      empresa: _empresaSeleccionada!.nombre,
      empresaId: _empresaSeleccionada!.empresaId,
      ubicacion: _direccionCtrl.text.trim(),
      fecha: fechaPrincipal,
      estado: widget.evento?.estado ?? 'activo',
      observaciones: _observacionesCtrl.text.trim(),
      fechaCreacion: DateTime.now(),
      serviciosAsignados:
          serviciosAsignados.map((e) => Map<String, dynamic>.from(e)).toList(),
    );

    debugPrint("🧾 MAP A GUARDAR => ${evento.toMap()}");

    try {
      if (widget.evento == null) {
        await _eventoService.createEvento(evento);
      } else {
        await _eventoService.updateEvento(evento);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar el evento.')),
        );
      }
    }
  }
}
