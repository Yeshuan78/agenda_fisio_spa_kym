// [client_service.dart] - SERVICE LAYER ENTERPRISE - ✅ FIX QUIRÚRGICO COMPLETO
// 📁 Ubicación: /lib/screens/clients/services/client_service.dart
// 🎯 OBJETIVO: Service principal con cache inteligente y control de costos + serviceMode preservation
// ✅ FIX CRÍTICO: BackgroundCostMonitor methods + serviceMode preservation COMPLETO

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/models/company/company_settings_model.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/background_cost_monitor.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/cost_data_models.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/services/client_cache_service.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/utils/client_constants.dart';

/// 🎯 SERVICE PRINCIPAL PARA GESTIÓN DE CLIENTES
/// Implementa cache-first strategy con control de costos avanzado + serviceMode preservation
class ClientService {
  static final _instance = ClientService._internal();
  factory ClientService() => _instance;
  ClientService._internal();

  // ✅ DEPENDENCIAS - FIX QUIRÚRGICO: Sin .instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ClientCacheService _cache = ClientCacheService();
  final BackgroundCostMonitor _costMonitor =
      BackgroundCostMonitor(); // ✅ FIX: Sin .instance

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
        // ✅ FIX: Método privado local
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
      // ✅ FIX: Método privado local
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
      debugPrint('   - ServiceMode: ${cachedClient.serviceMode.label}');
      return cachedClient;
    } catch (_) {
      // No encontrado en cache, continuar con consulta
    }

    // 2️⃣ Verificar límites de costo
    if (!_canPerformRead()) {
      // ✅ FIX: Método privado local
      debugPrint('💰 Límite de costos alcanzado para consulta individual');
      return null;
    }

    // 3️⃣ Consultar en Firestore
    try {
      _recordRead(); // ✅ FIX: Método privado local

      final doc = await _firestore.collection('clients').doc(clientId).get();

      if (!doc.exists) {
        debugPrint('❌ Cliente no encontrado: $clientId');
        return null;
      }

      final client = ClientModel.fromDoc(doc);

      // ✅ LOG CRÍTICO PARA VERIFICAR SERVICEMODE
      debugPrint('📖 Cliente leído desde Firestore:');
      debugPrint('   - Nombre: ${client.fullName}');
      debugPrint('   - ServiceMode: ${client.serviceMode.label}');
      debugPrint('   - IsHomeService: ${client.isHomeService}');
      debugPrint('   - IsInSiteService: ${client.isInSiteService}');
      debugPrint('   - IsHybridService: ${client.isHybridService}');

      // 4️⃣ Actualizar cache
      await _updateClientInCache(client);

      debugPrint('✅ Cliente obtenido y cacheado: ${client.fullName}');
      return client;
    } catch (e) {
      debugPrint('❌ Error obteniendo cliente $clientId: $e');
      return null;
    }
  }

  /// ➕ CREAR NUEVO CLIENTE - ✅ CON PRESERVACIÓN DE SERVICEMODE
  Future<ClientModel> createClient(ClientModel client) async {
    debugPrint('➕ Creando nuevo cliente: ${client.fullName}');
    debugPrint('🎯 Con serviceMode: ${client.serviceMode.label}');

    // 1️⃣ Verificar límites de costo
    if (!_canPerformRead()) {
      // ✅ FIX: Método privado local
      throw Exception('Límite de costos alcanzado. Intente más tarde.');
    }

    try {
      _recordRead(); // ✅ FIX: Método privado local

      // 2️⃣ Preparar datos para Firestore - ✅ CON SERVICEMODE COMPLETO
      final clientData = _prepareClientDataForFirestore(client);

      // ✅ LOG CRÍTICO ANTES DE GUARDAR
      debugPrint('💾 Datos a guardar en Firestore:');
      debugPrint('   - serviceMode: ${clientData['serviceMode']}');
      debugPrint('   - isHomeService: ${clientData['isHomeService']}');
      debugPrint('   - isInSiteService: ${clientData['isInSiteService']}');
      debugPrint('   - isHybridService: ${clientData['isHybridService']}');

      // 3️⃣ Crear documento en Firestore
      final docRef = await _firestore.collection('clients').add(clientData);

      // 4️⃣ Obtener cliente creado con ID
      final createdClient = client.copyWith(
        clientId: docRef.id,
        updatedAt: DateTime.now(),
      );

      // 5️⃣ Actualizar cache
      await _addClientToCache(createdClient);

      // 6️⃣ Notificar cambios
      _clientsStreamController.add(_cachedClients);

      debugPrint('✅ Cliente creado exitosamente: ${createdClient.clientId}');
      debugPrint(
          '✅ Con serviceMode preservado: ${createdClient.serviceMode.label}');
      return createdClient;
    } catch (e) {
      debugPrint('❌ Error creando cliente: $e');
      rethrow;
    }
  }

  /// ✏️ ACTUALIZAR CLIENTE EXISTENTE - ✅ CON PRESERVACIÓN DE SERVICEMODE
  Future<ClientModel> updateClient(ClientModel client) async {
    debugPrint('✏️ Actualizando cliente: ${client.fullName}');
    debugPrint('🎯 Con serviceMode: ${client.serviceMode.label}');

    // 1️⃣ Verificar límites de costo
    if (!_canPerformRead()) {
      // ✅ FIX: Método privado local
      throw Exception('Límite de costos alcanzado. Intente más tarde.');
    }

    try {
      _recordRead(); // ✅ FIX: Método privado local

      // 2️⃣ Preparar datos actualizados - ✅ CON SERVICEMODE
      final updatedClient = client.copyWith(updatedAt: DateTime.now());
      final updateData = _prepareClientDataForFirestore(updatedClient);

      // ✅ LOG CRÍTICO ANTES DE ACTUALIZAR
      debugPrint('💾 Datos a actualizar en Firestore:');
      debugPrint('   - serviceMode: ${updateData['serviceMode']}');
      debugPrint('   - isHomeService: ${updateData['isHomeService']}');
      debugPrint('   - isInSiteService: ${updateData['isInSiteService']}');
      debugPrint('   - isHybridService: ${updateData['isHybridService']}');

      // 3️⃣ Actualizar en Firestore
      await _firestore
          .collection('clients')
          .doc(client.clientId)
          .update(updateData);

      // 4️⃣ Actualizar cache
      await _updateClientInCache(updatedClient);

      // 5️⃣ Notificar cambios
      _clientsStreamController.add(_cachedClients);

      debugPrint('✅ Cliente actualizado exitosamente: ${client.clientId}');
      debugPrint(
          '✅ Con serviceMode preservado: ${updatedClient.serviceMode.label}');
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
      // ✅ FIX: Método privado local
      throw Exception('Límite de costos alcanzado. Intente más tarde.');
    }

    try {
      _recordRead(); // ✅ FIX: Método privado local

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

        // ✅ PRESERVAR SERVICEMODE EN UPDATE MASIVO
        final updateData = {
          'tiposCliente': updatedTags.map((t) => t.toMap()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
          // ✅ PRESERVAR CAMPOS DE SERVICEMODE
          'serviceMode': client.serviceMode.name,
          'isHomeService': client.isHomeService,
          'isInSiteService': client.isInSiteService,
          'isHybridService': client.isHybridService,
        };

        // Agregar al batch
        batch.update(
          _firestore.collection('clients').doc(clientId),
          updateData,
        );

        // Actualizar cache
        _cachedClients[clientIndex] = updatedClient;
      }

      // 3️⃣ Ejecutar batch
      await batch.commit();
      for (int i = 0; i < queriesNeeded; i++) {
        _recordRead(); // ✅ FIX: Método privado local
      }

      // 4️⃣ Notificar cambios
      _clientsStreamController.add(_cachedClients);

      debugPrint(
          '✅ Etiquetas actualizadas masivamente (serviceMode preservado)');
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
        _recordRead(); // ✅ FIX: Método privado local
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

  /// 📊 OBTENER ANALYTICS BÁSICOS (CÁLCULO LOCAL) - ✅ CON SERVICEMODE
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
      // ✅ NUEVOS ANALYTICS DE SERVICEMODE
      serviceModeDistribution: _cachedClients.countByServiceMode,
      homeServiceClients: _cachedClients.homeServiceClients.length,
      inSiteServiceClients: _cachedClients.inSiteServiceClients.length,
      hybridServiceClients: _cachedClients.hybridServiceClients.length,
      lastUpdated: DateTime.now(),
    );

    _analyticsStreamController.add(analytics);
    return analytics;
  }

  /// 🔄 SINCRONIZACIÓN MANUAL
  Future<void> forceSync() async {
    debugPrint('🔄 Forzando sincronización...');

    if (!_canPerformRead()) {
      // ✅ FIX: Método privado local
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

  // ========================================================================
  // 🔧 MÉTODOS PRIVADOS - ✅ CON PRESERVACIÓN DE SERVICEMODE + FIX COSTMONITOR
  // ========================================================================

  /// ✅ NUEVO: PREPARAR DATOS PARA FIRESTORE CON SERVICEMODE COMPLETO
  Map<String, dynamic> _prepareClientDataForFirestore(ClientModel client) {
    final data = client.toMap();

    // ✅ ASEGURAR QUE SERVICEMODE ESTÉ INCLUIDO
    data['serviceMode'] = client.serviceMode.name;
    data['isHomeService'] = client.isHomeService;
    data['isInSiteService'] = client.isInSiteService;
    data['isHybridService'] = client.isHybridService;

    // ✅ LOG PARA VERIFICACIÓN
    debugPrint('📤 Preparando datos para Firestore:');
    debugPrint('   - serviceMode: ${data['serviceMode']}');
    debugPrint('   - isHomeService: ${data['isHomeService']}');
    debugPrint('   - isInSiteService: ${data['isInSiteService']}');
    debugPrint('   - isHybridService: ${data['isHybridService']}');

    return data;
  }

  /// 🔄 MÉTODOS PRIVADOS DE SINCRONIZACIÓN
  Future<void> _performFullSync() async {
    debugPrint('🔄 Realizando sincronización completa...');

    try {
      _recordRead(); // ✅ FIX: Método privado local

      final snapshot =
          await _firestore.collection('clients').orderBy('nombre').get();

      final clients =
          snapshot.docs.map((doc) => ClientModel.fromDoc(doc)).toList();

      // ✅ LOG PARA VERIFICAR LECTURA DE SERVICEMODE
      debugPrint('📖 Clientes sincronizados desde Firestore:');
      for (final client in clients.take(3)) {
        // Solo los primeros 3 para no saturar logs
        debugPrint('   - ${client.fullName}: ${client.serviceMode.label}');
      }

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

  // ========================================================================
  // ✅ FIX CRÍTICO: MÉTODOS PRIVADOS DE COSTMONITOR COMPATIBLES CON TU CÓDIGO BASE
  // ========================================================================

  /// ✅ FIX: Verificar si se puede hacer una consulta general
  bool _canMakeQuery() {
    try {
      return _costMonitor.currentStats.dailyReadCount <
          CostControlConfig.dailyReadLimit;
    } catch (e) {
      debugPrint('⚠️ Error verificando límites de consulta: $e');
      return true; // Fail-safe: permitir operación
    }
  }

  /// ✅ FIX: Verificar si se puede realizar una lectura específica
  bool _canPerformRead() {
    try {
      return _costMonitor.currentStats.dailyReadCount <
          CostControlConfig.dailyReadLimit;
    } catch (e) {
      debugPrint('⚠️ Error verificando límites de lectura: $e');
      return true; // Fail-safe: permitir operación
    }
  }

  /// ✅ FIX: Registrar una lectura realizada
  void _recordRead() {
    try {
      _costMonitor.incrementReadCount(1,
          description: 'ClientService operation');
      debugPrint(
          '💰 Consulta registrada. Total: ${_costMonitor.currentStats.dailyReadCount}');
    } catch (e) {
      debugPrint('⚠️ Error registrando consulta: $e');
      // Continuar sin registrar si hay error
    }
  }

  /// 🧹 CLEANUP
  void dispose() {
    _clientsStreamController.close();
    _analyticsStreamController.close();
  }
}

/// 📊 MODELO DE ANALYTICS - ✅ ACTUALIZADO CON SERVICEMODE
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

  // ✅ NUEVOS CAMPOS DE SERVICEMODE
  final Map<ClientServiceMode, int> serviceModeDistribution;
  final int homeServiceClients;
  final int inSiteServiceClients;
  final int hybridServiceClients;

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
    // ✅ NUEVOS PARÁMETROS
    this.serviceModeDistribution = const {},
    this.homeServiceClients = 0,
    this.inSiteServiceClients = 0,
    this.hybridServiceClients = 0,
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

  // ✅ NUEVOS GETTERS PARA SERVICEMODE
  double get homeServicePercentage =>
      totalClients > 0 ? (homeServiceClients / totalClients) * 100 : 0.0;
  double get inSiteServicePercentage =>
      totalClients > 0 ? (inSiteServiceClients / totalClients) * 100 : 0.0;
  double get hybridServicePercentage =>
      totalClients > 0 ? (hybridServiceClients / totalClients) * 100 : 0.0;

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
      // ✅ NUEVOS CAMPOS DE SERVICEMODE
      'serviceModeDistribution':
          serviceModeDistribution.map((k, v) => MapEntry(k.name, v)),
      'homeServiceClients': homeServiceClients,
      'inSiteServiceClients': inSiteServiceClients,
      'hybridServiceClients': hybridServiceClients,
      'homeServicePercentage': homeServicePercentage,
      'inSiteServicePercentage': inSiteServicePercentage,
      'hybridServicePercentage': hybridServicePercentage,
    };
  }
}
