// [agenda_filters_panel.dart]
// 📁 Ubicación: /lib/widgets/agenda/agenda_filters_panel.dart
// 🎛️ PANEL DE FILTROS Y CONTROLES AVANZADOS PARA AGENDA

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class AgendaFiltersPanel extends StatefulWidget {
  final String selectedView;
  final String selectedResource;
  final DateTime selectedDay;
  final String searchQuery;
  final Function(String) onViewChanged;
  final Function(String) onResourceChanged;
  final Function(DateTime) onDayChanged;
  final Function(String) onSearchChanged;

  const AgendaFiltersPanel({
    super.key,
    required this.selectedView,
    required this.selectedResource,
    required this.selectedDay,
    required this.searchQuery,
    required this.onViewChanged,
    required this.onResourceChanged,
    required this.onDayChanged,
    required this.onSearchChanged,
  });

  @override
  State<AgendaFiltersPanel> createState() => _AgendaFiltersPanelState();
}

class _AgendaFiltersPanelState extends State<AgendaFiltersPanel>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kBorderColor.withValues(alpha: 0.02),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.006),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ HEADER CON CONTROLES PRINCIPALES
          _buildMainHeader(),

          // ✅ FILTROS EXPANDIBLES
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            child:
                _isExpanded ? _buildExpandedFilters() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ✅ FILA PRINCIPAL
          Row(
            children: [
              // ✅ BÚSQUEDA
              Expanded(
                flex: 3,
                child: _buildSearchField(),
              ),

              const SizedBox(width: 16),

              // ✅ SELECTOR DE VISTA
              Expanded(
                flex: 2,
                child: _buildViewSelector(),
              ),

              const SizedBox(width: 16),

              // ✅ SELECTOR DE RECURSOS
              Expanded(
                flex: 2,
                child: _buildResourceSelector(),
              ),

              const SizedBox(width: 16),

              // ✅ NAVEGACIÓN DE FECHA
              _buildDateNavigation(),

              const SizedBox(width: 16),

              // ✅ BOTÓN EXPANDIR
              _buildExpandButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kBrandPurpleLight.withValues(alpha: 0.01),
            kAccentBlue.withValues(alpha: 0.005),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kBrandPurple.withValues(alpha: 0.02),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: widget.onSearchChanged,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar citas, clientes, profesionales...',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kBrandPurple, kAccentBlue],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 18,
            ),
          ),
          suffixIcon: widget.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildViewSelector() {
    return _buildSelector(
      'Vista',
      widget.selectedView,
      [
        {'value': 'dia', 'label': 'Día', 'icon': Icons.view_day},
        {'value': 'semana', 'label': 'Semana', 'icon': Icons.view_week},
        {'value': 'mes', 'label': 'Mes', 'icon': Icons.view_module},
      ],
      widget.onViewChanged,
      kAccentBlue,
    );
  }

  Widget _buildResourceSelector() {
    return _buildSelector(
      'Recurso',
      widget.selectedResource,
      [
        {
          'value': 'profesionales',
          'label': 'Profesionales',
          'icon': Icons.people
        },
        {'value': 'cabinas', 'label': 'Cabinas', 'icon': Icons.room},
        {'value': 'mixto', 'label': 'Mixto', 'icon': Icons.view_comfy},
      ],
      widget.onResourceChanged,
      kAccentGreen,
    );
  }

  Widget _buildSelector(
    String title,
    String selectedValue,
    List<Map<String, dynamic>> options,
    Function(String) onChanged,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.005),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.02),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: color,
                size: 20,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              borderRadius: BorderRadius.circular(12),
              items: options.map((option) {
                final isSelected = option['value'] == selectedValue;
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Row(
                    children: [
                      Icon(
                        option['icon'],
                        size: 16,
                        color: isSelected ? color : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        option['label'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? color : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                  HapticFeedback.selectionClick();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: kBrandPurple.withValues(alpha: 0.005),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kBrandPurple.withValues(alpha: 0.02),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ BOTÓN ANTERIOR
          IconButton(
            onPressed: () => _navigateDate(-1),
            icon: const Icon(Icons.chevron_left),
            color: kBrandPurple,
            tooltip: 'Anterior',
          ),

          // ✅ FECHA ACTUAL
          GestureDetector(
            onTap: _showDatePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMM', 'es_MX')
                        .format(widget.selectedDay)
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: kBrandPurple,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    DateFormat('dd').format(widget.selectedDay),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kBrandPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ BOTÓN SIGUIENTE
          IconButton(
            onPressed: () => _navigateDate(1),
            icon: const Icon(Icons.chevron_right),
            color: kBrandPurple,
            tooltip: 'Siguiente',
          ),
        ],
      ),
    );
  }

  Widget _buildExpandButton() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _toggleExpanded,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isExpanded
                ? kBrandPurple.withValues(alpha: 0.01)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isExpanded
                  ? kBrandPurple.withValues(alpha: 0.03)
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              Icons.tune,
              color: _isExpanded ? kBrandPurple : Colors.grey.shade600,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedFilters() {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _expandAnimation,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                const Divider(
                  color: kBorderColor,
                  thickness: 1,
                ),
                const SizedBox(height: 16),

                // ✅ FILTROS AVANZADOS
                Row(
                  children: [
                    Expanded(
                      child: _buildAdvancedFilter(
                        'Estado de Citas',
                        ['Todas', 'Confirmadas', 'Pendientes', 'Canceladas'],
                        'Todas',
                        Icons.assignment_turned_in,
                        kAccentGreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAdvancedFilter(
                        'Tipo de Servicio',
                        ['Todos', 'Individual', 'Corporativo', 'Eventos'],
                        'Todos',
                        Icons.medical_services,
                        kAccentBlue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAdvancedFilter(
                        'Especialidad',
                        ['Todas', 'Fisioterapia', 'Masajes', 'Podología'],
                        'Todas',
                        Icons.healing,
                        Colors.orange.shade600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ✅ ACCIONES RÁPIDAS
                Row(
                  children: [
                    _buildQuickAction(
                      'Hoy',
                      Icons.today,
                      () => widget.onDayChanged(DateTime.now()),
                      kBrandPurple,
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAction(
                      'Esta Semana',
                      Icons.view_week,
                      () => _goToCurrentWeek(),
                      kAccentBlue,
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAction(
                      'Limpiar Filtros',
                      Icons.clear_all,
                      () => _clearAllFilters(),
                      Colors.grey.shade600,
                    ),
                    const Spacer(),
                    _buildQuickAction(
                      'Exportar',
                      Icons.file_download,
                      () => _exportData(),
                      kAccentGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedFilter(
    String title,
    List<String> options,
    String selectedValue,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.005),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.02),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: color, size: 18),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              borderRadius: BorderRadius.circular(12),
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                // TODO: Implementar lógica de filtro
                HapticFeedback.selectionClick();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    String label,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.01),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.03),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ MÉTODOS DE NAVEGACIÓN Y ACCIONES
  void _navigateDate(int days) {
    final newDate = widget.selectedDay.add(Duration(days: days));
    widget.onDayChanged(newDate);
    HapticFeedback.selectionClick();
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDay,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'MX'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: kBrandPurple,
                  onSurface: Colors.black87,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDayChanged(picked);
      HapticFeedback.selectionClick();
    }
  }

  void _goToCurrentWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    widget.onDayChanged(startOfWeek);
    HapticFeedback.lightImpact();
  }

  void _clearAllFilters() {
    _searchController.clear();
    widget.onSearchChanged('');
    widget.onViewChanged('semana');
    widget.onResourceChanged('profesionales');
    widget.onDayChanged(DateTime.now());
    HapticFeedback.mediumImpact();
  }

  void _exportData() {
    // TODO: Implementar exportación de datos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de exportación en desarrollo'),
        backgroundColor: kAccentGreen,
      ),
    );
    HapticFeedback.lightImpact();
  }
}
