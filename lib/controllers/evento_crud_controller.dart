// [evento_crud_controller.dart] - CONTROLADOR REACTIVO PARA EVENTO CRUD
// 📁 Ubicación: /lib/controllers/evento_crud_controller.dart
// 🎯 OBJETIVO: Estado reactivo + lógica de negocio REAL

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/models/evento_form_state.dart';
import 'package:agenda_fisio_spa_kym/models/evento_model.dart';
import 'package:agenda_fisio_spa_kym/models/empresa_model.dart';
import 'package:agenda_fisio_spa_kym/services/evento_service.dart';

class EventoCrudController extends ChangeNotifier {
  EventoFormState _state = EventoFormState.initial();
  EventoFormState get state => _state;

  // ✅ MANTENER CONEXIONES FIRESTORE REALES DEL ARCHIVO ORIGINAL
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _empresas = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _profesionales = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _servicios = [];
  final _eventoService = EventoService(); // ✅ Servicio real existente

  // ✅ CONTROLLERS REALES DEL ARCHIVO ORIGINAL
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController observacionesController = TextEditingController();

  // ✅ ESTADO EMPRESAS EXACTO DEL ORIGINAL
  EmpresaModel? _empresaSeleccionada;
  bool _usarDireccionEmpresa = false;

  // ✅ GETTERS PARA UI
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get empresas => _empresas;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get profesionales => _profesionales;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get servicios => _servicios;
  EmpresaModel? get empresaSeleccionada => _empresaSeleccionada;
  bool get usarDireccionEmpresa => _usarDireccionEmpresa;
  List<Map<String, dynamic>> get asignaciones => _convertAsignacionesToMap();

  // ✅ INICIALIZACIÓN CON EVENTO EXISTENTE
  void initializeWithEvento(EventoModel? evento) {
    if (evento != null) {
      nombreController.text = evento.nombre;
      direccionController.text = evento.ubicacion;
      observacionesController.text = evento.observaciones;

      // Convertir serviciosAsignados a EventoAsignacion
      final asignacionesConvertidas = evento.serviciosAsignados.map((asignacion) {
        return EventoAsignacion(
          servicioId: asignacion['servicioId'] ?? '',
          profesionalId: asignacion['profesionalId'] ?? '',
          fecha: evento.fecha,
          horaInicio: asignacion['horaInicio'] ?? '09:00',
          horaFin: asignacion['horaFin'] ?? '15:00',
        );
      }).toList();

      _state = _state.copyWith(
        asignaciones: asignacionesConvertidas,
        hasUnsavedChanges: false,
      );
    }
    notifyListeners();
  }

  // ✅ COPIAR EXACTO del archivo original evento_crud_dialog.dart línea ~80
  Future<void> loadFirestoreData() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final snapEmp = await FirebaseFirestore.instance.collection('empresas').get();
      final snapProfes = await FirebaseFirestore.instance.collection('profesionales').get();
      final snapServs = await FirebaseFirestore.instance.collection('services').get();

      // ✅ MANTENER filtro de servicios corporativos EXACTO
      final filteredServices = snapServs.docs
          .where((doc) => (doc.data()['category']?.toString().toLowerCase() == 'corporativo'))
          .toList();

