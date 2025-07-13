import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/professional_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/ui/paso_header.dart';
import 'package:agenda_fisio_spa_kym/screens/profesionales/widgets/tabs/professional_tab_datos.dart';
import 'package:agenda_fisio_spa_kym/screens/profesionales/widgets/tabs/professional_tab_servicios.dart';
import 'package:agenda_fisio_spa_kym/screens/profesionales/widgets/tabs/professional_tab_horario.dart';
import 'package:agenda_fisio_spa_kym/widgets/ui/step_footer_buttons.dart';

class ProfessionalCrudDialog extends StatefulWidget {
  final ProfessionalModel? professional;
  final List<Map<String, dynamic>> serviciosDisponibles;

  const ProfessionalCrudDialog({
    super.key,
    this.professional,
    required this.serviciosDisponibles,
  });

  @override
  State<ProfessionalCrudDialog> createState() => _ProfessionalCrudDialogState();
}

class _ProfessionalCrudDialogState extends State<ProfessionalCrudDialog> {
  int pasoActual = 0;

  late String nombre;
  late String apellidos;
  late String sexo;
  late String cedulaProfesional;
  late String email;
  late String telefono;
  late String fotoUrl;
  late String notas;
  late List<String> especialidades;
  late List<String> idiomas;
  late String sucursalId;
  late List<Map<String, dynamic>> horarios;
  late List<Map<String, dynamic>> disponibilidad;
  late List<Map<String, dynamic>> servicios;
  late List<String> serviciosSeleccionados;
  late bool estado;
  late DateTime fechaAlta;

  bool errorNombre = false;
  bool errorApellidos = false;
  bool errorEmail = false;
  bool errorTelefono = false;

  bool _guardando = false;
  List<String> _serviciosAntes = [];

  @override
  void initState() {
    super.initState();
    final p = widget.professional;
    nombre = p?.nombre ?? '';
    apellidos = p?.apellidos ?? '';
    sexo = p?.sexo ?? '';
    cedulaProfesional = p?.cedulaProfesional ?? '';
    email = p?.email ?? '';
    telefono = p?.telefono ?? '';
    fotoUrl = p?.fotoUrl ?? '';
    notas = p?.notas ?? '';
    especialidades = List<String>.from(p?.especialidades ?? []);
    idiomas = List<String>.from(p?.idiomas ?? []);
    sucursalId = p?.sucursalId ?? '';
    horarios = List<Map<String, dynamic>>.from(p?.horarios ?? []);
    disponibilidad = List<Map<String, dynamic>>.from(p?.disponibilidad ?? []);
    servicios = p?.servicios != null
        ? List<Map<String, dynamic>>.from(p!.servicios)
        : List<Map<String, dynamic>>.from(
            widget.serviciosDisponibles); // ✅ CAMBIO
    print(
        '🟡 CREANDO: serviciosDisponibles => ${widget.serviciosDisponibles.length}');
    print('🟡 servicios => ${servicios.length}');
    serviciosSeleccionados =
        servicios.map((s) => s['serviceId'] ?? '').whereType<String>().toList();
    estado = p?.estado ?? true;
    fechaAlta = p?.fechaAlta ?? DateTime.now();

    _serviciosAntes = List<String>.from(serviciosSeleccionados);

    if (p != null && p.id.isNotEmpty) {
      _cargarCalendarioDesdeFirestore(p.id);
    }
  }

  void _cargarCalendarioDesdeFirestore(String id) async {
    final snap = await FirebaseFirestore.instance
        .collection('calendarios')
        .doc(id)
        .get();

    final data = snap.data();
    if (data != null && mounted) {
      setState(() {
        disponibilidad =
            List<Map<String, dynamic>>.from(data['availableDays'] ?? []);
      });
    }
  }

  Future<void> _vincularServiciosEnFirestore(
      String profesionalId, List<Map<String, dynamic>> nuevosServicios) async {
    final firestore = FirebaseFirestore.instance;

    final nuevosIds = nuevosServicios
        .map((s) => s['serviceId'] ?? '')
        .whereType<String>()
        .toList();
    final eliminados = _serviciosAntes.where((id) => !nuevosIds.contains(id));
    final agregados = nuevosIds.where((id) => !_serviciosAntes.contains(id));

    for (final serviceId in agregados) {
      final ref = firestore.collection('services').doc(serviceId);
      final snap = await ref.get();
      if (!snap.exists) continue;

      final listaActual =
          List<String>.from(snap.data()?['professionalIds'] ?? []);
      if (!listaActual.contains(profesionalId)) {
        listaActual.add(profesionalId);
        await ref.update({'professionalIds': listaActual});
      }
    }

    for (final serviceId in eliminados) {
      final ref = firestore.collection('services').doc(serviceId);
      final snap = await ref.get();
      if (!snap.exists) continue;

      final listaActual =
          List<String>.from(snap.data()?['professionalIds'] ?? []);
      if (listaActual.contains(profesionalId)) {
        listaActual.remove(profesionalId);
        await ref.update({'professionalIds': listaActual});
      }
    }
  }

