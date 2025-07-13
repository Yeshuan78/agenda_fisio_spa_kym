import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/kym_pulse/pulse_dashboard_resumen.dart';
import 'package:agenda_fisio_spa_kym/widgets/kym_pulse/pulse_dashboard_resumen_alt.dart';
import 'package:agenda_fisio_spa_kym/widgets/kym_pulse/pulse_card.dart';
import 'package:agenda_fisio_spa_kym/models/evento_model.dart';

class KymPulseDashboard extends StatefulWidget {
  const KymPulseDashboard({super.key});

  @override
  State<KymPulseDashboard> createState() => _KymPulseDashboardState();
}

class _KymPulseDashboardState extends State<KymPulseDashboard>
    with TickerProviderStateMixin {
  // ✅ TU LÓGICA DE DATOS ORIGINAL
  bool mostrarResumenAlterno = false;

  int totalRegistros = 0;
  int totalEventos = 0;
  int totalProfesionales = 0;
  int totalServicios = 0;
  int totalCombinaciones = 0;
  int eventosSinRegistros = 0;

  List<EventoModel> eventos = [];
  Map<String, Map<String, int>> registrosPorEvento = {};
  Map<String, String> serviciosNombres = {};
  Map<String, String> profesionalesNombres = {};

  // ✅ ANIMACIONES PREMIUM ESTILO EVENTOS_SCREEN
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late AnimationController _fabController;
  late AnimationController _liveController;

  late Animation<double> _headerAnimation;
  late Animation<double> _cardsAnimation;
  late Animation<double> _fabAnimation;
  late Animation<double> _liveAnimation;

  // ✅ ESTADOS DE FILTROS Y BÚSQUEDA
  String searchQuery = '';
  String selectedFilter = 'Todos';
  List<EventoModel> eventosFiltrados = [];
  bool isLoading = true;

  final List<String> filtros = [
    'Todos',
    'Activo',
    'Completado',
    'Pendiente',
    'Cancelado'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _cargarDatos();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _liveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );

    _cardsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeOutCubic),
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _liveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _liveController, curve: Curves.easeInOut),
    );

    _startAnimationSequence();
    _liveController.repeat(reverse: true);
  }

  void _startAnimationSequence() async {
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _cardsController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _fabController.forward();
  }

  // ✅ TU FUNCIÓN ORIGINAL DE CARGAR DATOS MANTENIDA
  Future<void> _cargarDatos() async {
    setState(() => isLoading = true);

    final registrosSnap =
        await FirebaseFirestore.instance.collectionGroup('registros').get();

    final servicios = <String>{};
    final profesionales = <String>{};
    final agrupado = <String, Map<String, int>>{};
    final combinaciones = <String>{};

    for (final doc in registrosSnap.docs) {
      final data = doc.data();
      final eventoId = data['eventoId'] ?? '';
      final servicioId = data['servicioId'] ?? 'sin_servicio';
      final profesionalId = data['profesionalId'] ?? 'sin_profesional';
      final key = '$servicioId|$profesionalId';

      servicios.add(servicioId);
      profesionales.add(profesionalId);
      combinaciones.add('$eventoId|$key');

      agrupado.putIfAbsent(eventoId, () => {});
      agrupado[eventoId]![key] = (agrupado[eventoId]![key] ?? 0) + 1;
    }

    final eventosSnap = await FirebaseFirestore.instance
        .collection('eventos')
        .orderBy('fecha', descending: true)
        .get();

    final snapServicios =
        await FirebaseFirestore.instance.collection('services').get();

    final snapProfes =
        await FirebaseFirestore.instance.collection('profesionales').get();

    final mapServicios = {
      for (var doc in snapServicios.docs)
        doc.id: doc.data()['name']?.toString() ?? doc.id
    };

    final mapProfes = {
      for (var doc in snapProfes.docs)
        doc.id: doc.data()['nombre']?.toString() ?? doc.id
    };

    final eventosList = eventosSnap.docs
        .map((e) => EventoModel.fromMap(e.data(), e.id))
        .toList();

    final sinRegistros =
        eventosList.where((e) => !(agrupado.containsKey(e.id))).length;

    setState(() {
      totalRegistros = registrosSnap.docs.length;
      totalServicios = servicios.length;
      totalProfesionales = profesionales.length;
      totalEventos = eventosList.length;
      eventos = eventosList;
      registrosPorEvento = agrupado;
      serviciosNombres = mapServicios;
      profesionalesNombres = mapProfes;
      totalCombinaciones = combinaciones.length;
      eventosSinRegistros = sinRegistros;
      eventosFiltrados = eventosList;
      isLoading = false;
    });
  }

  void _filtrarEventos() {
    setState(() {
      eventosFiltrados = eventos.where((evento) {
        final matchesSearch = evento.nombre
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            evento.empresa.toLowerCase().contains(searchQuery.toLowerCase());

        final matchesFilter =
            selectedFilter == 'Todos' || evento.estado == selectedFilter;

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    _fabController.dispose();
    _liveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ✅ HEADER PREMIUM ESTILO EVENTOS_SCREEN
          _buildPremiumSliverAppBar(),

          // ✅ CONTENIDO PRINCIPAL CON 900PX
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _cardsAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _cardsAnimation.value)),
                  child: Opacity(
                    opacity: _cardsAnimation.value,
                    child: _buildMainContent(),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ✅ FAB PREMIUM ANIMADO
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: Transform.rotate(
              angle: (1 - _fabAnimation.value) * 0.5,
              child: FloatingActionButton.extended(
                onPressed: _cargarDatos,
                backgroundColor: kBrandPurple,
                icon: AnimatedBuilder(
                  animation: _liveController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _liveController.value * 2 * 3.14159,
                      child: const Icon(Icons.refresh, color: Colors.white),
                    );
                  },
                ),
                label: const Text(
                  'Actualizar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: AnimatedBuilder(
        animation: _headerAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -50 * (1 - _headerAnimation.value)),
            child: Opacity(
              opacity: _headerAnimation.value,
              child: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        kBrandPurple,
                        kAccentBlue,
                      ],
                    ),
                  ),
                  child: CustomPaint(
                    painter: _HeaderPatternPainter(),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.02),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.03),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.analytics,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 20),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'KYM Pulse Dashboard',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: kFontFamily,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Centro de comando para analytics avanzados',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                        fontFamily: kFontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _liveAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 0.8 + (_liveAnimation.value * 0.3),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green
                                                .withValues(alpha: 0.05),
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
                                            'SISTEMA ACTIVO',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ✅ 1. SEARCH BAR ESTILO EVENTOS_SCREEN
              _buildSearchSection(),

              const SizedBox(height: 32),

              // ✅ 2. RESÚMENES MEJORADOS ESTILO DASHBOARD
              _buildResumenSection(),

              const SizedBox(height: 32),

              // ✅ 3. PULSE CARDS
              _buildPulseCardsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.008),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.search, color: kBrandPurple, size: 24),
              SizedBox(width: 12),
              Text(
                'Buscar y Filtrar Eventos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Búsqueda
          TextField(
            onChanged: (value) {
              setState(() => searchQuery = value);
              _filtrarEventos();
            },
            decoration: InputDecoration(
              hintText: 'Buscar eventos o empresas...',
              prefixIcon: const Icon(Icons.search, color: kBrandPurple),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => searchQuery = '');
                        _filtrarEventos();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: kBorderColor.withValues(alpha: 0.03)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kBrandPurple, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Chips de filtro
          const Text(
            'Filtrar por estado:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: filtros.map((filtro) {
              final isSelected = selectedFilter == filtro;
              final color = _getFilterColor(filtro);

              return GestureDetector(
                onTap: () {
                  setState(() => selectedFilter = filtro);
                  _filtrarEventos();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withValues(alpha: 0.01),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getFilterIcon(filtro),
                        color: isSelected ? Colors.white : color,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        filtro,
                        style: TextStyle(
                          color: isSelected ? Colors.white : color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.008),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header con botón de cambio
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kBrandPurple.withValues(alpha: 0.01),
                  kAccentBlue.withValues(alpha: 0.01),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kBrandPurple, kAccentBlue],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.dashboard,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Resumen de registros KYM Pulse',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kBrandPurple,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: kBrandPurple.withValues(alpha: 0.01),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: AnimatedRotation(
                      turns: mostrarResumenAlterno ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.sync_alt, color: kBrandPurple),
                    ),
                    tooltip: 'Cambiar vista de resumen',
                    onPressed: () {
                      setState(() {
                        mostrarResumenAlterno = !mostrarResumenAlterno;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Contenido del resumen
          Padding(
            padding: const EdgeInsets.all(20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: !mostrarResumenAlterno
                  ? PulseDashboardResumen(
                      key: const ValueKey('resumen_principal'),
                      totalRegistros: totalRegistros,
                      totalEventos: totalEventos,
                      totalProfesionales: totalProfesionales,
                      totalServicios: totalServicios,
                    )
                  : PulseDashboardResumenAlt(
                      key: const ValueKey('resumen_alternativo'),
                      totalEventos: totalEventos,
                      totalRegistros: totalRegistros,
                      totalCombinaciones: totalCombinaciones,
                      eventosSinRegistros: eventosSinRegistros,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de eventos
        Row(
          children: [
            const Text(
              'Eventos recientes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kAccentGreen.withValues(alpha: 0.01),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kAccentGreen.withValues(alpha: 0.03)),
              ),
              child: Text(
                '${eventosFiltrados.length} eventos',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kAccentGreen,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Lista de pulse cards
        if (isLoading)
          ...List.generate(3, (index) => _buildLoadingSkeleton())
        else if (eventosFiltrados.isEmpty)
          _buildEmptyState()
        else
          ...eventosFiltrados.asMap().entries.map((entry) {
            final index = entry.key;
            final evento = entry.value;
            final delay = index * 0.1;

            return AnimatedBuilder(
              animation: _cardsAnimation,
              builder: (context, child) {
                final animationValue = Curves.easeOutCubic.transform(
                    ((_cardsAnimation.value - delay).clamp(0.0, 1.0) /
                            (1.0 - delay))
                        .clamp(0.0, 1.0));

                return Transform.translate(
                  offset: Offset(0, 30 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: PulseCard(evento: evento),
                  ),
                );
              },
            );
          }),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor.withValues(alpha: 0.03)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 16,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(
                3,
                (index) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor.withValues(alpha: 0.03)),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: kBrandPurple.withValues(alpha: 0.01),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              size: 60,
              color: kBrandPurple,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay eventos que coincidan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? 'Intenta con otros términos de búsqueda'
                : 'No hay eventos con el filtro seleccionado',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                searchQuery = '';
                selectedFilter = 'Todos';
              });
              _filtrarEventos();
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Limpiar filtros'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kBrandPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getFilterColor(String filtro) {
    switch (filtro) {
      case 'Activo':
        return kAccentGreen;
      case 'Completado':
        return kBrandPurple;
      case 'Pendiente':
        return kAccentBlue;
      case 'Cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getFilterIcon(String filtro) {
    switch (filtro) {
      case 'Activo':
        return Icons.play_circle_fill;
      case 'Completado':
        return Icons.check_circle;
      case 'Pendiente':
        return Icons.schedule;
      case 'Cancelado':
        return Icons.cancel;
      default:
        return Icons.filter_list;
    }
  }
}

class _HeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.01)
      ..strokeWidth = 1;

    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.width * 0.3, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
