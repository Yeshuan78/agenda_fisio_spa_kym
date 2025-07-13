// [client_form_state.dart] - ESTADOS ENTERPRISE PARA FORMULARIO DE CLIENTE
// 📁 Ubicación: /lib/models/clients/client_form_state.dart
// 🎯 OBJETIVO: Gestión robusta de estados para UX profesional

import 'package:flutter/foundation.dart';

/// 📊 ESTADOS PRINCIPALES DEL FORMULARIO
enum ClientFormState {
  /// 🆕 Estado inicial cuando se carga el formulario
  initial,
  
  /// ✏️ Usuario está editando campos
  editing,
  
  /// 🔍 Validando datos en tiempo real
  validating,
  
  /// 💾 Guardando datos en base de datos
  saving,
  
  /// ✅ Operación completada exitosamente
  success,
  
  /// ❌ Error en la operación
  error,
  
  /// 🔄 Cargando datos existentes (modo edición)
  loading,
}

/// 📋 MODELO COMPLETO DE ESTADO
class ClientFormStateModel {
  final ClientFormState state;
  final String? message;
  final String? errorCode;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final double? progress; // Para operaciones con progreso
  
  const ClientFormStateModel({
    required this.state,
    this.message,
    this.errorCode,
    this.metadata,
    required this.timestamp,
    this.progress,
  });

  /// 🏗️ FACTORY CONSTRUCTORS PARA CADA ESTADO
  
  factory ClientFormStateModel.initial() {
    return ClientFormStateModel(
      state: ClientFormState.initial,
      timestamp: DateTime.now(),
    );
  }

  factory ClientFormStateModel.editing() {
    return ClientFormStateModel(
      state: ClientFormState.editing,
      message: 'Editando información del cliente',
      timestamp: DateTime.now(),
    );
  }

  factory ClientFormStateModel.validating({String? field}) {
    return ClientFormStateModel(
      state: ClientFormState.validating,
      message: field != null ? 'Validando $field...' : 'Validando formulario...',
      metadata: field != null ? {'field': field} : null,
      timestamp: DateTime.now(),
    );
  }

  factory ClientFormStateModel.saving({double? progress}) {
    return ClientFormStateModel(
      state: ClientFormState.saving,
      message: 'Guardando cliente...',
      progress: progress,
      timestamp: DateTime.now(),
    );
  }

  factory ClientFormStateModel.success({
    required String message,
    String? clientId,
  }) {
    return ClientFormStateModel(
      state: ClientFormState.success,
      message: message,
      metadata: clientId != null ? {'clientId': clientId} : null,
      timestamp: DateTime.now(),
    );
  }

  factory ClientFormStateModel.error({
    required String message,
    String? errorCode,
    Map<String, dynamic>? details,
  }) {
    return ClientFormStateModel(
      state: ClientFormState.error,
      message: message,
      errorCode: errorCode,
      metadata: details,
      timestamp: DateTime.now(),
    );
  }

  factory ClientFormStateModel.loading({String? message}) {
    return ClientFormStateModel(
      state: ClientFormState.loading,
      message: message ?? 'Cargando datos del cliente...',
      timestamp: DateTime.now(),
    );
  }

  /// 🔄 COPYWITH PARA TRANSICIONES DE ESTADO
  ClientFormStateModel copyWith({
    ClientFormState? state,
    String? message,
    String? errorCode,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    double? progress,
  }) {
    return ClientFormStateModel(
      state: state ?? this.state,
      message: message ?? this.message,
      errorCode: errorCode ?? this.errorCode,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      progress: progress ?? this.progress,
    );
  }

  /// 🎯 GETTERS DE CONVENIENCIA PARA UI
  
  bool get isInitial => state == ClientFormState.initial;
  bool get isEditing => state == ClientFormState.editing;
  bool get isValidating => state == ClientFormState.validating;
  bool get isSaving => state == ClientFormState.saving;
  bool get isSuccess => state == ClientFormState.success;
  bool get isError => state == ClientFormState.error;
  bool get isLoading => state == ClientFormState.loading;
  
