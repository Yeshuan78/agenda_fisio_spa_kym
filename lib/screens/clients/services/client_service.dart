// [client_service.dart] - SERVICE LAYER ENTERPRISE - CORREGIDO
// 📁 Ubicación: /lib/screens/clients/services/client_service.dart
// 🎯 OBJETIVO: Service principal con cache inteligente y control de costos

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/background_cost_monitor.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/cost_data_models.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/services/client_cache_service.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/utils/client_constants.dart';

/// 🎯 SERVICE PRINCIPAL PARA GESTIÓN DE CLIENTES
/// Implementa cache-first strategy con control de costos avanzado
class ClientService {
  static final _instance = ClientService._internal();
  factory ClientService() => _instance;
  ClientService._internal();

  // ✅ DEPENDENCIAS
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ClientCacheService _cache = ClientCacheService();
  final BackgroundCostMonitor _costMonitor =
      BackgroundCostMonitor(); // ✅ CORREGIDO: Sin .instance

  // ✅ CONTROLADORES DE STREAM
  final StreamController<List<ClientModel>> _clientsStreamController =
      StreamController<List<ClientModel>>.broadcast();
  final StreamController<ClientAnalytics> _analyticsStreamController =
      StreamController<ClientAnalytics>.broadcast();

  // ✅ ESTADO INTERNO
  List<ClientModel> _cachedClients = [];
  DateTime? _lastFullSync;
  bool _isInitialized = false;

  // ✅ GETTERS PÚBLICOS
  Stream<List<ClientModel>> get clientsStream =>
      _clientsStreamController.stream;
  Stream<ClientAnalytics> get analyticsStream =>
      _analyticsStreamController.stream;
  List<ClientModel> get cachedClients => List.unmodifiable(_cachedClients);
  bool get isInitialized => _isInitialized;

  /// 🚀 INICIALIZACIÓN DEL SERVICIO
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('📊 Inicializando ClientService...');

