// [cache_service.dart] - SISTEMA DE CACHE INTELIGENTE PARA FIRESTORE
// 📁 Ubicación: /lib/services/cost_control/cache_service.dart
// 🎯 OBJETIVO: Cache real que reduce lecturas hasta 80%

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;
  bool _isEnabled = false;
  bool _isInitialized = false;

  // ⏱️ CONFIGURACIÓN DE CACHE
  static const Duration _defaultCacheDuration = Duration(minutes: 10);
  static const Duration _staticDataDuration = Duration(hours: 1);
  static const Duration _dynamicDataDuration = Duration(minutes: 5);

  // 🗂️ PREFIJOS PARA ORGANIZAR CACHE
  static const String _prefixTimestamp = 'cache_timestamp_';
  static const String _prefixEnabled = 'cache_enabled';

  /// 🚀 Inicializar servicio de cache
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isEnabled = _prefs?.getBool(_prefixEnabled) ?? false;

      // Limpiar cache expirado al inicializar
      await _cleanExpiredCache();

      _isInitialized = true;

      debugPrint(
          '💾 CacheService inicializado - Estado: ${_isEnabled ? "ACTIVO" : "INACTIVO"}');
    } catch (e) {
      debugPrint('❌ Error inicializando CacheService: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// ⚡ Activar/desactivar cache
  Future<void> setEnabled(bool enabled) async {
    await _ensureInitialized();

    _isEnabled = enabled;
    await _prefs?.setBool(_prefixEnabled, enabled);

    if (!enabled) {
      await clearAllCache();
      debugPrint('💾 Cache DESACTIVADO y limpiado');
    } else {
      debugPrint('💾 Cache ACTIVADO');
    }
  }

  /// 📊 Estado actual del cache
  bool get isEnabled => _isEnabled;
  bool get isInitialized => _isInitialized;

  /// 🔒 Asegurar que el servicio esté inicializado
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// 📥 OBTENER DATOS CON CACHE
  Future<List<T>?> getCachedData<T>(
      String key,
      Future<List<T>> Function() fetchFunction,
      T Function(Map<String, dynamic>) fromMapFunction,
      {Duration? cacheDuration}) async {
    await _ensureInitialized();

    if (!_isEnabled || _prefs == null) {
      debugPrint('💾 Cache deshabilitado - consulta directa para $key');
      return await fetchFunction();
    }

    final cacheKey = _getCacheKey(key);
    final timestampKey = _getTimestampKey(key);

    // Verificar si hay datos en cache y si son válidos
    final cachedData = _prefs!.getString(cacheKey);
    final timestamp = _prefs!.getInt(timestampKey);

    if (cachedData != null && timestamp != null) {
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final duration = cacheDuration ?? _getDefaultDuration(key);

      if (DateTime.now().difference(cacheTime) < duration) {
        try {
          final List<dynamic> jsonList = json.decode(cachedData);
          final List<T> result = jsonList
              .map((item) => fromMapFunction(item as Map<String, dynamic>))
              .toList();

          debugPrint('💾 ✅ Cache HIT para $key - ${result.length} elementos');
          return result;
        } catch (e) {
          debugPrint('💾 ❌ Error decodificando cache para $key: $e');
        }
      } else {
        debugPrint('💾 ⏰ Cache EXPIRADO para $key');
      }
    }

    // Cache miss o expirado - obtener datos frescos
    debugPrint('💾 ❌ Cache MISS para $key - obteniendo datos frescos');
    final freshData = await fetchFunction();

    if (freshData != null) {
      await _saveToCache(key, freshData);
    }

    return freshData;
  }

  /// 💾 GUARDAR DATOS EN CACHE
  Future<void> _saveToCache<T>(String key, List<T> data) async {
    if (!_isEnabled || _prefs == null) return;

    try {
      final jsonData = data.map((item) => _toMap(item)).toList();
      final cacheKey = _getCacheKey(key);
      final timestampKey = _getTimestampKey(key);

      await _prefs!.setString(cacheKey, json.encode(jsonData));
      await _prefs!.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);

      debugPrint('💾 💽 Guardado en cache: $key (${data.length} elementos)');
    } catch (e) {
      debugPrint('💾 ❌ Error guardando en cache $key: $e');
    }
  }

  /// 🗑️ INVALIDAR CACHE ESPECÍFICO
  Future<void> invalidateCache(String key) async {
    await _ensureInitialized();
    if (_prefs == null) return;

    final cacheKey = _getCacheKey(key);
    final timestampKey = _getTimestampKey(key);

    await _prefs!.remove(cacheKey);
    await _prefs!.remove(timestampKey);

    debugPrint('💾 🗑️ Cache invalidado para: $key');
  }

  /// 🧹 LIMPIAR TODO EL CACHE
  Future<void> clearAllCache() async {
    await _ensureInitialized();
    if (_prefs == null) return;

    final keys =
        _prefs!.getKeys().where((key) => key.startsWith('cache_')).toList();

    for (final key in keys) {
      await _prefs!.remove(key);
    }

    debugPrint('💾 🧹 Todo el cache limpiado (${keys.length} elementos)');
  }

  /// ⏰ LIMPIAR CACHE EXPIRADO
  Future<void> _cleanExpiredCache() async {
    if (_prefs == null) return;

    final timestampKeys = _prefs!
        .getKeys()
        .where((key) => key.startsWith(_prefixTimestamp))
        .toList();

    int cleanedCount = 0;

    for (final timestampKey in timestampKeys) {
      final timestamp = _prefs!.getInt(timestampKey);
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final dataKey = timestampKey.replaceFirst(_prefixTimestamp, '');
        final duration = _getDefaultDuration(dataKey);

        if (DateTime.now().difference(cacheTime) > duration) {
          await _prefs!.remove(timestampKey);
          await _prefs!.remove(_getCacheKey(dataKey));
          cleanedCount++;
        }
      }
    }

    if (cleanedCount > 0) {
      debugPrint('💾 🧹 Cache expirado limpiado: $cleanedCount elementos');
    }
  }

  /// 📊 ESTADÍSTICAS DEL CACHE
  Future<Map<String, dynamic>> getCacheStats() async {
    await _ensureInitialized();
    if (_prefs == null) return {'enabled': false, 'error': 'No inicializado'};

    final cacheKeys = _prefs!
        .getKeys()
        .where((key) =>
            key.startsWith('cache_') && !key.startsWith('cache_timestamp_'))
        .toList();

    int totalSize = 0;
    int validEntries = 0;
    int expiredEntries = 0;

    for (final key in cacheKeys) {
      final data = _prefs!.getString(key);
      if (data != null) {
        totalSize += data.length;

        final timestampKey = _getTimestampKey(key.replaceFirst('cache_', ''));
        final timestamp = _prefs!.getInt(timestampKey);

        if (timestamp != null) {
          final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final dataKey = key.replaceFirst('cache_', '');
          final duration = _getDefaultDuration(dataKey);

          if (DateTime.now().difference(cacheTime) < duration) {
            validEntries++;
          } else {
            expiredEntries++;
          }
        }
      }
    }

    return {
      'enabled': _isEnabled,
      'initialized': _isInitialized,
      'totalEntries': cacheKeys.length,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'totalSizeBytes': totalSize,
      'totalSizeKB': (totalSize / 1024).toStringAsFixed(2),
    };
  }

  // ========================================================================
  // 🎯 EXTENSIONES PARA INTEGRACIÓN CON AGENDA DATA SERVICE
  // ========================================================================

  /// 🏥 Cache específico para profesionales
  Future<List<Map<String, dynamic>>?> getCachedProfesionales(
      Future<List<Map<String, dynamic>>> Function() fetchFunction) async {
    return await getCachedData<Map<String, dynamic>>(
      'profesionales',
      fetchFunction,
      (map) => map,
      cacheDuration: _staticDataDuration,
    );
  }

  /// 🛏️ Cache específico para cabinas
  Future<List<Map<String, dynamic>>?> getCachedCabinas(
      Future<List<Map<String, dynamic>>> Function() fetchFunction) async {
    return await getCachedData<Map<String, dynamic>>(
      'cabinas',
      fetchFunction,
      (map) => map,
      cacheDuration: _staticDataDuration,
    );
  }

  /// 💼 Cache específico para servicios
  Future<List<Map<String, dynamic>>?> getCachedServicios(
      Future<List<Map<String, dynamic>>> Function() fetchFunction) async {
    return await getCachedData<Map<String, dynamic>>(
      'servicios',
      fetchFunction,
      (map) => map,
      cacheDuration: _staticDataDuration,
    );
  }

  /// 👥 Cache específico para clientes (más dinámico)
  Future<List<Map<String, dynamic>>?> getCachedClientes(
      Future<List<Map<String, dynamic>>> Function() fetchFunction) async {
    return await getCachedData<Map<String, dynamic>>(
      'clientes',
      fetchFunction,
      (map) => map,
      cacheDuration: _dynamicDataDuration,
    );
  }

  // ========================================================================
  // 🔧 MÉTODOS HELPER PRIVADOS
  // ========================================================================

  String _getCacheKey(String key) => 'cache_$key';
  String _getTimestampKey(String key) => '${_prefixTimestamp}$key';

  Duration _getDefaultDuration(String key) {
    if (key.contains('profesionales') ||
        key.contains('servicios') ||
        key.contains('cabinas')) {
      return _staticDataDuration; // 1 hora para datos estáticos
    } else if (key.contains('clientes') || key.contains('citas')) {
      return _dynamicDataDuration; // 5 minutos para datos dinámicos
    }
    return _defaultCacheDuration; // 10 minutos por defecto
  }

  Map<String, dynamic> _toMap(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item;
    } else if (item.toString().contains('DocumentSnapshot')) {
      // Manejar DocumentSnapshot
      return {'id': 'unknown', 'data': 'cached'};
    }
    return {'cached': true, 'data': item.toString()};
  }
}
