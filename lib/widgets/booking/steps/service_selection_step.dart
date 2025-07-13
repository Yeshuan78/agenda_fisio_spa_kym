// [service_selection_step.dart] - ✨ PREMIUM: CATEGORÍAS OPTIMIZADAS UX
// 📁 Ubicación: /lib/widgets/booking/steps/service_selection_step.dart
// 🎯 OBJETIVO: Categorías visibles + Header limpio + UX enterprise
// ✅ FIX: Mostrar selección visual antes de avanzar al siguiente paso

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/booking/components/service_card_widget.dart';
import 'package:agenda_fisio_spa_kym/widgets/booking/components/event_selector_widget.dart';

class ServiceSelectionStep extends StatefulWidget {
  final Color accentColor;
  final bool showPricing;
  final Map<String, dynamic>? selectedEventData;
  final List<DocumentSnapshot> eventos;
  final String? selectedEventId;
  final String? selectedServiceId;
  final List<Map<String, dynamic>> serviciosDisponibles;
  final Function(String eventId) onEventSelected;
  final Function(String serviceId) onServiceSelected;

  const ServiceSelectionStep({
    super.key,
    required this.accentColor,
    required this.showPricing,
    this.selectedEventData,
    required this.eventos,
    this.selectedEventId,
    this.selectedServiceId,
    required this.serviciosDisponibles,
    required this.onEventSelected,
    required this.onServiceSelected,
  });

  @override
  State<ServiceSelectionStep> createState() => _ServiceSelectionStepState();
}

class _ServiceSelectionStepState extends State<ServiceSelectionStep> {
  String _searchQuery = '';
  String? _selectedCategory; // ✅ REMOVIDO DEFAULT "Todas"

  // ✅ FIX: VARIABLE PARA MOSTRAR SELECCIÓN TEMPORAL
  String? _temporarySelectedServiceId;

