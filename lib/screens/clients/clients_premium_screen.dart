// [clients_premium_screen.dart] - ✅ ERRORES ARREGLADOS COMPLETAMENTE
// 📁 Ubicación: /lib/screens/clients/clients_premium_screen.dart
// 🎯 OBJETIVO: Arreglar TODOS los errores de compilación mostrados en la imagen

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/services/client_service.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/background_cost_monitor.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/cost_data_models.dart';
import 'package:agenda_fisio_spa_kym/enums/view_mode.dart';

// 🏗️ CONTROLLERS
import 'controllers/clients_screen_controller.dart';
import 'controllers/clients_animation_controller.dart';

// 🎨 WIDGETS MODULARES
import 'widgets/clients_header_section.dart';
import 'widgets/clients_search_section.dart';
import 'widgets/clients_list_section.dart';
import 'widgets/clients_fab_section.dart';

// 🎯 MIXINS - Solo los que existen y funcionan
import 'mixins/clients_dialogs_mixin.dart';
import 'mixins/clients_snackbars_mixin.dart';

/// 🏢 PANTALLA PRINCIPAL ENTERPRISE DE CLIENTES - ✅ ERRORES ARREGLADOS
class ClientsPremiumScreen extends StatefulWidget {
  const ClientsPremiumScreen({super.key});

  @override
  State<ClientsPremiumScreen> createState() => _ClientsPremiumScreenState();
}

