// [import_progress_section.dart] - PROGRESO DE IMPORTACIÓN ULTRA COMPACTO - FIX OVERFLOW
// 📁 Ubicación: /lib/widgets/clients/import/import_progress_section.dart
// 🎯 OBJETIVO: Versión compacta sin sacrificar funcionalidad - SIN OVERFLOW
// ✅ FIX CRÍTICO: Layout constraints para evitar RenderFlex overflow

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'import_models.dart';

/// 📝 ENTRADA DE LOG SIMPLE
class LogEntry {
  final String message;
  final DateTime timestamp;
  final ImportStatus level;

  LogEntry({
    required this.message,
    required this.timestamp,
    required this.level,
  });
}

/// 📊 SECCIÓN DE PROGRESO ENTERPRISE ULTRA COMPACTA - ✅ SIN OVERFLOW
class ImportProgressSection extends StatefulWidget {
  final ImportProgress progress;
  final ImportResult? finalResult;
  final List<String> logs;
  final bool showDetailedLogs;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final Function(ImportResult)? onComplete;

  const ImportProgressSection({
    super.key,
    required this.progress,
    this.finalResult,
    this.logs = const [],
    this.showDetailedLogs = true,
    this.onCancel,
    this.onRetry,
    this.onComplete,
  });

  @override
  State<ImportProgressSection> createState() => _ImportProgressSectionState();
}

