// [client_cache_service.dart] - CACHE INTELIGENTE CORREGIDO
// 📁 Ubicación: /lib/screens/clients/services/client_cache_service.dart
// 🎯 OBJETIVO: Cache persistente con serialización de Timestamps corregida

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/utils/client_constants.dart';

/// 💾 SERVICIO DE CACHE INTELIGENTE PARA CLIENTES
/// Implementa estrategia LRU + persistencia + serialización de Timestamps
class ClientCacheService {
  static final _instance = ClientCacheService._internal();
  factory ClientCacheService() => _instance;
  ClientCacheService._internal();

  // ✅ CONSTANTES DE CACHE
  static const String _clientsKey = 'cached_clients';
  static const String _lastSyncKey = 'last_sync_time';
  static const String _analyticsKey = 'cached_analytics';
  static const String _cacheMetadataKey = 'cache_metadata';

  // ✅ CACHE EN MEMORIA (LRU)
  final Map<String, ClientModel> _memoryCache = <String, ClientModel>{};
  final Map<String, DateTime> _accessTimes = <String, DateTime>{};
  final Map<String, ClientAnalytics> _analyticsCache =
      <String, ClientAnalytics>{};

  // ✅ METADATA DEL CACHE
  int _currentCacheSize = 0;
  DateTime? _lastCleanup;

  /// 🚀 INICIALIZACIÓN DEL CACHE
  Future<void> initialize() async {
    debugPrint('💾 Inicializando ClientCacheService...');

    try {
      await _loadCacheMetadata();
      await _performCleanupIfNeeded();
      debugPrint('✅ ClientCacheService inicializado');
    } catch (e) {
      debugPrint('❌ Error inicializando cache: $e');
    }
  }

  /// 📥 OBTENER TODOS LOS CLIENTES DEL CACHE
  Future<List<ClientModel>> getAllClients() async {
    debugPrint('📥 Cargando todos los clientes del cache...');

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_clientsKey);

      if (cachedData == null) {
        debugPrint('💾 No hay datos en cache persistente');
        return [];
      }

      final List<dynamic> jsonList = json.decode(cachedData);
      final clients = <ClientModel>[];

      for (final jsonData in jsonList) {
        try {
          // Convertir timestamps de vuelta a DateTime antes de crear el modelo
          final cleanedData = _convertTimestampsToDateTime(jsonData);
          final client =
              ClientModel.fromMap(cleanedData, cleanedData['clientId']);
          clients.add(client);
        } catch (e) {
          debugPrint('⚠️ Error procesando cliente del cache: $e');
          // Continuar con otros clientes
        }
      }

      // Cargar en memoria cache para acceso rápido
      for (final client in clients) {
        _memoryCache[client.clientId] = client;
        _accessTimes[client.clientId] = DateTime.now();
      }

