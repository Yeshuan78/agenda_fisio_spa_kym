// [custom_sidebar_ultra_premium.dart]
// 📁 Ubicación: /lib/widgets/navigation/custom_sidebar_ultra_premium.dart (UPDATED)
// 🚀 SIDEBAR PREMIUM CON SEARCH GLOBAL INTEGRADO + ESTADO GLOBAL CALENDARIO

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_option.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_firestore_service.dart';
import 'package:agenda_fisio_spa_kym/widgets/search/global_search_overlay.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/agenda_mini_calendar.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/mixins/calendar_state_listener.dart';
import 'package:agenda_fisio_spa_kym/services/calendar_state/calendar_state_models.dart';

class CustomSidebarUltraPremium extends StatefulWidget {
  final String currentRoute;
  final Function(String) onNavigate;
  final Function(bool)? onCompactModeChanged;
  final DateTime? selectedDay;
  final Map<DateTime, List<dynamic>>? appointments;
  final Function(DateTime)? onDaySelected;

  const CustomSidebarUltraPremium({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    this.onCompactModeChanged,
    this.selectedDay,
    this.appointments,
    this.onDaySelected,
  });

  @override
  State<CustomSidebarUltraPremium> createState() =>
      _CustomSidebarUltraPremiumState();
}

class _CustomSidebarUltraPremiumState extends State<CustomSidebarUltraPremium>
    with TickerProviderStateMixin, CalendarStateListener {
  // ✅ ESTADO DE LA APP (SIMPLIFICADO - SOLO 2 VISTAS)
  String _vista = 'estándar';
  List<String> _favoritos = [];
  Map<String, bool> _estadoGrupos = {};

  // ✅ ESTADO UI PREMIUM
  bool _isCompactMode = false;
  int? _hoveredIndex;
  bool _showSearchOverlay = false;

  // ✅ CONTROLLERS DE ANIMACIÓN
  late AnimationController _compactController;
  late AnimationController _pulseController;
  late AnimationController _logoController;
  late AnimationController _searchButtonController;

  // ✅ ANIMACIONES
  late Animation<double> _compactAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _logoAnimation;
  late Animation<double> _searchButtonPulse;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _cargarPreferencias();

    // 🔄 SINCRONIZAR CON ESTADO GLOBAL AL INICIALIZAR
    _syncFromGlobalState();
  }

  /// 🔄 SINCRONIZACIÓN CON ESTADO GLOBAL
  @override
  void onDateChanged(CalendarEventDateChanged event) {
    if (event.source != 'CustomSidebarUltraPremium') {
      // Solo actualizar UI si el cambio viene de otro componente
      if (mounted) {
        setState(() {
          // La fecha ya está sincronizada en calendarState.selectedDate
        });
      }
    }
  }

  @override
  void onAppointmentsChanged(CalendarEventAppointmentsChanged event) {
    if (event.source != 'CustomSidebarUltraPremium') {
      // Actualizar appointments en el mini calendario
      if (mounted) {
        setState(() {
          // Los appointments ya están sincronizados en calendarState.appointments
        });
      }
    }
  }

  void _syncFromGlobalState() {
    // Sincronizar appointments del estado global si están disponibles
    if (widget.appointments != null) {
      final convertedAppointments = _convertAppointments(widget.appointments!);
      calendarState.setAppointments(convertedAppointments,
          source: 'CustomSidebarUltraPremium');
    }

    // Sincronizar fecha seleccionada
    if (widget.selectedDay != null) {
      calendarState.setSelectedDate(widget.selectedDay!,
          source: 'CustomSidebarUltraPremium');
    }
  }

  void _initAnimations() {
    _compactController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _compactAnimation = CurvedAnimation(
      parent: _compactController,
      curve: Curves.easeInOutCubic,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    _pulseController.repeat(reverse: true);

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoController.forward();

    _searchButtonController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _searchButtonPulse = CurvedAnimation(
      parent: _searchButtonController,
      curve: Curves.easeInOut,
    );
    _searchButtonController.repeat(reverse: true);
  }

  Future<void> _cargarPreferencias() async {
    try {
      final prefs = await SidebarFirestoreService.cargarPreferencias();
      setState(() {
        _vista = prefs['vista'] ?? 'estándar';
        _favoritos = List<String>.from(prefs['favoritos'] ?? []);
        _estadoGrupos = Map<String, bool>.from(prefs['estadoGrupos'] ?? {});
      });
    } catch (e) {
      debugPrint('Error cargando preferencias: $e');
    }
  }

  void _toggleCompactMode() {
    setState(() {
      _isCompactMode = !_isCompactMode;
    });

    if (_isCompactMode) {
      _compactController.forward();
    } else {
      _compactController.reverse();
    }

    widget.onCompactModeChanged?.call(_isCompactMode);
    HapticFeedback.mediumImpact();
  }

  void _cambiarVista(String nuevaVista) {
    setState(() => _vista = nuevaVista);
    SidebarFirestoreService.guardarVista(nuevaVista);
    HapticFeedback.selectionClick();
  }

  void _toggleFavorito(String route) {
    final nuevos = [..._favoritos];
    if (nuevos.contains(route)) {
      nuevos.remove(route);
    } else {
      nuevos.add(route);
    }

    setState(() => _favoritos = nuevos);
    SidebarFirestoreService.guardarFavoritos(nuevos);
    HapticFeedback.lightImpact();
  }

  void _toggleGrupo(String grupo) {
    final nuevoEstado = !(_estadoGrupos[grupo] ?? false);
    setState(() {
      _estadoGrupos[grupo] = nuevoEstado;
    });
    SidebarFirestoreService.guardarEstadoGrupo(grupo, nuevoEstado);
    HapticFeedback.selectionClick();
  }

  void _openGlobalSearch() {
    setState(() => _showSearchOverlay = true);
    HapticFeedback.lightImpact();
  }

  void _closeGlobalSearch() {
    setState(() => _showSearchOverlay = false);
  }

  List<SidebarOption> _getOpcionesFiltradas() {
    List<SidebarOption> opciones;

    switch (_vista) {
      case 'favoritos':
        opciones = sidebarOptions
            .where((opt) => _favoritos.contains(opt.route))
            .toList();
        break;
      default:
        opciones = sidebarOptions;
    }

    return opciones;
  }

  @override
  void dispose() {
    _compactController.dispose();
    _pulseController.dispose();
    _logoController.dispose();
    _searchButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ SIDEBAR PRINCIPAL
        AnimatedBuilder(
          animation: _compactAnimation,
          builder: (context, child) {
            final width = _isCompactMode
                ? Tween<double>(begin: 280.0, end: 72.0)
                    .animate(_compactAnimation)
                    .value
                : 280.0;

            return Container(
              width: width,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    kBrandPurpleLight.withValues(alpha: 0.002),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: kBrandPurple.withValues(alpha: 0.006),
                    offset: const Offset(1, 0),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildPremiumHeader(),
                      if (!_isCompactMode) _buildSearchSection(),
                      if (!_isCompactMode) _buildVistaSelector(),
                      // ✅ MINI CALENDARIO

                      Expanded(
                        child: _buildMainContent(),
                      ),
                      _buildPremiumFooter(),
                    ],
                  ),
                  if (_isCompactMode)
                    Positioned(
                      top: 90,
                      right: -15,
                      child: _buildExpandButton(),
                    ),
                ],
              ),
            );
          },
        ),

        // ✅ SEARCH OVERLAY GLOBAL
        if (_showSearchOverlay)
          GlobalSearchOverlay(
            onNavigate: (route) {
              widget.onNavigate(route);
              _closeGlobalSearch();
            },
            onClose: _closeGlobalSearch,
          ),
      ],
    );
  }

  Widget _buildPremiumHeader() {
    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) {
        return Container(
          height: _isCompactMode ? 60 : 80,
          width: double.infinity,
          padding: EdgeInsets.all(_isCompactMode ? 12 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kBrandPurple.withValues(alpha: 0.005),
                kAccentBlue.withValues(alpha: 0.002),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: kBorderColor.withValues(alpha: 0.01),
                width: 1,
              ),
            ),
          ),
          child: _isCompactMode
              ? Center(
                  child: _buildCompactLogo(),
                )
              : _buildFullHeader(),
        );
      },
    );
  }

  Widget _buildCompactLogo() {
    return Transform.scale(
      scale: _logoAnimation.value,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: kBrandPurple.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              'assets/images/Mariposa.png',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kBrandPurple, kAccentBlue],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Icon(
                    Icons.spa,
                    color: Colors.white,
                    size: 14,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullHeader() {
    return Row(
      children: [
        Transform.scale(
          scale: _logoAnimation.value,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: kBrandPurple.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/images/Mariposa.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kBrandPurple, kAccentBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.spa,
                        color: Colors.white,
                        size: 16,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Fisio Spa KYM',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
              Text(
                'CRM Premium',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _toggleCompactMode,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.keyboard_arrow_left,
                color: kBrandPurple.withValues(alpha: 0.07),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandButton() {
    return Material(
      elevation: 6,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: _toggleCompactMode,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kBrandPurple, kAccentBlue],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: kBrandPurple.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.keyboard_double_arrow_right,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ SEARCH GLOBAL BUTTON PREMIUM
          AnimatedBuilder(
            animation: _searchButtonPulse,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.98 + (_searchButtonPulse.value * 0.04),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _openGlobalSearch,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kBrandPurple.withValues(alpha: 0.008),
                            kAccentBlue.withValues(alpha: 0.004),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: kBrandPurple.withValues(alpha: 0.02),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kBrandPurple.withValues(alpha: 0.01),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [kBrandPurple, kAccentBlue],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: kBrandPurple.withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Búsqueda Global...',
                              style: TextStyle(
                                fontSize: 14,
                                color: kBrandPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kBrandPurple.withValues(alpha: 0.01),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: kBrandPurple.withValues(alpha: 0.03),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              '⌘K',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: kBrandPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuickActionMini(
    IconData icon,
    String label,
    VoidCallback onTap,
    Color color,
  ) {
    return Tooltip(
      message: 'Crear $label',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.008),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.02),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.08)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVistaSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: kBrandPurpleLight.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: kBorderColor.withValues(alpha: 0.03),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildVistaTab('estándar', Icons.view_sidebar, 'Estándar'),
            _buildVistaTab('favoritos', Icons.favorite, 'Favoritos'),
            _buildVistaTab('calendario', Icons.calendar_today, 'Calendario'),
          ],
        ),
      ),
    );
  }

  Widget _buildVistaTab(String vista, IconData icon, String label) {
    final isActive = _vista == vista;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _cambiarVista(vista),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: kBrandPurple.withValues(alpha: 0.015),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isActive ? kBrandPurple : Colors.grey.shade600,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? kBrandPurple : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_vista == 'calendario') {
      return _buildCalendarioContent();
    }

    final opciones = _getOpcionesFiltradas();

    if (opciones.isEmpty) {
      return _buildEmptyState();
    }

    return _buildGroupContent(opciones);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: kBrandPurple.withValues(alpha: 0.01),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.favorite_border,
              size: 30,
              color: kBrandPurple.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isCompactMode ? '⭐' : 'Sin favoritos',
            style: TextStyle(
              fontSize: _isCompactMode ? 20 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          if (!_isCompactMode) ...[
            const SizedBox(height: 8),
            Text(
              'Marca módulos como favoritos',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupContent(List<SidebarOption> opciones) {
    final grupos = opciones.map((e) => e.group).toSet().toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: _isCompactMode ? 4 : 16,
        vertical: 8,
      ),
      child: Column(
        children: grupos.map((grupo) {
          final opcionesGrupo =
              opciones.where((opt) => opt.group == grupo).toList();
          final isExpanded = _estadoGrupos[grupo] ?? false;

          return _buildGrupoSection(grupo, opcionesGrupo, isExpanded);
        }).toList(),
      ),
    );
  }

  Widget _buildGrupoSection(
    String grupo,
    List<SidebarOption> opciones,
    bool isExpanded,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kBorderColor.withValues(alpha: 0.01),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.002),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              onTap: () => _toggleGrupo(grupo),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(_isCompactMode ? 8 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      kBrandPurple.withValues(alpha: 0.005),
                      kAccentBlue.withValues(alpha: 0.002),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: _isCompactMode ? 20 : 24,
                      height: _isCompactMode ? 20 : 24,
                      decoration: BoxDecoration(
                        // ✅ GRADIENTE VIVO EN ICONOS DE GRUPO (MODO COMPACTO)
                        gradient: const LinearGradient(
                          colors: [kBrandPurple, kAccentBlue],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: kBrandPurple.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getGrupoIcon(grupo),
                        size: _isCompactMode ? 12 : 14,
                        color: Colors.white,
                      ),
                    ),
                    if (!_isCompactMode) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          grupo.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: kBrandPurple,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ] else
                      const Spacer(),
                    if (opciones.isNotEmpty && !_isCompactMode) ...[
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.8 + (_pulseAnimation.value * 0.2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: kAccentGreen,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: kAccentGreen.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${opciones.length}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (!_isCompactMode)
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: kBrandPurple.withValues(alpha: 0.07),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            child: (isExpanded || _isCompactMode)
                ? Column(
                    children: opciones.asMap().entries.map((entry) {
                      final index = entry.key;
                      final opcion = entry.value;
                      return _buildOpcionItem(opcion, index);
                    }).toList(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcionItem(SidebarOption opcion, int index) {
    final isActive = widget.currentRoute == opcion.route;
    final isFavorito = _favoritos.contains(opcion.route);
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hoveredIndex = index);
        HapticFeedback.selectionClick();
      },
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: _isCompactMode ? 4 : 8,
          vertical: 2,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: _isCompactMode
              ? Tooltip(
                  message: opcion.label,
                  preferBelow: false,
                  margin: const EdgeInsets.only(left: 80),
                  decoration: BoxDecoration(
                    color: kDarkSidebar,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      widget.onNavigate(opcion.route);
                      HapticFeedback.lightImpact();
                    },
                    child: _buildCompactItem(opcion, isActive, isHovered),
                  ),
                )
              : InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    widget.onNavigate(opcion.route);
                    HapticFeedback.lightImpact();
                  },
                  child:
                      _buildFullItem(opcion, isActive, isHovered, isFavorito),
                ),
        ),
      ),
    );
  }

  Widget _buildCompactItem(
      SidebarOption opcion, bool isActive, bool isHovered) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [
                  kBrandPurple.withValues(alpha: 0.01),
                  kAccentBlue.withValues(alpha: 0.005),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isActive
            ? null
            : isHovered
                ? kBrandPurpleLight.withValues(alpha: 0.01)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive
              ? kBrandPurple.withValues(alpha: 0.03)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: kBrandPurple.withValues(alpha: 0.015),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            // ✅ GRADIENTES VIVOS EN MODO COMPACTO
            gradient: isActive
                ? const LinearGradient(
                    colors: [kBrandPurple, kAccentBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      kBrandPurple.withValues(alpha: 0.07),
                      kAccentBlue.withValues(alpha: 0.07),
                    ],
                  ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: kBrandPurple.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            opcion.icon,
            size: 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFullItem(
      SidebarOption opcion, bool isActive, bool isHovered, bool isFavorito) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [
                  kBrandPurple.withValues(alpha: 0.01),
                  kAccentBlue.withValues(alpha: 0.005),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isActive
            ? null
            : isHovered
                ? kBrandPurpleLight.withValues(alpha: 0.01)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive
              ? kBrandPurple.withValues(alpha: 0.03)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: kBrandPurple.withValues(alpha: 0.015),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [kBrandPurple, kAccentBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.grey.shade400,
                        Colors.grey.shade300,
                      ],
                    ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: kBrandPurple.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              opcion.icon,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              opcion.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? kBrandPurple : Colors.black87,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (opcion.badge != null && opcion.badge! > 0) ...[
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.9 + (_pulseAnimation.value * 0.1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          '${opcion.badge}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
              if (_vista == 'estándar') ...[
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => _toggleFavorito(opcion.route),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: AnimatedScale(
                        scale: isFavorito ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: Icon(
                          isFavorito ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFavorito
                              ? Colors.red.shade400
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFooter() {
    if (_isCompactMode) {
      return Container(
        height: 60,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                // ✅ GRADIENTE VIVO EN FOOTER COMPACTO
                gradient: const LinearGradient(
                  colors: [kAccentGreen, kAccentBlue],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            kBrandPurple.withValues(alpha: 0.002),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: kBorderColor.withValues(alpha: 0.01),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFooterStat(
                  'Módulos', '${sidebarOptions.length}', Icons.apps),
              _buildFooterStat(
                  'Favoritos', '${_favoritos.length}', Icons.favorite),
              _buildFooterStat('Activos', '1', Icons.circle,
                  color: kAccentGreen),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'KYM CRM v2.1.0 Premium',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterStat(String label, String value, IconData icon,
      {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color ?? kBrandPurple.withValues(alpha: 0.07),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color ?? kBrandPurple,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  /// 🆕 NUEVA VISTA CALENDARIO COMPLETA
  Widget _buildCalendarioContent() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: AgendaMiniCalendar(
        selectedDate: calendarState.selectedDate, // 🔄 USAR ESTADO GLOBAL
        focusedMonth: calendarState.selectedDate, // 🔄 USAR ESTADO GLOBAL
        appointments: calendarState.appointments, // 🔄 USAR ESTADO GLOBAL
        onDateSelected: (date) {
          // 🔄 ACTUALIZAR ESTADO GLOBAL
          updateSelectedDate(date);
          // También llamar callback del widget padre para compatibilidad
          widget.onDaySelected?.call(date);
        },
        onNavigate: widget.onNavigate,
        onAppointmentCreate: (date, resourceId) {
          // Crear nueva cita en fecha seleccionada
          widget.onNavigate('/agenda/premium');
        },
        compactMode: false,
        width: double.infinity,
        height: double.infinity,
        showAppointmentIndicators: true,
      ),
    );
  }

  IconData _getGrupoIcon(String grupo) {
    switch (grupo.toLowerCase()) {
      case 'agenda':
        return Icons.calendar_today;
      case 'clientes':
        return Icons.people;
      case 'corporativo':
        return Icons.business;
      case 'profesionales':
        return Icons.medical_services;
      case 'servicios':
        return Icons.spa;
      case 'ventas':
        return Icons.trending_up;
      case 'reportes':
        return Icons.analytics;
      case 'recordatorios':
        return Icons.notifications;
      case 'admin':
        return Icons.settings;
      case 'kym pulse':
        return Icons.analytics;
      default:
        return Icons.folder;
    }
  }

  /// 🔄 Convertir appointments del estado principal al formato del mini calendario
  Map<DateTime, List<AppointmentModel>> _convertAppointments(
      Map<DateTime, List<dynamic>> appointments) {
    final converted = <DateTime, List<AppointmentModel>>{};

    appointments.forEach((date, appointmentList) {
      final convertedList = <AppointmentModel>[];
      for (final appointment in appointmentList) {
        if (appointment is AppointmentModel) {
          convertedList.add(appointment);
        }
      }
      if (convertedList.isNotEmpty) {
        converted[date] = convertedList;
      }
    });

    return converted;
  }
}
