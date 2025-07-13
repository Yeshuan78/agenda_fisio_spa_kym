// [services_screen.dart] - CON SISTEMA MANDALA VORTEX INTEGRADO
// 📁 Ubicación: /lib/screens/servicios/services_screen.dart
// 🎯 OBJETIVO: Screen con Mandala Vortex 🌀 + funcionalidad existente

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/shared/search_bar_filtro.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/custom_sidebar_pro.dart';
import 'package:agenda_fisio_spa_kym/models/servicio_model.dart';
import 'package:agenda_fisio_spa_kym/models/categoria_model.dart';
import 'package:agenda_fisio_spa_kym/models/paquete_model.dart';
import 'package:agenda_fisio_spa_kym/models/tratamiento_model.dart';
import 'package:agenda_fisio_spa_kym/services/servicio_service.dart';
import 'package:agenda_fisio_spa_kym/services/categoria_service.dart';
import 'package:agenda_fisio_spa_kym/services/paquete_service.dart';
import 'package:agenda_fisio_spa_kym/services/tratamiento_service.dart';
import 'package:agenda_fisio_spa_kym/widgets/servicios/categoria_group_widget.dart';
import 'package:agenda_fisio_spa_kym/widgets/servicios/paquetes/paquetes_tratamientos_section.dart';
import 'package:agenda_fisio_spa_kym/widgets/servicios/categoria_form_dialog.dart';
import 'package:agenda_fisio_spa_kym/widgets/servicios/servicio_form.dart';
import 'package:agenda_fisio_spa_kym/widgets/servicios/paquetes/paquete_form.dart';
import 'package:agenda_fisio_spa_kym/widgets/servicios/paquetes/tratamiento_form.dart';
import 'package:agenda_fisio_spa_kym/widgets/servicios/floating_menu_speed_dial.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with TickerProviderStateMixin {
  // ✅ CONTROLADORES DE ANIMACIÓN
  late AnimationController _contentAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _contentAnimation;
  late Animation<double> _fabAnimation;

  // ✅ ESTADO DE LA APLICACIÓN
  List<ServicioModel> servicios = [];
  List<CategoriaModel> categorias = [];
  List<PaqueteModel> paquetes = [];
  List<TratamientoModel> tratamientos = [];
  bool isLoading = true;
  String _filtroTexto = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _cargarDatos();
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

  Future<void> _cargarDatos() async {
    try {
      final serviciosCargados = await ServicioService().getServicios();
      final categoriasCargadas = await CategoriaService().getCategorias();
      final paquetesCargados = await PaqueteService().getPaquetes();
      final tratamientosCargados = await TratamientoService().getTratamientos();

      setState(() {
        servicios = serviciosCargados;
        categorias = categoriasCargadas;
        paquetes = paquetesCargados;
        tratamientos = tratamientosCargados;
        isLoading = false;
      });

      // Iniciar animaciones después de cargar datos
      _contentAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 400), () {
        _fabAnimationController.forward();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error cargando datos: $e');
    }
  }

  void _abrirFormulario({ServicioModel? servicio}) async {
    final creado = await showDialog<bool>(
      context: context,
      builder: (_) => ServicioForm(servicio: servicio),
    );
    if (creado == true) await _cargarDatos();
  }

  void _crearCategoria() async {
    final nueva = await showDialog<String>(
      context: context,
      builder: (_) => const CategoriaFormDialog(),
    );
    if (nueva != null && nueva.isNotEmpty) await _cargarDatos();
  }

  void _eliminarServicio(String id) async {
    await ServicioService().deleteServicio(id);
    await _cargarDatos();
  }

  Map<String, List<ServicioModel>> _agruparServicios() {
    final Map<String, List<ServicioModel>> mapa = {};
    for (var servicio in servicios) {
      mapa.putIfAbsent(servicio.category, () => []).add(servicio);
    }
    return mapa;
  }

  void _onSearchChanged(String value) {
    setState(() {
      _filtroTexto = value;
    });
  }

  @override
  void dispose() {
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
    if (isLoading) {
      return _buildLoadingScreen();
    }

    // 🌀 USANDO CUSTOMSCROLLVIEW CON MANDALA VORTEX
    return CustomScrollView(
      slivers: [
        // 🌀 MANDALA APPBAR - VORTEX PARA SERVICIOS (YA ES UN SLIVER)
        MandalaTheme.buildMandalaAppBar(
          moduleName: 'servicios',
          title: 'Catálogo de Servicios',
          subtitle: 'Flujo de energía y tratamientos especializados',
          icon: Icons.spa_outlined,
          expandedHeight: 200,
          pinned: true,
          floating: false,
          actions: [
            IconButton(
              onPressed: () => _cargarDatos(),
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Actualizar catálogo',
            ),
            _buildMandalaHeaderStats(),
          ],
        ),

        // 🔧 FIX: SEPARAR CONTENIDO EN SLIVERS INDIVIDUALES
        _buildSearchSectionSliver(),
        _buildServicesContentSliver(),
      ],
    );
  }

  Widget _buildSearchSectionSliver() {
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kBorderSoft),
                            boxShadow: kSombraCard,
                          ),
                          child: SearchBarFiltro(
                            hint:
                                'Buscar servicios, paquetes o tratamientos...',
                            onChanged: _onSearchChanged,
                          ),
                        ),
                        if (_filtroTexto.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: kBrandPurple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: kBrandPurple.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.filter_alt,
                                  size: 16,
                                  color: kBrandPurple,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Filtrando por: "$_filtroTexto"',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: kBrandPurple,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _onSearchChanged(''),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: kBrandPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildServicesContentSliver() {
    return SliverToBoxAdapter(
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: AnimatedBuilder(
          animation: _contentAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 40 * (1 - _contentAnimation.value)),
              child: Opacity(
                opacity: _contentAnimation.value,
                child: Center(
                  child: Container(
                    width: 800,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(),
                        const SizedBox(height: 24),
                        _buildServicesCategories(),
                        const SizedBox(height: 32),
                        _buildPaquetesTratamientosSection(),
                        const SizedBox(height: 100), // Espacio para FAB
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
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
            'Cargando catálogo de servicios...',
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

  // 🌀 ESTADÍSTICAS PARA EL HEADER MANDALA
  Widget _buildMandalaHeaderStats() {
    final totalServicios = servicios.length;
    final totalCategorias = categorias.length;
    final totalPaquetes = paquetes.length;
    final totalTratamientos = tratamientos.length;

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
            Icons.spa,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '$totalServicios',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.category,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '$totalCategorias',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (totalPaquetes > 0 || totalTratamientos > 0) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.inventory_2,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              '${totalPaquetes + totalTratamientos}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Eliminar métodos ya que se refactorizaron en slivers separados

  Widget _buildSummaryCards() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Servicios',
              servicios.length.toString(),
              Icons.spa,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Categorías',
              categorias.length.toString(),
              Icons.category,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Paquetes',
              paquetes.length.toString(),
              Icons.inventory_2,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Tratamientos',
              tratamientos.length.toString(),
              Icons.healing,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: kSombraCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                count,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesCategories() {
    final serviciosAgrupados = _agruparServicios();

    return Column(
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
                'Servicios por Categoría',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
            ],
          ),
        ),
        ...categorias.map((categoria) {
          final serviciosCategoria = serviciosAgrupados[categoria.nombre] ?? [];
          return CategoriaGroupWidget(
            categoria: categoria,
            servicios: serviciosCategoria,
            onEdit: (s) => _abrirFormulario(servicio: s),
            onDelete: (s) => _eliminarServicio(s.servicioId),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPaquetesTratamientosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: kBrandPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Paquetes y Tratamientos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
            ],
          ),
        ),
        PaquetesTratamientosSection(
          paquetes: paquetes,
          tratamientos: tratamientos,
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: FloatingMenuSpeedDial(
            onNuevoServicio: () => _abrirFormulario(),
            onNuevaCategoria: _crearCategoria,
            onNuevoPaquete: () {
              showDialog(
                context: context,
                builder: (_) => PaqueteForm(
                  serviciosDisponibles: servicios,
                  onGuardar: (paquete) {
                    PaqueteService().crearPaquete(paquete);
                    _cargarDatos();
                  },
                ),
              );
            },
            onNuevoTratamiento: () {
              showDialog(
                context: context,
                builder: (_) => TratamientoForm(
                  serviciosDisponibles: servicios,
                  onGuardar: (tratamiento) {
                    TratamientoService().crearTratamiento(tratamiento);
                    _cargarDatos();
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
