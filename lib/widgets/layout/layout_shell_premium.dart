// [layout_shell_premium.dart] - REFACTORIZADO QUIRÚRGICO
// 📁 Ubicación: /lib/widgets/layout/layout_shell_premium.dart
// 🚀 COORDINADOR PRINCIPAL - CÓDIGO MODULAR
// 🔧 FIX ANTI-DUPLICACIÓN: Control de renderizado para evitar múltiples sidebars

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/custom_sidebar_ultra_premium.dart';
import 'package:agenda_fisio_spa_kym/widgets/search/global_search_overlay.dart';
import 'package:agenda_fisio_spa_kym/widgets/notifications/notification_center.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/layout/components/premium_app_bar.dart';
import 'package:agenda_fisio_spa_kym/widgets/layout/components/premium_loading_screen.dart';
import 'package:agenda_fisio_spa_kym/widgets/layout/components/quick_actions_row.dart';
import 'package:agenda_fisio_spa_kym/widgets/layout/components/floating_quick_actions.dart';
import 'package:agenda_fisio_spa_kym/widgets/layout/models/layout_shell_state.dart';

class LayoutShellPremium extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  final Function(String) onNavigate;
  final DateTime? selectedDay;
  final Map<DateTime, List<dynamic>>? appointments;
  final Function(DateTime)? onDaySelected;

  const LayoutShellPremium({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.onNavigate,
    this.selectedDay,
    this.appointments,
    this.onDaySelected,
  });

  @override
  State<LayoutShellPremium> createState() => _LayoutShellPremiumState();
}

