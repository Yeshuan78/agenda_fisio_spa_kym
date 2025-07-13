// [booking_data_loader_service.dart] - 🔧 FIX CRÍTICO: Cargar TODOS los servicios
// 📁 Ubicación: /lib/services/booking/booking_data_loader_service.dart
// 🎯 OBJETIVO: Mantener todo el código original + fix de consulta Firestore

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/evento_model.dart';
import '../../models/empresa_model.dart';
import '../../models/categoria_model.dart';
import '../../services/evento_service.dart';
import '../../services/empresa_service.dart';
import '../../services/categoria_service.dart';
import '../../enums/booking_types.dart';

/// 📥 SERVICIO DE CARGA DE DATOS DE BOOKING
/// Centraliza toda la lógica de carga asíncrona de datos
class BookingDataLoaderService {
  // 🎯 SERVICIOS DE DEPENDENCIAS
  final EventoService _eventoService;
  final EmpresaService _empresaService;
  final CategoriaService _categoriaService;
  final FirebaseFirestore _firestore;

  BookingDataLoaderService({
    EventoService? eventoService,
    EmpresaService? empresaService,
    CategoriaService? categoriaService,
    FirebaseFirestore? firestore,
  })  : _eventoService = eventoService ?? EventoService(),
        _empresaService = empresaService ?? EmpresaService(),
        _categoriaService = categoriaService ?? CategoriaService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// 🚀 CARGA INICIAL DE DATOS COMPLETA
  Future<BookingDataResult> loadInitialData({
    required BookingType bookingType,
    String? companyId,
    Map<String, String>? queryParams,
  }) async {
    try {
      debugPrint('📥 Iniciando carga de datos para tipo: ${bookingType.name}');

      final params = queryParams ?? {};
      final eventId = params['e'] ?? params['eventId'];

      // 🏢 Cargar datos de empresa si aplica
      EmpresaModel? empresa;
      Map<String, dynamic>? companyData;
      if (companyId != null) {
        final companyResult = await loadCompanyData(companyId);
        empresa = companyResult.empresa;
        companyData = companyResult.companyData;
      }

      // 📅 Cargar datos específicos según el tipo
      EventoModel? evento;
      Map<String, dynamic>? selectedEventData;
      List<DocumentSnapshot> eventos = [];
      List<Map<String, dynamic>> serviciosDisponibles = [];
      List<DocumentSnapshot> professionals = [];

      if (eventId != null) {
        // Evento específico
        final eventResult = await loadSpecificEvent(eventId);
        evento = eventResult.evento;
        selectedEventData = eventResult.selectedEventData;
        serviciosDisponibles = eventResult.serviciosDisponibles;
      } else if (companyId != null) {
        // Eventos de empresa
        final eventsResult = await loadCompanyEvents(companyId, companyData);
        eventos = eventsResult.eventos;
      } else {
        // Servicios particulares
        final servicesResult = await loadServicesForParticulares();
        serviciosDisponibles = servicesResult.serviciosDisponibles;
        professionals = servicesResult.professionals;
      }

      final result = BookingDataResult(
        empresa: empresa,
        companyData: companyData,
        evento: evento,
        selectedEventData: selectedEventData,
        eventos: eventos,
        serviciosDisponibles: serviciosDisponibles,
        professionals: professionals,
        categorias: await _loadCategorias(), // ✅ NUEVO: Cargar categorías
        isSuccess: true,
      );

      debugPrint('✅ Carga inicial completada exitosamente');
      debugPrint('   - Empresa: ${empresa?.nombre ?? 'N/A'}');
      debugPrint('   - Evento: ${evento?.nombre ?? 'N/A'}');
      debugPrint('   - Servicios: ${serviciosDisponibles.length}');
      debugPrint('   - Eventos: ${eventos.length}');

      return result;
    } catch (e) {
      debugPrint('❌ Error en carga inicial: $e');
      return BookingDataResult(
        isSuccess: false,
        error: 'Error cargando datos: $e',
      );
    }
  }

