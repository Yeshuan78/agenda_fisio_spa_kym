// [eventos_filters_section.dart] - EXTRACCIÓN QUIRÚRGICA EXACTA
// 📁 Ubicación: /lib/widgets/eventos/components/eventos_filters_section.dart
// 🎯 COPY-PASTE EXACTO de líneas 380-450 eventos_screen.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class EventosFiltersSection extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged;
  final List<String> availableFilters;
  final Animation<double> headerAnimation;

  const EventosFiltersSection({
    super.key,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.availableFilters,
    required this.headerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - headerAnimation.value)),
          child: Opacity(
            opacity: headerAnimation.value,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: kBrandPurple.withValues(alpha: 0.01),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Barra de búsqueda elegante
                      Container(
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kBorderColor.withValues(alpha: 0.05)),
                        ),
                        child: TextField(
                          onChanged: onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Buscar eventos, empresas...',
                            prefixIcon: Icon(Icons.search_rounded, color: kBrandPurple),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear_rounded, color: Colors.grey[400]),
                                    onPressed: () => onSearchChanged(''),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Filtros por estado
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: availableFilters.map((filter) => _buildFilterChip(filter)).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = selectedFilter == filter;
    final displayText = filter == 'Todos' ? filter : filter.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(displayText),
        selected: isSelected,
        onSelected: (selected) => onFilterChanged(filter),
        backgroundColor: Colors.transparent,
        selectedColor: kBrandPurple.withValues(alpha: 0.01),
        checkmarkColor: kBrandPurple,
        side: BorderSide(
          color: isSelected ? kBrandPurple : kBorderColor,
          width: isSelected ? 2 : 1,
        ),
        labelStyle: TextStyle(
          color: isSelected ? kBrandPurple : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}