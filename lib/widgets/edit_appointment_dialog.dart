import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../theme/theme.dart';

class EditAppointmentDialog extends StatefulWidget {
  final AppointmentModel cita;

  const EditAppointmentDialog({super.key, required this.cita});

  @override
  State<EditAppointmentDialog> createState() => _EditAppointmentDialogState();
}

class _EditAppointmentDialogState extends State<EditAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _fecha;
  TimeOfDay? _hora;
  String? _estado;
  String? _profesionalNombre;
  String? _profesionalId;
  String? _servicioNombre;
  String? _servicioId;

  final List<String> _estados = [
    'reservado',
    'confirmado',
    'cancelado',
    'en camino',
    'cita_realizada',
    'recordatorio',
  ];

  List<Map<String, String>> _profesionales = [];
  List<Map<String, String>> _serviciosFiltrados = [];

  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _fecha = widget.cita.fechaInicio;
    _hora = TimeOfDay.fromDateTime(widget.cita.fechaInicio!);
    _estado = widget.cita.estado;
    _profesionalNombre = widget.cita.nombreProfesional;
    _profesionalId = widget.cita.profesionalId;
    _servicioNombre = widget.cita.servicio;
    _servicioId = widget.cita.servicioId;
    _inicializarDatos();
  }

  Future<void> _inicializarDatos() async {
    await _cargarProfesionales();
    if (_profesionalId != null) {
      await _cargarServiciosPorProfesional(_profesionalId!);
    }
    setState(() => _cargando = false);
  }

  Future<void> _cargarProfesionales() async {
    final profSnap =
        await FirebaseFirestore.instance.collection('profesionales').get();

    _profesionales = profSnap.docs.map((doc) {
      final nombre = '${doc['nombre']} ${doc['apellidos'] ?? ''}'.trim();
      return {
        'id': doc.id,
        'nombre': nombre,
      };
    }).toList();
  }

  Future<void> _cargarServiciosPorProfesional(String profesionalId) async {
    final docSnap = await FirebaseFirestore.instance
        .collection('profesionales')
        .doc(profesionalId)
        .get();

    final servicios = List<String>.from(docSnap.data()?['servicios'] ?? []);

    _serviciosFiltrados = servicios.map((s) {
      final partes = s.split('|');
      final nombre = partes.length > 1 ? partes[1] : s;
      return {
        'id': s, // usamos todo como ID para mantener consistencia
        'nombre': nombre,
      };
    }).toList();

    if (_servicioId != null &&
        _servicioNombre != null &&
        !_serviciosFiltrados.any((s) =>
            s['nombre']?.trim().toLowerCase() ==
            _servicioNombre!.trim().toLowerCase())) {
      _serviciosFiltrados.insert(0, {
        'id': _servicioId!,
        'nombre': _servicioNombre!,
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'MX'),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _seleccionarHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _hora ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _hora = picked);
  }

  Future<void> _guardarCita() async {
    if (!_formKey.currentState!.validate() || _fecha == null || _hora == null)
      return;

    setState(() => _cargando = true);

    final nuevaFecha = DateTime(
      _fecha!.year,
      _fecha!.month,
      _fecha!.day,
      _hora!.hour,
      _hora!.minute,
    );

    try {
      final ref =
          FirebaseFirestore.instance.collection('bookings').doc(widget.cita.id);

      await ref.update({
        'estado': _estado,
        'fecha': nuevaFecha,
        'profesionalNombre': _profesionalNombre,
        'profesionalId': _profesionalId,
        'servicioNombre': _servicioNombre,
        'servicioId': _servicioId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al actualizar la cita: $e')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar cita'),
      content: SizedBox(
        width: 400,
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _estado,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: _estados
                          .map((e) => DropdownMenuItem<String>(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _estado = v),
                      validator: (v) => v == null ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _profesionalNombre,
                      decoration: const InputDecoration(
                          labelText: 'Profesional asignado'),
                      items: _profesionales
                          .map((p) => DropdownMenuItem<String>(
                                value: p['nombre']!,
                                child: Text(p['nombre']!),
                              ))
                          .toList(),
                      onChanged: (val) async {
                        final seleccionado = _profesionales.firstWhere(
                          (p) => p['nombre'] == val,
                        );
                        setState(() {
                          _profesionalNombre = seleccionado['nombre'];
                          _profesionalId = seleccionado['id'];
                        });
                        await _cargarServiciosPorProfesional(_profesionalId!);
                      },
                      validator: (v) => v == null ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _servicioNombre,
                      decoration:
                          const InputDecoration(labelText: 'Servicio asignado'),
                      items: _serviciosFiltrados
                          .map((s) => DropdownMenuItem<String>(
                                value: s['nombre']!,
                                child: Text(s['nombre']!),
                              ))
                          .toList(),
                      onChanged: (val) {
                        final seleccionado = _serviciosFiltrados
                            .firstWhere((s) => s['nombre'] == val);
                        setState(() {
                          _servicioNombre = seleccionado['nombre'];
                          _servicioId = seleccionado['id'];
                        });
                      },
                      validator: (v) => v == null ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _seleccionarFecha,
                            child: InputDecorator(
                              decoration:
                                  const InputDecoration(labelText: 'Fecha'),
                              child: Text(_fecha != null
                                  ? DateFormat('dd/MM/yyyy').format(_fecha!)
                                  : 'Seleccionar'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _seleccionarHora,
                            child: InputDecorator(
                              decoration:
                                  const InputDecoration(labelText: 'Hora'),
                              child: Text(_hora != null
                                  ? _hora!.format(context)
                                  : 'Seleccionar'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: kBrandPurple)),
        ),
        ElevatedButton(
          onPressed: _guardarCita,
          style: ElevatedButton.styleFrom(
            backgroundColor: kBrandPurple,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
