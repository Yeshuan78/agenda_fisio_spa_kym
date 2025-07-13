// [agenda_sync_service.dart]
// 📁 Ubicación: /lib/services/agenda/agenda_sync_service.dart
// 🔄 SERVICIO PROFESIONAL PARA SINCRONIZACIÓN TIEMPO REAL EMPRESARIAL

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';

/// 🔄 SERVICIO SINCRONIZACIÓN TIEMPO REAL EMPRESARIAL
/// Maneja actualizaciones en vivo, resolución de conflictos y colaboración multi-usuario
class AgendaSyncService extends ChangeNotifier {
  static final AgendaSyncService _instance = AgendaSyncService._internal();
  factory AgendaSyncService() => _instance;
  AgendaSyncService._internal() {
    _initializeService();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ ESTADO DE SINCRONIZACIÓN
  bool _isConnected = false;
  bool _isInitialized = false;
  DateTime? _lastSyncTimestamp;
  int _conflictResolutions = 0;
  int _optimisticUpdates = 0;

  // ✅ STREAMS Y CONTROLADORES
  final Map<String, StreamSubscription> _activeSubscriptions = {};
  final Map<String, DateTime> _userHeartbeats = {};
  final Map<String, PendingUpdate> _pendingUpdates = {};
  final Map<String, ConflictResolution> _activeConflicts = {};

  // ✅ CONFIGURACIÓN EMPRESARIAL
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _conflictResolutionTimeout = Duration(minutes: 2);
  static const Duration _optimisticUpdateTimeout = Duration(seconds: 10);
  static const int _maxRetryAttempts = 3;
  static const int _maxConcurrentUsers = 50;

  // ✅ VARIABLES DE CONTROL INTERNO
  Timer? _heartbeatTimer;
  int _retryCount = 0;
  bool _isReconnecting = false;

  // ✅ CALLBACKS Y EVENTOS
  Function(AppointmentModel)? onAppointmentUpdated;
  Function(AppointmentModel)? onAppointmentCreated;
  Function(String)? onAppointmentDeleted;
  Function(ConflictInfo)? onConflictDetected;
  Function(List<ActiveUser>)? onActiveUsersChanged;
  Function(SyncStatus)? onSyncStatusChanged;

  // ========================================================================
  // 🚀 INICIALIZACIÓN Y CONFIGURACIÓN
  // ========================================================================

  Future<void> _initializeService() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 Inicializando AgendaSyncService...');

      // 1. Configurar listeners de conexión
      await _setupConnectionMonitoring();

      // 2. Inicializar heartbeat del usuario actual
      await _startHeartbeat();

      // 3. Configurar listeners de cambios globales
      await _setupGlobalChangeListeners();

      // 4. Limpiar datos obsoletos
      await _cleanupObsoleteData();

      _isInitialized = true;
      _updateSyncStatus(SyncStatus.connected);

      debugPrint('✅ AgendaSyncService inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error inicializando sync service: $e');
      _updateSyncStatus(SyncStatus.error);
    }
  }

  /// 🎯 CONECTAR USUARIO A SESIÓN COLABORATIVA
  Future<void> connectUser(String userId, String userName) async {
    try {
      // 1. Registrar usuario activo
      await _firestore.collection('active_users').doc(userId).set({
        'userId': userId,
        'userName': userName,
        'lastSeen': FieldValue.serverTimestamp(),
        'isActive': true,
        'clientInfo': {
          'platform': defaultTargetPlatform.name,
          'version': '1.0.0', // TODO: Obtener versión real
        },
      });

      // 2. Configurar limpieza automática al desconectar
      await _firestore.collection('active_users').doc(userId).update({
        'sessionExpiry': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Usuario $userName conectado al sistema colaborativo');
    } catch (e) {
      debugPrint('❌ Error conectando usuario: $e');
    }
  }

  /// 🎯 DESCONECTAR USUARIO
  Future<void> disconnectUser(String userId) async {
    try {
      // 1. Marcar usuario como inactivo
      await _firestore.collection('active_users').doc(userId).update({
        'isActive': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      // 2. Limpiar heartbeat
      await _stopHeartbeat();

      // 3. Cancelar subscripciones activas
      for (final subscription in _activeSubscriptions.values) {
        await subscription.cancel();
      }
      _activeSubscriptions.clear();

      debugPrint('✅ Usuario desconectado del sistema colaborativo');
    } catch (e) {
      debugPrint('❌ Error desconectando usuario: $e');
    }
  }

  // ========================================================================
  // 📡 SINCRONIZACIÓN DE CITAS
  // ========================================================================

  /// 🎯 SUSCRIBIRSE A CAMBIOS DE CITAS EN TIEMPO REAL
  StreamSubscription<List<AppointmentModel>> subscribeToAppointments({
    DateTime? startDate,
    DateTime? endDate,
    String? profesionalId,
    required Function(List<AppointmentModel>) onUpdate,
  }) {
    final subscriptionKey = _generateSubscriptionKey(
      startDate,
      endDate,
      profesionalId,
    );

    // Cancelar suscripción existente si existe
    _activeSubscriptions[subscriptionKey]?.cancel();

    Query<Map<String, dynamic>> query = _firestore.collection('bookings');

    // Aplicar filtros
    if (startDate != null) {
      query = query.where(
        'fecha',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }
    if (endDate != null) {
      query = query.where(
        'fecha',
        isLessThan: Timestamp.fromDate(endDate),
      );
    }
    if (profesionalId != null) {
      query = query.where('profesionalId', isEqualTo: profesionalId);
    }

    query = query.orderBy('fecha');

    // Crear stream transformado que devuelve List<AppointmentModel>
    final appointmentsStream = query.snapshots().map((snapshot) {
      try {
        final appointments = snapshot.docs
            .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
            .toList();

        // Detectar cambios específicos
        _processSnapshotChanges(snapshot);

        return appointments;
      } catch (e) {
        debugPrint('❌ Error procesando cambios de citas: $e');
        return <AppointmentModel>[];
      }
    });

    final subscription = appointmentsStream.listen(
      onUpdate,
      onError: (error) {
        debugPrint('❌ Error en stream de citas: $error');
        _handleStreamError(subscriptionKey, error);
      },
    );

    _activeSubscriptions[subscriptionKey] = subscription;
    return subscription;
  }

  /// 🎯 ACTUALIZACIÓN OPTIMISTA CON ROLLBACK
  Future<OptimisticUpdateResult> optimisticUpdate({
    required String appointmentId,
    required Map<String, dynamic> updates,
    required String userId,
  }) async {
    final updateId = _generateUpdateId();

    try {
      // 1. Aplicar cambio optimista localmente
      final pendingUpdate = PendingUpdate(
        id: updateId,
        appointmentId: appointmentId,
        updates: updates,
        userId: userId,
        timestamp: DateTime.now(),
      );

      _pendingUpdates[updateId] = pendingUpdate;
      _optimisticUpdates++;

      // 2. Notificar cambio inmediato
      _notifyOptimisticChange(appointmentId, updates);

      // 3. Enviar al servidor
      final serverResult = await _sendUpdateToServer(
        appointmentId,
        updates,
        userId,
        updateId,
      );

      if (serverResult.success) {
        // 4. Confirmar actualización optimista
        _confirmOptimisticUpdate(updateId);

        return OptimisticUpdateResult(
          success: true,
          updateId: updateId,
          confirmedData: serverResult.data,
        );
      } else {
        // 5. Revertir cambio optimista
        await _revertOptimisticUpdate(updateId, serverResult.conflictData);

        return OptimisticUpdateResult(
          success: false,
          updateId: updateId,
          error: serverResult.error,
          requiresConflictResolution: serverResult.hasConflict,
          conflictData: serverResult.conflictData,
        );
      }
    } catch (e) {
      debugPrint('❌ Error en actualización optimista: $e');
      await _revertOptimisticUpdate(updateId, null);

      return OptimisticUpdateResult(
        success: false,
        updateId: updateId,
        error: 'Error interno: $e',
      );
    }
  }

  /// 🎯 RESOLUCIÓN AUTOMÁTICA DE CONFLICTOS
  Future<ConflictResolutionResult> resolveConflict({
    required String conflictId,
    required ConflictResolutionStrategy strategy,
    Map<String, dynamic>? customResolution,
  }) async {
    try {
      final conflict = _activeConflicts[conflictId];
      if (conflict == null) {
        return ConflictResolutionResult(
          success: false,
          error: 'Conflicto no encontrado',
        );
      }

      Map<String, dynamic>? resolvedData;

      switch (strategy) {
        case ConflictResolutionStrategy.serverWins:
          resolvedData = conflict.serverData;
          break;

        case ConflictResolutionStrategy.clientWins:
          resolvedData = conflict.clientData;
          break;

        case ConflictResolutionStrategy.merge:
          resolvedData = _mergeConflictData(
            conflict.serverData,
            conflict.clientData,
          );
          break;

        case ConflictResolutionStrategy.custom:
          resolvedData = customResolution;
          break;

        case ConflictResolutionStrategy.askUser:
          // Delegar al UI para resolución manual
          return ConflictResolutionResult(
            success: false,
            requiresUserInput: true,
            conflictData: conflict,
          );
      }

      if (resolvedData != null) {
        // Aplicar resolución
        await _applyConflictResolution(conflictId, resolvedData);

        _conflictResolutions++;
        _activeConflicts.remove(conflictId);

        return ConflictResolutionResult(
          success: true,
          resolvedData: resolvedData,
        );
      }

      return ConflictResolutionResult(
        success: false,
        error: 'No se pudo resolver el conflicto',
      );
    } catch (e) {
      debugPrint('❌ Error resolviendo conflicto: $e');
      return ConflictResolutionResult(
        success: false,
        error: 'Error interno: $e',
      );
    }
  }

  /// 🎯 OBTENER USUARIOS ACTIVOS EN TIEMPO REAL
  Stream<List<ActiveUser>> getActiveUsers() {
    return _firestore
        .collection('active_users')
        .where('isActive', isEqualTo: true)
        .where(
          'lastSeen',
          isGreaterThan: Timestamp.fromDate(
            DateTime.now().subtract(const Duration(minutes: 5)),
          ),
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ActiveUser(
          userId: data['userId'],
          userName: data['userName'],
          lastSeen: (data['lastSeen'] as Timestamp).toDate(),
          platform: data['clientInfo']?['platform'],
        );
      }).toList();
    });
  }

  /// 🎯 OBTENER MÉTRICAS DE SINCRONIZACIÓN
  SyncMetrics getSyncMetrics() {
    return SyncMetrics(
      isConnected: _isConnected,
      lastSyncTimestamp: _lastSyncTimestamp,
      activeSubscriptions: _activeSubscriptions.length,
      pendingUpdates: _pendingUpdates.length,
      conflictResolutions: _conflictResolutions,
      optimisticUpdates: _optimisticUpdates,
      activeUsers: _userHeartbeats.length,
    );
  }

  // ========================================================================
  // 🔧 MÉTODOS PRIVADOS DE IMPLEMENTACIÓN
  // ========================================================================

  Future<void> _setupConnectionMonitoring() async {
    // Monitorear estado de conexión de Firestore
    _firestore.enableNetwork().then((_) {
      _isConnected = true;
      _updateSyncStatus(SyncStatus.connected);
    }).catchError((error) {
      _isConnected = false;
      _updateSyncStatus(SyncStatus.disconnected);
    });
  }

  Future<void> _startHeartbeat() async {
    _heartbeatTimer?.cancel(); // Cancelar timer anterior si existe

    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) async {
      if (!_isInitialized) {
        timer.cancel();
        return;
      }

      try {
        // Actualizar heartbeat del usuario actual
        await _firestore
            .collection('system_heartbeat')
            .doc('current_user')
            .set({
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'active',
        });

        _lastSyncTimestamp = DateTime.now();
        _retryCount = 0; // Reset retry count on successful heartbeat
      } catch (e) {
        debugPrint('⚠️ Error en heartbeat: $e');
        _retryCount++;

        if (_retryCount >= _maxRetryAttempts) {
          _updateSyncStatus(SyncStatus.error);
          await _attemptReconnection();
        }
      }
    });
  }

  Future<void> _stopHeartbeat() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _isInitialized = false;
  }

  Future<void> _attemptReconnection() async {
    if (_isReconnecting) return;

    _isReconnecting = true;
    _updateSyncStatus(SyncStatus.syncing);

    try {
      await _firestore.enableNetwork();
      await _initializeService();
      _updateSyncStatus(SyncStatus.connected);
    } catch (e) {
      debugPrint('❌ Error en reconexión: $e');
      _updateSyncStatus(SyncStatus.error);
    } finally {
      _isReconnecting = false;
    }
  }

  Future<void> _setupGlobalChangeListeners() async {
    // Listener para cambios en profesionales
    _activeSubscriptions['professionals'] = _firestore
        .collection('profesionales')
        .snapshots()
        .listen(_handleProfessionalsChange);

    // Listener para cambios en servicios
    _activeSubscriptions['services'] = _firestore
        .collection('services')
        .snapshots()
        .listen(_handleServicesChange);

    // Listener para cambios en calendarios
    _activeSubscriptions['calendars'] = _firestore
        .collection('calendarios')
        .snapshots()
        .listen(_handleCalendarsChange);
  }

  Future<void> _cleanupObsoleteData() async {
    try {
      final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));

      // Limpiar usuarios inactivos
      await _firestore
          .collection('active_users')
          .where('lastSeen', isLessThan: Timestamp.fromDate(cutoffTime))
          .get()
          .then((snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // Limpiar locks expirados
      await _firestore
          .collection('editing_locks')
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffTime))
          .get()
          .then((snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      debugPrint('✅ Datos obsoletos limpiados');
    } catch (e) {
      debugPrint('⚠️ Error limpiando datos obsoletos: $e');
    }
  }

  void _processSnapshotChanges(QuerySnapshot<Map<String, dynamic>> snapshot) {
    for (final change in snapshot.docChanges) {
      final appointment =
          AppointmentModel.fromMap(change.doc.data()!, change.doc.id);

      switch (change.type) {
        case DocumentChangeType.added:
          onAppointmentCreated?.call(appointment);
          break;
        case DocumentChangeType.modified:
          onAppointmentUpdated?.call(appointment);
          break;
        case DocumentChangeType.removed:
          onAppointmentDeleted?.call(appointment.id);
          break;
      }
    }
  }

  void _handleStreamError(String subscriptionKey, dynamic error) {
    debugPrint('❌ Error en stream $subscriptionKey: $error');

    _retryCount++;

    if (_retryCount < _maxRetryAttempts) {
      // Intentar reconectar después de un delay
      Timer(Duration(seconds: _retryCount * 2), () {
        if (_activeSubscriptions.containsKey(subscriptionKey)) {
          debugPrint(
              '🔄 Intentando reconectar stream $subscriptionKey (intento $_retryCount)');
          _attemptReconnection();
        }
      });
    } else {
      debugPrint('❌ Máximo de intentos alcanzado para $subscriptionKey');
      _updateSyncStatus(SyncStatus.error);
    }
  }

  void _notifyOptimisticChange(
      String appointmentId, Map<String, dynamic> updates) {
    // Notificar cambio optimista a listeners
    if (onAppointmentUpdated != null) {
      try {
        // Crear modelo temporal con los cambios optimistas
        final optimisticAppointment = AppointmentModel(
          id: appointmentId,
          nombreCliente: updates['clienteNombre'],
          profesionalId: updates['profesionalId'],
          servicioNombre: updates['servicioNombre'],
          estado: updates['estado'],
          fechaInicio: updates['fecha'] is Timestamp
              ? (updates['fecha'] as Timestamp).toDate()
              : updates['fecha'],
        );
        onAppointmentUpdated!(optimisticAppointment);
      } catch (e) {
        debugPrint('⚠️ Error notificando cambio optimista: $e');
      }
    }
    debugPrint('⚡ Aplicando cambio optimista en $appointmentId');
  }

  Future<ServerUpdateResult> _sendUpdateToServer(
    String appointmentId,
    Map<String, dynamic> updates,
    String userId,
    String updateId,
  ) async {
    try {
      // Usar transacción para verificar conflictos
      return await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection('bookings').doc(appointmentId);
        final currentDoc = await transaction.get(docRef);

        if (!currentDoc.exists) {
          return ServerUpdateResult(
            success: false,
            error: 'Cita no encontrada',
          );
        }

        final currentData = currentDoc.data()!;
        final currentTimestamp = currentData['updatedAt'] as Timestamp?;

        // Verificar si hay conflictos de concurrencia
        final pendingUpdate = _pendingUpdates[updateId];
        if (pendingUpdate != null && currentTimestamp != null) {
          final serverTime = currentTimestamp.toDate();
          if (serverTime.isAfter(pendingUpdate.timestamp)) {
            // Hay conflicto de concurrencia
            return ServerUpdateResult(
              success: false,
              hasConflict: true,
              conflictData: currentData,
              error: 'Conflicto de concurrencia detectado',
            );
          }
        }

        // Aplicar actualizaciones
        final finalUpdates = {
          ...updates,
          'updatedAt': FieldValue.serverTimestamp(),
          'lastUpdatedBy': userId,
        };

        transaction.update(docRef, finalUpdates);

        return ServerUpdateResult(
          success: true,
          data: {...currentData, ...finalUpdates},
        );
      });
    } catch (e) {
      debugPrint('❌ Error enviando actualización al servidor: $e');
      return ServerUpdateResult(
        success: false,
        error: 'Error de comunicación: $e',
      );
    }
  }

  void _confirmOptimisticUpdate(String updateId) {
    _pendingUpdates.remove(updateId);
    debugPrint('✅ Actualización optimista confirmada: $updateId');
  }

  Future<void> _revertOptimisticUpdate(
    String updateId,
    Map<String, dynamic>? serverData,
  ) async {
    final pendingUpdate = _pendingUpdates.remove(updateId);
    if (pendingUpdate != null) {
      // Revertir cambios en el estado local
      if (onAppointmentUpdated != null && serverData != null) {
        try {
          final revertedAppointment =
              AppointmentModel.fromMap(serverData, pendingUpdate.appointmentId);
          onAppointmentUpdated!(revertedAppointment);
        } catch (e) {
          debugPrint('⚠️ Error revirtiendo estado local: $e');
        }
      }

      debugPrint('🔄 Revirtiendo actualización optimista: $updateId');

      if (serverData != null) {
        // Hay datos del servidor, crear conflicto para resolución
        _createConflictForResolution(pendingUpdate, serverData);
      }
    }
  }

  void _createConflictForResolution(
    PendingUpdate pendingUpdate,
    Map<String, dynamic> serverData,
  ) {
    final conflictId = _generateConflictId();
    final conflict = ConflictResolution(
      id: conflictId,
      appointmentId: pendingUpdate.appointmentId,
      clientData: pendingUpdate.updates,
      serverData: serverData,
      timestamp: DateTime.now(),
      userId: pendingUpdate.userId,
    );

    _activeConflicts[conflictId] = conflict;

    // Notificar sobre el conflicto
    onConflictDetected?.call(ConflictInfo(
      type: ConflictType.concurrencyConflict,
      message: 'Conflicto de datos detectado',
    ));
  }

  Map<String, dynamic> _mergeConflictData(
    Map<String, dynamic> serverData,
    Map<String, dynamic> clientData,
  ) {
    // Estrategia de merge inteligente
    final merged = Map<String, dynamic>.from(serverData);

    // Merge campos específicos con lógica empresarial
    for (final entry in clientData.entries) {
      final key = entry.key;
      final clientValue = entry.value;

      if (key == 'updatedAt') {
        // Usar timestamp más reciente
        continue; // Mantener del servidor
      } else if (key == 'estado') {
        // Dar prioridad a ciertos estados
        if (_isHighPriorityStatus(clientValue)) {
          merged[key] = clientValue;
        }
      } else {
        // Para otros campos, usar valor del cliente
        merged[key] = clientValue;
      }
    }

    return merged;
  }

  bool _isHighPriorityStatus(dynamic status) {
    const highPriorityStatuses = ['cancelado', 'completado'];
    return highPriorityStatuses.contains(status?.toString().toLowerCase());
  }

  Future<void> _applyConflictResolution(
    String conflictId,
    Map<String, dynamic> resolvedData,
  ) async {
    final conflict = _activeConflicts[conflictId];
    if (conflict == null) return;

    try {
      await _firestore
          .collection('bookings')
          .doc(conflict.appointmentId)
          .update({
        ...resolvedData,
        'updatedAt': FieldValue.serverTimestamp(),
        'conflictResolution': {
          'conflictId': conflictId,
          'resolvedAt': FieldValue.serverTimestamp(),
          'resolvedBy': conflict.userId,
        },
      });

      debugPrint('✅ Conflicto $conflictId resuelto');
    } catch (e) {
      debugPrint('❌ Error aplicando resolución de conflicto: $e');
      rethrow;
    }
  }

  void _handleProfessionalsChange(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    // Manejar cambios en profesionales
    for (final change in snapshot.docChanges) {
      final professionalData = change.doc.data();
      if (professionalData != null) {
        debugPrint(
            '👨‍⚕️ Cambio en profesional ${change.doc.id}: ${change.type.name}');

        // Notificar cambios relevantes
        if (change.type == DocumentChangeType.modified) {
          _updateSyncStatus(SyncStatus.syncing);
          // Actualizar caches locales si es necesario
          _updateSyncStatus(SyncStatus.connected);
        }
      }
    }
  }

  void _handleServicesChange(QuerySnapshot<Map<String, dynamic>> snapshot) {
    // Manejar cambios en servicios
    for (final change in snapshot.docChanges) {
      final serviceData = change.doc.data();
      if (serviceData != null) {
        debugPrint(
            '🔧 Cambio en servicio ${change.doc.id}: ${change.type.name}');

        // Actualizar precios y disponibilidad de servicios
        if (change.type == DocumentChangeType.modified) {
          _updateSyncStatus(SyncStatus.syncing);
          // Procesar cambios de servicios
          _updateSyncStatus(SyncStatus.connected);
        }
      }
    }
  }

  void _handleCalendarsChange(QuerySnapshot<Map<String, dynamic>> snapshot) {
    // Manejar cambios en calendarios
    for (final change in snapshot.docChanges) {
      final calendarData = change.doc.data();
      if (calendarData != null) {
        debugPrint(
            '📅 Cambio en calendario ${change.doc.id}: ${change.type.name}');

        // Actualizar disponibilidad de profesionales
        if (change.type == DocumentChangeType.modified) {
          _updateSyncStatus(SyncStatus.syncing);
          // Revalidar citas existentes contra nuevos horarios
          _updateSyncStatus(SyncStatus.connected);
        }
      }
    }
  }

  void _updateSyncStatus(SyncStatus status) {
    onSyncStatusChanged?.call(status);
    notifyListeners();
  }

  String _generateSubscriptionKey(
      DateTime? start, DateTime? end, String? professionalId) {
    return 'sub_${start?.millisecondsSinceEpoch ?? 'null'}_${end?.millisecondsSinceEpoch ?? 'null'}_${professionalId ?? 'all'}';
  }

  String _generateUpdateId() =>
      'update_${DateTime.now().millisecondsSinceEpoch}';
  String _generateConflictId() =>
      'conflict_${DateTime.now().millisecondsSinceEpoch}';

  // ========================================================================
  // 🧹 LIMPIEZA Y DISPOSAL
  // ========================================================================

  @override
  void dispose() {
    // Cancelar timer de heartbeat
    _heartbeatTimer?.cancel();

    // Cancelar todas las suscripciones
    for (final subscription in _activeSubscriptions.values) {
      subscription.cancel();
    }
    _activeSubscriptions.clear();

    // Limpiar estado
    _pendingUpdates.clear();
    _activeConflicts.clear();
    _userHeartbeats.clear();
    _isInitialized = false;

    super.dispose();
  }
}