      _empresas = snapEmp.docs;
      _profesionales = snapProfes.docs;
      _servicios = filteredServices;

      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando datos de Firestore: $e');
      _state = _state.copyWith(
        isLoading: false,
        errors: {'general': 'Error cargando datos: $e'},
      );
      notifyListeners();
    }
  }

  // ✅ MÉTODOS REACTIVOS PARA MANEJAR ESTADO
  void updateBasicInfo(String field, String value) {
    final newErrors = Map<String, String>.from(_state.errors);
    
    // Validaciones en tiempo real
    switch (field) {
      case 'nombre':
        if (value.trim().isEmpty) {
          newErrors['nombre'] = 'El nombre es requerido';
        } else {
          newErrors.remove('nombre');
        }
        break;
    }

    _state = _state.copyWith(
      errors: newErrors,
      hasUnsavedChanges: true,
      isValid: _validateForm(),
    );
    notifyListeners();
  }

  void updateHorarioDefecto(String inicio, String fin) {
    _state = _state.copyWith(
      horarioInicioPorDefecto: inicio,
      horarioFinPorDefecto: fin,
      hasUnsavedChanges: true,
    );
    notifyListeners();
  }

  void addAsignacion() {
    final nuevasAsignaciones = List<EventoAsignacion>.from(_state.asignaciones);
    nuevasAsignaciones.add(EventoAsignacion(
      servicioId: '',
      profesionalId: '',
      fecha: DateTime.now(),
      horaInicio: _state.horarioInicioPorDefecto,
      horaFin: _state.horarioFinPorDefecto,
    ));

    _state = _state.copyWith(
      asignaciones: nuevasAsignaciones,
      hasUnsavedChanges: true,
    );
    notifyListeners();
  }

  void removeAsignacion(int index) {
    final nuevasAsignaciones = List<EventoAsignacion>.from(_state.asignaciones);
    if (index >= 0 && index < nuevasAsignaciones.length) {
      nuevasAsignaciones.removeAt(index);
      _state = _state.copyWith(
        asignaciones: nuevasAsignaciones,
        hasUnsavedChanges: true,
      );
      notifyListeners();
    }
  }

  void updateAsignacion(int index, EventoAsignacion asignacion) {
    final nuevasAsignaciones = List<EventoAsignacion>.from(_state.asignaciones);
    if (index >= 0 && index < nuevasAsignaciones.length) {
      nuevasAsignaciones[index] = asignacion;
      _state = _state.copyWith(
        asignaciones: nuevasAsignaciones,
        hasUnsavedChanges: true,
      );
      notifyListeners();
    }
  }

  void updateAsignacionFecha(int index, DateTime fecha) {
    if (index >= 0 && index < _state.asignaciones.length) {
      final asignacion = _state.asignaciones[index];
      updateAsignacion(index, asignacion.copyWith(fecha: fecha));
    }
  }

  void updateAsignacionServicio(int index, String servicioId) {
    if (index >= 0 && index < _state.asignaciones.length) {
      final asignacion = _state.asignaciones[index];
      updateAsignacion(index, asignacion.copyWith(servicioId: servicioId));
    }
  }

  void updateAsignacionProfesional(int index, String profesionalId) {
    if (index >= 0 && index < _state.asignaciones.length) {
      final asignacion = _state.asignaciones[index];
      updateAsignacion(index, asignacion.copyWith(profesionalId: profesionalId));
    }
  }

  void updateAsignacionHorario(int index, String inicio, String fin) {
    if (index >= 0 && index < _state.asignaciones.length) {
      final asignacion = _state.asignaciones[index];
      updateAsignacion(index, asignacion.copyWith(
        horaInicio: inicio,
        horaFin: fin,
      ));
    }
  }

  // ✅ MÉTODOS DE EMPRESA - EXACTOS DEL ORIGINAL
  void setEmpresaSeleccionada(EmpresaModel empresa) {
    _empresaSeleccionada = empresa;
    if (_usarDireccionEmpresa) {
      direccionController.text = empresa.direccion ?? '';
    }
    _state = _state.copyWith(hasUnsavedChanges: true);
    notifyListeners();
  }

  void toggleDireccionEmpresa(bool value) {
    _usarDireccionEmpresa = value;
    if (value && _empresaSeleccionada != null) {
      direccionController.text = _empresaSeleccionada!.direccion ?? '';
    } else {
      direccionController.clear();
    }
    _state = _state.copyWith(hasUnsavedChanges: true);
    notifyListeners();
  }

  // ✅ VALIDACIÓN GENERAL
  bool _validateForm() {
    return nombreController.text.trim().isNotEmpty &&
           _empresaSeleccionada != null &&
           _state.asignaciones.isNotEmpty &&
           _state.asignaciones.every((a) => a.isValid);
  }

  // ✅ MANTENER lógica de guardado EXACTA del archivo original
  Future<bool> saveEvento({EventoModel? eventoExistente}) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      // ✅ COPIAR EXACTO método _guardarEvento() líneas 520-580 del archivo original
      if (_empresaSeleccionada == null) {
        _state = _state.copyWith(
          isLoading: false,
          errors: {'empresa': 'Debe seleccionar una empresa'},
        );
        notifyListeners();
        return false;
      }

      final asignacionesValidas = _state.asignaciones.where((a) {
        return a.servicioId.isNotEmpty &&
               a.profesionalId.isNotEmpty;
      }).toList();

      if (asignacionesValidas.isEmpty) {
        _state = _state.copyWith(
          isLoading: false,
          errors: {'asignaciones': 'Debe tener al menos una asignación válida'},
        );
        notifyListeners();
        return false;
      }

      final id = eventoExistente?.id ??
          FirebaseFirestore.instance.collection('eventos').doc().id;
      final fechaPrincipal = asignacionesValidas.first.fecha;

      final serviciosAsignados = asignacionesValidas.map((a) {
        final servicio = _servicios.firstWhere((s) => s.id == a.servicioId);
        final profesional = _profesionales.firstWhere((p) => p.id == a.profesionalId);

        return {
          'servicioId': a.servicioId,
          'servicioNombre': servicio.data()['name'] ?? '',
          'profesionalId': a.profesionalId,
          'profesionalNombre': profesional.data()['nombre'] ?? '',
          'fechaAsignada': a.fecha.toIso8601String(),
          'horaInicio': a.horaInicio,
          'horaFin': a.horaFin,
        };
      }).toList();

      final evento = EventoModel(
        id: id,
        eventoId: id,
        nombre: nombreController.text.trim(),
        empresa: _empresaSeleccionada!.nombre,
        empresaId: _empresaSeleccionada!.empresaId,
        ubicacion: direccionController.text.trim(),
        fecha: fechaPrincipal,
        estado: eventoExistente?.estado ?? 'activo',
        observaciones: observacionesController.text.trim(),
        fechaCreacion: DateTime.now(),
        serviciosAsignados: serviciosAsignados.map((e) => Map<String, dynamic>.from(e)).toList(),
      );

      if (eventoExistente == null) {
        await _eventoService.createEvento(evento);
      } else {
        await _eventoService.updateEvento(evento);
      }

      _state = _state.copyWith(
        isLoading: false,
        hasUnsavedChanges: false,
      );
      notifyListeners();
      return true;

    } catch (e) {
      debugPrint('Error guardando evento: $e');
      _state = _state.copyWith(
        isLoading: false,
        errors: {'general': 'Error guardando evento: $e'},
      );
      notifyListeners();
      return false;
    }
  }

  // ✅ CONVERSIÓN PARA COMPATIBILIDAD CON UI EXISTENTE
  List<Map<String, dynamic>> _convertAsignacionesToMap() {
    return _state.asignaciones.map((a) => {
      'fecha': a.fecha,
      'servicioId': a.servicioId,
      'profesionalId': a.profesionalId,
      'horaInicio': a.horaInicio,
      'horaFin': a.horaFin,
    }).toList();
  }

  @override
  void dispose() {
    nombreController.dispose();
    direccionController.dispose();
    observacionesController.dispose();
    super.dispose();
  }
}