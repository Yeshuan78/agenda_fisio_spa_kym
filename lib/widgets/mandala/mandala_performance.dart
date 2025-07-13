// [mandala_performance.dart] - OPTIMIZACIONES DE PERFORMANCE
// 📁 Ubicación: /lib/widgets/mandala/mandala_performance.dart
// 🎯 OBJETIVO: Optimizaciones inteligentes para performance del sistema mandala

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

/// 🚀 OPTIMIZADOR DE PERFORMANCE PARA MANDALAS
/// Adapta configuraciones según la plataforma y capacidades del dispositivo
class MandalaPerformance {
  // 🚫 Constructor privado
  MandalaPerformance._();

  // ⚡ CONFIGURACIONES ADAPTIVAS
  static const Duration _webDuration = Duration(seconds: 12);
  static const Duration _mobileDuration = Duration(seconds: 8);
  static const Duration _lowEndDuration = Duration(seconds: 15);

  static const Duration _intelligentPause = Duration(seconds: 3);
  static const Duration _shortPause = Duration(seconds: 2);
  static const Duration _lowEndPause = Duration(seconds: 5);

  // 📊 MÉTRICAS DE PERFORMANCE
  static double _lastFrameTime = 0.0;
  static int _droppedFrames = 0;
  static bool _isLowEndDevice = false;
  static bool _performanceInitialized = false;

  /// 🔧 INICIALIZAR SISTEMA DE PERFORMANCE
  static void initialize() {
    if (_performanceInitialized) return;

    _detectDeviceCapabilities();
    _setupPerformanceMonitoring();
    _performanceInitialized = true;

    debugPrint('🚀 MandalaPerformance inicializado');
    debugPrint('📱 Low-end device: $_isLowEndDevice');
    debugPrint('⏱️ Duration: ${getOptimalDuration()}');
  }

  /// 📱 DETECTAR CAPACIDADES DEL DISPOSITIVO
  static void _detectDeviceCapabilities() {
    try {
      // En web siempre asumimos capacidades normales
      if (kIsWeb) {
        _isLowEndDevice = false;
        return;
      }

      // En móvil, detectar por plataforma
      if (!kIsWeb) {
        // TODO: Aquí podrías agregar detección más sofisticada
        // Por ahora, asumimos capacidades normales
        _isLowEndDevice = false;
      }
    } catch (e) {
      debugPrint('⚠️ Error detectando capacidades: $e');
      _isLowEndDevice = true; // Default conservador
    }
  }

  /// 📊 CONFIGURAR MONITOREO DE PERFORMANCE
  static void _setupPerformanceMonitoring() {
    if (kDebugMode) {
      // En debug mode, monitorear frame rate
      WidgetsBinding.instance.addPersistentFrameCallback(_frameCallback);
    }
  }

  /// 📈 CALLBACK PARA MONITOREAR FRAMES
  static void _frameCallback(Duration timestamp) {
    final currentTime = timestamp.inMilliseconds.toDouble();

    if (_lastFrameTime > 0) {
      final frameDelta = currentTime - _lastFrameTime;
      const targetFrameTime = 16.67; // 60 FPS

      if (frameDelta > targetFrameTime * 1.5) {
        _droppedFrames++;
      }

      // Si hay muchos frames dropped, marcar como low-end
      if (_droppedFrames > 30) {
        _isLowEndDevice = true;
        debugPrint(
            '⚠️ Performance degradada detectada, activando modo low-end');
      }
    }

    _lastFrameTime = currentTime;
  }

  /// ⏱️ OBTENER DURACIÓN ÓPTIMA
  static Duration getOptimalDuration() {
    if (!_performanceInitialized) initialize();

    if (_isLowEndDevice) return _lowEndDuration;
    if (kIsWeb) return _webDuration;
    return _mobileDuration;
  }

  /// ⏸️ OBTENER PAUSA INTELIGENTE
  static Duration getIntelligentPause() {
    if (!_performanceInitialized) initialize();

    return _isLowEndDevice ? _lowEndPause : _intelligentPause;
  }

  /// ⏸️ OBTENER PAUSA CORTA
  static Duration getShortPause() {
    return _shortPause;
  }

  /// 🎨 OBTENER OPACIDAD OPTIMIZADA
  static double getOptimizedOpacity(double baseOpacity) {
    if (!_performanceInitialized) initialize();

    if (_isLowEndDevice) {
      return baseOpacity * 0.7; // Reducir opacidad en dispositivos lentos
    }

    return baseOpacity;
  }

