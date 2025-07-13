// [cost_analytics_view.dart] - VISTA DE ANALÍTICAS Y ESTADÍSTICAS DETALLADAS
// 📁 Ubicación: /lib/screens/cost_control/cost_analytics_view.dart
// 🎯 OBJETIVO: Análisis completo de uso, costos y tendencias con gráficos

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import '../../services/cost_control/background_cost_monitor.dart';
import '../../services/cost_control/cost_data_models.dart';

class CostAnalyticsView extends StatefulWidget {
  final BackgroundCostMonitor costMonitor;

  const CostAnalyticsView({
    super.key,
    required this.costMonitor,
  });

  @override
  State<CostAnalyticsView> createState() => _CostAnalyticsViewState();
}

class _CostAnalyticsViewState extends State<CostAnalyticsView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: widget.costMonitor,
        builder: (context, child) {
          final stats = widget.costMonitor.currentStats;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(stats),
              const SizedBox(height: 24),
              _buildProgressIndicators(stats),
              const SizedBox(height: 24),
              _buildDetailedStats(stats),
              const SizedBox(height: 24),
              _buildTrendAnalysis(stats),
              const SizedBox(height: 24),
              _buildComparison(stats),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(UsageStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Lecturas Hoy',
            '${stats.dailyReadCount}',
            Icons.visibility,
            kAccentBlue,
            'de ${widget.costMonitor.settings.customDailyLimit}',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Costo Estimado',
            '\$${stats.estimatedDailyCost.toStringAsFixed(3)}',
            Icons.attach_money,
            Colors.orange.shade600,
            'por día',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators(UsageStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progreso de Límites',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressBar(
            'Límite Diario',
            stats.dailyProgress,
            '${stats.dailyReadCount} / ${widget.costMonitor.settings.customDailyLimit}',
            stats.isInCriticalZone ? Colors.red : kAccentGreen,
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            'Límite Semanal',
            stats.weeklyProgress,
            '${stats.weeklyReadCount} / ${widget.costMonitor.settings.customWeeklyLimit}',
            stats.weeklyProgress > 0.8 ? Colors.orange : kAccentBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ],
    );
  }

  Widget _buildDetailedStats(UsageStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas Detalladas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatRow('Lecturas esta semana', '${stats.weeklyReadCount}'),
          _buildStatRow('Costo semanal', '\$${stats.estimatedWeeklyCost.toStringAsFixed(3)}'),
          _buildStatRow('Ahorro vs Live Mode', '\$${stats.savedAmount.toStringAsFixed(2)}'),
          _buildStatRow('Eficiencia', '${_calculateEfficiency(stats)}%'),
          _buildStatRow('Estado actual', stats.statusMessage),
          _buildStatRow('Última actualización', _formatLastUpdate(stats.lastUpdate)),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis(UsageStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kAccentGreen.withValues(alpha: 0.05),
            kAccentBlue.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kAccentGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: kAccentGreen),
              SizedBox(width: 8),
              Text(
                'Análisis de Tendencia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getTrendAnalysis(stats),
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparison(UsageStats stats) {
    const liveModeDailyReads = 24 * 60 / 2; // Una lectura cada 2 minutos
    const liveModeWeeklyCost = liveModeDailyReads * 7 * CostControlConfig.costPerRead;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparación de Modos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildComparisonCard(
                  'Modo Actual',
                  stats.currentMode.toUpperCase(),
                  '\$${stats.estimatedWeeklyCost.toStringAsFixed(2)}',
                  'por semana',
                  _getModeColor(stats.currentMode),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComparisonCard(
                  'Live Mode',
                  'TIEMPO REAL',
                  '\$${liveModeWeeklyCost.toStringAsFixed(2)}',
                  'por semana',
                  Colors.red.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kAccentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.savings, color: kAccentGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Estás ahorrando \$${stats.savedAmount.toStringAsFixed(2)} por semana vs Live Mode',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kAccentGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
    String title,
    String mode,
    String cost,
    String period,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mode,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cost,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            period,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateEfficiency(UsageStats stats) {
    const liveModeDailyReads = 24 * 60 / 2; // Una lectura cada 2 minutos
    final efficiency = ((liveModeDailyReads - stats.dailyReadCount) / liveModeDailyReads) * 100;
    return efficiency.clamp(0, 100).toStringAsFixed(1);
  }

  String _formatLastUpdate(DateTime lastUpdate) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    
    if (difference.inMinutes < 1) {
      return 'Hace unos segundos';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(lastUpdate);
    }
  }

  String _getTrendAnalysis(UsageStats stats) {
    if (stats.isInCriticalZone) {
      return '🚨 ATENCIÓN: Has alcanzado el límite crítico de lecturas. Se recomienda usar solo modo Manual por el resto del día para evitar costos adicionales.';
    } else if (stats.isInWarningZone) {
      return '⚠️ ADVERTENCIA: Te estás acercando al límite diario. Considera activar Horarios Inteligentes o usar Cache más frecuentemente.';
    } else if (stats.currentMode == 'live') {
      return '⚡ MODO LIVE: Estás usando el modo en tiempo real. Los costos están aumentando activamente. Considera usar Modo Burst para sesiones cortas.';
    } else {
      return '✅ EXCELENTE: Tu uso está optimizado. Has ahorrado \$${stats.savedAmount.toStringAsFixed(2)} comparado con el modo Live tradicional.';
    }
  }

  Color _getModeColor(String mode) {
    switch (mode) {
      case 'live':
        return Colors.blue.shade600;
      case 'burst':
        return Colors.orange.shade600;
      case 'manual':
      default:
        return kAccentGreen;
    }
  }
}