  /// 🏢 CARGAR DATOS DE EMPRESA
  Future<CompanyDataResult> loadCompanyData(String companyId) async {
    try {
      debugPrint('🏢 Cargando datos de empresa: $companyId');

      final empresa = await _empresaService.getEmpresaById(companyId);

      if (empresa != null) {
        final companyData = {
          'nombre': empresa.nombre,
          'empresaId': empresa.empresaId,
          'rfc': empresa.rfc,
          'razonSocial': empresa.razonSocial,
          'telefono': empresa.telefono,
          'correo': empresa.correo,
          'direccion': empresa.direccion,
          'ciudad': empresa.ciudad,
          'estado': empresa.estado,
        };

        debugPrint('✅ Empresa cargada: ${empresa.nombre}');

        return CompanyDataResult(
          empresa: empresa,
          companyData: companyData,
          isSuccess: true,
        );
      } else {
        debugPrint('⚠️ Empresa no encontrada: $companyId');
        return CompanyDataResult(
          isSuccess: false,
          error: 'Empresa no encontrada',
        );
      }
    } catch (e) {
      debugPrint('❌ Error cargando empresa $companyId: $e');
      return CompanyDataResult(
        isSuccess: false,
        error: 'Error cargando empresa: $e',
      );
    }
  }

  /// 📅 CARGAR EVENTO ESPECÍFICO
  Future<EventDataResult> loadSpecificEvent(String eventId) async {
    try {
      debugPrint('📅 Cargando evento específico: $eventId');

      final evento = await _eventoService.getEventoById(eventId);

      if (evento != null) {
        final selectedEventData = {
          'nombre': evento.nombre,
          'empresa': evento.empresa,
          'fecha': Timestamp.fromDate(evento.fecha),
          'ubicacion': evento.ubicacion,
          'estado': evento.estado,
          'observaciones': evento.observaciones,
        };

        // Cargar servicios del evento
        final servicios = await loadServicesFromEvent(eventId, evento);

        debugPrint('✅ Evento cargado: ${evento.nombre}');
        debugPrint('   - Fecha: ${evento.fecha}');
        debugPrint('   - Servicios: ${servicios.length}');

        return EventDataResult(
          evento: evento,
          selectedEventData: selectedEventData,
          serviciosDisponibles: servicios,
          isSuccess: true,
        );
      } else {
        debugPrint('⚠️ Evento no encontrado: $eventId');
        return EventDataResult(
          isSuccess: false,
          error: 'Evento no encontrado',
        );
      }
    } catch (e) {
      debugPrint('❌ Error cargando evento $eventId: $e');
      return EventDataResult(
        isSuccess: false,
        error: 'Error cargando evento: $e',
      );
    }
  }

  /// 🏢 CARGAR EVENTOS DE EMPRESA
  Future<CompanyEventsResult> loadCompanyEvents(
    String companyId,
    Map<String, dynamic>? companyData,
  ) async {
    try {
      debugPrint('📋 Cargando eventos de empresa: $companyId');

      final companyName = companyData?['nombre'] ?? '';
      final allEvents = await _eventoService.getEventos();

      final eventos = <DocumentSnapshot>[];

      // Crear documentos reales en lugar de mock
      for (final evento in allEvents) {
        if (evento.estado == 'activo' &&
            (evento.empresa == companyName || evento.empresaId == companyId)) {
          // Buscar el documento real en Firestore
          try {
            final doc =
                await _firestore.collection('eventos').doc(evento.id).get();
            if (doc.exists) {
              eventos.add(doc);
            }
          } catch (e) {
            debugPrint(
                '⚠️ Error obteniendo documento del evento ${evento.id}: $e');
          }
        }
      }

      debugPrint('✅ Eventos de empresa cargados: ${eventos.length}');

      return CompanyEventsResult(
        eventos: eventos,
        isSuccess: true,
      );
    } catch (e) {
      debugPrint('❌ Error cargando eventos de empresa: $e');
      return CompanyEventsResult(
        eventos: [],
        isSuccess: false,
        error: 'Error cargando eventos: $e',
      );
    }
  }

