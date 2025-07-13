// [client_card_factory.dart] - FACTORY ENTERPRISE PARA CARDS DE CLIENTE - ✅ LOGS REDUCIDOS
// 📁 Ubicación: /lib/widgets/clients/client_card_factory.dart
// 🎯 OBJETIVO: Factory pattern robusto con optimizaciones y analytics - SIN SPAM DE LOGS

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:agenda_fisio_spa_kym/enums/view_mode.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/client_card_compact.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/client_card_comfortable.dart'; // Renombrado
import 'package:agenda_fisio_spa_kym/widgets/clients/client_card_table.dart';

/// 🏭 FACTORY ENTERPRISE PARA GENERACIÓN DE CLIENT CARDS
/// Implementa pattern Factory con cache, optimizaciones y métricas
class ClientCardFactory {
  // ✅ CACHE PARA OPTIMIZACIÓN DE RENDERS
  static final Map<String, Widget> _widgetCache = {};
  static const int _maxCacheSize = 100;

  // ✅ MÉTRICAS DE PERFORMANCE
  static final Map<ViewMode, int> _renderCounts = {};
  static final Map<ViewMode, List<int>> _renderTimes = {};

  // ✅ FIX: CONTROL DE LOGS PARA EVITAR SPAM
  static int _cacheLogCount = 0;
  static const int _maxCacheLogs = 5; // Solo primeros 5 logs de cache

  /// 🏗️ FACTORY METHOD PRINCIPAL
  /// Genera el widget apropiado según el modo de vista con optimizaciones
  static Widget buildCard({
    required ViewMode viewMode,
    required ClientModel client,
    required bool isSelected,
    required VoidCallback onSelect,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onQuickPreview,
    bool enableCache = true,
    bool enableHoverEffects = true,
    Map<String, dynamic>? additionalParams,
  }) {
    // 📊 Métricas de inicio
    final stopwatch = Stopwatch()..start();

    // 🗝️ Generar cache key único
    final cacheKey = enableCache
        ? _generateCacheKey(
            viewMode,
            client,
            isSelected,
            enableHoverEffects,
            additionalParams,
          )
        : null;

    // 💾 Verificar cache si está habilitado
    if (enableCache && cacheKey != null && _widgetCache.containsKey(cacheKey)) {
      _recordMetrics(viewMode, stopwatch.elapsedMicroseconds, fromCache: true);

      // ✅ FIX: REDUCIR SPAM DE LOGS DE CACHE
      if (_cacheLogCount < _maxCacheLogs) {
        debugPrint(
            '💾 Card desde cache: ${client.clientId} (${viewMode.name})');
        _cacheLogCount++;
      } else if (_cacheLogCount == _maxCacheLogs) {
        debugPrint('💾 Cache hits adicionales silenciados...');
        _cacheLogCount++;
      }

      return _widgetCache[cacheKey]!;
    }

    // 🏗️ Construir widget según modo
    Widget card;
    try {
      card = _buildCardByMode(
        viewMode: viewMode,
        client: client,
        isSelected: isSelected,
        onSelect: onSelect,
        onEdit: onEdit,
        onDelete: onDelete,
        onQuickPreview: onQuickPreview,
        enableHoverEffects: enableHoverEffects,
        additionalParams: additionalParams,
      );

      // 💾 Guardar en cache si está habilitado
      if (enableCache && cacheKey != null) {
        _cacheWidget(cacheKey, card);
      }
    } catch (e) {
      debugPrint('❌ Error construyendo card: $e');
      card = _buildErrorCard(client, e);
    }

    // 📊 Registrar métricas
    _recordMetrics(viewMode, stopwatch.elapsedMicroseconds);

    return card;
  }

  /// 🎯 BUILDER ESPECÍFICO POR MODO
  static Widget _buildCardByMode({
    required ViewMode viewMode,
    required ClientModel client,
    required bool isSelected,
    required VoidCallback onSelect,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onQuickPreview,
    required bool enableHoverEffects,
    Map<String, dynamic>? additionalParams,
  }) {
    switch (viewMode) {
      case ViewMode.compact:
        return ClientCardCompact(
          client: client,
          isSelected: isSelected,
          onSelect: onSelect,
          onEdit: onEdit,
          onDelete: onDelete,
          onQuickPreview: onQuickPreview,
          showHoverEffects: enableHoverEffects,
        );

      case ViewMode.comfortable:
        return ClientCardComfortable(
          // ✅ WIDGET ORIGINAL RENOMBRADO
          client: client,
          isSelected: isSelected,
          onSelect: onSelect,
          onEdit: onEdit,
          onDelete: onDelete,
          onQuickPreview: onQuickPreview,
        );

      case ViewMode.table:
        final isEvenRow = additionalParams?['isEvenRow'] ?? false;
        return ClientCardTable(
          client: client,
          isSelected: isSelected,
          onSelect: onSelect,
          onEdit: onEdit,
          onDelete: onDelete,
          onQuickPreview: onQuickPreview,
          isEvenRow: isEvenRow,
        );
    }
  }

