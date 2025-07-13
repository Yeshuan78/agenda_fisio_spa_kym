// [client_import_modal.dart] - FIX: PASAR HEADERS CORRECTOS AL VALIDADOR
// 🚨 PROBLEMA: ImportValidationSection necesita headers reales del parser
// ✅ SOLUCIÓN: Pasar parseResult.headers al validador

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'import_models.dart';
import 'import_service.dart';
import 'file_parser_service.dart';
import 'import_file_selector.dart';
import 'import_field_mapper.dart';
import 'import_validation_section.dart';
import 'import_progress_section.dart';

/// 🎯 FUNCIÓN GLOBAL EXPORTABLE
Future<ImportResult?> showClientImportModal(BuildContext context) async {
  return showDialog<ImportResult?>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const ClientImportModal(),
  );
}

/// 🎭 MODAL PRINCIPAL
class ClientImportModal extends StatefulWidget {
  const ClientImportModal({super.key});

  @override
  State<ClientImportModal> createState() => _ClientImportModalState();
}

class _ClientImportModalState extends State<ClientImportModal> {
  final ClientImportService _importService = ClientImportService();
  final FileParserService _parser = FileParserService();

  int _currentStep = 0;
  bool _isProcessing = false;

  ImportFileInfo? _selectedFile;
  ParseResult? _parseResult;
  List<FieldMapping> _mappings = [];
  MappingConfiguration? _mappingConfig;
  ValidationResult? _validationResult;
  ImportProgress _progress = ImportProgress.initial();
  ImportResult? _finalResult;
  List<String> _importLogs = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: kSombraCardElevated,
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildStepper(),
            Expanded(child: _buildContent()),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: kHeaderGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.upload_file, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Importar Clientes',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(_getStepDescription(),
                    style:
                        const TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          IconButton(
            onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStep(0, 'Archivo', Icons.upload_file),
          Expanded(
              child: Container(
                  height: 2,
                  color: _currentStep > 0 ? kAccentGreen : kBorderSoft)),
          _buildStep(1, 'Mapeo', Icons.compare_arrows),
          Expanded(
              child: Container(
                  height: 2,
                  color: _currentStep > 1 ? kAccentGreen : kBorderSoft)),
          _buildStep(2, 'Importar', Icons.save),
        ],
      ),
    );
  }

  Widget _buildStep(int index, String label, IconData icon) {
    final isActive = index == _currentStep;
    final isCompleted = index < _currentStep;
    final color = isCompleted
        ? kAccentGreen
        : isActive
            ? kBrandPurple
            : kBorderSoft;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(20)),
          child: Icon(isCompleted ? Icons.check : icon,
              color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildContent() {
    if (_isProcessing) {
      return ImportProgressSection(
        progress: _progress,
        logs: _importLogs,
        onCancel: () {
          setState(() => _isProcessing = false);
          Navigator.of(context).pop();
        },
      );
    }

    switch (_currentStep) {
      case 0:
        return _buildFileStep();
      case 1:
        return _buildMappingStep();
      case 2:
        return _buildImportStep();
      default:
        return Container();
    }
  }

  Widget _buildFileStep() {
    return ImportFileSelector(
      selectedFile: _selectedFile,
      parseResult: _parseResult,
      onFileSelected: _handleFileSelected,
      onFileRemoved: () => setState(() {
        _selectedFile = null;
        _parseResult = null;
        _mappings.clear();
        _currentStep = 0;
      }),
    );
  }

  Widget _buildMappingStep() {
    if (_parseResult == null) return Container();

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ImportFieldMapper(
            sourceColumns: _parseResult!.headers,
            currentMappings: _mappings,
            onMappingsChanged: _handleMappingsChanged,
            onConfigurationChanged: _handleConfigurationChanged,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: ImportValidationSection(
            sampleData: _parseResult!.previewData,
            headers:
                _parseResult!.headers, // ✅ FIX CRÍTICO: Pasar headers reales
            mappings: _mappings,
            onValidationChanged: _handleValidationChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildImportStep() {
    if (_finalResult != null) {
      return ImportProgressSection(
        progress: _progress,
        finalResult: _finalResult,
        logs: _importLogs,
        onComplete: (result) => Navigator.of(context).pop(result),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Todo listo para importar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('${_parseResult?.totalRows ?? 0} filas serán procesadas'),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _startImport,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar Importación'),
            style: ElevatedButton.styleFrom(
                backgroundColor: kAccentGreen, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    if (_isProcessing || _finalResult != null) return Container();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('Atrás')),
          const Spacer(),
          OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed:
                _canProceed() ? () => setState(() => _currentStep++) : null,
            child: const Text('Siguiente'),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // 🔧 MÉTODOS HELPER
  // ========================================================================

  String _getStepDescription() {
    switch (_currentStep) {
      case 0:
        return 'Selecciona archivo CSV o Excel';
      case 1:
        return 'Mapea campos del archivo';
      case 2:
        return 'Inicia la importación';
      default:
        return '';
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _parseResult?.isSuccess ?? false;
      case 1:
        return _mappings
                .where((m) => m.isRequired && m.sourceColumn.isNotEmpty)
                .length ==
            TargetFields.requiredFields.length;
      default:
        return false;
    }
  }

  void _handleMappingsChanged(List<FieldMapping> mappings) {
    if (_mappings.length != mappings.length ||
        !_mappings.every((m) => mappings.any((nm) =>
            nm.sourceColumn == m.sourceColumn &&
            nm.targetField == m.targetField))) {
      if (mounted) {
        setState(() {
          _mappings = mappings;
        });

        // ✅ DEBUG: Verificar mappings actualizados
        debugPrint('🔧 FIX: Mappings actualizados en modal:');
        for (final mapping in _mappings) {
          debugPrint(
              '  ${mapping.targetField} -> "${mapping.sourceColumn}" (required: ${mapping.isRequired})');
        }
      }
    }
  }

  void _handleConfigurationChanged(MappingConfiguration config) {
    if (_mappingConfig == null ||
        _mappingConfig!.isComplete != config.isComplete ||
        _mappingConfig!.mappedColumns != config.mappedColumns) {
      if (mounted) {
        setState(() {
          _mappingConfig = config;
        });
      }
    }
  }

  void _handleValidationChanged(ValidationResult validation) {
    if (_validationResult == null ||
        _validationResult!.hasErrors != validation.hasErrors ||
        _validationResult!.validRows != validation.validRows) {
      if (mounted) {
        setState(() {
          _validationResult = validation;
        });

        // ✅ DEBUG: Resultado de validación
        debugPrint(
            '✅ FIX: Validación completada: ${validation.validRows} válidas, ${validation.errors.length} errores');
      }
    }
  }

  Future<void> _handleFileSelected(PlatformFile file) async {
    setState(() => _isProcessing = true);

    try {
      final fileInfo = ImportFileInfo(
        name: file.name,
        sizeBytes: file.size,
        format: FileParserService.detectFormatByExtension(file.name) ??
            ImportFormat.csv,
        bytes: file.bytes!,
        selectedAt: DateTime.now(),
      );

      final parseResult =
          await _parser.parseFile(fileInfo, ImportOptions.defaultCsv());

      if (mounted) {
        setState(() {
          _selectedFile = fileInfo;
          _parseResult = parseResult;
          _isProcessing = false;
        });

        // ✅ DEBUG: Verificar headers parseados
        if (parseResult.isSuccess) {
          debugPrint(
              '✅ FIX: Headers parseados correctamente: ${parseResult.headers}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: kErrorColor));
      }
    }
  }

  Future<void> _startImport() async {
    if (_selectedFile == null || _parseResult == null) return;

    setState(() {
      _isProcessing = true;
      _currentStep = 2;
    });

    try {
      final result = await _importService.importClients(
        _selectedFile!.bytes,
        _selectedFile!.name,
        ImportOptions.defaultCsv(),
        _mappings.where((m) => m.sourceColumn.isNotEmpty).toList(),
        onProgress: (progress) {
          if (mounted) {
            setState(() => _progress = progress);
          }
        },
        onStatusUpdate: (status) {
          if (mounted) {
            setState(() => _importLogs.add(status));
          }
        },
      );

      if (mounted) {
        setState(() {
          _finalResult = result;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _progress = ImportProgress(
            status: ImportStatus.failed,
            percentage: 0.0,
            processedRows: 0,
            totalRows: 0,
            currentOperation: 'Error: $e',
            elapsed: Duration.zero,
            recentErrors: [e.toString()],
          );
        });
      }
    }
  }
}
