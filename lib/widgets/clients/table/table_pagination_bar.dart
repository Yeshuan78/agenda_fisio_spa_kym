// ✅ NUEVO WIDGET: TablePaginationBar
// 📁 Ubicación: /lib/widgets/clients/table/table_pagination_bar.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class TablePaginationBar extends StatelessWidget {
  final int currentPage;           // Página actual (0-based)
  final int totalItems;            // Total de registros
  final int itemsPerPage;          // Registros por página
  final Function(int) onPageChanged;
  final Function(int) onPageSizeChanged;
  
  // Opciones de tamaño de página
  static const List<int> pageSizeOptions = [20, 50, 100];

  const TablePaginationBar({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalItems / itemsPerPage).ceil();
    final startItem = (currentPage * itemsPerPage) + 1;
    final endItem = ((currentPage + 1) * itemsPerPage).clamp(0, totalItems);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: kBorderSoft, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ INFO DE REGISTROS (LEFT)
          _buildItemsInfo(startItem, endItem),
          
          const Spacer(),
          
          // ✅ PAGINADOR (CENTER)
          if (totalPages > 1) _buildPagination(totalPages),
          
          const SizedBox(width: 20),
          
          // ✅ SELECTOR DE TAMAÑO (RIGHT)
          _buildPageSizeSelector(),
        ],
      ),
    );
  }

  Widget _buildItemsInfo(int startItem, int endItem) {
    return Text(
      'Mostrando $startItem-$endItem de $totalItems registros',
      style: const TextStyle(
        fontSize: 14,
        color: kTextSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ BOTÓN ANTERIOR
        _buildPageButton(
          icon: Icons.chevron_left,
          enabled: currentPage > 0,
          onTap: () => onPageChanged(currentPage - 1),
        ),
        
        const SizedBox(width: 8),
        
        // ✅ NÚMEROS DE PÁGINA
        ..._buildPageNumbers(totalPages),
        
        const SizedBox(width: 8),
        
        // ✅ BOTÓN SIGUIENTE
        _buildPageButton(
          icon: Icons.chevron_right,
          enabled: currentPage < totalPages - 1,
          onTap: () => onPageChanged(currentPage + 1),
        ),
      ],
    );
  }

  List<Widget> _buildPageNumbers(int totalPages) {
    final List<Widget> pages = [];
    
    // ✅ LÓGICA INTELIGENTE DE PÁGINAS (TIPO NOTION)
    if (totalPages <= 7) {
      // Mostrar todas las páginas si son pocas
      for (int i = 0; i < totalPages; i++) {
        pages.add(_buildPageNumber(i));
        if (i < totalPages - 1) pages.add(const SizedBox(width: 4));
      }
    } else {
      // Mostrar páginas con ellipsis
      pages.add(_buildPageNumber(0)); // Primera página
      
      if (currentPage > 2) {
        pages.add(const SizedBox(width: 4));
        pages.add(_buildEllipsis());
      }
      
      // Páginas alrededor de la actual
      final start = (currentPage - 1).clamp(1, totalPages - 2);
      final end = (currentPage + 1).clamp(1, totalPages - 2);
      
      for (int i = start; i <= end; i++) {
        pages.add(const SizedBox(width: 4));
        pages.add(_buildPageNumber(i));
      }
      
      if (currentPage < totalPages - 3) {
        pages.add(const SizedBox(width: 4));
        pages.add(_buildEllipsis());
      }
      
      pages.add(const SizedBox(width: 4));
      pages.add(_buildPageNumber(totalPages - 1)); // Última página
    }
    
    return pages;
  }

  Widget _buildPageNumber(int pageIndex) {
    final isActive = pageIndex == currentPage;
    
    return GestureDetector(
      onTap: () => onPageChanged(pageIndex),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? kBrandPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? kBrandPurple : kBorderSoft,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            '${pageIndex + 1}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : kTextSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : kBackgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: enabled ? kBorderSoft : kTextMuted.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? kTextSecondary : kTextMuted,
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      width: 32,
      height: 32,
      child: const Center(
        child: Text(
          '...',
          style: TextStyle(
            fontSize: 13,
            color: kTextMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPageSizeSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Mostrar',
          style: TextStyle(
            fontSize: 14,
            color: kTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kBorderSoft, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: itemsPerPage,
              items: pageSizeOptions.map((size) {
                return DropdownMenuItem<int>(
                  value: size,
                  child: Text(
                    '$size',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newSize) {
                if (newSize != null) {
                  onPageSizeChanged(newSize);
                }
              },
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: kTextMuted,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'por página',
          style: TextStyle(
            fontSize: 14,
            color: kTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}