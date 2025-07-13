// [clients_screen_controller.dart] - CONTROLLER COMPLETO CON PAGINACIÓN REAL + SELECCIÓN POR PÁGINA
// 📁 Ubicación: /lib/screens/clients/controllers/clients_screen_controller.dart
// 🎯 OBJETIVO: Controller completo con método selectCurrentPageClients + optimizaciones

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/services/client_service.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/utils/client_constants.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/background_cost_monitor.dart';
import 'package:agenda_fisio_spa_kym/services/cost_control/cost_data_models.dart';
import 'package:agenda_fisio_spa_kym/enums/view_mode.dart';
import 'package:agenda_fisio_spa_kym/services/user_preferences_service.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/client_card_factory.dart';

/// 🧠 CONTROLLER PRINCIPAL CON PAGINACIÓN REAL COMPLETA + SELECCIÓN POR PÁGINA
class ClientsScreenController extends ChangeNotifier {
  // ✅ CONTROLADORES Y SERVICIOS
  final TextEditingController searchController = TextEditingController();
  final ClientService _clientService = ClientService();
  final BackgroundCostMonitor _costMonitor = BackgroundCostMonitor();
  final ScrollController scrollController = ScrollController();
  final UserPreferencesService _preferencesService =
      UserPreferencesService.instance;

  // ✅ ESTADO DE LA APLICACIÓN
  List<ClientModel> _allClients = [];
  List<ClientModel> _filteredClients = [];
  final Set<String> _selectedClients = <String>{};
  ClientFilterCriteria _currentFilter = const ClientFilterCriteria();
  ClientAnalytics? _analytics;

  // ✅ ESTADO DE UI
  bool _isSearching = false;
  bool _showFiltersPanel = false;
  bool _isInitialized = false;
  String _sortOption = ClientConstants.SORT_OPTIONS.first;
  String _searchQuery = '';

  // ✅ ESTADO DEL SISTEMA DE VISTAS MÚLTIPLES
  ViewMode _currentViewMode = ViewMode.table;
  String? _tableSortColumn;
  bool _tableSortAscending = true;

  // ✅ PAGINACIÓN REAL - VARIABLES PRINCIPALES
  int _currentPage = 0;
  int _itemsPerPage = 20;
  static const List<int> _availablePageSizes = [20, 50, 100];

  // ✅ CONTROL DE LOGS PARA EVITAR SPAM
  int _paginationLogCount = 0;
  static const int _maxPaginationLogs = 3;

  // ✅ CONFIGURACIÓN DE PERFORMANCE
  static const int _pageSize = ClientConstants.CLIENTS_PER_PAGE;

  // ====================================================================
  // 🎯 GETTERS PÚBLICOS
  // ====================================================================

  List<ClientModel> get allClients => List.unmodifiable(_allClients);
  List<ClientModel> get filteredClients => List.unmodifiable(_filteredClients);
  Set<String> get selectedClients => Set<String>.from(_selectedClients);
  ClientFilterCriteria get currentFilter => _currentFilter;
  ClientAnalytics? get analytics => _analytics;
  bool get isSearching => _isSearching;
  bool get showFiltersPanel => _showFiltersPanel;
  bool get isInitialized => _isInitialized;
  String get sortOption => _sortOption;
  String get searchQuery => _searchQuery;
  ViewMode get currentViewMode => _currentViewMode;
  String? get tableSortColumn => _tableSortColumn;
  bool get tableSortAscending => _tableSortAscending;

  // ✅ GETTERS DE PAGINACIÓN
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  List<int> get availablePageSizes => _availablePageSizes;

  int get totalPages {
    if (_filteredClients.isEmpty) return 1;
    return (_filteredClients.length / _itemsPerPage).ceil();
  }

  // ✅ GETTERS DE NAVEGACIÓN
  bool get hasNextPage => _currentPage < totalPages - 1;
  bool get hasPreviousPage => _currentPage > 0;

  // ====================================================================
  // 🚀 MÉTODOS DE INICIALIZACIÓN
  // ====================================================================

