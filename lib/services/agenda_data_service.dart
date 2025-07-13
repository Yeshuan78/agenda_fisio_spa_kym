// [agenda_data_service.dart]
// 📁 Ubicación: /lib/services/agenda_data_service.dart
// 🔧 EXTRACCIÓN QUIRÚRGICA: Métodos de carga de datos
// ✅ COPY-PASTE EXACTO del archivo original - CERO MODIFICACIONES
// 🆕 IMPLEMENTACIÓN CACHE: Sistema completo integrado

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:agenda_fisio_spa_kym/services/firestore_agenda_service.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';
import 'package:agenda_fisio_spa_kym/managers/agenda_state_manager.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/background_cost_monitor.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/cache_service.dart';

class AgendaDataService {
  // ✅ SERVICIOS EXACTOS DEL ORIGINAL
  final FirestoreAgendaService _agendaService = FirestoreAgendaService();

  // 🎯 CORRECCIÓN 2A: Control de Live Mode
  bool _isLiveModeEnabled = false;

  // 🎯 CONEXIÓN REAL: Referencia al monitor de costos
  BackgroundCostMonitor? _costMonitor;

  // 🆕 IMPLEMENTACIÓN CACHE: Instancia del servicio de cache
  final CacheService _cacheService = CacheService();

  // ========================================================================
  // 🎯 MÉTODOS DE CARGA INICIAL EXACTOS DEL ORIGINAL
  // ========================================================================

  Future<void> loadInitialData(AgendaStateManager stateManager) async {
    stateManager.isLoading = true;

    try {
      // 🎯 CORRECCIÓN 2B: TRACKING DE CARGA INICIAL - INTEGRACIÓN COST CONTROL
      // Nota: El tracking se hará desde el coordinador principal

      final futures = await Future.wait([
        _agendaService.loadCitas(null),
        _loadProfesionales(),
        _loadCabinas(),
        _loadServicios(),
        _loadEventos(),
        _loadDocumentSnapshots(stateManager),
        _loadBloqueosConFallback(stateManager), // 🔧 MÉTODO OPTIMIZADO
      ]);

      final citasData = futures[0] as Map<DateTime, List<DocumentSnapshot>>;
      final Map<DateTime, List<AppointmentModel>> appointmentsMap = {};

      for (final entry in citasData.entries) {
        for (final doc in entry.value) {
          final data = doc.data() as Map<String, dynamic>;
          final model = AppointmentModel.fromMap(data, doc.id);
          final fechaKey =
              DateTime(entry.key.year, entry.key.month, entry.key.day);
          appointmentsMap.putIfAbsent(fechaKey, () => []).add(model);
        }
      }

      // ✅ ASIGNAR DATOS EXACTO DEL ORIGINAL
      stateManager.appointments = appointmentsMap;
      stateManager.profesionales = futures[1] as List<Map<String, dynamic>>;
      stateManager.cabinas = futures[2] as List<Map<String, dynamic>>;
      stateManager.servicios = futures[3] as List<Map<String, dynamic>>;
      stateManager.eventos = futures[4] as List<Map<String, dynamic>>;
      stateManager.bloqueos =
          futures[6] as Map<DateTime, List<Map<String, dynamic>>>;

      // ✅ CALCULAR MÉTRICAS EXACTO DEL ORIGINAL
      stateManager.calculateMetrics(appointmentsMap);
    } catch (e) {
      debugPrint('❌ Error cargando datos iniciales: $e');
    } finally {
      stateManager.isLoading = false;
    }
  }

  // ✅ LOAD DOCUMENT SNAPSHOTS EXACTO DEL ORIGINAL
  Future<void> _loadDocumentSnapshots(AgendaStateManager stateManager) async {
    try {
      final futures = await Future.wait([
        FirebaseFirestore.instance.collection('clients').get(),
        FirebaseFirestore.instance.collection('profesionales').get(),
        FirebaseFirestore.instance.collection('services').get(),
      ]);

      stateManager.listaClientesDoc = futures[0].docs;
      stateManager.listaProfesionalesDoc = futures[1].docs;
      stateManager.listaServiciosDoc = futures[2].docs;
    } catch (e) {
      debugPrint('❌ Error cargando DocumentSnapshots: $e');
    }
  }