class _ClientsPremiumScreenState extends State<ClientsPremiumScreen>
    with TickerProviderStateMixin, ClientsDialogsMixin, ClientsSnackbarsMixin {
  // ✅ CONTROLLERS
  late ClientsScreenController _screenController;
  late ClientsAnimationController _animationController;

  // ✅ SERVICIOS
  final ClientService _clientService = ClientService();
  final BackgroundCostMonitor _costMonitor = BackgroundCostMonitor();

  // ✅ CONTROL DE REFRESH
  bool _isRefreshing = false;
  Timer? _refreshDebouncer;

  // ✅ CONTROL DE REBUILDS
  int _buildCount = 0;
  static const int _maxBuildLogs = 3;

  // ✅ CACHE DE WIDGETS
  Widget? _cachedBody;
  Widget? _cachedFAB;
  String? _lastCacheKey;

  // ====================================================================
  // 🚀 LIFECYCLE
  // ====================================================================

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
    _initializeServices();
  }

  void _initializeControllers() {
    _screenController = ClientsScreenController();
    _animationController = ClientsAnimationController(vsync: this);
  }

  void _setupListeners() {
    _screenController.searchController
        .addListener(_screenController.onSearchChanged);
    _screenController.addListener(_onScreenControllerChanged);
  }

  Future<void> _initializeServices() async {
    try {
      await _clientService.initialize();
      await _screenController.initializeServices();
      await _screenController.loadUserViewMode();

      if (_screenController.isInitialized) {
        _animationController.startAnimations();
      }

      if (kDebugMode) {
        debugPrint('✅ Servicios inicializados correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error inicializando servicios: $e');
      }
      _showErrorSnackBar('Error inicializando: $e');
    }
  }

  void _onScreenControllerChanged() {
    if (mounted && !_isRefreshing) {
      _invalidateCache();
      setState(() {});
    }
  }

  void _invalidateCache() {
    _cachedBody = null;
    _cachedFAB = null;
    _lastCacheKey = null;
  }

  String _generateCacheKey() {
    return '${_screenController.isInitialized}_'
        '${_screenController.currentViewMode.name}_'
        '${_screenController.filteredClients.length}_'
        '${_screenController.selectedClients.length}_'
        '${_screenController.currentPage}_'
        '${_screenController.searchQuery.hashCode}';
  }

  @override
  void dispose() {
    _refreshDebouncer?.cancel();
    _screenController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ====================================================================
  // 🎨 UI BUILD
  // ====================================================================

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    if (_buildCount <= _maxBuildLogs && kDebugMode) {
      debugPrint('🏗️ ClientsPremiumScreen build #$_buildCount');
    } else if (_buildCount == _maxBuildLogs + 1 && kDebugMode) {
      debugPrint('🏗️ Builds adicionales silenciados...');
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: _buildBodyWithCache(),
      floatingActionButton: _buildFloatingActionButtonWithCache(),
    );
  }

  Widget _buildBodyWithCache() {
    final currentCacheKey = _generateCacheKey();

    if (_cachedBody != null && _lastCacheKey == currentCacheKey) {
      return _cachedBody!;
    }

    _cachedBody = _buildBody();
    _lastCacheKey = currentCacheKey;

    return _cachedBody!;
  }

  Widget _buildBody() {
    if (!_screenController.isInitialized) {
      return _buildLoadingScreen();
    }

    return CustomScrollView(
      controller: _screenController.scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: ClientsHeaderSection(
            analytics: _screenController.analytics,
            totalClients: _screenController.allClients.length,
            filteredClients: _screenController.filteredClients.length,
            selectedClients: _screenController.selectedClients.length,
            onRefresh: _handleRefreshAnalytics,
            onForceRefresh: _handleForceRefresh,
            headerAnimation: _animationController.headerAnimation,
            costMonitor: _costMonitor,
          ),
        ),
        SliverToBoxAdapter(
          child: ClientsSearchSection(
            searchController: _screenController.searchController,
            currentViewMode: _screenController.currentViewMode,
            isSearching: _screenController.isSearching,
            sortOption: _screenController.sortOption,
            currentFilter: _screenController.currentFilter,
            allClients: _screenController.allClients,
            filteredClients: _screenController.filteredClients,
            selectedClients: _screenController.selectedClients,
            searchQuery: _screenController.searchController.text,
            onViewModeChanged: _handleViewModeChanged,
            onClearSearch: _handleClearSearch,
            onSort: _handleSort,
            onToggleFilters: _handleToggleFilters,
            onAction: _handleAction,
            cardsAnimation: _animationController.cardsAnimation,
            onExportCompleted: () {
              _showSuccessSnackBar('Exportación completada exitosamente');
            },
          ),
        ),
        SliverToBoxAdapter(
          child: ClientsListSection(
            clients: _screenController.getPaginatedClients(),
            allClients: _screenController.allClients,
            filteredClients: _screenController.filteredClients,
            selectedClients: _screenController.selectedClients,
            totalFilteredClients: _screenController.filteredClients.length,
            currentViewMode: _screenController.currentViewMode,
            tableSortColumn: _screenController.tableSortColumn,
            tableSortAscending: _screenController.tableSortAscending,
            screenController: _screenController,
            onClientSelect: _handleClientSelect,
            onClientEdit: _handleClientEdit,
            onClientDelete: _handleClientDelete,
            onClientPreview: _handleClientPreview,
            onTableSort: _screenController.handleTableSort,
            onBulkDelete: _handleBulkDelete,
            onBulkAddTags: _handleBulkAddTags,
            onBulkExport: _handleBulkExport,
            onClearSelection: _handleClearSelection,
            // ✅ FIX ERROR: Cambiar onSelectAll por onSelectCurrentPage
            onSelectCurrentPage: _handleSelectCurrentPage,
            cardsAnimation: _animationController.cardsAnimation,
            viewModeTransition: _animationController.viewModeTransition,
          ),
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
            'Cargando clientes...',
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

  Widget _buildFloatingActionButtonWithCache() {
    if (_cachedFAB != null) {
      return _cachedFAB!;
    }

    _cachedFAB = _buildFloatingActionButton();
    return _cachedFAB!;
  }

  Widget _buildFloatingActionButton() {
    return ClientsFabSection(
      onPressed: _handleCreateNewClient,
      fabAnimation: _animationController.fabAnimation,
    );
  }

  // ====================================================================
  // 🎯 EVENT HANDLERS PRINCIPALES
  // ====================================================================

  Future<void> _handleRefreshAnalytics() async {
    try {
      await _screenController.handleRefreshAnalytics();
    } catch (e) {
      _showErrorSnackBar('Error actualizando analytics: $e');
    }
  }

  Future<void> _handleForceRefresh() async {
    try {
      _checkCostLimits();
      await _clientService.clearCache();
      await _clientService.forceSync();
      await _screenController.handleForceRefresh();
    } catch (e) {
      _showErrorSnackBar('Error actualizando datos: $e');
    }
  }

  Future<void> _handleViewModeChanged(ViewMode newMode) async {
    try {
      await _animationController.startViewModeTransition();
      await _screenController.handleViewModeChanged(newMode);
      await _animationController.completeViewModeTransition();
      _invalidateCache();
    } catch (e) {
      _showErrorSnackBar('Error cambiando vista: $e');
    }
  }

  void _handleClearSearch() {
    _screenController.searchController.clear();
    _screenController.clearSearch();
    _invalidateCache();
  }

  void _handleSort(String sortOption) {
    _screenController.setSortOption(sortOption);
    _invalidateCache();
  }

  void _handleToggleFilters() {
    _screenController.toggleFiltersPanel();
    if (!_screenController.showFiltersPanel) {
      _showFiltersBottomSheet();
    }
  }

  void _handleAction(String action) {
    switch (action) {
      case 'export':
        _showDevelopmentFeatureSnackBar('Exportación legacy');
        break;
      case 'export_completed':
        _showSuccessSnackBar('Exportación completada exitosamente');
        break;
      case 'import':
        _showDevelopmentFeatureSnackBar('Importación');
        break;
      case 'refresh':
        _handleForceRefresh();
        break;
      case 'settings':
        _showDevelopmentFeatureSnackBar('Configuración');
        break;
    }
  }

  // ====================================================================
  // 👥 CLIENT HANDLERS
  // ====================================================================

  void _handleClientSelect(String clientId) {
    _screenController.toggleClientSelection(clientId);
  }

  Future<void> _handleClientEdit(ClientModel client) async {
    if (kDebugMode) {
      debugPrint('✏️ Iniciando edición de cliente: ${client.fullName}');
    }

    await editClient(
      client,
      () {
        _triggerRefreshAfterCRUD('Cliente actualizado exitosamente');
      },
    );
  }

  Future<void> _handleClientDelete(String clientId) async {
    final client =
        _screenController.allClients.firstWhere((c) => c.clientId == clientId);

    final confirmed = await _showConfirmDialog(
      'Eliminar cliente',
      '¿Está seguro de que desea eliminar a ${client.fullName}? Esta acción no se puede deshacer.',
    );

    if (!confirmed) return;

    try {
      await _clientService.deleteClient(clientId);
      _triggerRefreshAfterCRUD('Cliente eliminado exitosamente');
    } catch (e) {
      _showErrorSnackBar('Error eliminando cliente: $e');
    }
  }

  void _handleClientPreview(ClientModel client) {
    showClientPreview(client, _screenController.currentViewMode.name);
    _showPreviewDevelopmentSnackBar(client.fullName);
  }

  Future<void> _handleCreateNewClient() async {
    if (kDebugMode) {
      debugPrint('➕ Iniciando creación de cliente nuevo...');
    }

    await createNewClient(() {
      _triggerRefreshAfterCRUD('Cliente creado exitosamente');
    });
  }

  // ====================================================================
  // ✅ FIX ERROR: SELECCIÓN SOLO DE PÁGINA ACTUAL (MÉTODO CORREGIDO)
  // ====================================================================

  /// ✅ FIX ERROR: onSelectCurrentPage en lugar de onSelectAll
  void _handleSelectCurrentPage() {
    if (kDebugMode) {
      debugPrint('🔧 SCREEN: Seleccionando solo página actual');
      debugPrint(
          '🔧 SCREEN: Página ${_screenController.currentPage + 1}/${_screenController.totalPages}');
    }

    try {
      // ✅ USAR EL MÉTODO CORRECTO DEL CONTROLLER
      _screenController.selectCurrentPageClients();

      HapticFeedback.mediumImpact();

      final currentPageClients = _screenController.getPaginatedClients();
      if (kDebugMode) {
        debugPrint(
            '✅ SCREEN: ${currentPageClients.length} clientes de página actual seleccionados');
        debugPrint(
            '📊 SCREEN: Total seleccionados: ${_screenController.selectedClients.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SCREEN: Error en _handleSelectCurrentPage: $e');
      }
      _showErrorSnackBar('Error seleccionando clientes: $e');
    }
  }

  void _handleClearSelection() {
    if (kDebugMode) {
      debugPrint('🔧 SCREEN: Limpiando selección');
    }

    try {
      _screenController.clearAllSelection();
      HapticFeedback.lightImpact();

      if (kDebugMode) {
        debugPrint('✅ SCREEN: Selección limpiada');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SCREEN: Error en _handleClearSelection: $e');
      }
      _showErrorSnackBar('Error limpiando selección: $e');
    }
  }

  // ====================================================================
  // 📦 BULK HANDLERS
  // ====================================================================

  Future<void> _handleBulkDelete(List<String> clientIds) async {
    final confirmed = await _showConfirmDialog(
      'Eliminar ${clientIds.length} clientes',
      '¿Está seguro de que desea eliminar los clientes seleccionados? Esta acción no se puede deshacer.',
    );

    if (!confirmed) return;

    try {
      await _clientService.bulkDelete(clientIds);
      _triggerRefreshAfterCRUD('${clientIds.length} clientes eliminados');
    } catch (e) {
      _showErrorSnackBar('Error eliminando clientes: $e');
    }
  }

  Future<void> _handleBulkAddTags(
      List<String> clientIds, List<ClientTag> tags) async {
    try {
      await _clientService.bulkUpdateTags(clientIds, tags);
      _triggerRefreshAfterCRUD(
          'Etiquetas agregadas a ${clientIds.length} clientes');
    } catch (e) {
      _showErrorSnackBar('Error agregando etiquetas: $e');
    }
  }

  void _handleBulkExport(List<String> clientIds) {
    final selectedClients = _screenController.allClients
        .where((client) => clientIds.contains(client.clientId))
        .toList();

    if (kDebugMode) {
      debugPrint(
          '🎯 Bulk export iniciado para ${selectedClients.length} clientes');
    }
  }

  // ====================================================================
  // ✅ REFRESH AUTOMÁTICO DESPUÉS DE OPERACIONES CRUD
  // ====================================================================

  void _triggerRefreshAfterCRUD(String successMessage) {
    if (!mounted) return;

    if (kDebugMode) {
      debugPrint('🚀 Disparando refresh después de CRUD...');
    }

    _showSuccessSnackBar(successMessage);
    HapticFeedback.mediumImpact();

    Future.microtask(() async {
      try {
        if (kDebugMode) {
          debugPrint('⚡ Ejecutando refresh optimizado...');
        }

        _invalidateCache();

        if (mounted) {
          setState(() {
            if (kDebugMode) {
              debugPrint('🎨 UI actualizada con refresh optimizado');
            }
          });
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Error en refresh optimizado: $e');
        }
      }
    });
  }

  // ====================================================================
  // 🛠️ HELPER METHODS - ✅ FIX ERROR: showFiltersBottomSheet DEFINIDO
  // ====================================================================

  /// ✅ FIX ERROR: Método showFiltersBottomSheet definido
  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: false,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Panel de filtros en desarrollo'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _checkCostLimits() {
    if (_costMonitor.currentStats.dailyReadCount >=
        CostControlConfig.dailyReadLimit) {
      throw Exception('Límite de costos alcanzado. Intente más tarde.');
    }
  }

  // ====================================================================
  // 🎨 SNACKBAR METHODS
  // ====================================================================

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: kAccentGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: kErrorColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDevelopmentFeatureSnackBar(String feature) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.build_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('$feature - Función en desarrollo'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPreviewDevelopmentSnackBar(String clientName) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.visibility, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Vista previa de $clientName - En desarrollo'),
            ),
          ],
        ),
        backgroundColor: kBrandPurple,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
