// [main.dart] - INTEGRACIÓN AGENDA PREMIUM COMPLETA + RUTAS PÚBLICAS + ESTADO GLOBAL
// 📁 Ubicación: /lib/main.dart
// 🔧 FIX: CÓDIGO COMPLETO SIN ERRORES + OPTIMIZACIÓN DE RENDERS + ESTADO GLOBAL CALENDARIO

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/layout/layout_shell_premium.dart'
    as premium_layout;
import 'package:agenda_fisio_spa_kym/services/calendar_state/global_calendar_state.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';

// ✅ AGENDA PREMIUM IMPORTS
import 'package:agenda_fisio_spa_kym/screens/agenda/agenda_premium_screen.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/clients_premium_screen.dart';
// 🆕 NUEVO IMPORT ENTERPRISE
import 'package:agenda_fisio_spa_kym/screens/dev_tools/widget_laboratory_screen.dart';

// ✅ EXISTING SCREENS IMPORTS

import 'package:agenda_fisio_spa_kym/widgets/clients/wizard/client_wizard_modal.dart';
import 'package:agenda_fisio_spa_kym/screens/profesionales/professionals_screen.dart';
import 'package:agenda_fisio_spa_kym/screens/reminders/reminders_screen.dart';
import 'package:agenda_fisio_spa_kym/screens/admin/admin_tools_screen.dart';
import 'package:agenda_fisio_spa_kym/screens/empresas/empresas_screen.dart';
import 'package:agenda_fisio_spa_kym/screens/contratos/contratos_screen.dart';
import 'package:agenda_fisio_spa_kym/screens/ventas/ventas_screen.dart';
import 'package:agenda_fisio_spa_kym/screens/servicios/services_screen.dart';
import 'package:agenda_fisio_spa_kym/screens/campanas/campanas_screen.dart';
import 'package:agenda_fisio_spa_kym/screens/facturas/facturas_screen.dart';
import 'package:agenda_fisio_spa_kym/screens/cotizaciones/cotizaciones_screen.dart';
import 'package:agenda_fisio_spa_kym/screens/micrositio/micrositio_screen.dart';
import 'package:agenda_fisio_spa_kym/screens/kym_pulse/kym_pulse_dashboard.dart';
import 'package:agenda_fisio_spa_kym/screens/kym_pulse/eventos_screen.dart';
import 'package:agenda_fisio_spa_kym/widgets/encuestas/encuesta_creator_premium.dart';
import 'package:agenda_fisio_spa_kym/app/firebase_options.dart';
import 'package:agenda_fisio_spa_kym/screens/cost_control/cost_dashboard_screen.dart';

// 🆕 NUEVOS IMPORTS PARA RUTAS PÚBLICAS
import 'package:agenda_fisio_spa_kym/screens/public/public_booking_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('es_MX', null);

  runApp(const FisioSpaKYMPremiumApp());
}

class FisioSpaKYMPremiumApp extends StatelessWidget {
  const FisioSpaKYMPremiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Fisio Spa KYM',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: const Locale('es', 'MX'),
      supportedLocales: const [
        Locale('es', 'MX'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      home: const MainLayoutPremium(),
    );
  }
}

class MainLayoutPremium extends StatefulWidget {
  const MainLayoutPremium({super.key});

  @override
  State<MainLayoutPremium> createState() => _MainLayoutPremiumState();
}

