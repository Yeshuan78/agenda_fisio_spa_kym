// [clients_export_actions_widget.dart] - WIDGET INDEPENDIENTE DE ACCIONES DE EXPORTACIÓN
// 📁 Ubicación: /lib/widgets/clients/export/clients_export_actions_widget.dart
// 🎯 OBJETIVO: Widget separado para manejar todas las acciones de exportación

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/services/export/client_export_service.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/client_export_modal.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/utils/client_constants.dart';

/// 🚀 WIDGET INDEPENDIENTE PARA ACCIONES DE EXPORTACIÓN DE CLIENTES
/// Maneja toda la lógica de exportación separada del screen principal
class ClientsExportActionsWidget extends StatefulWidget {
  final List<ClientModel> allClients;
  final List<ClientModel> filteredClients;
  final Set<String> selectedClients;
  final ClientFilterCriteria currentFilter;
  final String searchQuery;
  final VoidCallback? onExportCompleted;

  const ClientsExportActionsWidget({
    super.key,
    required this.allClients,
    required this.filteredClients,
    required this.selectedClients,
    required this.currentFilter,
    required this.searchQuery,
    this.onExportCompleted,
  });

  @override
  State<ClientsExportActionsWidget> createState() => _ClientsExportActionsWidgetState();
}

class _ClientsExportActionsWidgetState extends State<ClientsExportActionsWidget> {
  // ✅ SERVICIOS
  final ClientExportService _exportService = ClientExportService();