  // ✅ LOAD PROFESIONALES CON CACHE IMPLEMENTADO
  Future<List<Map<String, dynamic>>> _loadProfesionales() async {
    return await _cacheService.getCachedProfesionales(() async {
          try {
            final snapshot = await FirebaseFirestore.instance
                .collection('profesionales')
                .where('estado', isEqualTo: true)
                .get();

            return snapshot.docs
                .map((doc) => {
                      'id': doc.id,
                      'nombre':
                          '${doc['nombre']} ${doc['apellidos'] ?? ''}'.trim(),
                      'especialidades': doc['especialidades'] ?? [],
                      'avatar': doc['fotoUrl'] ?? '',
                      'estado': 'activo',
                    })
                .toList();
          } catch (e) {
            debugPrint('⚠️ Error cargando profesionales: $e');
            return <Map<String, dynamic>>[];
          }
        }) ??
        <Map<String, dynamic>>[];
  }

  // ✅ LOAD CABINAS CON CACHE IMPLEMENTADO
  Future<List<Map<String, dynamic>>> _loadCabinas() async {
    return await _cacheService.getCachedCabinas(() async {
          return <Map<String, dynamic>>[
            {
              'id': 'cabina1',
              'nombre': 'Cabina VIP 1',
              'tipo': 'vip',
              'estado': 'disponible'
            },
            {
              'id': 'cabina2',
              'nombre': 'Cabina Premium 2',
              'tipo': 'premium',
              'estado': 'disponible'
            },
            {
              'id': 'cabina3',
              'nombre': 'Sala Grupal A',
              'tipo': 'grupal',
              'estado': 'mantenimiento'
            },
          ];
        }) ??
        <Map<String, dynamic>>[];
  }

  // ✅ LOAD SERVICIOS CON CACHE IMPLEMENTADO
  Future<List<Map<String, dynamic>>> _loadServicios() async {
    return await _cacheService.getCachedServicios(() async {
          try {
            final docs = await FirebaseFirestore.instance
                .collection('services')
                .where('activo', isEqualTo: true)
                .get();

            return docs.docs
                .map((doc) => {
                      'id': doc.id,
                      'nombre': doc['name'] ?? '',
                      'duracion': doc['duration'] ?? 60,
                      'tipo': doc['tipo'] ?? 'individual',
                      'categoria': doc['category'] ?? '',
                    })
                .toList();
          } catch (e) {
            debugPrint('⚠️ Error cargando servicios: $e');
            return <Map<String, dynamic>>[];
          }
        }) ??
        <Map<String, dynamic>>[];
  }

  // ✅ LOAD EVENTOS EXACTO DEL ORIGINAL
  Future<List<Map<String, dynamic>>> _loadEventos() async {
    try {
      final docs = await FirebaseFirestore.instance
          .collection('eventos')
          .where('estado', isEqualTo: 'activo')
          .get();

      return docs.docs
          .map((doc) => {
                'id': doc.id,
                'nombre': doc['nombre'] ?? '',
                'empresa': doc['empresa'] ?? '',
                'fecha': doc['fecha'],
                'tipo': 'corporativo',
              })
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error cargando eventos: $e');
      return [];
    }
  }

  // ========================================================================
  // 🎯 MÉTODOS DE BLOQUEOS OPTIMIZADOS EXACTOS DEL ORIGINAL
  // ========================================================================

