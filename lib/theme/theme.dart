import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:agenda_fisio_spa_kym/widgets/mandala/mandala_painters.dart';
import 'package:agenda_fisio_spa_kym/config/module_mandala_mapping.dart'
    as mapping;

/// 🎨 COLORES BASE DE MARCA (TUS COLORES ORIGINALES) - SIN CAMBIOS
const Color kBrandPurple = Color(0xFF9920A7);
const Color kBackgroundColor = Color(0xFFF5F5F9);
const Color kWhite = Color(0xFFFFFFFF);
const Color kAccentBlue = Color(0xFF4DB1E0);
const Color kAccentGreen = Color(0xFF8ABF54);
const Color kBorderColor = Color(0xFFCCAEE0);
const Color kBrandPurpleLight = Color(0xFFEADCF9);

/// 🌟 NUEVOS COLORES PREMIUM PARA PROFUNDIDAD VISUAL - SIN CAMBIOS
const Color kDarkSidebar = Color(0xFF2D3748);
const Color kDarkSidebarHover = Color(0xFF4A5568);
const Color kDarkSidebarActive = Color(0xFF553C9A);
const Color kTextSecondary = Color(0xFF718096);
const Color kTextMuted = Color(0xFFA0AEC0);
const Color kBorderSoft = Color(0xFFE2E8F0);
const Color kBorderLight = Color(0xFFF7FAFC);
const Color kCardShadow = Color(0xFF64748B);
const Color kSuccessColor = Color(0xFF48BB78);
const Color kWarningColor = Color(0xFFED8936);
const Color kErrorColor = Color(0xFFE53E3E);
const Color kInfoColor = Color(0xFF3182CE);

/// 📱 ✅ NUEVO: SISTEMA RESPONSIVO PREMIUM - iPhone SE OPTIMIZADO
class ResponsiveMetrics {
  /// 📱 Detectores de dispositivo
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  static bool isIPhoneSE(BuildContext context) =>
      MediaQuery.of(context).size.width <= 375;
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  /// 📏 AppBar Heights - OPTIMIZACIÓN CRÍTICA para iPhone SE
  static double getAppBarHeight(BuildContext context) {
    if (isIPhoneSE(context)) return 160; // ✅ REDUCIDO de 220 (-27%)
    if (isMobile(context)) return 180;
    if (isTablet(context)) return 200;
    return 220; // Desktop mantiene altura original
  }

  /// 📝 Typography Scale - ESCALADO INTELIGENTE
  static double getTitleSize(BuildContext context) {
    if (isIPhoneSE(context)) return 20; // ✅ REDUCIDO de 32
    if (isMobile(context)) return 24;
    if (isTablet(context)) return 28;
    return 32; // Desktop
  }

  static double getSubtitleSize(BuildContext context) {
    if (isIPhoneSE(context)) return 13; // ✅ REDUCIDO de 16
    if (isMobile(context)) return 14;
    if (isTablet(context)) return 15;
    return 16; // Desktop
  }

  static double getBodyTextSize(BuildContext context) {
    if (isIPhoneSE(context)) return 14;
    if (isMobile(context)) return 15;
    if (isTablet(context)) return 16;
    return 16; // Desktop
  }

  /// 📦 Padding System - ESPACIADO ADAPTATIVO
  static double getContainerPadding(BuildContext context) {
    if (isIPhoneSE(context)) return 16; // ✅ REDUCIDO de 32
    if (isMobile(context)) return 20;
    if (isTablet(context)) return 24;
    return 32; // Desktop
  }

  static double getCardPadding(BuildContext context) {
    if (isIPhoneSE(context)) return 16; // ✅ REDUCIDO de 24
    if (isMobile(context)) return 20;
    if (isTablet(context)) return 22;
    return 24; // Desktop
  }

  static double getSectionSpacing(BuildContext context) {
    if (isIPhoneSE(context)) return 16;
    if (isMobile(context)) return 20;
    if (isTablet(context)) return 24;
    return 32; // Desktop
  }

  /// 🎯 Component Sizes - TAMAÑOS ADAPTATIVOS
  static double getIconSize(BuildContext context) {
    if (isIPhoneSE(context)) return 20;
    if (isMobile(context)) return 22;
    if (isTablet(context)) return 24;
    return 24; // Desktop
  }