// ========================================================================
// 📋 MODELOS DE DATOS PARA SINCRONIZACIÓN
// ========================================================================

class OptimisticUpdateResult {
  final bool success;
  final String updateId;
  final Map<String, dynamic>? confirmedData;
  final String? error;
  final bool requiresConflictResolution;
  final Map<String, dynamic>? conflictData;

  OptimisticUpdateResult({
    required this.success,
    required this.updateId,
    this.confirmedData,
    this.error,
    this.requiresConflictResolution = false,
    this.conflictData,
  });
}

class ConflictResolutionResult {
  final bool success;
  final Map<String, dynamic>? resolvedData;
  final String? error;
  final bool requiresUserInput;
  final ConflictResolution? conflictData;

  ConflictResolutionResult({
    required this.success,
    this.resolvedData,
    this.error,
    this.requiresUserInput = false,
    this.conflictData,
  });
}

class ServerUpdateResult {
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;
  final bool hasConflict;
  final Map<String, dynamic>? conflictData;

  ServerUpdateResult({
    required this.success,
    this.data,
    this.error,
    this.hasConflict = false,
    this.conflictData,
  });
}

class PendingUpdate {
  final String id;
  final String appointmentId;
  final Map<String, dynamic> updates;
  final String userId;
  final DateTime timestamp;