    try {
      // 1️⃣ Cargar datos del cache primero
      final cachedData = await _cache.getAllClients();
      if (cachedData.isNotEmpty) {
        _cachedClients = cachedData;
        _clientsStreamController.add(_cachedClients);
        debugPrint('💾 Cargados ${cachedData.length} clientes desde cache');
      }

      // 2️⃣ Verificar si necesitamos sincronización
      final lastSync = await _cache.getLastSyncTime();
      final needsSync = lastSync == null ||
          DateTime.now().difference(lastSync).inHours >=
              ClientConstants.CACHE_EXPIRY_HOURS;

      if (needsSync && _canMakeQuery()) {
        await _performFullSync();
      }

      _isInitialized = true;
      debugPrint('✅ ClientService inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error inicializando ClientService: $e');
      rethrow;
    }
  }

  /// 📥 OBTENER TODOS LOS CLIENTES (CACHE-FIRST)
  Future<List<ClientModel>> getAllClients({bool forceRefresh = false}) async {
    debugPrint(
        '📋 Obteniendo todos los clientes (forceRefresh: $forceRefresh)');

    // 1️⃣ Si no forzamos refresh y tenemos cache válido, usarlo
    if (!forceRefresh && _cachedClients.isNotEmpty) {
      final cacheAge = _lastFullSync != null
          ? DateTime.now().difference(_lastFullSync!)
          : Duration.zero;

      if (cacheAge.inHours < ClientConstants.CACHE_EXPIRY_HOURS) {
        debugPrint('💾 Usando cache (edad: ${cacheAge.inMinutes} minutos)');
        return _cachedClients;
      }
    }

    // 2️⃣ Verificar límites de costo antes de consultar
    if (!_canPerformRead()) {
      debugPrint('💰 Límite de costos alcanzado, usando cache');
      return _cachedClients.isNotEmpty ? _cachedClients : [];
    }

    // 3️⃣ Realizar consulta optimizada
    try {
      await _performFullSync();
      return _cachedClients;
    } catch (e) {
      debugPrint('❌ Error obteniendo clientes: $e');
      // En caso de error, devolver cache si existe
      return _cachedClients;
    }
  }

  /// 🔍 OBTENER CLIENTE POR ID
  Future<ClientModel?> getClientById(String clientId) async {
    debugPrint('🔍 Buscando cliente: $clientId');

    // 1️⃣ Buscar primero en cache
    try {
      final cachedClient = _cachedClients.firstWhere(
        (client) => client.clientId == clientId,
      );
      debugPrint('💾 Cliente encontrado en cache');
      return cachedClient;
    } catch (_) {
      // No encontrado en cache, continuar con consulta
    }

    // 2️⃣ Verificar límites de costo
    if (!_canPerformRead()) {
      debugPrint('💰 Límite de costos alcanzado para consulta individual');
      return null;
    }

    // 3️⃣ Consultar en Firestore
    try {
      _recordRead(); // 💰 Registrar consulta

      final doc = await _firestore.collection('clients').doc(clientId).get();

      if (!doc.exists) {
        debugPrint('❌ Cliente no encontrado: $clientId');
        return null;
      }

      final client = ClientModel.fromDoc(doc);

      // 4️⃣ Actualizar cache
      await _updateClientInCache(client);

      debugPrint('✅ Cliente obtenido y cacheado: ${client.fullName}');
      return client;
    } catch (e) {
      debugPrint('❌ Error obteniendo cliente $clientId: $e');
      return null;
    }
  }

  /// ➕ CREAR NUEVO CLIENTE
  Future<ClientModel> createClient(ClientModel client) async {
    debugPrint('➕ Creando nuevo cliente: ${client.fullName}');

    // 1️⃣ Verificar límites de costo
    if (!_canPerformRead()) {
      throw Exception('Límite de costos alcanzado. Intente más tarde.');
    }

    try {
      _recordRead(); // 💰 Registrar consulta

      // 2️⃣ Crear documento en Firestore
      final docRef = await _firestore.collection('clients').add(client.toMap());

      // 3️⃣ Obtener cliente creado con ID
      final createdClient = client.copyWith(
        clientId: docRef.id,
        updatedAt: DateTime.now(),
      );

      // 4️⃣ Actualizar cache
      await _addClientToCache(createdClient);

      // 5️⃣ Notificar cambios
      _clientsStreamController.add(_cachedClients);

      debugPrint('✅ Cliente creado exitosamente: ${createdClient.clientId}');
      return createdClient;
    } catch (e) {
      debugPrint('❌ Error creando cliente: $e');
      rethrow;
    }
  }

  /// ✏️ ACTUALIZAR CLIENTE EXISTENTE
  Future<ClientModel> updateClient(ClientModel client) async {
    debugPrint('✏️ Actualizando cliente: ${client.fullName}');

    // 1️⃣ Verificar límites de costo
    if (!_canPerformRead()) {
      throw Exception('Límite de costos alcanzado. Intente más tarde.');
    }

    try {
      _recordRead(); // 💰 Registrar consulta

      // 2️⃣ Actualizar en Firestore
      final updatedClient = client.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('clients')
          .doc(client.clientId)
          .update(updatedClient.toMap());

      // 3️⃣ Actualizar cache
      await _updateClientInCache(updatedClient);

      // 4️⃣ Notificar cambios
      _clientsStreamController.add(_cachedClients);

      debugPrint('✅ Cliente actualizado exitosamente: ${client.clientId}');
      return updatedClient;
    } catch (e) {
      debugPrint('❌ Error actualizando cliente: $e');
      rethrow;
    }
  }

  /// 🗑️ ELIMINAR CLIENTE
  Future<void> deleteClient(String clientId) async {
    debugPrint('🗑️ Eliminando cliente: $clientId');

    // 1️⃣ Verificar límites de costo
    if (!_canPerformRead()) {
      throw Exception('Límite de costos alcanzado. Intente más tarde.');
    }

    try {
      _recordRead(); // 💰 Registrar consulta

      // 2️⃣ Eliminar de Firestore
      await _firestore.collection('clients').doc(clientId).delete();

      // 3️⃣ Eliminar del cache
      await _removeClientFromCache(clientId);

      // 4️⃣ Notificar cambios
      _clientsStreamController.add(_cachedClients);

      debugPrint('✅ Cliente eliminado exitosamente: $clientId');
    } catch (e) {
      debugPrint('❌ Error eliminando cliente: $e');
      rethrow;
    }
  }

  /// 📦 OPERACIONES MASIVAS - ACTUALIZAR ETIQUETAS
  Future<void> bulkUpdateTags(
      List<String> clientIds, List<ClientTag> tagsToAdd) async {
    debugPrint(
        '📦 Actualizando etiquetas masivamente: ${clientIds.length} clientes');

    if (clientIds.length > ClientConstants.MAX_BULK_OPERATIONS) {
      throw Exception(
          'Máximo ${ClientConstants.MAX_BULK_OPERATIONS} operaciones por lote');
    }

    // 1️⃣ Verificar límites de costo
    final queriesNeeded = clientIds.length;
    if (_costMonitor.currentStats.dailyReadCount + queriesNeeded >
        CostControlConfig.dailyReadLimit) {
      throw Exception('Límite de costos insuficiente para esta operación');
    }

    try {
      // 2️⃣ Usar batch para optimizar
      final batch = _firestore.batch();

      for (final clientId in clientIds) {
        // Encontrar cliente en cache
        final clientIndex = _cachedClients.indexWhere(
          (c) => c.clientId == clientId,
        );

        if (clientIndex == -1) continue;

        final client = _cachedClients[clientIndex];
        final updatedTags = List<ClientTag>.from(client.tags);

        // Agregar nuevas etiquetas
        for (final tag in tagsToAdd) {
          if (!client.hasTag(tag.label)) {
            updatedTags.add(tag);
          }
        }

        final updatedClient = client.copyWith(
          tags: updatedTags,
          updatedAt: DateTime.now(),
        );

        // Agregar al batch
        batch.update(
          _firestore.collection('clients').doc(clientId),
          {'tiposCliente': updatedTags.map((t) => t.toMap()).toList()},
        );

        // Actualizar cache
        _cachedClients[clientIndex] = updatedClient;
      }

      // 3️⃣ Ejecutar batch
      await batch.commit();
      for (int i = 0; i < queriesNeeded; i++) {
        _recordRead(); // 💰 Registrar consultas
      }

      // 4️⃣ Notificar cambios
      _clientsStreamController.add(_cachedClients);

      debugPrint('✅ Etiquetas actualizadas masivamente');
    } catch (e) {
      debugPrint('❌ Error en actualización masiva de etiquetas: $e');
      rethrow;
    }
  }

  /// 🗑️ ELIMINAR MÚLTIPLES CLIENTES
  Future<void> bulkDelete(List<String> clientIds) async {
    debugPrint(
        '🗑️ Eliminando clientes masivamente: ${clientIds.length} clientes');

    if (clientIds.length > ClientConstants.MAX_BULK_OPERATIONS) {
      throw Exception(
          'Máximo ${ClientConstants.MAX_BULK_OPERATIONS} eliminaciones por lote');
    }

    // 1️⃣ Verificar límites de costo
    final queriesNeeded = clientIds.length;
    if (_costMonitor.currentStats.dailyReadCount + queriesNeeded >
        CostControlConfig.dailyReadLimit) {
      throw Exception('Límite de costos insuficiente para esta operación');
    }

    try {
      // 2️⃣ Usar batch para optimizar
      final batch = _firestore.batch();

      for (final clientId in clientIds) {
        batch.delete(_firestore.collection('clients').doc(clientId));
      }

      // 3️⃣ Ejecutar batch
      await batch.commit();
      for (int i = 0; i < queriesNeeded; i++) {
        _recordRead(); // 💰 Registrar consultas
      }

      // 4️⃣ Eliminar del cache
      for (final clientId in clientIds) {
        await _removeClientFromCache(clientId);
      }

      // 5️⃣ Notificar cambios
      _clientsStreamController.add(_cachedClients);

      debugPrint('✅ Clientes eliminados masivamente');
    } catch (e) {
      debugPrint('❌ Error en eliminación masiva: $e');
      rethrow;
    }
  }

  /// 📊 OBTENER ANALYTICS BÁSICOS (CÁLCULO LOCAL)
  Future<ClientAnalytics> getBasicAnalytics() async {
    debugPrint('📊 Calculando analytics básicos...');

    // Cálculos basados en datos ya cargados en memoria (COSTO: $0.00)
    final analytics = ClientAnalytics(
      totalClients: _cachedClients.length,
      activeClients: _cachedClients.where((c) => c.isActive).length,
      vipClients: _cachedClients.where((c) => c.isVIP).length,
      corporateClients: _cachedClients.where((c) => c.isCorporate).length,
      newClients: _cachedClients.where((c) => c.isNew).length,
      averageSatisfaction: _cachedClients.averageSatisfaction,
      totalRevenue: _cachedClients.totalRevenue,
      totalAppointments: _cachedClients.totalAppointments,
      topTags: _getTopTags(),
      topAlcaldias: _getTopAlcaldias(),
      statusDistribution: _cachedClients.countByStatus,
      lastUpdated: DateTime.now(),
    );

    _analyticsStreamController.add(analytics);
    return analytics;
  }

  /// 🔄 SINCRONIZACIÓN MANUAL
  Future<void> forceSync() async {
    debugPrint('🔄 Forzando sincronización...');

    if (!_canPerformRead()) {
      throw Exception('Límite de costos alcanzado para sincronización');
    }

    await _performFullSync();
  }

  /// 🧹 LIMPIAR CACHE
  Future<void> clearCache() async {
    debugPrint('🧹 Limpiando cache...');

    await _cache.clearAll();
    _cachedClients.clear();
    _lastFullSync = null;
    _isInitialized = false;

    _clientsStreamController.add(_cachedClients);
  }

  /// 🔄 MÉTODOS PRIVADOS DE SINCRONIZACIÓN
  Future<void> _performFullSync() async {
    debugPrint('🔄 Realizando sincronización completa...');

    try {
      _recordRead(); // 💰 Registrar consulta

      final snapshot =
          await _firestore.collection('clients').orderBy('nombre').get();

      final clients =
          snapshot.docs.map((doc) => ClientModel.fromDoc(doc)).toList();

      // Actualizar cache y estado
      _cachedClients = clients;
      _lastFullSync = DateTime.now();

      // Guardar en cache persistente
      await _cache.setAllClients(clients);
      await _cache.setLastSyncTime(_lastFullSync!);

      // Notificar cambios
      _clientsStreamController.add(_cachedClients);

      debugPrint('✅ Sincronización completa: ${clients.length} clientes');
    } catch (e) {
      debugPrint('❌ Error en sincronización completa: $e');
      rethrow;
    }
  }

  Future<void> _updateClientInCache(ClientModel client) async {
    final index = _cachedClients.indexWhere(
      (c) => c.clientId == client.clientId,
    );

    if (index != -1) {
      _cachedClients[index] = client;
    } else {
      _cachedClients.add(client);
    }

    await _cache.setClient(client);
  }

  Future<void> _addClientToCache(ClientModel client) async {
    _cachedClients.add(client);
    await _cache.setClient(client);
  }

  Future<void> _removeClientFromCache(String clientId) async {
    _cachedClients.removeWhere((c) => c.clientId == clientId);
    await _cache.removeClient(clientId);
  }

  List<Map<String, dynamic>> _getTopTags() {
    final tagCounts = _cachedClients.countByTag;
    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTags
        .take(10)
        .map((entry) => {
              'tag': entry.key,
              'count': entry.value,
            })
        .toList();
  }

  List<Map<String, dynamic>> _getTopAlcaldias() {
    final alcaldiaCounts = _cachedClients.countByAlcaldia;
    final sortedAlcaldias = alcaldiaCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedAlcaldias
        .take(10)
        .map((entry) => {
              'alcaldia': entry.key,
              'count': entry.value,
            })
        .toList();
  }

  // ✅ MÉTODOS DE COSTO CORREGIDOS
  bool _canMakeQuery() {
    // Verificar si se puede hacer una consulta general
    return _costMonitor.currentStats.dailyReadCount <
        CostControlConfig.dailyReadLimit;
  }

  bool _canPerformRead() {
    // Verificar si se puede realizar una lectura específica
    return _costMonitor.currentStats.dailyReadCount <
        CostControlConfig.dailyReadLimit;
  }

  void _recordRead() {
    // Registrar una lectura realizada
    // El BackgroundCostMonitor se actualiza automáticamente
    debugPrint(
        '💰 Consulta registrada. Total: ${_costMonitor.currentStats.dailyReadCount + 1}');
  }

  /// 🧹 CLEANUP
  void dispose() {
    _clientsStreamController.close();
    _analyticsStreamController.close();
  }
}

