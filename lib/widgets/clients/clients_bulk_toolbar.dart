// [clients_bulk_toolbar.dart] - ✅ FIX CRÍTICO: SELECCIÓN SOLO POR PÁGINA ACTUAL
// 📁 Ubicación: /lib/widgets/clients/clients_bulk_toolbar.dart
// 🎯 OBJETIVO: Toolbar que solo selecciona clientes de la página actual, no todos los filtrados
// ✅ FIX: Cambiar lógica para trabajar con página actual en lugar de todos los filtrados

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/utils/client_constants.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/client_export_modal.dart';

/// 🔧 TOOLBAR DE ACCIONES MASIVAS PARA CLIENTES - ✅ SELECCIÓN SOLO POR PÁGINA
class ClientsBulkToolbar extends StatefulWidget {
  final Set<String> selectedClients;
  final List<ClientModel> allClients;
  final List<ClientModel> filteredClients;

  // ✅ NUEVO: Clientes de la página actual
  final List<ClientModel> currentPageClients;
  final int totalFilteredClients;
  final Function(List<String>) onBulkDelete;
  final Function(List<String>, List<ClientTag>) onBulkAddTags;
  final Function(List<String>) onBulkExport;
  final VoidCallback onClearSelection;

  // ✅ MODIFICADO: Ahora selecciona solo página actual
  final VoidCallback onSelectCurrentPage;
  final VoidCallback? onExportCompleted;

  const ClientsBulkToolbar({
    super.key,
    required this.selectedClients,
    required this.allClients,
    required this.filteredClients,
    required this.currentPageClients, // ✅ NUEVO PARÁMETRO
    required this.totalFilteredClients,
    required this.onBulkDelete,
    required this.onBulkAddTags,
    required this.onBulkExport,
    required this.onClearSelection,
    required this.onSelectCurrentPage, // ✅ MODIFICADO
    this.onExportCompleted,
  });

  @override
  State<ClientsBulkToolbar> createState() => _ClientsBulkToolbarState();
}

