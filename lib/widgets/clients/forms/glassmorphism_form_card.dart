// [glassmorphism_form_card.dart] - CARD BASE PARA FORMULARIOS - CORREGIDO
// 📁 Ubicación: /lib/widgets/clients/forms/glassmorphism_form_card.dart
// 🎯 OBJETIVO: Wrapper glassmorphism especializado para secciones de formulario

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ AGREGADO: Import para TextInputFormatter
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

/// 🎨 CARD BASE GLASSMORPHISM PARA FORMULARIOS
class GlassmorphismFormCard extends StatefulWidget {
  final Widget child;
  final String? title;
  final IconData? titleIcon;
  final String? subtitle;
  final Color primaryColor;
  final bool isRequired;
  final bool hasError;
  final String? errorMessage;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool enableHover;
  final VoidCallback? onTap;

  const GlassmorphismFormCard({
    super.key,
    required this.child,
    this.title,
    this.titleIcon,
    this.subtitle,
    this.primaryColor = kBrandPurple,
    this.isRequired = false,
    this.hasError = false,
    this.errorMessage,
    this.padding = const EdgeInsets.all(24),
    this.margin = const EdgeInsets.only(bottom: 24),
    this.borderRadius = 16.0,
    this.enableHover = true,
    this.onTap,
  });

  @override
  State<GlassmorphismFormCard> createState() => _GlassmorphismFormCardState();
}

class _GlassmorphismFormCardState extends State<GlassmorphismFormCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  // ✅ REMOVIDO: _elevationAnimation no utilizado
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.01,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // ✅ REMOVIDO: _elevationAnimation no utilizado
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin,
            child: widget.enableHover
                ? MouseRegion(
                    onEnter: (_) => _handleHoverStart(),
                    onExit: (_) => _handleHoverEnd(),
                    child: _buildCard(),
                  )
                : _buildCard(),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: _buildGlassmorphismDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title != null) ...[
              _buildCardHeader(),
              const SizedBox(height: 20),
            ],
            Container(
              padding: widget.padding,
              child: widget.child,
            ),
            if (widget.hasError && widget.errorMessage != null) ...[
              const SizedBox(height: 12),
              _buildErrorMessage(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          if (widget.titleIcon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.primaryColor.withValues(alpha: 0.2),
                    widget.primaryColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.primaryColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                widget.titleIcon,
                color: widget.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.primaryColor,
                          fontFamily: kFontFamily,
                        ),
                      ),
                    ),
                    if (widget.isRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          // ✅ CORREGIDO: const
                          'REQUERIDO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: kTextSecondary,
                      fontFamily: kFontFamily,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade700,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.errorMessage!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildGlassmorphismDecoration() {
    final intensity = _isHovered ? 1.3 : 1.0;
    final errorOverride = widget.hasError;
    final borderColor = errorOverride
        ? Colors.red.withValues(alpha: 0.4)
        : widget.primaryColor.withValues(alpha: _isHovered ? 0.3 : 0.15);

    return BoxDecoration(
      // ✅ GRADIENTE GLASSMORPHISM BASE
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: errorOverride
            ? [
                Colors.red.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.7),
                Colors.red.withValues(alpha: 0.03),
              ]
            : [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.7),
                widget.primaryColor.withValues(alpha: 0.05),
                widget.primaryColor.withValues(alpha: 0.025),
              ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),

      borderRadius: BorderRadius.circular(widget.borderRadius),

      // ✅ BORDE GLASSMORPHISM
      border: Border.all(
        color: borderColor,
        width: _isHovered ? 2.0 : 1.5,
      ),

      // ✅ SOMBRAS MULTICAPA GLASSMORPHISM
      boxShadow: [
        // SOMBRA PRINCIPAL COLOREADA
        BoxShadow(
          color: (errorOverride ? Colors.red : widget.primaryColor)
              .withValues(alpha: 0.15 * intensity),
          blurRadius: 20 * intensity,
          spreadRadius: 2 * intensity,
          offset: Offset(0, 8 * intensity),
        ),
        // SOMBRA INTERNA GLASSMORPHISM
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.8),
          blurRadius: 15 * intensity,
          spreadRadius: -5 * intensity,
          offset: Offset(0, -5 * intensity),
        ),
        // SOMBRA DE PROFUNDIDAD
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05 * intensity),
          blurRadius: 30 * intensity,
          spreadRadius: 0,
          offset: Offset(0, 15 * intensity),
        ),
      ],
    );
  }

  void _handleHoverStart() {
    if (widget.enableHover && mounted) {
      setState(() => _isHovered = true);
      _animationController.forward();
    }
  }

  void _handleHoverEnd() {
    if (widget.enableHover && mounted) {
      setState(() => _isHovered = false);
      _animationController.reverse();
    }
  }
}

/// 🎨 GLASSMORPHISM INPUT FIELD ESPECIALIZADO
class GlassmorphismInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool isRequired;
  final String? errorText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters; // ✅ CORREGIDO: Tipo correcto
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final bool obscureText;
  final bool enabled;

  const GlassmorphismInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.isRequired = false,
    this.errorText,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.nextFocusNode,
    this.prefixIcon,
    this.suffixWidget,
    this.obscureText = false,
    this.enabled = true,
  });

  @override
  State<GlassmorphismInputField> createState() =>
      _GlassmorphismInputFieldState();
}

class _GlassmorphismInputFieldState extends State<GlassmorphismInputField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? Colors.red.withValues(alpha: 0.4)
        : _isFocused
            ? kBrandPurple.withValues(alpha: 0.6)
            : kBorderSoft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label con indicador requerido
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: hasError ? Colors.red.shade700 : kTextSecondary,
              ),
            ),
            if (widget.isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Campo de texto glassmorphism
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: _isFocused ? 2.0 : 1.5,
            ),
            boxShadow: [
              if (_isFocused) ...[
                BoxShadow(
                  color: kBrandPurple.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onFieldSubmitted: (value) {
              widget.onSubmitted?.call(value);
              if (widget.nextFocusNode != null) {
                FocusScope.of(context).requestFocus(widget.nextFocusNode);
              }
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused ? kBrandPurple : kTextMuted,
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.suffixWidget,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                // ✅ CORREGIDO: const
                horizontal: 16,
                vertical: 16,
              ),
              counterText: '', // Ocultar contador
              hintStyle: TextStyle(
                color: kTextMuted,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),

        // Mensaje de error
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: Colors.red.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
