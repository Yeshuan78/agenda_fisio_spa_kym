// [agenda_state_manager.dart]
// 📁 Ubicación: /lib/managers/agenda_state_manager.dart
// 🔧 EXTRACCIÓN QUIRÚRGICA: Variables de estado centralizadas
// ✅ COPY-PASTE EXACTO del archivo original - CERO MODIFICACIONES

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';

class AgendaStateManager extends ChangeNotifier {
  // ✅ DATA STATE EXACTO DEL ORIGINAL
  DateTime _selectedDay = DateTime.now();
  String _selectedView = 'semana';
  String _selectedResource = 'profesionales';

  Map<DateTime, List<AppointmentModel>> _appointments = {};
  Map<DateTime, List<Map<String, dynamic>>> _bloqueos = {};
  List<Map<String, dynamic>> _profesionales = [];
  List<Map<String, dynamic>> _cabinas = [];
  List<Map<String, dynamic>> _servicios = [];
  List<Map<String, dynamic>> _eventos = [];

  bool _isLoading = true;
  String _searchQuery = '';

  // ✅ MÉTRICAS EN TIEMPO REAL EXACTAS DEL ORIGINAL
  int _citasHoy = 0;
  int _citasManana = 0;
  int _profesionalesActivos = 0;
  int _cabinasDisponibles = 0;
  double _ocupacionPromedio = 0.0;

  // ✅ VARIABLES PARA DOCUMENTSNAPSHOT EXACTAS DEL ORIGINAL
  List<DocumentSnapshot> _listaClientesDoc = [];
  List<DocumentSnapshot> _listaProfesionalesDoc = [];
  List<DocumentSnapshot> _listaServiciosDoc = [];

  // ✅ LISTENERS EN TIEMPO REAL EXACTOS DEL ORIGINAL
  StreamSubscription<QuerySnapshot>? _appointmentsSubscription;
  StreamSubscription<QuerySnapshot>? _profesionalesSubscription;
  StreamSubscription<QuerySnapshot>? _bloqueosSubscription;

  // 🔧 NUEVAS VARIABLES PARA CONTROL DE BLOQUEOS EXACTAS DEL ORIGINAL
  bool _bloqueosIndexAvailable = false;
  bool _bloqueosCollectionExists = false;

  // ========================================================================
  // 🎯 GETTERS EXACTOS - SIN MODIFICACIONES
  // ========================================================================

  // ✅ DATA STATE GETTERS
  DateTime get selectedDay => _selectedDay;
  String get selectedView => _selectedView;
  String get selectedResource => _selectedResource;
  
  Map<DateTime, List<AppointmentModel>> get appointments => _appointments;
  Map<DateTime, List<Map<String, dynamic>>> get bloqueos => _bloqueos;
  List<Map<String, dynamic>> get profesionales => _profesionales;
  List<Map<String, dynamic>> get cabinas => _cabinas;
  List<Map<String, dynamic>> get servicios => _servicios;
  List<Map<String, dynamic>> get eventos => _eventos;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // ✅ MÉTRICAS GETTERS EXACTOS DEL ORIGINAL
  int get citasHoy => _citasHoy;
  int get citasManana => _citasManana;
  int get profesionalesActivos => _profesionalesActivos;
  int get cabinasDisponibles => _cabinasDisponibles;
  double get ocupacionPromedio => _ocupacionPromedio;

  // ✅ DOCUMENTSNAPSHOT GETTERS EXACTOS DEL ORIGINAL
  List<DocumentSnapshot> get listaClientesDoc => _listaClientesDoc;
  List<DocumentSnapshot> get listaProfesionalesDoc => _listaProfesionalesDoc;
  List<DocumentSnapshot> get listaServiciosDoc => _listaServiciosDoc;

  // ✅ LISTENERS GETTERS EXACTOS DEL ORIGINAL
  StreamSubscription<QuerySnapshot>? get appointmentsSubscription => _appointmentsSubscription;
  StreamSubscription<QuerySnapshot>? get profesionalesSubscription => _profesionalesSubscription;
  StreamSubscription<QuerySnapshot>? get bloqueosSubscription => _bloqueosSubscription;

  // 🔧 BLOQUEOS CONTROL GETTERS EXACTOS DEL ORIGINAL
  bool get bloqueosIndexAvailable => _bloqueosIndexAvailable;
  bool get bloqueosCollectionExists => _bloqueosCollectionExists;

