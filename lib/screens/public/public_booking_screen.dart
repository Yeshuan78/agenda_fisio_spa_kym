// [public_booking_screen.dart] - ✅ UNIFICADO: Elegancia consistente en TODOS los tamaños
// 📁 Ubicación: /lib/screens/public/public_booking_screen.dart
// 🎯 OBJETIVO: Mantener identidad premium como Notion - Sin saltos de diseño
// ✅ SOLUCIÓN: Responsividad inteligente + widgets unificados + funcionalidad intacta

import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../enums/booking_types.dart';
import '../../enums/booking_enums.dart';

// ✅ CONTROLADOR PRINCIPAL (SIN CAMBIOS)
import '../../controllers/booking/booking_flow_controller.dart';

// ✅ WIDGETS UNIFICADOS NUEVOS
import '../../widgets/booking/layout/booking_app_bar.dart';
import '../../widgets/booking/layout/booking_step_wrapper.dart';

// ✅ PANTALLA DE CONFIRMACIÓN (SIN CAMBIOS)
import 'booking_confirmation_screen.dart';

// ✅ SERVICIOS (SIN CAMBIOS)
import '../../services/booking/booking_submission_service.dart';

/// 📱 PANTALLA PÚBLICA DE BOOKING - ✅ UNIFICADA Y ELEGANTE
class PublicBookingScreen extends StatefulWidget {
  final String? companyId;
  final bool isParticular;
  final Map<String, String>? queryParams;

  const PublicBookingScreen({
    super.key,
    this.companyId,
    this.isParticular = false,
    this.queryParams,
  });

  @override
  State<PublicBookingScreen> createState() => _PublicBookingScreenState();
}