      debugPrint('✅ Cargados ${clients.length} clientes del cache');
      return clients;
    } catch (e) {
      debugPrint('❌ Error cargando clientes del cache: $e');
      return [];
    }
  }

  /// 💾 GUARDAR TODOS LOS CLIENTES EN CACHE
  Future<void> setAllClients(List<ClientModel> clients) async {
    debugPrint('💾 Guardando ${clients.length} clientes en cache...');

    try {
      // 1️⃣ Convertir a JSON con manejo de Timestamps
      final jsonList = <Map<String, dynamic>>[];

      for (final client in clients) {
        final clientMap = client.toMap();
        final serializedMap = _convertTimestampsToStrings(clientMap);
        serializedMap['clientId'] = client.clientId; // Asegurar ID
        jsonList.add(serializedMap);
      }

      // 2️⃣ Usar toEncodable personalizado para manejar objetos no serializables
      final jsonString = json.encode(jsonList, toEncodable: _toEncodable);

      // 3️⃣ Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_clientsKey, jsonString);

      // 4️⃣ Actualizar memoria cache
      _memoryCache.clear();
      _accessTimes.clear();

      for (final client in clients) {
        _memoryCache[client.clientId] = client;
        _accessTimes[client.clientId] = DateTime.now();
      }

      // 5️⃣ Actualizar metadata
      _currentCacheSize = jsonString.length;
      await _saveCacheMetadata();

      debugPrint(
          '✅ Clientes guardados en cache (${_formatBytes(_currentCacheSize)})');
    } catch (e) {
      debugPrint('❌ Error guardando clientes en cache: $e');
      rethrow;
    }
  }

  /// 🔍 OBTENER CLIENTE ESPECÍFICO POR ID
  Future<ClientModel?> getClient(String clientId) async {
    // 1️⃣ Buscar primero en memoria (más rápido)
    if (_memoryCache.containsKey(clientId)) {
      _accessTimes[clientId] = DateTime.now(); // Actualizar tiempo de acceso
      debugPrint('⚡ Cliente encontrado en memoria cache: $clientId');
      return _memoryCache[clientId];
    }

    // 2️⃣ Buscar en cache persistente
    try {
      final allClients = await getAllClients();
      final client = allClients.firstWhere(
        (c) => c.clientId == clientId,
        orElse: () => throw StateError('Cliente no encontrado'),
      );

      debugPrint('💾 Cliente encontrado en cache persistente: $clientId');
      return client;
    } catch (e) {
      debugPrint('❌ Cliente no encontrado en cache: $clientId');
      return null;
    }
  }

  /// ➕ GUARDAR/ACTUALIZAR CLIENTE INDIVIDUAL
  Future<void> setClient(ClientModel client) async {
    debugPrint('💾 Actualizando cliente en cache: ${client.clientId}');

    try {
      // 1️⃣ Actualizar memoria cache
      _memoryCache[client.clientId] = client;
      _accessTimes[client.clientId] = DateTime.now();

      // 2️⃣ Mantener límite de memoria cache (LRU)
      await _enforceLRULimit();

      // 3️⃣ Actualizar cache persistente
      await _updatePersistentCache();

      debugPrint('✅ Cliente actualizado en cache');
    } catch (e) {
      debugPrint('❌ Error actualizando cliente en cache: $e');
      rethrow;
    }
  }

  /// 🗑️ ELIMINAR CLIENTE DEL CACHE
  Future<void> removeClient(String clientId) async {
    debugPrint('🗑️ Eliminando cliente del cache: $clientId');

    try {
      // 1️⃣ Eliminar de memoria
      _memoryCache.remove(clientId);
      _accessTimes.remove(clientId);

      // 2️⃣ Actualizar cache persistente
      await _updatePersistentCache();

      debugPrint('✅ Cliente eliminado del cache');
    } catch (e) {
      debugPrint('❌ Error eliminando cliente del cache: $e');
      rethrow;
    }
  }

  /// ⏰ GESTIÓN DE TIEMPO DE SINCRONIZACIÓN
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastSyncKey);
      return timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null;
    } catch (e) {
      debugPrint('❌ Error obteniendo tiempo de sincronización: $e');
      return null;
    }
  }

  Future<void> setLastSyncTime(DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, time.millisecondsSinceEpoch);
      debugPrint('✅ Tiempo de sincronización actualizado: $time');
    } catch (e) {
      debugPrint('❌ Error guardando tiempo de sincronización: $e');
    }
  }

  /// 📊 CACHE DE ANALYTICS
  Future<ClientAnalytics?> getClientAnalytics(String key) async {
    // 1️⃣ Buscar en memoria
    if (_analyticsCache.containsKey(key)) {
      final analytics = _analyticsCache[key]!;

      // Verificar si no ha expirado
      final age = DateTime.now().difference(analytics.lastUpdated);
      if (age.inHours < ClientConstants.CACHE_EXPIRY_HOURS) {
        debugPrint('⚡ Analytics encontrados en memoria cache');
        return analytics;
      } else {
        _analyticsCache.remove(key);
      }
    }

    // 2️⃣ Buscar en cache persistente
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('$_analyticsKey\_$key');

      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        final analytics = ClientAnalytics.fromMap(jsonData);

        // Verificar si no ha expirado
        final age = DateTime.now().difference(analytics.lastUpdated);
        if (age.inHours < ClientConstants.CACHE_EXPIRY_HOURS) {
          _analyticsCache[key] = analytics;
          debugPrint('💾 Analytics encontrados en cache persistente');
          return analytics;
        }
      }
    } catch (e) {
      debugPrint('❌ Error cargando analytics del cache: $e');
    }

    return null;
  }

  Future<void> setClientAnalytics(String key, ClientAnalytics analytics) async {
    debugPrint('💾 Guardando analytics en cache: $key');

    try {
      // 1️⃣ Guardar en memoria
      _analyticsCache[key] = analytics;

      // 2️⃣ Guardar en cache persistente con serialización segura
      final prefs = await SharedPreferences.getInstance();
      final analyticsMap = analytics.toMap();
      final serializedMap = _convertTimestampsToStrings(analyticsMap);
      final jsonString = json.encode(serializedMap, toEncodable: _toEncodable);
      await prefs.setString('$_analyticsKey\_$key', jsonString);

      debugPrint('✅ Analytics guardados en cache');
    } catch (e) {
      debugPrint('❌ Error guardando analytics en cache: $e');
    }
  }

  /// 🧹 LIMPIEZA Y MANTENIMIENTO
  Future<void> clearAll() async {
    debugPrint('🧹 Limpiando todo el cache...');

    try {
      final prefs = await SharedPreferences.getInstance();

      // Eliminar claves relacionadas con clientes
      await prefs.remove(_clientsKey);
      await prefs.remove(_lastSyncKey);
      await prefs.remove(_cacheMetadataKey);

      // Eliminar analytics cache
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_analyticsKey)) {
          await prefs.remove(key);
        }
      }

      // Limpiar memoria
      _memoryCache.clear();
      _accessTimes.clear();
      _analyticsCache.clear();
      _currentCacheSize = 0;

      debugPrint('✅ Cache limpiado completamente');
    } catch (e) {
      debugPrint('❌ Error limpiando cache: $e');
    }
  }

  Future<void> cleanup() async {
    debugPrint('🧹 Iniciando limpieza de cache...');

    try {
      // 1️⃣ Limpiar entries expirados en memoria
      final now = DateTime.now();
      final expiredKeys = <String>[];

      for (final entry in _accessTimes.entries) {
        final age = now.difference(entry.value);
        if (age.inHours > ClientConstants.CACHE_EXPIRY_HOURS) {
          expiredKeys.add(entry.key);
        }
      }

      for (final key in expiredKeys) {
        _memoryCache.remove(key);
        _accessTimes.remove(key);
      }

      // 2️⃣ Limpiar analytics expirados
      final expiredAnalytics = <String>[];
      for (final entry in _analyticsCache.entries) {
        final age = now.difference(entry.value.lastUpdated);
        if (age.inHours > ClientConstants.CACHE_EXPIRY_HOURS) {
          expiredAnalytics.add(entry.key);
        }
      }

      for (final key in expiredAnalytics) {
        _analyticsCache.remove(key);
      }

      // 3️⃣ Aplicar límite LRU si es necesario
      await _enforceLRULimit();

      // 4️⃣ Actualizar metadata
      _lastCleanup = now;
      await _saveCacheMetadata();

      debugPrint(
          '✅ Limpieza completada: ${expiredKeys.length} clientes, ${expiredAnalytics.length} analytics');
    } catch (e) {
      debugPrint('❌ Error en limpieza de cache: $e');
    }
  }

  /// 📊 ESTADÍSTICAS DEL CACHE
  Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    final totalItems = _memoryCache.length;
    final cacheAge =
        _lastCleanup != null ? now.difference(_lastCleanup!).inMinutes : 0;

    return {
      'memoryItems': totalItems,
      'cacheSize': _formatBytes(_currentCacheSize),
      'cacheSizeBytes': _currentCacheSize,
      'lastCleanup': _lastCleanup?.toIso8601String(),
      'cacheAgeMinutes': cacheAge,
      'analyticsItems': _analyticsCache.length,
      'isHealthy': totalItems < ClientConstants.MAX_CACHE_SIZE &&
          _currentCacheSize < ClientConstants.MAX_CACHE_SIZE_BYTES,
    };
  }

  /// 🔧 MÉTODOS PRIVADOS PARA SERIALIZACIÓN SEGURA

  /// 🔄 CONVERTIR TIMESTAMPS A STRINGS PARA SERIALIZACIÓN
  Map<String, dynamic> _convertTimestampsToStrings(Map<String, dynamic> data) {
    final Map<String, dynamic> result = {};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is Timestamp) {
        // Convertir Timestamp a ISO string
        result[key] = value.toDate().toIso8601String();
      } else if (value is DateTime) {
        // Convertir DateTime a ISO string
        result[key] = value.toIso8601String();
      } else if (value is Map<String, dynamic>) {
        // Recursivamente convertir mapas anidados
        result[key] = _convertTimestampsToStrings(value);
      } else if (value is List) {
        // Convertir listas recursivamente
        result[key] = _convertTimestampsInList(value);
      } else {
        // Mantener valor original
        result[key] = value;
      }
    }

    return result;
  }

  /// 🔄 CONVERTIR TIMESTAMPS EN LISTAS
  List<dynamic> _convertTimestampsInList(List<dynamic> list) {
    return list.map((item) {
      if (item is Timestamp) {
        return item.toDate().toIso8601String();
      } else if (item is DateTime) {
        return item.toIso8601String();
      } else if (item is Map<String, dynamic>) {
        return _convertTimestampsToStrings(item);
      } else if (item is List) {
        return _convertTimestampsInList(item);
      } else {
        return item;
      }
    }).toList();
  }

  /// 🔄 CONVERTIR STRINGS DE VUELTA A DATETIME
  Map<String, dynamic> _convertTimestampsToDateTime(Map<String, dynamic> data) {
    final Map<String, dynamic> result = {};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is String && _isISODateString(value)) {
        // Convertir string ISO de vuelta a DateTime
        try {
          result[key] = DateTime.parse(value);
        } catch (e) {
          result[key] = value; // Mantener original si falla
        }
      } else if (value is Map<String, dynamic>) {
        // Recursivamente convertir mapas anidados
        result[key] = _convertTimestampsToDateTime(value);
      } else if (value is List) {
        // Convertir listas recursivamente
        result[key] = _convertDateTimesInList(value);
      } else {
        // Mantener valor original
        result[key] = value;
      }
    }

    return result;
  }

  /// 🔄 CONVERTIR STRINGS EN LISTAS DE VUELTA A DATETIME
  List<dynamic> _convertDateTimesInList(List<dynamic> list) {
    return list.map((item) {
      if (item is String && _isISODateString(item)) {
        try {
          return DateTime.parse(item);
        } catch (e) {
          return item;
        }
      } else if (item is Map<String, dynamic>) {
        return _convertTimestampsToDateTime(item);
      } else if (item is List) {
        return _convertDateTimesInList(item);
      } else {
        return item;
      }
    }).toList();
  }

  /// 🔍 VERIFICAR SI STRING ES FECHA ISO
  bool _isISODateString(String value) {
    // Patrón básico para fecha ISO: YYYY-MM-DDTHH:mm:ss
    final isoPattern = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}');
    return isoPattern.hasMatch(value);
  }

  /// 🔄 FUNCIÓN TOENCONDABLE PERSONALIZADA
  Object? _toEncodable(Object? nonEncodable) {
    if (nonEncodable is Timestamp) {
      return nonEncodable.toDate().toIso8601String();
    } else if (nonEncodable is DateTime) {
      return nonEncodable.toIso8601String();
    } else {
      // Para otros objetos no serializables, intentar llamar toMap() si existe
      try {
        final dynamic obj = nonEncodable;
        if (obj.runtimeType.toString().contains('Model') &&
            obj.runtimeType.toString() != 'ClientModel') {
          // Intentar llamar toMap si el objeto tiene este método
          return obj.toMap();
        }
      } catch (e) {
        debugPrint('⚠️ No se pudo serializar objeto: $nonEncodable');
      }

      // Fallback: convertir a string
      return nonEncodable.toString();
    }
  }

  /// 🔧 MÉTODOS HELPER EXISTENTES
  Future<void> _enforceLRULimit() async {
    if (_memoryCache.length <= ClientConstants.MAX_CACHE_SIZE) return;

    debugPrint('🔄 Aplicando límite LRU: ${_memoryCache.length} items');

    // Ordenar por tiempo de acceso (menos reciente primero)
    final sortedEntries = _accessTimes.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // Eliminar los más antiguos
    final itemsToRemove = _memoryCache.length - ClientConstants.MAX_CACHE_SIZE;
    for (int i = 0; i < itemsToRemove; i++) {
      final key = sortedEntries[i].key;
      _memoryCache.remove(key);
      _accessTimes.remove(key);
    }

    debugPrint('✅ LRU aplicado: ${itemsToRemove} items eliminados');
  }

  Future<void> _updatePersistentCache() async {
    // Solo actualizar si hay suficientes cambios o ha pasado tiempo suficiente
    final clients = _memoryCache.values.toList();
    if (clients.isNotEmpty) {
      await setAllClients(clients);
    }
  }

  Future<void> _loadCacheMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadataString = prefs.getString(_cacheMetadataKey);

      if (metadataString != null) {
        final metadata = json.decode(metadataString);
        _currentCacheSize = metadata['cacheSize'] ?? 0;

        final lastCleanupTimestamp = metadata['lastCleanup'];
        if (lastCleanupTimestamp != null) {
          _lastCleanup =
              DateTime.fromMillisecondsSinceEpoch(lastCleanupTimestamp);
        }
      }
    } catch (e) {
      debugPrint('❌ Error cargando metadata del cache: $e');
    }
  }

  Future<void> _saveCacheMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadata = {
        'cacheSize': _currentCacheSize,
        'lastCleanup': _lastCleanup?.millisecondsSinceEpoch,
      };

      await prefs.setString(_cacheMetadataKey, json.encode(metadata));
    } catch (e) {
      debugPrint('❌ Error guardando metadata del cache: $e');
    }
  }

  Future<void> _performCleanupIfNeeded() async {
    if (_lastCleanup == null) {
      await cleanup();
      return;
    }

    final now = DateTime.now();
    final timeSinceCleanup = now.difference(_lastCleanup!);

    if (timeSinceCleanup.inHours >=
        ClientConstants.CACHE_CLEANUP_INTERVAL_HOURS) {
      await cleanup();
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// 🧹 CLEANUP AL DESTRUIR
  void dispose() {
    _memoryCache.clear();
    _accessTimes.clear();
    _analyticsCache.clear();
  }
}

/// 📊 PLACEHOLDER PARA CLIENTANALYTICS
/// TODO: Implementar el modelo real ClientAnalytics
class ClientAnalytics {
  final DateTime lastUpdated;
  final Map<String, dynamic> data;

  const ClientAnalytics({
    required this.lastUpdated,
    required this.data,
  });

  factory ClientAnalytics.fromMap(Map<String, dynamic> map) {
    return ClientAnalytics(
      lastUpdated: map['lastUpdated'] is String
          ? DateTime.parse(map['lastUpdated'])
          : DateTime.now(),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lastUpdated': lastUpdated.toIso8601String(),
      'data': data,
    };
  }
}
