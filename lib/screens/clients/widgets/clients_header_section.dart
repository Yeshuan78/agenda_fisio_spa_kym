// [clients_header_section.dart] - PERFORMANCE OPTIMIZADA
// 📁 Ubicación: /lib/screens/clients/widgets/clients_header_section.dart
// 🎯 OBJETIVO: Widget para header con mandala + dashboard - PERFORMANCE FIJA

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/services/client_service.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/clients_header_dashboard.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/background_cost_monitor.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/cost_data_models.dart';
import 'package:agenda_fisio_spa_kym/widgets/mandala/mandala_painters.dart';

/// 🌀 SECCIÓN HEADER - MANDALA + DASHBOARD
class ClientsHeaderSection extends StatefulWidget {
  final ClientAnalytics? analytics;
  final int totalClients;
  final int filteredClients;
  final int selectedClients;
  final VoidCallback onRefresh;
  final VoidCallback onForceRefresh;
  final Animation<double> headerAnimation;
  final BackgroundCostMonitor costMonitor;

  const ClientsHeaderSection({
    super.key,
    required this.analytics,
    required this.totalClients,
    required this.filteredClients,
    required this.selectedClients,
    required this.onRefresh,
    required this.onForceRefresh,
    required this.headerAnimation,
    required this.costMonitor,
  });

  @override
  State<ClientsHeaderSection> createState() => _ClientsHeaderSectionState();
}

