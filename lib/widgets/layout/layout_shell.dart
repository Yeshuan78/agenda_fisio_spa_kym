// [Archivo: lib/widgets/layout/layout_shell_premium.dart]
// 🏗️ LAYOUT PREMIUM CORREGIDO - SIN OVERFLOW NI ESPACIOS

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/custom_sidebar_ultra_premium.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class LayoutShellPremium extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  final Function(String) onNavigate;

  const LayoutShellPremium({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  State<LayoutShellPremium> createState() => _LayoutShellPremiumState();
}

class _LayoutShellPremiumState extends State<LayoutShellPremium>
    with TickerProviderStateMixin {
  late AnimationController _layoutController;
  late Animation<double> _slideAnimation;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _simulateLoading();
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
      setState(() => _isLoading = false);
      _layoutController.forward();
    }
  }

  @override
  void dispose() {
    _layoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor:
          Colors.white, // ✅ CAMBIO: Fondo blanco en lugar de kBackgroundColor
      body: Row(
        children: [
          // ✅ SIDEBAR SIN ESPACIO
          CustomSidebarUltraPremium(
            currentRoute: widget.currentRoute,
            onNavigate: widget.onNavigate,
          ),

          // ✅ CONTENIDO PRINCIPAL - SIN GAPS
          Expanded(
            child: Column(
              children: [
                // ✅ AppBar Premium
                _buildPremiumAppBar(),

                // ✅ Contenido Principal DIRECTO
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color:
                        kBackgroundColor, // ✅ Solo el contenido tiene el fondo gris
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              kBrandPurple.withValues(alpha: 0.05),
              kAccentBlue.withValues(alpha: 0.02),
              Colors.white,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PremiumLoadingLogo(),
              SizedBox(height: 32),
              Text(
                'Cargando Fisio Spa KYM',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'CRM Premium Enterprise',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 48),
              _PremiumProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumAppBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: kBorderColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        // ✅ SOMBRA MÍNIMA PARA NO CREAR GAPS
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: _buildBreadcrumb(),
            ),
            Row(
              children: [
                _buildQuickAction(
                  Icons.notifications_outlined,
                  'Notificaciones',
                  () {},
                  badge: 3,
                ),
                const SizedBox(width: 16),
                _buildQuickAction(
                  Icons.search,
                  'Búsqueda global',
                  () {},
                ),
                const SizedBox(width: 16),
                _buildQuickAction(
                  Icons.settings_outlined,
                  'Configuración',
                  () {},
                ),
                const SizedBox(width: 24),
                _buildUserAvatar(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    final routeParts =
        widget.currentRoute.split('/').where((p) => p.isNotEmpty).toList();

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kBrandPurple, kAccentBlue],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getRouteIcon(widget.currentRoute),
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getRouteTitle(widget.currentRoute),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (routeParts.length > 1) ...[
                const SizedBox(height: 2),
                Text(
                  routeParts.map(_capitalizeFirst).join(' › '),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String tooltip,
    VoidCallback onTap, {
    int? badge,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kBrandPurple.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: kBrandPurple.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    color: kBrandPurple,
                    size: 20,
                  ),
                ),
                if (badge != null && badge > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                        ),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          badge > 9 ? '9+' : '$badge',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kBrandPurple, kAccentBlue],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  IconData _getRouteIcon(String route) {
    switch (route) {
      case '/agenda/semanal':
      case '/agenda/diaria':
        return Icons.calendar_today;
      case '/clientes':
      case '/clientes/nuevo':
        return Icons.people;
      case '/profesionales':
      case '/profesionales/nuevo':
        return Icons.medical_services;
      case '/servicios':
        return Icons.spa;
      case '/empresas':
        return Icons.business;
      case '/kympulse':
        return Icons.analytics;
      case '/eventos':
        return Icons.event;
      case '/encuestas':
        return Icons.quiz;
      case '/admin':
        return Icons.settings;
      default:
        return Icons.dashboard;
    }
  }

  String _getRouteTitle(String route) {
    switch (route) {
      case '/agenda/semanal':
        return 'Agenda Semanal';
      case '/agenda/diaria':
        return 'Agenda Diaria';
      case '/clientes':
        return 'Gestión de Clientes';
      case '/clientes/nuevo':
        return 'Nuevo Cliente';
      case '/profesionales':
        return 'Profesionales';
      case '/profesionales/nuevo':
        return 'Nuevo Profesional';
      case '/servicios':
        return 'Servicios';
      case '/empresas':
        return 'Empresas Corporativas';
      case '/kympulse':
        return 'KYM Pulse Dashboard';
      case '/eventos':
        return 'Eventos Corporativos';
      case '/encuestas':
        return 'Creator de Encuestas';
      case '/admin':
        return 'Configuración del Sistema';
      default:
        return 'Dashboard';
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}

/// 🔄 LOGO DE CARGA PREMIUM
class _PremiumLoadingLogo extends StatefulWidget {
  const _PremiumLoadingLogo();

  @override
  State<_PremiumLoadingLogo> createState() => _PremiumLoadingLogoState();
}

class _PremiumLoadingLogoState extends State<_PremiumLoadingLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _glowController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _rotationController.repeat();
    _scaleController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationController,
        _scaleController,
        _glowController,
      ]),
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    kBrandPurple,
                    kAccentBlue,
                    kAccentGreen,
                    kBrandPurple,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: kBrandPurple.withOpacity(_glowAnimation.value * 0.8),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                  BoxShadow(
                    color: kAccentBlue.withOpacity(_glowAnimation.value * 0.6),
                    blurRadius: 40,
                    spreadRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: const Icon(
                Icons.spa,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 📊 INDICADOR DE PROGRESO PREMIUM
class _PremiumProgressIndicator extends StatefulWidget {
  const _PremiumProgressIndicator();

  @override
  State<_PremiumProgressIndicator> createState() =>
      _PremiumProgressIndicatorState();
}

class _PremiumProgressIndicatorState extends State<_PremiumProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kBrandPurple, kAccentBlue, kAccentGreen],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: kBrandPurple.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final percentage = (_progressAnimation.value * 100).toInt();
              return Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kBrandPurple,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
