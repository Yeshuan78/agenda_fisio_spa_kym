import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class AppointmentDialog extends StatefulWidget {
  final DateTime? fechaSeleccionada;
  final List<DocumentSnapshot> listaClientes;
  final List<DocumentSnapshot> listaProfesionales;
  final List<DocumentSnapshot> listaServicios;

  const AppointmentDialog({
    super.key,
    this.fechaSeleccionada,
    required this.listaClientes,
    required this.listaProfesionales,
    required this.listaServicios,
  });

  @override
  State<AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<AppointmentDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _clienteCtrl = TextEditingController();
  final TextEditingController _statusCtrl =
      TextEditingController(text: 'Reservado');

  List<DocumentSnapshot> _sugerenciasClientes = [];
  List<DocumentSnapshot> _serviciosFiltrados = [];

  String? _profesionalId;
  String? _servicioId;
  String? _clienteId;
  DateTime _fecha = DateTime.now();
  int? _duracionMinutos;

  @override
  void initState() {
    super.initState();
    _fecha = widget.fechaSeleccionada ?? DateTime.now();
  }

  void _filtrarClientes(String query) {
    _sugerenciasClientes = widget.listaClientes.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final nombre = (data['nombre'] ?? '').toString().toLowerCase();
      final apellidos = (data['apellidos'] ?? '').toString().toLowerCase();
      return '$nombre $apellidos'.contains(query.toLowerCase());
    }).toList();
  }

  void _filtrarServicios(String profesionalId) {
    final doc =
        widget.listaProfesionales.firstWhere((e) => e.id == profesionalId);
    final data = doc.data() as Map<String, dynamic>;
    final serviciosIds = (data['servicios'] as List?)
        ?.map((e) => e is String && e.contains("|") ? e.split("|")[0] : e)
        .toSet();
    _serviciosFiltrados = widget.listaServicios
        .where((s) => serviciosIds?.contains(s.id) ?? false)
        .toList();
  }

  Future<void> _editarFechaHora() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'MX'),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fecha),
    );

    if (pickedTime != null) {
      setState(() {
        _fecha = DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
            pickedTime.hour, pickedTime.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Crear Cita",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Profesional
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Profesional"),
                value: _profesionalId,
                items: widget.listaProfesionales.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nombre =
                      "${data["nombre"] ?? ""} ${data["apellidos"] ?? ""}"
                          .trim();
                  return DropdownMenuItem(value: doc.id, child: Text(nombre));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _profesionalId = val;
                    _filtrarServicios(val!);
                  });
                },
                validator: (val) => val == null ? "Requerido" : null,
              ),
              const SizedBox(height: 12),
              // Servicio
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Servicio"),
                value: _servicioId,
                items: _serviciosFiltrados.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DropdownMenuItem(
                      value: doc.id, child: Text(data["name"] ?? ""));
                }).toList(),
                onChanged: (val) => setState(() => _servicioId = val),
                validator: (val) => val == null ? "Requerido" : null,
              ),
              const SizedBox(height: 12),
              // Cliente
              TextFormField(
                controller: _clienteCtrl,
                decoration: const InputDecoration(labelText: "Cliente"),
                onChanged: (val) {
                  setState(() {
                    _filtrarClientes(val);
                  });
                },
                validator: (val) =>
                    val == null || val.isEmpty ? "Requerido" : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _abrirFormularioNuevoCliente(
                    context,
                    setState,
                    _clienteCtrl,
                    widget.listaClientes,
                    (String nuevoId) => _clienteId = nuevoId,
                  ),
                  child: const Text("+ Crear nuevo cliente"),
                ),
              ),
              if (_sugerenciasClientes.isNotEmpty)
                ..._sugerenciasClientes.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nombre =
                      "${data['nombre'] ?? ''} ${data['apellidos'] ?? ''}"
                          .trim();
                  return ListTile(
                    title: Text(nombre),
                    onTap: () {
                      setState(() {
                        _clienteCtrl.text = nombre;
                        _clienteId = doc.id;
                        _sugerenciasClientes.clear();
                      });
                    },
                  );
                }),
              const SizedBox(height: 16),
              // Fecha y hora
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat("dd/MM/yyyy HH:mm").format(_fecha)),
                onPressed: _editarFechaHora,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              // Botón Guardar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _guardarCita,
                child: const Text("Guardar Cita"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardarCita() async {
    if (!_formKey.currentState!.validate()) return;

    final firestore = FirebaseFirestore.instance;

    final servicioDoc =
        _serviciosFiltrados.firstWhere((d) => d.id == _servicioId);
    final servicioData = servicioDoc.data() as Map<String, dynamic>;
    final servicioNombre = servicioData['name'] ?? '';
    _duracionMinutos = servicioData['duracion'] ?? 30;

    final nuevaCita = {
      "profesionalId": _profesionalId,
      "serviceId": _servicioId,
      "serviceName": servicioNombre,
      "clientId": _clienteId ?? "",
      "clientName": _clienteCtrl.text.trim(),
      "status": _statusCtrl.text.trim(),
      "date": DateFormat("yyyy-MM-dd HH:mm").format(_fecha),
      "duracion": _duracionMinutos,
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    };

    await firestore.collection('bookings').add(nuevaCita);
    if (!context.mounted) return;
    Navigator.pop(context, true);
  }
}