  /// 🗝️ GENERADOR DE CACHE KEYS
  static String _generateCacheKey(
    ViewMode viewMode,
    ClientModel client,
    bool isSelected,
    bool enableHoverEffects,
    Map<String, dynamic>? additionalParams,
  ) {
    final buffer = StringBuffer();
    buffer.write('${viewMode.name}_');
    buffer.write('${client.clientId}_');
    buffer.write('${client.updatedAt.millisecondsSinceEpoch}_');
    buffer.write('${isSelected}_');
    buffer.write('${enableHoverEffects}_');

    // Agregar parámetros adicionales al cache key
    if (additionalParams != null) {
      final sortedKeys = additionalParams.keys.toList()..sort();
      for (final key in sortedKeys) {
        buffer.write('${key}:${additionalParams[key]}_');
      }
    }

    return buffer.toString();
  }

  /// 💾 GESTIÓN DE CACHE
  static void _cacheWidget(String key, Widget widget) {
    // Limpiar cache si excede el tamaño máximo
    if (_widgetCache.length >= _maxCacheSize) {
      _clearOldestCacheEntries();
    }

    _widgetCache[key] = widget;
  }

  static void _clearOldestCacheEntries() {
    // Remover 20% de las entradas más antiguas
    final entriesToRemove = (_maxCacheSize * 0.2).round();
    final keys = _widgetCache.keys.take(entriesToRemove).toList();

    for (final key in keys) {
      _widgetCache.remove(key);
    }

    // ✅ FIX: SOLO LOG CUANDO ES NECESARIO
    if (kDebugMode) {
      debugPrint('🧹 Cache limpiado: $entriesToRemove entradas removidas');
    }
  }

  /// 📊 MÉTRICAS Y ANALYTICS
  static void _recordMetrics(ViewMode mode, int microseconds,
      {bool fromCache = false}) {
    _renderCounts[mode] = (_renderCounts[mode] ?? 0) + 1;

    if (!fromCache) {
      _renderTimes[mode] ??= [];
      _renderTimes[mode]!.add(microseconds);

      // Mantener solo las últimas 100 mediciones
      if (_renderTimes[mode]!.length > 100) {
        _renderTimes[mode]!.removeAt(0);
      }
    }
  }

  /// 📊 HELPERS DE INFORMACIÓN Y MÉTRICAS

  /// Obtener altura esperada por modo
  static double getCardHeight(ViewMode viewMode) => viewMode.cardHeight;

  /// Obtener spacing esperado por modo
  static EdgeInsets getCardMargin(ViewMode viewMode) => viewMode.cardMargin;

  /// Verificar si el modo soporta una funcionalidad específica
  static bool supportsFeature(ViewMode viewMode, ViewModeFeature feature) {
    return viewMode.supportsFeature(feature);
  }

  /// Obtener número esperado de clientes por pantalla
  static int getExpectedClientsPerScreen(
      ViewMode viewMode, double screenHeight) {
    return viewMode.getExpectedClientsPerScreen(screenHeight);
  }

  /// Verificar si el modo requiere parámetros adicionales
  static bool requiresAdditionalParams(ViewMode viewMode) {
    switch (viewMode) {
      case ViewMode.table:
        return true; // Necesita isEvenRow
      case ViewMode.compact:
      case ViewMode.comfortable:
        return false;
    }
  }

  /// Obtener parámetros requeridos por modo
  static List<String> getRequiredParams(ViewMode viewMode) {
    switch (viewMode) {
      case ViewMode.table:
        return ['isEvenRow'];
      case ViewMode.compact:
      case ViewMode.comfortable:
        return [];
    }
  }

  /// 🎨 BUILDER PARA TABLE HEADER
  static Widget buildTableHeader({
    bool showSortIndicators = true,
    String? sortColumn,
    bool sortAscending = true,
    Function(String)? onSort,
  }) {
    return ClientTableHeader(
      showSortIndicators: showSortIndicators,
      sortColumn: sortColumn,
      sortAscending: sortAscending,
      onSort: onSort,
    );
  }

