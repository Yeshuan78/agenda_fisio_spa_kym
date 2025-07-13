// [crud_form_actions.dart] - BOTONES DE ACCIÓN FORMULARIO ENTERPRISE
// 📁 Ubicación: /lib/widgets/clients/forms/crud_form_actions.dart
// 🎯 OBJETIVO: Botones de acción profesionales con estados y feedback visual
// 👨‍💼 AUTOR: Ingeniero Senior - Fisio Spa KYM CRM Multinacional

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

/// ⚡ BOTONES DE ACCIÓN PARA FORMULARIOS CRUD
/// Features: estados loading/disabled, feedback visual, animaciones profesionales
class CrudFormActions extends StatefulWidget {
  // ✅ CONFIGURACIÓN DE BOTONES
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  // ✅ ESTADOS
  final bool isLoading;
  final bool isEnabled;
  final bool isEditing;
  final bool hasUnsavedChanges;

  // ✅ CONFIGURACIÓN VISUAL
  final Color primaryColor;
  final Color secondaryColor;
  final IconData? primaryIcon;
  final IconData? secondaryIcon;

  // ✅ FEEDBACK Y CONFIRMACIÓN
  final bool requireConfirmation;
  final String? confirmationMessage;
  final bool showProgress;
  final double? progress;

  // ✅ LAYOUT
  final MainAxisAlignment alignment;
  final bool fullWidth;
  final EdgeInsetsGeometry padding;

  const CrudFormActions({
    super.key,
    this.primaryButtonText = 'Guardar',
    this.secondaryButtonText = 'Cancelar',
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.isEditing = false,
    this.hasUnsavedChanges = false,
    this.primaryColor = kBrandPurple,
    this.secondaryColor = kTextSecondary,
    this.primaryIcon,
    this.secondaryIcon,
    this.requireConfirmation = false,
    this.confirmationMessage,
    this.showProgress = false,
    this.progress,
    this.alignment = MainAxisAlignment.end,
    this.fullWidth = false,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  State<CrudFormActions> createState() => _CrudFormActionsState();
}

class _CrudFormActionsState extends State<CrudFormActions>
    with TickerProviderStateMixin {
  
  // ✅ CONTROLADORES DE ANIMACIÓN
  late AnimationController _slideController;
  late AnimationController _primaryButtonController;
  late AnimationController _secondaryButtonController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _primaryScaleAnimation;
  late Animation<double> _secondaryScaleAnimation;

  // ✅ ESTADO INTERNO
  bool _primaryPressed = false;
  bool _secondaryPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimation();
  }

  void _initializeAnimations() {
    // Animación de entrada
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Animaciones de botones
    _primaryButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _secondaryButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _primaryScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _primaryButtonController,
      curve: Curves.easeInOut,
    ));

