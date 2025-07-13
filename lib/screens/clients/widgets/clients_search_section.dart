// [clients_search_section.dart] - SECCIÓN DE BÚSQUEDA Y TOOLBAR CON EXPORTACIÓN
// 📁 Ubicación: /lib/screens/clients/widgets/clients_search_section.dart
// 🎯 OBJETIVO: Widget para búsqueda + controles + view mode toggle + EXPORTACIÓN + IMPORTACIÓN MÍNIMA

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/enums/view_mode.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/clients_search_bar.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/view_mode_toggle.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/utils/client_constants.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/client_export_modal.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/import/client_import_modal.dart';

/// 🔍 SECCIÓN DE BÚSQUEDA - EXTRAÍDA DEL SCREEN PRINCIPAL CON EXPORTACIÓN
class ClientsSearchSection extends StatelessWidget {
  final TextEditingController searchController;
  final ViewMode currentViewMode;
  final bool isSearching;
  final String sortOption;
  final ClientFilterCriteria currentFilter;
  final List<ClientModel> allClients; // ✅ PARA EXPORTACIÓN
  final List<ClientModel> filteredClients; // ✅ PARA EXPORTACIÓN
  final Set<String> selectedClients; // ✅ PARA EXPORTACIÓN
  final String searchQuery; // ✅ PARA EXPORTACIÓN
  final Function(ViewMode) onViewModeChanged;
  final VoidCallback onClearSearch;
  final Function(String) onSort;
  final VoidCallback onToggleFilters;
  final Function(String) onAction;
  final VoidCallback? onExportCompleted; // ✅ CALLBACK DE EXPORTACIÓN
  final Animation<double> cardsAnimation;

  const ClientsSearchSection({
    super.key,
    required this.searchController,
    required this.currentViewMode,
    required this.isSearching,
    required this.sortOption,
    required this.currentFilter,
    required this.allClients, // ✅ REQUERIDO
    required this.filteredClients, // ✅ REQUERIDO
    required this.selectedClients, // ✅ REQUERIDO
    required this.searchQuery, // ✅ REQUERIDO
    required this.onViewModeChanged,
    required this.onClearSearch,
    required this.onSort,
    required this.onToggleFilters,
    required this.onAction,
    required this.cardsAnimation,
    this.onExportCompleted, // ✅ OPCIONAL
  });

  @override
  Widget build(BuildContext context) {
    return _buildSearchAndActions(context);
  }

  // ====================================================================
  // 🔍 SEARCH AND ACTIONS (CON EXPORTACIÓN INTEGRADA)
  // ====================================================================

  Widget _buildSearchAndActions(BuildContext context) {
    return AnimatedBuilder(
      animation: cardsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - cardsAnimation.value)),
          child: Opacity(
            opacity: cardsAnimation.value,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // VIEW MODE TOGGLE A LA IZQUIERDA
                      ViewModeToggle(
                        currentMode: currentViewMode,
                        onModeChanged: onViewModeChanged,
                        showLabels: MediaQuery.of(context).size.width > 1024,
                        isCompact: MediaQuery.of(context).size.width < 768,
                      ),

                      const SizedBox(width: 16),

                      // SEARCH BAR (FLEX 5)
                      Expanded(
                        flex: 5,
                        child: ClientsSearchBar(
                          controller: searchController,
                          isSearching: isSearching,
                          onClear: onClearSearch,
                          hintText:
                              'Buscar clientes por nombre, email, teléfono...',
                        ),
                      ),

                      const SizedBox(width: 16),

                      // BOTONES DE ACCIÓN CON EXPORTACIÓN
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSortButton(context),
                          const SizedBox(width: 12),
                          _buildFiltersButton(context),
                          const SizedBox(width: 12),
                          _buildImportButton(context), // 🆕 NUEVO BOTÓN
                          const SizedBox(width: 12),
                          _buildExportButton(context), // ✅ TU BOTÓN ORIGINAL
                        ],
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

  // ====================================================================
  // 🆕 BOTÓN DE IMPORTACIÓN - AGREGADO QUIRÚRGICAMENTE
  // ====================================================================