  PendingUpdate({
    required this.id,
    required this.appointmentId,
    required this.updates,
    required this.userId,
    required this.timestamp,
  });
}

class ConflictResolution {
  final String id;
  final String appointmentId;
  final Map<String, dynamic> clientData;
  final Map<String, dynamic> serverData;
  final DateTime timestamp;
  final String userId;

  ConflictResolution({
    required this.id,
    required this.appointmentId,
    required this.clientData,
    required this.serverData,
    required this.timestamp,
    required this.userId,
  });
}

class ActiveUser {
  final String userId;
  final String userName;
  final DateTime lastSeen;
  final String? platform;

  ActiveUser({
    required this.userId,
    required this.userName,
    required this.lastSeen,
    this.platform,
  });
}

class SyncMetrics {
  final bool isConnected;
  final DateTime? lastSyncTimestamp;
  final int activeSubscriptions;
  final int pendingUpdates;
  final int conflictResolutions;
  final int optimisticUpdates;
  final int activeUsers;

  SyncMetrics({
    required this.isConnected,
    this.lastSyncTimestamp,
    required this.activeSubscriptions,
    required this.pendingUpdates,
    required this.conflictResolutions,
    required this.optimisticUpdates,
    required this.activeUsers,
  });
}

enum SyncStatus {
  connected,
  disconnected,
  syncing,
  error,
  conflictPending,
}