  static double getButtonHeight(BuildContext context) {
    if (isIPhoneSE(context)) return 48;
    if (isMobile(context)) return 52;
    if (isTablet(context)) return 56;
    return 56; // Desktop
  }

  /// 📐 Border Radius - CONSISTENCIA VISUAL
  static double getCardRadius(BuildContext context) {
    if (isIPhoneSE(context)) return 16;
    if (isMobile(context)) return 18;
    if (isTablet(context)) return 20;
    return 20; // Desktop
  }

  static double getButtonRadius(BuildContext context) {
    if (isIPhoneSE(context)) return 12;
    if (isMobile(context)) return 14;
    if (isTablet(context)) return 16;
    return 16; // Desktop
  }
}

/// 🎨 ✅ NUEVO: GRADIENTES PREMIUM - 3 COLORES DE MARCA
final LinearGradient kHeaderGradientPremium = LinearGradient(
  colors: [kBrandPurple, kAccentBlue, kAccentGreen],
  stops: [0.0, 0.6, 1.0],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final LinearGradient kCardGradientPremium = LinearGradient(
  colors: [
    kBrandPurple.withValues(alpha: 0.1),
    kAccentBlue.withValues(alpha: 0.05),
    Colors.white
  ],
  stops: [0.0, 0.3, 1.0],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final LinearGradient kButtonGradientPremium = LinearGradient(
  colors: [kBrandPurple, kAccentBlue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// 🎨 ✅ NUEVO: GLASSMORPHISM HELPERS - EFECTOS PREMIUM
class GlassmorphismHelper {
  static BoxDecoration createGlassContainer({
    Color? backgroundColor,
    double opacity = 0.1,
    double borderOpacity = 0.2,
    double borderRadius = 20,
    double borderWidth = 1,
  }) {
    return BoxDecoration(
      color: (backgroundColor ?? Colors.white).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: borderOpacity),
        width: borderWidth,
      ),
    );
  }

  static BoxDecoration createGlassAppBar({
    double borderRadius = 24,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1,
      ),
    );
  }
}

/// 🎨 GRADIENTES ORIGINALES (MANTENER COMPATIBILIDAD) - SIN CAMBIOS
final LinearGradient kHeaderGradient = const LinearGradient(
  colors: [kBrandPurple, kAccentBlue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final LinearGradient kCardGradient = LinearGradient(
  colors: [Colors.white, kBrandPurpleLight.withValues(alpha: 0.03)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final LinearGradient kSidebarGradient = const LinearGradient(
  colors: [kDarkSidebar, Color(0xFF1A202C)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

final LinearGradient kButtonGradient = const LinearGradient(
  colors: [kBrandPurple, Color(0xFF7C3AED)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// 🌒 SOMBRAS PREMIUM - SISTEMA DE 3 NIVELES - SIN CAMBIOS
final List<BoxShadow> kSombraCard = [
  BoxShadow(
    color: kCardShadow.withValues(alpha: 0.08),
    offset: const Offset(0, 1),
    blurRadius: 4,
    spreadRadius: 0,
  ),
  BoxShadow(
    color: kCardShadow.withValues(alpha: 0.06),
    offset: const Offset(0, 4),
    blurRadius: 12,
    spreadRadius: -2,
  ),
];

final List<BoxShadow> kSombraCardElevated = [
  BoxShadow(
    color: kBrandPurple.withValues(alpha: 0.15),
    offset: const Offset(0, 4),
    blurRadius: 20,
    spreadRadius: 0,
  ),
  BoxShadow(
    color: kCardShadow.withValues(alpha: 0.12),
    offset: const Offset(0, 8),
    blurRadius: 24,
    spreadRadius: -4,
  ),
];

final List<BoxShadow> kSombraHeader = [
  BoxShadow(
    color: kBrandPurple.withValues(alpha: 0.2),
    offset: const Offset(0, 4),
    blurRadius: 16,
    spreadRadius: -2,
  ),
];

/// 🌒 SOMBRAS ORIGINALES (MANTENIDAS PARA COMPATIBILIDAD) - SIN CAMBIOS
final List<BoxShadow> kSombraLateral = [
  BoxShadow(
    color: kDarkSidebar.withValues(alpha: 0.15),
    offset: const Offset(2, 0),
    blurRadius: 8,
    spreadRadius: 0,
  ),
];

final List<BoxShadow> kSombraSuperior = [
  BoxShadow(
    color: kBrandPurple.withValues(alpha: 0.12),
    offset: const Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  ),
];

/// 📱 FUENTE PRINCIPAL - SIN CAMBIOS
const String kFontFamily = 'Poppins';

/// 🎯 TEMA PRINCIPAL EVOLUCIONADO - SIN CAMBIOS (MANTENER EXACTO)
ThemeData buildAppTheme() {
  return ThemeData(
    primaryColor: kBrandPurple,
    scaffoldBackgroundColor: kBackgroundColor,
    fontFamily: kFontFamily,
    useMaterial3: true, // ✅ Material 3 para componentes más modernos

    /// ✅ APPBAR PREMIUM CON GRADIENTE
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 4,
      shadowColor: kBrandPurple.withValues(alpha: 0.2),
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        fontFamily: kFontFamily,
        letterSpacing: -0.5,
      ),
      toolbarTextStyle: const TextStyle(
        color: Colors.white,
        fontFamily: kFontFamily,
      ),
    ),

    /// 🎨 INPUT FIELDS PREMIUM
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(
        fontSize: 14,
        color: kTextSecondary,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        fontSize: 14,
        color: kTextMuted,
        fontWeight: FontWeight.w400,
      ),

      // ✅ BORDES SUAVES Y ELEGANTES
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kBorderSoft, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kBorderSoft, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBrandPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kErrorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kErrorColor, width: 2),
      ),
    ),

    /// 🚀 BOTONES PREMIUM CON GRADIENTES
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: kBrandPurple,
        elevation: 3,
        shadowColor: kBrandPurple.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: kFontFamily,
          letterSpacing: 0.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    /// 🎯 BOTONES DE TEXTO REFINADOS
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kBrandPurple,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: kFontFamily,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    /// 🎨 CARDS PREMIUM CON GRADIENTE SUTIL
    cardTheme: CardTheme(
      color: Colors.white,
      shadowColor: kCardShadow.withValues(alpha: 0.15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kBorderSoft, width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    ),

    /// 🎭 DIALOGS PREMIUM
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      elevation: 16,
      shadowColor: kCardShadow.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: kBorderSoft, width: 1),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        fontFamily: kFontFamily,
        letterSpacing: -0.3,
      ),
      contentTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: kTextSecondary,
        fontFamily: kFontFamily,
        height: 1.5,
      ),
    ),

    /// 🎨 CHIPS PREMIUM
    chipTheme: ChipThemeData(
      backgroundColor: kBrandPurpleLight.withValues(alpha: 0.3),
      deleteIconColor: kBrandPurple,
      disabledColor: kTextMuted.withValues(alpha: 0.2),
      selectedColor: kBrandPurple,
      secondarySelectedColor: kAccentBlue,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        fontFamily: kFontFamily,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        fontFamily: kFontFamily,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: kBorderSoft, width: 1),
      ),
    ),

    /// 📊 DIVIDERS Y SEPARADORES
    dividerColor: kBorderSoft,
    dividerTheme: DividerThemeData(
      color: kBorderSoft,
      thickness: 1,
      space: 1,
    ),

    /// 🎯 ICONOS CONSISTENTES
    iconTheme: IconThemeData(
      color: kTextSecondary,
      size: 20,
    ),
    primaryIconTheme: const IconThemeData(
      color: kBrandPurple,
      size: 20,
    ),

    /// 🎨 SISTEMA DE COLORES PREMIUM
    colorScheme: ColorScheme.fromSeed(
      seedColor: kBrandPurple,
      brightness: Brightness.light,
      primary: kBrandPurple,
      secondary: kAccentBlue,
      tertiary: kAccentGreen,
      surface: Colors.white,
      background: kBackgroundColor,
      error: kErrorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
      outline: kBorderSoft,
      outlineVariant: kBorderLight,
    ),

    /// 🎭 BOTTOM SHEETS PREMIUM
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white,
      elevation: 12,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
    ),

    /// 📱 SNACKBARS PREMIUM
    snackBarTheme: SnackBarThemeData(
      backgroundColor: kDarkSidebar,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: kFontFamily,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    ),

    /// 🎯 CHECKBOX Y RADIO PREMIUM
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.selected)) {
          return kBrandPurple;
        }
        return null;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.selected)) {
          return kBrandPurple;
        }
        return kTextMuted;
      }),
    ),

    /// 🎨 SWITCH PREMIUM
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.selected)) {
          return kBrandPurple;
        }
        return null;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.selected)) {
          return kBrandPurple.withValues(alpha: 0.4);
        }
        return null;
      }),
    ),

    /// 🎯 SLIDERS PREMIUM
    sliderTheme: SliderThemeData(
      activeTrackColor: kBrandPurple,
      inactiveTrackColor: kBrandPurple.withValues(alpha: 0.2),
      thumbColor: kBrandPurple,
      overlayColor: kBrandPurple.withValues(alpha: 0.2),
      valueIndicatorColor: kBrandPurple,
      valueIndicatorTextStyle: const TextStyle(
        color: Colors.white,
        fontFamily: kFontFamily,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

/// 🎨 ✅ NUEVO: EXTENSIONES HELPER PARA RESPONSIVIDAD
extension ThemeExtensions on BuildContext {
  /// Acceso rápido a colores (MANTENER ORIGINALES)
  Color get primaryColor => kBrandPurple;
  Color get secondaryColor => kAccentBlue;
  Color get accentColor => kAccentGreen;
  Color get backgroundColor => kBackgroundColor;
  Color get textSecondary => kTextSecondary;
  Color get borderColor => kBorderSoft;

  /// Gradientes comunes (MANTENER ORIGINALES)
  LinearGradient get headerGradient => kHeaderGradient;
  LinearGradient get cardGradient => kCardGradient;
  LinearGradient get sidebarGradient => kSidebarGradient;

  /// ✅ NUEVO: Gradientes premium
  LinearGradient get headerGradientPremium => kHeaderGradientPremium;
  LinearGradient get cardGradientPremium => kCardGradientPremium;
  LinearGradient get buttonGradientPremium => kButtonGradientPremium;

  /// Sombras comunes (MANTENER ORIGINALES)
  List<BoxShadow> get cardShadow => kSombraCard;
  List<BoxShadow> get elevatedShadow => kSombraCardElevated;
  List<BoxShadow> get headerShadow => kSombraHeader;

  /// ✅ NUEVO: ResponsiveMetrics shortcuts
  double get appBarHeight => ResponsiveMetrics.getAppBarHeight(this);
  double get titleSize => ResponsiveMetrics.getTitleSize(this);
  double get subtitleSize => ResponsiveMetrics.getSubtitleSize(this);
  double get containerPadding => ResponsiveMetrics.getContainerPadding(this);
  double get cardPadding => ResponsiveMetrics.getCardPadding(this);
  double get sectionSpacing => ResponsiveMetrics.getSectionSpacing(this);
  double get cardRadius => ResponsiveMetrics.getCardRadius(this);
  double get buttonRadius => ResponsiveMetrics.getButtonRadius(this);
  double get iconSize => ResponsiveMetrics.getIconSize(this);
  double get buttonHeight => ResponsiveMetrics.getButtonHeight(this);

  bool get isMobile => ResponsiveMetrics.isMobile(this);
  bool get isIPhoneSE => ResponsiveMetrics.isIPhoneSE(this);
  bool get isTablet => ResponsiveMetrics.isTablet(this);
  bool get isDesktop => ResponsiveMetrics.isDesktop(this);
}

// ==========================================
// 🌀 SISTEMA MANDALA - CONECTADO A WIDGETS ESPECIALIZADOS - SIN CAMBIOS
// ==========================================

/// 🎨 GRADIENTE MANDALA DE MARCA (3 COLORES) - ✅ MEJORADO
final LinearGradient kMandalaGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kBrandPurple, kAccentBlue, kAccentGreen],
  stops: [0.0, 0.5, 1.0],
);