class _MainLayoutPremiumState extends State<MainLayoutPremium>
    with TickerProviderStateMixin {
  late String _currentRoute;
  late AnimationController _routeController;
  late Animation<double> _routeAnimation;

  // 🔄 ESTADO GLOBAL DEL CALENDARIO
  late GlobalCalendarState _globalCalendarState;

  // 🔧 FIX: ESTADO GLOBAL PARA DATOS DEL CALENDARIO
  DateTime _globalSelectedDay = DateTime.now();
  Map<DateTime, List<dynamic>> _globalAppointments = {};

  // 🔧 FIX: CACHE PARA EVITAR REBUILDS INNECESARIOS
  Widget? _cachedPage;
  String? _cachedRoute;

  @override
  void initState() {
    super.initState();

    // 🔄 INICIALIZAR ESTADO GLOBAL DEL CALENDARIO
    _globalCalendarState = GlobalCalendarState();

    // 🔗 ESCUCHAR CAMBIOS EN ESTADO GLOBAL
    _globalCalendarState.addListener(_onGlobalCalendarStateChanged);

    // 🔧 CAPTURAR RUTA DESDE URL HASH
    _currentRoute = _getCurrentRouteFromUrl();

    print('🔗 RUTA INICIAL DETECTADA: $_currentRoute');

    _routeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _routeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _routeController,
      curve: Curves.easeInOut,
    ));

    _routeController.forward();
  }

  /// 🔄 LISTENER PARA CAMBIOS EN ESTADO GLOBAL
  void _onGlobalCalendarStateChanged() {
    if (mounted) {
      setState(() {
        _globalSelectedDay = _globalCalendarState.selectedDate;
        _globalAppointments = _globalCalendarState.appointments.map(
          (key, value) => MapEntry(key, value.cast<dynamic>()),
        );
      });
    }
  }

  // 🔧 MÉTODO PARA OBTENER RUTA ACTUAL DESDE URL
  String _getCurrentRouteFromUrl() {
    final uri = Uri.base;

    // En Flutter Web, la ruta está en el fragment (después del #)
    String route = uri.fragment;

    // Si no hay fragment, usar el path
    if (route.isEmpty) {
      route = uri.path;
    }

    // Limpiar la ruta
    if (route.isEmpty || route == '/') {
      print('🏠 RUTA VACÍA - Usando agenda premium por defecto');
      return '/agenda/premium';
    }

    // Asegurar que empiece con /
    if (!route.startsWith('/')) {
      route = '/$route';
    }

    print('🔍 URI completa: ${uri.toString()}');
    print('🔍 Fragment: ${uri.fragment}');
    print('🔍 Path: ${uri.path}');
    print('🔍 Ruta procesada: $route');

    // 🔧 PROTECCIÓN ESPECÍFICA PARA BOOKING
    if (route.startsWith('/booking')) {
      print('🔒 PROTEGIENDO RUTA BOOKING: $route');
    }

    return route;
  }

  @override
  void dispose() {
    _globalCalendarState.removeListener(_onGlobalCalendarStateChanged);
    _routeController.dispose();
    super.dispose();
  }

  void _navigateTo(String route) {
    print('🔄 NAVEGACIÓN SOLICITADA: $_currentRoute -> $route');
    if (route == _currentRoute) return;

    // 🔧 FIX: EVITAR MÚLTIPLES ANIMACIONES SIMULTÁNEAS
    if (_routeController.isAnimating) {
      print('⚠️ Navegación cancelada - animación en progreso');
      return;
    }

    // 🔧 FIX: LIMPIAR CACHE AL NAVEGAR
    _cachedPage = null;
    _cachedRoute = null;

    _routeController.reverse().then((_) {
      if (mounted) {
        print('✅ NAVEGACIÓN COMPLETADA: $route');
        setState(() => _currentRoute = route);
        _routeController.forward();
      }
    });
  }

  Widget _getPageByRoute(String route) {
    // 🔧 FIX: USAR CACHE PARA EVITAR REBUILDS INNECESARIOS
    if (_cachedRoute == route && _cachedPage != null) {
      return _cachedPage!;
    }

    print('🎯 RUTA RECIBIDA: $route');

    Widget page;
    switch (route) {
      // ✅ AGENDA PREMIUM - 🔧 CON CALLBACKS PARA SINCRONIZACIÓN
      case '/agenda/premium':
        page = AgendaPremiumScreen(
          onSelectedDayChanged: _handleSelectedDayChanged,
          onAppointmentsChanged: _handleAppointmentsChanged,
        );
        break;

      // ✅ CLIENTES
      case '/clientes':
        page = const ClientsPremiumScreen();
        break;
      case '/clientes/premium':
        page = const ClientsPremiumScreen();
        break;
      case '/clientes/nuevo':
        page = const ClientWizardModal();
        break;

      // ✅ PROFESIONALES
      case '/profesionales':
        page = const ProfessionalsScreen();
        break;
      case '/profesionales/nuevo':
        page = const ProfessionalsScreen(key: ValueKey('crear_nuevo'));
        break;

      // ✅ SERVICIOS
      case '/servicios':
        page = const ServicesScreen();
        break;

      // ✅ RECORDATORIOS
      case '/recordatorios':
        page = const RemindersScreen();
        break;

      // ✅ ADMIN
      case '/admin':
        page = const AdminToolsScreen();
        break;
      case '/admin/cost-control':
        page = const CostDashboardScreen();
        break;
      case '/dev/widgets':
        page = const WidgetLaboratoryScreen();
        break;

      // ✅ CORPORATIVO
      case '/empresas':
        page = const EmpresasScreen();
        break;
      case '/contratos':
        page = const ContratosScreen();
        break;
      case '/facturacion':
        page = const FacturasScreen();
        break;
      case '/micrositio/demo':
        page = const MicrositioScreen(empresaId: 'demo123');
        break;

      // ✅ KYM PULSE
      case '/kympulse':
        page = const KymPulseDashboard();
        break;
      case '/eventos':
        page = const EventosScreen();
        break;
      case '/encuestas':
        page = const EncuestaCreatorPremium();
        break;

      // ✅ VENTAS
      case '/ventas':
        page = const VentasScreen();
        break;
      case '/campanas':
        page = const CampanasScreen();
        break;
      case '/cotizaciones':
        page = const CotizacionesScreen();
        break;

      // ✅ REPORTES
      case '/reportes/pdf':
        page = const _ReportesPDFPlaceholder();
        break;
      case '/reportes/csv':
        page = const _ReportesCSVPlaceholder();
        break;

      // 🆕 NUEVAS RUTAS PÚBLICAS - MICROSITIO DE AGENDAMIENTO
      case '/booking':
        print('✅ Cargando PublicBookingScreen - Particular');
        page = const PublicBookingScreen(isParticular: true);
        break;

      case '/booking/particular':
        print('✅ Cargando PublicBookingScreen - Particular con params');
        page = PublicBookingScreen(
          isParticular: true,
          queryParams: Uri.base.queryParameters,
        );
        break;

      default:
        // 🔧 MANEJAR RUTAS DINÁMICAS DE EMPRESA
        if (route.startsWith('/booking/empresa/')) {
          final segments = route.split('/');
          if (segments.length >= 4) {
            final companyId = segments[3]; // /booking/empresa/[ID]
            print('✅ Cargando PublicBookingScreen - Empresa: $companyId');
            page = PublicBookingScreen(companyId: companyId);
            break;
          }
        }

        print('❌ Ruta no encontrada: $route');
        page = _NotFoundPage(route: route);
        break;
    }

    // 🔧 FIX: CACHE LA PÁGINA CREADA
    _cachedRoute = route;
    _cachedPage = page;

    return page;
  }

  /// 🎨 DETERMINAR SI MOSTRAR LAYOUT COMPLETO O SOLO CONTENIDO
  bool _shouldShowFullLayout(String route) {
    // No mostrar sidebar/header para rutas públicas de booking
    final isPublicRoute = route.startsWith('/booking');
    print('🎨 ¿Mostrar layout completo? ${!isPublicRoute} (ruta: $route)');
    return !isPublicRoute;
  }

  // 🔧 FIX: MÉTODOS HELPER PARA DATOS DEL CALENDARIO
  DateTime? _getSelectedDayForRoute(String route) {
    // Retornar fecha para rutas de agenda o mantener fecha global
    return _globalSelectedDay;
  }

  Map<DateTime, List<dynamic>>? _getAppointmentsForRoute(String route) {
    // Retornar appointments para rutas de agenda o mantener datos globales
    return _globalAppointments;
  }

  void _handleDaySelected(DateTime selectedDay) {
    // 🎯 OPTIMIZACIÓN QUIRÚRGICA: Verificar cambios antes de setState
    final currentNormalized = DateTime(_globalSelectedDay.year,
        _globalSelectedDay.month, _globalSelectedDay.day);
    final newNormalized =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    print('📅 Día seleccionado desde main.dart: $selectedDay');

    if (currentNormalized.millisecondsSinceEpoch ==
        newNormalized.millisecondsSinceEpoch) {
      return; // No hacer nada si es exactamente la misma fecha
    }

    // 🔄 ACTUALIZAR ESTADO GLOBAL PRIMERO
    _globalCalendarState.setSelectedDate(selectedDay, source: 'MainLayout');

    // 🔧 FIX: setState necesario para propagación a AgendaPremiumScreen
    setState(() {
      _globalSelectedDay = selectedDay;
    });

    // Si estamos en una ruta de agenda, navegar a agenda premium
    if (!_currentRoute.startsWith('/agenda')) {
      _navigateTo('/agenda/premium');
    }
  }

  // 🔧 FIX: CALLBACKS PARA SINCRONIZACIÓN CON AGENDA PREMIUM - OPTIMIZADOS
  void _handleSelectedDayChanged(DateTime selectedDay) {
    // 🎯 OPTIMIZACIÓN QUIRÚRGICA: Normalizar fechas para comparación correcta
    final currentNormalized = DateTime(_globalSelectedDay.year,
        _globalSelectedDay.month, _globalSelectedDay.day);
    final newNormalized =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    if (currentNormalized.millisecondsSinceEpoch ==
        newNormalized.millisecondsSinceEpoch) {
      return; // No hacer nada si es exactamente la misma fecha
    }

    print('📅 Día actualizado desde AgendaPremium: $selectedDay');

    // 🔄 ACTUALIZAR ESTADO GLOBAL PRIMERO
    _globalCalendarState.setSelectedDate(selectedDay,
        source: 'AgendaPremiumScreen');

    // 🔧 FIX: setState necesario para mini calendario
    setState(() {
      _globalSelectedDay = selectedDay;
    });
  }

  void _handleAppointmentsChanged(Map<DateTime, List<dynamic>> appointments) {
    // 🎯 OPTIMIZACIÓN QUIRÚRGICA: Verificación profunda de cambios
    if (_globalAppointments.length == appointments.length) {
      // Verificar si realmente cambió el contenido
      bool hasRealChanges = false;
      for (final entry in appointments.entries) {
        final existing = _globalAppointments[entry.key];
        if (existing == null || existing.length != entry.value.length) {
          hasRealChanges = true;
          break;
        }
      }
      if (!hasRealChanges) {
        return; // No hacer nada si no hay cambios reales
      }
    }

    print(
        '📊 Appointments actualizados desde AgendaPremium: ${appointments.length} días');

    // 🔄 ACTUALIZAR ESTADO GLOBAL PRIMERO
    final convertedAppointments = <DateTime, List<AppointmentModel>>{};
    appointments.forEach((date, appointmentList) {
      final convertedList = <AppointmentModel>[];
      for (final appointment in appointmentList) {
        if (appointment is AppointmentModel) {
          convertedList.add(appointment);
        }
      }
      if (convertedList.isNotEmpty) {
        convertedAppointments[date] = convertedList;
      }
    });

    _globalCalendarState.setAppointments(convertedAppointments,
        source: 'AgendaPremiumScreen');

    // 🔧 FIX: setState necesario para mini calendario
    setState(() {
      _globalAppointments = appointments;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ BUILDING con ruta: $_currentRoute');

    // 🎯 Para rutas públicas, mostrar solo el contenido sin layout
    if (!_shouldShowFullLayout(_currentRoute)) {
      print('📱 RENDERIZANDO SIN LAYOUT (público)');
      return AnimatedBuilder(
        animation: _routeAnimation,
        builder: (context, child) {
          // 🔧 FIX: SOLO LOGGEAR SI LA ANIMACIÓN ESTÁ ACTIVA
          if (_routeController.isAnimating) {
            print('🎬 ANIMANDO RUTA PÚBLICA: $_currentRoute');
          }
          return FadeTransition(
            opacity: _routeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(_routeAnimation),
              child: _getPageByRoute(_currentRoute),
            ),
          );
        },
      );
    }

    // 🔧 FIX: TODAS LAS RUTAS DEL CRM USAN EL MISMO LAYOUT SHELL PREMIUM
    // Eliminado caso especial para /agenda/premium
    print('🏢 RENDERIZANDO CON LAYOUT COMPLETO (CRM) - Ruta: $_currentRoute');
    return premium_layout.LayoutShellPremium(
      currentRoute: _currentRoute,
      onNavigate: _navigateTo,
      // 🔧 FIX: SIEMPRE PASAR DATOS DEL CALENDARIO PARA EL MINI CALENDARIO
      selectedDay: _getSelectedDayForRoute(_currentRoute),
      appointments: _getAppointmentsForRoute(_currentRoute),
      onDaySelected: _handleDaySelected,
      child: AnimatedBuilder(
        animation: _routeAnimation,
        builder: (context, child) {
          // 🔧 FIX: SOLO LOGGEAR SI LA ANIMACIÓN ESTÁ ACTIVA
          if (_routeController.isAnimating) {
            print('🎬 ANIMANDO RUTA CRM: $_currentRoute');
          }
          return FadeTransition(
            opacity: _routeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(_routeAnimation),
              child: _getPageByRoute(_currentRoute),
            ),
          );
        },
      ),
    );
  }
}

// ========================================================================
// 🎯 PLACEHOLDERS EXISTENTES (MANTENER)
// ========================================================================

class _ReportesPDFPlaceholder extends StatelessWidget {
  const _ReportesPDFPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.redAccent],
                ),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Reportes PDF',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Generación automática de reportes en PDF',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportesCSVPlaceholder extends StatelessWidget {
  const _ReportesCSVPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kAccentGreen, kAccentBlue],
                ),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: kAccentGreen.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.table_chart,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Exportación CSV',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: kAccentGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Exporta datos a hojas de cálculo',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  final String route;

  const _NotFoundPage({required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.grey.shade400,
                size: 60,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '404 - Página no encontrada',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'La ruta "$route" no existe',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/agenda/premium');
              },
              icon: const Icon(Icons.home),
              label: const Text('Ir a Agenda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
