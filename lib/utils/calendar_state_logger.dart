// [calendar_state_logger.dart] - Logger Enterprise para Calendario
// 📁 Ubicación: /lib/utils/calendar_state_logger.dart
// 📊 LOGGING ENTERPRISE: Métricas y monitoreo para estado del calendario

import 'package:flutter/foundation.dart';

class CalendarStateLogger {
  static const String _prefix = '🏢 [CalendarState]';
  
  static void logStateChange(String component, String action, Map<String, dynamic> data) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('$_prefix [$timestamp] $component: $action');
      debugPrint('$_prefix Data: $data');
    }
  }

  static void logEvent(String eventType, String source, Map<String, dynamic> data) {
    if (kDebugMode) {
      debugPrint('$_prefix Event: $eventType (source: $source)');
      debugPrint('$_prefix EventData: $data');
    }
  }

  static void logPerformance(String operation, Duration duration) {
    if (kDebugMode) {
      debugPrint('$_prefix Performance: $operation took ${duration.inMilliseconds}ms');
    }
  }

  static void logSync(String fromComponent, String toComponent, String dataType) {
    if (kDebugMode) {
      debugPrint('$_prefix Sync: $dataType from $fromComponent → $toComponent');
    }
  }

  static void logError(String component, String error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrint('$_prefix ERROR in $component: $error');
      if (stackTrace != null) {
        debugPrint('$_prefix StackTrace: $stackTrace');
      }
    }
  }
}