class _ImportProgressSectionState extends State<ImportProgressSection>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _successController;
  late AnimationController _warningController;

  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successAnimation;
  late Animation<double> _warningAnimation;

  final ScrollController _logsScrollController = ScrollController();

  // DETECCIÓN DE TIMEOUT
  DateTime? _lastProgressUpdate;
  bool _possibleTimeout = false;
  static const Duration _timeoutThreshold = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _warningController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    _warningAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _warningController,
      curve: Curves.easeInOut,
    ));

    _updateAnimations();
    _processLogs();
    _lastProgressUpdate = DateTime.now();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    _warningController.dispose();
    _logsScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ImportProgressSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.progress.percentage != widget.progress.percentage) {
      _lastProgressUpdate = DateTime.now();
      _possibleTimeout = false;
      _warningController.reset();
      _updateAnimations();
    }

    _checkForTimeout();

    if (oldWidget.logs != widget.logs) {
      _processLogs();
    }
  }

  /// ✅ FIX CRÍTICO: Layout sin overflow
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompactHeader(),
          const SizedBox(height: 12),

          // ✅ FIX: Usar Flexible en lugar de Expanded para progreso
          Flexible(
            flex: 2, // ✅ REDUCIDO de 3 a 2
            child: _buildCompactProgressIndicator(),
          ),
          const SizedBox(height: 12),
          _buildCompactStats(),

          if (widget.showDetailedLogs) ...[
            const SizedBox(height: 12),
            // ✅ FIX CRÍTICO: Flexible con flex reducido para logs
            Flexible(
              flex: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 80, // ✅ ALTURA MÁXIMA FIJA
                  minHeight: 60, // ✅ ALTURA MÍNIMA
                ),
                child: _buildCompactLogsSection(),
              ),
            ),
          ],

          if (_shouldShowActions()) ...[
            const SizedBox(height: 8), // ✅ REDUCIDO spacing
            _buildCompactActions(),
          ],
        ],
      ),
    );
  }

  // ========================================================================
  // 🔧 DETECCIÓN DE TIMEOUT
  // ========================================================================

  void _checkForTimeout() {
    if (_lastProgressUpdate == null || !widget.progress.isActive) return;

    final timeSinceUpdate = DateTime.now().difference(_lastProgressUpdate!);

    if (timeSinceUpdate > _timeoutThreshold && !_possibleTimeout) {
      setState(() {
        _possibleTimeout = true;
      });
      _warningController.repeat(reverse: true);
      debugPrint(
          '⚠️ Posible timeout detectado - ${timeSinceUpdate.inSeconds}s sin progreso');
    }
  }

  // ========================================================================
  // 🎨 COMPONENTES ULTRA COMPACTOS
  // ========================================================================

  /// 🎨 HEADER COMPACTO
  Widget _buildCompactHeader() {
    return Row(
      children: [
        _buildCompactStatusIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _getStatusTitle(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                      fontFamily: kFontFamily,
                    ),
                  ),
                  if (_possibleTimeout) ...[
                    const SizedBox(width: 6),
                    AnimatedBuilder(
                      animation: _warningAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _warningAnimation.value,
                          child: Icon(
                            Icons.warning_amber,
                            color: kWarningColor,
                            size: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _getCurrentOperationWithFeedback(),
                style: TextStyle(
                  fontSize: 12,
                  color: _possibleTimeout ? kWarningColor : kTextSecondary,
                  fontFamily: kFontFamily,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (_possibleTimeout) ...[
                const SizedBox(height: 2),
                Text(
                  'Proceso lento detectado...',
                  style: const TextStyle(
                    fontSize: 10,
                    color: kWarningColor,
                    fontFamily: kFontFamily,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_shouldShowProgressBadge()) _buildCompactBadge(),
      ],
    );
  }

  /// 🎯 ÍCONO DE ESTADO COMPACTO
  Widget _buildCompactStatusIcon() {
    Widget icon;
    Color color = _getStatusColor();

    switch (widget.progress.status) {
      case ImportStatus.completed:
        icon = AnimatedBuilder(
          animation: _successAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _successAnimation.value,
              child: Icon(Icons.check_circle, color: color, size: 24),
            );
          },
        );
        break;
      case ImportStatus.failed:
        icon = Icon(Icons.error, color: color, size: 24);
        break;
      case ImportStatus.cancelled:
        icon = Icon(Icons.cancel, color: color, size: 24);
        break;
      default:
        icon = AnimatedBuilder(
          animation: _possibleTimeout ? _warningAnimation : _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _possibleTimeout
                  ? _warningAnimation.value
                  : _pulseAnimation.value,
              child: SizedBox(
                width: 24,
                height: 24,
                child: _possibleTimeout
                    ? Icon(Icons.hourglass_top, color: kWarningColor, size: 20)
                    : CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
              ),
            );
          },
        );
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color:
            (_possibleTimeout ? kWarningColor : color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(child: icon),
    );
  }

  /// 🏷️ BADGE COMPACTO
  Widget _buildCompactBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withValues(alpha: 0.2)),
      ),
      child: Text(
        '${widget.progress.percentage.toInt()}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(),
          fontFamily: kFontFamily,
        ),
      ),
    );
  }

  /// 📊 INDICADOR DE PROGRESO ULTRA COMPACTO
  Widget _buildCompactProgressIndicator() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderSoft),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // PROGRESO CIRCULAR COMPACTO
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 6,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey.shade200,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: (widget.progress.percentage / 100) *
                            _progressAnimation.value,
                        strokeWidth: 6,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            _possibleTimeout
                                ? kWarningColor
                                : _getStatusColor()),
                      );
                    },
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.progress.percentage.toInt()}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _possibleTimeout
                              ? kWarningColor
                              : _getStatusColor(),
                          fontFamily: kFontFamily,
                        ),
                      ),
                      if (widget.progress.totalRows > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${widget.progress.processedRows}/${widget.progress.totalRows}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: kTextSecondary,
                            fontFamily: kFontFamily,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // INFORMACIÓN COMPACTA
          if (widget.progress.estimatedRemaining != null) ...[
            Text(
              widget.progress.remainingText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: kTextSecondary,
                fontFamily: kFontFamily,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // BARRA DE PROGRESO COMPACTA
          LinearProgressIndicator(
            value: widget.progress.percentage / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
                _possibleTimeout ? kWarningColor : _getStatusColor()),
            minHeight: 3,
          ),
        ],
      ),
    );
  }

  /// 📊 ESTADÍSTICAS ULTRA COMPACTAS
  Widget _buildCompactStats() {
    return Row(
      children: [
        Expanded(
          child: _buildMiniStatCard(
            'Tiempo',
            _formatDuration(widget.progress.elapsed),
            Icons.timer,
            kAccentBlue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniStatCard(
            'Procesadas',
            '${widget.progress.processedRows}',
            Icons.done,
            kAccentGreen,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniStatCard(
            'Estado',
            _possibleTimeout ? 'Lento' : _getShortStatusName(),
            _getStatusIconData(),
            _possibleTimeout ? kWarningColor : _getStatusColor(),
          ),
        ),
      ],
    );
  }

  /// 📊 MINI CARD DE ESTADÍSTICA
  Widget _buildMiniStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: kFontFamily,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontFamily: kFontFamily,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 📋 SECCIÓN DE LOGS COMPACTA - ✅ FIX OVERFLOW
  Widget _buildCompactLogsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // ✅ FIX: MainAxisSize.min
      children: [
        Text(
          'Registro',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kTextSecondary,
            fontFamily: kFontFamily,
          ),
        ),
        const SizedBox(height: 6),

        // ✅ FIX CRÍTICO: Container con altura fija más pequeña
        Container(
          height: 60, // ✅ REDUCIDO de 80 a 60 para evitar overflow
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kBorderSoft),
          ),
          child:
              widget.logs.isEmpty ? _buildEmptyLogs() : _buildCompactLogsList(),
        ),
      ],
    );
  }

  /// ✅ FIX: Empty logs sin overflow
  Widget _buildEmptyLogs() {
    return Center(
      child: Text(
        'Sin registros',
        style: TextStyle(
          fontSize: 11, // ✅ REDUCIDO de 12 a 11
          color: kTextMuted,
          fontFamily: kFontFamily,
        ),
      ),
    );
  }

  /// ✅ FIX: Lista de logs compacta
  Widget _buildCompactLogsList() {
    return ListView.builder(
      controller: _logsScrollController,
      padding: const EdgeInsets.all(2), // ✅ REDUCIDO padding
      itemCount: widget.logs.length,
      itemBuilder: (context, index) {
        final log = widget.logs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 1), // ✅ REDUCIDO margin
          padding: const EdgeInsets.symmetric(
              horizontal: 4, vertical: 2), // ✅ REDUCIDO padding
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(2), // ✅ REDUCIDO border radius
          ),
          child: Text(
            '${DateTime.now().toString().substring(11, 19)} - $log',
            style: const TextStyle(
              fontSize: 9, // ✅ REDUCIDO de 10 a 9
              fontFamily: 'monospace',
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  /// 🎮 ACCIONES COMPACTAS
  Widget _buildCompactActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.onCancel != null && widget.progress.isActive)
          _buildCompactButton(
            onPressed: widget.onCancel!,
            icon: Icons.cancel,
            label: _possibleTimeout ? 'Forzar' : 'Cancelar',
            color: kErrorColor,
            isOutlined: true,
          ),
        if (_possibleTimeout && widget.progress.isActive) ...[
          const SizedBox(width: 8),
          _buildCompactButton(
            onPressed: _showDiagnosticInfo,
            icon: Icons.info_outline,
            label: 'Info',
            color: kWarningColor,
            isOutlined: true,
          ),
        ],
        if (widget.onRetry != null &&
            widget.progress.status == ImportStatus.failed) ...[
          const SizedBox(width: 12),
          _buildCompactButton(
            onPressed: widget.onRetry!,
            icon: Icons.refresh,
            label: 'Reintentar',
            color: kBrandPurple,
          ),
        ],
        if (widget.onComplete != null && widget.finalResult != null)
          _buildCompactButton(
            onPressed: () => widget.onComplete!(widget.finalResult!),
            icon: Icons.check,
            label: 'Finalizar',
            color: kAccentGreen,
          ),
      ],
    );
  }

  /// 🔘 BOTÓN COMPACTO HELPER
  Widget _buildCompactButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }
  }

  // ========================================================================
  // 🔧 MÉTODOS HELPER
  // ========================================================================

  void _showDiagnosticInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diagnóstico', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progreso: ${widget.progress.percentage.toInt()}%',
                style: const TextStyle(fontSize: 12)),
            Text('Tiempo: ${_formatDuration(widget.progress.elapsed)}',
                style: const TextStyle(fontSize: 12)),
            Text(
                'Procesadas: ${widget.progress.processedRows}/${widget.progress.totalRows}',
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            const Text('Posibles causas:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Text('• Archivo grande', style: TextStyle(fontSize: 11)),
            const Text('• Conexión lenta', style: TextStyle(fontSize: 11)),
            const Text('• Validaciones complejas',
                style: TextStyle(fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  String _getCurrentOperationWithFeedback() {
    if (_possibleTimeout) {
      return '${widget.progress.currentOperation} (lento)';
    }
    return widget.progress.currentOperation;
  }

  String _getShortStatusName() {
    switch (widget.progress.status) {
      case ImportStatus.idle:
        return 'Idle';
      case ImportStatus.analyzing:
        return 'Analiz.';
      case ImportStatus.mapping:
        return 'Mapeo';
      case ImportStatus.validating:
        return 'Valid.';
      case ImportStatus.importing:
        return 'Import.';
      case ImportStatus.completed:
        return 'OK';
      case ImportStatus.failed:
        return 'Error';
      case ImportStatus.cancelled:
        return 'Cancel.';
    }
  }

  void _updateAnimations() {
    final targetProgress = widget.progress.percentage / 100;
    _progressController.animateTo(targetProgress);

    switch (widget.progress.status) {
      case ImportStatus.completed:
        _successController.forward();
        _pulseController.stop();
        _warningController.stop();
        break;
      case ImportStatus.failed:
      case ImportStatus.cancelled:
        _pulseController.stop();
        _warningController.stop();
        break;
      default:
        if (widget.progress.isActive) {
          _pulseController.repeat(reverse: true);
        }
        break;
    }
  }

  void _processLogs() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logsScrollController.hasClients) {
        _logsScrollController.animateTo(
          _logsScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getStatusTitle() {
    if (_possibleTimeout) return 'Lento';

    switch (widget.progress.status) {
      case ImportStatus.idle:
        return 'Esperando';
      case ImportStatus.analyzing:
        return 'Analizando';
      case ImportStatus.mapping:
        return 'Mapeando';
      case ImportStatus.validating:
        return 'Validando';
      case ImportStatus.importing:
        return 'Importando';
      case ImportStatus.completed:
        return 'Completado';
      case ImportStatus.failed:
        return 'Error';
      case ImportStatus.cancelled:
        return 'Cancelado';
    }
  }

  Color _getStatusColor() {
    if (_possibleTimeout) return kWarningColor;

    switch (widget.progress.status) {
      case ImportStatus.idle:
        return kTextSecondary;
      case ImportStatus.analyzing:
      case ImportStatus.mapping:
      case ImportStatus.validating:
      case ImportStatus.importing:
        return kBrandPurple;
      case ImportStatus.completed:
        return kAccentGreen;
      case ImportStatus.failed:
        return kErrorColor;
      case ImportStatus.cancelled:
        return kWarningColor;
    }
  }

  IconData _getStatusIconData() {
    if (_possibleTimeout) return Icons.hourglass_top;

    switch (widget.progress.status) {
      case ImportStatus.idle:
        return Icons.hourglass_empty;
      case ImportStatus.analyzing:
      case ImportStatus.mapping:
      case ImportStatus.validating:
      case ImportStatus.importing:
        return Icons.sync;
      case ImportStatus.completed:
        return Icons.check_circle;
      case ImportStatus.failed:
        return Icons.error;
      case ImportStatus.cancelled:
        return Icons.cancel;
    }
  }

  bool _shouldShowProgressBadge() {
    return widget.progress.status != ImportStatus.idle &&
        widget.progress.status != ImportStatus.failed &&
        widget.progress.status != ImportStatus.cancelled;
  }

  bool _shouldShowActions() {
    return widget.onCancel != null ||
        widget.onRetry != null ||
        (widget.onComplete != null && widget.finalResult != null);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