  /// 🏠 CARGAR SERVICIOS PARA PARTICULARES - ✅ FIX CRÍTICO APLICADO
  Future<ParticularsServicesResult> loadServicesForParticulares() async {
    try {
      debugPrint(
          '🏠 Cargando servicios para particulares - FIX CRÍTICO aplicado');

      // ✅ CARGAR CATEGORÍAS REALES PRIMERO
      final categoriasReales = await _categoriaService.getCategorias();
      final categoriasMap = {for (var cat in categoriasReales) cat.nombre: cat};

      // ✅ FIX CRÍTICO: CARGAR TODOS LOS SERVICIOS SIN FILTRO
      debugPrint('🔄 Cargando TODOS los servicios sin filtro...');
      final snapshot = await _firestore.collection('services').get();

      debugPrint('📊 TOTAL servicios en colección: ${snapshot.docs.length}');
      debugPrint('🗂️ Categorías reales cargadas: ${categoriasReales.length}');

      final serviciosDisponibles = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        // Debug: Mostrar cada servicio para entender la estructura
        debugPrint(
            '🔍 Servicio: ${data['name']} - Tipo: ${data['tipo']} - Category: ${data['category']} - Activo: ${data['activo']}');

        final category = data['category']?.toString().trim() ?? '';

        // ✅ FILTRO MEJORADO: Verificar activo PRIMERO
        final activo = data['activo'] ?? true;
        if (!activo) {
          debugPrint('   ❌ EXCLUIDO: Servicio inactivo');
          continue;
        }

        // ✅ FILTRO CORRECTO: Excluir por CATEGORÍA corporativa
        final esCorporativo = category.toLowerCase().contains('corporativo') ||
            category.toLowerCase().contains('empresarial') ||
            category.toLowerCase().contains('enterprise') ||
            category.toLowerCase().contains('corporate') ||
            category.toLowerCase() == 'corporativo';

        if (!esCorporativo) {
          // ✅ ENRIQUECER CON DATOS DE CATEGORÍA REAL
          final categoriaReal = categoriasMap[category];

          serviciosDisponibles.add({
            'id': doc.id,
            'name': data['name'] ?? 'Servicio sin nombre',
            'duration': data['duration'] ?? 60,
            'price': data['price'] ?? 0,
            'category': category.isNotEmpty ? category : 'General',
            'description': data['description'] ?? '',
            'tipo': data['tipo'] ?? 'domicilio',
            'bufferMin': data['bufferMin'] ?? 0,
            'nivelEnergia': data['nivelEnergia'] ?? 'media',
            'capacidad': data['capacidad'] ?? 1,
            'image': data['image'] ?? '',
            'activo': data['activo'] ?? true,
            'professionalIds': data['professionalIds'] ?? [],
            // ✅ NUEVOS CAMPOS DE CATEGORÍA REAL
            'categoriaId': categoriaReal?.categoriaId,
            'categoriaColor': categoriaReal?.colorHex ?? '#6B7280',
            'categoriaIcono': categoriaReal?.icono ?? 'spa',
            'categoriaOrden': categoriaReal?.orden ?? 999,
          });

          debugPrint(
              '   ✅ INCLUIDO: ${data['name']} (${category}) - Color: ${categoriaReal?.colorHex ?? 'default'}');
        } else {
          debugPrint(
              '   ❌ EXCLUIDO: ${data['name']} - Category: $category (es corporativo)');
        }
      }

      // ✅ ORDENAR POR ORDEN DE CATEGORÍA Y LUEGO POR NOMBRE
      serviciosDisponibles.sort((a, b) {
        final ordenA = a['categoriaOrden'] ?? 999;
        final ordenB = b['categoriaOrden'] ?? 999;
        final ordenComparison = ordenA.compareTo(ordenB);
        if (ordenComparison != 0) return ordenComparison;

        final categoryComparison =
            (a['category'] ?? '').compareTo(b['category'] ?? '');
        if (categoryComparison != 0) return categoryComparison;

        return (a['name'] ?? '').compareTo(b['name'] ?? '');
      });

      // Cargar profesionales disponibles
      final professionals = await loadProfessionals();

      debugPrint(
          '✅ Servicios particulares finales: ${serviciosDisponibles.length}');
      debugPrint('✅ Profesionales cargados: ${professionals.length}');

      // Log detallado de categorías con colores
      final categorias = serviciosDisponibles
          .map((s) => s['category'])
          .toSet()
          .toList()
        ..sort();
      debugPrint('📋 Categorías con servicios: $categorias');

      // Log de servicios por categoría con colores
      for (final categoria in categorias) {
        final serviciosEnCategoria = serviciosDisponibles
            .where((s) => s['category'] == categoria)
            .toList();
        final color = serviciosEnCategoria.isNotEmpty
            ? serviciosEnCategoria.first['categoriaColor']
            : '#6B7280';
        debugPrint(
            '📂 $categoria: ${serviciosEnCategoria.length} servicios (Color: $color)');
      }

      return ParticularsServicesResult(
        serviciosDisponibles: serviciosDisponibles,
        professionals: professionals,
        categorias: categoriasReales, // ✅ INCLUIR CATEGORÍAS REALES
        isSuccess: true,
      );
    } catch (e) {
      debugPrint('❌ Error cargando servicios particulares: $e');
      return ParticularsServicesResult(
        serviciosDisponibles: [],
        professionals: [],
        categorias: [], // ✅ LISTA VACÍA EN ERROR
        isSuccess: false,
        error: 'Error cargando servicios: $e',
      );
    }
  }

  /// 📅 CARGAR SERVICIOS DESDE EVENTO
  Future<List<Map<String, dynamic>>> loadServicesFromEvent(
    String eventId,
    EventoModel evento,
  ) async {
    try {
      debugPrint('🔧 Cargando servicios del evento: $eventId');

      final serviciosAsignados = evento.serviciosAsignados;
      if (serviciosAsignados.isEmpty) {
        debugPrint('⚠️ No hay servicios asignados al evento');
        return [];
      }

      final servicios = <Map<String, dynamic>>[];

      for (Map<String, dynamic> servicioAsignado in serviciosAsignados) {
        final serviceId = servicioAsignado['servicioId'];
        if (serviceId == null) continue;

        try {
          final serviceDoc =
              await _firestore.collection('services').doc(serviceId).get();

          if (serviceDoc.exists) {
            final data = serviceDoc.data()!;

            servicios.add({
              'id': serviceDoc.id,
              'name': data['name'] ?? servicioAsignado['servicioNombre'] ?? '',
              'duration': data['duration'] ?? 60,
              'price': data['price'] ?? 0,
              'category': data['category'] ?? '',
              'description': data['description'] ?? '',
              'profesionalAsignado': servicioAsignado['profesionalId'],
              'profesionalNombre': servicioAsignado['profesionalNombre'],
              'fechaAsignada': servicioAsignado['fechaAsignada'],
              'ubicacion': servicioAsignado['ubicacion'],
              'horaInicio': servicioAsignado['horaInicio'] ?? '09:00',
              'horaFin': servicioAsignado['horaFin'] ?? '17:00',
              'eventoId': eventId,
              'eventoNombre': evento.nombre,
              'eventoFecha': evento.fecha,
              'eventoUbicacion': evento.ubicacion,
            });

            debugPrint('✅ Servicio cargado: ${data['name']}');
          } else {
            debugPrint('⚠️ Servicio no encontrado: $serviceId');
          }
        } catch (e) {
          debugPrint('❌ Error cargando servicio $serviceId: $e');
        }
      }

      debugPrint('✅ Total servicios del evento cargados: ${servicios.length}');
      return servicios;
    } catch (e) {
      debugPrint('❌ Error cargando servicios del evento: $e');
      return [];
    }
  }

  /// 👨‍⚕️ CARGAR PROFESIONALES DISPONIBLES
  Future<List<DocumentSnapshot>> loadProfessionals() async {
    try {
      debugPrint('👨‍⚕️ Cargando profesionales disponibles');

      final snapshot = await _firestore
          .collection('profesionales')
          .where('estado', isEqualTo: true)
          .get();

      debugPrint('✅ Profesionales cargados: ${snapshot.docs.length}');
      return snapshot.docs;
    } catch (e) {
      debugPrint('❌ Error cargando profesionales: $e');
      return [];
    }
  }

  /// 🔄 RECARGAR DATOS ESPECÍFICOS
  Future<BookingDataResult> reloadData({
    required BookingType bookingType,
    String? companyId,
    String? eventId,
    Map<String, String>? queryParams,
  }) async {
    debugPrint('🔄 Recargando datos de booking');

    return await loadInitialData(
      bookingType: bookingType,
      companyId: companyId,
      queryParams: queryParams,
    );
  }

  /// 🔍 BUSCAR CLIENTE POR TELÉFONO
  Future<DocumentSnapshot?> searchClientByPhone(String telefono) async {
    try {
      debugPrint('🔍 Buscando cliente por teléfono: $telefono');

      final query = await _firestore
          .collection('clients')
          .where('telefono', isEqualTo: telefono)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        debugPrint('✅ Cliente encontrado por teléfono');
        return query.docs.first;
      } else {
        debugPrint('⚠️ Cliente no encontrado por teléfono');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error buscando cliente por teléfono: $e');
      return null;
    }
  }

  /// 🔍 BUSCAR EMPLEADO POR NÚMERO
  Future<DocumentSnapshot?> searchEmployeeByNumber(
      String numeroEmpleado) async {
    try {
      debugPrint('🔍 Buscando empleado por número: $numeroEmpleado');

      final query = await _firestore
          .collection('employees')
          .where('numeroEmpleado', isEqualTo: numeroEmpleado)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        debugPrint('✅ Empleado encontrado por número');
        return query.docs.first;
      } else {
        debugPrint('⚠️ Empleado no encontrado por número');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error buscando empleado por número: $e');
      return null;
    }
  }

  /// 📋 OBTENER CONFIGURACIÓN DE EMPRESA
  Future<Map<String, dynamic>?> getCompanySettings(String companyId) async {
    try {
      debugPrint('⚙️ Cargando configuración de empresa: $companyId');

      final doc =
          await _firestore.collection('company_settings').doc(companyId).get();

      if (doc.exists) {
        debugPrint('✅ Configuración de empresa cargada');
        return doc.data();
      } else {
        debugPrint('⚠️ No hay configuración específica para la empresa');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error cargando configuración de empresa: $e');
      return null;
    }
  }

  /// 🧹 LIMPIAR CACHE DE DATOS
  void clearCache() {
    debugPrint('🧹 Limpiando cache de datos de booking');
  }

  /// 🗂️ CARGAR CATEGORÍAS REALES
  Future<List<CategoriaModel>> _loadCategorias() async {
    try {
      return await _categoriaService.getCategorias();
    } catch (e) {
      debugPrint('❌ Error cargando categorías: $e');
      return [];
    }
  }
}

