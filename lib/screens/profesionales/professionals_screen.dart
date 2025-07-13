// [professionals_screen.dart] - CON SISTEMA MANDALA MOLECULAR INTEGRADO
// 📁 Ubicación: /lib/screens/profesionales/professionals_screen.dart
// 🎯 OBJETIVO: Screen con Mandala Molecular ⚗️ + funcionalidad existente

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/screens/profesionales/widgets/professionals_panel.dart';
import 'package:agenda_fisio_spa_kym/screens/profesionales/widgets/professional_crud_dialog.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class ProfessionalsScreen extends StatefulWidget {
  final Future<void> Function()? onNuevoProfesional;

  const ProfessionalsScreen({super.key, this.onNuevoProfesional});

  @override
  State<ProfessionalsScreen> createState() => _ProfessionalsScreenState();
}

class _ProfessionalsScreenState extends State<ProfessionalsScreen>
    with TickerProviderStateMixin {
  // ✅ CONTROLADORES DE ANIMACIÓN
  late AnimationController _contentAnimationController;
  late Animation<double> _contentAnimation;

  // ✅ ESTADO DE LA APLICACIÓN
  String _filtroBusqueda = '';
  String? _filtroCategoria;
  List<Map<String, dynamic>> _serviciosDisponibles = [];
  Map<String, int> _conteoProfesionales = {};
  Map<String, int> _conteoServicios = {};
  bool _isInitialized = false;

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
  }

  Future<void> _initializeData() async {
    await _cargarServicios();
    await _cargarConteosProfesionales();

    setState(() {
      _isInitialized = true;
    });

    // Iniciar animaciones
    _contentAnimationController.forward();

    // ✅ Detectar navegación con key especial para abrir CRUD automáticamente
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isDesdeSidebar = widget.key == const ValueKey('crear_nuevo');
      if (isDesdeSidebar) {
        await _abrirDialogoCrearProfesional();
        if (!mounted) return;
        // ❌ Se eliminó pushReplacementNamed('/profesionales')
        // ✅ No hacer nada: el listado ya está renderizado
      }
    });
  }

  Future<void> _abrirDialogoNuevoProfesional(BuildContext context) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('services')
        .where('activo', isEqualTo: true)
        .get();
    final serviciosDisponibles = snapshot.docs.map((e) => e.data()).toList();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => ProfessionalCrudDialog(
        serviciosDisponibles: serviciosDisponibles,
      ),
    );
  }

  Future<void> _cargarServicios() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('services').get();

    final servicios = snapshot.docs
        .map((doc) => {'serviceId': doc.id, ...doc.data()})
        .toList();

    setState(() {
      _serviciosDisponibles = servicios;
    });

    final Map<String, int> conteo = {};
    for (final s in servicios) {
      final cat = (s['category'] ?? '').toString();
      conteo[cat] = (conteo[cat] ?? 0) + 1;
    }

    setState(() {
      _conteoServicios = conteo;
    });
  }

  Future<void> _cargarConteosProfesionales() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('profesionales').get();

    final Map<String, Set<String>> profesionalesPorCategoria = {};

    for (var doc in snapshot.docs) {
      final profesionalId = doc.id;
      final servicios = List<Map<String, dynamic>>.from(doc['servicios'] ?? []);

      final Set<String> categoriasUnicas = servicios
          .map((s) => s['category']?.toString())
          .where((c) => c != null && c.isNotEmpty)
          .cast<String>()
          .toSet();

      for (var categoria in categoriasUnicas) {
        profesionalesPorCategoria
            .putIfAbsent(categoria, () => <String>{})
            .add(profesionalId);
      }
    }

    final Map<String, int> conteoFinal = {
      for (var entry in profesionalesPorCategoria.entries)
        entry.key: entry.value.length,
    };

    setState(() {
      _conteoProfesionales = conteoFinal;
    });
  }

  void _recargarProfesionales() {
    _cargarConteosProfesionales();
    setState(() {});
  }

  void _actualizarBusqueda(String texto) {
    setState(() {
      _filtroBusqueda = texto;
    });
  }

  void _actualizarCategoria(String? categoria) {
    setState(() {
      _filtroCategoria = categoria;
    });
  }

  Future<void> _abrirDialogoCrearProfesional() async {
    final creado = await showDialog(
      context: context,
      builder: (_) => ProfessionalCrudDialog(
        serviciosDisponibles: _serviciosDisponibles,
      ),
    );
    if (creado != null) {
      _recargarProfesionales();
    }
  }

  Color _colorFondoCategoria(String categoria) {
    final base = categoria.trim().toLowerCase();
    final colores = {
      'masajes': const Color(0xFFE1F5FE),
      'faciales': const Color(0xFFFFF3E0),
      'fisioterapia': const Color(0xFFE8F5E9),
      'podología': const Color(0xFFF3E5F5),
      'cosmetología': const Color(0xFFFFEBEE),
    };
    return colores[base] ?? Colors.grey.shade200;
  }

  @override
  void dispose() {
    _contentAnimationController.dispose();
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

    // ⚗️ USANDO CUSTOMSCROLLVIEW CON MANDALA MOLECULAR
    return CustomScrollView(
      slivers: [
        // 🌀 MANDALA APPBAR - MOLECULAR PARA PROFESIONALES
        MandalaTheme.buildMandalaAppBar(
          moduleName: 'profesionales',
          title: 'Equipo Profesional',
          subtitle: 'Estructura especializada y certificada',
          icon: Icons.medical_services_outlined,
          expandedHeight: 200,
          pinned: true,
          floating: false,
          actions: [
            IconButton(
              onPressed: () => _recargarProfesionales(),
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Actualizar datos',
            ),
            _buildMandalaHeaderStats(),
          ],
        ),

        SliverToBoxAdapter(child: _buildSearchSection()),
        SliverToBoxAdapter(child: _buildCategoriesFilter()),

        // 🔧 FIX: USAR SLIVERTOBOXADAPTER CON ALTURA FIJA PARA EVITAR CONFLICTO
        SliverToBoxAdapter(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7, // Altura fija
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedBuilder(
              animation: _contentAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _contentAnimation.value)),
                  child: Opacity(
                    opacity: _contentAnimation.value,
                    child: ProfessionalsPanel(
                      filtroTexto: _filtroBusqueda,
                      filtroCategoria: _filtroCategoria,
                      serviciosDisponibles: _serviciosDisponibles,
                      onUpdated: _recargarProfesionales,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Espacio adicional para el FAB
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
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
            'Cargando profesionales...',
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
    final totalProfesionales =
        _conteoProfesionales.values.fold(0, (a, b) => a + b);
    final totalServicios = _conteoServicios.values.fold(0, (a, b) => a + b);
    final categorias = _conteoServicios.keys.length;

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
            Icons.groups,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '$totalProfesionales',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.spa,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '$totalServicios',
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

  Widget _buildSearchSection() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorderSoft),
                      boxShadow: kSombraCard,
                    ),
                    child: TextField(
                      onChanged: _actualizarBusqueda,
                      decoration: InputDecoration(
                        hintText:
                            'Buscar profesionales por nombre, especialidad...',
                        hintStyle: TextStyle(
                          color: kTextMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: kTextSecondary,
                          size: 24,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesFilter() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          color: kBrandPurple,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Especialidades',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kBrandPurple,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_conteoServicios.keys.length} categorías activas',
                          style: TextStyle(
                            fontSize: 14,
                            color: kTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildFiltroCategorias(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFiltroCategorias() {
    final categorias = _serviciosDisponibles
        .map((s) => s['category']?.toString())
        .toSet()
        .whereType<String>()
        .toList()
      ..sort();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildCategoryChip(
          label: 'Todas',
          isSelected: _filtroCategoria == null,
          onSelected: () => _actualizarCategoria(null),
          professionalCount:
              _conteoProfesionales.values.fold(0, (a, b) => a + b),
          serviceCount: _conteoServicios.values.fold(0, (a, b) => a + b),
        ),
        ...categorias.map((categoria) {
          final isSelected = _filtroCategoria == categoria;
          final pCount = _conteoProfesionales[categoria] ?? 0;
          final sCount = _conteoServicios[categoria] ?? 0;

          return _buildCategoryChip(
            label: categoria,
            isSelected: isSelected,
            onSelected: () => _actualizarCategoria(categoria),
            professionalCount: pCount,
            serviceCount: sCount,
            backgroundColor: _colorFondoCategoria(categoria),
          );
        }),
      ],
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required int professionalCount,
    required int serviceCount,
    Color? backgroundColor,
  }) {
    final tooltip =
        '👥 $professionalCount profesionales\n📦 $serviceCount servicios';

    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (backgroundColor ?? kBrandPurple.withValues(alpha: 0.1))
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? kBrandPurple : kBorderSoft,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: kBrandPurple.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.check_circle,
                    size: 16,
                    color: kBrandPurple,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? kBrandPurple : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? kBrandPurple : kTextMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  professionalCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Eliminar método ya que se integró directamente en build()

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _contentAnimation.value,
          child: Container(
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
              onPressed:
                  widget.onNuevoProfesional ?? _abrirDialogoCrearProfesional,
              backgroundColor: kBrandPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              icon: const Icon(Icons.person_add, size: 24),
              label: const Text(
                'Nuevo Profesional',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