  void _guardar() async {
    setState(() => _guardando = true);

    try {
      final db = FirebaseFirestore.instance;
      final docRef = widget.professional != null
          ? db.collection('profesionales').doc(widget.professional!.id)
          : db.collection('profesionales').doc();

      final profesionalId = docRef.id;

      final serviciosCompletos = widget.serviciosDisponibles
          .where((s) => serviciosSeleccionados.contains(s['serviceId']))
          .map((s) => {
                'serviceId': s['serviceId'],
                'name': s['name'] ?? '',
                'category': s['category'] ?? '',
                'duracion': s['duration']?.toString() ?? '',
                'notas': s['description'] ?? '',
              })
          .toList();

      final profesional = ProfessionalModel(
        id: profesionalId,
        professionalId: profesionalId,
        nombre: nombre,
        apellidos: apellidos,
        sexo: sexo,
        cedulaProfesional: cedulaProfesional,
        email: email,
        telefono: telefono,
        fotoUrl: fotoUrl,
        notas: notas,
        especialidades: especialidades,
        idiomas: idiomas,
        sucursalId: sucursalId,
        horarios: horarios,
        disponibilidad: disponibilidad,
        servicios: serviciosCompletos,
        estado: estado,
        fechaAlta: fechaAlta,
      );

      await docRef.set(profesional.toJson());

      await db.collection('calendarios').doc(profesionalId).set({
        'calendarId': profesionalId, // ✅ Único cambio autorizado
        'availableDays': disponibilidad,
        'calendarName': '$nombre $apellidos Calendar',
        'profesionalId': profesionalId,
      });

      await _vincularServiciosEnFirestore(profesionalId, serviciosCompletos);

      if (mounted) Navigator.of(context).pop(profesional);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: \$e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Widget _contenidoPaso() {
    switch (pasoActual) {
      case 0:
        return ProfessionalTabDatos(
          nombre: nombre,
          apellidos: apellidos,
          sexo: sexo,
          cedulaProfesional: cedulaProfesional,
          email: email,
          telefono: telefono,
          fotoUrl: fotoUrl,
          notas: notas,
          estado: estado,
          fechaAlta: fechaAlta,
          especialidades: especialidades,
          onChanged: ({
            String? nombre,
            String? apellidos,
            String? sexo,
            String? cedulaProfesional,
            String? fotoUrl,
            String? notas,
            List<String>? especialidades,
            String? email,
            String? telefono,
          }) {
            setState(() {
              if (nombre != null) this.nombre = nombre;
              if (apellidos != null) this.apellidos = apellidos;
              if (sexo != null) this.sexo = sexo;
              if (cedulaProfesional != null) {
                this.cedulaProfesional = cedulaProfesional;
              }
              if (fotoUrl != null) this.fotoUrl = fotoUrl;
              if (notas != null) this.notas = notas;
              if (especialidades != null) this.especialidades = especialidades;
              if (email != null) this.email = email;
              if (telefono != null) this.telefono = telefono;
            });
          },
        );
      case 1:
        return ProfessionalTabServicios(
          servicios: servicios,
          serviciosSeleccionados: serviciosSeleccionados,
          onServiciosSeleccionados: (seleccionados) {
            setState(() {
              serviciosSeleccionados = seleccionados;
              servicios = widget.serviciosDisponibles
                  .where((s) => seleccionados.contains(s['serviceId']))
                  .toList();
            });
          },
        );
      case 2:
        return ProfessionalTabHorario(
          disponibilidad: disponibilidad,
          onChanged: (nueva) => setState(() => disponibilidad = nueva),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.professional == null
                  ? 'Agregar Profesional'
                  : 'Editar Profesional',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 30),
            PasoHeader(
              titulo: pasoActual == 0
                  ? '📄 Paso 1: Datos personales'
                  : pasoActual == 1
                      ? '🧰 Paso 2: Servicios ofrecidos'
                      : '⏰ Paso 3: Horarios y bloqueos',
            ),
            const SizedBox(height: 12),
            Expanded(child: _contenidoPaso()),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                Row(
                  children: [
                    Switch(
                      value: estado,
                      onChanged: (val) => setState(() => estado = val),
                    ),
                    Text(estado ? 'Activo' : 'Inactivo'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            StepFooterButtons(
              mostrarAtras: pasoActual > 0,
              mostrarSiguiente: pasoActual < 2,
              mostrarGuardar: pasoActual == 2,
              isSaving: _guardando,
              onBack: () => setState(() => pasoActual--),
              onNext: () {
                final esNuevo = widget.professional == null;

                if (pasoActual == 0 && esNuevo) {
                  setState(() {
                    errorNombre = nombre.trim().isEmpty;
                    errorApellidos = apellidos.trim().isEmpty;
                    errorEmail = email.trim().isEmpty || !email.contains('@');
                    errorTelefono = telefono.trim().isEmpty;
                  });

                  if (errorNombre ||
                      errorApellidos ||
                      errorEmail ||
                      errorTelefono) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Completa todos los datos antes de continuar.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                }

                if (pasoActual == 1 &&
                    esNuevo &&
                    serviciosSeleccionados.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecciona al menos un servicio.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                if (pasoActual < 2) {
                  setState(() => pasoActual++);
                }
              },
              onGuardar: _guardar,
            ),
          ],
        ),
      ),
    );
  }
}