class _PublicBookingScreenState extends State<PublicBookingScreen>
    with TickerProviderStateMixin {
  // 🎛️ CONTROLADOR PRINCIPAL (SIN CAMBIOS)
  late final BookingFlowController _controller;

  // 🎨 ANIMACIONES OPTIMIZADAS
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ✅ FLAG PARA INICIALIZACIÓN ÚNICA
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _initializeAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ INICIALIZAR SOLO UNA VEZ CUANDO EL CONTEXTO ESTÉ DISPONIBLE
    if (!_hasInitialized) {
      _hasInitialized = true;
      _loadInitialData();
    }
  }

  /// 🎛️ INICIALIZAR CONTROLADOR (SIN CAMBIOS)
  void _initializeController() {
    _controller = BookingFlowController();
    _controller.addListener(_onControllerChanged);
  }

  /// 🎨 INICIALIZAR ANIMACIONES - DURACIÓN INTELIGENTE
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
  }

  /// 📥 CARGAR DATOS INICIALES
  Future<void> _loadInitialData() async {
    try {
      debugPrint('📥 Iniciando carga de datos iniciales...');

      await _controller.initialize(
        companyId: widget.companyId,
        isParticular: widget.isParticular,
        queryParams: widget.queryParams,
      );

      // ✅ CALLBACK DE NAVEGACIÓN (FUNCIONALIDAD INTACTA)
      _controller.setSubmissionCallback(_handleSubmissionComplete);
      debugPrint('✅ Callback de navegación conectado');

      if (mounted && _controller.state == BookingFlowState.ready) {
        _fadeController.forward();
        debugPrint('✅ Datos iniciales cargados correctamente');
      }
    } catch (e) {
      debugPrint('❌ Error en carga inicial: $e');
      if (mounted) {
        _showError('Error cargando datos: $e');
      }
    }
  }

  /// 🔄 ESCUCHAR CAMBIOS DEL CONTROLADOR (SIN CAMBIOS)
  void _onControllerChanged() {
    if (!mounted) return;

    switch (_controller.state) {
      case BookingFlowState.error:
        if (_controller.errorMessage != null) {
          _showError(_controller.errorMessage!);
        }
        break;
      case BookingFlowState.completed:
        debugPrint(
            '✅ BookingFlowState.completed - El callback debería manejar la navegación');
        break;
      default:
        break;
    }
  }

  /// 📤 MANEJAR RESULTADO DE ENVÍO (SIN CAMBIOS)
  void _handleSubmissionComplete(SubmissionResult result) {
    debugPrint('📤 _handleSubmissionComplete llamado:');
    debugPrint('   - isSuccess: ${result.isSuccess}');
    debugPrint('   - bookingId: ${result.bookingId}');

    if (result.isSuccess && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BookingConfirmationScreen(
            bookingId: result.bookingId!,
            bookingData: result.appointmentModel?.toMap() ?? {},
            bookingType: _controller.bookingType,
          ),
        ),
      );
    } else if (!result.isSuccess) {
      _showError(result.error ?? 'Error en la reserva');
    }
  }

  /// ❌ MOSTRAR ERROR - UNIFICADO Y ELEGANTE
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: _getIntelligentIconSize(context),
            ),
            SizedBox(width: _getIntelligentSpacing(context, 'small')),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: _getIntelligentFontSize(context, 'body'),
                  fontFamily: kFontFamily,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getIntelligentRadius(context)),
        ),
        duration: const Duration(seconds: 5),
        margin: EdgeInsets.all(_getIntelligentPadding(context)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: _buildUnifiedResponsiveBody(),
    );
  }

  /// 📱 BODY UNIFICADO - ✅ ELEGANCIA CONSISTENTE EN TODOS LOS TAMAÑOS
  Widget _buildUnifiedResponsiveBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // 🔄 ESTADOS DE CARGA
            if (_controller.state == BookingFlowState.initializing ||
                _controller.state == BookingFlowState.loadingData) {
              return _buildUnifiedLoadingScreen(context);
            }

            // ❌ ESTADO DE ERROR
            if (_controller.state == BookingFlowState.error) {
              return _buildUnifiedErrorScreen(context);
            }

            // ✅ PANTALLA PRINCIPAL UNIFICADA
            return _buildUnifiedMainScreen(context, constraints);
          },
        );
      },
    );
  }

  /// ⏳ PANTALLA DE CARGA UNIFICADA - SIEMPRE PREMIUM
  Widget _buildUnifiedLoadingScreen(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _getMaxContentWidth(context),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: _controller.isInitialized
                ? kHeaderGradientPremium
                : kHeaderGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUnifiedLoadingIndicator(context),
                SizedBox(height: _getIntelligentSpacing(context, 'large')),
                Text(
                  _controller.state.getMessageForUI(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _getIntelligentFontSize(context, 'title'),
                    fontWeight: FontWeight.w500,
                    fontFamily: kFontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ⚡ LOADING INDICATOR UNIFICADO
  Widget _buildUnifiedLoadingIndicator(BuildContext context) {
    final size = _getIntelligentLoadingSize(context);

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.2), // 20% padding escalable
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius:
            BorderRadius.circular(size * 0.25), // 25% radius escalable
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: size * 0.06, // 6% stroke escalable
      ),
    );
  }

  /// ❌ PANTALLA DE ERROR UNIFICADA
  Widget _buildUnifiedErrorScreen(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _getMaxContentWidth(context),
        ),
        child: Padding(
          padding: EdgeInsets.all(_getIntelligentPadding(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildUnifiedErrorIcon(context),
              SizedBox(height: _getIntelligentSpacing(context, 'large')),
              Text(
                'Error al cargar',
                style: TextStyle(
                  fontSize: _getIntelligentFontSize(context, 'title'),
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                  fontFamily: kFontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: _getIntelligentSpacing(context, 'medium')),
              Text(
                _controller.errorMessage ?? 'Ha ocurrido un error inesperado',
                style: TextStyle(
                  fontSize: _getIntelligentFontSize(context, 'body'),
                  color: kTextSecondary,
                  fontFamily: kFontFamily,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: _getIntelligentSpacing(context, 'large')),
              _buildUnifiedRetryButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// ❌ ERROR ICON UNIFICADO
  Widget _buildUnifiedErrorIcon(BuildContext context) {
    final size = _getIntelligentIconContainerSize(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(_getIntelligentRadius(context)),
        border: Border.all(
          color: Colors.red.shade200,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.error_outline,
        color: Colors.red.shade600,
        size: size * 0.5, // 50% del container
      ),
    );
  }

  /// 🔄 RETRY BUTTON UNIFICADO
  Widget _buildUnifiedRetryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _getIntelligentButtonHeight(context),
      child: ElevatedButton.icon(
        onPressed: _loadInitialData,
        icon: Icon(
          Icons.refresh,
          size: _getIntelligentIconSize(context),
        ),
        label: Text(
          'Reintentar',
          style: TextStyle(
            fontSize: _getIntelligentFontSize(context, 'button'),
            fontWeight: FontWeight.w600,
            fontFamily: kFontFamily,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kBrandPurple,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: _getIntelligentPadding(context),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getIntelligentRadius(context)),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  /// ✅ PANTALLA PRINCIPAL UNIFICADA - SIEMPRE PREMIUM
  Widget _buildUnifiedMainScreen(
      BuildContext context, BoxConstraints constraints) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _getMaxContentWidth(context),
          minHeight: constraints.maxHeight,
        ),
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: CustomScrollView(
                physics: _getIntelligentScrollPhysics(context),
                slivers: [
                  // 🎨 HEADER UNIFICADO - SIEMPRE ELEGANTE
                  _buildUnifiedBookingAppBar(),

                  // 📋 CONTENIDO PRINCIPAL
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _getContentHorizontalPadding(context),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SizedBox(
                            height: _getIntelligentSpacing(context, 'medium')),

                        // ✅ CONTENIDO DEL STEP - WRAPPER INTELIGENTE
                        _buildIntelligentStepWrapper(),

                        SizedBox(
                            height: _getIntelligentSpacing(context, 'medium')),

                        // 🔄 NAVEGACIÓN ELEGANTE
                        if (_controller.canGoBack) _buildUnifiedNavigation(),

                        SizedBox(height: _getBottomSafeArea(context)),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🎨 HEADER UNIFICADO - SIEMPRE PREMIUM
  Widget _buildUnifiedBookingAppBar() {
    return BookingAppBar(
      configuration: _controller.configuration,
      currentStep: _controller.currentStep,
      totalSteps: _controller.configuration.totalSteps,
      companyData: _controller.companyData,
      eventData: _controller.selectedEventData,
      isMobile: _isMobileSize(context),
    );
  }

  /// 📦 STEP WRAPPER INTELIGENTE
  Widget _buildIntelligentStepWrapper() {
    return BookingStepWrapperFactory.create(
      context: context,
      child: _controller.getCurrentStepWidget(),
      animate: !_isMobileSize(context), // Solo animar en desktop
      minimal: _isVerySmallScreen(context), // Minimal en pantallas muy pequeñas
    );
  }

  /// 🔄 NAVEGACIÓN UNIFICADA
  Widget _buildUnifiedNavigation() {
    return Center(
      child: TextButton.icon(
        onPressed: _controller.previousStep,
        icon: Icon(
          Icons.arrow_back,
          size: _getIntelligentIconSize(context),
          color: kTextSecondary,
        ),
        label: Text(
          'Paso anterior',
          style: TextStyle(
            fontSize: _getIntelligentFontSize(context, 'body'),
            color: kTextSecondary,
            fontFamily: kFontFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: _getIntelligentPadding(context),
            vertical: _getIntelligentSpacing(context, 'small'),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // 📏 MÉTODOS DE RESPONSIVIDAD INTELIGENTE - TRANSICIONES SUAVES
  // ============================================================================

  /// 📱 DETECTORES DE TAMAÑO
  bool _isMobileSize(BuildContext context) {
    return MediaQuery.of(context).size.width <= 768;
  }

  bool _isVerySmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width <= 320;
  }

  /// 📐 MAX CONTENT WIDTH - CENTRADO ELEGANTE
  double _getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 768) return width;
    if (width <= 1200) return 900;
    return 1000;
  }

  /// 📦 PADDING INTELIGENTE
  double _getIntelligentPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12;
    if (width <= 375) return 16;
    if (width <= 430) return 20;
    if (width <= 768) return 24;
    return 32;
  }

  /// 📦 CONTENT HORIZONTAL PADDING
  double _getContentHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 375) return 12;
    if (width <= 768) return 16;
    return 20;
  }

  /// 📏 SPACING INTELIGENTE
  double _getIntelligentSpacing(BuildContext context, String size) {
    final width = MediaQuery.of(context).size.width;

    switch (size) {
      case 'small':
        if (width <= 320) return 6;
        if (width <= 375) return 8;
        if (width <= 768) return 12;
        return 16;
      case 'medium':
        if (width <= 320) return 12;
        if (width <= 375) return 16;
        if (width <= 768) return 20;
        return 24;
      case 'large':
        if (width <= 320) return 20;
        if (width <= 375) return 24;
        if (width <= 768) return 32;
        return 40;
      default:
        return 16;
    }
  }

  /// 📐 BORDER RADIUS INTELIGENTE
  double _getIntelligentRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 375) return 12;
    if (width <= 768) return 16;
    return 20;
  }

  /// 📝 FONT SIZE INTELIGENTE
  double _getIntelligentFontSize(BuildContext context, String type) {
    final width = MediaQuery.of(context).size.width;

    switch (type) {
      case 'title':
        if (width <= 320) return 18;
        if (width <= 375) return 20;
        if (width <= 768) return 24;
        return 28;
      case 'subtitle':
        if (width <= 320) return 14;
        if (width <= 375) return 15;
        if (width <= 768) return 16;
        return 18;
      case 'body':
        if (width <= 320) return 13;
        if (width <= 375) return 14;
        if (width <= 768) return 15;
        return 16;
      case 'button':
        if (width <= 320) return 14;
        if (width <= 375) return 15;
        if (width <= 768) return 16;
        return 16;
      default:
        return 14;
    }
  }

  /// 🎯 ICON SIZE INTELIGENTE
  double _getIntelligentIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 16;
    if (width <= 375) return 18;
    if (width <= 768) return 20;
    return 22;
  }

  /// 📦 ICON CONTAINER SIZE INTELIGENTE
  double _getIntelligentIconContainerSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 56;
    if (width <= 375) return 64;
    if (width <= 768) return 72;
    return 80;
  }

  /// ⏳ LOADING SIZE INTELIGENTE
  double _getIntelligentLoadingSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 50;
    if (width <= 375) return 60;
    if (width <= 768) return 70;
    return 80;
  }

  /// 🔘 BUTTON HEIGHT INTELIGENTE
  double _getIntelligentButtonHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 44;
    if (width <= 375) return 48;
    if (width <= 768) return 52;
    return 56;
  }

  /// 📜 SCROLL PHYSICS INTELIGENTE
  ScrollPhysics _getIntelligentScrollPhysics(BuildContext context) {
    return _isMobileSize(context)
        ? const BouncingScrollPhysics()
        : const ClampingScrollPhysics();
  }

  /// 📱 BOTTOM SAFE AREA
  double _getBottomSafeArea(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final additionalPadding = _getIntelligentSpacing(context, 'large');
    return bottomPadding + additionalPadding;
  }

  @override
  void dispose() {
    debugPrint('🧹 Disposing PublicBookingScreen...');
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}

/// 🎨 EXTENSIONES HELPER PARA RESPONSIVIDAD CONSISTENTE
extension PublicBookingResponsive on BuildContext {
  /// 📱 QUICK ACCESS DETECTORES
  bool get isVerySmall => MediaQuery.of(this).size.width <= 320;
  bool get isSmall => MediaQuery.of(this).size.width <= 375;
  bool get isMobile => MediaQuery.of(this).size.width <= 768;
  bool get isTablet =>
      MediaQuery.of(this).size.width > 768 &&
      MediaQuery.of(this).size.width <= 1024;
  bool get isDesktop => MediaQuery.of(this).size.width > 1024;

  /// 📐 QUICK ACCESS VALORES
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  /// 📦 QUICK ACCESS SPACING
  double get spacingSmall {
    if (isVerySmall) return 6;
    if (isSmall) return 8;
    if (isMobile) return 12;
    return 16;
  }

  double get spacingMedium {
    if (isVerySmall) return 12;
    if (isSmall) return 16;
    if (isMobile) return 20;
    return 24;
  }

  double get spacingLarge {
    if (isVerySmall) return 20;
    if (isSmall) return 24;
    if (isMobile) return 32;
    return 40;
  }

  /// 📝 QUICK ACCESS TYPOGRAPHY
  double get titleSize {
    if (isVerySmall) return 18;
    if (isSmall) return 20;
    if (isMobile) return 24;
    return 28;
  }

  double get bodySize {
    if (isVerySmall) return 13;
    if (isSmall) return 14;
    if (isMobile) return 15;
    return 16;
  }

  /// 📦 QUICK ACCESS CONTAINERS
  double get paddingStandard {
    if (isVerySmall) return 12;
    if (isSmall) return 16;
    if (isMobile) return 24;
    return 32;
  }

  double get radiusStandard {
    if (isSmall) return 12;
    if (isMobile) return 16;
    return 20;
  }

  /// 🎯 QUICK ACCESS ICONS
  double get iconSizeStandard {
    if (isVerySmall) return 16;
    if (isSmall) return 18;
    if (isMobile) return 20;
    return 22;
  }
}