  bool get isProcessing => isSaving || isValidating || isLoading;
  bool get canEdit => !isProcessing;
  bool get shouldShowProgress => isSaving && progress != null;
  bool get shouldShowSpinner => isProcessing && !shouldShowProgress;
  
  /// 🎨 PROPIEDADES PARA UI STYLING
  
  String get displayMessage {
    switch (state) {
      case ClientFormState.initial:
        return 'Complete los datos del cliente';
      case ClientFormState.editing:
        return message ?? 'Editando información';
      case ClientFormState.validating:
        return message ?? 'Validando datos...';
      case ClientFormState.saving:
        return message ?? 'Guardando cliente...';
      case ClientFormState.success:
        return message ?? 'Cliente guardado exitosamente';
      case ClientFormState.error:
        return message ?? 'Error al procesar solicitud';
      case ClientFormState.loading:
        return message ?? 'Cargando...';
    }
  }

  /// 🚨 TIPOS DE ERROR ESPECÍFICOS
  
  bool get isValidationError => errorCode?.startsWith('VALIDATION_') == true;
  bool get isCostLimitError => errorCode == 'COST_LIMIT_EXCEEDED';
  bool get isNetworkError => errorCode?.startsWith('NETWORK_') == true;
  bool get isFirestoreError => errorCode?.startsWith('FIRESTORE_') == true;
  bool get isDuplicateError => errorCode == 'DUPLICATE_EMAIL';
  
  /// 📱 FEEDBACK HÁPTICO RECOMENDADO
  
  String? get hapticFeedback {
    switch (state) {
      case ClientFormState.success:
        return 'success'; // HapticFeedback.mediumImpact
      case ClientFormState.error:
        return 'error'; // HapticFeedback.heavyImpact
      case ClientFormState.validating:
        return 'light'; // HapticFeedback.lightImpact
      default:
        return null;
    }
  }

  /// 🎵 SONIDO RECOMENDADO (para accesibilidad)
  
  String? get accessibilitySound {
    switch (state) {
      case ClientFormState.success:
        return 'success_sound';
      case ClientFormState.error:
        return 'error_sound';
      default:
        return null;
    }
  }

  /// 📊 METADATA HELPERS
  
  String? get clientId => metadata?['clientId'] as String?;
  String? get validatingField => metadata?['field'] as String?;
  Map<String, String>? get validationErrors => 
      metadata?['validationErrors'] as Map<String, String>?;

  /// 🔍 LOGGING Y DEBUG
  