  // ========================================================================
  // 🎯 SETTERS CON NOTIFYLISTENERS - COMPORTAMIENTO IDÉNTICO A setState
  // ========================================================================

  // ✅ DATA STATE SETTERS
  set selectedDay(DateTime value) {
    _selectedDay = value;
    notifyListeners();
  }

  set selectedView(String value) {
    _selectedView = value;
    notifyListeners();
  }

  set selectedResource(String value) {
    _selectedResource = value;
    notifyListeners();
  }

  set appointments(Map<DateTime, List<AppointmentModel>> value) {
    _appointments = value;
    notifyListeners();
  }

  set bloqueos(Map<DateTime, List<Map<String, dynamic>>> value) {
    _bloqueos = value;
    notifyListeners();
  }

  set profesionales(List<Map<String, dynamic>> value) {
    _profesionales = value;
    notifyListeners();
  }

  set cabinas(List<Map<String, dynamic>> value) {
    _cabinas = value;
    notifyListeners();
  }

  set servicios(List<Map<String, dynamic>> value) {
    _servicios = value;
    notifyListeners();
  }

  set eventos(List<Map<String, dynamic>> value) {
    _eventos = value;
    notifyListeners();
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  // ✅ MÉTRICAS SETTERS EXACTOS DEL ORIGINAL
  set citasHoy(int value) {
    _citasHoy = value;
    notifyListeners();
  }

  set citasManana(int value) {
    _citasManana = value;
    notifyListeners();
  }

  set profesionalesActivos(int value) {
    _profesionalesActivos = value;
    notifyListeners();
  }

  set cabinasDisponibles(int value) {
    _cabinasDisponibles = value;
    notifyListeners();
  }

  set ocupacionPromedio(double value) {
    _ocupacionPromedio = value;
    notifyListeners();
  }

  // ✅ DOCUMENTSNAPSHOT SETTERS EXACTOS DEL ORIGINAL
  set listaClientesDoc(List<DocumentSnapshot> value) {
    _listaClientesDoc = value;
    notifyListeners();
  }

  set listaProfesionalesDoc(List<DocumentSnapshot> value) {
    _listaProfesionalesDoc = value;
    notifyListeners();
  }

  set listaServiciosDoc(List<DocumentSnapshot> value) {
    _listaServiciosDoc = value;
    notifyListeners();
  }

  // ✅ LISTENERS SETTERS EXACTOS DEL ORIGINAL
  set appointmentsSubscription(StreamSubscription<QuerySnapshot>? value) {
    _appointmentsSubscription = value;
    notifyListeners();
  }

  set profesionalesSubscription(StreamSubscription<QuerySnapshot>? value) {
    _profesionalesSubscription = value;
    notifyListeners();
  }

  set bloqueosSubscription(StreamSubscription<QuerySnapshot>? value) {
    _bloqueosSubscription = value;
    notifyListeners();
  }

  // 🔧 BLOQUEOS CONTROL SETTERS EXACTOS DEL ORIGINAL
  set bloqueosIndexAvailable(bool value) {
    _bloqueosIndexAvailable = value;
    notifyListeners();
  }

  set bloqueosCollectionExists(bool value) {
    _bloqueosCollectionExists = value;
    notifyListeners();
  }

  // ========================================================================
  // 🎯 MÉTODOS HELPER EXACTOS DEL ORIGINAL
  // ========================================================================

  // ✅ MÉTODO CALCULATE METRICS EXACTO DEL ORIGINAL
  void calculateMetrics(Map<DateTime, List<AppointmentModel>> appointments) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    final todayKey = DateTime(today.year, today.month, today.day);
    final tomorrowKey = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    _citasHoy = appointments[todayKey]?.length ?? 0;
    _citasManana = appointments[tomorrowKey]?.length ?? 0;
    _profesionalesActivos = _profesionales.where((p) => p['estado'] == 'activo').length;
    _cabinasDisponibles = _cabinas.where((c) => c['estado'] == 'disponible').length;

    int totalSlots = _profesionalesActivos * 10;
    int occupiedSlots = _citasHoy;
    _ocupacionPromedio = totalSlots > 0 ? (occupiedSlots / totalSlots) * 100 : 0.0;
    
    notifyListeners();
  }

  // ========================================================================
  // 🎯 DISPOSE PARA CLEANUP DE LISTENERS
  // ========================================================================

  @override
  void dispose() {
    _appointmentsSubscription?.cancel();
    _profesionalesSubscription?.cancel();
    _bloqueosSubscription?.cancel();
    super.dispose();
  }
}