// [Sección 1.3] - Formulario emergente para crear cliente nuevo
Future<void> _abrirFormularioNuevoCliente(
  BuildContext context,
  void Function(void Function()) setStateDialog,
  TextEditingController clientCtrl,
  List<DocumentSnapshot> listaClientes,
  void Function(String idNuevoCliente) onClienteCreado,
) async {
  final formKey = GlobalKey<FormState>();
  final nombreCtrl = TextEditingController();
  final apellidosCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final calleCtrl = TextEditingController();
  final numExtCtrl = TextEditingController();
  final numIntCtrl = TextEditingController();
  final codigoPostalCtrl = TextEditingController();
  final coloniaCtrl = TextEditingController();
  final empresaCtrl = TextEditingController();
  String? alcaldiaSeleccionada;

  final List<String> _alcaldias = [
    'Álvaro Obregón',
    'Azcapotzalco',
    'Benito Juárez',
    'Coyoacán',
    'Cuajimalpa de Morelos',
    'Cuauhtémoc',
    'Gustavo A. Madero',
    'Iztacalco',
    'Iztapalapa',
    'Magdalena Contreras',
    'Milpa Alta',
    'Tláhuac',
    'Tlalpan',
    'Venustiano Carranza',
    'Xochimilco',
  ];

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Nuevo Cliente"),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
              ),
              TextFormField(
                controller: apellidosCtrl,
                decoration: const InputDecoration(labelText: "Apellidos"),
                validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
              ),
              TextFormField(
                controller: correoCtrl,
                decoration: const InputDecoration(labelText: "Correo"),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  final pat = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return pat.hasMatch(v) ? null : 'Inválido';
                },
              ),
              TextFormField(
                controller: telefonoCtrl,
                decoration: const InputDecoration(labelText: "Teléfono"),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: calleCtrl,
                decoration: const InputDecoration(labelText: "Calle"),
                validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
              ),
              TextFormField(
                controller: numExtCtrl,
                decoration: const InputDecoration(labelText: "Número Exterior"),
                validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
              ),
              TextFormField(
                controller: numIntCtrl,
                decoration: const InputDecoration(
                    labelText: "Número Interior (opcional)"),
              ),
              TextFormField(
                controller: codigoPostalCtrl,
                decoration: const InputDecoration(labelText: "Código Postal"),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
              ),
              TextFormField(
                controller: coloniaCtrl,
                decoration: const InputDecoration(labelText: "Colonia"),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Alcaldía"),
                value: alcaldiaSeleccionada,
                items: _alcaldias
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (v) => alcaldiaSeleccionada = v,
                validator: (v) => v == null ? "Requerido" : null,
              ),
              TextFormField(
                controller: empresaCtrl,
                decoration:
                    const InputDecoration(labelText: "Empresa (opcional)"),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kBrandPurple),
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            final idUsuario = const Uuid().v4();
            final newClient = {
              'idUsuario': idUsuario,
              'nombre': nombreCtrl.text.trim(),
              'apellidos': apellidosCtrl.text.trim(),
              'correo': correoCtrl.text.trim(),
              'telefono': telefonoCtrl.text.trim(),
              'calle': calleCtrl.text.trim(),
              'numeroExterior': numExtCtrl.text.trim(),
              'numeroInterior': numIntCtrl.text.trim(),
              'codigoPostal': codigoPostalCtrl.text.trim(),
              'colonia': coloniaCtrl.text.trim(),
              'empresa': empresaCtrl.text.trim(),
              'alcaldia': alcaldiaSeleccionada ?? '',
              'createdAt': FieldValue.serverTimestamp(),
            };
            final docRef = await FirebaseFirestore.instance
                .collection('clients')
                .add(newClient);
            final fullName =
                "${nombreCtrl.text.trim()} ${apellidosCtrl.text.trim()}";
            clientCtrl.text = fullName;
            onClienteCreado(docRef.id);
            final nuevoDoc = await docRef.get();
            setStateDialog(() {
              listaClientes.add(nuevoDoc);
            });
            if (!context.mounted) return;
            Navigator.pop(ctx);
          },
          child: const Text("Guardar"),
        ),
      ],
    ),
  );
}
