// [datetime_selection_step.dart] - ✨ STEP SELECCIÓN FECHA/HORA CON 3 PESTAÑAS PREMIUM
// 📁 Ubicación: /lib/widgets/booking/steps/datetime_selection_step.dart
// 🎯 OBJETIVO: 3 modos - PARTICULAR (3 Pestañas) + EMPRESA/EVENTO (Time Slots)
// ✅ FIX: Mostrar selección visual antes de avanzar al siguiente paso

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/enums/booking_types.dart';
import 'package:agenda_fisio_spa_kym/widgets/booking/components/booking_step_header.dart';
import 'package:agenda_fisio_spa_kym/widgets/booking/components/event_date_display.dart';
import 'package:agenda_fisio_spa_kym/widgets/booking/components/date_picker_field.dart';
import 'package:agenda_fisio_spa_kym/widgets/booking/components/time_slot_grid_widget.dart';

class DateTimeSelectionStep extends StatefulWidget {
  final Color accentColor;
  final Map<String, dynamic>? selectedEventData;
  final DateTime? selectedDate;
  final String? selectedTime;
  final List<String> timeSlots;
  final Function(DateTime) onDateSelected;
  final Function(String) onTimeSelected;

  const DateTimeSelectionStep({
    super.key,
    required this.accentColor,
    this.selectedEventData,
    this.selectedDate,
    this.selectedTime,
    required this.timeSlots,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  State<DateTimeSelectionStep> createState() => _DateTimeSelectionStepState();
}

class _DateTimeSelectionStepState extends State<DateTimeSelectionStep>
    with TickerProviderStateMixin {
  // ✅ CONTROLADORES PARA CUSTOM SLIDING PICKER
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  // ✅ VALORES PARA PARTICULAR MODE
  int _selectedHour = 9; // Default 9 AM
  int _selectedMinute = 0; // Default :00

  // ✅ ANIMACIONES
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 🆕 NUEVO: CONTROLADOR DE PESTAÑAS
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // ✅ FIX: VARIABLE PARA MOSTRAR SELECCIÓN TEMPORAL
  String? _temporarySelectedTime;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _initializeTabs();
    _parseSelectedTime();
  }

  void _initializeControllers() {
    _hourController =
        FixedExtentScrollController(initialItem: _selectedHour - 9);
    _minuteController =
        FixedExtentScrollController(initialItem: _selectedMinute ~/ 15);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
  }

  // 🆕 NUEVO: INICIALIZAR PESTAÑAS
  void _initializeTabs() {
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  void _parseSelectedTime() {
    if (widget.selectedTime != null && _isParticularMode()) {
      try {
        final timeParts = widget.selectedTime!.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        if (hour >= 9 && hour <= 21) {
          _selectedHour = hour;
          _selectedMinute = minute;

          // Actualizar controladores
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _hourController.animateToItem(
              _selectedHour - 9,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
            _minuteController.animateToItem(
              _selectedMinute ~/ 15,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }
      } catch (e) {
        debugPrint('Error parsing selected time: $e');
      }
    }
  }

  // ✅ FIX: NUEVO MÉTODO PARA MANEJAR SELECCIÓN CON DELAY VISUAL
  void _handleTimeSlotSelection(String timeSlot) async {
    // Primero mostrar la selección visual
    setState(() {
      _temporarySelectedTime = timeSlot;
    });

    // Esperar un momento para que el usuario vea la selección
    await Future.delayed(const Duration(milliseconds: 700));

    // Luego ejecutar el callback original que avanza al siguiente paso
    if (mounted) {
      widget.onTimeSelected(timeSlot);
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _fadeController.dispose();
    _tabController.dispose(); // 🆕 NUEVO
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(_getContainerPadding(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_getBorderRadius(context)),
          boxShadow: kSombraCard,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ HEADER LIMPIO
            _buildCleanHeader(),
            SizedBox(height: _getSectionSpacing(context)),

            // 📅 FECHA DEL EVENTO O SELECTOR DE FECHA
            _buildDateSelection(),
            SizedBox(height: _getContentSpacing(context)),

            // ⏰ SELECCIÓN DE HORA SEGÚN TIPO DE BOOKING
            _buildTimeSelection(),
          ],
        ),
      ),
    );
  }

  /// ✅ HEADER LIMPIO CON INFORMACIÓN CONTEXTUAL
  Widget _buildCleanHeader() {
    String title = 'Fecha y horario';
    String subtitle;

    if (_isParticularMode()) {
      subtitle = 'Elige cuándo prefieres tu servicio';
    } else if (widget.selectedEventData != null) {
      subtitle = 'Horarios disponibles para el evento';
    } else {
      subtitle = 'Selecciona tu horario preferido';
    }

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: _getTitleFontSize(context),
            fontWeight: FontWeight.w700,
            color: widget.accentColor,
            fontFamily: kFontFamily,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: _getTextSpacing(context)),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: _getSubtitleFontSize(context),
            color: kTextSecondary,
            fontFamily: kFontFamily,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 📅 SELECCIÓN DE FECHA
  Widget _buildDateSelection() {
    if (widget.selectedEventData != null) {
      // Mostrar fecha del evento
      return EventDateDisplay(selectedEventData: widget.selectedEventData);
    } else {
      // Selector de fecha libre
      return DatePickerField(
        selectedDate: widget.selectedDate,
        accentColor: widget.accentColor,
        onDateSelected: widget.onDateSelected,
      );
    }
  }

  /// ⏰ SELECCIÓN DE HORA SEGÚN TIPO
  Widget _buildTimeSelection() {
    if (_isParticularMode()) {
      return _buildTabbedTimeSlots(); // 🆕 NUEVO: Pestañas
    } else {
      return _buildTimeSlotGrid(); // ✅ EXISTENTE: Time Slots
    }
  }

  /// 🔍 DETECTAR SI ES MODO PARTICULAR
  bool _isParticularMode() {
    // ✅ LÓGICA CORREGIDA: Es particular si NO hay eventos Y la lista de timeSlots está vacía
    // El controller debe enviar lista vacía para particulares
    return widget.selectedEventData == null && widget.timeSlots.isEmpty;
  }

  /// 🆕 NUEVO: SELECTOR CON 3 PESTAÑAS PREMIUM
  Widget _buildTabbedTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ TÍTULO DE SECCIÓN
        Text(
          'Selecciona tu hora preferida',
          style: TextStyle(
            fontSize: _getSectionTitleSize(context),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: kFontFamily,
          ),
        ),
        SizedBox(height: _getContentSpacing(context)),

        // 🆕 NUEVO: TAB BAR CON BADGES
        _buildPremiumTabBar(),
        SizedBox(height: _getContentSpacing(context) * 0.5),

        // 🆕 NUEVO: TAB VIEW CON TIME SLOTS
        _buildTabViewContent(),
      ],
    );
  }

  /// 🎨 TAB BAR PREMIUM CON BADGES - ✅ FONDO AZUL DE MARCA
  Widget _buildPremiumTabBar() {
    final morningSlots = _getMorningTimeSlots();
    final afternoonSlots = _getAfternoonTimeSlots();
    final eveningSlots = _getEveningTimeSlots();

    return Container(
      height: _getTabBarHeight(context),
      decoration: BoxDecoration(
        // ✅ GLASSMORPHISM BACKGROUND CON AZUL DE MARCA
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kBrandPurple.withValues(alpha: 0.08), // ✅ AZUL EN LUGAR DE MORADO
            kBrandPurple.withValues(alpha: 0.05), // ✅ AZUL EN LUGAR DE MORADO
            Colors.white.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(_getBorderRadius(context)),
        border: Border.all(
          color: kBrandPurple.withValues(alpha: 0.2), // ✅ BORDE AZUL
          width: 1,
        ),
        boxShadow: [
          // ✅ SOMBRAS PROFUNDAS CON AZUL DE MARCA
          BoxShadow(
            color: kBrandPurple.withValues(
                alpha: 0.15), // ✅ AZUL EN LUGAR DE MORADO
            offset: const Offset(0, 6),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kBrandPurple, // ✅ INDICADOR AZUL EN LUGAR DE MORADO
              kBrandPurple.withValues(alpha: 0.8), // ✅ AZUL EN LUGAR DE MORADO
            ],
          ),
          borderRadius: BorderRadius.circular(_getBorderRadius(context) * 0.8),
          boxShadow: [
            BoxShadow(
              color: kBrandPurple.withValues(alpha: 0.4), // ✅ SOMBRA AZUL
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.all(_getTabPadding(context)),
        labelColor: Colors.white,
        unselectedLabelColor:
            kBrandPurple.withValues(alpha: 0.7), // ✅ TEXTO AZUL
        labelStyle: TextStyle(
          fontSize: _getTabFontSize(context),
          fontWeight: FontWeight.w700,
          fontFamily: kFontFamily,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: _getTabFontSize(context),
          fontWeight: FontWeight.w500,
          fontFamily: kFontFamily,
        ),
        tabs: [
          // 🌅 MAÑANA
          _buildTabWithBadge(
            icon: Icons.wb_sunny_outlined,
            label: 'Mañana',
            count: morningSlots.length,
            timeRange: '9:00 AM - 1:00 PM',
          ),
          // ☀️ TARDE
          _buildTabWithBadge(
            icon: Icons.wb_sunny,
            label: 'Tarde',
            count: afternoonSlots.length,
            timeRange: '1:30 PM - 6:00 PM',
          ),
          // 🌙 NOCHE
          _buildTabWithBadge(
            icon: Icons.nightlight_round,
            label: 'Noche',
            count: eveningSlots.length,
            timeRange: '6:30 PM - 9:00 PM',
          ),
        ],
      ),
    );
  }

  /// 🏷️ TAB CON BADGE - ✅ FIX OVERFLOW IPHONE SE
  Widget _buildTabWithBadge({
    required IconData icon,
    required String label,
    required int count,
    required String timeRange,
  }) {
    final isIPhoneSE = context.isIPhoneSE;

    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _getTabPadding(context),
          vertical: _getTabPadding(context) * 0.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ FIX: Layout adaptativo según tamaño
            if (isIPhoneSE)
              _buildCompactTabContent(icon, label, count)
            else
              _buildFullTabContent(icon, label, count),

            // ✅ Solo mostrar timeRange en pantallas grandes
            if (!isIPhoneSE) ...[
              SizedBox(height: 2),
              Text(
                timeRange,
                style: TextStyle(
                  fontSize: _getTabFontSize(context) * 0.7,
                  fontFamily: kFontFamily,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 📱 CONTENIDO COMPACTO PARA IPHONE SE
  Widget _buildCompactTabContent(IconData icon, String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Solo ícono + badge en primera línea
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: _getTabIconSize(context)),
            SizedBox(width: 2),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  fontFamily: kFontFamily,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        // Texto en segunda línea
        Text(
          label,
          style: TextStyle(
            fontSize: _getTabFontSize(context),
            fontFamily: kFontFamily,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 💻 CONTENIDO COMPLETO PARA PANTALLAS NORMALES
  Widget _buildFullTabContent(IconData icon, String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: _getTabIconSize(context)),
        SizedBox(width: _getTabSpacing(context)),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: _getTabFontSize(context),
              fontFamily: kFontFamily,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: _getTabSpacing(context) * 0.5),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: _getTabSpacing(context) * 0.7,
            vertical: 1,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: _getTabFontSize(context) * 0.75,
              fontWeight: FontWeight.w700,
              fontFamily: kFontFamily,
            ),
          ),
        ),
      ],
    );
  }

  /// 📋 CONTENIDO DE PESTAÑAS - ✅ MEJOR ESPACIADO
  Widget _buildTabViewContent() {
    return Container(
      height: _getTimeGridHeight(context),
      padding: EdgeInsets.symmetric(
        horizontal:
            _getTabContentPadding(context), // ✅ NUEVO: PADDING HORIZONTAL
        vertical:
            _getTabContentVerticalPadding(context), // ✅ NUEVO: PADDING VERTICAL
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          // 🌅 MAÑANA
          _buildTimeGrid(_getMorningTimeSlots()),
          // ☀️ TARDE
          _buildTimeGrid(_getAfternoonTimeSlots()),
          // 🌙 NOCHE
          _buildTimeGrid(_getEveningTimeSlots()),
        ],
      ),
    );
  }

  /// 🕒 GRID DE HORARIOS ESPECÍFICO - ✅ MEJOR ESPACIADO
  Widget _buildTimeGrid(List<String> timeSlots) {
    if (timeSlots.isEmpty) {
      return _buildEmptyPeriodState();
    }

    final crossAxisCount = _getTimeGridColumns(context);

    return GridView.builder(
      padding: EdgeInsets.all(
          _getTimeGridPadding(context)), // ✅ NUEVO: PADDING GENERAL
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 2.0, // ✅ AJUSTADO: Más alto para mejor proporción
        crossAxisSpacing:
            _getTimeSlotSpacing(context), // ✅ ESPACIADO HORIZONTAL
        mainAxisSpacing:
            _getTimeSlotMainSpacing(context), // ✅ NUEVO: ESPACIADO VERTICAL
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = timeSlots[index];
        // ✅ FIX: Usar temporarySelectedTime para mostrar selección inmediata
        final isSelected =
            (_temporarySelectedTime ?? widget.selectedTime) == timeSlot;

        return _buildTimeSlotCard(timeSlot, isSelected);
      },
    );
  }

  /// 🎯 TIME SLOT CARD CON ESTILO CONSISTENTE - ✅ COLOR ORIGINAL + FIX SELECCIÓN
  Widget _buildTimeSlotCard(String timeSlot, bool isSelected) {
    return GestureDetector(
      onTap: () =>
          _handleTimeSlotSelection(timeSlot), // ✅ FIX: Usar nuevo método
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          // ✅ GRADIENTE SUTIL DE FONDO COMO SERVICE CARDS (COLOR ORIGINAL)
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.accentColor
                        .withValues(alpha: 0.08), // ✅ COLOR ORIGINAL
                    widget.accentColor
                        .withValues(alpha: 0.12), // ✅ COLOR ORIGINAL
                    Colors.white,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                )
              : const LinearGradient(
                  colors: [Colors.white, Colors.white],
                ),
          borderRadius: BorderRadius.circular(_getTimeSlotRadius(context)),
          border: Border.all(
            color: isSelected
                ? widget.accentColor
                    .withValues(alpha: 0.4) // ✅ BORDE COLOR ORIGINAL
                : kBorderSoft.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              _buildTimeSlotShadows(isSelected), // ✅ SOMBRAS CON COLOR ORIGINAL
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: widget.accentColor, // ✅ CHECK COLOR ORIGINAL
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.accentColor
                            .withValues(alpha: 0.5), // ✅ SOMBRA COLOR ORIGINAL
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: _getTimeSlotIconSize(context),
                  ),
                ),
                SizedBox(width: _getTimeSlotSpacing(context) * 0.5),
              ],
              Flexible(
                child: Text(
                  _formatTimeSlot(timeSlot),
                  style: TextStyle(
                    fontSize: _getTimeSlotFontSize(context),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? widget.accentColor
                        : Colors.black87, // ✅ TEXTO COLOR ORIGINAL
                    fontFamily: kFontFamily,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🌟 SOMBRAS PROFUNDAS PARA TIME SLOTS - ✅ CON COLOR ORIGINAL
  List<BoxShadow> _buildTimeSlotShadows(bool isSelected) {
    if (isSelected) {
      return [
        // ✅ SOMBRA PRINCIPAL CON COLOR ORIGINAL
        BoxShadow(
          color: widget.accentColor.withValues(alpha: 0.25), // ✅ COLOR ORIGINAL
          offset: const Offset(0, 8),
          blurRadius: 24,
          spreadRadius: 2,
        ),
        // ✅ SOMBRA SECUNDARIA COLOR ORIGINAL
        BoxShadow(
          color: widget.accentColor.withValues(alpha: 0.15), // ✅ COLOR ORIGINAL
          offset: const Offset(0, 16),
          blurRadius: 32,
          spreadRadius: -2,
        ),
        // ✅ SOMBRA BASE OSCURA (sin cambios)
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          offset: const Offset(0, 4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
        // ✅ GLOW EFECTO COLOR ORIGINAL
        BoxShadow(
          color: widget.accentColor
              .withValues(alpha: 0.1), // ✅ GLOW COLOR ORIGINAL
          offset: const Offset(0, 0),
          blurRadius: 12,
          spreadRadius: 3,
        ),
      ];
    } else {
      return [
        // ✅ SOMBRA NEUTRA (sin cambios)
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          offset: const Offset(0, 6),
          blurRadius: 20,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          offset: const Offset(0, 12),
          blurRadius: 28,
          spreadRadius: -4,
        ),
        BoxShadow(
          color: kBorderSoft.withValues(alpha: 0.15),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    }
  }

  /// ❌ ESTADO VACÍO PARA PERÍODO
  Widget _buildEmptyPeriodState() {
    return Container(
      height: _getTimeGridHeight(context),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: _getEmptyIconSize(context),
              height: _getEmptyIconSize(context),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius:
                    BorderRadius.circular(_getEmptyIconRadius(context)),
                border: Border.all(color: kBorderSoft, width: 2),
              ),
              child: Icon(
                Icons.schedule_outlined,
                size: _getEmptyIconSize(context) * 0.5,
                color: kTextMuted,
              ),
            ),
            SizedBox(height: _getContentSpacing(context)),
            Text(
              'No hay horarios disponibles',
              style: TextStyle(
                fontSize: _getEmptyTitleSize(context),
                fontWeight: FontWeight.w600,
                color: kTextSecondary,
                fontFamily: kFontFamily,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'en este período',
              style: TextStyle(
                fontSize: _getEmptySubtitleSize(context),
                color: kTextMuted,
                fontFamily: kFontFamily,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ⏰ TIME SLOTS GRID PARA EMPRESA/CORPORATIVO
  Widget _buildTimeSlotGrid() {
    return TimeSlotGridWidget(
      timeSlots: widget.timeSlots,
      selectedTime: _temporarySelectedTime ??
          widget.selectedTime, // ✅ FIX: Usar temporarySelectedTime
      accentColor: widget.accentColor,
      onTimeSelected: _handleTimeSlotSelection, // ✅ FIX: Usar nuevo método
    );
  }

  // ============================================================================
  // 🆕 GENERADORES DE TIME SLOTS POR PERÍODO
  // ============================================================================

  /// 🌅 HORARIOS DE MAÑANA: 9:00 AM - 1:00 PM
  List<String> _getMorningTimeSlots() {
    return [
      '09:00',
      '09:30',
      '10:00',
      '10:30',
      '11:00',
      '11:30',
      '12:00',
      '12:30',
      '13:00'
    ];
  }

  /// ☀️ HORARIOS DE TARDE: 1:30 PM - 6:00 PM
  List<String> _getAfternoonTimeSlots() {
    return [
      '13:30',
      '14:00',
      '14:30',
      '15:00',
      '15:30',
      '16:00',
      '16:30',
      '17:00',
      '17:30',
      '18:00'
    ];
  }

  /// 🌙 HORARIOS DE NOCHE: 6:30 PM - 9:00 PM
  List<String> _getEveningTimeSlots() {
    return ['18:30', '19:00', '19:30', '20:00', '20:30', '21:00'];
  }

  /// 🕐 FORMATEAR TIME SLOT PARA DISPLAY
  String _formatTimeSlot(String timeSlot) {
    try {
      final timeParts = timeSlot.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final displayHour = hour > 12 ? hour - 12 : hour;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHourStr = displayHour == 0 ? '12' : displayHour.toString();

      return '$displayHourStr:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return timeSlot;
    }
  }

  // ============================================================================
  // 📐 SISTEMA RESPONSIVO INTELIGENTE
  // ============================================================================

  /// 📦 PADDING CONTENEDOR
  double _getContainerPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 16;
    if (width <= 375) return 20;
    if (width <= 768) return 24;
    return 32;
  }

  /// 📐 RADIO DE BORDES
  double _getBorderRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12;
    if (width <= 768) return 16;
    return 20;
  }

  /// 📏 ESPACIADO SECCIONES
  double _getSectionSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 20;
    if (width <= 375) return 24;
    if (width <= 768) return 28;
    return 32;
  }

  /// 📏 ESPACIADO CONTENIDO
  double _getContentSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12;
    if (width <= 375) return 16;
    if (width <= 768) return 20;
    return 24;
  }

  /// 📝 FONT SIZE TÍTULO
  double _getTitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 20;
    if (width <= 375) return 22;
    if (width <= 768) return 24;
    return 28;
  }

  /// 📝 FONT SIZE SUBTITLE
  double _getSubtitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 13;
    if (width <= 375) return 14;
    if (width <= 768) return 15;
    return 16;
  }

  /// 📝 FONT SIZE SECTION TITLE
  double _getSectionTitleSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 14;
    if (width <= 375) return 15;
    if (width <= 768) return 16;
    return 18;
  }

  /// 📏 ESPACIADO TEXTO
  double _getTextSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 6;
    if (width <= 768) return 8;
    return 12;
  }

  // 🆕 NUEVAS MÉTRICAS PARA PESTAÑAS Y TIME SLOTS

  /// 🎯 ALTURA TAB BAR - ✅ FIX OVERFLOW
  double _getTabBarHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 55; // ✅ REDUCIDO para iPhone SE
    if (width <= 375) return 65; // ✅ REDUCIDO para iPhone pequeño
    if (width <= 768) return 75; // Móvil normal
    return 85; // Desktop
  }

  /// 📦 PADDING TABS - ✅ FIX OVERFLOW
  double _getTabPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 2; // ✅ MÍN PADDING para iPhone SE
    if (width <= 375) return 4; // ✅ REDUCIDO para iPhone pequeño
    if (width <= 768) return 6;
    return 8;
  }

  /// 📝 FONT SIZE TABS - ✅ FIX OVERFLOW
  double _getTabFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 9; // ✅ MÁS PEQUEÑO para iPhone SE
    if (width <= 375) return 10; // ✅ REDUCIDO para iPhone pequeño
    if (width <= 768) return 11;
    return 12;
  }

  /// 🎯 TAMAÑO ÍCONO TABS - ✅ FIX OVERFLOW
  double _getTabIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12; // ✅ MÁS PEQUEÑO para iPhone SE
    if (width <= 375) return 14; // ✅ REDUCIDO para iPhone pequeño
    if (width <= 768) return 16;
    return 18;
  }

  /// 📏 ESPACIADO TABS - ✅ FIX OVERFLOW
  double _getTabSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 2; // ✅ MÍN SPACING para iPhone SE
    if (width <= 375) return 3; // ✅ REDUCIDO para iPhone pequeño
    if (width <= 768) return 4;
    return 6;
  }

  /// 📊 ALTURA GRID DE TIME SLOTS
  double _getTimeGridHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 200; // iPhone SE
    if (width <= 375) return 250; // iPhone pequeño
    if (width <= 768) return 300; // Móvil normal
    return 350; // Desktop
  }

  /// 📊 COLUMNAS GRID TIME SLOTS
  int _getTimeGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 2; // iPhone SE: 2 columnas
    if (width <= 375) return 3; // iPhone pequeño: 3 columnas
    if (width <= 768) return 4; // Móvil normal: 4 columnas
    return 5; // Desktop: 5 columnas
  }

  /// 📏 ESPACIADO TIME SLOTS HORIZONTAL - ✅ MEJORADO
  double _getTimeSlotSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12; // ✅ MÁS ESPACIO para iPhone SE
    if (width <= 375) return 14; // ✅ MÁS ESPACIO para iPhone pequeño
    if (width <= 768) return 16; // ✅ MÁS ESPACIO para móvil normal
    return 20; // ✅ MÁS ESPACIO para desktop
  }

  /// 📏 ESPACIADO TIME SLOTS VERTICAL - ✅ NUEVO
  double _getTimeSlotMainSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 14; // ✅ ESPACIADO VERTICAL iPhone SE
    if (width <= 375) return 16; // ✅ ESPACIADO VERTICAL iPhone pequeño
    if (width <= 768) return 18; // ✅ ESPACIADO VERTICAL móvil normal
    return 22; // ✅ ESPACIADO VERTICAL desktop
  }

  /// 📦 PADDING GENERAL DEL GRID - ✅ NUEVO
  double _getTimeGridPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 8; // ✅ PADDING iPhone SE
    if (width <= 375) return 10; // ✅ PADDING iPhone pequeño
    if (width <= 768) return 12; // ✅ PADDING móvil normal
    return 16; // ✅ PADDING desktop
  }

  /// 📦 PADDING HORIZONTAL DEL TAB CONTENT - ✅ NUEVO
  double _getTabContentPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 4; // ✅ MÍN PADDING para iPhone SE
    if (width <= 375) return 6; // ✅ PADDING para iPhone pequeño
    if (width <= 768) return 8; // ✅ PADDING para móvil normal
    return 12; // ✅ PADDING para desktop
  }

  /// 📦 PADDING VERTICAL DEL TAB CONTENT - ✅ NUEVO
  double _getTabContentVerticalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 8; // ✅ PADDING VERTICAL iPhone SE
    if (width <= 375) return 10; // ✅ PADDING VERTICAL iPhone pequeño
    if (width <= 768) return 12; // ✅ PADDING VERTICAL móvil normal
    return 16; // ✅ PADDING VERTICAL desktop
  }

  /// 📐 RADIO TIME SLOTS
  double _getTimeSlotRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 10;
    if (width <= 768) return 12;
    return 14;
  }

  /// 📝 FONT SIZE TIME SLOTS
  double _getTimeSlotFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12;
    if (width <= 375) return 13;
    if (width <= 768) return 14;
    return 15;
  }

  /// 🎯 TAMAÑO ÍCONO TIME SLOT
  double _getTimeSlotIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12;
    if (width <= 768) return 14;
    return 16;
  }

  /// ❌ TAMAÑO ÍCONO EMPTY STATE
  double _getEmptyIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 48;
    if (width <= 768) return 64;
    return 80;
  }

  /// ❌ RADIO ÍCONO EMPTY STATE
  double _getEmptyIconRadius(BuildContext context) {
    return _getEmptyIconSize(context) * 0.25;
  }

  /// ❌ FONT SIZE TÍTULO EMPTY
  double _getEmptyTitleSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 14;
    if (width <= 375) return 16;
    if (width <= 768) return 18;
    return 20;
  }

  /// ❌ FONT SIZE SUBTITLE EMPTY
  double _getEmptySubtitleSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12;
    if (width <= 375) return 13;
    if (width <= 768) return 14;
    return 15;
  }
}