class _ClientsHeaderSectionState extends State<ClientsHeaderSection>
    with TickerProviderStateMixin {
  // ✅ CONTROLADOR DE ANIMACIÓN MANDALA - OPTIMIZADO
  late AnimationController _mandalaController;
  late Animation<double> _mandalaAnimation;

  @override
  void initState() {
    super.initState();
    _initializeMandalaAnimation();
    _startOptimizedMandalaLoop();
  }

  void _initializeMandalaAnimation() {
    // ⚡ DURACIÓN FIJA OPTIMIZADA (SIN PERFORMANCE MONITOR)
    _mandalaController = AnimationController(
      duration: const Duration(seconds: 8), // Duración fija para estabilidad
      vsync: this,
    );

    _mandalaAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mandalaController,
      curve: Curves.easeInOut,
    ));
  }

  void _startOptimizedMandalaLoop() async {
    // ⚡ CICLO OPTIMIZADO SIN MONITORING EXCESIVO
    while (mounted) {
      try {
        // Fase activa
        await _mandalaController.forward();
        if (!mounted) break;

        // Pausa fija optimizada
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) break;

        // Fase reversa
        await _mandalaController.reverse();
        if (!mounted) break;

        // Pausa corta
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        // Si hay error (widget disposed), salir del ciclo
        break;
      }
    }
  }

  @override
  void dispose() {
    // ⚡ DISPOSE SEGURO PARA EVITAR ERRORES
    if (_mandalaController.isAnimating) {
      _mandalaController.stop();
    }
    _mandalaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🌀 MANDALA APPBAR - FLOWER OF LIFE PARA CLIENTES
        _buildMandalaAppBar(context),

        // 📊 DASHBOARD
        _buildHeaderDashboard(),
      ],
    );
  }

  // ====================================================================
  // 🌀 MANDALA APPBAR (PRESERVADO EXACTO + MANDALA FUNCIONANDO)
  // ====================================================================

  Widget _buildMandalaAppBar(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          // Fondo con gradiente mandala
          Container(
            height: 200,
            decoration: BoxDecoration(gradient: kMandalaGradient),
            child: Stack(
              children: [
                // ✅ CÍRCULOS ORGÁNICOS NATURALES
                ..._buildBubbleCircles(),

                // ✅ MANDALA ANIMADO FUNCIONANDO - OPTIMIZADO
                Positioned.fill(
                  child: RepaintBoundary(
                    // ⚡ OPTIMIZACIÓN DE REPAINT
                    child: AnimatedBuilder(
                      animation: _mandalaAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: FlowerOfLifePainter(
                            animationValue: _mandalaAnimation.value,
                            color: Colors.white,
                            strokeWidth: 1.0, // Stroke width fijo optimizado
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Contenido del header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          _buildIconContainer(),
                          const SizedBox(width: 20),
                          _buildTitleSection(),
                          _buildMandalaHeaderCostIndicator(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // AppBar transparente para acciones
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: widget.onForceRefresh,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Actualizar datos',
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // 🔵 CÍRCULOS SIMPLES POR TODO EL APPBAR - SIN COMPLICACIONES
  // ====================================================================

  List<Widget> _buildBubbleCircles() {
    final List<Widget> circles = [];
    final screenWidth = MediaQuery.of(context).size.width;

    // Centro del mandala
    final centerX = screenWidth / 2;
    const centerY = 100.0;

    // CÍRCULOS POR TODO EL APPBAR - SIMPLE Y DIRECTO
    circles.addAll(_createSimpleGridEverywhere(screenWidth, centerX, centerY));

    return circles;
  }

  // 🎯 GRILLA SIMPLE POR TODO EL APPBAR - SIN TOCAR ENTRE CÍRCULOS
  List<Widget> _createSimpleGridEverywhere(
      double screenWidth, double centerX, double centerY) {
    final List<Widget> allCircles = [];

    // Círculos grandes pero SIN que se toquen
    const double circleSize = 95.0; // Círculos grandes
    const double spacing =
        105.0; // Espaciado MAYOR que el círculo para que no se toquen

    // CUBRIR TODO - SIN QUE SE TOQUEN
    for (double x = -200; x <= screenWidth + 200; x += spacing) {
      for (double y = -120; y <= 250; y += spacing) {
        // AGREGAR TODOS LOS CÍRCULOS - SIN EXCLUSIONES
        allCircles.add(
          Positioned(
            left: x - circleSize / 2,
            top: y - circleSize / 2,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1.2,
                ),
              ),
            ),
          ),
        );
      }
    }

    debugPrint('🔵 Total círculos: ${allCircles.length}');
    return allCircles;
  }

  // 🎨 WIDGET CREATOR OPTIMIZADO
  Widget _createCircleWidget(CircleData circle) {
    return Positioned(
      left: circle.x - circle.size / 2,
      top: circle.y - circle.size / 2,
      child: RepaintBoundary(
        child: Container(
          width: circle.size,
          height: circle.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: circle.opacity),
              width: circle.size > 50
                  ? 1.8
                  : circle.size > 35
                      ? 1.4
                      : 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.people_outline, color: Colors.white, size: 36),
    );
  }

  Widget _buildTitleSection() {
    return const Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestión de Clientes',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: kFontFamily,
              letterSpacing: -1.0,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Red de conexiones y relaciones empresariales',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontFamily: kFontFamily,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // 🌸 INDICADOR DE COSTO PARA EL HEADER MANDALA (PRESERVADO EXACTO)
  Widget _buildMandalaHeaderCostIndicator() {
    return StreamBuilder<UsageStats>(
      stream: Stream.periodic(const Duration(seconds: 30))
          .asyncMap((_) async => widget.costMonitor.currentStats),
      initialData: widget.costMonitor.currentStats,
      builder: (context, snapshot) {
        final stats = snapshot.data ?? UsageStats.empty();

        return Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                stats.isInCriticalZone
                    ? Icons.warning
                    : stats.isInWarningZone
                        ? Icons.info
                        : Icons.check_circle,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '${stats.dailyReadCount}/${CostControlConfig.dailyReadLimit}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ====================================================================
  // 📊 DASHBOARD (PRESERVADO EXACTO)
  // ====================================================================

  Widget _buildHeaderDashboard() {
    return AnimatedBuilder(
      animation: widget.headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - widget.headerAnimation.value)),
          child: Opacity(
            opacity: widget.headerAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(20),
              child: widget.analytics != null
                  ? ClientsHeaderDashboard(
                      analytics: widget.analytics!,
                      totalClients: widget.totalClients,
                      filteredClients: widget.filteredClients,
                      selectedClients: widget.selectedClients,
                      onRefresh: widget.onRefresh,
                    )
                  : _buildDashboardSkeleton(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardSkeleton() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: kSombraCard,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kBrandPurple),
        ),
      ),
    );
  }
}

// 📊 DATA CLASS PARA CÍRCULOS
class CircleData {
  final double x;
  final double y;
  final double size;
  final double opacity;

  CircleData(this.x, this.y, this.size, this.opacity);
}