  Future<void> initializeServices() async {
    debugPrint('🚀 Inicializando ClientsScreenController...');

    try {
      await _clientService.initialize();
      await _preferencesService.initialize();
      await _loadInitialData();
      _isInitialized = true;
      notifyListeners();
      debugPrint('✅ ClientsScreenController inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error inicializando ClientsScreenController: $e');
      _isInitialized = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _loadInitialData() async {
    debugPrint('📊 Cargando datos iniciales...');
    final clients = await _clientService.getAllClients();
    final analytics = await _clientService.getBasicAnalytics();
    _allClients = clients;
    _filteredClients = clients;
    _analytics = analytics;
    _applyCurrentFilters();
    notifyListeners();
  }

  Future<void> loadUserViewMode() async {
    try {
      final savedMode = await _preferencesService.getViewMode();
      _currentViewMode = savedMode;
      notifyListeners();
      debugPrint('📱 ViewMode cargado: ${savedMode.displayName}');
    } catch (e) {
      debugPrint('❌ Error cargando ViewMode: $e');
    }
  }

  // ====================================================================
  // ✅ MÉTODOS DE PAGINACIÓN REAL
  // ====================================================================

  /// ✅ MÉTODO CRÍTICO: OBTENER CLIENTES PAGINADOS
  List<ClientModel> getPaginatedClients() {
    // ✅ VALIDACIONES DE SEGURIDAD
    if (_filteredClients.isEmpty) {
      return [];
    }

    if (_currentPage < 0) {
      _currentPage = 0;
    }

    // ✅ CÁLCULO CORRECTO DE ÍNDICES
    final startIndex = _currentPage * _itemsPerPage;

    // ✅ VERIFICAR QUE EL START INDEX SEA VÁLIDO
    if (startIndex >= _filteredClients.length) {
      // Auto-corregir a la última página válida
      _currentPage = (((_filteredClients.length - 1) / _itemsPerPage).floor())
          .clamp(0, double.infinity)
          .toInt();
      final correctedStartIndex = _currentPage * _itemsPerPage;
      final correctedEndIndex = (correctedStartIndex + _itemsPerPage)
          .clamp(0, _filteredClients.length);

      return _filteredClients.sublist(correctedStartIndex, correctedEndIndex);
    }

    final endIndex =
        (startIndex + _itemsPerPage).clamp(0, _filteredClients.length);
    final paginatedClients = _filteredClients.sublist(startIndex, endIndex);

    // ✅ LOGS REDUCIDOS PARA EVITAR SPAM
    if (paginatedClients.isNotEmpty &&
        _paginationLogCount < _maxPaginationLogs) {
      debugPrint(
          '📄 Página ${_currentPage + 1}/$totalPages: ${paginatedClients.length} clientes (${startIndex}-${endIndex - 1})');
      _paginationLogCount++;
    } else if (_paginationLogCount == _maxPaginationLogs) {
      debugPrint('📄 Logs de paginación adicionales silenciados...');
      _paginationLogCount++;
    }

    return paginatedClients;
  }

  /// ✅ CAMBIAR PÁGINA
  void setPage(int page) {
    if (page < 0 || page >= totalPages) {
      return;
    }

    final oldPage = _currentPage;
    _currentPage = page;
    notifyListeners();

    // ✅ LOG SOLO SI ES NECESARIO
    if (_paginationLogCount < _maxPaginationLogs) {
      debugPrint('✅ Página cambiada: ${oldPage + 1} → ${page + 1}');
    }
  }

  /// ✅ CAMBIAR TAMAÑO DE PÁGINA
  void setPageSize(int newSize) {
    if (!_availablePageSizes.contains(newSize)) {
      return;
    }

    // Calcular nueva página para mantener posición aproximada
    final currentFirstItemIndex = _currentPage * _itemsPerPage;

    _itemsPerPage = newSize;
    _currentPage = (currentFirstItemIndex / _itemsPerPage).floor();

    // Ajustar si la nueva página excede el total
    if (_currentPage >= totalPages) {
      _currentPage = totalPages - 1;
    }

    notifyListeners();

    debugPrint('📊 Tamaño de página cambiado a: $newSize');
    debugPrint('📄 Nueva página: ${_currentPage + 1}/$totalPages');
  }

  /// ✅ RESETEAR PAGINACIÓN
  void resetPagination() {
    _currentPage = 0;
    _paginationLogCount = 0;
    notifyListeners();
  }

  /// ✅ NAVEGACIÓN SIMPLE
  void nextPage() {
    if (hasNextPage) {
      setPage(_currentPage + 1);
    }
  }

  void previousPage() {
    if (hasPreviousPage) {
      setPage(_currentPage - 1);
    }
  }

  void goToFirstPage() {
    setPage(0);
  }

  void goToLastPage() {
    setPage(totalPages - 1);
  }

  /// ✅ INFORMACIÓN DE PAGINACIÓN
  Map<String, dynamic> getPaginationInfo() {
    final startItem = (_currentPage * _itemsPerPage) + 1;
    final endItem =
        ((_currentPage + 1) * _itemsPerPage).clamp(0, _filteredClients.length);

    return {
      'currentPage': _currentPage + 1,
      'totalPages': totalPages,
      'itemsPerPage': _itemsPerPage,
      'totalItems': _filteredClients.length,
      'startItem': startItem,
      'endItem': endItem,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  // ====================================================================
  // 🔍 MÉTODOS DE BÚSQUEDA Y FILTROS
  // ====================================================================

  void onSearchChanged() {
    final query = searchController.text.trim();
    if (query == _searchQuery) return;

    _searchQuery = query;
    _isSearching = query.isNotEmpty;
    notifyListeners();

    Future.delayed(ClientConstants.SEARCH_DEBOUNCE, () {
      if (searchController.text.trim() == query) {
        _performSearch(query);
      }
    });
  }

  void _performSearch(String query) {
    debugPrint('🔍 Realizando búsqueda: "$query"');

    final stopwatch = Stopwatch()..start();

    List<ClientModel> results;
    if (query.isEmpty) {
      results = _allClients;
    } else if (query.length < ClientConstants.MIN_SEARCH_CHARS) {
      results = _filteredClients;
    } else {
      results = _allClients.search(query);
    }

    if (!_currentFilter.isEmpty) {
      results = results.filterByCriteria(_currentFilter);
    }

    results = _applySorting(results);

    _filteredClients = results;
    resetPagination(); // ✅ RESET PAGINACIÓN AL BUSCAR
    _isSearching = false;
    notifyListeners();

    stopwatch.stop();
    debugPrint('⚡ Búsqueda completada en ${stopwatch.elapsedMilliseconds}ms');
    debugPrint('📊 Resultados: ${results.length} clientes');
  }

  void applyCurrentFilters() {
    debugPrint('🔍 Aplicando filtros...');

    List<ClientModel> filtered = _allClients;

    if (!_currentFilter.isEmpty) {
      filtered = filtered.filterByCriteria(_currentFilter);
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.search(_searchQuery);
    }

    filtered = _applySorting(filtered);

    _filteredClients = filtered;
    resetPagination(); // ✅ RESET PAGINACIÓN AL FILTRAR
    notifyListeners();

    debugPrint('📊 Filtros aplicados: ${filtered.length} clientes');
  }

  void _applyCurrentFilters() => applyCurrentFilters();

  List<ClientModel> _applySorting(List<ClientModel> clients) {
    if (_currentViewMode == ViewMode.table && _tableSortColumn != null) {
      return clients;
    }

    switch (_sortOption) {
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
  // 🎯 MÉTODOS DE VISTA MÚLTIPLE
  // ====================================================================

  Future<void> handleViewModeChanged(ViewMode newMode) async {
    if (_currentViewMode == newMode) return;

    try {
      _currentViewMode = newMode;
      if (newMode != ViewMode.table) {
        _tableSortColumn = null;
        _tableSortAscending = true;
      }
      notifyListeners();

      await _preferencesService.setViewMode(newMode);
      ClientCardFactory.clearCache();

      await _preferencesService.recordUsageEvent('view_mode_changed', {
        'newMode': newMode.name,
        'timestamp': DateTime.now().toIso8601String(),
      });

      HapticFeedback.mediumImpact();
      debugPrint('🎯 ViewMode cambiado a: ${newMode.displayName}');
    } catch (e) {
      debugPrint('❌ Error cambiando ViewMode: $e');
      rethrow;
    }
  }

  void handleTableSort(String column) {
    if (_tableSortColumn == column) {
      _tableSortAscending = !_tableSortAscending;
    } else {
      _tableSortColumn = column;
      _tableSortAscending = true;
    }
    notifyListeners();

    _applySortingByColumn(column, _tableSortAscending);
    HapticFeedback.lightImpact();
    debugPrint(
        '📊 Tabla ordenada por: $column (${_tableSortAscending ? 'ASC' : 'DESC'})');
  }

  void _applySortingByColumn(String column, bool ascending) {
    List<ClientModel> sorted = List.from(_filteredClients);

    switch (column) {
      case 'name':
        sorted.sort((a, b) => ascending
            ? a.fullName.compareTo(b.fullName)
            : b.fullName.compareTo(a.fullName));
        break;
      case 'email':
        sorted.sort((a, b) => ascending
            ? a.email.compareTo(b.email)
            : b.email.compareTo(a.email));
        break;
      case 'phone':
        sorted.sort((a, b) => ascending
            ? a.phone.compareTo(b.phone)
            : b.phone.compareTo(a.phone));
        break;
      case 'company':
        sorted.sort((a, b) => ascending
            ? a.empresa.compareTo(b.empresa)
            : b.empresa.compareTo(a.empresa));
        break;
      case 'status':
        sorted.sort((a, b) => ascending
            ? a.statusDisplayName.compareTo(b.statusDisplayName)
            : b.statusDisplayName.compareTo(a.statusDisplayName));
        break;
    }

    _filteredClients = sorted;
    resetPagination(); // ✅ RESET PAGINACIÓN AL ORDENAR
    notifyListeners();
  }

  // ====================================================================
  // 📊 MÉTODOS DE PAGINACIÓN Y SCROLL
  // ====================================================================

  /// ✅ MÉTODO DESACTIVADO: onScroll para evitar conflictos
  void onScroll() {
    // ❌ DESACTIVADO - CONFLICTO CON PAGINACIÓN MANUAL
    // El scroll NO debe cambiar páginas automáticamente
  }

  /// ✅ MÉTODO CORREGIDO: getDisplayedClients() - USA PAGINACIÓN REAL
  List<ClientModel> getDisplayedClients() {
    return getPaginatedClients();
  }

  // ====================================================================
  // 🔧 MÉTODOS DE GESTIÓN DE ESTADO
  // ====================================================================

  void setSortOption(String newSortOption) {
    _sortOption = newSortOption;
    applyCurrentFilters();
  }

  void setCurrentFilter(ClientFilterCriteria newFilter) {
    _currentFilter = newFilter;
    applyCurrentFilters();
  }

  void clearFilter() {
    _currentFilter = const ClientFilterCriteria();
    applyCurrentFilters();
  }

  void toggleClientSelection(String clientId) {
    if (_selectedClients.contains(clientId)) {
      _selectedClients.remove(clientId);
    } else {
      _selectedClients.add(clientId);
    }
    notifyListeners();
  }

  void selectAllClients() {
    _selectedClients.addAll(_filteredClients.map((c) => c.clientId));
    notifyListeners();
  }

  void clearSelection() {
    _selectedClients.clear();
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery = '';
    _isSearching = false;
    applyCurrentFilters();
  }

  void toggleFiltersPanel() {
    _showFiltersPanel = !_showFiltersPanel;
    notifyListeners();
  }

  // ====================================================================
  // ✅ MÉTODOS PÚBLICOS PARA MANIPULAR SELECCIÓN - CON PÁGINA ACTUAL
  // ====================================================================

  void selectAllFilteredClients() {
    debugPrint('🔧 CONTROLLER: selectAllFilteredClients llamado');
    debugPrint(
        '🔧 CONTROLLER: _filteredClients.length = ${_filteredClients.length}');
    debugPrint(
        '🔧 CONTROLLER: _selectedClients.length ANTES = ${_selectedClients.length}');

    try {
      _selectedClients.clear();
      for (final client in _filteredClients) {
        _selectedClients.add(client.clientId);
      }
      debugPrint(
          '✅ CONTROLLER: ${_selectedClients.length} clientes seleccionados');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ CONTROLLER: Error en selectAllFilteredClients: $e');
      rethrow;
    }
  }

  /// ✅ NUEVO: SELECCIONAR SOLO LOS CLIENTES DE LA PÁGINA ACTUAL
  void selectCurrentPageClients() {
    debugPrint('🔧 CONTROLLER: selectCurrentPageClients llamado');

    try {
      // ✅ OBTENER SOLO LOS CLIENTES DE LA PÁGINA ACTUAL
      final currentPageClients = getPaginatedClients();

      debugPrint(
          '🔧 CONTROLLER: Página actual tiene ${currentPageClients.length} clientes');
      debugPrint(
          '🔧 CONTROLLER: _selectedClients.length ANTES = ${_selectedClients.length}');

      // ✅ LIMPIAR SELECCIÓN ANTERIOR Y SELECCIONAR SOLO PÁGINA ACTUAL
      _selectedClients.clear();
      for (final client in currentPageClients) {
        _selectedClients.add(client.clientId);
      }

      debugPrint(
          '✅ CONTROLLER: ${_selectedClients.length} clientes de página actual seleccionados');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ CONTROLLER: Error en selectCurrentPageClients: $e');
      rethrow;
    }
  }

  void clearAllSelection() {
    debugPrint('🔧 CONTROLLER: clearAllSelection llamado');
    debugPrint(
        '🔧 CONTROLLER: _selectedClients.length ANTES = ${_selectedClients.length}');

    try {
      _selectedClients.clear();
      debugPrint('✅ CONTROLLER: Selección limpiada exitosamente');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ CONTROLLER: Error en clearAllSelection: $e');
      rethrow;
    }
  }

  /// ✅ OBTENER LISTA DE CLIENTES DE LA PÁGINA ACTUAL (PARA BULK TOOLBAR)
  List<ClientModel> getCurrentPageClients() {
    return getPaginatedClients();
  }

  bool get areAllFilteredClientsSelected {
    if (_filteredClients.isEmpty) return false;
    return _selectedClients.length == _filteredClients.length &&
        _filteredClients
            .every((client) => _selectedClients.contains(client.clientId));
  }

  /// ✅ NUEVO: VERIFICAR SI TODOS LOS CLIENTES DE LA PÁGINA ACTUAL ESTÁN SELECCIONADOS
  bool get areAllCurrentPageClientsSelected {
    final currentPageClients = getPaginatedClients();
    if (currentPageClients.isEmpty) return false;

    return currentPageClients
        .every((client) => _selectedClients.contains(client.clientId));
  }

  int get filteredClientsCount => _filteredClients.length;

  // ====================================================================
  // ✅ MÉTODOS DE REFRESH
  // ====================================================================

  Future<void> handleRefreshAnalytics() async {
    debugPrint('📊 Refrescando analytics...');
    try {
      final analytics = await _clientService.getBasicAnalytics();
      _analytics = analytics;
      notifyListeners();
      debugPrint('✅ Analytics refrescados exitosamente');
    } catch (e) {
      debugPrint('❌ Error actualizando analytics: $e');
      rethrow;
    }
  }

  Future<void> handleForceRefresh() async {
    debugPrint('🔄 INICIANDO REFRESH COMPLETO FORZADO...');

    if (_costMonitor.currentStats.dailyReadCount >=
        CostControlConfig.dailyReadLimit) {
      throw Exception('Límite de costos alcanzado. Intente más tarde.');
    }

    try {
      debugPrint('🧹 Limpiando cache del ClientService...');
      await _clientService.clearCache();
      ClientCardFactory.clearCache();

      debugPrint('🔄 Forzando sincronización desde Firestore...');
      await _clientService.forceSync();

      debugPrint('📊 Recargando datos frescos...');
      final clients = await _clientService.getAllClients(forceRefresh: true);
      final analytics = await _clientService.getBasicAnalytics();

      debugPrint('💾 Actualizando estado interno...');
      final oldCount = _allClients.length;
      _allClients = clients;
      _analytics = analytics;

      debugPrint('🔍 Reaplicando filtros y búsqueda...');
      _applyCurrentFilters();

      notifyListeners();

      debugPrint('✅ REFRESH COMPLETO EXITOSO:');
      debugPrint('   - Clientes antes: $oldCount');
      debugPrint('   - Clientes después: ${_allClients.length}');
      debugPrint('   - Clientes filtrados: ${_filteredClients.length}');
      debugPrint('   - Modo actual: ${_currentViewMode.displayName}');
    } catch (e) {
      debugPrint('❌ Error en refresh completo: $e');
      rethrow;
    }
  }

  Future<void> forceImmediateRefresh() async {
    debugPrint('⚡ REFRESH INMEDIATO SIN CACHE...');
    try {
      final clients = await _clientService.getAllClients(forceRefresh: true);
      _allClients = clients;
      _applyCurrentFilters();
      notifyListeners();
      debugPrint('✅ Refresh inmediato completado: ${clients.length} clientes');
    } catch (e) {
      debugPrint('❌ Error en refresh inmediato: $e');
      rethrow;
    }
  }

  Future<void> refreshSingleClient(String clientId) async {
    debugPrint('🔍 Refrescando cliente específico: $clientId');
    try {
      final client = await _clientService.getClientById(clientId);
      if (client != null) {
        final index = _allClients.indexWhere((c) => c.clientId == clientId);
        if (index != -1) {
          _allClients[index] = client;
          _applyCurrentFilters();
          notifyListeners();
          debugPrint('✅ Cliente $clientId actualizado exitosamente');
        } else {
          _allClients.add(client);
          _applyCurrentFilters();
          notifyListeners();
          debugPrint('✅ Cliente nuevo $clientId agregado a la lista');
        }
      }
    } catch (e) {
      debugPrint('❌ Error refrescando cliente $clientId: $e');
      await handleForceRefresh();
    }
  }

  // ====================================================================
  // 🔧 MÉTODOS HELPER
  // ====================================================================

  List<String> getAvailableTags() {
    final tags = <String>{};
    for (final client in _allClients) {
      for (final tag in client.tags) {
        tags.add(tag.label);
      }
    }
    return tags.toList()..sort();
  }

  List<String> getAvailableAlcaldias() {
    final alcaldias = <String>{};
    for (final client in _allClients) {
      final alcaldia = client.addressInfo.alcaldia;
      if (alcaldia.isNotEmpty) {
        alcaldias.add(alcaldia);
      }
    }
    return alcaldias.toList()..sort();
  }

  int getActiveFiltersCount() {
    int count = 0;
    if (_currentFilter.statuses.isNotEmpty) count++;
    if (_currentFilter.tags.isNotEmpty) count++;
    if (_currentFilter.dateRange != null) count++;
    if (_currentFilter.alcaldias.isNotEmpty) count++;
    if (_currentFilter.minAppointments != null) count++;
    return count;
  }

  void logViewModeStats(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final expectedClients =
        _currentViewMode.getExpectedClientsPerScreen(screenHeight);
    final factoryReport = ClientCardFactory.getPerformanceReport();

    debugPrint('📊 ViewMode Stats:');
    debugPrint('   Current mode: ${_currentViewMode.displayName}');
    debugPrint('   Expected clients per screen: $expectedClients');
    debugPrint('   Actual clients showing: ${getDisplayedClients().length}');
    debugPrint('   Factory performance: $factoryReport');
  }

  // ====================================================================
  // 🗑️ CLEANUP
  // ====================================================================

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
