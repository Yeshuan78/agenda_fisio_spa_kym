// [background_cost_monitor.dart] - OPTIMIZADO SIN SPAM - ✅ FIX DEFINITIVO
// 📁 Ubicación: /lib/services/cost_control/background_cost_monitor.dart
// 🎯 OBJETIVO: Monitor sin spam de logs + optimización quirúrgica
// ✅ FIX CRÍTICO: Eliminado spam de logs + control inteligente

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cost_data_models.dart';

class BackgroundCostMonitor extends ChangeNotifier {
  // 📊 Estado actual
  UsageStats _currentStats = UsageStats.empty();
  CostSettings _settings = const CostSettings();
  bool _isInitialized = false;

  // ⏱️ Timers para automatización
  Timer? _statsTimer;
  Timer? _weeklyResetTimer;
  Timer? _smartHoursTimer;

  // 🎯 Callbacks
  Function(String message, String type)? _onAlert;
  Function(String mode)? _onModeChange;

  // ✅ FIX: CONTROL DE LOGS
  bool _verboseLogging = false;
  int _lastLoggedReadCount = 0;

  // 📊 Getters públicos
  UsageStats get currentStats => _currentStats;
  CostSettings get settings => _settings;
  bool get isInitialized => _isInitialized;
  bool get shouldShowBadge => _shouldShowCostBadge();

  /// 🚀 Inicializar el monitor
  Future<void> initialize({
    Function(String message, String type)? onAlert,
    Function(String mode)? onModeChange,
  }) async {
    if (_isInitialized) return;

    _onAlert = onAlert;
    _onModeChange = onModeChange;

    await _loadStatsFromStorage();
    await _loadSettingsFromStorage();
    _setupTimers();

    _isInitialized = true;
    notifyListeners();

    if (_verboseLogging) {
      debugPrint('🤖 BackgroundCostMonitor inicializado');
    }
  }

  /// 📈 Incrementar contador de lecturas - ✅ SIN SPAM LOGS
  void incrementReadCount(int reads, {String? description}) {
    if (reads <= 0) return;

    final newDailyCount = _currentStats.dailyReadCount + reads;
    final newWeeklyCount = _currentStats.weeklyReadCount + reads;

    final newDailyCost = newDailyCount * CostControlConfig.costPerRead;
    final newWeeklyCost = newWeeklyCount * CostControlConfig.costPerRead;

    // Calcular ahorro vs Live Mode
    const liveModeDailyReads = 24 * 60 / 2; // Una lectura cada 2 minutos
    const liveModeWeeklyReads = liveModeDailyReads * 7;
    final savedAmount =
        (liveModeWeeklyReads - newWeeklyCount) * CostControlConfig.costPerRead;

    _currentStats = _currentStats.copyWith(
      dailyReadCount: newDailyCount,
      weeklyReadCount: newWeeklyCount,
      estimatedDailyCost: newDailyCost,
      estimatedWeeklyCost: newWeeklyCost,
      savedAmount: savedAmount.clamp(0.0, double.infinity),
      lastUpdate: DateTime.now(),
    );

    _checkLimitsAndAlert();
    _saveStatsToStorage();
    notifyListeners();

    // ✅ FIX CRÍTICO: SOLO LOG VERBOSE Y CADA 5 LECTURAS
    if (_verboseLogging && (newDailyCount - _lastLoggedReadCount >= 5)) {
      debugPrint(
          '💰 +$reads lecturas ${description ?? ''} | Total: ${_currentStats.dailyReadCount} (\$${_currentStats.estimatedDailyCost.toStringAsFixed(3)})');
      _lastLoggedReadCount = newDailyCount;
    }
  }

  /// 🔄 Cambiar modo de operación
  void setMode(String mode) {
    if (_currentStats.currentMode != mode) {
      _currentStats = _currentStats.copyWith(currentMode: mode);
      _onModeChange?.call(mode);
      notifyListeners();
      _saveStatsToStorage();
      if (_verboseLogging) {
        debugPrint('🔄 Modo cambiado a: $mode');
      }
    }
  }

  /// ⚙️ Actualizar configuración
  Future<void> updateSettings(CostSettings newSettings) async {
    _settings = newSettings;
    await _saveSettingsToStorage();
    _setupTimers(); // Reconfigurar timers con nueva configuración
    notifyListeners();
    if (_verboseLogging) {
      debugPrint('⚙️ Configuración actualizada');
    }
  }

  /// 🔄 Reset manual de estadísticas
  Future<void> resetStats() async {
    _currentStats =
        UsageStats.empty().copyWith(currentMode: _currentStats.currentMode);
    await _saveStatsToStorage();
    notifyListeners();
    if (_verboseLogging) {
      debugPrint('📊 Estadísticas reseteadas manualmente');
    }
  }

  /// 🚨 Verificar límites y enviar alertas
  void _checkLimitsAndAlert() {
    if (_currentStats.isInCriticalZone && _settings.enableNotifications) {
      _onAlert?.call(
          'Límite crítico: ${_currentStats.dailyReadCount}/${_settings.customDailyLimit} lecturas',
          'critical');
    } else if (_currentStats.isInWarningZone && _settings.enableNotifications) {
      _onAlert?.call(
          'Advertencia: ${_currentStats.dailyReadCount}/${_settings.customDailyLimit} lecturas',
          'warning');
    }

    // Auto-cambio de modo si excede límites
    if (_currentStats.isDailyLimitExceeded &&
        _currentStats.currentMode == 'live') {
      setMode('manual');
      _onAlert?.call(
          'Live Mode desactivado automáticamente (límite excedido)', 'info');
    }
  }

