// [user_preferences_service.dart] - SERVICIO ENTERPRISE DE PREFERENCIAS
// 📁 Ubicación: /lib/services/user_preferences_service.dart
// 🎯 OBJETIVO: Persistencia robusta con validación y analytics

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agenda_fisio_spa_kym/enums/view_mode.dart';

/// 🏢 SERVICIO ENTERPRISE DE PREFERENCIAS DE USUARIO
/// Maneja persistencia, validación, cache y analytics de preferencias
class UserPreferencesService {
  static UserPreferencesService? _instance;
  static UserPreferencesService get instance =>
      _instance ??= UserPreferencesService._internal();
  UserPreferencesService._internal();

  // ✅ CONSTANTES DE CONFIGURACIÓN
  static const String _viewModeKey = 'client_list_view_mode';
  static const String _userMetricsKey = 'user_metrics';
  static const String _lastSyncKey = 'preferences_last_sync';
  static const String _versionKey = 'preferences_version';

  static const int _currentVersion = 1;
  static const Duration _cacheExpiry = Duration(hours: 24);

  // ✅ CACHE EN MEMORIA PARA PERFORMANCE
  ViewMode? _cachedViewMode;
  Map<String, dynamic>? _cachedMetrics;
  DateTime? _lastCacheUpdate;

  /// 🚀 INICIALIZACIÓN DEL SERVICIO
  Future<void> initialize() async {
    debugPrint('🚀 Inicializando UserPreferencesService...');

    try {
      await _validateAndMigratePreferences();
      // ✅ CORREGIDO: NO pre-cargar cache aquí para evitar loops

      debugPrint('✅ UserPreferencesService inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error inicializando UserPreferencesService: $e');
      await _resetToDefaults();
    }
  }

  /// 📱 GESTIÓN DE VIEW MODE

