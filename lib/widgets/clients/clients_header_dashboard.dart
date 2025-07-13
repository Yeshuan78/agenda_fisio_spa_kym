// [clients_header_dashboard.dart] - OPTIMIZADO - CONSTRAINT 1200px
// 📁 Ubicación: /lib/widgets/clients/clients_header_dashboard.dart
// 🎯 OBJETIVO: Dashboard 1200px con KPIs + Top Tags en una sola fila

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/services/client_service.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/utils/client_constants.dart';

/// 📊 DASHBOARD CLIENTES OPTIMIZADO - CONSTRAINT 1200px
class ClientsHeaderDashboard extends StatefulWidget {
  final ClientAnalytics analytics;
  final int totalClients;
  final int filteredClients;
  final int selectedClients;
  final VoidCallback onRefresh;

  const ClientsHeaderDashboard({
    super.key,
    required this.analytics,
    required this.totalClients,
    required this.filteredClients,
    required this.selectedClients,
    required this.onRefresh,
  });

  @override
  State<ClientsHeaderDashboard> createState() => _ClientsHeaderDashboardState();
}

class _ClientsHeaderDashboardState extends State<ClientsHeaderDashboard>
    with TickerProviderStateMixin {
  // ✅ CONTROLADORES DE ANIMACIÓN
  late AnimationController _kpiAnimationController;
  late AnimationController _refreshController;

  late Animation<double> _kpiAnimation;

  // ✅ ESTADO DE UI
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Animación de KPIs
    _kpiAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _kpiAnimation = CurvedAnimation(
      parent: _kpiAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Animación de refresh
    _refreshController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  void _startAnimations() {
    _kpiAnimationController.forward();
  }

  @override
  void dispose() {
    _kpiAnimationController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 1200), // 🎯 ACTUALIZADO A 1200PX
        child: Container(
          decoration: _buildMainContainerDecoration(),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              _buildCompactKPIRow(),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎨 DECORACIÓN GLASSMORPHISM PARA CONTAINER PRINCIPAL
  BoxDecoration _buildMainContainerDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.white,
          kBrandPurple.withValues(alpha: 0.02),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kBorderSoft, width: 1),
      boxShadow: [
        BoxShadow(
          color: kBrandPurple.withValues(alpha: 0.1),
          blurRadius: 15,
          spreadRadius: 1,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.8),
          blurRadius: 10,
          spreadRadius: -3,
          offset: const Offset(0, -3),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kBrandPurple, kAccentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard Ejecutivo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: kFontFamily,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getDataFreshnessText(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontFamily: kFontFamily,
                  ),
                ),
              ],
            ),
          ),
          _buildRefreshButton(),
        ],
      ),
    );
  }

  String _getDataFreshnessText() {
    final dataAge = DateTime.now().difference(widget.analytics.lastUpdated);

    if (dataAge.inMinutes < 5) {
      return 'Datos recientes (${dataAge.inMinutes} min)';
    } else if (dataAge.inHours < 1) {
      return 'Cache: hace ${dataAge.inMinutes} min';
    } else if (dataAge.inHours < 24) {
      return 'Cache: hace ${dataAge.inHours}h';
    } else {
      return 'Datos antiguos: ${dataAge.inDays} días';
    }
  }

  Widget _buildRefreshButton() {
    return AnimatedBuilder(
      animation: _refreshController,
      builder: (context, child) {
        return InkWell(
          onTap: _isRefreshing ? null : _handleRefresh,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Transform.rotate(
              angle: _refreshController.value * 2 * 3.14159,
              child: const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 📊 FILA COMPACTA: 4 KPIs + Top Tags
  Widget _buildCompactKPIRow() {
    return AnimatedBuilder(
      animation: _kpiAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _kpiAnimation.value)),
          child: Opacity(
            opacity: _kpiAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // ✅ 4 KPIs COMPACTOS (70% del ancho)
                  Expanded(
                    flex: 7,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildCompactKPI(
                            'Total',
                            widget.analytics.totalClients.toString(),
                            Icons.people,
                            kBrandPurple,
                            '+${widget.analytics.newClients}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCompactKPI(
                            'Activos',
                            widget.analytics.activeClients.toString(),
                            Icons.trending_up,
                            kAccentGreen,
                            '${widget.analytics.activePercentage.toStringAsFixed(0)}%',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCompactKPI(
                            'VIP',
                            widget.analytics.vipClients.toString(),
                            Icons.star,
                            Colors.orange,
                            '${widget.analytics.vipPercentage.toStringAsFixed(0)}%',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildCompactKPI(
                            'Satisfacción',
                            '${widget.analytics.averageSatisfaction.toStringAsFixed(1)}',
                            Icons.sentiment_satisfied,
                            Colors.amber,
                            _getSatisfactionText(
                                widget.analytics.averageSatisfaction),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ✅ TOP TAGS (30% del ancho)
                  Expanded(
                    flex: 3,
                    child: _buildCompactTopTags(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 📊 KPI COMPACTO
  Widget _buildCompactKPI(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      height: 162,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
            color.withValues(alpha: 0.04),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderSoft),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // FILA 1: ICONO + BADGE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              _buildDataFreshnessBadge(),
            ],
          ),

          // FILA 2: VALOR PRINCIPAL (CENTRO EXPANDIDO)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // FILA 3: SUBTÍTULO
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: kTextSecondary,
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 🏷️ TOP TAGS COMPACTO
  Widget _buildCompactTopTags() {
    final topTags = widget.analytics.topTags.take(5).toList();

    return Container(
      height: 162,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
            kAccentGreen.withValues(alpha: 0.04),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderSoft),
        boxShadow: [
          BoxShadow(
            color: kAccentGreen.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER COMPACTO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: kAccentGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.label_outlined,
                      color: kAccentGreen,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Top Tags',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              _buildDataFreshnessBadge(),
            ],
          ),

          const SizedBox(height: 8),

          // TAGS LIST
          Expanded(
            child: topTags.isNotEmpty
                ? Column(
                    children: topTags.asMap().entries.map((entry) {
                      final tag = entry.value;
                      return _buildCompactTagRow(
                        tag['tag'].toString(),
                        tag['count'] as int,
                        ClientConstants.getBaseTagColor(tag['tag']),
                      );
                    }).toList(),
                  )
                : _buildEmptyState('Sin etiquetas', Icons.label_off),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTagRow(String tag, int count, Color color) {
    return Container(
      height: 18,
      margin: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              tag,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: kTextMuted, size: 16),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: kTextMuted,
                fontStyle: FontStyle.italic,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ BADGE COMPACTO
  Widget _buildDataFreshnessBadge() {
    final dataAge = DateTime.now().difference(widget.analytics.lastUpdated);
    final (badgeText, badgeColor) = _getDataFreshnessBadge(dataAge);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badgeColor.withValues(alpha: 0.9),
            badgeColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _getDataFreshnessBadge(Duration dataAge) {
    if (dataAge.inMinutes < 2) {
      return ('RECIENTE', kAccentGreen);
    } else if (dataAge.inMinutes < 10) {
      return ('CACHE', kAccentBlue);
    } else if (dataAge.inHours < 1) {
      return ('VIEJO', Colors.orange);
    } else {
      return ('ANTIGUO', Colors.red);
    }
  }

  String _getSatisfactionText(double score) {
    if (score >= 4.5) return 'Excelente';
    if (score >= 4.0) return 'Muy Bueno';
    if (score >= 3.5) return 'Bueno';
    if (score >= 3.0) return 'Regular';
    return 'Mejorar';
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _refreshController.repeat();

    try {
      widget.onRefresh();
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
        _refreshController.stop();
        _refreshController.reset();
      }
    }
  }
}