  // ✅ LOAD BLOQUEOS CON FALLBACK EXACTO DEL ORIGINAL
  Future<Map<DateTime, List<Map<String, dynamic>>>> _loadBloqueosConFallback(
      AgendaStateManager stateManager) async {
    try {
      // ✅ VERIFICAR SI LA COLECCIÓN EXISTE
      if (!(await _checkBloqueosCollectionExists(stateManager))) {
        debugPrint(
            '📝 Colección bloqueos no existe - creando estructura básica');
        await _createBloqueosCollectionIfNeeded(stateManager);
        return {};
      }

      // ✅ ESTRATEGIA 1: Intentar consulta optimizada
      try {
        final result = await _loadBloqueosSimple(stateManager);
        debugPrint('✅ Bloqueos cargados con consulta optimizada');
        return result;
      } catch (e) {
        debugPrint('⚠️ Error en consulta optimizada: $e');
      }

      // ✅ ESTRATEGIA 2: Fallback a consulta básica
      try {
        stateManager.bloqueosIndexAvailable = false;
        final result = await _loadBloqueosBasic();
        debugPrint('✅ Bloqueos cargados con consulta básica (fallback)');
        return result;
      } catch (e1) {
        debugPrint('⚠️ Error en consulta básica: $e1');

        // ✅ ESTRATEGIA 3: Crear estructura si no existe
        if (!stateManager.bloqueosCollectionExists) {
          debugPrint('📝 Colección no disponible - creando estructura básica');
          await _createBloqueosCollectionIfNeeded(stateManager);
          return {};
        }

        // ✅ ESTRATEGIA 4: Cargar sin filtros complejos
        return await _loadBloqueosBasic();
      }
    } catch (e2) {
      debugPrint('❌ Error en fallback de bloqueos: $e2');
      return {};
    }
  }

  // ✅ CONSULTA SIMPLE SIN ÍNDICE COMPUESTO EXACTA DEL ORIGINAL
  Future<Map<DateTime, List<Map<String, dynamic>>>> _loadBloqueosSimple(
      AgendaStateManager stateManager) async {
    final Map<DateTime, List<Map<String, dynamic>>> result = {};

    try {
      // ✅ CONSULTA SIMPLE: Solo por fecha (sin estado)
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));
      final endDate = now.add(const Duration(days: 60));

      final snapshot = await FirebaseFirestore.instance
          .collection('bloqueos')
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .limit(100) // Limitar para rendimiento
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // ✅ FILTRAR EN CLIENTE: Solo bloqueos activos
        if (data['estado'] != 'activo') continue;

        if (!data.containsKey('fecha') || data['fecha'] == null) continue;

        DateTime fecha;
        if (data['fecha'] is Timestamp) {
          fecha = (data['fecha'] as Timestamp).toDate();
        } else if (data['fecha'] is String) {
          fecha = DateTime.tryParse(data['fecha']) ?? DateTime.now();
        } else {
          continue;
        }

        final fechaKey = DateTime(fecha.year, fecha.month, fecha.day);
        final bloqueoData = Map<String, dynamic>.from(data);
        bloqueoData['id'] = doc.id;