  Map<String, dynamic> toLogMap() {
    return {
      'state': state.name,
      'message': message,
      'errorCode': errorCode,
      'timestamp': timestamp.toIso8601String(),
      'progress': progress,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'ClientFormStateModel{state: ${state.name}, message: $message, errorCode: $errorCode}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientFormStateModel &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          message == other.message &&
          errorCode == other.errorCode &&
          mapEquals(metadata, other.metadata) &&
          progress == other.progress;

  @override
  int get hashCode =>
      state.hashCode ^
      message.hashCode ^
      errorCode.hashCode ^
      metadata.hashCode ^
      progress.hashCode;
}

/// 🎯 TRANSICIONES DE ESTADO PERMITIDAS
class ClientFormStateTransitions {
  static const Map<ClientFormState, List<ClientFormState>> _allowedTransitions = {
    ClientFormState.initial: [
      ClientFormState.editing,
      ClientFormState.loading,
      ClientFormState.error,
    ],
    ClientFormState.loading: [
      ClientFormState.editing,
      ClientFormState.error,
      ClientFormState.initial,
    ],
    ClientFormState.editing: [
      ClientFormState.validating,
      ClientFormState.saving,
      ClientFormState.error,
    ],
    ClientFormState.validating: [
      ClientFormState.editing,
      ClientFormState.saving,
      ClientFormState.error,
    ],
    ClientFormState.saving: [
      ClientFormState.success,
      ClientFormState.error,
    ],
    ClientFormState.success: [
      ClientFormState.initial,
      ClientFormState.editing,
    ],
    ClientFormState.error: [
      ClientFormState.initial,
      ClientFormState.editing,
      ClientFormState.validating,
    ],
  };

  /// ✅ VALIDAR SI UNA TRANSICIÓN ES PERMITIDA
  static bool isValidTransition(ClientFormState from, ClientFormState to) {
    return _allowedTransitions[from]?.contains(to) ?? false;
  }

  /// 📋 OBTENER TRANSICIONES PERMITIDAS DESDE UN ESTADO
  static List<ClientFormState> getAllowedTransitions(ClientFormState from) {
    return _allowedTransitions[from] ?? [];
  }

  /// 🚨 VALIDAR TRANSICIÓN O LANZAR EXCEPCIÓN
  static void validateTransition(ClientFormState from, ClientFormState to) {
    if (!isValidTransition(from, to)) {
      throw StateError(
        'Transición inválida de ${from.name} a ${to.name}. '
        'Transiciones permitidas desde ${from.name}: '
        '${getAllowedTransitions(from).map((s) => s.name).join(', ')}'
      );
    }
  }
}

/// 🎮 ACCIONES DISPONIBLES POR ESTADO
class ClientFormActions {
  static const Map<ClientFormState, List<String>> _availableActions = {
    ClientFormState.initial: ['startEditing', 'loadExisting'],
    ClientFormState.loading: ['cancel'],
    ClientFormState.editing: ['validate', 'save', 'cancel', 'reset'],
    ClientFormState.validating: ['save', 'cancel'],
    ClientFormState.saving: ['cancel'],
    ClientFormState.success: ['createNew', 'editAgain', 'close'],
    ClientFormState.error: ['retry', 'reset', 'cancel'],
  };

  /// 📋 OBTENER ACCIONES DISPONIBLES
  static List<String> getAvailableActions(ClientFormState state) {
    return _availableActions[state] ?? [];
  }

  /// ✅ VERIFICAR SI UNA ACCIÓN ESTÁ DISPONIBLE
  static bool isActionAvailable(ClientFormState state, String action) {
    return _availableActions[state]?.contains(action) ?? false;
  }
}

/// 📈 MÉTRICAS DE ESTADO (para analytics)
class ClientFormStateMetrics {
  final Map<ClientFormState, int> stateCount;
  final Map<ClientFormState, Duration> stateDurations;
  final DateTime sessionStart;
  
  ClientFormStateMetrics({
    required this.stateCount,
    required this.stateDurations,
    required this.sessionStart,
  });

  factory ClientFormStateMetrics.empty() {
    return ClientFormStateMetrics(
      stateCount: {},
      stateDurations: {},
      sessionStart: DateTime.now(),
    );
  }

  Duration get totalSessionTime => DateTime.now().difference(sessionStart);
  
  int get totalStateTransitions => 
      stateCount.values.fold(0, (sum, count) => sum + count);

  double get averageValidationTime {
    final validationDuration = stateDurations[ClientFormState.validating];
    final validationCount = stateCount[ClientFormState.validating] ?? 0;
    
    if (validationCount == 0 || validationDuration == null) return 0.0;
    return validationDuration.inMilliseconds / validationCount;
  }

  Map<String, dynamic> toAnalyticsMap() {
    return {
      'session_duration_ms': totalSessionTime.inMilliseconds,
      'total_transitions': totalStateTransitions,
      'state_counts': stateCount.map((k, v) => MapEntry(k.name, v)),
      'state_durations_ms': stateDurations.map((k, v) => MapEntry(k.name, v.inMilliseconds)),
      'average_validation_time_ms': averageValidationTime,
      'session_start': sessionStart.toIso8601String(),
    };
  }
}