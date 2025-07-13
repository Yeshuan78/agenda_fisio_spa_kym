// [monthly_calendar_view.dart] - VISTA MENSUAL PROFESIONAL SIMPLIFICADA
// 📁 Ubicación: /lib/widgets/agenda/monthly_calendar_view.dart
// 📅 VISTA MENSUAL LIMPIA Y FUNCIONAL
// ✅ Sin redundancias, solo funcionalidad esencial

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';

class MonthlyCalendarView extends StatefulWidget {
  final DateTime selectedDay;
  final Map<DateTime, List<AppointmentModel>> appointments;
  final Map<DateTime, List<Map<String, dynamic>>> bloqueos;
  final List<Map<String, dynamic>> resources; // ✅ PARÁMETRO AGREGADO
  final Function(AppointmentModel, DateTime, String?) onAppointmentMove;
  final Function(AppointmentModel) onAppointmentEdit;
  final Function(DateTime, String?) onAppointmentCreate;
  final Function(DateTime) onDaySelected;
  final Function(DateTime)? onMonthChanged;

  const MonthlyCalendarView({
    super.key,
    required this.selectedDay,
    required this.appointments,
    required this.bloqueos,
    required this.resources,
    required this.onAppointmentMove,
    required this.onAppointmentEdit,
    required this.onAppointmentCreate,
    required this.onDaySelected,
    this.onMonthChanged,
  });

  @override
  State<MonthlyCalendarView> createState() => _MonthlyCalendarViewState();
}