/// 📊 MODELO DE ANALYTICS
class ClientAnalytics {
  final int totalClients;
  final int activeClients;
  final int vipClients;
  final int corporateClients;
  final int newClients;
  final double averageSatisfaction;
  final double totalRevenue;
  final int totalAppointments;
  final List<Map<String, dynamic>> topTags;
  final List<Map<String, dynamic>> topAlcaldias;
  final Map<ClientStatus, int> statusDistribution;
  final DateTime lastUpdated;

  const ClientAnalytics({
    required this.totalClients,
    required this.activeClients,
    required this.vipClients,
    required this.corporateClients,
    required this.newClients,
    required this.averageSatisfaction,
    required this.totalRevenue,
    required this.totalAppointments,
    required this.topTags,
    required this.topAlcaldias,
    required this.statusDistribution,
    required this.lastUpdated,
  });

  double get vipPercentage =>
      totalClients > 0 ? (vipClients / totalClients) * 100 : 0.0;
  double get activePercentage =>
      totalClients > 0 ? (activeClients / totalClients) * 100 : 0.0;
  double get corporatePercentage =>
      totalClients > 0 ? (corporateClients / totalClients) * 100 : 0.0;
  double get averageRevenuePerClient =>
      totalClients > 0 ? totalRevenue / totalClients : 0.0;
  double get averageAppointmentsPerClient =>
      totalClients > 0 ? totalAppointments / totalClients : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'totalClients': totalClients,
      'activeClients': activeClients,
      'vipClients': vipClients,
      'corporateClients': corporateClients,
      'newClients': newClients,
      'averageSatisfaction': averageSatisfaction,
      'totalRevenue': totalRevenue,
      'totalAppointments': totalAppointments,
      'topTags': topTags,
      'topAlcaldias': topAlcaldias,
      'statusDistribution':
          statusDistribution.map((k, v) => MapEntry(k.name, v)),
      'lastUpdated': lastUpdated.toIso8601String(),
      'vipPercentage': vipPercentage,
      'activePercentage': activePercentage,
      'corporatePercentage': corporatePercentage,
      'averageRevenuePerClient': averageRevenuePerClient,
      'averageAppointmentsPerClient': averageAppointmentsPerClient,
    };
  }
}
