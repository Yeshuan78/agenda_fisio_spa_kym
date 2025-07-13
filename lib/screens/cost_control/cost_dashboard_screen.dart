// [cost_dashboard_screen.dart] - PANTALLA PRINCIPAL DEL DASHBOARD DE CONTROL DE COSTOS
// 📁 Ubicación: /lib/screens/cost_control/cost_dashboard_screen.dart
// 🎯 OBJETIVO: Pantalla independiente con control total, 3 tabs especializados

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import '../../services/cost_control/background_cost_monitor.dart';
import '../../services/cost_control/cost_data_models.dart';
import 'cost_analytics_view.dart';
import 'cost_settings_view.dart';
import 'cost_recommendations_view.dart';

class CostDashboardScreen extends StatefulWidget {
  const CostDashboardScreen({super.key});

  @override
  State<CostDashboardScreen> createState() => _CostDashboardScreenState();
}

class _CostDashboardScreenState extends State<CostDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late BackgroundCostMonitor _costMonitor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _costMonitor = BackgroundCostMonitor();
    _initializeCostMonitor();
  }

  Future<void> _initializeCostMonitor() async {
    await _costMonitor.initialize();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _costMonitor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: _isLoading ? _buildLoadingState() : _buildMainContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: kBrandPurple),
          SizedBox(height: 16),
          Text(
            'Cargando control de costos...',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        _buildTabBar(),
        _buildTabContent(),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kAccentGreen, kAccentBlue],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.savings,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Control de Costos',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Optimización inteligente de Firestore',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: _buildQuickStats(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return AnimatedBuilder(
      animation: _costMonitor,
      builder: (context, child) {
        final stats = _costMonitor.currentStats;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Hoy',
                '\$${stats.estimatedDailyCost.toStringAsFixed(3)}',
                Icons.today,
                stats.isInWarningZone ? Colors.orange : Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Ahorro',
                '\$${stats.savedAmount.toStringAsFixed(2)}',
                Icons.trending_up,
                Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Modo',
                stats.currentMode.toUpperCase(),
                Icons.flash_on,
                stats.currentMode == 'live' ? Colors.yellow : Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: kBrandPurple,
          unselectedLabelColor: Colors.grey,
          indicatorColor: kBrandPurple,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Estadísticas'),
            Tab(icon: Icon(Icons.settings), text: 'Configuración'),
            Tab(icon: Icon(Icons.lightbulb), text: 'Recomendaciones'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          CostAnalyticsView(costMonitor: _costMonitor),
          CostSettingsView(costMonitor: _costMonitor),
          CostRecommendationsView(costMonitor: _costMonitor),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: kBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
