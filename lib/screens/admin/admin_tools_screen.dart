// [admin_tools_screen.dart] - CON SISTEMA MANDALA MOLECULAR INTEGRADO
// 📁 Ubicación: /lib/screens/admin/admin_tools_screen.dart
// 🎯 OBJETIVO: Screen con Mandala Molecular ⚗️ + herramientas administrativas

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/dev_tools/encuesta_editor_widget.dart';
import 'package:http/http.dart' as http;

class AdminToolsScreen extends StatefulWidget {
  const AdminToolsScreen({super.key});

  @override
  State<AdminToolsScreen> createState() => _AdminToolsScreenState();
}

class _AdminToolsScreenState extends State<AdminToolsScreen>
    with TickerProviderStateMixin {
  // ✅ CONTROLADORES DE ANIMACIÓN
  late AnimationController _contentAnimationController;
  late AnimationController _cardsAnimationController;
  late Animation<double> _contentAnimation;
  late Animation<double> _cardsAnimation;

  // ✅ ESTADO DE LA APLICACIÓN
  bool _isInitialized = false;
  final Map<String, bool> _executionStatus = {};
  int _totalOperations = 0;
  int _successfulOperations = 0;
  int _failedOperations = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _contentAnimation = CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    );

    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cardsAnimation = CurvedAnimation(
      parent: _cardsAnimationController,
      curve: Curves.easeOutQuart,
    );
  }

  void _initializeData() {
    setState(() {
      _isInitialized = true;
    });

    // Iniciar animaciones en secuencia
    _contentAnimationController.forward().then((_) {
      _cardsAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _contentAnimationController.dispose();
    _cardsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isInitialized) {
      return _buildLoadingScreen();
    }

    // ⚗️ USANDO CUSTOMSCROLLVIEW CON MANDALA MOLECULAR
    return CustomScrollView(
      slivers: [
        // 🌀 MANDALA APPBAR - MOLECULAR PARA ADMIN
        MandalaTheme.buildMandalaAppBar(
          moduleName: 'admin',
          title: 'Panel de Administración',
          subtitle: 'Herramientas avanzadas y control del sistema',
          icon: Icons.admin_panel_settings_outlined,
          expandedHeight: 200,
          pinned: true,
          floating: false,
          actions: [
            IconButton(
              onPressed: () => _refreshStats(),
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Actualizar estadísticas',
            ),
            _buildMandalaHeaderStats(),
          ],
        ),

        _buildDashboardSliver(),
        _buildMaintenanceToolsSliver(),
        _buildMicrositioToolsSliver(),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kBrandPurple),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Cargando herramientas administrativas...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ⚗️ ESTADÍSTICAS PARA EL HEADER MANDALA
  Widget _buildMandalaHeaderStats() {
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
          const Icon(
            Icons.build_circle,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '$_successfulOperations',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '$_failedOperations',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSliver() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _contentAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - _contentAnimation.value)),
            child: Opacity(
              opacity: _contentAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(20),
                child: _buildSystemDashboard(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSystemDashboard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            kBrandPurple.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBrandPurple.withValues(alpha: 0.2)),
        boxShadow: kSombraCardElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kBrandPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.dashboard_outlined,
                  color: kBrandPurple,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Panel de Control del Sistema',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kBrandPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monitoreo de operaciones administrativas y estado del sistema',
                      style: TextStyle(
                        fontSize: 14,
                        color: kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Operaciones Totales',
                  _totalOperations.toString(),
                  Icons.all_inclusive,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Exitosas',
                  _successfulOperations.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Fallidas',
                  _failedOperations.toString(),
                  Icons.error,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Estado Sistema',
                  'Operativo',
                  Icons.health_and_safety,
                  Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: kSombraCard,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: kTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceToolsSliver() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _cardsAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 40 * (1 - _cardsAnimation.value)),
            child: Opacity(
              opacity: _cardsAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildMaintenanceSection(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMaintenanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Tareas de Mantenimiento del Sistema',
          'Operaciones críticas para la integridad de datos',
          Icons.build_outlined,
          kBrandPurple,
        ),
        const SizedBox(height: 20),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildMaintenanceCard(
                  'Migrar Profesionales',
                  'Migra profesionales con servicios y especialidades',
                  Icons.people_outline,
                  Colors.deepPurple,
                  () => _ejecutarFuncion(
                    context,
                    'https://us-central1-fisiospakym-afff6.cloudfunctions.net/migrarProfesionales',
                    'Migración de profesionales',
                    'migrar_profesionales',
                  ),
                  'migrar_profesionales',
                ),
                const SizedBox(height: 16),
                _buildMaintenanceCard(
                  'Vincular Servicios',
                  'Vincula servicios existentes con profesionales',
                  Icons.link,
                  Colors.teal,
                  () => _ejecutarFuncion(
                    context,
                    'https://us-central1-fisiospakym-afff6.cloudfunctions.net/vincularServiciosConProfesionales',
                    'Vinculación de servicios',
                    'vincular_servicios',
                  ),
                  'vincular_servicios',
                ),
                const SizedBox(height: 16),
                _buildMaintenanceCard(
                  'Reset de Relaciones',
                  'Elimina arrays de professionalIds en servicios',
                  Icons.cleaning_services,
                  Colors.orange,
                  () => _confirmarYReset(context),
                  'reset_relaciones',
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMicrositioToolsSliver() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _cardsAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - _cardsAnimation.value)),
            child: Opacity(
              opacity: _cardsAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildMicrositioSection(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMicrositioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _buildSectionHeader(
          'Micrositio - Encuestas',
          'Gestión de formularios y encuestas del micrositio público',
          Icons.poll_outlined,
          kAccentBlue,
        ),
        const SizedBox(height: 20),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _buildMaintenanceCard(
              'Editor de Encuestas',
              'Edita preguntas y configuración de encuestas del micrositio',
              Icons.edit_note,
              kAccentBlue,
              () => _abrirDialogoEncuesta(context),
              'editar_encuestas',
            ),
          ),
        ),
        const SizedBox(height: 100), // Espacio final
      ],
    );
  }

  Widget _buildSectionHeader(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: kSombraCard,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    String operationKey, {
    bool isDestructive = false,
  }) {
    final isExecuting = _executionStatus[operationKey] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.3)
              : color.withValues(alpha: 0.2),
        ),
        boxShadow: kSombraCard,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isExecuting ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.1),
                        color.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: isExecuting
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        )
                      : Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDestructive
                              ? Colors.red.shade700
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: kTextSecondary,
                          height: 1.4,
                        ),
                      ),
                      if (isDestructive) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning,
                                size: 14,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Operación destructiva',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  isExecuting ? Icons.hourglass_empty : Icons.arrow_forward_ios,
                  color: isExecuting ? color : kTextMuted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // 🎯 MÉTODOS DE LÓGICA DE NEGOCIO (MANTENIDOS DEL ORIGINAL)
  // ====================================================================

  void _refreshStats() {
    // Aquí podrías cargar estadísticas reales del sistema
    setState(() {
      // Simular actualización de stats
    });
  }

  void _ejecutarFuncion(
    BuildContext context,
    String url,
    String nombreProceso,
    String operationKey,
  ) async {
    final scaffold = ScaffoldMessenger.of(context);

    setState(() {
      _executionStatus[operationKey] = true;
    });

    HapticFeedback.mediumImpact();

    scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('Ejecutando $nombreProceso...')),
          ],
        ),
        backgroundColor: kBrandPurple,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final response = await http.get(Uri.parse(url));

      setState(() {
        _executionStatus[operationKey] = false;
        _totalOperations++;
        if (response.statusCode == 200) {
          _successfulOperations++;
        } else {
          _failedOperations++;
        }
      });

      scaffold.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                response.statusCode == 200 ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  response.statusCode == 200
                      ? '✅ $nombreProceso completado exitosamente'
                      : '❌ Error ejecutando $nombreProceso',
                ),
              ),
            ],
          ),
          backgroundColor:
              response.statusCode == 200 ? Colors.green : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() {
        _executionStatus[operationKey] = false;
        _totalOperations++;
        _failedOperations++;
      });

      scaffold.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('❌ Error ejecutando $nombreProceso: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _confirmarYReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('¿Estás seguro?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esto eliminará los arrays de professionalIds en todos los servicios.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Esta operación no se puede deshacer',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Confirmar', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pop(context);
              _ejecutarFuncion(
                context,
                'https://us-central1-fisiospakym-afff6.cloudfunctions.net/resetProfessionalIds',
                'Reset de relaciones',
                'reset_relaciones',
              );
            },
          ),
        ],
      ),
    );
  }

  void _abrirDialogoEncuesta(BuildContext context) {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        child: Container(
          width: 700,
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: kSombraCardElevated,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kAccentBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.edit_note, color: kAccentBlue),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Editor de encuesta del micrositio',
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            body: const EncuestaEditorWidget(),
          ),
        ),
      ),
    );
  }
}
