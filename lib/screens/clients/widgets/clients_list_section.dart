// [clients_list_section.dart] - ✅ FIX: PAGINACIÓN CENTRADA COMO LA TABLA
// 📁 Ubicación: /lib/screens/clients/widgets/clients_list_section.dart
// 🎯 OBJETIVO: Centrar la barra de paginación con el mismo ancho que la tabla

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/enums/view_mode.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/client_card_factory.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/clients_bulk_toolbar.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/controllers/clients_screen_controller.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

/// 📋 SECCIÓN DE LISTA - ✅ PAGINACIÓN CENTRADA
class ClientsListSection extends StatelessWidget {
  final List<ClientModel> clients;
  final List<ClientModel>? allClients;
  final List<ClientModel>? filteredClients;
  final Set<String> selectedClients;
  final int totalFilteredClients;
  final ViewMode currentViewMode;
  final String? tableSortColumn;
  final bool tableSortAscending;
  final Function(String) onClientSelect;
  final Function(ClientModel) onClientEdit;
  final Function(String) onClientDelete;
  final Function(ClientModel) onClientPreview;
  final Function(String) onTableSort;
  final Function(List<String>) onBulkDelete;
  final Function(List<String>, List<ClientTag>) onBulkAddTags;
  final Function(List<String>) onBulkExport;
  final VoidCallback onClearSelection;
  final VoidCallback onSelectCurrentPage;
  final Animation<double> cardsAnimation;
  final Animation<double> viewModeTransition;
  final ClientsScreenController? screenController;

  static int _paginationDisplayLogCount = 0;
  static const int _maxDisplayLogs = 2;

