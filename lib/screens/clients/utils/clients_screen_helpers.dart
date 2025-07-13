// [clients_screen_helpers.dart] - UTILIDADES Y HELPERS
// 📁 Ubicación: /lib/screens/clients/utils/clients_screen_helpers.dart
// 🎯 OBJETIVO: Métodos helper extraídos del screen principal

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/client_card_factory.dart';
import 'package:agenda_fisio_spa_kym/enums/view_mode.dart';

/// 🛠️ HELPERS ESTÁTICOS - EXTRAÍDOS DEL SCREEN PRINCIPAL
class ClientsScreenHelpers {
  
  // ====================================================================
  // 🏷️ MÉTODOS DE TAGS (COPIADO EXACTO)
  // ====================================================================

  static List<String> getAvailableTags(List<ClientModel> clients) {
    final tags = <String>{};
    for (final client in clients) {
      for (final tag in client.tags) {
        tags.add(tag.label);
      }
    }
    return tags.toList()..sort();
  }

  static List<String> getAvailableAlcaldias(List<ClientModel> clients) {
    final alcaldias = <String>{};
    for (final client in clients) {
      final alcaldia = client.addressInfo.alcaldia;
      if (alcaldia.isNotEmpty) {
        alcaldias.add(alcaldia);
      }
    }
    return alcaldias.toList()..sort();
  }

  // ====================================================================
  // 🔢 MÉTODOS DE CONTEO (COPIADO EXACTO)
  // ====================================================================

  static int getActiveFiltersCount(ClientFilterCriteria filter) {
    int count = 0;
    if (filter.statuses.isNotEmpty) count++;
    if (filter.tags.isNotEmpty) count++;
    if (filter.dateRange != null) count++;
    if (filter.alcaldias.isNotEmpty) count++;
    if (filter.minAppointments != null) count++;
    return count;
  }

  static int getSelectedClientsCount(Set<String> selectedClients) {
    return selectedClients.length;
  }

  static bool hasActiveFilters(ClientFilterCriteria filter) {
    return !filter.isEmpty;
  }

  // ====================================================================
  // 📊 MÉTODOS DE ANALYTICS Y DEBUG (COPIADO EXACTO)
  // ====================================================================

  static void logViewModeStats(
    BuildContext context,
    ViewMode currentViewMode,
    List<ClientModel> displayedClients,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final expectedClients = currentViewMode.getExpectedClientsPerScreen(screenHeight);
    final factoryReport = ClientCardFactory.getPerformanceReport();

    debugPrint('📊 ViewMode Stats:');
    debugPrint('   Current mode: ${currentViewMode.displayName}');
    debugPrint('   Expected clients per screen: $expectedClients');
    debugPrint('   Actual clients showing: ${displayedClients.length}');
    debugPrint('   Factory performance: $factoryReport');
  }

  static Map<String, dynamic> getPerformanceMetrics(
    List<ClientModel> allClients,
    List<ClientModel> filteredClients,
    List<ClientModel> displayedClients,
    Set<String> selectedClients,
  ) {
    return {
      'total_clients': allClients.length,
      'filtered_clients': filteredClients.length,
      'displayed_clients': displayedClients.length,
      'selected_clients': selectedClients.length,
      'filter_efficiency': filteredClients.length / allClients.length,
      'selection_rate': selectedClients.length / filteredClients.length,
      'memory_usage': _calculateMemoryUsage(allClients),
    };
  }

  static double _calculateMemoryUsage(List<ClientModel> clients) {
    // Estimación simple de uso de memoria
    const bytesPerClient = 2048; // Estimación
    return (clients.length * bytesPerClient) / 1024 / 1024; // MB
  }

  // ====================================================================
  // 🔍 MÉTODOS DE BÚSQUEDA Y FILTROS (COPIADO EXACTO)
  // ====================================================================

  static List<ClientModel> applySearchFilter(
    List<ClientModel> clients,
    String query,
  ) {
    if (query.isEmpty) return clients;
    return clients.search(query);
  }

  static List<ClientModel> applyCriteriaFilter(
    List<ClientModel> clients,
    ClientFilterCriteria criteria,
  ) {
    if (criteria.isEmpty) return clients;
    return clients.filterByCriteria(criteria);
  }