  /// 📱 Determinar si mostrar badge
  bool _shouldShowCostBadge() {
    if (!_settings.showCostBadge) return false;

    return _currentStats.isInWarningZone ||
        _currentStats.currentMode == 'live' ||
        _currentStats.estimatedDailyCost > 1.0;
  }

  /// ⏰ Configurar timers automáticos
  void _setupTimers() {
    _statsTimer?.cancel();
    _weeklyResetTimer?.cancel();
    _smartHoursTimer?.cancel();

    // Timer para auto-guardar cada 5 minutos
    _statsTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _saveStatsToStorage();
    });

    // Timer para verificar reset semanal cada hora
    _weeklyResetTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _checkWeeklyReset();
    });

    // Timer para horarios inteligentes cada minuto
    if (_settings.enableSmartHours) {
      _smartHoursTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        _checkSmartHours();
      });
    }
  }

  /// ⏰ Verificar horarios inteligentes
  void _checkSmartHours() {
    if (!_settings.enableSmartHours) return;

    final now = DateTime.now();
    final isWorkHours =
        now.hour >= _settings.workStartHour && now.hour < _settings.workEndHour;

    if (!isWorkHours && _currentStats.currentMode == 'live') {
      setMode('manual');
      _onAlert?.call(
          'Live Mode desactivado automáticamente (fuera de horario laboral)',
          'info');
    }
  }

  /// 📊 Verificar reset semanal
  void _checkWeeklyReset() {
    final now = DateTime.now();
    final daysSinceLastUpdate = now.difference(_currentStats.lastUpdate).inDays;

    if (daysSinceLastUpdate >= 7) {
      _resetWeeklyStats();
    }
  }

  /// 🔄 Reset estadísticas semanales
  void _resetWeeklyStats() {
    _currentStats = _currentStats.copyWith(
      weeklyReadCount: 0,
      estimatedWeeklyCost: 0.0,
      lastUpdate: DateTime.now(),
    );

    _saveStatsToStorage();
    if (_verboseLogging) {
      debugPrint('📊 Reset semanal ejecutado');
    }
  }

  /// 💾 Cargar estadísticas desde storage
  Future<void> _loadStatsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month}-${today.day}';

      final dailyReads = prefs.getInt('daily_reads_$todayKey') ?? 0;
      final weeklyReads = prefs.getInt('weekly_reads') ?? 0;
      final currentMode = prefs.getString('current_mode') ?? 'manual';
      final lastUpdateString = prefs.getString('last_update');

      DateTime lastUpdate = DateTime.now();
      if (lastUpdateString != null) {
        lastUpdate = DateTime.tryParse(lastUpdateString) ?? DateTime.now();
      }

      // Verificar si es un nuevo día
      final lastDay =
          '${lastUpdate.year}-${lastUpdate.month}-${lastUpdate.day}';
      if (lastDay != todayKey) {
        // Nuevo día - resetear lecturas diarias
        await prefs.setInt('daily_reads_$todayKey', 0);
        _currentStats = UsageStats.empty().copyWith(
          weeklyReadCount: weeklyReads,
          currentMode: currentMode,
          lastUpdate: DateTime.now(),
        );
      } else {
        // Mismo día - cargar datos
        final dailyCost = dailyReads * CostControlConfig.costPerRead;
        final weeklyCost = weeklyReads * CostControlConfig.costPerRead;

        const liveModeDailyReads = 24 * 60 / 2;
        const liveModeWeeklyReads = liveModeDailyReads * 7;
        final savedAmount =
            (liveModeWeeklyReads - weeklyReads) * CostControlConfig.costPerRead;

        _currentStats = UsageStats(
          dailyReadCount: dailyReads,
          weeklyReadCount: weeklyReads,
          estimatedDailyCost: dailyCost,
          estimatedWeeklyCost: weeklyCost,
          savedAmount: savedAmount.clamp(0.0, double.infinity),
          lastUpdate: lastUpdate,
          currentMode: currentMode,
        );
      }
    } catch (e) {
      if (_verboseLogging) {
        debugPrint('⚠️ Error cargando estadísticas: $e');
      }
    }
  }

  /// 💾 Guardar estadísticas en storage
  Future<void> _saveStatsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month}-${today.day}';

      await Future.wait([
        prefs.setInt('daily_reads_$todayKey', _currentStats.dailyReadCount),
        prefs.setInt('weekly_reads', _currentStats.weeklyReadCount),
        prefs.setString('current_mode', _currentStats.currentMode),
        prefs.setString(
            'last_update', _currentStats.lastUpdate.toIso8601String()),
      ]);
    } catch (e) {
      if (_verboseLogging) {
        debugPrint('⚠️ Error guardando estadísticas: $e');
      }
    }
  }

  /// ⚙️ Cargar configuración desde storage
  Future<void> _loadSettingsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('cost_settings');

      if (settingsJson != null) {
        final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
        _settings = CostSettings.fromMap(settingsMap);
      }
    } catch (e) {
      if (_verboseLogging) {
        debugPrint('⚠️ Error cargando configuración: $e');
      }
    }
  }

  /// ⚙️ Guardar configuración en storage
  Future<void> _saveSettingsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cost_settings', json.encode(_settings.toMap()));
    } catch (e) {
      if (_verboseLogging) {
        debugPrint('⚠️ Error guardando configuración: $e');
      }
    }
  }

  /// 🔧 MÉTODOS DE CONTROL DE LOGGING

  void enableVerboseLogging() {
    _verboseLogging = true;
    debugPrint('🔊 BackgroundCostMonitor: Logging verbose ACTIVADO');
  }

  void disableVerboseLogging() {
    _verboseLogging = false;
    debugPrint('🔇 BackgroundCostMonitor: Logging verbose DESACTIVADO');
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    _weeklyResetTimer?.cancel();
    _smartHoursTimer?.cancel();
    super.dispose();
  }
}
