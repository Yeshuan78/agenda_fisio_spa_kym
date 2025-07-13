// [client_export_modal.dart] - MODAL REFACTORIZADO Y LIMPIO
// 📁 Ubicación: /lib/widgets/clients/export/client_export_modal.dart
// 🎯 OBJETIVO: Modal principal simple que usa componentes modulares

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/export_models.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/export_service.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/export_format_selector.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/export_fields_selector.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/export_filters_section.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/export_confirm_section.dart';

/// 🚀 MODAL ENTERPRISE REFACTORIZADO - SOLO ORCHESTACIÓN
class ClientExportModal extends StatefulWidget {
  final List<ClientModel> clients;
  final String title;
  final bool isSelectionMode;
  final List<String>? preSelectedFields;

  const ClientExportModal({
    super.key,
    required this.clients,
    this.title = 'Exportar Clientes',
    this.isSelectionMode = false,
    this.preSelectedFields,
  });

  @override
  State<ClientExportModal> createState() => _ClientExportModalState();
}

class _ClientExportModalState extends State<ClientExportModal>
    with TickerProviderStateMixin {
  // ✅ SERVICIOS
  final ClientExportService _exportService = ClientExportService();

  // ✅ CONTROLADORES DE ANIMACIÓN
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // ✅ ESTADO SIMPLIFICADO
  ExportFormat _selectedFormat = ExportFormat.csv;
  final Set<String> _selectedFields = <String>{};
  final Set<ClientStatus> _statusFilter = <ClientStatus>{};
  final Set<String> _tagsFilter = <String>{};
  DateTimeRange? _dateRange;

  bool _includePersonalInfo = true;
  bool _includeAddressInfo = true;
  bool _includeMetrics = false;
  bool _includeUtf8BOM = true;
  bool _includeFilterSuffix = true;

  bool _showPreview = false;
  bool _isExporting = false;
  ExportPreview? _currentPreview;
  String? _exportError;
  int _currentStep = 0;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDefaults();
    _startAnimations();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    ));
  }

  void _initializeDefaults() {
    _selectedFields.addAll(widget.preSelectedFields ??
        [
          'fullName',
          'email',
          'phone',
          'status',
        ]);

    if (_selectedFields.isEmpty) {
      final requiredFields = ExportField.getAllFields()
          .where((field) => field.isRequired)
          .map((field) => field.key);
      _selectedFields.addAll(requiredFields);
    }
  }

  void _startAnimations() {
    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: _buildModalContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalContent() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 900,
        maxHeight: 700,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildStepsIndicator(),
          Expanded(child: _buildContent()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: kHeaderGradient,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _selectedFormat.icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isSelectionMode
                      ? '${widget.clients.length} clientes seleccionados'
                      : 'Configurar exportación completa',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Formato', Icons.file_present),
          _buildStepConnector(),
          _buildStepIndicator(1, 'Campos', Icons.checklist),
          _buildStepConnector(),
          _buildStepIndicator(2, 'Filtros', Icons.filter_list),
          _buildStepConnector(),
          _buildStepIndicator(3, 'Confirmar', Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? kAccentGreen
                  : isActive
                      ? kBrandPurple
                      : kTextMuted.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isActive ? kBrandPurple : kTextMuted.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isCompleted || isActive ? Colors.white : kTextMuted,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? kBrandPurple : kTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      height: 2,
      width: 40,
      margin: const EdgeInsets.only(bottom: 24),
      color: kBorderSoft,
    );
  }

  Widget _buildContent() {
    return PageView(
      controller: _pageController,
      onPageChanged: (page) => setState(() => _currentStep = page),
      children: [
        // ✅ COMPONENTES MODULARES
        ExportFormatSelector(
          selectedFormat: _selectedFormat,
          onFormatChanged: (format) => setState(() => _selectedFormat = format),
        ),
        ExportFieldsSelector(
          selectedFields: _selectedFields,
          onFieldsChanged: (fields) => setState(() {
            _selectedFields.clear();
            _selectedFields.addAll(fields);
          }),
        ),
        ExportFiltersSection(
          statusFilter: _statusFilter,
          tagsFilter: _tagsFilter,
          dateRange: _dateRange,
          availableTags: _getAvailableTags(),
          includePersonalInfo: _includePersonalInfo,
          includeAddressInfo: _includeAddressInfo,
          includeMetrics: _includeMetrics,
          includeUtf8BOM: _includeUtf8BOM,
          includeFilterSuffix: _includeFilterSuffix,
          onStatusFilterChanged: (statuses) => setState(() {
            _statusFilter.clear();
            _statusFilter.addAll(statuses);
          }),
          onTagsFilterChanged: (tags) => setState(() {
            _tagsFilter.clear();
            _tagsFilter.addAll(tags);
          }),
          onDateRangeChanged: (range) => setState(() => _dateRange = range),
          onPersonalInfoChanged: (value) =>
              setState(() => _includePersonalInfo = value),
          onAddressInfoChanged: (value) =>
              setState(() => _includeAddressInfo = value),
          onMetricsChanged: (value) => setState(() => _includeMetrics = value),
          onUtf8BOMChanged: (value) => setState(() => _includeUtf8BOM = value),
          onFilterSuffixChanged: (value) =>
              setState(() => _includeFilterSuffix = value),
        ),
        ExportConfirmSection(
          clients: widget.clients,
          selectedFormat: _selectedFormat,
          selectedFields: _selectedFields,
          statusFilter: _statusFilter,
          tagsFilter: _tagsFilter,
          dateRange: _dateRange,
          includePersonalInfo: _includePersonalInfo,
          includeAddressInfo: _includeAddressInfo,
          includeMetrics: _includeMetrics,
          includeUtf8BOM: _includeUtf8BOM,
          includeFilterSuffix: _includeFilterSuffix,
          exportService: _exportService,
          isExporting: _isExporting,
          currentPreview: _currentPreview,
          onPreviewGenerated: (preview) => setState(() {
            _currentPreview = preview;
            _showPreview = true;
          }),
          onExportStarted: () => setState(() => _isExporting = true),
          onExportCompleted: (result) {
            setState(() => _isExporting = false);
            Navigator.of(context).pop(result);
          },
          onExportError: (error) => setState(() {
            _isExporting = false;
            _exportError = error;
          }),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kBorderSoft)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: _previousStep,
              child: const Text('Anterior'),
            ),
          const Spacer(),
          if (_exportError != null) ...[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kErrorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: kErrorColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _exportError!,
                        style: TextStyle(
                          fontSize: 12,
                          color: kErrorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (_currentStep < 3)
            ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Siguiente'),
            ),
        ],
      ),
    );
  }

  // ====================================================================
  // 🎯 MÉTODOS DE NAVEGACIÓN
  // ====================================================================

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }

  List<String> _getAvailableTags() {
    final tags = <String>{};
    for (final client in widget.clients) {
      for (final tag in client.tags) {
        tags.add(tag.label);
      }
    }
    return tags.toList()..sort();
  }
}

/// 🚀 FUNCIÓN HELPER PARA MOSTRAR EL MODAL
Future<ExportResult?> showClientExportModal(
  BuildContext context, {
  required List<ClientModel> clients,
  String? title,
  bool isSelectionMode = false,
  List<String>? preSelectedFields,
}) async {
  return await showDialog<ExportResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ClientExportModal(
      clients: clients,
      title: title ?? 'Exportar Clientes',
      isSelectionMode: isSelectionMode,
      preSelectedFields: preSelectedFields,
    ),
  );
}