enum ConflictResolutionStrategy {
  serverWins,
  clientWins,
  merge,
  custom,
  askUser,
}

// ========================================================================
// 🔄 EXTENSIONES PARA APPOINTMENT MODEL
// ========================================================================

extension AppointmentModelSync on AppointmentModel {
  AppointmentModel copyWith({
    String? id,
    String? nombreCliente,
    String? profesionalId,
    String? servicioId,
    DateTime? fechaInicio,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      clientEmail: clientEmail,
      clientPhone: clientPhone,
      profesionalId: profesionalId ?? this.profesionalId,
      profesionalNombre: profesionalNombre,
      servicioId: servicioId ?? this.servicioId,
      servicioNombre: servicioNombre,
      estado: estado,
      comentarios: comentarios,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin,
      duracion: duracion,
    );
  }
}

// ========================================================================
// 🎯 TIPOS PARA CONFLICTOS (REUTILIZANDO DEL OTRO SERVICIO)
// ========================================================================

enum ConflictType {
  concurrencyConflict,
  appointmentConflict,
  unavailableTime,
  blockedTime,
  professionalUnavailable,
  resourceCapacity,
  systemError,
}

class ConflictInfo {
  final ConflictType type;
  final String message;

  ConflictInfo({required this.type, required this.message});
}
