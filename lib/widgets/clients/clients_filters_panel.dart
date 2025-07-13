// [clients_filters_panel.dart] - CORREGIDO: COMPATIBLE CON MODELO REAL
// 📁 Ubicación: /lib/widgets/clients/clients_filters_panel.dart
// 🎯 OBJETIVO: Panel de filtros CON HANDLE + CHIPS HORIZONTALES + COMPATIBLE CON ClientFilterCriteria

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/utils/client_constants.dart';

/// 🔍 PANEL DE FILTROS CON HANDLE Y CHIPS HORIZONTALES - COMPATIBLE
class ClientsFiltersPanel extends StatefulWidget {
  final ClientFilterCriteria currentFilter;
  final List<String> availableTags;
  final List<String> availableAlcaldias;
  final Function(ClientFilterCriteria) onFilterChanged;
  final VoidCallback onResetFilters;
  final ScrollController? scrollController;

  const ClientsFiltersPanel({
    super.key,
    required this.currentFilter,
    required this.availableTags,
    required this.availableAlcaldias,
    required this.onFilterChanged,
    required this.onResetFilters,
    this.scrollController,
  });

  @override
  State<ClientsFiltersPanel> createState() => _ClientsFiltersPanelState();
}

class _ClientsFiltersPanelState extends State<ClientsFiltersPanel>
    with TickerProviderStateMixin {
  // ✅ CONTROLADORES DE ANIMACIÓN
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // ✅ ESTADO DEL FILTRO LOCAL
  late ClientFilterCriteria _localFilter;

  // ✅ CONTROLADORES DE EXPANSIÓN
  final Map<String, bool> _expandedSections = {
    'status': false,
    'tags': false,
    'location': false,
    'appointments': false,
    'date': false,
    'saved': false,
  };

  // ✅ CONTROLADORES DE INPUT
  final TextEditingController _minAppointmentsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _localFilter = widget.currentFilter;
    _initializeAnimations();
    _initializeControllers();
    _startAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  void _initializeControllers() {
    _minAppointmentsController.text =
        _localFilter.minAppointments?.toString() ?? '';
  }

  void _startAnimations() {
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _minAppointmentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: kSombraCardElevated,
                ),
                child: Column(
                  children: [
                    _buildHandle(),
                    _buildHeader(),
                    Expanded(child: _buildFilterContent()),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // 🎯 COMPONENTES UI
  // ====================================================================

  Widget _buildHandle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: kTextSecondary.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kBrandPurple, kBrandPurple.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtros Inteligentes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Encuentra clientes específicos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActiveFiltersCount(),
              const SizedBox(width: 12),
              // ✅ BOTÓN CERRAR
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersCount() {
    final count = _getActiveFiltersCount();
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        '$count activos',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFilterContent() {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStatusSection(),
          const SizedBox(height: 20),
          _buildTagsSection(),
          const SizedBox(height: 20),
          _buildLocationSection(),
          const SizedBox(height: 20),
          _buildAppointmentsSection(),
          const SizedBox(height: 20),
          _buildDateSection(),
          const SizedBox(height: 20),
          _buildSavedFiltersSection(),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(
    String key,
    String title,
    IconData icon,
    Widget content, {
    Color? iconColor,
  }) {
    final isExpanded = _expandedSections[key] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderSoft),
        boxShadow: kSombraCard,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleSection(key),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (iconColor ?? kBrandPurple).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? kBrandPurple,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: kTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: isExpanded
                ? Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: content,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // 🎯 SECCIONES DE FILTROS
  // ====================================================================

  Widget _buildStatusSection() {
    return _buildExpandableSection(
      'status',
      'Estado de Clientes',
      Icons.people_outline,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona estados:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ClientStatus.values.map((status) {
              final isSelected = _localFilter.statuses.contains(status);
              return _buildFilterChip(
                status.displayName,
                isSelected,
                status.color,
                () => _toggleStatus(status),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return _buildExpandableSection(
      'tags',
      'Etiquetas',
      Icons.label_outline,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.availableTags.isNotEmpty) ...[
            const Text(
              'Etiquetas disponibles:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.availableTags.map((tag) {
                final isSelected = _localFilter.tags.contains(tag);
                final isBaseTag = ClientConstants.isBaseTag(tag);
                final color = isBaseTag
                    ? ClientConstants.getBaseTagColor(tag)
                    : kBrandPurple;
                return _buildFilterChip(
                  tag,
                  isSelected,
                  color,
                  () => _toggleTag(tag),
                );
              }).toList(),
            ),
          ] else
            const Text(
              'No hay etiquetas disponibles',
              style: TextStyle(
                fontSize: 14,
                color: kTextSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return _buildExpandableSection(
      'location',
      'Ubicación',
      Icons.location_on_outlined,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.availableAlcaldias.isNotEmpty) ...[
            const Text(
              'Alcaldías disponibles:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.availableAlcaldias.map((alcaldia) {
                final isSelected = _localFilter.alcaldias.contains(alcaldia);
                return _buildFilterChip(
                  alcaldia,
                  isSelected,
                  kAccentBlue,
                  () => _toggleAlcaldia(alcaldia),
                );
              }).toList(),
            ),
          ] else
            const Text(
              'No hay ubicaciones disponibles',
              style: TextStyle(
                fontSize: 14,
                color: kTextSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
      iconColor: kAccentBlue,
    );
  }

  Widget _buildAppointmentsSection() {
    return _buildExpandableSection(
      'appointments',
      'Actividad de Citas',
      Icons.event_outlined,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Número mínimo de citas:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _minAppointmentsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Mínimo de citas',
              hintText: 'Ej: 5',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: _updateMinAppointments,
          ),
        ],
      ),
      iconColor: kWarningColor,
    );
  }

  Widget _buildDateSection() {
    return _buildExpandableSection(
      'date',
      'Rango de Fechas',
      Icons.date_range_outlined,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona rango de fechas:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              _localFilter.dateRange != null
                  ? '${_formatDate(_localFilter.dateRange!.start)} - ${_formatDate(_localFilter.dateRange!.end)}'
                  : 'Seleccionar rango',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
          if (_localFilter.dateRange != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _clearDateRange,
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Limpiar fechas'),
              style: TextButton.styleFrom(
                foregroundColor: kErrorColor,
              ),
            ),
          ],
        ],
      ),
      iconColor: kSuccessColor,
    );
  }

  Widget _buildSavedFiltersSection() {
    return _buildExpandableSection(
      'saved',
      'Filtros Guardados',
      Icons.bookmark_outline,
      const Column(
        children: [
          Text(
            'Próximamente: Guarda y reutiliza tus filtros favoritos',
            style: TextStyle(
              fontSize: 14,
              color: kTextSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      iconColor: kBrandPurple,
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: kBorderSoft),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _resetAllFilters,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kTextSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Limpiar Filtros',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Aplicar Filtros',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // 🎯 MÉTODOS DE LÓGICA DE NEGOCIO
  // ====================================================================

  void _toggleSection(String key) {
    setState(() {
      _expandedSections[key] = !(_expandedSections[key] ?? false);
    });
  }

  void _toggleStatus(ClientStatus status) {
    final newStatuses = List<ClientStatus>.from(_localFilter.statuses);
    if (newStatuses.contains(status)) {
      newStatuses.remove(status);
    } else {
      newStatuses.add(status);
    }

    setState(() {
      _localFilter = _localFilter.copyWith(statuses: newStatuses);
    });
  }

  void _toggleTag(String tag) {
    final newTags = List<String>.from(_localFilter.tags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }

    setState(() {
      _localFilter = _localFilter.copyWith(tags: newTags);
    });
  }

  void _toggleAlcaldia(String alcaldia) {
    final newAlcaldias = List<String>.from(_localFilter.alcaldias);
    if (newAlcaldias.contains(alcaldia)) {
      newAlcaldias.remove(alcaldia);
    } else {
      newAlcaldias.add(alcaldia);
    }

    setState(() {
      _localFilter = _localFilter.copyWith(alcaldias: newAlcaldias);
    });
  }

  void _updateMinAppointments(String value) {
    final intValue = int.tryParse(value);
    setState(() {
      _localFilter = _localFilter.copyWith(minAppointments: intValue);
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
      initialDateRange: _localFilter.dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: kBrandPurple,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _localFilter = _localFilter.copyWith(dateRange: picked);
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _localFilter = _localFilter.copyWith(dateRange: null);
    });
  }

  void _applyFilters() {
    widget.onFilterChanged(_localFilter);
    Navigator.of(context).pop();
  }

  void _resetAllFilters() {
    setState(() {
      _localFilter = const ClientFilterCriteria();
      _minAppointmentsController.clear();
    });
    widget.onResetFilters();
  }

  int _getActiveFiltersCount() {
    int count = 0;

    if (_localFilter.statuses.isNotEmpty) count++;
    if (_localFilter.tags.isNotEmpty) count++;
    if (_localFilter.alcaldias.isNotEmpty) count++;
    if (_localFilter.minAppointments != null) count++;
    if (_localFilter.dateRange != null) count++;

    return count;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
