// ========================================================================
// 🌟 GLASSMORPHISM CARD TEMPLATE - FISIO SPA KYM PREMIUM
// ========================================================================
// 📁 Ubicación: /lib/templates/glassmorphism_card_template.dart
// 🎯 OBJETIVO: Template reutilizable para cards con estilo glassmorphism elegante
// 👨‍💼 AUTOR: Equipo Fisio Spa KYM - Nivel Multinacional
// 📅 VERSIÓN: 1.0 - Enero 2025

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

// ========================================================================
// 🎨 GLASSMORPHISM CARD BASE
// ========================================================================

class GlassmorphismCard extends StatefulWidget {
  // ✅ CONFIGURACIÓN BÁSICA
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  
  // ✅ CONFIGURACIÓN DE GLASSMORPHISM
  final Color primaryColor;
  final Color? secondaryColor;
  final double borderRadius;
  final double borderWidth;
  final double glassOpacity;
  final int shadowLayers;
  
  // ✅ CONFIGURACIÓN DE ESTADO
  final bool isActive;
  final bool hasHover;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin = const EdgeInsets.all(8),
    this.padding = const EdgeInsets.all(20),
    this.primaryColor = kBrandPurple,
    this.secondaryColor,
    this.borderRadius = 16.0,
    this.borderWidth = 1.0,
    this.glassOpacity = 0.05,
    this.shadowLayers = 3,
    this.isActive = false,
    this.hasHover = true,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<GlassmorphismCard> createState() => _GlassmorphismCardState();
}

class _GlassmorphismCardState extends State<GlassmorphismCard> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    if (widget.hasHover) {
      _hoverController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _hoverAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
        CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
      );
    }
  }

  @override
  void dispose() {
    if (widget.hasHover) {
      _hoverController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = widget.secondaryColor ?? 
        (widget.primaryColor == kBrandPurple ? kAccentBlue : kBrandPurple);

    return widget.hasHover 
        ? MouseRegion(
            onEnter: (_) {
              setState(() => _isHovered = true);
              _hoverController.forward();
            },
            onExit: (_) {
              setState(() => _isHovered = false);
              _hoverController.reverse();
            },
            child: _buildCard(secondaryColor),
          )
        : _buildCard(secondaryColor);
  }

  Widget _buildCard(Color secondaryColor) {
    return AnimatedBuilder(
      animation: widget.hasHover ? _hoverAnimation : 
          const AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.hasHover ? _hoverAnimation.value : 1.0,
          child: GestureDetector(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Container(
              width: widget.width,
              height: widget.height,
              margin: widget.margin,
              decoration: _buildGlassmorphismDecoration(secondaryColor),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Container(
                  padding: widget.padding,
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildGlassmorphismDecoration(Color secondaryColor) {
    final isActiveOrHovered = widget.isActive || _isHovered;
    
    return BoxDecoration(
      // ✅ GRADIENTE GLASSMORPHISM BASE
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.9),
          Colors.white.withValues(alpha: 0.7),
          widget.primaryColor.withValues(alpha: widget.glassOpacity),
          secondaryColor.withValues(alpha: widget.glassOpacity * 0.5),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),
      
      borderRadius: BorderRadius.circular(widget.borderRadius),
      
      // ✅ BORDE GLASSMORPHISM
      border: Border.all(
        color: isActiveOrHovered 
            ? widget.primaryColor.withValues(alpha: 0.3)
            : widget.primaryColor.withValues(alpha: 0.15),
        width: isActiveOrHovered ? widget.borderWidth * 1.5 : widget.borderWidth,
      ),
      
      // ✅ SOMBRAS MULTICAPA GLASSMORPHISM
      boxShadow: _buildGlassmorphismShadows(isActiveOrHovered),
    );
  }

  List<BoxShadow> _buildGlassmorphismShadows(bool isActiveOrHovered) {
    final shadows = <BoxShadow>[];
    final intensity = isActiveOrHovered ? 1.5 : 1.0;
    
    // 📐 SOMBRA PRINCIPAL COLOREADA
    shadows.add(BoxShadow(
      color: widget.primaryColor.withValues(alpha: 0.15 * intensity),
      blurRadius: 20 * intensity,
      spreadRadius: 2 * intensity,
      offset: Offset(0, 8 * intensity),
    ));
    
    if (widget.shadowLayers >= 2) {
      // 📐 SOMBRA INTERNA GLASSMORPHISM
      shadows.add(BoxShadow(
        color: Colors.white.withValues(alpha: 0.8),
        blurRadius: 15 * intensity,
        spreadRadius: -5 * intensity,
        offset: Offset(0, -5 * intensity),
      ));
    }
    
    if (widget.shadowLayers >= 3) {
      // 📐 SOMBRA DE PROFUNDIDAD
      shadows.add(BoxShadow(
        color: Colors.black.withValues(alpha: 0.05 * intensity),
        blurRadius: 30 * intensity,
        spreadRadius: 0,
        offset: Offset(0, 15 * intensity),
      ));
    }
    
    if (widget.shadowLayers >= 4) {
      // 📐 SOMBRA SECUNDARIA COLOREADA
      final secondaryColor = widget.secondaryColor ?? kAccentBlue;
      shadows.add(BoxShadow(
        color: secondaryColor.withValues(alpha: 0.08 * intensity),
        blurRadius: 25 * intensity,
        spreadRadius: 1 * intensity,
        offset: Offset(3 * intensity, 10 * intensity),
      ));
    }
    
    return shadows;
  }
}

// ========================================================================
// 🎨 GLASSMORPHISM SECTION
// ========================================================================

class GlassmorphismSection extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? titleIcon;
  final Color titleColor;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool hasBorder;

  const GlassmorphismSection({
    super.key,
    required this.child,
    this.title,
    this.titleIcon,
    this.titleColor = kBrandPurple,
    this.backgroundColor = kBrandPurple,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 12.0,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.8),
            backgroundColor.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: hasBorder ? Border.all(
          color: backgroundColor.withValues(alpha: 0.2),
          width: 1,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.9),
            blurRadius: 10,
            spreadRadius: -3,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            _buildSectionHeader(),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            titleColor.withValues(alpha: 0.1),
            titleColor.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: titleColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: titleColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (titleIcon != null) ...[
            Icon(titleIcon, color: titleColor, size: 18),
            const SizedBox(width: 12),
          ],
          Text(
            title!,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================================
// 🎨 GLASSMORPHISM CHIP
// ========================================================================

class GlassmorphismChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback? onTap;
  final bool isSelected;

  const GlassmorphismChip({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected ? [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
            ] : [
              Colors.white.withValues(alpha: 0.6),
              color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: isSelected ? 0.4 : 0.3),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isSelected ? 0.2 : 0.15),
              blurRadius: isSelected ? 8 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================================================
// 🎨 GLASSMORPHISM BUTTON
// ========================================================================

class GlassmorphismButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;

  const GlassmorphismButton({
    super.key,
    required this.text,
    this.icon,
    this.color = kBrandPurple,
    this.onPressed,
    this.isLoading = false,
    this.width,
  });

  @override
  State<GlassmorphismButton> createState() => _GlassmorphismButtonState();
}

class _GlassmorphismButtonState extends State<GlassmorphismButton>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : () {
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                  widget.onPressed?.call();
                },
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color,
                        widget.color.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading) ...[
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ] else if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 18),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        widget.text,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ========================================================================
// 🎨 GLASSMORPHISM BADGE
// ========================================================================

class GlassmorphismBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool isAnimated;

  const GlassmorphismBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.isAnimated = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.9),
            color.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 8,
            spreadRadius: -2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );

    if (isAnimated) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: badge);
        },
      );
    }

    return badge;
  }
}