  const ClientsListSection({
    super.key,
    required this.clients,
    this.allClients,
    this.filteredClients,
    required this.selectedClients,
    required this.totalFilteredClients,
    required this.currentViewMode,
    required this.tableSortColumn,
    required this.tableSortAscending,
    required this.onClientSelect,
    required this.onClientEdit,
    required this.onClientDelete,
    required this.onClientPreview,
    required this.onTableSort,
    required this.onBulkDelete,
    required this.onBulkAddTags,
    required this.onBulkExport,
    required this.onClearSelection,
    required this.onSelectCurrentPage,
    required this.cardsAnimation,
    required this.viewModeTransition,
    this.screenController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ BULK TOOLBAR
        _buildBulkToolbar(),

        // ✅ CLIENTS LIST CON PAGINACIÓN REAL
        _buildClientsList(),
      ],
    );
  }

  // ====================================================================
  // 🔧 BULK TOOLBAR
  // ====================================================================

  Widget _buildBulkToolbar() {
    return ClientsBulkToolbar(
      selectedClients: selectedClients,
      allClients: allClients ?? clients,
      filteredClients: filteredClients ?? clients,
      currentPageClients: clients,
      totalFilteredClients: totalFilteredClients,
      onSelectCurrentPage: onSelectCurrentPage,
      onClearSelection: onClearSelection,
      onBulkDelete: onBulkDelete,
      onBulkAddTags: onBulkAddTags,
      onBulkExport: onBulkExport,
      onExportCompleted: () {
        if (kDebugMode) {
          debugPrint('✅ LIST_SECTION: Exportación completada');
        }
      },
    );
  }

  // ====================================================================
  // 📋 CLIENTS LIST - ✅ CON PAGINACIÓN CENTRADA
  // ====================================================================

  Widget _buildClientsList() {
    if (screenController != null) {
      return _buildPaginatedView();
    }
    return _buildNormalView();
  }

  /// ✅ VISTA PAGINADA CON PAGINACIÓN CENTRADA
  Widget _buildPaginatedView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ HEADER DE TABLA
        if (currentViewMode == ViewMode.table) _buildTableHeaderIfNeeded(),

        // ✅ CONTENIDO PAGINADO
        _buildPaginatedContent(),

        // ✅ BARRA DE PAGINACIÓN CENTRADA
        _buildCenteredPaginationBar(),
      ],
    );
  }

  /// ✅ CONTENIDO PAGINADO
  Widget _buildPaginatedContent() {
    return AnimatedBuilder(
      animation: cardsAnimation,
      builder: (context, child) {
        final paginatedClients = clients;

        if (paginatedClients.isNotEmpty &&
            _paginationDisplayLogCount < _maxDisplayLogs) {
          debugPrint(
              '📄 Mostrando ${paginatedClients.length} clientes de la página ${screenController!.currentPage + 1}');
          _paginationDisplayLogCount++;
        } else if (_paginationDisplayLogCount == _maxDisplayLogs) {
          if (kDebugMode) {
            debugPrint('📄 Logs de display adicionales silenciados...');
          }
          _paginationDisplayLogCount++;
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: paginatedClients.asMap().entries.map((entry) {
              final index = entry.key;
              final client = entry.value;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: currentViewMode == ViewMode.table ? 1200 : 800,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: AnimatedBuilder(
                      animation: viewModeTransition,
                      builder: (context, child) {
                        return Opacity(
                          opacity: viewModeTransition.value,
                          child: Transform.translate(
                            offset:
                                Offset(0, 20 * (1 - viewModeTransition.value)),
                            child: _buildClientCard(client, index),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// ✅ FIX CRÍTICO: BARRA DE PAGINACIÓN CENTRADA
  Widget _buildCenteredPaginationBar() {
    if (screenController == null) return const SizedBox.shrink();

    final info = screenController!.getPaginationInfo();
    final totalPages = info['totalPages'] as int;

    if (totalPages <= 1) return const SizedBox.shrink();

    // ✅ FIX: CENTRAR CON EL MISMO ANCHO QUE LA TABLA
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: currentViewMode == ViewMode.table ? 1200 : 800,
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderSoft, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // ✅ INFO DE REGISTROS
              Text(
                'Mostrando ${info['startItem']}-${info['endItem']} de ${info['totalItems']} registros',
                style: const TextStyle(
                  fontSize: 14,
                  color: kTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // ✅ CONTROLES DE PAGINACIÓN
              _buildPaginationControls(info),

              const SizedBox(width: 20),

              // ✅ SELECTOR DE TAMAÑO
              _buildPageSizeSelector(),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ VISTA NORMAL (FALLBACK SIN PAGINACIÓN)
  Widget _buildNormalView() {
    return AnimatedBuilder(
      animation: cardsAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentViewMode == ViewMode.table)
                _buildTableHeaderIfNeeded(),
              ...clients.asMap().entries.map((entry) {
                final index = entry.key;
                final client = entry.value;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: currentViewMode == ViewMode.table ? 1200 : 800,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: AnimatedBuilder(
                        animation: viewModeTransition,
                        builder: (context, child) {
                          return Opacity(
                            opacity: viewModeTransition.value,
                            child: Transform.translate(
                              offset: Offset(
                                  0, 20 * (1 - viewModeTransition.value)),
                              child: _buildClientCard(client, index),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  /// ✅ CONTROLES DE PAGINACIÓN
  Widget _buildPaginationControls(Map<String, dynamic> info) {
    final currentPage = info['currentPage'] as int;
    final totalPages = info['totalPages'] as int;
    final hasPrevious = info['hasPreviousPage'] as bool;
    final hasNext = info['hasNextPage'] as bool;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ BOTÓN ANTERIOR
        _buildPageButton(
          icon: Icons.chevron_left,
          enabled: hasPrevious,
          onTap: () {
            if (kDebugMode) {
              debugPrint(
                  '🔙 NAVEGACIÓN: Clic en ANTERIOR (página actual: $currentPage)');
            }
            screenController!.previousPage();
          },
        ),

        const SizedBox(width: 8),

        // ✅ NÚMEROS DE PÁGINA
        ..._buildPageNumbers(currentPage, totalPages),

        const SizedBox(width: 8),

        // ✅ BOTÓN SIGUIENTE
        _buildPageButton(
          icon: Icons.chevron_right,
          enabled: hasNext,
          onTap: () {
            if (kDebugMode) {
              debugPrint(
                  '🔜 NAVEGACIÓN: Clic en SIGUIENTE (página actual: $currentPage)');
            }
            screenController!.nextPage();
          },
        ),
      ],
    );
  }

  /// ✅ NÚMEROS DE PÁGINA
  List<Widget> _buildPageNumbers(int currentPage, int totalPages) {
    final List<Widget> pages = [];

    if (totalPages <= 7) {
      // Mostrar todas las páginas
      for (int i = 1; i <= totalPages; i++) {
        pages.add(_buildPageNumber(i, currentPage));
        if (i < totalPages) pages.add(const SizedBox(width: 4));
      }
    } else {
      // Mostrar páginas con ellipsis
      pages.add(_buildPageNumber(1, currentPage));

      if (currentPage > 3) {
        pages.add(const SizedBox(width: 4));
        pages.add(_buildEllipsis());
      }

      final start = (currentPage - 1).clamp(2, totalPages - 1);
      final end = (currentPage + 1).clamp(2, totalPages - 1);

      for (int i = start; i <= end; i++) {
        pages.add(const SizedBox(width: 4));
        pages.add(_buildPageNumber(i, currentPage));
      }

      if (currentPage < totalPages - 2) {
        pages.add(const SizedBox(width: 4));
        pages.add(_buildEllipsis());
      }

      pages.add(const SizedBox(width: 4));
      pages.add(_buildPageNumber(totalPages, currentPage));
    }

    return pages;
  }

  /// ✅ BOTÓN DE PÁGINA
  Widget _buildPageNumber(int pageNumber, int currentPage) {
    final isActive = pageNumber == currentPage;

    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          debugPrint(
              '🔢 NAVEGACIÓN: Clic en página $pageNumber (actual: $currentPage)');
        }
        screenController!.setPage(pageNumber - 1);
      },
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
            '$pageNumber',
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

  /// ✅ BOTÓN DE NAVEGACIÓN
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
            color: enabled
                ? kBorderSoft
                : kTextMuted.withAlpha((0.3 * 255).round()),
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

  /// ✅ ELLIPSIS
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

  /// ✅ SELECTOR DE TAMAÑO DE PÁGINA
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
              value: screenController!.itemsPerPage,
              items: screenController!.availablePageSizes.map((size) {
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
                  if (kDebugMode) {
                    debugPrint(
                        '📊 NAVEGACIÓN: Cambiando tamaño de página a $newSize');
                  }
                  screenController!.setPageSize(newSize);
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

  // ====================================================================
  // 🎯 HELPERS
  // ====================================================================

  Widget _buildTableHeaderIfNeeded() {
    if (currentViewMode != ViewMode.table) {
      return const SizedBox.shrink();
    }

    return ClientCardFactory.buildTableHeader(
      showSortIndicators: true,
      sortColumn: tableSortColumn,
      sortAscending: tableSortAscending,
      onSort: onTableSort,
    );
  }

  Widget _buildClientCard(ClientModel client, int index) {
    final isSelected = selectedClients.contains(client.clientId);

    Map<String, dynamic>? additionalParams;
    if (currentViewMode == ViewMode.table) {
      additionalParams = {
        'isEvenRow': index % 2 == 0,
      };
    }

    return ClientCardFactory.buildCard(
      viewMode: currentViewMode,
      client: client,
      isSelected: isSelected,
      onSelect: () => onClientSelect(client.clientId),
      onEdit: () => onClientEdit(client),
      onDelete: () => onClientDelete(client.clientId),
      onQuickPreview: () => onClientPreview(client),
      enableCache: true,
      enableHoverEffects: currentViewMode != ViewMode.table,
      additionalParams: additionalParams,
    );
  }
}
