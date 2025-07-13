// [sidebar_premium_widgets.dart]
// 📁 Ubicación: /widgets/navigation/sidebar_premium_widgets.dart
// 🎨 WIDGETS AUXILIARES PARA EL SIDEBAR PREMIUM - VERSIÓN CORREGIDA

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

/// 🔍 BARRA DE BÚSQUEDA PREMIUM CON ANIMACIONES
class PremiumSearchBar extends StatefulWidget {
  final bool isVisible;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const PremiumSearchBar({
    super.key,
    required this.isVisible,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<PremiumSearchBar> createState() => _PremiumSearchBarState();
}

class _PremiumSearchBarState extends State<PremiumSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(PremiumSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: widget.isVisible ? 60 : 0,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: widget.isVisible ? 12 : 0,
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
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
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kBrandPurple.withValues(alpha: 0.01),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  onChanged: widget.onChanged,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar módulos, funciones...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
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
                    suffixIcon: widget.controller.text.isNotEmpty
                        ? Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: widget.onClear,
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.clear,
                                  color: Colors.grey.shade600,
                                  size: 18,
                                ),
                              ),
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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

/// 🎯 BOTÓN DE CONTROL PREMIUM
class PremiumControlButton extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;
  final Color? activeColor;

  const PremiumControlButton({
    super.key,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.tooltip,
    this.activeColor,
  });

  @override
  State<PremiumControlButton> createState() => _PremiumControlButtonState();
}

class _PremiumControlButtonState extends State<PremiumControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PremiumControlButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? kBrandPurple;

    return Tooltip(
      message: widget.tooltip,
      preferBelow: false,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isActive ? _pulseAnimation.value : 1.0,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: widget.isActive
                          ? LinearGradient(
                              colors: [
                                activeColor,
                                activeColor.withValues(alpha: 0.08),
                              ],
                            )
                          : null,
                      color: widget.isActive
                          ? null
                          : _isHovered
                              ? activeColor.withValues(alpha: 0.01)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.isActive
                            ? activeColor
                            : _isHovered
                                ? activeColor.withValues(alpha: 0.03)
                                : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: widget.isActive
                          ? [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 20,
                      color: widget.isActive ? Colors.white : activeColor,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 📊 BADGE PREMIUM CON ANIMACIONES
class PremiumBadge extends StatefulWidget {
  final int count;
  final Color? color;
  final bool isPulsing;

  const PremiumBadge({
    super.key,
    required this.count,
    this.color,
    this.isPulsing = false,
  });

  @override
  State<PremiumBadge> createState() => _PremiumBadgeState();
}

class _PremiumBadgeState extends State<PremiumBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isPulsing) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PremiumBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing != oldWidget.isPulsing) {
      if (widget.isPulsing) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = widget.color ?? Colors.red;

    if (widget.count <= 0) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isPulsing ? _scaleAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  badgeColor,
                  badgeColor.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: badgeColor.withOpacity(
                    widget.isPulsing ? _glowAnimation.value : 0.4,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.count > 99 ? '99+' : '${widget.count}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🎨 ICONO CON GRADIENTE PREMIUM
class PremiumGradientIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final bool isActive;
  final List<Color>? gradient;

  const PremiumGradientIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.isActive,
    this.gradient,
  });

  @override
  State<PremiumGradientIcon> createState() => _PremiumGradientIconState();
}

class _PremiumGradientIconState extends State<PremiumGradientIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    if (widget.isActive) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(PremiumGradientIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.repeat();
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.gradient ??
        [
          kBrandPurple,
          kAccentBlue,
        ];

    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: widget.isActive ? _rotationAnimation.value * 2 * 3.14159 : 0,
          child: Container(
            width: widget.size + 16,
            height: widget.size + 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isActive
                    ? gradientColors
                    : [
                        Colors.grey.shade400,
                        Colors.grey.shade300,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: gradientColors.first.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              widget.icon,
              size: widget.size,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

/// 💫 ESTADO VACÍO PREMIUM
class PremiumEmptyState extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const PremiumEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  State<PremiumEmptyState> createState() => _PremiumEmptyStateState();
}

class _PremiumEmptyStateState extends State<PremiumEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _animationController.forward();
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(0, -_floatAnimation.value),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono flotante
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kBrandPurple.withValues(alpha: 0.01),
                        kAccentBlue.withValues(alpha: 0.005),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: kBrandPurple.withValues(alpha: 0.02),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 40,
                    color: kBrandPurple.withValues(alpha: 0.06),
                  ),
                ),

                const SizedBox(height: 24),

                // Título
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Subtítulo
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Botón de acción (opcional)
                if (widget.onAction != null && widget.actionLabel != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: widget.onAction,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(widget.actionLabel!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 🔄 INDICADOR DE CARGA PREMIUM
class PremiumLoadingIndicator extends StatefulWidget {
  final String? message;
  final double size;

  const PremiumLoadingIndicator({
    super.key,
    this.message,
    this.size = 40.0,
  });

  @override
  State<PremiumLoadingIndicator> createState() =>
      _PremiumLoadingIndicatorState();
}

class _PremiumLoadingIndicatorState extends State<PremiumLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _rotationController.repeat();
    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_rotationController, _scaleController]),
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * 3.14159,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kBrandPurple, kAccentBlue, kAccentGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(widget.size / 2),
                    boxShadow: [
                      BoxShadow(
                        color: kBrandPurple.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.spa,
                    color: Colors.white,
                    size: widget.size * 0.6,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// 🏷️ ETIQUETA DE ESTADO PREMIUM
class PremiumStatusTag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool isAnimated;

  const PremiumStatusTag({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.isAnimated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎛️ SELECTOR DE VISTA PREMIUM
class PremiumVistaSelector extends StatelessWidget {
  final String vistaActual;
  final Function(String) onVistaChanged;

  const PremiumVistaSelector({
    super.key,
    required this.vistaActual,
    required this.onVistaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kBorderColor.withValues(alpha: 0.02),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.005),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildVistaTab('estándar', Icons.view_sidebar, 'Estándar'),
          _buildVistaTab('favoritos', Icons.favorite, 'Favoritos'),
          _buildVistaTab('personalizada', Icons.tune, 'Custom'),
        ],
      ),
    );
  }

  Widget _buildVistaTab(String vista, IconData icon, String label) {
    final isActive = vistaActual == vista;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            onVistaChanged(vista);
            HapticFeedback.selectionClick();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [kBrandPurple, kAccentBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: kBrandPurple.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: isActive ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isActive ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