        result.putIfAbsent(fechaKey, () => []).add(bloqueoData);
      }

      debugPrint(
          '✅ Bloqueos cargados (consulta simple): ${result.length} días');
      stateManager.bloqueosIndexAvailable = true;

      return result;
    } catch (e) {
      debugPrint('❌ Error en consulta simple de bloqueos: $e');
      rethrow;
    }
  }

  // ✅ CONSULTA BÁSICA SIN FILTROS EXACTA DEL ORIGINAL
  Future<Map<DateTime, List<Map<String, dynamic>>>> _loadBloqueosBasic() async {
    final Map<DateTime, List<Map<String, dynamic>>> result = {};

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bloqueos')
          .limit(50) // Limitar para evitar sobrecarga
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // ✅ FILTRAR EN CLIENTE
        if (data['estado'] != 'activo') continue;

        if (!data.containsKey('fecha') || data['fecha'] == null) continue;

        DateTime fecha;
        if (data['fecha'] is Timestamp) {
          fecha = (data['fecha'] as Timestamp).toDate();
        } else if (data['fecha'] is String) {
          fecha = DateTime.tryParse(data['fecha']) ?? DateTime.now();
        } else {
          continue;
        }

        final fechaKey = DateTime(fecha.year, fecha.month, fecha.day);
        final bloqueoData = Map<String, dynamic>.from(data);
        bloqueoData['id'] = doc.id;

        result.putIfAbsent(fechaKey, () => []).add(bloqueoData);
      }

      debugPrint(
          '✅ Bloqueos cargados (consulta básica): ${result.length} días');
      return result;
    } catch (e) {
      debugPrint('❌ Error en consulta básica de bloqueos: $e');
      return {};
    }
  }

  // ✅ VERIFICAR EXISTENCIA DE COLECCIÓN EXACTO DEL ORIGINAL
  Future<bool> _checkBloqueosCollectionExists(
      AgendaStateManager stateManager) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bloqueos')
          .limit(1)
          .get();

      final exists = snapshot.docs.isNotEmpty;
      stateManager.bloqueosCollectionExists = exists;

      return exists;
    } catch (e) {
      debugPrint('⚠️ Error verificando colección bloqueos: $e');
      return false;
    }
  }

  // ✅ CREAR COLECCIÓN BÁSICA SI NO EXISTE EXACTO DEL ORIGINAL
  Future<void> _createBloqueosCollectionIfNeeded(
      AgendaStateManager stateManager) async {
    try {
      // Crear documento ejemplo para establecer la estructura
      await FirebaseFirestore.instance.collection('bloqueos').add({
        'profesionalId': 'ejemplo',
        'fecha': Timestamp.fromDate(DateTime.now()),
        'horaInicio': '09:00',
        'horaFin': '09:30',
        'motivo': 'Documento de estructura',
        'tipo': 'sistema',
        'estado': 'inactivo', // Inactivo para que no aparezca en consultas
        'creadoPor': 'Sistema',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Estructura de bloqueos creada');
      stateManager.bloqueosCollectionExists = true;
    } catch (e) {
      debugPrint('❌ Error creando estructura de bloqueos: $e');
    }
  }

  // ========================================================================
  // 🎯 MÉTODOS DE LISTENERS EN TIEMPO REAL EXACTOS DEL ORIGINAL
  // ========================================================================

  // ✅ SETUP REALTIME LISTENERS EXACTO DEL ORIGINAL
  void setupRealtimeListeners(AgendaStateManager stateManager) {
    // ✅ LISTENER DE CITAS (CON THROTTLING)
    stateManager.appointmentsSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .orderBy('fecha')
        .snapshots()
        .listen((snapshot) {
      _processAppointmentsSnapshot(snapshot, stateManager);
    }, onError: (error) {
      debugPrint('❌ Error en listener de citas: $error');
    });

    // ✅ LISTENER DE PROFESIONALES (MENOS FRECUENTE)
    stateManager.profesionalesSubscription = FirebaseFirestore.instance
        .collection('profesionales')
        .where('estado', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _processProfesionalesSnapshot(snapshot, stateManager);
    }, onError: (error) {
      debugPrint('❌ Error en listener de profesionales: $error');
    });

    // ✅ LISTENER DE BLOQUEOS OPTIMIZADO CON VALIDACIÓN
    _setupBloqueosListenerOptimizado(stateManager);
  }

  // 🔧 LISTENER DE BLOQUEOS OPTIMIZADO EXACTO DEL ORIGINAL
  void _setupBloqueosListenerOptimizado(AgendaStateManager stateManager) {
    // Solo configurar si sabemos que la colección existe
    if (!stateManager.bloqueosCollectionExists) {
      debugPrint('📝 Colección bloqueos no existe - listener no configurado');
      return;
    }

    try {
      if (stateManager.bloqueosIndexAvailable) {
        // ✅ LISTENER CON CONSULTA SIMPLE (SIN ÍNDICE COMPUESTO)
        stateManager.bloqueosSubscription = FirebaseFirestore.instance
            .collection('bloqueos')
            .where('fecha',
                isGreaterThanOrEqualTo: Timestamp.fromDate(
                    DateTime.now().subtract(const Duration(days: 7))))
            .where('fecha',
                isLessThanOrEqualTo: Timestamp.fromDate(
                    DateTime.now().add(const Duration(days: 30))))
            .limit(50)
            .snapshots()
            .listen((snapshot) {
          _processBloqueosSnapshotOptimizado(snapshot, stateManager);
        }, onError: (error) {
          debugPrint('❌ Error en listener de bloqueos optimizado: $error');
          _setupBloqueosListenerBasico(stateManager); // Fallback
        });
      } else {
        _setupBloqueosListenerBasico(stateManager);
      }
    } catch (e) {
      debugPrint('❌ Error configurando listener de bloqueos: $e');
      _setupBloqueosListenerBasico(stateManager);
    }
  }

  // ✅ LISTENER BÁSICO SIN FILTROS COMPLEJOS EXACTO DEL ORIGINAL
  void _setupBloqueosListenerBasico(AgendaStateManager stateManager) {
    stateManager.bloqueosSubscription = FirebaseFirestore.instance
        .collection('bloqueos')
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      _processBloqueosSnapshotOptimizado(snapshot, stateManager);
    }, onError: (error) {
      debugPrint('❌ Error en listener básico de bloqueos: $error');
    });
  }

  // ========================================================================
  // 🎯 PROCESADORES DE SNAPSHOTS EXACTOS DEL ORIGINAL
  // ========================================================================

  // ✅ PROCESS APPOINTMENTS SNAPSHOT EXACTO DEL ORIGINAL
  void _processAppointmentsSnapshot(
      QuerySnapshot snapshot, AgendaStateManager stateManager) {
    // 🎯 TRACKING REAL ACTIVADO - MODIFICACIÓN 7A
    trackReadIfLiveMode(1, 'listener citas');

    try {
      final Map<DateTime, List<AppointmentModel>> appointmentsMap = {};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final appointment = AppointmentModel.fromMap(data, doc.id);

        if (appointment.fechaInicio != null) {
          final dateKey = DateTime(
            appointment.fechaInicio!.year,
            appointment.fechaInicio!.month,
            appointment.fechaInicio!.day,
          );
          appointmentsMap.putIfAbsent(dateKey, () => []).add(appointment);
        }
      }

      stateManager.appointments = appointmentsMap;
      stateManager.calculateMetrics(appointmentsMap);
    } catch (e) {
      debugPrint('❌ Error procesando snapshot de citas: $e');
    }
  }

  // ✅ PROCESS PROFESIONALES SNAPSHOT EXACTO DEL ORIGINAL
  void _processProfesionalesSnapshot(
      QuerySnapshot snapshot, AgendaStateManager stateManager) {
    try {
      final profesionales = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'nombre': '${data['nombre']} ${data['apellidos'] ?? ''}'.trim(),
          'especialidades': data['especialidades'] ?? [],
          'avatar': data['fotoUrl'] ?? '',
          'estado': 'activo',
        };
      }).toList();

      stateManager.profesionales = profesionales;
    } catch (e) {
      debugPrint('❌ Error procesando snapshot de profesionales: $e');
    }
  }

  // ✅ PROCESS BLOQUEOS SNAPSHOT OPTIMIZADO EXACTO DEL ORIGINAL
  void _processBloqueosSnapshotOptimizado(
      QuerySnapshot snapshot, AgendaStateManager stateManager) {
    // 🎯 TRACKING REAL ACTIVADO - MODIFICACIÓN 7B
    trackReadIfLiveMode(1, 'listener bloqueos');

    try {
      final Map<DateTime, List<Map<String, dynamic>>> bloqueosMap = {};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // ✅ FILTRAR EN CLIENTE: Solo bloqueos activos
        if (data['estado'] != 'activo') continue;

        if (!data.containsKey('fecha') || data['fecha'] == null) continue;

        DateTime fecha;
        if (data['fecha'] is Timestamp) {
          fecha = (data['fecha'] as Timestamp).toDate();
        } else if (data['fecha'] is String) {
          fecha = DateTime.tryParse(data['fecha']) ?? DateTime.now();
        } else {
          continue;
        }

        final fechaKey = DateTime(fecha.year, fecha.month, fecha.day);
        final bloqueoData = Map<String, dynamic>.from(data);
        bloqueoData['id'] = doc.id;

        bloqueosMap.putIfAbsent(fechaKey, () => []).add(bloqueoData);
      }

      stateManager.bloqueos = bloqueosMap;
      debugPrint(
          '🔄 Bloqueos actualizados en tiempo real: ${bloqueosMap.length} días');
    } catch (e) {
      debugPrint('❌ Error procesando snapshot de bloqueos: $e');
    }
  }

  // ========================================================================
  // 🎯 CORRECCIÓN 2C: CONTROL DE LIVE MODE - INTEGRACIÓN COST CONTROL
  // ========================================================================

  /// Conectar con el monitor de costos
  void setCostMonitor(BackgroundCostMonitor costMonitor) {
    _costMonitor = costMonitor;
    debugPrint('🔗 CostMonitor conectado al DataService');
  }

  /// Activar/desactivar Live Mode desde el dashboard
  void setLiveMode(bool enabled) {
    _isLiveModeEnabled = enabled;
    debugPrint('🔄 Live Mode interno: ${enabled ? "ACTIVADO" : "DESACTIVADO"}');

    // Aquí se pueden activar/desactivar listeners específicos
    if (enabled) {
      debugPrint('⚡ Activando listeners de tiempo real');
      // TODO: Activar listeners específicos si es necesario
    } else {
      debugPrint('⏸️ Pausando listeners de tiempo real');
      // TODO: Pausar listeners específicos si es necesario
    }
  }

  /// Obtener estado actual del Live Mode
  bool get isLiveModeEnabled => _isLiveModeEnabled;

  /// Incrementar tracking cuando Live Mode está activo - AHORA FUNCIONAL
  void trackReadIfLiveMode(int reads, String description) {
    if (_isLiveModeEnabled && _costMonitor != null) {
      debugPrint(
          '📊 Tracking REAL: +$reads lecturas ($description) - Live Mode activo');
      _costMonitor!.incrementReadCount(reads, description: description);
    } else if (_isLiveModeEnabled) {
      debugPrint('⚠️ Live Mode activo pero costMonitor no conectado');
    }
  }

  // ========================================================================
  // 🆕 IMPLEMENTACIÓN CACHE SYSTEM - MÉTODOS PÚBLICOS
  // ========================================================================

  /// 💾 Activar sistema de cache inteligente
  Future<void> enableCache() async {
    try {
      await _cacheService.initialize();
      await _cacheService.setEnabled(true);
      debugPrint('💾 ✅ Sistema de cache activado exitosamente');
    } catch (e) {
      debugPrint('💾 ❌ Error activando cache: $e');
      rethrow;
    }
  }

  /// 💾 Desactivar sistema de cache
  Future<void> disableCache() async {
    try {
      await _cacheService.setEnabled(false);
      debugPrint('💾 ⏸️ Sistema de cache desactivado');
    } catch (e) {
      debugPrint('💾 ❌ Error desactivando cache: $e');
      rethrow;
    }
  }

  /// 💾 Obtener estado del cache
  bool get isCacheEnabled => _cacheService.isEnabled;

  /// 💾 Limpiar cache manualmente
  Future<void> clearCache() async {
    try {
      await _cacheService.clearAllCache();
      debugPrint('💾 🧹 Cache limpiado manualmente');
    } catch (e) {
      debugPrint('💾 ❌ Error limpiando cache: $e');
      rethrow;
    }
  }

  /// 💾 Obtener estadísticas del cache
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      return await _cacheService.getCacheStats();
    } catch (e) {
      debugPrint('💾 ❌ Error obteniendo estadísticas de cache: $e');
      return {};
    }
  }

  /// 💾 Invalidar cache específico
  Future<void> invalidateCache(String key) async {
    try {
      await _cacheService.invalidateCache(key);
      debugPrint('💾 🗑️ Cache invalidado para: $key');
    } catch (e) {
      debugPrint('💾 ❌ Error invalidando cache: $e');
    }
  }
}
