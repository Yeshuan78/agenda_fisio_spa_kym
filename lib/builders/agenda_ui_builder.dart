// [agenda_ui_builder.dart]
// 📁 Ubicación: /lib/builders/agenda_ui_builder.dart
// 🔧 EXTRACCIÓN QUIRÚRGICA: Métodos de construcción de UI
// ✅ ACTUALIZADO CON SISTEMA MANDALA FIBONACCI CONECTADO

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/managers/agenda_state_manager.dart';
import 'package:agenda_fisio_spa_kym/handlers/agenda_event_handlers.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/agenda_metrics_panel.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/agenda_filters_panel.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/agenda_drag_drop_calendar.dart';
import 'package:agenda_fisio_spa_kym/widgets/cost_control/mini_cost_badge.dart';
import 'package:agenda_fisio_spa_kym/screens/cost_control/cost_dashboard_screen.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/cost_data_models.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/background_cost_monitor.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';

class AgendaUIBuilder {
  final BuildContext context;
  final AgendaStateManager stateManager;
  final AgendaEventHandlers eventHandlers;
  final BackgroundCostMonitor costMonitor;
  final Animation<double> headerAnimation;
  final Animation<double> cardsAnimation;
  final Animation<double> fabAnimation;
  final Animation<double> liveAnimation;
  final Function(DateTime)? onDaySelected;

  AgendaUIBuilder({
    required this.context,
    required this.stateManager,
    required this.eventHandlers,
    required this.costMonitor,
    required this.headerAnimation,
    required this.cardsAnimation,
    required this.fabAnimation,
    required this.liveAnimation,
    this.onDaySelected,
  });

  Widget buildScaffold() {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              buildPremiumSliverAppBar(),
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: headerAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - headerAnimation.value)),
                      child: Opacity(
                        opacity: headerAnimation.value,
                        child: buildMetricsSection(),
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: cardsAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - cardsAnimation.value)),
                      child: Opacity(
                        opacity: cardsAnimation.value,
                        child: buildFiltersSection(),
                      ),
                    );
                  },
                ),
              ),
              SliverFillRemaining(
                child: AnimatedBuilder(
                  animation: cardsAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - cardsAnimation.value)),
                      child: Opacity(
                        opacity: cardsAnimation.value,
                        child: buildMainCalendar(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          buildMiniCostBadge(),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: fabAnimation.value,
            child: Transform.rotate(
              angle: (1 - fabAnimation.value) * 0.5,
              child: buildPremiumFAB(),
            ),
          );
        },
      ),
    );
  }

  /// 🎯 NUEVO: Solo el contenido del calendario (sin sidebar duplicado)
  Widget buildCalendarOnly() {
    return Container(
      color: kBackgroundColor,
      child: CustomScrollView(
        slivers: [
          buildPremiumSliverAppBar(),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: headerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - headerAnimation.value)),
                  child: Opacity(
                    opacity: headerAnimation.value,
                    child: buildMetricsSection(),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: cardsAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - cardsAnimation.value)),
                  child: Opacity(
                    opacity: cardsAnimation.value,
                    child: buildFiltersSection(),
                  ),
                );
              },
            ),
          ),
          SliverFillRemaining(
            child: AnimatedBuilder(
              animation: cardsAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - cardsAnimation.value)),
                  child: Opacity(
                    opacity: cardsAnimation.value,
                    child: buildMainCalendar(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🌀 APPBAR CON MANDALA FIBONACCI CONECTADO
  Widget buildPremiumSliverAppBar() {
    return MandalaTheme.buildMandalaAppBar(
      moduleName: 'agenda',
      title: 'Agenda',
      subtitle: 'Sistema inteligente de gestión de citas',
      icon: Icons.calendar_view_week,
      expandedHeight: 220,
      pinned: true,
      floating: false,
      trailing: AnimatedBuilder(
        animation: liveAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: kAccentGreen.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kAccentGreen.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'En vivo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildMetricsSection() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Container(
          margin: const EdgeInsets.all(20),
          child: buildMetricsPanel(),
        ),
      ),
    );
  }

  Widget buildFiltersSection() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: buildFiltersPanel(),
        ),
      ),
    );
  }

  Widget buildMetricsPanel() {
    return AgendaMetricsPanel(
      citasHoy: stateManager.citasHoy,
      citasManana: stateManager.citasManana,
      profesionalesActivos: stateManager.profesionalesActivos,
      cabinasDisponibles: stateManager.cabinasDisponibles,
      ocupacionPromedio: stateManager.ocupacionPromedio,
      isLoading: stateManager.isLoading,
    );
  }

  Widget buildFiltersPanel() {
    return AgendaFiltersPanel(
      selectedView: stateManager.selectedView,
      selectedResource: stateManager.selectedResource,
      selectedDay: stateManager.selectedDay,
      searchQuery: stateManager.searchQuery,
      onViewChanged: (value) => stateManager.selectedView = value,
      onResourceChanged: (value) => stateManager.selectedResource = value,
      onDayChanged: (value) => stateManager.selectedDay = value,
      onSearchChanged: (value) => stateManager.searchQuery = value,
    );
  }

  Widget buildMainCalendar() {
    if (stateManager.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kBrandPurple),
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Cargando agenda en tiempo real...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Container(
          margin: const EdgeInsets.all(20),
          child: AgendaDragDropCalendar(
            selectedView: stateManager.selectedView,
            selectedResource: stateManager.selectedResource,
            selectedDay: stateManager.selectedDay,
            appointments: stateManager.appointments,
            bloqueos: stateManager.bloqueos,
            profesionales: stateManager.profesionales,
            cabinas: stateManager.cabinas,
            servicios: stateManager.servicios,
            eventos: stateManager.eventos,
            onAppointmentMove: eventHandlers.handleAppointmentMove,
            onAppointmentEdit: eventHandlers.handleAppointmentEdit,
            onAppointmentCreate: eventHandlers.handleAppointmentCreate,
            onBlockCreate: eventHandlers.handleBlockCreate,
            onBlockUpdate: eventHandlers.handleBlockUpdate,
            onBlockDelete: eventHandlers.handleBlockDelete,
            onDaySelected: eventHandlers.handleDaySelected,
          ),
        ),
      ),
    );
  }

  Widget buildPremiumFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => eventHandlers.showQuickActionsModal(),
        backgroundColor: kBrandPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: AnimatedBuilder(
          animation: liveAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: liveAnimation.value * 2 * 3.14159,
              child: const Icon(Icons.add_rounded, size: 28),
            );
          },
        ),
        label: const Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// 🏷️ MINI COST BADGE CONECTADO
  Widget buildMiniCostBadge() {
    return Positioned(
      bottom: 100,
      right: 20,
      child: AnimatedBuilder(
        animation: costMonitor,
        builder: (context, child) {
          // 🔍 DEBUG: Verificar datos del costMonitor
          final stats = costMonitor.currentStats;
          debugPrint(
              '🏷️ Badge stats: ${stats.dailyReadCount} lecturas, \${stats.estimatedDailyCost.toStringAsFixed(3)}');

          return MiniCostBadge(
            stats: stats,
            visible: true, // Siempre visible durante desarrollo
            onTap: () {
              debugPrint('🏷️ Badge presionado - navegando a dashboard');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CostDashboardScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