  // ✅ ESTADO
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: _handleExportAction,
      tooltip: 'Opciones de exportación',
      itemBuilder: (context) => _buildExportMenuItems(),
      child: _buildExportButton(),
    );
  }

  /// 🎨 BOTÓN PRINCIPAL DE EXPORTACIÓN
  Widget _buildExportButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderSoft),
        boxShadow: kSombraCard,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isExporting) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(kAccentGreen),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Exportando...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kAccentGreen,
                ),
              ),
            ] else ...[
              Icon(
                Icons.download_outlined,
                size: 20,
                color: kTextSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Exportar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: kTextSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 📋 ITEMS DEL MENÚ DE EXPORTACIÓN
  List<PopupMenuEntry<String>> _buildExportMenuItems() {
    final items = <PopupMenuEntry<String>>[];

    // Header del menú
    items.add(
      PopupMenuItem<String>(
        enabled: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.download_outlined, size: 18, color: kBrandPurple),
              const SizedBox(width: 8),
              Text(
                'Opciones de Exportación',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    items.add(const PopupMenuDivider());

    // Exportar todo
    items.add(
      PopupMenuItem<String>(
        value: 'export_all',
        child: _buildMenuItem(
          icon: Icons.select_all,
          title: 'Exportar Todo',
          subtitle: '${widget.filteredClients.length} clientes',
          color: kAccentGreen,
        ),
      ),
    );

    // Exportar seleccionados (solo si hay selección)
    if (widget.selectedClients.isNotEmpty) {
      items.add(
        PopupMenuItem<String>(
          value: 'export_selected',
          child: _buildMenuItem(
            icon: Icons.checklist,
            title: 'Exportar Seleccionados',
            subtitle: '${widget.selectedClients.length} clientes',
            color: kBrandPurple,
          ),
        ),
      );
    }

    items.add(const PopupMenuDivider());

    // Exportaciones rápidas
    items.add(
      PopupMenuItem<String>(
        value: 'quick_csv',
        child: _buildMenuItem(
          icon: Icons.table_chart,
          title: 'CSV Completo',
          subtitle: 'Todos los campos',
          color: kAccentBlue,
        ),
      ),
    );

    items.add(
      PopupMenuItem<String>(
        value: 'quick_contacts',
        child: _buildMenuItem(
          icon: Icons.contacts,
          title: 'Solo Contactos',
          subtitle: 'Nombre, email, teléfono',
          color: Colors.orange,
        ),
      ),
    );

    // Solo mostrar Excel si hay menos de 1000 registros
    if (widget.filteredClients.length < 1000) {
      items.add(
        PopupMenuItem<String>(
          value: 'quick_excel',
          child: _buildMenuItem(
            icon: Icons.grid_on,
            title: 'Excel Rápido',
            subtitle: 'Formato .xlsx',
            color: Colors.green,
          ),
        ),
      );
    }

    return items;
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: kTextSecondary,
        ),
      ),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  /// 🎯 MANEJADOR PRINCIPAL DE ACCIONES
  Future<void> _handleExportAction(String action) async {
    if (_isExporting) return;

    HapticFeedback.lightImpact();

    switch (action) {
      case 'export_all':
        await _exportAllClients();
        break;
      case 'export_selected':
        await _exportSelectedClients();
        break;
      case 'quick_csv':
        await _quickExportCSV();
        break;
      case 'quick_contacts':
        await _quickExportContacts();
        break;
      case 'quick_excel':
        await _quickExportExcel();
        break;
    }
  }

  // ====================================================================
  // 🎯 MÉTODOS DE EXPORTACIÓN
  // ====================================================================

  /// 📊 EXPORTAR TODOS LOS CLIENTES FILTRADOS
  Future<void> _exportAllClients() async {
    if (widget.filteredClients.isEmpty) {
      _showErrorSnackBar('No hay clientes para exportar');
      return;
    }

    // Confirmar exportación grande
    if (widget.filteredClients.length > 1000) {
      final confirmed = await _showConfirmDialog(
        'Exportación Grande',
        'Vas a exportar ${widget.filteredClients.length} clientes. '
        'Esto puede tomar tiempo. ¿Continuar?',
      );
      if (!confirmed) return;
    }

    await _showExportModal(
      clients: widget.filteredClients,
      title: 'Exportar ${widget.filteredClients.length} Clientes',
      isSelectionMode: false,
    );
  }

  /// 📋 EXPORTAR SOLO CLIENTES SELECCIONADOS
  Future<void> _exportSelectedClients() async {
    final selectedClientModels = widget.filteredClients
        .where((client) => widget.selectedClients.contains(client.clientId))
        .toList();

    if (selectedClientModels.isEmpty) {
      _showErrorSnackBar('No se encontraron clientes seleccionados');
      return;
    }

    await _showExportModal(
      clients: selectedClientModels,
      title: 'Exportar ${selectedClientModels.length} Clientes Seleccionados',
      isSelectionMode: true,
      preSelectedFields: ['fullName', 'email', 'phone', 'status', 'tags'],
    );
  }

  /// ⚡ EXPORTACIÓN RÁPIDA CSV
  Future<void> _quickExportCSV() async {
    await _performQuickExport(
      format: ExportFormat.csv,
      fields: [
        'fullName', 'email', 'phone', 'company', 
        'status', 'tags', 'address', 'createdAt'
      ],
      filename: 'clientes_completo',
    );
  }

  /// 📱 EXPORTACIÓN RÁPIDA SOLO CONTACTOS
  Future<void> _quickExportContacts() async {
    await _performQuickExport(
      format: ExportFormat.csv,
      fields: ['fullName', 'email', 'phone'],
      filename: 'contactos_clientes',
    );
  }

  /// 📈 EXPORTACIÓN RÁPIDA EXCEL
  Future<void> _quickExportExcel() async {
    await _performQuickExport(
      format: ExportFormat.excel,
      fields: [
        'fullName', 'email', 'phone', 'company',
        'status', 'tags', 'appointmentsCount', 'totalRevenue'
      ],
      filename: 'clientes_excel',
    );
  }

  // ====================================================================
  // 🔧 MÉTODOS HELPER
  // ====================================================================

  /// 🚀 MOSTRAR MODAL DE EXPORTACIÓN
  Future<void> _showExportModal({
    required List<ClientModel> clients,
    required String title,
    required bool isSelectionMode,
    List<String>? preSelectedFields,
  }) async {
    setState(() => _isExporting = true);

    try {
      final result = await showClientExportModal(
        context,
        clients: clients,
        title: title,
        isSelectionMode: isSelectionMode,
        preSelectedFields: preSelectedFields,
      );

      if (result != null && result.isSuccess) {
        _showSuccessSnackBar(
          'Exportación completada: ${result.fileName} (${result.formattedSize})',
        );
        _onExportCompleted();
      }

    } catch (e) {
      _showErrorSnackBar('Error durante la exportación: $e');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /// ⚡ REALIZAR EXPORTACIÓN RÁPIDA
  Future<void> _performQuickExport({
    required ExportFormat format,
    required List<String> fields,
    required String filename,
  }) async {
    setState(() => _isExporting = true);

    try {
      final options = ExportOptions(
        format: format,
        selectedFields: fields,
        includePersonalInfo: true,
        includeAddressInfo: fields.contains('address'),
        includeMetrics: fields.any((f) => ['appointmentsCount', 'totalRevenue', 'satisfactionScore'].contains(f)),
        includeUtf8BOM: format == ExportFormat.csv,
        includeFilterSuffix: true,
      );

      ExportResult result;
      switch (format) {
        case ExportFormat.csv:
          result = await _exportService.exportToCSV(
            clients: widget.filteredClients,
            options: options,
          );
          break;
        case ExportFormat.excel:
          result = await _exportService.exportToExcel(
            clients: widget.filteredClients,
            options: options,
          );
          break;
        case ExportFormat.pdf:
          result = await _exportService.exportToPDF(
            clients: widget.filteredClients,
            options: options,
          );
          break;
        case ExportFormat.json:
          result = await _exportService.exportToJSON(
            clients: widget.filteredClients,
            options: options,
          );
          break;
      }

      if (result.isSuccess) {
        _showSuccessSnackBar(
          '${format.displayName} exportado: ${result.fileName} (${result.formattedSize})',
        );
        _onExportCompleted();
      } else {
        _showErrorSnackBar(result.errorMessage ?? 'Error en exportación');
      }

    } catch (e) {
      _showErrorSnackBar('Error exportando ${format.displayName}: $e');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /// ✅ CALLBACK DE EXPORTACIÓN COMPLETADA
  void _onExportCompleted() {
    widget.onExportCompleted?.call();
    
    // Analytics
    debugPrint('📊 Export completed - tracking analytics');
    _trackExportEvent();
  }

  /// 📈 TRACKING DE ANALYTICS
  void _trackExportEvent() {
    final stats = {
      'total_clients': widget.allClients.length,
      'filtered_clients': widget.filteredClients.length,
      'selected_clients': widget.selectedClients.length,
      'has_filters': !widget.currentFilter.isEmpty,
      'has_search': widget.searchQuery.isNotEmpty,
      'timestamp': DateTime.now().toIso8601String(),
    };

    debugPrint('📊 Export Analytics: $stats');
    
    // TODO: Integrar con servicio de analytics
    // AnalyticsService.track('client_export_completed', stats);
  }

  /// ❓ DIÁLOGO DE CONFIRMACIÓN
  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kBrandPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// ✅ SNACKBAR DE ÉXITO
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: kAccentGreen,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Abrir carpeta de descargas
            debugPrint('🔗 Opening downloads folder');
          },
        ),
      ),
    );
  }

  /// ❌ SNACKBAR DE ERROR
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: kErrorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// 🎯 WIDGET SIMPLIFICADO PARA TOOLBAR
/// Widget más compacto para usar en el bulk toolbar
class ClientsExportButtonCompact extends StatelessWidget {
  final List<ClientModel> clients;
  final bool isLoading;
  final VoidCallback? onExportCompleted;

  const ClientsExportButtonCompact({
    super.key,
    required this.clients,
    this.isLoading = false,
    this.onExportCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Exportar seleccionados',
      child: InkWell(
        onTap: isLoading ? null : () => _handleQuickExport(context),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isLoading 
                ? kAccentGreen.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLoading
                  ? kAccentGreen.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(
                  Icons.download_outlined,
                  color: Colors.white,
                  size: 20,
                ),
        ),
      ),
    );
  }

  Future<void> _handleQuickExport(BuildContext context) async {
    HapticFeedback.lightImpact();

    if (clients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay clientes para exportar'),
          backgroundColor: kErrorColor,
        ),
      );
      return;
    }

    // Mostrar modal de exportación
    final result = await showClientExportModal(
      context,
      clients: clients,
      title: 'Exportar ${clients.length} Clientes Seleccionados',
      isSelectionMode: true,
      preSelectedFields: ['fullName', 'email', 'phone', 'status'],
    );

    if (result != null && result.isSuccess) {
      onExportCompleted?.call();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exportado: ${result.fileName}'),
          backgroundColor: kAccentGreen,
        ),
      );
    }
  }
}