/// 🌀 FACTORY PARA CREAR MANDALAS POR MÓDULO - SIN CAMBIOS
class MandalaTheme {
  // Mapeo de módulos a patrones de mandala - USANDO EL ENUM CORRECTO
  static const Map<String, mapping.MandalaPattern> _modulePatterns = {
    'agenda': mapping.MandalaPattern.fibonacci,
    'clientes': mapping.MandalaPattern.flowerOfLife,
    'profesionales': mapping.MandalaPattern.molecular,
    'servicios': mapping.MandalaPattern.vortex,
    'recordatorios': mapping.MandalaPattern.crystalline,
    'corporativo': mapping.MandalaPattern.penrose,
    'empresas': mapping.MandalaPattern.penrose,
    'kympulse': mapping.MandalaPattern.fibonacci,
    'ventas': mapping.MandalaPattern.vortex,
    'admin': mapping.MandalaPattern.molecular,
    'reportes': mapping.MandalaPattern.crystalline,
  };

  /// 🏗️ CONSTRUCTOR PRINCIPAL DE APPBAR CON MANDALA
  static Widget buildMandalaAppBar({
    required String moduleName,
    required String title,
    required String subtitle,
    required IconData icon,
    double expandedHeight = 220,
    bool pinned = true,
    bool floating = false,
    Widget? trailing,
    List<Widget>? actions,
  }) {
    final pattern = _modulePatterns[moduleName.toLowerCase()] ??
        mapping.MandalaPattern.fibonacci;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        background: _MandalaBackground(
          pattern: pattern,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _buildIconContainer(icon),
                    const SizedBox(width: 20),
                    _buildTitleSection(title, subtitle),
                    if (trailing != null) trailing,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildIconContainer(IconData icon) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 36),
    );
  }

  static Widget _buildTitleSection(String title, String subtitle) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: kFontFamily,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontFamily: kFontFamily,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎨 WIDGET DE FONDO MANDALA CON ANIMACIONES OPTIMIZADAS - SIN CAMBIOS