    _secondaryScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _secondaryButtonController,
      curve: Curves.easeInOut,
    ));
  }

  void _startEntryAnimation() {
    // Delay para animación escalonada
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _primaryButtonController.dispose();
    _secondaryButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: widget.padding,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.fullWidth) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showProgress && widget.progress != null)
            _buildProgressIndicator(),
          
          if (widget.hasUnsavedChanges)
            _buildUnsavedChangesWarning(),

          const SizedBox(height: 16),
          
          _buildPrimaryButton(fullWidth: true),
          
          const SizedBox(height: 12),
          
          _buildSecondaryButton(fullWidth: true),
        ],
      );
    }

    return Column(
      children: [
        if (widget.showProgress && widget.progress != null)
          _buildProgressIndicator(),
        
        if (widget.hasUnsavedChanges)
          _buildUnsavedChangesWarning(),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: widget.alignment,
          children: [
            _buildSecondaryButton(),
            const SizedBox(width: 16),
            _buildPrimaryButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Guardando información...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.primaryColor,
                  fontFamily: kFontFamily,
                ),
              ),
              Text(
                '${(widget.progress! * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary,
                  fontFamily: kFontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: widget.progress,
            backgroundColor: kBorderSoft,
            valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsavedChangesWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kWarningColor.withValues(alpha: 0.1),
            kWarningColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kWarningColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kWarningColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.warning_outlined,
              color: kWarningColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cambios sin guardar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kWarningColor,
                    fontFamily: kFontFamily,
                  ),
                ),
                Text(
                  'Tienes modificaciones que se perderán si sales',
                  style: TextStyle(
                    fontSize: 12,
                    color: kTextSecondary,
                    fontFamily: kFontFamily,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({bool fullWidth = false}) {
    final effectiveIcon = widget.primaryIcon ?? 
        (widget.isEditing ? Icons.save : Icons.add_circle_outline);

    return AnimatedBuilder(
      animation: _primaryScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _primaryScaleAnimation.value,
          child: _buildGlassmorphismButton(
            text: widget.primaryButtonText,
            icon: effectiveIcon,
            color: widget.primaryColor,
            onPressed: widget.isEnabled && !widget.isLoading 
                ? _handlePrimaryAction 
                : null,
            isLoading: widget.isLoading,
            isPressed: _primaryPressed,
            fullWidth: fullWidth,
            isPrimary: true,
          ),
        );
      },
    );
  }

  Widget _buildSecondaryButton({bool fullWidth = false}) {
    final effectiveIcon = widget.secondaryIcon ?? Icons.close;

    return AnimatedBuilder(
      animation: _secondaryScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _secondaryScaleAnimation.value,
          child: _buildGlassmorphismButton(
            text: widget.secondaryButtonText,
            icon: effectiveIcon,
            color: widget.secondaryColor,
            onPressed: widget.onSecondaryPressed,
            isPressed: _secondaryPressed,
            fullWidth: fullWidth,
            isPrimary: false,
          ),
        );
      },
    );
  }

  Widget _buildGlassmorphismButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isPressed = false,
    bool fullWidth = false,
    bool isPrimary = false,
  }) {
    final isEnabled = onPressed != null && !isLoading;

    return Container(
      width: fullWidth ? double.infinity : null,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled && !isPressed ? [
          BoxShadow(
            color: color.withValues(alpha: isPrimary ? 0.3 : 0.15),
            blurRadius: isPrimary ? 12 : 8,
            offset: Offset(0, isPrimary ? 6 : 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          onTapDown: isEnabled ? (_) {
            setState(() {
              if (isPrimary) {
                _primaryPressed = true;
                _primaryButtonController.forward();
              } else {
                _secondaryPressed = true;
                _secondaryButtonController.forward();
              }
            });
          } : null,
          onTapUp: isEnabled ? (_) {
            setState(() {
              if (isPrimary) {
                _primaryPressed = false;
                _primaryButtonController.reverse();
              } else {
                _secondaryPressed = false;
                _secondaryButtonController.reverse();
              }
            });
          } : null,
          onTapCancel: () {
            setState(() {
              _primaryPressed = false;
              _secondaryPressed = false;
            });
            _primaryButtonController.reverse();
            _secondaryButtonController.reverse();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: isPrimary ? LinearGradient(
                colors: isEnabled ? [
                  color,
                  color.withValues(alpha: 0.8),
                ] : [
                  kTextMuted.withValues(alpha: 0.3),
                  kTextMuted.withValues(alpha: 0.2),
                ],
              ) : null,
              color: !isPrimary ? (isEnabled ? Colors.white : kTextMuted.withValues(alpha: 0.1)) : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPrimary 
                    ? Colors.white.withValues(alpha: 0.3)
                    : (isEnabled ? color.withValues(alpha: 0.3) : kTextMuted.withValues(alpha: 0.3)),
                width: isPrimary ? 1 : 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPrimary ? Colors.white : color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  Icon(
                    icon,
                    color: isPrimary 
                        ? Colors.white 
                        : (isEnabled ? color : kTextMuted),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isPrimary 
                        ? Colors.white 
                        : (isEnabled ? color : kTextMuted),
                    fontFamily: kFontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // 🎯 MÉTODOS DE LÓGICA DE NEGOCIO
  // ========================================================================

  void _handlePrimaryAction() {
    HapticFeedback.mediumImpact();

    if (widget.requireConfirmation) {
      _showConfirmationDialog();
    } else {
      widget.onPrimaryPressed?.call();
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.help_outline,
                color: widget.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Confirmar Acción'),
          ],
        ),
        content: Text(
          widget.confirmationMessage ?? 
              '¿Estás seguro de que deseas ${widget.primaryButtonText.toLowerCase()}?',
          style: const TextStyle(
            fontSize: 16,
            fontFamily: kFontFamily,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: kTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onPrimaryPressed?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Confirmar',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎯 VARIANTES ESPECIALIZADAS PARA DIFERENTES CONTEXTOS

/// 💾 ACCIONES PARA GUARDAR/EDITAR
class SaveFormActions extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final bool isLoading;
  final bool isEditing;
  final bool hasChanges;

  const SaveFormActions({
    super.key,
    this.onSave,
    this.onCancel,
    this.isLoading = false,
    this.isEditing = false,
    this.hasChanges = false,
  });

  @override
  Widget build(BuildContext context) {
    return CrudFormActions(
      primaryButtonText: isEditing ? 'Actualizar' : 'Guardar',
      secondaryButtonText: 'Cancelar',
      onPrimaryPressed: onSave,
      onSecondaryPressed: onCancel,
      isLoading: isLoading,
      isEditing: isEditing,
      hasUnsavedChanges: hasChanges,
      primaryColor: kBrandPurple,
      primaryIcon: isEditing ? Icons.save : Icons.add_circle_outline,
      secondaryIcon: Icons.close,
    );
  }
}

/// 🗑️ ACCIONES PARA ELIMINAR
class DeleteFormActions extends StatelessWidget {
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;
  final bool isLoading;
  final String itemName;

  const DeleteFormActions({
    super.key,
    this.onDelete,
    this.onCancel,
    this.isLoading = false,
    this.itemName = 'elemento',
  });

  @override
  Widget build(BuildContext context) {
    return CrudFormActions(
      primaryButtonText: 'Eliminar',
      secondaryButtonText: 'Cancelar',
      onPrimaryPressed: onDelete,
      onSecondaryPressed: onCancel,
      isLoading: isLoading,
      primaryColor: kErrorColor,
      primaryIcon: Icons.delete_outline,
      secondaryIcon: Icons.close,
      requireConfirmation: true,
      confirmationMessage: '¿Estás seguro de que deseas eliminar este $itemName? Esta acción no se puede deshacer.',
    );
  }
}

/// 📤 ACCIONES PARA EXPORTAR/PROCESAR
class ProcessFormActions extends StatelessWidget {
  final VoidCallback? onProcess;
  final VoidCallback? onCancel;
  final bool isLoading;
  final double? progress;
  final String processText;

  const ProcessFormActions({
    super.key,
    this.onProcess,
    this.onCancel,
    this.isLoading = false,
    this.progress,
    this.processText = 'Procesar',
  });

  @override
  Widget build(BuildContext context) {
    return CrudFormActions(
      primaryButtonText: processText,
      secondaryButtonText: 'Cancelar',
      onPrimaryPressed: onProcess,
      onSecondaryPressed: onCancel,
      isLoading: isLoading,
      showProgress: progress != null,
      progress: progress,
      primaryColor: kAccentBlue,
      primaryIcon: Icons.play_arrow,
      secondaryIcon: Icons.stop,
    );
  }
}

/// 📋 EJEMPLO DE USO
/*
// ✅ USO BÁSICO:
CrudFormActions(
  primaryButtonText: 'Guardar Cliente',
  secondaryButtonText: 'Cancelar',
  onPrimaryPressed: () => _saveClient(),
  onSecondaryPressed: () => Navigator.pop(context),
  isLoading: _isLoading,
  isEditing: widget.cliente != null,
  hasUnsavedChanges: _hasChanges,
)

// ✅ CON VARIANTES:
SaveFormActions(
  onSave: _saveClient,
  onCancel: _cancelForm,
  isLoading: _isLoading,
  isEditing: widget.isEditing,
  hasChanges: _formHasChanges,
)

// ✅ ACCIONES DE ELIMINACIÓN:
DeleteFormActions(
  onDelete: _deleteClient,
  onCancel: _cancelDelete,
  isLoading: _isDeleting,
  itemName: 'cliente',
)

// ✅ ACCIONES DE PROCESAMIENTO:
ProcessFormActions(
  onProcess: _exportClients,
  onCancel: _cancelExport,
  isLoading: _isExporting,
  progress: _exportProgress,
  processText: 'Exportar CSV',
)
*/