// ============================================================================
// 📋 MODELOS DE RESULTADO
// ============================================================================

/// 📊 RESULTADO PRINCIPAL DE CARGA DE DATOS
class BookingDataResult {
  final EmpresaModel? empresa;
  final Map<String, dynamic>? companyData;
  final EventoModel? evento;
  final Map<String, dynamic>? selectedEventData;
  final List<DocumentSnapshot> eventos;
  final List<Map<String, dynamic>> serviciosDisponibles;
  final List<DocumentSnapshot> professionals;
  final List<CategoriaModel> categorias; // ✅ NUEVO
  final bool isSuccess;
  final String? error;

  const BookingDataResult({
    this.empresa,
    this.companyData,
    this.evento,
    this.selectedEventData,
    this.eventos = const [],
    this.serviciosDisponibles = const [],
    this.professionals = const [],
    this.categorias = const [], // ✅ NUEVO
    required this.isSuccess,
    this.error,
  });

  bool get hasCompanyData => empresa != null && companyData != null;
  bool get hasEventData => evento != null && selectedEventData != null;
  bool get hasServices => serviciosDisponibles.isNotEmpty;
  bool get hasEvents => eventos.isNotEmpty;
  bool get hasProfessionals => professionals.isNotEmpty;
  bool get hasCategorias => categorias.isNotEmpty; // ✅ NUEVO
}