// ========================================================================
// 📚 EJEMPLOS DE USO
// ========================================================================

class GlassmorphismExamples extends StatelessWidget {
  const GlassmorphismExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(title: const Text('Glassmorphism Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🎯 EJEMPLO 1: CARD BÁSICO
            GlassmorphismCard(
              primaryColor: kBrandPurple,
              child: Column(
                children: [
                  const Text('Card Básico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GlassmorphismChip(icon: Icons.star, text: 'Premium', color: kAccentGreen),
                      const SizedBox(width: 12),
                      GlassmorphismChip(icon: Icons.verified, text: 'Verified', color: kAccentBlue),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🎯 EJEMPLO 2: CARD CON SECCIONES
            GlassmorphismCard(
              primaryColor: kAccentBlue,
              shadowLayers: 4,
              child: Column(
                children: [
                  GlassmorphismSection(
                    title: 'Información Principal',
                    titleIcon: Icons.info,
                    titleColor: kBrandPurple,
                    child: const Text('Contenido de la sección principal'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GlassmorphismButton(
                          text: 'Acción 1',
                          icon: Icons.check,
                          color: kAccentGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassmorphismButton(
                          text: 'Acción 2',
                          icon: Icons.edit,
                          color: kAccentBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🎯 EJEMPLO 3: BADGES Y ESTADOS
            GlassmorphismCard(
              primaryColor: kAccentGreen,
              isActive: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estado del Sistema', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  GlassmorphismBadge(
                    text: 'ACTIVO',
                    color: kAccentGreen,
                    icon: Icons.check_circle,
                    isAnimated: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================================================
// 📋 INSTRUCCIONES DE USO RÁPIDO
// ========================================================================

/*
🎯 CÓMO USAR EL TEMPLATE:

1. CARD BÁSICO:
   GlassmorphismCard(
     primaryColor: kBrandPurple,
     child: YourContent(),
   )

2. CARD CON SECCIONES:
   GlassmorphismCard(
     child: Column(children: [
       GlassmorphismSection(
         title: 'Mi Sección',
         titleIcon: Icons.star,
         child: YourSectionContent(),
       ),
     ]),
   )

3. BOTONES:
   GlassmorphismButton(
     text: 'Mi Botón',
     icon: Icons.save,
     color: kAccentGreen,
     onPressed: () => yourAction(),
   )

4. CHIPS:
   GlassmorphismChip(
     icon: Icons.tag,
     text: 'Etiqueta',
     color: kAccentBlue,
   )

5. BADGES:
   GlassmorphismBadge(
     text: 'ESTADO',
     color: kAccentGreen,
     icon: Icons.check,
     isAnimated: true,
   )

🎨 PERSONALIZACIÓN:
- primaryColor: Color principal del glassmorphism
- secondaryColor: Color secundario (auto si no se especifica)
- shadowLayers: 1-4 niveles de sombra
- glassOpacity: 0.05 - 0.15 para transparencia
- isActive: true para estado destacado
- hasHover: false para desactivar animaciones hover

📱 RESPONSIVE:
- Usa ConstrainedBox(maxWidth: 900) para centrar
- EdgeInsets adaptativos según pantalla
- Breakpoints automáticos en el template
*/