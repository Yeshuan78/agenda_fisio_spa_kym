// [cost_recommendations_view.dart] - VISTA DE RECOMENDACIONES INTELIGENTES
// 📁 Ubicación: /lib/screens/cost_control/cost_recommendations_view.dart
// 🎯 OBJETIVO: IA para optimización automática con recomendaciones personalizadas

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import '../../services/cost_control/background_cost_monitor.dart';
import '../../services/cost_control/cost_data_models.dart';
import '../../widgets/cost_control/cost_alert_overlay.dart';
import '../../services/agenda_data_service.dart';

class CostRecommendationsView extends StatelessWidget {
  final BackgroundCostMonitor costMonitor;

  const CostRecommendationsView({
    super.key,
    required this.costMonitor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: costMonitor,
        builder: (context, child) {
          final stats = costMonitor.currentStats;
          final recommendations = _generateRecommendations(stats);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOptimizationScore(stats),
              const SizedBox(height: 24),
              _buildRecommendationsList(context, recommendations),
              const SizedBox(height: 24),
              _buildQuickActions(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOptimizationScore(UsageStats stats) {
    final efficiency = _calculateEfficiency(stats);
    final scoreColor = _getScoreColor(efficiency);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withValues(alpha: 0.1),
            scoreColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scoreColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Puntuación de Optimización',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getScoreDescription(efficiency),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${efficiency.toStringAsFixed(0)}/100',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: efficiency / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(scoreColor),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(
      BuildContext context, List<Recommendation> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recomendaciones Personalizadas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...recommendations.map((recommendation) =>
            _buildRecommendationCard(context, recommendation)),
      ],
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, Recommendation recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  color: recommendation.priority == 'high'
                      ? Colors.red.withValues(alpha: 0.1)
                      : recommendation.priority == 'medium'
                          ? Colors.orange.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  recommendation.icon,
                  color: recommendation.priority == 'high'
                      ? Colors.red.shade600
                      : recommendation.priority == 'medium'
                          ? Colors.orange.shade600
                          : Colors.green.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getPriorityLabel(recommendation.priority),
                      style: TextStyle(
                        fontSize: 12,
                        color: recommendation.priority == 'high'
                            ? Colors.red.shade600
                            : recommendation.priority == 'medium'
                                ? Colors.orange.shade600
                                : Colors.green.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (recommendation.potentialSaving > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kAccentGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Ahorro: \$${recommendation.potentialSaving.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: kAccentGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (recommendation.actionButton != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => recommendation.actionButton!.action(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandPurple,
                  foregroundColor: Colors.white,
                ),
                child: Text(recommendation.actionButton!.label),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kBrandPurple.withValues(alpha: 0.05),
            kAccentBlue.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBrandPurple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flash_on, color: kBrandPurple),
              SizedBox(width: 8),
              Text(
                'Acciones Rápidas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 🆕 BOTONES DE CACHE DINÁMICOS
          FutureBuilder<bool>(
            future: _getCacheStatus(),
            builder: (context, snapshot) {
              final isCacheEnabled = snapshot.data ?? false;

              return Row(
                children: [
                  Expanded(
                    child: isCacheEnabled
                        ? _buildQuickActionButton(
                            'Desactivar Cache',
                            Icons.storage_outlined,
                            () => _disableCache(context),
                            color: Colors.orange.shade600,
                          )
                        : _buildQuickActionButton(
                            'Activar Cache',
                            Icons.storage,
                            () => _enableCache(context),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionButton(
                      'Horarios Smart',
                      Icons.schedule,
                      () => _enableSmartHours(context),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Modo Manual',
                  Icons.pan_tool,
                  () => _switchToManual(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Optimizar Todo',
                  Icons.auto_fix_high,
                  () => _optimizeAll(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color ?? kBrandPurple,
        side: BorderSide(color: color ?? kBrandPurple),
      ),
    );
  }

  // Helper methods para generar recomendaciones
  List<Recommendation> _generateRecommendations(UsageStats stats) {
    List<Recommendation> recommendations = [];

    // Recomendación crítica si excede límites
    if (stats.isInCriticalZone) {
      recommendations.add(Recommendation(
        title: 'Límite Crítico Alcanzado',
        description:
            'Has excedido el 95% de tu límite diario. Cambia a modo Manual inmediatamente para evitar costos adicionales.',
        priority: 'high',
        icon: Icons.error,
        potentialSaving: 5.0,
        actionButton: ActionButton(
          label: 'Cambiar a Manual',
          action: (context) {
            costMonitor.setMode('manual');
            CostAlertOverlay.showInfoSnackbar(context,
                message: '🔄 Cambiado a modo Manual');
          },
        ),
      ));
    }

    // Recomendación de horarios inteligentes
    if (!costMonitor.settings.enableSmartHours && stats.currentMode == 'live') {
      recommendations.add(Recommendation(
        title: 'Activar Horarios Inteligentes',
        description:
            'Configura horarios de trabajo para que el Live Mode se desactive automáticamente fuera de horas laborales.',
        priority: 'medium',
        icon: Icons.schedule,
        potentialSaving: 2.5,
        actionButton: ActionButton(
          label: 'Configurar Horarios',
          action: (context) {
            final newSettings =
                costMonitor.settings.copyWith(enableSmartHours: true);
            costMonitor.updateSettings(newSettings);
            CostAlertOverlay.showInfoSnackbar(context,
                message: '⏰ Horarios inteligentes activados');
          },
        ),
      ));
    }

    // Recomendación de cache si no está usando
    if (stats.weeklyReadCount > 100) {
      recommendations.add(Recommendation(
        title: 'Optimizar con Cache',
        description:
            'Activa el cache inteligente para reducir las lecturas de Firestore hasta en un 80%.',
        priority: 'medium',
        icon: Icons.storage,
        potentialSaving: 3.0,
      ));
    }

    // Recomendación de modo burst
    if (stats.currentMode == 'live' && costMonitor.settings.enableBurstMode) {
      recommendations.add(Recommendation(
        title: 'Usar Modo Burst',
        description:
            'Para sesiones cortas de trabajo intensivo, usa el Modo Burst que se desactiva automáticamente.',
        priority: 'low',
        icon: Icons.flash_on,
        potentialSaving: 1.0,
      ));
    }

    // Recomendación de eficiencia
    if (_calculateEfficiency(stats) > 90) {
      recommendations.add(Recommendation(
        title: '¡Excelente Optimización!',
        description:
            'Tu uso está muy optimizado. Continúa con estas buenas prácticas para mantener los costos bajos.',
        priority: 'low',
        icon: Icons.eco,
        potentialSaving: 0.0,
      ));
    }

    // Si no hay recomendaciones específicas, agregar sugerencias generales
    if (recommendations.isEmpty) {
      recommendations.add(Recommendation(
        title: 'Sistema Funcionando Correctamente',
        description:
            'No hay recomendaciones críticas en este momento. Tu sistema está funcionando de manera eficiente.',
        priority: 'low',
        icon: Icons.check_circle,
        potentialSaving: 0.0,
      ));
    }

    return recommendations;
  }

  double _calculateEfficiency(UsageStats stats) {
    const liveModeDailyReads = 24 * 60 / 2; // Una lectura cada 2 minutos
    final efficiency =
        ((liveModeDailyReads - stats.dailyReadCount) / liveModeDailyReads) *
            100;
    return efficiency.clamp(0, 100);
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return kAccentGreen;
    if (score >= 60) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  String _getScoreDescription(double score) {
    if (score >= 90) return 'Optimización excelente';
    if (score >= 80) return 'Bien optimizado';
    if (score >= 60) return 'Optimización moderada';
    if (score >= 40) return 'Necesita optimización';
    return 'Optimización crítica requerida';
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return 'PRIORIDAD ALTA';
      case 'medium':
        return 'PRIORIDAD MEDIA';
      case 'low':
        return 'SUGERENCIA';
      default:
        return 'INFO';
    }
  }

  // 🆕 MÉTODOS PARA CACHE
  Future<bool> _getCacheStatus() async {
    try {
      final agendaDataService = AgendaDataService();
      return agendaDataService.isCacheEnabled;
    } catch (e) {
      return false;
    }
  }

  // Quick actions
  void _enableCache(BuildContext context) async {
    try {
      // 🎯 ACTIVAR CACHE REAL EN VEZ DE PLACEHOLDER
      final agendaDataService = AgendaDataService();
      await agendaDataService.enableCache();

      CostAlertOverlay.showInfoSnackbar(context,
          message: '💾 Cache inteligente activado - Ahorro hasta 80%');
    } catch (e) {
      CostAlertOverlay.showInfoSnackbar(
        context,
        message: '❌ Error activando cache: $e',
      );
    }
  }

  void _disableCache(BuildContext context) async {
    try {
      final agendaDataService = AgendaDataService();
      await agendaDataService.disableCache();

      CostAlertOverlay.showInfoSnackbar(context,
          message: '💾 Cache desactivado - Lecturas directas a Firestore');
    } catch (e) {
      CostAlertOverlay.showInfoSnackbar(
        context,
        message: '❌ Error desactivando cache: $e',
      );
    }
  }

  void _enableSmartHours(BuildContext context) {
    final newSettings = costMonitor.settings.copyWith(enableSmartHours: true);
    costMonitor.updateSettings(newSettings);
    CostAlertOverlay.showInfoSnackbar(context,
        message: '⏰ Horarios inteligentes activados');
  }

  void _switchToManual(BuildContext context) {
    costMonitor.setMode('manual');
    CostAlertOverlay.showInfoSnackbar(context,
        message: '🔄 Cambiado a modo Manual');
  }

  void _optimizeAll(BuildContext context) {
    final optimizedSettings = costMonitor.settings.copyWith(
      enableSmartHours: true,
      showCostBadge: true,
      enableNotifications: true,
    );
    costMonitor.updateSettings(optimizedSettings);
    CostAlertOverlay.showInfoSnackbar(context,
        message: '⚡ Optimización automática aplicada');
  }
}

// Clases auxiliares para recomendaciones
class Recommendation {
  final String title;
  final String description;
  final String priority; // 'high', 'medium', 'low'
  final IconData icon;
  final double potentialSaving;
  final ActionButton? actionButton;

  Recommendation({
    required this.title,
    required this.description,
    required this.priority,
    required this.icon,
    this.potentialSaving = 0.0,
    this.actionButton,
  });
}

class ActionButton {
  final String label;
  final Function(BuildContext context) action;

  ActionButton({
    required this.label,
    required this.action,
  });
}
