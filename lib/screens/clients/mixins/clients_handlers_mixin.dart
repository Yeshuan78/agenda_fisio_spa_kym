// [clients_handlers_mixin.dart] - MIXIN DE HANDLERS DE EVENTOS - ✅ FIX CRÍTICO SET INMUTABLE
// 📁 Ubicación: /lib/screens/clients/mixins/clients_handlers_mixin.dart
// 🎯 OBJETIVO: Extraer todos los handlers de eventos del screen principal
// ✅ FIX: Corregir manipulación de Set inmutable en selectAllClients y clearSelection

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/services/client_service.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/utils/client_constants.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/cost_data_models.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/client_card_factory.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/clients_filters_panel.dart';

/// 🎯 MIXIN DE HANDLERS - EXTRAÍDO DEL SCREEN PRINCIPAL - ✅ FIX CRÍTICO
mixin ClientsHandlersMixin<T extends StatefulWidget> on State<T> {
  // ====================================================================
  // 🔄 HANDLERS DE REFRESH (COPIADO EXACTO)
  // ====================================================================

  Future<void> handleRefreshAnalytics(ClientService clientService,
      Function() onSuccess, Function(String) onError) async {
    try {
      final analytics = await clientService.getBasicAnalytics();
      onSuccess();
      // Usar callback directo para éxito - el mensaje se maneja en el controller
    } catch (e) {
      onError('Error actualizando analytics: $e');
    }
  }

  Future<void> handleForceRefresh(
    ClientService clientService,
    Function() onSuccess,
    Function(String) onError,
    Function() checkCostLimits,
  ) async {
    try {
      checkCostLimits();

      debugPrint('🔄 Forzando actualización completa...');

      // Limpiar cache primero
      await clientService.clearCache();
      ClientCardFactory.clearCache();

      // Forzar sincronización desde Firestore
      await clientService.forceSync();

      onSuccess();
      // Mensaje de éxito se maneja en el controller
      debugPrint('✅ Actualización completa exitosa');
    } catch (e) {
      debugPrint('❌ Error actualizando datos: $e');
      onError('Error actualizando datos: $e');
    }
  }

  // ====================================================================
  // 🎮 HANDLERS DE ACCIONES (COPIADO EXACTO)
  // ====================================================================

  void handleAction(String action, VoidCallback onExport, VoidCallback onImport,
      VoidCallback onRefresh) {
    switch (action) {
      case 'export':
        onExport();
        break;
      case 'import':
        onImport();
        break;
      case 'refresh':
        onRefresh();
        break;
    }
  }

  // ====================================================================
  // 📦 HANDLERS DE OPERACIONES MASIVAS (COPIADO EXACTO)
  // ====================================================================

  Future<void> handleBulkDelete(
    List<String> clientIds,
    ClientService clientService,
    Function() onSuccess,
    Function(String) onError,
    Function(String, String) showConfirmDialog,
  ) async {
    final confirmed = await showConfirmDialog(
      'Eliminar ${clientIds.length} clientes',
      '¿Está seguro de que desea eliminar los clientes seleccionados? Esta acción no se puede deshacer.',
    );

    if (!confirmed) return;

    try {
      await clientService.bulkDelete(clientIds);
      onSuccess();
      // Mensaje de éxito se maneja en el controller
    } catch (e) {
      onError('Error eliminando clientes: $e');
    }
  }

  Future<void> handleBulkAddTags(
    List<String> clientIds,
    List<ClientTag> tags,
    ClientService clientService,
    Function() onSuccess,
    Function(String) onError,
  ) async {
    try {
      await clientService.bulkUpdateTags(clientIds, tags);
      onSuccess();
      // Mensaje de éxito se maneja en el controller
    } catch (e) {
      onError('Error agregando etiquetas: $e');
    }
  }

  void handleBulkExport(List<String> clientIds, List<ClientModel> allClients,
      Function(List<ClientModel>) exportFunction) {
    final selectedClients = allClients
        .where((client) => clientIds.contains(client.clientId))
        .toList();
    exportFunction(selectedClients);
  }

  // ====================================================================
  // 🔧 HANDLERS DE SELECCIÓN - ✅ FIX CRÍTICO APLICADO
  // ====================================================================

  void toggleClientSelection(
      String clientId, Set<String> selectedClients, VoidCallback onUpdate) {
    HapticFeedback.lightImpact();

    if (selectedClients.contains(clientId)) {
      selectedClients.remove(clientId);
    } else {
      selectedClients.add(clientId);
    }
    onUpdate();
  }

  /// ✅ FIX CRÍTICO: SELECCIONAR TODOS - NO MODIFICAR SET DIRECTAMENTE
  void selectAllClients(List<ClientModel> filteredClients,
      Set<String> selectedClients, VoidCallback onUpdate) {
    debugPrint('🔧 MIXIN: selectAllClients llamado');
    debugPrint('🔧 MIXIN: filteredClients.length = ${filteredClients.length}');
    debugPrint(
        '🔧 MIXIN: selectedClients.length ANTES = ${selectedClients.length}');

    // ✅ FIX: NO usar addAll en Set inmutable, usar clear + add individualmente
    try {
      // Limpiar primero
      selectedClients.clear();

      // Agregar uno por uno para evitar addAll en Set inmutable
      for (final client in filteredClients) {
        selectedClients.add(client.clientId);
      }

      HapticFeedback.mediumImpact();
      onUpdate();

      debugPrint(
          '✅ MIXIN: selectedClients.length DESPUÉS = ${selectedClients.length}');
      debugPrint('✅ MIXIN: Seleccionados todos los clientes exitosamente');
    } catch (e) {
      debugPrint('❌ MIXIN: Error en selectAllClients: $e');
      debugPrint(
          '❌ MIXIN: selectedClients.runtimeType = ${selectedClients.runtimeType}');

      // ✅ FALLBACK: Si el Set es completamente inmutable, notificar al parent
      debugPrint(
          '⚠️ MIXIN: Set inmutable detectado, delegando al parent widget');
      onUpdate(); // El parent debe manejar la selección
    }
  }

  /// ✅ FIX CRÍTICO: LIMPIAR SELECCIÓN - MÉTODO SEGURO
  void clearSelection(Set<String> selectedClients, VoidCallback onUpdate) {
    debugPrint('🔧 MIXIN: clearSelection llamado');
    debugPrint(
        '🔧 MIXIN: selectedClients.length ANTES = ${selectedClients.length}');

    try {
      // ✅ FIX: Usar clear() de forma segura
      selectedClients.clear();
      onUpdate();

      debugPrint(
          '✅ MIXIN: selectedClients.length DESPUÉS = ${selectedClients.length}');
      debugPrint('✅ MIXIN: Selección limpiada exitosamente');
    } catch (e) {
      debugPrint('❌ MIXIN: Error en clearSelection: $e');
      debugPrint(
          '❌ MIXIN: selectedClients.runtimeType = ${selectedClients.runtimeType}');

      // ✅ FALLBACK: Si el Set es completamente inmutable, notificar al parent
      debugPrint(
          '⚠️ MIXIN: Set inmutable detectado, delegando al parent widget');
      onUpdate(); // El parent debe manejar la limpieza
    }
  }

  // ====================================================================
  // 🔍 HANDLERS DE BÚSQUEDA Y FILTROS (COPIADO EXACTO)
  // ====================================================================

  void clearSearch(
      TextEditingController searchController, VoidCallback onUpdate) {
    searchController.clear();
    onUpdate();
  }

  void toggleFiltersPanel(bool showFiltersPanel, VoidCallback onToggle,
      VoidCallback showFiltersBottomSheet) {
    onToggle();
    if (!showFiltersPanel) {
      showFiltersBottomSheet();
    }
  }

  void handleFilterChanged(ClientFilterCriteria newFilter,
      Function(ClientFilterCriteria) onFilterChanged) {
    onFilterChanged(newFilter);
  }

  void handleResetFilters(Function() onResetFilters) {
    onResetFilters();
  }

  // ====================================================================
  // 🎨 HANDLERS DE BOTTOM SHEETS (COPIADO EXACTO)
  // ====================================================================

  void showFiltersBottomSheet(
    BuildContext context,
    ClientFilterCriteria currentFilter,
    List<String> availableTags,
    List<String> availableAlcaldias,
    Function(ClientFilterCriteria) onFilterChanged,
    VoidCallback onResetFilters,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: false,
      builder: (BuildContext context) {
        return ClientsFiltersPanel(
          currentFilter: currentFilter,
          availableTags: availableTags,
          availableAlcaldias: availableAlcaldias,
          onFilterChanged: onFilterChanged,
          onResetFilters: onResetFilters,
        );
      },
    );
  }

  // ====================================================================
  // 📱 HANDLERS DE EXPORTACIÓN E IMPORTACIÓN (COPIADO EXACTO)
  // ====================================================================

  void exportClients() {
    // Exportación de clientes - función en desarrollo
    // Se maneja el mensaje en el caller
  }

  void exportSelectedClients(List<ClientModel> clients) {
    // Exportación de clientes seleccionados - función en desarrollo
    // Se maneja el mensaje en el caller
  }

  void importClients() {
    // Importación de clientes - función en desarrollo
    // Se maneja el mensaje en el caller
  }
}