  /// 📏 OBTENER STROKE WIDTH OPTIMIZADO
  static double getOptimizedStrokeWidth(double baseStrokeWidth) {
    if (!_performanceInitialized) initialize();

    if (_isLowEndDevice) {
      return baseStrokeWidth * 0.8; // Líneas más delgadas
    }

    return baseStrokeWidth;
  }

  /// 🔢 OBTENER DENSIDAD DE ELEMENTOS OPTIMIZADA
  static double getElementDensity() {
    if (!_performanceInitialized) initialize();

    if (_isLowEndDevice) return 0.6; // 60% de elementos
    if (kIsWeb) return 1.0; // 100% de elementos
    return 0.8; // 80% de elementos en móvil
  }

  /// 🎯 OBTENER STEP SIZE OPTIMIZADO
  static double getOptimizedStepSize(double baseStep) {
    if (!_performanceInitialized) initialize();

    if (_isLowEndDevice) {
      return baseStep * 1.5; // Pasos más grandes = menos elementos
    }

    return baseStep;
  }

  /// 📊 OBTENER ESTADÍSTICAS DE PERFORMANCE
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'isLowEndDevice': _isLowEndDevice,
      'droppedFrames': _droppedFrames,
      'duration': getOptimalDuration().inSeconds,
      'intelligentPause': getIntelligentPause().inSeconds,
      'elementDensity': getElementDensity(),
      'platform': _getPlatformName(),
      'isWeb': kIsWeb,
      'isDebug': kDebugMode,
      'lastFrameTime': _lastFrameTime,
    };
  }

  /// 🔄 RESETEAR ESTADÍSTICAS
  static void resetStats() {
    _droppedFrames = 0;
    _lastFrameTime = 0.0;
    _isLowEndDevice = false;
    _detectDeviceCapabilities();

    debugPrint('🔄 Performance stats reseteadas');
  }

  /// 📱 OBTENER NOMBRE DE PLATAFORMA
  static String _getPlatformName() {
    if (kIsWeb) return 'Web';

    try {
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
      if (Platform.isWindows) return 'Windows';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isLinux) return 'Linux';
    } catch (e) {
      // En caso de error, asumir web
    }

    return 'Unknown';
  }

  /// 🎮 CONFIGURACIÓN ADAPTIVA PARA PAINTERS
  static MandalaePaintConfig getPaintConfig() {
    if (!_performanceInitialized) initialize();

    return MandalaePaintConfig(
      maxElements: _isLowEndDevice ? 100 : 300,
      stepSize: getOptimizedStepSize(0.1),
      opacity: getOptimizedOpacity(0.3),
      strokeWidth: getOptimizedStrokeWidth(1.0),
      enableAntiAliasing: !_isLowEndDevice,
      enableFilters: !_isLowEndDevice,
      complexityLevel: _isLowEndDevice ? 1 : 3,
    );
  }

  /// 🧪 MODO DEBUG PARA TESTING
  static void enableDebugMode() {
    if (kDebugMode) {
      debugPrint('🧪 Mandala Debug Mode habilitado');
      debugPrint('📊 Stats: ${getPerformanceStats()}');
    }
  }

  /// 🔧 FORZAR MODO LOW-END (para testing)
  static void forceLowEndMode(bool enable) {
    _isLowEndDevice = enable;
    debugPrint('🔧 Modo low-end forzado: $enable');
  }

  /// ⚡ VERIFICAR SI ESTÁ OPTIMIZADO
  static bool get isOptimized => _performanceInitialized && !_isLowEndDevice;

  /// 📊 OBTENER FRAME RATE PROMEDIO
  static double get averageFrameRate {
    if (_lastFrameTime == 0) return 60.0;
    return 1000.0 / (_lastFrameTime / 60);
  }

  /// 🎯 CONFIGURACIÓN INTELIGENTE POR MÓDULO
  static MandalaModuleConfig getModuleConfig(String moduleName) {
    final baseConfig = getPaintConfig();

    switch (moduleName.toLowerCase()) {
      case 'agenda':
        return MandalaModuleConfig(
          paintConfig: baseConfig,
          enableParticles: !_isLowEndDevice,
          particleCount: _isLowEndDevice ? 20 : 50,
          enableGlow: !_isLowEndDevice,
        );

      case 'clientes':
        return MandalaModuleConfig(
          paintConfig: baseConfig.copyWith(
              maxElements: (baseConfig.maxElements * 0.8).round()),
          enableParticles: false, // Flower of Life es complejo por sí mismo
          particleCount: 0,
          enableGlow: true,
        );

      case 'kympulse':
        return MandalaModuleConfig(
          paintConfig: baseConfig.copyWith(complexityLevel: 3),
          enableParticles: true,
          particleCount: _isLowEndDevice ? 30 : 80,
          enableGlow: true,
        );

      default:
        return MandalaModuleConfig(
          paintConfig: baseConfig,
          enableParticles: !_isLowEndDevice,
          particleCount: _isLowEndDevice ? 15 : 40,
          enableGlow: !_isLowEndDevice,
        );
    }
  }
}

