// [reminders_screen.dart] - CON SISTEMA MANDALA CRYSTALLINE INTEGRADO
// 📁 Ubicación: /lib/screens/reminders/reminders_screen.dart
// 🎯 OBJETIVO: Screen con Mandala Crystalline 💎 + funcionalidad existente

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:agenda_fisio_spa_kym/theme/theme.dart';

import 'package:agenda_fisio_spa_kym/screens/reminders/widgets/reminder_card.dart';
import 'package:agenda_fisio_spa_kym/screens/reminders/widgets/reminder_filters_sidebar.dart';
import 'package:agenda_fisio_spa_kym/screens/reminders/widgets/message_templates_tab.dart';
import 'package:agenda_fisio_spa_kym/screens/reminders/widgets/resumen_envios_dashboard.dart';
import 'package:agenda_fisio_spa_kym/screens/reminders/widgets/citas_con_errores_dashboard.dart';
import 'package:agenda_fisio_spa_kym/screens/reminders/widgets/estado_citas_dashboard.dart';
import 'package:agenda_fisio_spa_kym/screens/reminders/widgets/automatic_reminder_settings_card.dart';
import 'package:agenda_fisio_spa_kym/screens/reminders/widgets/historial_envios_sidebar.dart';

import 'package:agenda_fisio_spa_kym/services/whatsapp_integration.dart';
import 'package:agenda_fisio_spa_kym/services/correo_service.dart';
import 'package:agenda_fisio_spa_kym/services/notificaciones_logger.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with TickerProviderStateMixin {
  // ✅ CONTROLADORES DE ANIMACIÓN
  late final TabController _tabController;
  late AnimationController _contentAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _contentAnimation;
  late Animation<double> _fabAnimation;

  // ✅ ESTADO DE LA APLICACIÓN
  ReminderFilters _filtros = ReminderFilters();
  bool _isInitialized = false;
  int _totalCitas = 0;
  int _citasEnviadas = 0;
  int _citasPendientes = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _loadInitialData();
  }

  void _initializeControllers() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
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

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    );
  }

  Future<void> _loadInitialData() async {
    try {
      // Cargar estadísticas básicas
      final snapshot =
          await FirebaseFirestore.instance.collection('bookings').get();

      int total = snapshot.docs.length;
      int enviadas = 0;
      int pendientes = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final whatsappSent = data['whatsappSent'] ?? false;
        final emailSent = data['emailSent'] ?? false;

        if (whatsappSent || emailSent) {
          enviadas++;
        } else {
          pendientes++;
        }
      }

      setState(() {
        _totalCitas = total;
        _citasEnviadas = enviadas;
        _citasPendientes = pendientes;
        _isInitialized = true;
      });

      // Iniciar animaciones
      _contentAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (_tabController.index == 1) {
          _fabAnimationController.forward();
        }
      });
    } catch (e) {
      setState(() {
        _isInitialized = true;
      });
      debugPrint('Error cargando datos iniciales: $e');
    }
  }

  void _onTabChanged() {
    if (_tabController.index == 1) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contentAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    if (!_isInitialized) {
      return _buildLoadingScreen();
    }

    // 💎 USANDO CUSTOMSCROLLVIEW CON MANDALA CRYSTALLINE
    return CustomScrollView(
      slivers: [
        // 🌀 MANDALA APPBAR - CRYSTALLINE PARA RECORDATORIOS
        MandalaTheme.buildMandalaAppBar(
          moduleName: 'recordatorios',
          title: 'Sistema de Recordatorios',
          subtitle: 'Precisión temporal y notificaciones automatizadas',
          icon: Icons.notifications_outlined,
          expandedHeight: 200,
          pinned: true,
          floating: false,
          actions: [
            IconButton(
              onPressed: () => _loadInitialData(),
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Actualizar estadísticas',
            ),
            _buildMandalaHeaderStats(),
          ],
        ),

        _buildTabBarSliver(),
        _buildTabContentSliver(),
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
            'Cargando sistema de recordatorios...',
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

  // 💎 ESTADÍSTICAS PARA EL HEADER MANDALA
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
            Icons.schedule_send,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '$_citasEnviadas',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.pending_actions,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '$_citasPendientes',
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

  Widget _buildTabBarSliver() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _contentAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _contentAnimation.value)),
            child: Opacity(
              opacity: _contentAnimation.value,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorderSoft),
                  boxShadow: kSombraCard,
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: kBrandPurple,
                    unselectedLabelColor: kTextSecondary,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    indicator: BoxDecoration(
                      color: kBrandPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: kBrandPurple.withValues(alpha: 0.3)),
                    ),
                    indicatorPadding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.dashboard_outlined, size: 18),
                            const SizedBox(width: 8),
                            const Text('Dashboard'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.notifications_outlined, size: 18),
                            const SizedBox(width: 8),
                            const Text('Recordatorios'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.message_outlined, size: 18),
                            const SizedBox(width: 8),
                            const Text('Plantillas'),
                          ],
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
    );
  }

  Widget _buildTabContentSliver() {
    return SliverToBoxAdapter(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8, // 🔧 FIX: Altura fija
        child: AnimatedBuilder(
          animation: _contentAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _contentAnimation.value)),
              child: Opacity(
                opacity: _contentAnimation.value,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // 📊 TAB 1: DASHBOARD
                      _buildDashboardTab(),

                      // 📝 TAB 2: RECORDATORIOS
                      _buildRemindersTab(),

                      // 💬 TAB 3: PLANTILLAS
                      _buildTemplatesTab(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDashboardHeader(),
          const SizedBox(height: 24),
          const ResumenEnviosDashboard(),
          const SizedBox(height: 16),
          const CitasConErroresDashboard(),
          const SizedBox(height: 16),
          const EstadoCitasDashboard(),
          const SizedBox(height: 100), // Espacio para posible FAB
        ],
      ),
    );
  }

  Widget _buildDashboardHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            kBrandPurple.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBrandPurple.withValues(alpha: 0.2)),
        boxShadow: kSombraCard,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kBrandPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.analytics_outlined,
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
                  'Panel de Control',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kBrandPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitoreo en tiempo real del sistema de notificaciones',
                  style: TextStyle(
                    fontSize: 14,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildQuickStatItem('Total', _totalCitas.toString(), Colors.blue),
        const SizedBox(width: 16),
        _buildQuickStatItem(
            'Enviadas', _citasEnviadas.toString(), Colors.green),
        const SizedBox(width: 16),
        _buildQuickStatItem(
            'Pendientes', _citasPendientes.toString(), Colors.orange),
      ],
    );
  }

  Widget _buildQuickStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: kTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRemindersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: MediaQuery.of(context).size.height *
            0.75, // Altura fija para el contenido
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtros
            Container(
              width: 280,
              child: ReminderFiltersSidebar(
                initialFilters: _filtros,
                onFilterChanged: (f) {
                  setState(() {
                    _filtros = f;
                  });
                },
              ),
            ),

            const SizedBox(width: 24),

            // Lista de recordatorios
            Expanded(child: _buildReminderList()),

            const SizedBox(width: 24),

            // Columna derecha: Ajustes + Historial
            Container(
              width: 300,
              child: Column(
                children: const [
                  // Ajustes automáticos
                  Expanded(
                    child: AutomaticReminderSettingsCard(),
                  ),
                  SizedBox(height: 16),

                  // Historial de envíos
                  Expanded(
                    child: HistorialEnviosSidebar(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTemplatesHeader(),
          const SizedBox(height: 24),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6, // Altura fija
            child: const MessageTemplatesTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            kAccentBlue.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAccentBlue.withValues(alpha: 0.2)),
        boxShadow: kSombraCard,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kAccentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.message_outlined,
              color: kAccentBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plantillas de Mensajes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kAccentBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gestiona plantillas personalizadas para WhatsApp y correo electrónico',
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

  Widget _buildReminderList() {
    final query = FirebaseFirestore.instance.collection('bookings');
    Query base = query.orderBy('date', descending: true);

    if (_filtros.tipoUsuario?.isNotEmpty == true) {
      base = base.where('tipoUsuario', isEqualTo: _filtros.tipoUsuario);
    }
    if (_filtros.estado?.isNotEmpty == true) {
      base = base.where('status', isEqualTo: _filtros.estado);
    }
    if (_filtros.fechaDesde != null) {
      final iso = _filtros.fechaDesde!.toIso8601String();
      base = base.where('date', isGreaterThanOrEqualTo: iso);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderSoft),
        boxShadow: kSombraCard,
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: base.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: kTextMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay citas registradas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final clientName = data['clientName'] ?? 'Sin nombre';
              final status = data['status'] ?? 'Sin estado';
              final telefono = data['clientPhone'] ?? '';
              final correo = data['clientEmail'] ?? '';
              final tipoUsuario = data['tipoUsuario'] ?? 'cliente';
              final servicio = data['serviceName'] ?? 'Servicio no definido';

              final profesionalNombre = data['profesionalNombre'] ?? '';
              final profesionalApellidos = data['profesionalApellidos'] ?? '';
              final nombreCompletoProfesional =
                  '$profesionalNombre $profesionalApellidos'.trim();

              final dateString = data['date'] ?? '';
              DateTime? dateTime;
              try {
                dateTime = DateTime.parse(dateString);
              } catch (_) {
                dateTime = null;
              }

              final fecha = dateTime != null
                  ? DateFormat.yMMMMd('es_MX').format(dateTime)
                  : 'Fecha inválida';
              final hora =
                  dateTime != null ? DateFormat.Hm().format(dateTime) : '--:--';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: ReminderCard(
                  nombreCliente: clientName,
                  estado: status,
                  fecha: fecha,
                  hora: hora,
                  whatsappEnviado: data['whatsappSent'] ?? false,
                  correoEnviado: data['emailSent'] ?? false,
                  telefonoCliente: telefono,
                  emailCliente: correo,
                  tipoUsuario: tipoUsuario,
                  nombreServicio: servicio,
                  nombreProfesional: nombreCompletoProfesional,
                  onMensajeReenviado: () {
                    debugPrint("Mensaje reenviado para $clientName");
                    _loadInitialData(); // Actualizar stats
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: _tabController.index == 1
              ? Container(
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
                    onPressed: _confirmarEnvioMasivo,
                    backgroundColor: kBrandPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    icon: const Icon(Icons.send, size: 24),
                    label: const Text(
                      "Enviar a todos",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }

  // ====================================================================
  // 🎯 MÉTODOS DE LÓGICA DE NEGOCIO (MANTENIDOS DEL ORIGINAL)
  // ====================================================================

  Future<void> _confirmarEnvioMasivo() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Enviar recordatorios masivos?"),
        content: const Text(
          "Se enviarán recordatorios por WhatsApp y correo a todas las citas con estado 'reservado' o 'confirmado'.",
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancelar")),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Enviar")),
        ],
      ),
    );

    if (confirmado == true) {
      await _enviarRecordatoriosMasivos();
    }
  }

  Future<void> _enviarRecordatoriosMasivos() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('status', whereIn: ['reservado', 'confirmado']).get();

    int enviadosWhatsApp = 0;
    int enviadosCorreo = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final id = doc.id;

      final nombre = data['clientName'] ?? 'Cliente';
      final estado = (data['status'] ?? 'reservado').toLowerCase();
      final telefono = data['clientPhone'] ?? '';
      final correo = data['clientEmail'] ?? '';
      final tipoUsuario = (data['tipoUsuario'] ?? 'cliente').toLowerCase();
      final servicio = data['serviceName'] ?? 'Servicio no definido';

      final profesionalNombre = data['profesionalNombre'] ?? '';
      final profesionalApellidos = data['profesionalApellidos'] ?? '';
      final nombreProfesional =
          '$profesionalNombre $profesionalApellidos'.trim();

      final fechaRaw = data['date'] ?? '';
      DateTime? fechaCita;
      try {
        fechaCita = DateTime.parse(fechaRaw);
      } catch (_) {}

      final fecha = fechaCita != null
          ? DateFormat.yMMMMd('es_MX').format(fechaCita)
          : 'fecha';
      final hora =
          fechaCita != null ? DateFormat.Hm().format(fechaCita) : 'hora';

      final variables = {
        '{{nombre}}': nombre,
        '{{fecha}}': fecha,
        '{{hora}}': hora,
        '{{servicio}}': servicio,
        '{{profesional}}': nombreProfesional,
      };

      // WHATSAPP
      if (telefono.isNotEmpty && (data['whatsappSent'] != true)) {
        final snap = await FirebaseFirestore.instance
            .collection('notificaciones_config')
            .doc('templates')
            .collection('whatsapp_$tipoUsuario')
            .doc(estado)
            .get();

        if (snap.exists) {
          String mensaje = snap['mensaje'] ?? '';
          variables.forEach((k, v) => mensaje = mensaje.replaceAll(k, v));

          await WhatsAppIntegration.enviarMensajeTexto(
            telefono: telefono,
            mensaje: mensaje,
          );

          await doc.reference.update({'whatsappSent': true});
          await NotificacionesLogger.logEnvioMensaje(
            bookingId: id,
            canal: 'whatsapp',
            clienteNombre: nombre,
            estado: estado,
            mensaje: mensaje,
            tipoUsuario: tipoUsuario,
          );
          enviadosWhatsApp++;
        } else {
          debugPrint(
              '❌ No se encontró plantilla WhatsApp: $estado / $tipoUsuario');
        }
      }

      // CORREO
      if (correo.isNotEmpty && (data['emailSent'] != true)) {
        final snap = await FirebaseFirestore.instance
            .collection('notificaciones_config')
            .doc('templates')
            .collection('email_$tipoUsuario')
            .doc(estado)
            .get();

        if (snap.exists) {
          String mensaje = snap['mensaje'] ?? '';
          variables.forEach((k, v) => mensaje = mensaje.replaceAll(k, v));

          final enviado = await CorreoService.enviarCorreo(
            destinatario: correo,
            asunto: "Detalles de tu cita - Fisio Spa KYM",
            contenidoHtml: mensaje,
          );

          if (enviado) {
            await doc.reference.update({'emailSent': true});
            await NotificacionesLogger.logEnvioMensaje(
              bookingId: id,
              canal: 'email',
              clienteNombre: nombre,
              estado: estado,
              mensaje: mensaje,
              tipoUsuario: tipoUsuario,
            );
            enviadosCorreo++;
          }
        } else {
          debugPrint(
              '❌ No se encontró plantilla Correo: $estado / $tipoUsuario');
        }
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "📨 $enviadosWhatsApp WhatsApp enviados\n📧 $enviadosCorreo correos enviados",
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: kBrandPurple,
      ),
    );

    // Actualizar estadísticas después del envío masivo
    await _loadInitialData();
  }
}