/// 🏢 RESULTADO DE CARGA DE EMPRESA
class CompanyDataResult {
  final EmpresaModel? empresa;
  final Map<String, dynamic>? companyData;
  final bool isSuccess;
  final String? error;

  const CompanyDataResult({
    this.empresa,
    this.companyData,
    required this.isSuccess,
    this.error,
  });
}

/// 📅 RESULTADO DE CARGA DE EVENTO
class EventDataResult {
  final EventoModel? evento;
  final Map<String, dynamic>? selectedEventData;
  final List<Map<String, dynamic>> serviciosDisponibles;
  final bool isSuccess;
  final String? error;

  const EventDataResult({
    this.evento,
    this.selectedEventData,
    this.serviciosDisponibles = const [],
    required this.isSuccess,
    this.error,
  });
}

/// 📋 RESULTADO DE EVENTOS DE EMPRESA
class CompanyEventsResult {
  final List<DocumentSnapshot> eventos;
  final bool isSuccess;
  final String? error;

  const CompanyEventsResult({
    this.eventos = const [],
    required this.isSuccess,
    this.error,
  });
}

/// 🏠 RESULTADO DE SERVICIOS PARTICULARES
class ParticularsServicesResult {
  final List<Map<String, dynamic>> serviciosDisponibles;
  final List<DocumentSnapshot> professionals;
  final List<CategoriaModel> categorias; // ✅ NUEVO
  final bool isSuccess;
  final String? error;

  const ParticularsServicesResult({
    this.serviciosDisponibles = const [],
    this.professionals = const [],
    this.categorias = const [], // ✅ NUEVO
    required this.isSuccess,
    this.error,
  });
}