/// 🎨 CONFIGURACIÓN DE PAINT OPTIMIZADA
class MandalaePaintConfig {
  final int maxElements;
  final double stepSize;
  final double opacity;
  final double strokeWidth;
  final bool enableAntiAliasing;
  final bool enableFilters;
  final int complexityLevel; // 1-3

  const MandalaePaintConfig({
    required this.maxElements,
    required this.stepSize,
    required this.opacity,
    required this.strokeWidth,
    required this.enableAntiAliasing,
    required this.enableFilters,
    required this.complexityLevel,
  });

  MandalaePaintConfig copyWith({
    int? maxElements,
    double? stepSize,
    double? opacity,
    double? strokeWidth,
    bool? enableAntiAliasing,
    bool? enableFilters,
    int? complexityLevel,
  }) {
    return MandalaePaintConfig(
      maxElements: maxElements ?? this.maxElements,
      stepSize: stepSize ?? this.stepSize,
      opacity: opacity ?? this.opacity,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      enableAntiAliasing: enableAntiAliasing ?? this.enableAntiAliasing,
      enableFilters: enableFilters ?? this.enableFilters,
      complexityLevel: complexityLevel ?? this.complexityLevel,
    );
  }
}

/// 🎯 CONFIGURACIÓN POR MÓDULO
class MandalaModuleConfig {
  final MandalaePaintConfig paintConfig;
  final bool enableParticles;
  final int particleCount;
  final bool enableGlow;

  const MandalaModuleConfig({
    required this.paintConfig,
    required this.enableParticles,
    required this.particleCount,
    required this.enableGlow,
  });
}

/// 🎮 HELPER PARA WIDGETS
class MandalaPerformanceWidget extends StatefulWidget {
  final Widget child;
  final String moduleName;

  const MandalaPerformanceWidget({
    super.key,
    required this.child,
    required this.moduleName,
  });

  @override
  State<MandalaPerformanceWidget> createState() =>
      _MandalaPerformanceWidgetState();
}

class _MandalaPerformanceWidgetState extends State<MandalaPerformanceWidget> {
  @override
  void initState() {
    super.initState();
    MandalaPerformance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      return Stack(
        children: [
          widget.child,
          Positioned(
            top: 100,
            right: 10,
            child: _buildDebugOverlay(),
          ),
        ],
      );
    }

    return widget.child;
  }

  Widget _buildDebugOverlay() {
    final stats = MandalaPerformance.getPerformanceStats();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🌀 ${widget.moduleName.toUpperCase()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'FPS: ${MandalaPerformance.averageFrameRate.toStringAsFixed(1)}',
            style: const TextStyle(color: Colors.green, fontSize: 8),
          ),
          Text(
            'Dropped: ${stats['droppedFrames']}',
            style: const TextStyle(color: Colors.orange, fontSize: 8),
          ),
          Text(
            'Low-end: ${stats['isLowEndDevice']}',
            style: const TextStyle(color: Colors.red, fontSize: 8),
          ),
          Text(
            'Density: ${(stats['elementDensity'] * 100).toInt()}%',
            style: const TextStyle(color: Colors.blue, fontSize: 8),
          ),
        ],
      ),
    );
  }
}

/// 🎯 EXTENSIONES HELPER
extension MandalaPerformanceExt on CustomPainter {
  /// Verificar si debe dibujar basado en performance
  bool shouldDrawElement(int index, int maxElements) {
    final density = MandalaPerformance.getElementDensity();
    return index < (maxElements * density).round();
  }

  /// Obtener opacidad optimizada para un elemento
  double getOptimizedElementOpacity(double baseOpacity, int layer) {
    final optimized = MandalaPerformance.getOptimizedOpacity(baseOpacity);
    return optimized * (1.0 - (layer * 0.1)).clamp(0.1, 1.0);
  }
}