  static List<ClientModel> applySort(
    List<ClientModel> clients,
    String sortOption,
  ) {
    switch (sortOption) {
      case 'Nombre A-Z':
        return clients.sortByName();
      case 'Nombre Z-A':
        final sorted = clients.sortByName();
        return sorted.reversed.toList();
      case 'Fecha creación (reciente)':
        return clients.sortByCreatedDate();
      case 'Fecha creación (antigua)':
        final sorted = clients.sortByCreatedDate();
        return sorted.reversed.toList();
      case 'Citas (más)':
        return clients.sortByAppointments();
      case 'Citas (menos)':
        final sorted = clients.sortByAppointments();
        return sorted.reversed.toList();
      case 'Satisfacción (mayor)':
        return clients.sortBySatisfaction();
      case 'Satisfacción (menor)':
        final sorted = clients.sortBySatisfaction();
        return sorted.reversed.toList();
      default:
        return clients;
    }
  }

  // ====================================================================
  // 🎨 MÉTODOS DE UI HELPERS (COPIADO EXACTO)
  // ====================================================================

  static EdgeInsets getListPadding(ViewMode viewMode) {
    switch (viewMode) {
      case ViewMode.compact:
        return const EdgeInsets.fromLTRB(20, 20, 20, 20);
      case ViewMode.comfortable:
        return const EdgeInsets.fromLTRB(20, 30, 20, 20);
      case ViewMode.table:
        return const EdgeInsets.fromLTRB(20, 10, 20, 20);
    }
  }

  static double getConstraintWidth(ViewMode viewMode) {
    switch (viewMode) {
      case ViewMode.compact:
      case ViewMode.comfortable:
        return 800;
      case ViewMode.table:
        return 1200;
    }
  }

  static Color getViewModeColor(ViewMode viewMode) {
    return viewMode.themeColor;
  }

  // ====================================================================
  // 📱 MÉTODOS DE RESPONSIVE DESIGN (COPIADO EXACTO)
  // ====================================================================

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > 1024;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 768 && width <= 1024;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 768;
  }

  static int getColumnsForWidth(double width) {
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  // ====================================================================
  // 🎯 MÉTODOS DE VALIDACIÓN (COPIADO EXACTO)
  // ====================================================================

  static bool canPerformBulkOperation(int selectedCount, int maxOperations) {
    return selectedCount > 0 && selectedCount <= maxOperations;
  }

  static bool canExportClients(int clientCount, int maxExports) {
    return clientCount > 0 && clientCount <= maxExports;
  }

  static String? validateSearchQuery(String query) {
    if (query.length < 2 && query.isNotEmpty) {
      return 'Mínimo 2 caracteres para buscar';
    }
    return null;
  }

  // ====================================================================
  // 📊 MÉTODOS DE FORMATEO (COPIADO EXACTO)
  // ====================================================================

  static String formatClientCount(int count) {
    if (count == 0) return 'Sin clientes';
    if (count == 1) return '1 cliente';
    return '$count clientes';
  }

  static String formatSelectionCount(int selected, int total) {
    if (selected == 0) return 'Ninguno seleccionado';
    if (selected == total && total > 0) return 'Todos seleccionados';
    return '$selected de $total seleccionados';
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  // ====================================================================
  // 🔧 MÉTODOS DE ESTADO (COPIADO EXACTO)
  // ====================================================================

  static bool hasUnsavedChanges(
    List<ClientModel> originalClients,
    List<ClientModel> currentClients,
  ) {
    if (originalClients.length != currentClients.length) return true;
    
    for (int i = 0; i < originalClients.length; i++) {
      if (originalClients[i] != currentClients[i]) return true;
    }
    
    return false;
  }

  static bool shouldShowBulkToolbar(Set<String> selectedClients) {
    return selectedClients.isNotEmpty;
  }

  static bool shouldShowEmptyState(List<ClientModel> clients, bool isLoading) {
    return clients.isEmpty && !isLoading;
  }

  // ====================================================================
  // 🚀 MÉTODOS DE PERFORMANCE (COPIADO EXACTO)
  // ====================================================================

  static void clearCaches() {
    ClientCardFactory.clearCache();
  }

  static Map<String, dynamic> getMemoryReport(List<ClientModel> clients) {
    final memoryUsage = _calculateMemoryUsage(clients);
    return {
      'clients_count': clients.length,
      'estimated_memory_mb': memoryUsage,
      'memory_per_client_kb': (memoryUsage * 1024) / clients.length,
      'cache_status': ClientCardFactory.getPerformanceReport(),
    };
  }
}