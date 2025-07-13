// [agenda_metrics_panel.dart] - OVERFLOW CORREGIDO
// 📁 Ubicación: /lib/widgets/agenda/agenda_metrics_panel.dart
// 🔧 CORREGIDO: Constraints y aspectRatio optimizados

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class AgendaMetricsPanel extends StatefulWidget {
  final int citasHoy;
  final int citasManana;
  final int profesionalesActivos;
  final int cabinasDisponibles;
  final double ocupacionPromedio;
  final bool isLoading;

  const AgendaMetricsPanel({
    super.key,
    required this.citasHoy,
    required this.citasManana,
    required this.profesionalesActivos,
    required this.cabinasDisponibles,
    required this.ocupacionPromedio,
    required this.isLoading,
  });

  @override
  State<AgendaMetricsPanel> createState() => _AgendaMetricsPanelState();
}

class _AgendaMetricsPanelState extends State<AgendaMetricsPanel>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _countController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);

    _countController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    );
    _countController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kBorderColor.withValues(alpha: 0.02),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ HEADER DEL PANEL
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kBrandPurple, kAccentBlue],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: kBrandPurple.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Métricas de Agenda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kBrandPurple,
                      ),
                    ),
                    Text(
                      'Dashboard en tiempo real',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // ✅ LIVE INDICATOR
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kAccentGreen,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kAccentGreen.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 8,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ✅ GRID DE MÉTRICAS CORREGIDO
          if (widget.isLoading) _buildLoadingGrid() else _buildMetricsGrid(),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // ✅ CÁLCULO DINÁMICO DE COLUMNAS BASADO EN ANCHO DISPONIBLE
        final availableWidth = constraints.maxWidth;
        final minCardWidth = 120.0;
        final crossAxisCount =
            (availableWidth / minCardWidth).floor().clamp(2, 5);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1, // ✅ RATIO MÁS GRANDE PARA EVITAR OVERFLOW
          children: List.generate(5, (index) => _buildLoadingSkeleton()),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      padding: const EdgeInsets.all(12), // ✅ PADDING REDUCIDO
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // ✅ TAMAÑO MÍNIMO
        children: [
          Container(
            width: 24, // ✅ TAMAÑO REDUCIDO
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8), // ✅ ESPACIADO REDUCIDO
          Container(
            width: 32,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 48,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // ✅ CÁLCULO DINÁMICO DE COLUMNAS BASADO EN ANCHO DISPONIBLE
        final availableWidth = constraints.maxWidth;
        final minCardWidth = 120.0;
        final crossAxisCount =
            (availableWidth / minCardWidth).floor().clamp(2, 5);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1, // ✅ RATIO MÁS GRANDE PARA EVITAR OVERFLOW
          children: [
            _buildMetricCard(
              'Citas Hoy',
              widget.citasHoy,
              Icons.today,
              kAccentBlue,
              '${widget.citasHoy} programadas',
            ),
            _buildMetricCard(
              'Mañana',
              widget.citasManana,
              Icons.event,
              kAccentGreen,
              '${widget.citasManana} agendadas',
            ),
            _buildMetricCard(
              'Profesionales',
              widget.profesionalesActivos,
              Icons.people,
              kBrandPurple,
              '${widget.profesionalesActivos} activos',
            ),
            _buildMetricCard(
              'Cabinas',
              widget.cabinasDisponibles,
              Icons.room,
              Colors.orange.shade600,
              '${widget.cabinasDisponibles} disponibles',
            ),
            _buildOccupancyCard(),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(
    String title,
    int value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(12), // ✅ PADDING REDUCIDO
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // ✅ TAMAÑO MÍNIMO
        children: [
          // ✅ ICONO CON GRADIENTE REDUCIDO
          Container(
            width: 28, // ✅ TAMAÑO REDUCIDO
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16, // ✅ ICONO MÁS PEQUEÑO
            ),
          ),

          const SizedBox(height: 8), // ✅ ESPACIADO REDUCIDO

          // ✅ VALOR ANIMADO
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, child) {
              final currentValue = (_countAnimation.value * value).round();
              return Text(
                '$currentValue',
                style: TextStyle(
                  fontSize: 20, // ✅ TAMAÑO REDUCIDO
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              );
            },
          ),

          const SizedBox(height: 4),

          // ✅ TÍTULO REDUCIDO
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11, // ✅ TAMAÑO REDUCIDO
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis, // ✅ OVERFLOW PROTECTION
            ),
          ),

          const SizedBox(height: 2),

          // ✅ SUBTÍTULO REDUCIDO
          Flexible(
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 9, // ✅ TAMAÑO REDUCIDO
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis, // ✅ OVERFLOW PROTECTION
              maxLines: 1, // ✅ UNA SOLA LÍNEA
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyCard() {
    final occupancyColor = widget.ocupacionPromedio > 80
        ? Colors.red.shade600
        : widget.ocupacionPromedio > 60
            ? Colors.orange.shade600
            : kAccentGreen;

    return Container(
      padding: const EdgeInsets.all(12), // ✅ PADDING REDUCIDO
      decoration: BoxDecoration(
        color: occupancyColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: occupancyColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: occupancyColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // ✅ TAMAÑO MÍNIMO
        children: [
          // ✅ ICONO REDUCIDO
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [occupancyColor, occupancyColor.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.pie_chart_outline,
              color: Colors.white,
              size: 16,
            ),
          ),

          const SizedBox(height: 8),

          // ✅ PORCENTAJE ANIMADO
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, child) {
              final currentValue =
                  (_countAnimation.value * widget.ocupacionPromedio).round();
              return Text(
                '$currentValue%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: occupancyColor,
                ),
              );
            },
          ),

          const SizedBox(height: 4),

          // ✅ TÍTULO
          Flexible(
            child: Text(
              'Ocupación',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 2),

          // ✅ SUBTÍTULO
          Flexible(
            child: Text(
              'Promedio diario',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
