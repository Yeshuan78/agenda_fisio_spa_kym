// [cost_data_models.dart] - MODELOS DE DATOS PARA SISTEMA DE CONTROL DE COSTOS
// 📁 Ubicación: /lib/services/cost_control/cost_data_models.dart
// 🎯 OBJETIVO: Modelos puros sin dependencias externas para máxima compatibilidad

import 'package:flutter/foundation.dart';

/// 📊 Configuración maestra del sistema
class CostControlConfig {
  // 💰 LÍMITES DE COSTOS
  static const int dailyReadLimit = 100;
  static const int weeklyReadLimit = 500;
  static const double dailyCostLimit = 2.0;
  static const double weeklyCostLimit = 10.0;
  static const double costPerRead = 0.0036; // Precio Firestore

  // ⏰ HORARIOS INTELIGENTES
  static const int workStartHour = 8;
  static const int workEndHour = 18;
  static const bool enableSmartHours = true;

  // 💾 CACHE INTELIGENTE
  static const bool useOfflineFirst = true;
  static const Duration cacheValidDuration = Duration(minutes: 5);

  // 🎮 CONTROLES AVANZADOS
  static const bool enableShakeGesture = true;
  static const Duration burstModeDuration = Duration(minutes: 5);
  
  // 🚨 ALERTAS
  static const double warningThreshold = 0.8; // 80% del límite
  static const double criticalThreshold = 0.95; // 95% del límite
}

/// 📈 Estadísticas de uso
class UsageStats {
  final int dailyReadCount;
  final int weeklyReadCount;
  final double estimatedDailyCost;
  final double estimatedWeeklyCost;
  final double savedAmount;
  final DateTime lastUpdate;
  final String currentMode; // 'manual', 'live', 'burst'

  const UsageStats({
    required this.dailyReadCount,
    required this.weeklyReadCount,
    required this.estimatedDailyCost,
    required this.estimatedWeeklyCost,
    required this.savedAmount,
    required this.lastUpdate,
    required this.currentMode,
  });

  factory UsageStats.empty() {
    return UsageStats(
      dailyReadCount: 0,
      weeklyReadCount: 0,
      estimatedDailyCost: 0.0,
      estimatedWeeklyCost: 0.0,
      savedAmount: 0.0,
      lastUpdate: DateTime.now(),
      currentMode: 'manual',
    );
  }

  UsageStats copyWith({
    int? dailyReadCount,
    int? weeklyReadCount,
    double? estimatedDailyCost,
    double? estimatedWeeklyCost,
    double? savedAmount,
    DateTime? lastUpdate,
    String? currentMode,
  }) {
    return UsageStats(
      dailyReadCount: dailyReadCount ?? this.dailyReadCount,
      weeklyReadCount: weeklyReadCount ?? this.weeklyReadCount,
      estimatedDailyCost: estimatedDailyCost ?? this.estimatedDailyCost,
      estimatedWeeklyCost: estimatedWeeklyCost ?? this.estimatedWeeklyCost,
      savedAmount: savedAmount ?? this.savedAmount,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      currentMode: currentMode ?? this.currentMode,
    );
  }

  // 📊 Métodos de análisis
  bool get isDailyLimitExceeded => dailyReadCount > CostControlConfig.dailyReadLimit;
  bool get isWeeklyLimitExceeded => weeklyReadCount > CostControlConfig.weeklyReadLimit;
  bool get isCostLimitExceeded => estimatedDailyCost > CostControlConfig.dailyCostLimit;
  bool get isInWarningZone => (dailyReadCount / CostControlConfig.dailyReadLimit) >= CostControlConfig.warningThreshold;
  bool get isInCriticalZone => (dailyReadCount / CostControlConfig.dailyReadLimit) >= CostControlConfig.criticalThreshold;
  
  double get dailyProgress => (dailyReadCount / CostControlConfig.dailyReadLimit).clamp(0.0, 1.0);
  double get weeklyProgress => (weeklyReadCount / CostControlConfig.weeklyReadLimit).clamp(0.0, 1.0);
  
  String get statusMessage {
    if (isInCriticalZone) return 'Límite crítico alcanzado';
    if (isInWarningZone) return 'Acercándose al límite';
    return 'Uso normal';
  }
}

/// ⚙️ Configuración de usuario
class CostSettings {
  final bool enableSmartHours;
  final bool enableShakeGesture;
  final bool enableBurstMode;
  final bool showCostBadge;
  final bool enableNotifications;
  final int customDailyLimit;
  final int customWeeklyLimit;
  final int workStartHour;
  final int workEndHour;

  const CostSettings({
    this.enableSmartHours = true,
    this.enableShakeGesture = true,
    this.enableBurstMode = true,
    this.showCostBadge = true,
    this.enableNotifications = true,
    this.customDailyLimit = 100,
    this.customWeeklyLimit = 500,
    this.workStartHour = 8,
    this.workEndHour = 18,
  });

  factory CostSettings.fromMap(Map<String, dynamic> map) {
    return CostSettings(
      enableSmartHours: map['enableSmartHours'] ?? true,
      enableShakeGesture: map['enableShakeGesture'] ?? true,
      enableBurstMode: map['enableBurstMode'] ?? true,
      showCostBadge: map['showCostBadge'] ?? true,
      enableNotifications: map['enableNotifications'] ?? true,
      customDailyLimit: map['customDailyLimit'] ?? 100,
      customWeeklyLimit: map['customWeeklyLimit'] ?? 500,
      workStartHour: map['workStartHour'] ?? 8,
      workEndHour: map['workEndHour'] ?? 18,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enableSmartHours': enableSmartHours,
      'enableShakeGesture': enableShakeGesture,
      'enableBurstMode': enableBurstMode,
      'showCostBadge': showCostBadge,
      'enableNotifications': enableNotifications,
      'customDailyLimit': customDailyLimit,
      'customWeeklyLimit': customWeeklyLimit,
      'workStartHour': workStartHour,
      'workEndHour': workEndHour,
    };
  }

  CostSettings copyWith({
    bool? enableSmartHours,
    bool? enableShakeGesture,
    bool? enableBurstMode,
    bool? showCostBadge,
    bool? enableNotifications,
    int? customDailyLimit,
    int? customWeeklyLimit,
    int? workStartHour,
    int? workEndHour,
  }) {
    return CostSettings(
      enableSmartHours: enableSmartHours ?? this.enableSmartHours,
      enableShakeGesture: enableShakeGesture ?? this.enableShakeGesture,
      enableBurstMode: enableBurstMode ?? this.enableBurstMode,
      showCostBadge: showCostBadge ?? this.showCostBadge,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      customDailyLimit: customDailyLimit ?? this.customDailyLimit,
      customWeeklyLimit: customWeeklyLimit ?? this.customWeeklyLimit,
      workStartHour: workStartHour ?? this.workStartHour,
      workEndHour: workEndHour ?? this.workEndHour,
    );
  }
}