class _MandalaBackground extends StatefulWidget {
  final mapping.MandalaPattern pattern;
  final Widget child;

  const _MandalaBackground({
    required this.pattern,
    required this.child,
  });

  @override
  State<_MandalaBackground> createState() => _MandalaBackgroundState();
}

class _MandalaBackgroundState extends State<_MandalaBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // ⚡ PERFORMANCE: Duración adaptiva según dispositivo
    final duration = _getOptimalDuration();

    _controller = AnimationController(duration: duration, vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startIntelligentAnimation();
  }

  Duration _getOptimalDuration() {
    // Performance optimizada según plataforma
    if (kIsWeb) return const Duration(seconds: 12);
    return const Duration(seconds: 8);
  }

  void _startIntelligentAnimation() async {
    // ⚡ CICLO SEGURO DE ANIMACIÓN
    while (mounted) {
      try {
        await _controller.forward();
        if (!mounted) break;

        await Future.delayed(
            const Duration(seconds: 3)); // 🔄 PAUSA INTELIGENTE
        if (!mounted) break;

        await _controller.reverse();
        if (!mounted) break;

        await Future.delayed(const Duration(seconds: 2)); // 🔄 PAUSA CORTA
      } catch (e) {
        // Si hay error (widget disposed), salir del ciclo
        break;
      }
    }
  }

  @override
  void dispose() {
    // ⚡ DISPOSE SEGURO
    if (_controller.isAnimating) {
      _controller.stop(); // Detener animación activa
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: kMandalaGradient),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _createPainter(_animation.value),
                );
              },
            ),
          ),
          widget.child,
        ],
      ),
    );
  }

  CustomPainter _createPainter(double animationValue) {
    const color = Colors.white;
    const strokeWidth = 1.0;

    // 🎯 USAR LOS PAINTERS OPTIMIZADOS DE mandala_painters.dart
    switch (widget.pattern) {
      case mapping.MandalaPattern.fibonacci:
        return FibonacciPainter(
          animationValue: animationValue,
          color: color,
          strokeWidth: strokeWidth,
        );
      case mapping.MandalaPattern.flowerOfLife:
        return FlowerOfLifePainter(
          animationValue: animationValue,
          color: color,
          strokeWidth: strokeWidth,
        );
      case mapping.MandalaPattern.molecular:
        return MolecularPainter(
          animationValue: animationValue,
          color: color,
          strokeWidth: strokeWidth,
        );
      case mapping.MandalaPattern.vortex:
        return VortexPainter(
          animationValue: animationValue,
          color: color,
          strokeWidth: strokeWidth,
        );
      case mapping.MandalaPattern.crystalline:
        return CrystallinePainter(
          animationValue: animationValue,
          color: color,
          strokeWidth: strokeWidth,
        );
      case mapping.MandalaPattern.penrose:
        return PenrosePainter(
          animationValue: animationValue,
          color: color,
          strokeWidth: strokeWidth,
        );
    }
  }
}
