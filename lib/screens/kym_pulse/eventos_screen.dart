// [eventos_screen_refactored.dart] - COORDINADOR QUIRÚRGICO
// 📁 Ubicación: /lib/screens/eventos/eventos_screen_refactored.dart
// 🎯 PRESERVA EXACTAMENTE la funcionalidad del eventos_screen.dart original

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/evento_model.dart';
import 'package:agenda_fisio_spa_kym/services/evento_service.dart';
import 'package:agenda_fisio_spa_kym/screens/kym_pulse/evento_crud_dialog.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/components/eventos_header.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/components/eventos_filters_section.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/components/eventos_stats_section.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/components/eventos_list_builder.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/components/eventos_empty_state.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/components/eventos_loading_state.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/components/eventos_fab.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen>
    with TickerProviderStateMixin {
  // ✅ MANTENER: Todas las variables de estado EXACTAS
  List<EventoModel> eventos = [];
  List<EventoModel> eventosFiltrados = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedFilter = 'Todos';

  // ✅ MANTENER: Todos los controladores de animación EXACTOS
  late AnimationController _headerController;
  late AnimationController _fabController;
  late AnimationController _cardsController;

  late Animation<double> _headerAnimation;
  late Animation<double> _fabAnimation;
  late Animation<double> _cardsAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupScrollListener();
    cargarEventos();
  }

  // ✅ MANTENER: Todos los métodos de inicialización EXACTOS
  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );

    _cardsAnimation = CurvedAnimation(
      parent: _cardsController,
      curve: Curves.easeOutCubic,
    );
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isScrolled = _scrollController.offset > 10;
      if (isScrolled != _isScrolled) {
        setState(() => _isScrolled = isScrolled);
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _fabController.dispose();
    _cardsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ MANTENER: Toda la lógica de negocio EXACTA
  void cargarEventos() async {
    setState(() => isLoading = true);
    final data = await EventoService().getEventos();
    if (!mounted) return;

    setState(() {
      eventos = data;
      eventosFiltrados = data;
      isLoading = false;
    });

    // Iniciar animaciones cuando los datos estén listos
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _cardsController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _fabController.forward();
  }

  void _handleEventoUpdated(EventoModel eventoActualizado) {
    setState(() {
      // Actualizar en la lista principal
      final index = eventos.indexWhere((e) => e.id == eventoActualizado.id);
      if (index != -1) {
        eventos[index] = eventoActualizado;
      }

      // Actualizar en la lista filtrada
      final filteredIndex =
          eventosFiltrados.indexWhere((e) => e.id == eventoActualizado.id);
      if (filteredIndex != -1) {
        eventosFiltrados[filteredIndex] = eventoActualizado;
      }
    });

    debugPrint(
        '✅ Evento actualizado inmediatamente en UI: ${eventoActualizado.estado}');
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

  void abrirDialogoNuevoEvento() async {
    final resultado = await showDialog(
      context: context,
      builder: (_) => const EventoCrudDialog(),
    );
    if (!mounted) return;
    if (resultado == true) {
      cargarEventos();
    }
  }

  void _editarEvento(EventoModel evento) {
    showDialog(
      context: context,
      builder: (_) => EventoCrudDialog(evento: evento),
    ).then((resultado) {
      if (!mounted) return;
      if (resultado == true) cargarEventos();
    });
  }

  void _eliminarEvento(EventoModel evento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteDialog(),
    );
    if (confirmar == true) {
      await EventoService().deleteEvento(evento.eventoId ?? '');
      if (!mounted) return;
      cargarEventos();
    }
  }

  Widget _buildDeleteDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.01),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(Icons.warning_rounded, color: Colors.red[600], size: 24),
          ),
          const SizedBox(width: 12),
          const Text('¿Eliminar evento?'),
        ],
      ),
      content: const Text(
          'Esta acción no se puede deshacer. Todos los datos relacionados se perderán permanentemente.'),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Eliminar'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ✅ COMPONENTE HEADER EXTRAÍDO
          EventosHeader(
            headerAnimation: _headerAnimation,
            totalEventos: eventos.length,
            eventosActivos: eventos.where((e) => e.estado == 'activo').length,
          ),

          // ✅ COMPONENTE FILTROS EXTRAÍDO
          SliverToBoxAdapter(
            child: EventosFiltersSection(
              searchQuery: searchQuery,
              selectedFilter: selectedFilter,
              onSearchChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _filtrarEventos();
                });
              },
              onFilterChanged: (filter) {
                setState(() {
                  selectedFilter = filter;
                  _filtrarEventos();
                });
              },
              availableFilters: const [
                'Todos',
                'activo',
                'completado',
                'programado',
                'cancelado',
                'reagendado',
                'pausado'
              ],
              headerAnimation: _headerAnimation,
            ),
          ),

          // ✅ COMPONENTE ESTADÍSTICAS EXTRAÍDO
          SliverToBoxAdapter(
            child: EventosStatsSection(
              eventos: eventos,
              headerAnimation: _headerAnimation,
            ),
          ),

          // ✅ COMPONENTES CONDICIONALES EXTRAÍDOS - CORREGIDOS
          if (isLoading)
            const EventosLoadingState()
          else if (eventosFiltrados.isEmpty)
            EventosEmptyState(
              searchQuery: searchQuery,
              selectedFilter: selectedFilter,
              onCreateEvento: abrirDialogoNuevoEvento,
            )
          else
            EventosListBuilder(
              eventosFiltrados: eventosFiltrados,
              cardsAnimation: _cardsAnimation,
              onEdit: _editarEvento,
              onDelete: _eliminarEvento,
              onEventoUpdated: _handleEventoUpdated,
            ),
        ],
      ),

      // ✅ COMPONENTE FAB EXTRAÍDO
      floatingActionButton: EventosFab(
        fabAnimation: _fabAnimation,
        onPressed: abrirDialogoNuevoEvento,
      ),
    );
  }
}