class _MonthlyCalendarViewState extends State<MonthlyCalendarView>
    with TickerProviderStateMixin {
  // 🎯 ANIMACIONES PROFESIONALES
  late AnimationController _monthTransitionController;
  late AnimationController _hoverController;
  late AnimationController _pulseController;
  late AnimationController _slideController;

  late Animation<double> _monthTransitionAnimation;
  late Animation<double> _hoverAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  List<DateTime> _monthDays = [];
  DateTime _displayedMonth = DateTime.now();
  DateTime? _hoveredDate;
  DateTime? _selectedDateForMenu;

  // 🎯 ESTADO PARA QUICK ADD
  bool _showQuickAdd = false;
  String? _quickAddResourceId;

  @override
  void initState() {
    super.initState();
    _displayedMonth =
        DateTime(widget.selectedDay.year, widget.selectedDay.month);
    _initAnimations();
    _generateMonthData();
  }

  @override
  void didUpdateWidget(MonthlyCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newMonth =
        DateTime(widget.selectedDay.year, widget.selectedDay.month);
    if (_displayedMonth != newMonth) {
      _animateToMonth(newMonth);
    }
  }

  @override
  void dispose() {
    _monthTransitionController.dispose();
    _hoverController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // 🎨 INICIALIZACIÓN DE ANIMACIONES
  void _initAnimations() {
    _monthTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _monthTransitionAnimation = CurvedAnimation(
      parent: _monthTransitionController,
      curve: Curves.easeInOutCubic,
    );

    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Pulso sutil para fecha actual
    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  // 🗓️ GENERACIÓN DE DATOS DEL MES
  void _generateMonthData() {
    _monthDays.clear();

    final firstDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);

    // Empezar desde el lunes de la semana que contiene el primer día
    final startDate = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday - 1),
    );

    // Generar 42 días (6 semanas completas)
    for (int i = 0; i < 42; i++) {
      _monthDays.add(startDate.add(Duration(days: i)));
    }

    debugPrint(
        '📅 MonthlyCalendarView: Generados ${_monthDays.length} días para ${DateFormat('MMMM yyyy', 'es').format(_displayedMonth)}');
  }

  // 🔄 ANIMACIÓN DE TRANSICIÓN DE MES
  void _animateToMonth(DateTime newMonth) {
    setState(() => _displayedMonth = newMonth);
    _generateMonthData();

    _monthTransitionController.forward().then((_) {
      _monthTransitionController.reset();
    });
  }

  // 📋 OBTENER DATOS PARA UN DÍA
  List<AppointmentModel> _getAppointmentsForDay(DateTime day) {
    final dayKey = DateTime(day.year, day.month, day.day);
    return widget.appointments[dayKey] ?? [];
  }

  List<Map<String, dynamic>> _getBloqueosForDay(DateTime day) {
    final dayKey = DateTime(day.year, day.month, day.day);
    return widget.bloqueos[dayKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthHeaderProfessional(),
        _buildWeekdaysHeaderProfessional(),
        Expanded(child: _buildMonthGridProfessional()),
        if (_showQuickAdd) _buildQuickAddPanel(),
      ],
    );
  }

  // 📋 HEADER MENSUAL PROFESIONAL - ALTURA OPTIMIZADA
  Widget _buildMonthHeaderProfessional() {
    return Container(
      height: 90, // ✅ REDUCIDO: 100 → 90 para evitar overflow
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ ESTADÍSTICAS LIMPIAS - ELIMINAR DUPLICADO
          Container(
            width: 250,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vista Mensual',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kBrandPurple,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildStatChip(
                            '${_getMonthAppointmentCount()}',
                            'Citas',
                            kAccentGreen,
                          ),
                          const SizedBox(width: 8),
                          _buildStatChip(
                            '${widget.resources.length}',
                            'Recursos',
                            kAccentBlue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✅ NAVEGACIÓN DE MES
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNavigationButton(
                  icon: Icons.chevron_left,
                  onTap: () => _navigateMonth(-1),
                  tooltip: 'Mes anterior',
                ),

                const SizedBox(width: 12), // ✅ REDUCIDO: 16 → 12

                // ✅ SELECTOR PRINCIPAL DE MES/AÑO - SIN REDUNDANCIA
                GestureDetector(
                  onTap: _showMonthYearPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10), // ✅ REDUCIDO
                    decoration: BoxDecoration(
                      color: kBrandPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                          color: kBrandPurple.withValues(alpha: 0.25),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: kBrandPurple.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.date_range,
                            color: kBrandPurple,
                            size: 16), // ✅ REDUCIDO: 18 → 16
                        const SizedBox(width: 10), // ✅ REDUCIDO: 12 → 10
                        Text(
                          DateFormat('MMMM yyyy', 'es').format(_displayedMonth),
                          style: TextStyle(
                            fontSize: 15, // ✅ REDUCIDO: 16 → 15
                            fontWeight: FontWeight.bold,
                            color: kBrandPurple,
                          ),
                        ),
                        const SizedBox(width: 6), // ✅ REDUCIDO: 8 → 6
                        Icon(Icons.expand_more,
                            color: kBrandPurple,
                            size: 16), // ✅ REDUCIDO: 18 → 16
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12), // ✅ REDUCIDO: 16 → 12

                _buildNavigationButton(
                  icon: Icons.chevron_right,
                  onTap: () => _navigateMonth(1),
                  tooltip: 'Mes siguiente',
                ),
              ],
            ),
          ),

          // ✅ ESPACIO VACÍO - SIN DUPLICADO
          Container(
            width: 160,
            padding: const EdgeInsets.all(12),
            child: SizedBox.shrink(), // ✅ ESPACIO VACÍO PARA BALANCE VISUAL
          ),
        ],
      ),
    );
  }

  // 📅 HEADER DE DÍAS DE LA SEMANA - ALTURA OPTIMIZADA
  Widget _buildWeekdaysHeaderProfessional() {
    const weekdays = ['LUN', 'MAR', 'MIE', 'JUE', 'VIE', 'SAB', 'DOM'];

    return Container(
      height: 40, // ✅ REDUCIDO: 45 → 40
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: weekdays.map((day) {
          final isWeekend = day == 'SAB' || day == 'DOM';
          return Expanded(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade200, width: 0.5),
                ),
              ),
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 11, // ✅ REDUCIDO: 12 → 11
                  fontWeight: FontWeight.w600,
                  color: isWeekend ? kAccentGreen : Colors.grey.shade700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 🗓️ GRID MENSUAL PROFESIONAL
  Widget _buildMonthGridProfessional() {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: _monthTransitionAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.95 + (0.05 * _monthTransitionAnimation.value),
            child: Opacity(
              opacity: 0.7 + (0.3 * _monthTransitionAnimation.value),
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.3, // ✅ Más alto para mostrar más citas
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _monthDays.length,
                itemBuilder: (context, index) {
                  final day = _monthDays[index];
                  return _buildDayCellProfessional(day);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // 📱 CELDA DE DÍA PROFESIONAL CON FUNCIONALIDADES COMPLETAS
  Widget _buildDayCellProfessional(DateTime day) {
    final appointments = _getAppointmentsForDay(day);
    final bloqueos = _getBloqueosForDay(day);
    final isToday = _isSameDay(day, DateTime.now());
    final isSelected = _isSameDay(day, widget.selectedDay);
    final isCurrentMonth = _isCurrentMonth(day);
    final appointmentCount = appointments.length;
    final blockCount = bloqueos.length;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hoveredDate = day);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _hoveredDate = null);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: () {
          if (isCurrentMonth) {
            widget.onDaySelected(day);
            HapticFeedback.selectionClick();

            // ✅ MOSTRAR MENÚ DE OPCIONES SIMPLE
            Future.delayed(const Duration(milliseconds: 150), () {
              if (mounted) {
                _showDayOptionsMenu(day);
              }
            });
          }
        },
        onLongPress: () {
          if (isCurrentMonth) {
            // Long press siempre muestra el menú completo
            _showDayOptionsMenu(day);
          }
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverAnimation, _pulseAnimation]),
          builder: (context, child) {
            final isHovered =
                _hoveredDate != null && _isSameDay(_hoveredDate!, day);
            final scale = isSelected && isToday
                ? _pulseAnimation.value
                : isHovered
                    ? _hoverAnimation.value
                    : 1.0;

            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  color: _getDayCellColor(
                      isSelected, isToday, isCurrentMonth, isHovered),
                  borderRadius: BorderRadius.circular(8),
                  border: _getDayCellBorder(isSelected, isToday, isHovered),
                  boxShadow: _getDayCellShadow(isSelected, isToday, isHovered),
                ),
                child: Column(
                  children: [
                    // Header del día
                    Container(
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.2)
                            : null,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: _getDayTextColor(
                                  isSelected, isToday, isCurrentMonth),
                            ),
                          ),
                          if (appointmentCount > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : kAccentGreen.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$appointmentCount',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? kAccentGreen : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Área de contenido expandida
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: Column(
                          children: [
                            // Citas (máximo 3 visibles)
                            if (appointmentCount > 0)
                              Expanded(
                                  child: _buildAppointmentsList(
                                      appointments, isSelected)),

                            // Indicadores de bloqueos
                            if (blockCount > 0)
                              _buildBlockIndicator(blockCount, isSelected),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 📋 LISTA DE CITAS MEJORADA
  Widget _buildAppointmentsList(
      List<AppointmentModel> appointments, bool isSelected) {
    final displayCount = appointments.length > 3 ? 3 : appointments.length;

    return Column(
      children: [
        ...appointments.take(displayCount).map((appointment) {
          return Container(
            width: double.infinity,
            height: 16,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: _getAppointmentColor(appointment),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color:
                      _getAppointmentColor(appointment).withValues(alpha: 0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      appointment.nombreCliente ?? 'Sin nombre',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (appointment.fechaInicio != null)
                    Text(
                      DateFormat('HH:mm').format(appointment.fechaInicio!),
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),

        // Indicador de más citas
        if (appointments.length > 3)
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '+${appointments.length - 3} más',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.grey.shade700 : Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 🚫 INDICADOR DE BLOQUEOS
  Widget _buildBlockIndicator(int blockCount, bool isSelected) {
    return Container(
      width: double.infinity,
      height: 14,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.red.shade100
            : Colors.red.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.red.shade600,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          blockCount > 1 ? '$blockCount Bloqueados' : 'Bloqueado',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.red.shade700 : Colors.white,
          ),
        ),
      ),
    );
  }

  // 🎨 COMPONENTES AUXILIARES
  Widget _buildStatChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kBrandPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: kBrandPurple,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  // 🚀 PANEL DE CREACIÓN RÁPIDA - ALTURA OPTIMIZADA
  Widget _buildQuickAddPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showQuickAdd ? 100 : 0, // ✅ REDUCIDO: 120 → 100
      decoration: BoxDecoration(
        color: kBrandPurple.withValues(alpha: 0.05),
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: _showQuickAdd
          ? Padding(
              padding: const EdgeInsets.all(12), // ✅ REDUCIDO: 16 → 12
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚡ Creación Rápida - Selecciona recurso y luego haz clic en un día',
                    style: TextStyle(
                      fontSize: 13, // ✅ REDUCIDO: 14 → 13
                      fontWeight: FontWeight.w600,
                      color: kBrandPurple,
                    ),
                  ),
                  const SizedBox(height: 8), // ✅ REDUCIDO: 12 → 8
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.resources.length,
                      itemBuilder: (context, index) {
                        final resource = widget.resources[index];
                        final isSelected =
                            _quickAddResourceId == resource['id'];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _quickAddResourceId =
                                  isSelected ? null : resource['id'];
                            });
                            HapticFeedback.selectionClick();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                right: 10), // ✅ REDUCIDO: 12 → 10
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6), // ✅ REDUCIDO
                            decoration: BoxDecoration(
                              color: isSelected ? kBrandPurple : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? kBrandPurple
                                    : Colors.grey.shade300,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color:
                                            kBrandPurple.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                resource['nombre'] ?? 'Sin nombre',
                                style: TextStyle(
                                  fontSize: 11, // ✅ REDUCIDO: 12 → 11
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  // 🎯 FUNCIONES DE INTERACCIÓN
  void _toggleQuickAdd() {
    setState(() {
      _showQuickAdd = !_showQuickAdd;
      if (!_showQuickAdd) {
        _quickAddResourceId = null;
      }
    });
    HapticFeedback.lightImpact();
  }

  void _createDefaultAppointment(DateTime day) {
    if (widget.resources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay recursos disponibles'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    // ✅ USAR APPOINTMENT DIALOG CON PRIMER RECURSO
    final firstResource = widget.resources.first;
    _showAppointmentDialog(day, resourceId: firstResource['id']);
  }

  void _createQuickAppointment(DateTime day) {
    if (_quickAddResourceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecciona un recurso primero'),
          backgroundColor: Colors.orange.shade600,
        ),
      );
      return;
    }

    // ✅ USAR APPOINTMENT DIALOG CON RECURSO PRESELECCIONADO
    _showAppointmentDialog(day, resourceId: _quickAddResourceId!);
  }

  void _showDayOptionsMenu(DateTime day) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        width: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
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
                  Text(
                    DateFormat('EEEE dd MMMM yyyy', 'es').format(day),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kBrandPurple,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Opciones de acciones con iconos mejorados
                  _buildMenuOption(
                    icon: Icons.add_circle_outline,
                    title: 'Nueva Cita',
                    subtitle: 'Crear nueva cita',
                    color: kAccentGreen,
                    onTap: () {
                      Navigator.pop(context);
                      _showAppointmentDialog(day);
                    },
                  ),

                  _buildMenuOption(
                    icon: Icons.block,
                    title: 'Bloquear Horario',
                    subtitle: 'Bloquear disponibilidad',
                    color: Colors.red.shade600,
                    onTap: () {
                      Navigator.pop(context);
                      _showBlockDialog(day);
                    },
                  ),

                  if (_getAppointmentsForDay(day).isNotEmpty)
                    _buildMenuOption(
                      icon: Icons.list,
                      title:
                          'Ver Citas (${_getAppointmentsForDay(day).length})',
                      subtitle: 'Ver todas las citas del día',
                      color: kBrandPurple,
                      onTap: () {
                        Navigator.pop(context);
                        _showDayAppointments(day);
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 FUNCIÓN PRINCIPAL PARA MOSTRAR APPOINTMENT DIALOG - SIMPLIFICADA
  void _showAppointmentDialog(DateTime day, {String? resourceId}) {
    final appointmentDateTime = DateTime(
      day.year,
      day.month,
      day.day,
      9, // 9:00 AM por defecto
      0,
    );

    // ✅ USAR EL CALLBACK DIRECTO QUE YA FUNCIONA
    widget.onAppointmentCreate(appointmentDateTime, resourceId);

    // Feedback inmediato
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Abriendo formulario de cita para ${DateFormat('dd/MM/yyyy').format(day)}',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: kAccentGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 🔧 FUNCIONES SIMPLIFICADAS - REMOVEMOS COMPLEJIDAD INNECESARIA
  void _showTimeSelector(DateTime day, String resourceId) {
    // ✅ SIMPLIFICADO: Solo abrir AppointmentDialog con recurso preseleccionado
    _showAppointmentDialog(day, resourceId: resourceId);
  }

  void _showBlockDialog(DateTime day) {
    // ✅ USAR CALLBACK DIRECTO PARA BLOQUEOS
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funcionalidad de bloqueo disponible próximamente'),
        backgroundColor: Colors.orange.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDayAppointments(DateTime day) {
    final appointments = _getAppointmentsForDay(day);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
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
                  Text(
                    'Citas del Día',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kBrandPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${DateFormat('EEEE dd MMMM yyyy', 'es').format(day)} - ${appointments.length} citas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getAppointmentColor(appointment)
                          .withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getAppointmentColor(appointment)
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getAppointmentColor(appointment),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.nombreCliente ?? 'Sin nombre',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (appointment.servicioNombre != null)
                                Text(
                                  appointment.servicioNombre!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              if (appointment.fechaInicio != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('HH:mm')
                                          .format(appointment.fechaInicio!),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getAppointmentColor(appointment),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            appointment.estado ?? 'Sin estado',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🔧 FUNCIONES AUXILIARES SIMPLIFICADAS
  List<DateTime> _generateTimeSlots() {
    // Simplificado - no se usa ya que delegamos al AppointmentDialog
    return [];
  }

  bool _isTimeSlotAvailable(
      DateTime day, DateTime timeSlot, String resourceId) {
    // Simplificado - la validación se hace en el AppointmentDialog
    return true;
  }

  IconData _getResourceIcon(String? tipo) {
    switch (tipo) {
      case 'profesional':
        return Icons.person;
      case 'cabina':
        return Icons.room;
      case 'servicio':
        return Icons.spa;
      case 'evento':
        return Icons.event;
      default:
        return Icons.category;
    }
  }

  // 🎨 ESTILOS Y COLORES
  Color _getDayCellColor(
      bool isSelected, bool isToday, bool isCurrentMonth, bool isHovered) {
    if (isSelected) {
      return isToday ? kAccentGreen : kBrandPurple;
    }

    if (isToday) {
      return kAccentGreen.withValues(alpha: 0.1);
    }

    if (isHovered && isCurrentMonth) {
      return kBrandPurple.withValues(alpha: 0.06);
    }

    if (!isCurrentMonth) {
      return Colors.grey.shade100;
    }

    return Colors.white;
  }

  Border? _getDayCellBorder(bool isSelected, bool isToday, bool isHovered) {
    if (isToday && !isSelected) {
      return Border.all(color: kAccentGreen, width: 2);
    }

    if (isHovered) {
      return Border.all(color: kBrandPurple.withValues(alpha: 0.3), width: 1);
    }

    return Border.all(color: Colors.grey.shade200, width: 0.5);
  }

  List<BoxShadow>? _getDayCellShadow(
      bool isSelected, bool isToday, bool isHovered) {
    if (isSelected) {
      return [
        BoxShadow(
          color:
              (isToday ? kAccentGreen : kBrandPurple).withValues(alpha: 0.25),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    if (isHovered) {
      return [
        BoxShadow(
          color: kBrandPurple.withValues(alpha: 0.12),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return null;
  }

  Color _getDayTextColor(bool isSelected, bool isToday, bool isCurrentMonth) {
    if (isSelected) {
      return Colors.white;
    }

    if (!isCurrentMonth) {
      return Colors.grey.shade400;
    }

    if (isToday) {
      return kAccentGreen;
    }

    return Colors.black87;
  }

  Color _getAppointmentColor(AppointmentModel appointment) {
    switch (appointment.estado?.toLowerCase()) {
      case 'confirmado':
        return kAccentGreen;
      case 'reservado':
        return Colors.orange.shade600;
      case 'cancelado':
        return Colors.red.shade600;
      case 'pendiente':
        return Colors.blue.shade600;
      default:
        return kBrandPurple;
    }
  }

  // 🔄 NAVEGACIÓN Y UTILIDADES
  void _navigateMonth(int direction) {
    final newMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + direction,
    );

    _animateToMonth(newMonth);
    widget.onMonthChanged?.call(newMonth);
    HapticFeedback.lightImpact();
  }

  void _showMonthYearPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _displayedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'MX'),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      _animateToMonth(picked);
      widget.onMonthChanged?.call(picked);
    }
  }

  // 📊 UTILIDADES
  int _getMonthAppointmentCount() {
    int count = 0;
    for (final day in _monthDays) {
      if (_isCurrentMonth(day)) {
        count += _getAppointmentsForDay(day).length;
      }
    }
    return count;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isCurrentMonth(DateTime day) {
    return day.month == _displayedMonth.month &&
        day.year == _displayedMonth.year;
  }
}