  // ✅ FIX: NUEVO MÉTODO PARA MANEJAR SELECCIÓN CON DELAY VISUAL
  void _handleServiceSelection(String serviceId) async {
    // Primero mostrar la selección visual
    setState(() {
      _temporarySelectedServiceId = serviceId;
    });

    // Esperar un momento para que el usuario vea la selección
    await Future.delayed(const Duration(milliseconds: 600));

    // Luego ejecutar el callback original que avanza al siguiente paso
    if (mounted) {
      widget.onServiceSelected(serviceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_getContainerPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_getBorderRadius(context)),
        boxShadow: kSombraCard,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ HEADER LIMPIO SIN ÍCONO + CONTADOR DINÁMICO
          _buildCleanHeader(),
          SizedBox(height: _getSectionSpacing(context)),

          // 📅 SELECTOR DE EVENTOS (SI APLICA)
          if (widget.eventos.isNotEmpty && widget.selectedEventId == null) ...[
            EventSelectorWidget(
              eventos: widget.eventos,
              selectedEventId: widget.selectedEventId,
              onEventSelected: widget.onEventSelected,
            ),
            SizedBox(height: _getSectionSpacing(context)),
          ],

          // 🔍 BARRA DE BÚSQUEDA PREMIUM
          _buildSearchBar(),
          SizedBox(height: _getContentSpacing(context)),

          // 🏷️ CATEGORÍAS RESPONSIVAS - ✅ NUEVO DISEÑO
          _buildResponsiveCategoryFilters(),
          SizedBox(height: _getContentSpacing(context)),

          // 🛍️ LISTA DE SERVICIOS
          _buildServicesList(),
        ],
      ),
    );
  }

  /// ✅ HEADER LIMPIO CON CONTADOR DINÁMICO
  Widget _buildCleanHeader() {
    final serviciosFiltrados = _getFilteredServices();
    final totalServicios = widget.serviciosDisponibles.length;

    String subtitle;
    if (_searchQuery.isNotEmpty || _selectedCategory != null) {
      subtitle =
          'Mostrando ${serviciosFiltrados.length} de $totalServicios servicios';
    } else if (widget.selectedEventData != null) {
      subtitle =
          '$totalServicios servicios en ${widget.selectedEventData!['nombre']}';
    } else {
      subtitle = '$totalServicios servicios disponibles';
    }

    return Column(
      children: [
        Text(
          'Selecciona tu servicio',
          style: TextStyle(
            fontSize: _getTitleFontSize(context),
            fontWeight: FontWeight.w700,
            color: widget.accentColor,
            fontFamily: kFontFamily,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: _getTextSpacing(context)),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: _getSubtitleFontSize(context),
            color: kTextSecondary,
            fontFamily: kFontFamily,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 🔍 BARRA DE BÚSQUEDA PREMIUM
  Widget _buildSearchBar() {
    return Container(
      height: _getSearchBarHeight(context),
      decoration: BoxDecoration(
        color: kBackgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(_getSearchRadius(context)),
        border: Border.all(
          color: kBorderSoft.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar servicios...',
          hintStyle: TextStyle(
            color: kTextMuted,
            fontSize: _getSearchFontSize(context),
            fontFamily: kFontFamily,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: kTextMuted,
            size: _getSearchIconSize(context),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: _getSearchPadding(context),
            vertical: _getSearchPadding(context) * 0.8,
          ),
        ),
        style: TextStyle(
          fontSize: _getSearchFontSize(context),
          fontFamily: kFontFamily,
        ),
      ),
    );
  }

  /// 🏷️ CATEGORÍAS RESPONSIVAS - ✅ NUEVO: GRID/WRAP SEGÚN PANTALLA
  Widget _buildResponsiveCategoryFilters() {
    final categorias = _getCategoriesFromServices();

    if (categorias.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ DECISIÓN UX: GRID PARA PANTALLAS PEQUEÑAS, WRAP PARA GRANDES
    if (screenWidth <= 375) {
      return _buildCategoryGrid(categorias);
    } else {
      return _buildCategoryWrap(categorias);
    }
  }

  /// 📱 GRID DE CATEGORÍAS PARA MÓVIL (iPhone SE/pequeño)
  Widget _buildCategoryGrid(List<String> categorias) {
    final crossAxisCount = _getCategoryGridColumns(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 3.5, // Ratio para botones rectangulares
        crossAxisSpacing: _getCategorySpacing(context),
        mainAxisSpacing: _getCategorySpacing(context),
      ),
      itemCount: categorias.length,
      itemBuilder: (context, index) {
        final categoria = categorias[index];
        return _buildCategoryChip(categoria);
      },
    );
  }

  /// 💻 WRAP DE CATEGORÍAS PARA PANTALLAS GRANDES
  Widget _buildCategoryWrap(List<String> categorias) {
    return Wrap(
      spacing: _getCategorySpacing(context),
      runSpacing: _getCategorySpacing(context),
      children:
          categorias.map((categoria) => _buildCategoryChip(categoria)).toList(),
    );
  }

  /// 🏷️ CHIP DE CATEGORÍA INDIVIDUAL
  Widget _buildCategoryChip(String categoria) {
    final isSelected = _selectedCategory == categoria;
    final serviciosEnCategoria = _getServicesInCategory(categoria);

    return GestureDetector(
      onTap: () {
        setState(() {
          // ✅ TOGGLE: Si ya está seleccionada, deseleccionar
          _selectedCategory = isSelected ? null : categoria;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: _getCategoryPadding(context),
          vertical: _getCategoryPadding(context) * 0.7,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    widget.accentColor,
                    widget.accentColor.withValues(alpha: 0.8)
                  ],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(_getCategoryRadius(context)),
          border: Border.all(
            color: isSelected
                ? widget.accentColor
                : kBorderSoft.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ NOMBRE DE CATEGORÍA
            Text(
              categoria,
              style: TextStyle(
                color: isSelected ? Colors.white : kTextSecondary,
                fontSize: _getCategoryFontSize(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontFamily: kFontFamily,
              ),
            ),

            // ✅ CONTADOR DE SERVICIOS
            if (serviciosEnCategoria > 0) ...[
              SizedBox(width: _getCategorySpacing(context) * 0.5),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _getCategorySpacing(context) * 0.6,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : kBorderSoft.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  serviciosEnCategoria.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : kTextMuted,
                    fontSize: _getCategoryFontSize(context) * 0.85,
                    fontWeight: FontWeight.w600,
                    fontFamily: kFontFamily,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 🛍️ LISTA DE SERVICIOS FILTRADA
  Widget _buildServicesList() {
    final serviciosFiltrados = _getFilteredServices();

    if (serviciosFiltrados.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: _getServicesListHeight(context),
      child: ListView.builder(
        itemCount: serviciosFiltrados.length,
        itemBuilder: (context, index) {
          final service = serviciosFiltrados[index];
          // ✅ FIX: Usar temporarySelectedServiceId para mostrar selección inmediata
          final isSelected =
              (_temporarySelectedServiceId ?? widget.selectedServiceId) ==
                  service['id'];

          return ServiceCardWidget(
            service: service,
            isSelected: isSelected,
            accentColor: widget.accentColor,
            showPricing: widget.showPricing,
            onTap: () => _handleServiceSelection(
                service['id']), // ✅ FIX: Usar nuevo método
          );
        },
      ),
    );
  }

  /// ❌ ESTADO VACÍO ELEGANTE
  Widget _buildEmptyState() {
    return Container(
      height: _getEmptyStateHeight(context),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: _getEmptyIconSize(context),
              height: _getEmptyIconSize(context),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius:
                    BorderRadius.circular(_getEmptyIconRadius(context)),
                border: Border.all(color: kBorderSoft, width: 2),
              ),
              child: Icon(
                Icons.search_off,
                size: _getEmptyIconSize(context) * 0.5,
                color: kTextMuted,
              ),
            ),
            SizedBox(height: _getContentSpacing(context)),
            Text(
              'No se encontraron servicios',
              style: TextStyle(
                fontSize: _getEmptyTitleSize(context),
                fontWeight: FontWeight.w600,
                color: kTextSecondary,
                fontFamily: kFontFamily,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _getEmptyStateMessage(),
              style: TextStyle(
                fontSize: _getEmptySubtitleSize(context),
                color: kTextMuted,
                fontFamily: kFontFamily,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // 🔧 MÉTODOS HELPER
  // ============================================================================

  /// 🏷️ OBTENER CATEGORÍAS SIN "TODAS"
  List<String> _getCategoriesFromServices() {
    final categorias = <String>[];

    for (final service in widget.serviciosDisponibles) {
      final categoria = service['category']?.toString() ?? 'General';
      if (!categorias.contains(categoria)) {
        categorias.add(categoria);
      }
    }

    // ✅ ORDENAR ALFABÉTICAMENTE PARA CONSISTENCIA
    categorias.sort();
    return categorias;
  }

  /// 📊 OBTENER CANTIDAD DE SERVICIOS EN CATEGORÍA
  int _getServicesInCategory(String categoria) {
    return widget.serviciosDisponibles
        .where((service) => service['category'] == categoria)
        .length;
  }

  /// 🔍 FILTRAR SERVICIOS
  List<Map<String, dynamic>> _getFilteredServices() {
    return widget.serviciosDisponibles.where((service) {
      // Filtro por búsqueda
      final name = service['name']?.toString().toLowerCase() ?? '';
      final category = service['category']?.toString().toLowerCase() ?? '';
      final searchMatch = _searchQuery.isEmpty ||
          name.contains(_searchQuery) ||
          category.contains(_searchQuery);

      // Filtro por categoría
      final categoryMatch =
          _selectedCategory == null || service['category'] == _selectedCategory;

      return searchMatch && categoryMatch;
    }).toList();
  }

  /// 📝 MENSAJE DE ESTADO VACÍO CONTEXTUAL
  String _getEmptyStateMessage() {
    if (_searchQuery.isNotEmpty && _selectedCategory != null) {
      return 'No hay servicios que coincidan con "$_searchQuery" en $_selectedCategory';
    } else if (_searchQuery.isNotEmpty) {
      return 'No hay servicios que coincidan con "$_searchQuery"';
    } else if (_selectedCategory != null) {
      return 'No hay servicios en la categoría $_selectedCategory';
    } else {
      return 'No hay servicios disponibles en este momento';
    }
  }

  // ============================================================================
  // 📐 SISTEMA RESPONSIVO INTELIGENTE
  // ============================================================================

  /// 📦 PADDING CONTENEDOR
  double _getContainerPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 16;
    if (width <= 375) return 20;
    if (width <= 768) return 24;
    return 32;
  }

  /// 📐 RADIO DE BORDES
  double _getBorderRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 16;
    if (width <= 768) return 20;
    return 24;
  }

  /// 📏 ESPACIADO SECCIONES
  double _getSectionSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 20;
    if (width <= 375) return 24;
    if (width <= 768) return 28;
    return 32;
  }

  /// 📏 ESPACIADO CONTENIDO
  double _getContentSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12;
    if (width <= 375) return 16;
    if (width <= 768) return 20;
    return 24;
  }

  /// 📝 FONT SIZE TÍTULO
  double _getTitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 20;
    if (width <= 375) return 22;
    if (width <= 768) return 24;
    return 28;
  }

  /// 📝 FONT SIZE SUBTITLE
  double _getSubtitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 13;
    if (width <= 375) return 14;
    if (width <= 768) return 15;
    return 16;
  }

  /// 📏 ESPACIADO TEXTO
  double _getTextSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 6;
    if (width <= 768) return 8;
    return 12;
  }

  /// 🔍 ALTURA BARRA BÚSQUEDA
  double _getSearchBarHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 40;
    if (width <= 375) return 44;
    if (width <= 768) return 48;
    return 52;
  }

  /// 🔍 RADIO BÚSQUEDA
  double _getSearchRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 10;
    if (width <= 768) return 12;
    return 14;
  }

  /// 🔍 FONT SIZE BÚSQUEDA
  double _getSearchFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 13;
    if (width <= 375) return 14;
    if (width <= 768) return 15;
    return 16;
  }

  /// 🔍 TAMAÑO ÍCONO BÚSQUEDA
  double _getSearchIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 18;
    if (width <= 768) return 20;
    return 22;
  }

  /// 🔍 PADDING BÚSQUEDA
  double _getSearchPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12;
    if (width <= 768) return 16;
    return 20;
  }

  /// 🏷️ COLUMNAS GRID CATEGORÍAS
  int _getCategoryGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 2; // iPhone SE: 2 columnas
    if (width <= 375) return 2; // iPhone pequeño: 2 columnas
    return 3; // Otros: 3 columnas
  }

  /// 🏷️ ESPACIADO CATEGORÍAS
  double _getCategorySpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 6;
    if (width <= 768) return 8;
    return 12;
  }

  /// 🏷️ PADDING CATEGORÍAS
  double _getCategoryPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 8;
    if (width <= 375) return 10;
    if (width <= 768) return 14;
    return 18;
  }

  /// 🏷️ RADIO CATEGORÍAS
  double _getCategoryRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12;
    if (width <= 768) return 14;
    return 16;
  }

  /// 🏷️ FONT SIZE CATEGORÍAS
  double _getCategoryFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 11;
    if (width <= 375) return 12;
    if (width <= 768) return 13;
    return 14;
  }

  /// ❌ TAMAÑO ÍCONO EMPTY STATE
  double _getEmptyIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 48;
    if (width <= 768) return 64;
    return 80;
  }

  /// ❌ RADIO ÍCONO EMPTY STATE
  double _getEmptyIconRadius(BuildContext context) {
    return _getEmptyIconSize(context) * 0.25;
  }

  /// ❌ FONT SIZE TÍTULO EMPTY
  double _getEmptyTitleSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 14;
    if (width <= 375) return 16;
    if (width <= 768) return 18;
    return 20;
  }

  /// ❌ FONT SIZE SUBTITLE EMPTY
  double _getEmptySubtitleSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12;
    if (width <= 375) return 13;
    if (width <= 768) return 14;
    return 15;
  }

  /// 🛍️ ALTURA LISTA DE SERVICIOS
  double _getServicesListHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 200;
    if (width <= 375) return 250;
    if (width <= 768) return 300;
    return 400;
  }

  /// ❌ ALTURA EMPTY STATE
  double _getEmptyStateHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 150;
    if (width <= 375) return 180;
    if (width <= 768) return 200;
    return 250;
  }
}