  /// Obtener modo de vista (con cache inteligente)
  Future<ViewMode> getViewMode() async {
    // 1️⃣ Verificar cache en memoria
    if (_cachedViewMode != null && _isCacheValid()) {
      debugPrint('💾 ViewMode desde cache: ${_cachedViewMode!.displayName}');
      return _cachedViewMode!;
    }

    // 2️⃣ Cargar desde SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_viewModeKey);

      ViewMode mode;
      if (stored != null) {
        mode = ViewMode.fromString(stored);
        debugPrint('💿 ViewMode desde storage: ${mode.displayName}');
      } else {
        mode = ViewMode.compact; // DEFAULT ENTERPRISE
        debugPrint('🆕 ViewMode default asignado: ${mode.displayName}');
        // ✅ CORREGIDO: NO llamar setViewMode aquí para evitar loop infinito
        // Solo persistir directamente sin callbacks
        await prefs.setString(_viewModeKey, mode.toString());
      }

      // 3️⃣ Actualizar cache
      _cachedViewMode = mode;
      _lastCacheUpdate = DateTime.now();

      return mode;
    } catch (e) {
      debugPrint('❌ Error obteniendo ViewMode: $e');
      return ViewMode.compact; // Fallback seguro
    }
  }

  /// Establecer modo de vista (con validación y analytics)
  Future<void> setViewMode(ViewMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1️⃣ Validar el modo
      if (!ViewMode.values.contains(mode)) {
        throw ArgumentError('ViewMode inválido: $mode');
      }

      // 2️⃣ Obtener modo anterior para analytics
      final previousMode = _cachedViewMode ?? await getViewMode();

      // 3️⃣ Persistir nuevo modo
      await prefs.setString(_viewModeKey, mode.toString());

      // 4️⃣ Actualizar cache
      _cachedViewMode = mode;
      _lastCacheUpdate = DateTime.now();

      // 5️⃣ Registrar métricas de uso
      await _recordViewModeChange(previousMode, mode);

      debugPrint('✅ ViewMode actualizado: ${mode.displayName}');
    } catch (e) {
      debugPrint('❌ Error estableciendo ViewMode: $e');
      rethrow;
    }
  }

  /// 📊 GESTIÓN DE MÉTRICAS DE USUARIO

  /// Obtener métricas de uso (para analytics y optimización)
  Future<Map<String, dynamic>> getUserMetrics() async {
    if (_cachedMetrics != null && _isCacheValid()) {
      return _cachedMetrics!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsJson = prefs.getString(_userMetricsKey);

      Map<String, dynamic> metrics;
      if (metricsJson != null) {
        metrics = json.decode(metricsJson) as Map<String, dynamic>;
      } else {
        metrics = _getDefaultMetrics();
        await _saveMetrics(metrics);
      }

      _cachedMetrics = metrics;
      return metrics;
    } catch (e) {
      debugPrint('❌ Error obteniendo métricas: $e');
      return _getDefaultMetrics();
    }
  }

  /// Registrar evento de uso para analytics
  Future<void> recordUsageEvent(String event, Map<String, dynamic> data) async {
    try {
      final metrics = await getUserMetrics();
      final events = List<Map<String, dynamic>>.from(metrics['events'] ?? []);

      events.add({
        'event': event,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Mantener solo los últimos 100 eventos
      if (events.length > 100) {
        events.removeRange(0, events.length - 100);
      }

      metrics['events'] = events;
      metrics['lastEventTimestamp'] = DateTime.now().toIso8601String();

      await _saveMetrics(metrics);
      debugPrint('📊 Evento registrado: $event');
    } catch (e) {
      debugPrint('❌ Error registrando evento: $e');
    }
  }

  /// 🧹 GESTIÓN DE CACHE Y LIMPIEZA

  /// Limpiar todas las preferencias (para logout o reset)
  Future<void> clearAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Limpiar keys específicos (mantener otros datos de la app)
      await Future.wait([
        prefs.remove(_viewModeKey),
        prefs.remove(_userMetricsKey),
        prefs.remove(_lastSyncKey),
        prefs.remove(_versionKey),
      ]);

      // Limpiar cache
      _cachedViewMode = null;
      _cachedMetrics = null;
      _lastCacheUpdate = null;

      debugPrint('🧹 Preferencias limpiadas');
    } catch (e) {
      debugPrint('❌ Error limpiando preferencias: $e');
    }
  }

  /// Invalidar cache manualmente
  void invalidateCache() {
    _cachedViewMode = null;
    _cachedMetrics = null;
    _lastCacheUpdate = null;
    debugPrint('🔄 Cache invalidado manualmente');
  }

  /// 🔧 MÉTODOS PRIVADOS

  Future<void> _loadCacheFromStorage() async {
    // Pre-cargar datos críticos en cache para performance inicial
    _cachedViewMode = await getViewMode();
    _cachedMetrics = await getUserMetrics();
  }

  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheExpiry;
  }

  Future<void> _validateAndMigratePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt(_versionKey) ?? 0;

    if (currentVersion < _currentVersion) {
      debugPrint(
          '🔄 Migrando preferencias de v$currentVersion a v$_currentVersion');

      // Aquí se pueden agregar migraciones futuras
      switch (currentVersion) {
        case 0:
          // Migración inicial - validar ViewMode existente
          final existingMode = prefs.getString(_viewModeKey);
          if (existingMode != null &&
              !ViewMode.values.any((m) => m.name == existingMode)) {
            await prefs.remove(_viewModeKey);
          }
          break;
      }

      await prefs.setInt(_versionKey, _currentVersion);
      debugPrint('✅ Migración completada');
    }
  }

  Future<void> _resetToDefaults() async {
    debugPrint('🔄 Reseteando a valores por defecto');
    await clearAllPreferences();
    await setViewMode(ViewMode.compact);
  }

  Future<void> _recordViewModeChange(ViewMode from, ViewMode to) async {
    await recordUsageEvent('view_mode_changed', {
      'from': from.name,
      'to': to.name,
      'fromHeight': from.cardHeight,
      'toHeight': to.cardHeight,
    });

    // Actualizar contadores específicos de ViewMode
    final metrics = await getUserMetrics();
    final viewModeUsage = Map<String, int>.from(metrics['viewModeUsage'] ?? {});
    viewModeUsage[to.name] = (viewModeUsage[to.name] ?? 0) + 1;

    metrics['viewModeUsage'] = viewModeUsage;
    metrics['lastViewModeChange'] = DateTime.now().toIso8601String();

    await _saveMetrics(metrics);
  }

  Map<String, dynamic> _getDefaultMetrics() {
    return {
      'viewModeUsage': {
        'compact': 0,
        'comfortable': 0,
        'table': 0,
      },
      'events': <Map<String, dynamic>>[],
      'createdAt': DateTime.now().toIso8601String(),
      'lastEventTimestamp': null,
      'lastViewModeChange': null,
    };
  }

  Future<void> _saveMetrics(Map<String, dynamic> metrics) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userMetricsKey, json.encode(metrics));

      _cachedMetrics = metrics;
      _lastCacheUpdate = DateTime.now();
    } catch (e) {
      debugPrint('❌ Error guardando métricas: $e');
    }
  }

  /// 📊 MÉTODOS DE ANALYTICS Y DEBUG

  /// Obtener reporte de uso para debug/analytics
  Future<Map<String, dynamic>> getUsageReport() async {
    final metrics = await getUserMetrics();
    final currentMode = await getViewMode();

    return {
      'currentViewMode': currentMode.name,
      'viewModeUsage': metrics['viewModeUsage'],
      'totalEvents': (metrics['events'] as List?)?.length ?? 0,
      'createdAt': metrics['createdAt'],
      'lastActivity': metrics['lastEventTimestamp'],
      'cacheStatus': {
        'isValid': _isCacheValid(),
        'lastUpdate': _lastCacheUpdate?.toIso8601String(),
        'cachedViewMode': _cachedViewMode?.name,
      },
      'performanceExpectations': currentMode.getPerformanceExpectations(),
    };
  }

  /// Health check del servicio
  Future<bool> healthCheck() async {
    try {
      final mode = await getViewMode();
      final metrics = await getUserMetrics();

      return mode != null &&
          metrics.isNotEmpty &&
          ViewMode.values.contains(mode);
    } catch (e) {
      debugPrint('❌ Health check falló: $e');
      return false;
    }
  }
}