class _ClientsBulkToolbarState extends State<ClientsBulkToolbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _wasVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    _wasVisible = widget.selectedClients.isNotEmpty;

    if (_wasVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _animationController.forward();
        }
      });
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didUpdateWidget(ClientsBulkToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final isVisible = widget.selectedClients.isNotEmpty;

    if (isVisible != _wasVisible) {
      debugPrint('🔧 TOOLBAR: Visibilidad cambió: $_wasVisible -> $isVisible');
      debugPrint('🔧 TOOLBAR: Seleccionados: ${widget.selectedClients.length}');

      _wasVisible = isVisible;

      if (isVisible) {
        _animationController.forward();
        HapticFeedback.lightImpact();
      } else {
        _animationController.reverse();
      }
    }

    if (oldWidget.selectedClients.length != widget.selectedClients.length) {
      debugPrint(
          '🔧 TOOLBAR: Selección cambió: ${oldWidget.selectedClients.length} -> ${widget.selectedClients.length}');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedClients.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildToolbar(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolbar() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kBrandPurple,
                kBrandPurple.withAlpha((0.9 * 255).round()),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kBrandPurple.withAlpha((0.4 * 255).round()),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  _buildSelectionInfo(),
                  const Spacer(),
                  _buildActionButtons(),
                  const SizedBox(width: 16),
                  _buildCloseButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionInfo() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              widget.selectedClients.length.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.selectedClients.length} seleccionados',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              _getSelectionSubtitle(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSelectCurrentPageButton(),
        const SizedBox(width: 8),
        _buildActionButton(
          Icons.label_outline,
          'Etiquetas',
          _showAddTagsDialog,
        ),
        const SizedBox(width: 8),
        _buildExportButton(context),
        const SizedBox(width: 8),
        _buildActionButton(
          Icons.delete_outline,
          'Eliminar',
          _handleDelete,
          isDestructive: true,
        ),
      ],
    );
  }

  /// ✅ FIX CRÍTICO: BOTÓN PARA SELECCIONAR SOLO PÁGINA ACTUAL
  Widget _buildSelectCurrentPageButton() {
    // ✅ VERIFICAR SI TODOS LOS CLIENTES DE LA PÁGINA ACTUAL ESTÁN SELECCIONADOS
    final allCurrentPageSelected = _areAllCurrentPageSelected();
    final hasPartialSelection =
        widget.selectedClients.isNotEmpty && !allCurrentPageSelected;

    return Tooltip(
      message: allCurrentPageSelected
          ? 'Deseleccionar página'
          : 'Seleccionar página actual',
      child: InkWell(
        onTap: () {
          debugPrint('🔧 TOOLBAR: SelectCurrentPage button presionado');
          debugPrint(
              '🔧 TOOLBAR: allCurrentPageSelected=$allCurrentPageSelected');
          debugPrint(
              '🔧 TOOLBAR: currentPageClients=${widget.currentPageClients.length}');

          _handleSelectCurrentPageToggle(allCurrentPageSelected);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withAlpha((0.3 * 255).round()),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                allCurrentPageSelected
                    ? Icons.deselect
                    : hasPartialSelection
                        ? Icons.select_all
                        : Icons.check_box_outline_blank,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                allCurrentPageSelected ? 'Deseleccionar' : 'Seleccionar página',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String tooltip,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withAlpha((0.2 * 255).round())
                : Colors.white.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDestructive
                  ? Colors.red.withAlpha((0.3 * 255).round())
                  : Colors.white.withAlpha((0.3 * 255).round()),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red.shade100 : Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return InkWell(
      onTap: () {
        debugPrint('🔧 TOOLBAR: Close button presionado');
        _handleClose();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.2 * 255).round()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return Tooltip(
      message: 'Exportar seleccionados',
      child: InkWell(
        onTap: () => _handleExportSelected(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kAccentGreen.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: kAccentGreen.withAlpha((0.3 * 255).round()),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                'Exportar',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // ✅ FIX CRÍTICO: MÉTODOS DE LÓGICA PARA PÁGINA ACTUAL
  // ====================================================================

  /// ✅ VERIFICAR SI TODOS LOS CLIENTES DE LA PÁGINA ACTUAL ESTÁN SELECCIONADOS
  bool _areAllCurrentPageSelected() {
    if (widget.currentPageClients.isEmpty) return false;

    // ✅ VERIFICAR QUE TODOS LOS CLIENTES DE LA PÁGINA ACTUAL ESTÉN EN LA SELECCIÓN
    return widget.currentPageClients
        .every((client) => widget.selectedClients.contains(client.clientId));
  }

  /// ✅ TOGGLE SELECCIÓN DE PÁGINA ACTUAL
  void _handleSelectCurrentPageToggle(bool allCurrentPageSelected) {
    HapticFeedback.lightImpact();

    debugPrint(
        '🔧 TOOLBAR: _handleSelectCurrentPageToggle llamado con allCurrentPageSelected=$allCurrentPageSelected');

    try {
      if (allCurrentPageSelected) {
        // Deseleccionar todos
        debugPrint('✅ TOOLBAR: Ejecutando deselección total');
        widget.onClearSelection();
      } else {
        // Seleccionar solo los clientes de la página actual
        debugPrint('✅ TOOLBAR: Ejecutando selección de página actual');
        widget.onSelectCurrentPage();
      }
    } catch (e) {
      debugPrint('❌ TOOLBAR: Error en _handleSelectCurrentPageToggle: $e');
    }
  }

  void _handleClose() {
    HapticFeedback.lightImpact();

    debugPrint('✅ TOOLBAR: Cerrando toolbar - ejecutando onClearSelection');

    try {
      widget.onClearSelection();
    } catch (e) {
      debugPrint('❌ TOOLBAR: Error en _handleClose: $e');
    }
  }

  String _getSelectionSubtitle() {
    final count = widget.selectedClients.length;
    final currentPageCount = widget.currentPageClients.length;

    if (count > ClientConstants.MAX_BULK_OPERATIONS) {
      return 'Máximo ${ClientConstants.MAX_BULK_OPERATIONS} por operación';
    }

    if (_areAllCurrentPageSelected() && currentPageCount > 0) {
      return 'Toda la página seleccionada ($currentPageCount de $currentPageCount)';
    }

    return 'Clientes de página actual: $count de $currentPageCount';
  }

  // ====================================================================
  // 🆕 RESTO DE MÉTODOS
  // ====================================================================

  Future<void> _handleExportSelected(BuildContext context) async {
    HapticFeedback.lightImpact();

    if (widget.selectedClients.length > ClientConstants.MAX_EXPORT_RECORDS) {
      _showErrorDialog(
        'Límite de exportación',
        'Solo puedes exportar hasta ${ClientConstants.MAX_EXPORT_RECORDS} clientes a la vez.',
      );
      return;
    }

    // ✅ USAR CLIENTES DE LA PÁGINA ACTUAL PARA EXPORTACIÓN
    final selectedClientModels = widget.currentPageClients
        .where((client) => widget.selectedClients.contains(client.clientId))
        .toList();

    if (selectedClientModels.isEmpty) {
      _showErrorDialog(
        'Sin selección',
        'No se encontraron clientes seleccionados para exportar.',
      );
      return;
    }

    final result = await showClientExportModal(
      context,
      clients: selectedClientModels,
      title: 'Exportar ${selectedClientModels.length} Clientes Seleccionados',
      isSelectionMode: true,
      preSelectedFields: ['fullName', 'email', 'phone', 'status', 'tags'],
    );

    if (result != null && result.isSuccess) {
      widget.onExportCompleted?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Exportado: ${result.fileName} (${result.formattedSize})',
                ),
              ),
            ],
          ),
          backgroundColor: kAccentGreen,
          duration: const Duration(seconds: 4),
        ),
      );

      widget.onBulkExport(widget.selectedClients.toList());
    }
  }

  void _handleDelete() {
    HapticFeedback.mediumImpact();

    if (widget.selectedClients.length > ClientConstants.MAX_BULK_OPERATIONS) {
      _showErrorDialog(
        'Límite de operación',
        'Solo puedes eliminar hasta ${ClientConstants.MAX_BULK_OPERATIONS} clientes a la vez.',
      );
      return;
    }

    _showDeleteConfirmation();
  }

  void _showAddTagsDialog() {
    HapticFeedback.lightImpact();

    if (widget.selectedClients.length > ClientConstants.MAX_BULK_OPERATIONS) {
      _showErrorDialog(
        'Límite de operación',
        'Solo puedes agregar etiquetas a ${ClientConstants.MAX_BULK_OPERATIONS} clientes a la vez.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _AddTagsDialog(
        selectedCount: widget.selectedClients.length,
        onAddTags: (tags) {
          widget.onBulkAddTags(widget.selectedClients.toList(), tags);
        },
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que deseas eliminar ${widget.selectedClients.length} clientes?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.red.withAlpha((0.3 * 255).round())),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Esta acción no se puede deshacer',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onBulkDelete(widget.selectedClients.toList());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

/// 🏷️ DIALOG PARA AGREGAR ETIQUETAS
class _AddTagsDialog extends StatefulWidget {
  final int selectedCount;
  final Function(List<ClientTag>) onAddTags;

  const _AddTagsDialog({
    required this.selectedCount,
    required this.onAddTags,
  });

  @override
  State<_AddTagsDialog> createState() => _AddTagsDialogState();
}

class _AddTagsDialogState extends State<_AddTagsDialog> {
  final Set<String> _selectedBaseTags = <String>{};
  final TextEditingController _customTagController = TextEditingController();
  final List<String> _customTags = <String>[];

  @override
  void dispose() {
    _customTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kBrandPurple.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.label_outline,
              color: kBrandPurple,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agregar Etiquetas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'A ${widget.selectedCount} clientes',
                  style: TextStyle(
                    fontSize: 14,
                    color: kTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBaseTagsSection(),
              const SizedBox(height: 20),
              _buildCustomTagsSection(),
              if (_getSelectedTagsCount() > 0) ...[
                const SizedBox(height: 20),
                _buildSelectedTagsPreview(),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _getSelectedTagsCount() > 0 ? _handleAddTags : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: kBrandPurple,
            foregroundColor: Colors.white,
          ),
          child: Text('Agregar ${_getSelectedTagsCount()} etiquetas'),
        ),
      ],
    );
  }

  Widget _buildBaseTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Etiquetas base:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ClientConstants.DEFAULT_TAGS.map((tag) {
            final isSelected = _selectedBaseTags.contains(tag);
            final color = ClientConstants.getBaseTagColor(tag);

            return InkWell(
              onTap: () => _toggleBaseTag(tag),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: ClientConstants.MICRO_ANIMATION_DURATION,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isSelected ? color : color.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : color.withAlpha((0.3 * 255).round()),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Etiqueta personalizada:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _customTagController,
                decoration: InputDecoration(
                  hintText: 'Escribe una etiqueta personalizada',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kBorderSoft),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kBorderSoft),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kBrandPurple, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onFieldSubmitted: (_) => _addCustomTag(),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _addCustomTag,
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
        if (_customTags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _customTags.map((tag) {
              final colorIndex = _customTags.indexOf(tag);
              final color = ClientConstants.getCustomTagColor(colorIndex);

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: color.withAlpha((0.3 * 255).round())),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _removeCustomTag(tag),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedTagsPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBrandPurple.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBrandPurple.withAlpha((0.2 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: kBrandPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Etiquetas a agregar (${_getSelectedTagsCount()}):',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Se agregarán a ${widget.selectedCount} clientes seleccionados',
            style: TextStyle(
              fontSize: 12,
              color: kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleBaseTag(String tag) {
    setState(() {
      if (_selectedBaseTags.contains(tag)) {
        _selectedBaseTags.remove(tag);
      } else {
        _selectedBaseTags.add(tag);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _addCustomTag() {
    final tag = _customTagController.text.trim();
    if (tag.isEmpty) return;

    if (_customTags.contains(tag) || _selectedBaseTags.contains(tag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta etiqueta ya fue agregada'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _customTags.add(tag);
      _customTagController.clear();
    });

    HapticFeedback.lightImpact();
  }

  void _removeCustomTag(String tag) {
    setState(() {
      _customTags.remove(tag);
    });
    HapticFeedback.lightImpact();
  }

  void _handleAddTags() {
    final tags = <ClientTag>[];

    for (final tag in _selectedBaseTags) {
      tags.add(ClientTag(
        label: tag,
        type: TagType.base,
        createdAt: DateTime.now(),
      ));
    }

    for (int i = 0; i < _customTags.length; i++) {
      final tag = _customTags[i];
      final color = ClientConstants.getCustomTagColor(i);

      tags.add(ClientTag(
        label: tag,
        color: '#${color.value.toRadixString(16).substring(2)}',
        type: TagType.custom,
        createdAt: DateTime.now(),
      ));
    }

    Navigator.of(context).pop();
    widget.onAddTags(tags);

    HapticFeedback.mediumImpact();
  }

  int _getSelectedTagsCount() {
    return _selectedBaseTags.length + _customTags.length;
  }
}