  /// ❌ BUILDER PARA CASOS DE ERROR
  static Widget _buildErrorCard(ClientModel client, dynamic error) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error renderizando cliente: ${client.fullName}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                Text(
                  error.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🧹 GESTIÓN DE MEMORIA Y CLEANUP

  /// Limpiar cache completamente
  static void clearCache() {
    _widgetCache.clear();
    _cacheLogCount = 0; // ✅ FIX: RESET CONTADOR DE LOGS
    if (kDebugMode) {
      debugPrint('🧹 Cache de widgets limpiado completamente');
    }
  }

  /// Limpiar cache para un cliente específico
  static void clearCacheForClient(String clientId) {
    final keysToRemove =
        _widgetCache.keys.where((key) => key.contains(clientId)).toList();

    for (final key in keysToRemove) {
      _widgetCache.remove(key);
    }

    if (kDebugMode && keysToRemove.isNotEmpty) {
      debugPrint('🧹 Cache limpiado para cliente: $clientId');
    }
  }

  /// Limpiar cache para un modo específico
  static void clearCacheForMode(ViewMode mode) {
    final keysToRemove = _widgetCache.keys
        .where((key) => key.startsWith('${mode.name}_'))
        .toList();

    for (final key in keysToRemove) {
      _widgetCache.remove(key);
    }

    if (kDebugMode && keysToRemove.isNotEmpty) {
      debugPrint('🧹 Cache limpiado para modo: ${mode.name}');
    }
  }

  /// 📊 REPORTE DE PERFORMANCE Y ANALYTICS

  /// Obtener reporte de performance detallado
  static Map<String, dynamic> getPerformanceReport() {
    final report = <String, dynamic>{
      'cacheStats': {
        'size': _widgetCache.length,
        'maxSize': _maxCacheSize,
        'utilizationPercentage':
            (_widgetCache.length / _maxCacheSize * 100).toStringAsFixed(1),
      },
      'renderStats': {},
    };

    for (final mode in ViewMode.values) {
      final renderCount = _renderCounts[mode] ?? 0;
      final renderTimes = _renderTimes[mode] ?? [];

      double avgRenderTime = 0;
      if (renderTimes.isNotEmpty) {
        avgRenderTime =
            renderTimes.reduce((a, b) => a + b) / renderTimes.length;
      }

      report['renderStats'][mode.name] = {
        'totalRenders': renderCount,
        'avgRenderTimeMicros': avgRenderTime.toStringAsFixed(1),
        'avgRenderTimeMs': (avgRenderTime / 1000).toStringAsFixed(2),
        'lastRenderTimes': renderTimes.take(10).toList(),
      };
    }

    return report;
  }

  /// Obtener recomendaciones de optimización
  static List<String> getOptimizationRecommendations() {
    final recommendations = <String>[];
    final report = getPerformanceReport();

    // Analizar utilización de cache
    final cacheUtilization =
        double.parse(report['cacheStats']['utilizationPercentage']);

    if (cacheUtilization > 90) {
      recommendations.add('Considerar aumentar el tamaño del cache');
    } else if (cacheUtilization < 30) {
      recommendations
          .add('El cache podría ser más pequeño para ahorrar memoria');
    }

    // Analizar tiempos de render por modo
    final renderStats = report['renderStats'] as Map<String, dynamic>;

    for (final entry in renderStats.entries) {
      final mode = entry.key;
      final stats = entry.value as Map<String, dynamic>;
      final avgTimeMs = double.parse(stats['avgRenderTimeMs']);

      if (avgTimeMs > 10) {
        recommendations.add('$mode: Tiempo de render alto (${avgTimeMs}ms)');
      }
    }

    if (recommendations.isEmpty) {
      recommendations
          .add('Performance óptima - no se requieren optimizaciones');
    }

    return recommendations;
  }

  /// 🔧 MÉTODOS DE DEBUG Y DESARROLLO

  /// Log de estado del factory para debugging
  static void logFactoryState() {
    if (!kDebugMode) return;

    debugPrint('🏭 ClientCardFactory State:');
    debugPrint('   Cache size: ${_widgetCache.length}/$_maxCacheSize');
    debugPrint('   Render counts: $_renderCounts');

    final report = getPerformanceReport();
    debugPrint('   Performance report: $report');

    final recommendations = getOptimizationRecommendations();
    debugPrint('   Recommendations: $recommendations');
  }

  /// Verificar integridad del factory
  static bool healthCheck() {
    try {
      // Verificar que todos los modos tienen constructors válidos
      for (final mode in ViewMode.values) {
        final testClient = _createTestClient();
        buildCard(
          viewMode: mode,
          client: testClient,
          isSelected: false,
          onSelect: () {},
          onEdit: () {},
          onDelete: () {},
          onQuickPreview: () {},
          enableCache: false,
        );
      }

      if (kDebugMode) {
        debugPrint('✅ ClientCardFactory health check passed');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ClientCardFactory health check failed: $e');
      }
      return false;
    }
  }

  static ClientModel _createTestClient() {
    return ClientModel(
      clientId: 'test_id',
      personalInfo: const PersonalInfo(
        nombre: 'Test',
        apellidos: 'Client',
      ),
      contactInfo: const ContactInfo(
        email: 'test@example.com',
        telefono: '1234567890',
      ),
      addressInfo: const AddressInfo(
        calle: 'Test St',
        numeroExterior: '123',
        colonia: 'Test Col',
        codigoPostal: '12345',
        alcaldia: 'Test Alcaldia',
      ),
      tags: const [],
      metrics: const ClientMetrics(),
      auditInfo: const AuditInfo(createdBy: 'test'),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