  Widget _buildImportButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kAccentGreen,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: kAccentGreen.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleImportAction(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.upload_file, size: 18, color: Colors.white),
                SizedBox(width: 6),
                Text('Importar',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleImportAction(BuildContext context) async {
    try {
      final result = await showClientImportModal(context);
      if (result != null && result.isSuccess) {
        // Manejar resultado exitoso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.successfulRows} clientes importados'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Manejar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en importación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // ====================================================================
  // 🆕 BOTÓN DE EXPORTACIÓN PRINCIPAL - TU FUNCIONALIDAD ORIGINAL
  // ====================================================================

  Widget _buildExportButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderSoft),
        boxShadow: kSombraCard,
      ),
      child: PopupMenuButton<String>(
        onSelected: (value) => _handleExportAction(context, value),
        tooltip: 'Opciones de exportación',
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'export_all',
            child: ListTile(
              leading: Icon(Icons.select_all, color: kAccentGreen),
              title: const Text('Exportar Todo'),
              subtitle: Text('${filteredClients.length} clientes'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (selectedClients.isNotEmpty)
            PopupMenuItem(
              value: 'export_selected',
              child: ListTile(
                leading: Icon(Icons.checklist, color: kBrandPurple),
                title: const Text('Exportar Seleccionados'),
                subtitle: Text('${selectedClients.length} clientes'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'quick_csv',
            child: ListTile(
              leading: Icon(Icons.table_chart, color: kAccentBlue),
              title: const Text('CSV Rápido'),
              subtitle: const Text('Campos principales'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_outlined, size: 20, color: kTextSecondary),
              const SizedBox(width: 8),
              Text(
                'Exportar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, size: 16, color: kTextSecondary),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // 🎯 HANDLERS DE EXPORTACIÓN - TU FUNCIONALIDAD ORIGINAL
  // ====================================================================

  Future<void> _handleExportAction(BuildContext context, String action) async {
    List<ClientModel> clientsToExport;
    String title;
    bool isSelectionMode = false;

    switch (action) {
      case 'export_all':
        clientsToExport = filteredClients;
        title = 'Exportar ${filteredClients.length} Clientes';
        break;
      case 'export_selected':
        clientsToExport = filteredClients
            .where((client) => selectedClients.contains(client.clientId))
            .toList();
        title = 'Exportar ${clientsToExport.length} Clientes Seleccionados';
        isSelectionMode = true;
        break;
      case 'quick_csv':
        clientsToExport = filteredClients;
        title = 'Exportación Rápida CSV';
        break;
      default:
        return;
    }

    if (clientsToExport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay clientes para exportar'),
          backgroundColor: kErrorColor,
        ),
      );
      return;
    }

    // Mostrar modal de exportación
    final result = await showClientExportModal(
      context,
      clients: clientsToExport,
      title: title,
      isSelectionMode: isSelectionMode,
      preSelectedFields: action == 'quick_csv'
          ? ['fullName', 'email', 'phone', 'status']
          : null,
    );

    if (result != null && result.isSuccess) {
      onExportCompleted?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Exportado: ${result.fileName} (${result.formattedSize})',
                ),
              ),
            ],
          ),
          backgroundColor: kAccentGreen,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Ver',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Abrir carpeta de descargas
            },
          ),
        ),
      );
    }
  }

  // ====================================================================
  // 🔧 BOTONES DE CONTROL EXISTENTES - MANTENIDOS
  // ====================================================================

  Widget _buildSortButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderSoft),
        boxShadow: kSombraCard,
      ),
      child: PopupMenuButton<String>(
        onSelected: onSort,
        itemBuilder: (context) => ClientConstants.SORT_OPTIONS
            .map((option) => PopupMenuItem(
                  value: option,
                  child: Text(option),
                ))
            .toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sort, size: 20, color: kTextSecondary),
              const SizedBox(width: 8),
              Text(
                'Ordenar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersButton(BuildContext context) {
    final hasActiveFilters = !currentFilter.isEmpty;

    return Container(
      decoration: BoxDecoration(
        color: hasActiveFilters
            ? kBrandPurple.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasActiveFilters ? kBrandPurple : kBorderSoft,
        ),
        boxShadow: kSombraCard,
      ),
      child: InkWell(
        onTap: onToggleFilters,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.filter_list,
                size: 20,
                color: hasActiveFilters ? kBrandPurple : kTextSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: hasActiveFilters ? kBrandPurple : kTextSecondary,
                ),
              ),
              if (hasActiveFilters) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: kBrandPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getActiveFiltersCount().toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // 🔧 MÉTODOS HELPER EXISTENTES - MANTENIDOS
  // ====================================================================

  int _getActiveFiltersCount() {
    int count = 0;
    if (currentFilter.statuses.isNotEmpty) count++;
    if (currentFilter.tags.isNotEmpty) count++;
    if (currentFilter.dateRange != null) count++;
    if (currentFilter.alcaldias.isNotEmpty) count++;
    if (currentFilter.minAppointments != null) count++;
    return count;
  }
}
