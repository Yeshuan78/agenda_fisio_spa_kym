// [evento_crud_dialog_premium.dart]
// 📁 Ubicación: /lib/widgets/eventos/evento_crud_dialog_premium.dart
// 🎯 OBJETIVO: Coordinador principal premium manteniendo lógica exacta del original

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/evento_model.dart';
import 'package:agenda_fisio_spa_kym/models/empresa_model.dart';
import 'package:agenda_fisio_spa_kym/services/evento_service.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/components/evento_form_header.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/components/evento_basic_info_section.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/components/evento_horario_section.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/components/evento_asignaciones_section.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/components/evento_form_actions.dart';

class EventoCrudDialogPremium extends StatefulWidget {
  final EventoModel? evento;

  const EventoCrudDialogPremium({super.key, this.evento});

  @override
  State<EventoCrudDialogPremium> createState() => _EventoCrudDialogPremiumState();
}

class _EventoCrudDialogPremiumState extends State<EventoCrudDialogPremium>
    with TickerProviderStateMixin {
  
  // ✅ MANTENER todas las variables del archivo original EXACTO
  final _formKey = GlobalKey<FormState>();
  final _eventoService = EventoService(); // ✅ Servicio real

  // ✅ COPIAR EXACTO controllers del archivo original líneas 50-55
  late TextEditingController _nombreCtrl;
  late TextEditingController _direccionCtrl;
  late TextEditingController _observacionesCtrl;

  EmpresaModel? _empresaSeleccionada;
  bool usarDireccionEmpresa = false;
  List<Map<String, dynamic>> asignaciones = [];

  // ✅ MANTENER listas Firestore EXACTAS del archivo original
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _empresas = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _profesionales = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _servicios = [];

  // ✅ AGREGAR horarios por defecto para el evento
  String _horarioEventoInicio = '09:00';
  String _horarioEventoFin = '15:00';

  // Controladores de animación premium
  late AnimationController _dialogController;
  late AnimationController _stepController;
  late Animation<double> _dialogAnimation;
  late Animation<double> _stepAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    
    // ✅ MANTENER inicialización EXACTA del archivo original líneas 60-75
    _nombreCtrl = TextEditingController(text: widget.evento?.nombre ?? '');
    _direccionCtrl = TextEditingController(text: widget.evento?.ubicacion ?? '');
    _observacionesCtrl = TextEditingController(text: widget.evento?.observaciones ?? '');

    if (widget.evento != null && widget.evento!.serviciosAsignados.isNotEmpty) {
      for (final asignacion in widget.evento!.serviciosAsignados) {
        asignaciones.add({
          'fecha': widget.evento!.fecha,
          'servicioId': asignacion['servicioId'],
          'profesionalId': asignacion['profesionalId'],
          // ✅ AGREGAR horarios por defecto si no existen
          'horaInicio': asignacion['horaInicio'] ?? '09:00',
          'horaFin': asignacion['horaFin'] ?? '15:00',
        });
      }
    }
    
    _loadFirestoreData();
  }

  void _initAnimations() {
    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _stepController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _dialogAnimation = CurvedAnimation(
      parent: _dialogController,
      curve: Curves.easeOutCubic,
    );
    _stepAnimation = CurvedAnimation(
      parent: _stepController,
      curve: Curves.easeInOut,
    );

    _dialogController.forward();
  }

  // ✅ MANTENER _loadFirestoreData EXACTO del archivo original líneas 80-100
  Future<void> _loadFirestoreData() async {
    try {
      final snapEmp = await FirebaseFirestore.instance.collection('empresas').get();
      final snapProfes = await FirebaseFirestore.instance.collection('profesionales').get();
      final snapServs = await FirebaseFirestore.instance.collection('services').get();

      // ✅ CAMBIO: solo servicios con categoría 'corporativo' (case-insensitive)
      final filteredServices = snapServs.docs
          .where((doc) => (doc.data()['category']?.toString().toLowerCase() == 'corporativo'))
          .toList();

      setState(() {
        _empresas = snapEmp.docs;
        _profesionales = snapProfes.docs;
        _servicios = filteredServices;
      });

      // ✅ COPIAR EXACTO _autoseleccionarEmpresa del archivo original
      _autoseleccionarEmpresa();
    } catch (e) {
      debugPrint('Error cargando datos de Firestore: $e');
    }
  }

  // ✅ COPIAR EXACTO método _autoseleccionarEmpresa del archivo original líneas 550-570
  void _autoseleccionarEmpresa() {
    if (widget.evento != null && (widget.evento!.empresaId ?? '').isNotEmpty) {
      QueryDocumentSnapshot<Map<String, dynamic>>? empDoc;

      if (_empresas.any((e) => e.id == widget.evento!.empresaId)) {
        empDoc = _empresas.firstWhere((e) => e.id == widget.evento!.empresaId);
      } else if (_empresas.isNotEmpty) {
        empDoc = _empresas.first;
      } else {
        return;
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

  // ✅ MANTENER método _toggleDireccionEmpresa EXACTO del archivo original
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

  // ✅ MANTENER métodos de asignaciones EXACTOS del archivo original
  void _addAsignacion() {
    setState(() {
      asignaciones.add({
        'fecha': null,
        'servicioId': '',
        'profesionalId': '',
        'horaInicio': _horarioEventoInicio,
        'horaFin': _horarioEventoFin,
      });
    });
  }

  void _removeAsignacion(int index) {
    setState(() {
      asignaciones.removeAt(index);
    });
  }

  void _updateAsignacion(int index, String field, dynamic value) {
    setState(() {
      asignaciones[index][field] = value;
    });
  }

  void _updateHorarioEvento(String inicio, String fin) {
    setState(() {
      _horarioEventoInicio = inicio;
      _horarioEventoFin = fin;
    });
  }

  int _getCurrentStep() {
    if (_nombreCtrl.text.isEmpty || _empresaSeleccionada == null) return 1;
    if (_horarioEventoInicio.isEmpty || _horarioEventoFin.isEmpty) return 2;
    if (asignaciones.isEmpty) return 3;
    return 4;
  }

  @override
  void dispose() {
    _dialogController.dispose();
    _stepController.dispose();
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dialogAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _dialogAnimation.value,
          child: Opacity(
            opacity: _dialogAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 900,
                height: 700,
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: kBrandPurple.withValues(alpha: 0.2),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      // Header premium con progress
                      EventoFormHeader(
                        title: widget.evento == null ? 'Crear Evento' : 'Editar Evento',
                        currentStep: _getCurrentStep(),
                        totalSteps: 4,
                        isEditing: widget.evento != null,
                      ),
                      
                      // Contenido principal scrolleable
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Información básica
                                EventoBasicInfoSection(
                                  nombreController: _nombreCtrl,
                                  direccionController: _direccionCtrl,
                                  empresaSeleccionada: _empresaSeleccionada,
                                  usarDireccionEmpresa: usarDireccionEmpresa,
                                  empresas: _empresas,
                                  onEmpresaChanged: (empresa) {
                                    setState(() {
                                      _empresaSeleccionada = empresa;
                                      if (usarDireccionEmpresa) {
                                        _direccionCtrl.text = empresa?.direccion ?? '';
                                      }
                                    });
                                  },
                                  onToggleDireccionEmpresa: _toggleDireccionEmpresa,
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Horarios del evento
                                EventoHorarioSection(
                                  horarioInicio: _horarioEventoInicio,
                                  horarioFin: _horarioEventoFin,
                                  onHorarioChanged: _updateHorarioEvento,
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Asignaciones
                                EventoAsignacionesSection(
                                  asignaciones: asignaciones,
                                  servicios: _servicios,
                                  profesionales: _profesionales,
                                  horarioEventoInicio: _horarioEventoInicio,
                                  horarioEventoFin: _horarioEventoFin,
                                  onAddAsignacion: _addAsignacion,
                                  onRemoveAsignacion: _removeAsignacion,
                                  onUpdateAsignacion: _updateAsignacion,
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Campo observaciones con controller real
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: kBorderColor.withValues(alpha: 0.1)),
                                  ),
                                  child: TextFormField(
                                    controller: _observacionesCtrl,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      labelText: 'Observaciones',
                                      hintText: 'Notas adicionales sobre el evento...',
                                      prefixIcon: Icon(Icons.note_add, color: kBrandPurple),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(16),
                                      labelStyle: TextStyle(
                                        color: kBrandPurple,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Acciones del formulario
                      EventoFormActions(
                        isLoading: false,
                        canSave: _canSave(),
                        onCancel: () => Navigator.of(context).pop(false),
                        onSave: _handleSave,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _canSave() {
    return _nombreCtrl.text.isNotEmpty &&
           _empresaSeleccionada != null &&
           _horarioEventoInicio.isNotEmpty &&
           _horarioEventoFin.isNotEmpty;
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate() && _canSave()) {
      await _guardarEventoReal();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  // ✅ COPIAR EXACTO método _guardarEvento del archivo original líneas 520-580
  Future<void> _guardarEventoReal() async {
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
        // ✅ INCLUIR horarios nuevos
        'horaInicio': a['horaInicio'] ?? _horarioEventoInicio,
        'horaFin': a['horaFin'] ?? _horarioEventoFin,
        'ubicacion': _direccionCtrl.text.trim(),
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.evento == null 
                  ? 'Evento creado exitosamente'
                  : 'Evento actualizado exitosamente',
            ),
            backgroundColor: kAccentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error guardando evento: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el evento: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}