class _LayoutShellPremiumState extends State<LayoutShellPremium>
    with TickerProviderStateMixin {
  // ✅ KEYS ESTÁTICOS PARA FIX DEL SIDEBAR
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _sidebarKey = GlobalKey();

  late AnimationController _layoutController;
  late Animation<double> _slideAnimation;

  // ✅ ESTADO REFACTORIZADO
  LayoutShellState _state = const LayoutShellState();

  // 🔧 FIX: DATOS PERSISTENTES PARA MINI CALENDARIO
  DateTime? _persistentSelectedDay;
  Map<DateTime, List<dynamic>>? _persistentAppointments;

  @override
  void initState() {
    super.initState();
    // 🔧 FIX: INICIALIZAR DATOS PERSISTENTES
    _persistentSelectedDay = widget.selectedDay ?? DateTime.now();
    _persistentAppointments = widget.appointments ?? {};

    _initAnimations();
    _simulateLoading();
    _setupKeyboardShortcuts();
  }

  @override
  void didUpdateWidget(LayoutShellPremium oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔧 FIX: ACTUALIZAR DATOS PERSISTENTES CUANDO CAMBIAN
    if (widget.selectedDay != null &&
        widget.selectedDay != _persistentSelectedDay) {
      _persistentSelectedDay = widget.selectedDay;
    }

    if (widget.appointments != null &&
        widget.appointments != _persistentAppointments) {
      _persistentAppointments = widget.appointments;
    }
  }

  void _initAnimations() {
    _layoutController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _layoutController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _state = _state.copyWith(isLoading: false);
      });
      _layoutController.forward();
    }
  }

  void _setupKeyboardShortcuts() {
    ServicesBinding.instance.keyboard.addHandler(_handleKeyPress);
  }

  bool _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      if ((event.logicalKey == LogicalKeyboardKey.keyK) &&
          (HardwareKeyboard.instance.isMetaPressed ||
              HardwareKeyboard.instance.isControlPressed)) {
        _openGlobalSearch();
        return true;
      }
    }
    return false;
  }

  void _openGlobalSearch() {
    setState(() {
      _state = _state.copyWith(showSearchOverlay: true);
    });
    HapticFeedback.lightImpact();
  }

  void _closeGlobalSearch() {
    setState(() {
      _state = _state.copyWith(showSearchOverlay: false);
    });
  }

  void _openNotificationCenter() {
    setState(() {
      _state = _state.copyWith(showNotificationCenter: true);
    });
    HapticFeedback.lightImpact();
  }

  void _closeNotificationCenter() {
    setState(() {
      _state = _state.copyWith(showNotificationCenter: false);
    });
  }

  void _handleNavigation(String route) {
    debugPrint('🧭 Navegando desde LayoutShell a: $route');

    // Manejar rutas especiales de agenda
    switch (route) {
      case '/agenda/premium':
        debugPrint('📊 Usuario accedió a Agenda Premium');
        _showPremiumFeatureNotification();
        break;
      case '/agenda/semanal':
        debugPrint('⚠️ Usuario usando agenda legacy');
        _showLegacyMigrationTip();
        break;
      case '/agenda/diaria':
        debugPrint('📅 Usuario accedió a Vista Diaria');
        break;
    }

    widget.onNavigate(route);

    // Cerrar overlays si están abiertos
    if (_state.showSearchOverlay) {
      setState(() {
        _state = _state.copyWith(showSearchOverlay: false);
      });
    }
    if (_state.showNotificationCenter) {
      setState(() {
        _state = _state.copyWith(showNotificationCenter: false);
      });
    }

    HapticFeedback.lightImpact();
  }

  // 🔧 FIX: CALLBACK PARA MINI CALENDARIO
  void _handleDaySelected(DateTime selectedDay) {
    debugPrint('📅 Día seleccionado desde mini calendario: $selectedDay');

    // Actualizar estado persistente
    setState(() {
      _persistentSelectedDay = selectedDay;
    });

    // Llamar callback del widget padre si existe
    if (widget.onDaySelected != null) {
      widget.onDaySelected!(selectedDay);
    }
  }

  void _showPremiumFeatureNotification() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.orangeAccent],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Agenda Premium Activada',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Drag & Drop, vistas avanzadas y más funcionalidades',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: kBrandPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showLegacyMigrationTip() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.orange.shade200,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Vista Legacy Activa',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Prueba la nueva Agenda Premium para más funcionalidades',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _handleNavigation('/agenda/premium');
              },
              child: const Text(
                'Probar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_handleKeyPress);
    _layoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_state.isLoading) {
      return const PremiumLoadingScreen();
    }

    final routesWithSliverAppBar = [
      '/eventos',
      '/kympulse',
      '/agenda/premium',
      '/clientes/premium',
      '/profesionales',
      '/servicios',
      '/recordatorios',
      '/admin',
      '/dev/widgets'
    ];
    final hasOwnSliverAppBar =
        routesWithSliverAppBar.contains(widget.currentRoute);

    return Scaffold(
      key: _scaffoldKey, // ← FIX SIDEBAR: Key estático
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Row(
            children: [
              // SIDEBAR CON KEY ESTÁTICO
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_slideAnimation.value * 280, 0),
                    child: CustomSidebarUltraPremium(
                      key: _sidebarKey, // ← FIX SIDEBAR: Key estático
                      currentRoute: widget.currentRoute,
                      onNavigate: _handleNavigation,
                      selectedDay:
                          _persistentSelectedDay, // 🔧 FIX: Usar datos persistentes
                      appointments:
                          _persistentAppointments, // 🔧 FIX: Usar datos persistentes
                      onDaySelected:
                          _handleDaySelected, // 🔧 FIX: Usar callback local
                    ),
                  );
                },
              ),

              // CONTENIDO PRINCIPAL
              Expanded(
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset.zero,
                      child: Opacity(
                        opacity: (1 + _slideAnimation.value).clamp(0.0, 1.0),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.005),
                                blurRadius: 20,
                                offset: const Offset(-5, 0),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(child: widget.child),

                              // QUICK ACTIONS PARA PANTALLAS CON SLIVERAPPBAR
                              if (hasOwnSliverAppBar)
                                Positioned(
                                  top: 70,
                                  right: 24,
                                  child: FloatingQuickActionsWidget(
                                    onSearchPressed: _openGlobalSearch,
                                    onNotificationsPressed:
                                        _openNotificationCenter,
                                    onSettingsPressed: () {},
                                  ),
                                ),

                              // APPBAR PARA PANTALLAS NORMALES
                              if (!hasOwnSliverAppBar)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: PremiumAppBar(
                                    currentRoute: widget.currentRoute,
                                    quickActionsRow: QuickActionsRow(
                                      onSearchPressed: _openGlobalSearch,
                                      onNotificationsPressed:
                                          _openNotificationCenter,
                                      onSettingsPressed: () {},
                                      notificationCount:
                                          _state.notificationCount,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // OVERLAYS
          if (_state.showSearchOverlay)
            GlobalSearchOverlay(
              onNavigate: (route) {
                _handleNavigation(route);
                _closeGlobalSearch();
              },
              onClose: _closeGlobalSearch,
            ),

          if (_state.showNotificationCenter)
            NotificationCenter(
              onClose: _closeNotificationCenter,
              onNavigate: (route) {
                _handleNavigation(route);
                _closeNotificationCenter();
              },
            ),
        ],
      ),
    );
  }
}
