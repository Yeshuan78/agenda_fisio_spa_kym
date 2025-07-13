// [import_file_selector.dart] - SELECTOR COMPACTO CON DRAG & DROP SIMPLIFICADO
// 📁 Ubicación: /lib/widgets/clients/import/import_file_selector.dart
// 🎯 OBJETIVO: Selector compacto que funciona sin errores de compilación

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'import_models.dart';
import 'file_parser_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// 📁 SELECTOR DE ARCHIVOS ENTERPRISE COMPACTO CON DRAG & DROP
class ImportFileSelector extends StatefulWidget {
  final ImportFileInfo? selectedFile;
  final ParseResult? parseResult;
  final Function(PlatformFile) onFileSelected;
  final VoidCallback onFileRemoved;

  const ImportFileSelector({
    super.key,
    this.selectedFile,
    this.parseResult,
    required this.onFileSelected,
    required this.onFileRemoved,
  });

  @override
  State<ImportFileSelector> createState() => _ImportFileSelectorState();
}

class _ImportFileSelectorState extends State<ImportFileSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isDragOver = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Solo configurar drag & drop en web usando DragTarget de Flutter
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setupFlutterDragAndDrop();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: widget.selectedFile != null
          ? _buildCompactFileSelected()
          : _buildCompactFileSelector(),
    );
  }

  // ========================================================================
  // 📁 SELECTOR CON DRAG & DROP USANDO FLUTTER NATIVO
  // ========================================================================

  /// 📁 ZONA DE SELECCIÓN CON DRAG TARGET
  Widget _buildCompactFileSelector() {
    return Column(
      children: [
        // 🎯 ÁREA DE DROP CON DRAGTARGET DE FLUTTER
        Expanded(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: DragTarget<String>(
                  onWillAccept: (data) {
                    setState(() => _isDragOver = true);
                    return true;
                  },
                  onAccept: (data) {
                    setState(() => _isDragOver = false);
                    // Para archivos reales, usar FilePicker
                    _selectFile();
                  },
                  onLeave: (data) {
                    setState(() => _isDragOver = false);
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 140),
                      decoration: BoxDecoration(
                        color: _isDragOver || candidateData.isNotEmpty
                            ? kBrandPurple.withValues(alpha: 0.12)
                            : Colors.grey.shade50,
                        border: Border.all(
                          color: _isDragOver || candidateData.isNotEmpty
                              ? kBrandPurple
                              : kBorderSoft,
                          width:
                              _isDragOver || candidateData.isNotEmpty ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: _selectFile,
                        borderRadius: BorderRadius.circular(12),
                        child: _buildCompactDropContent(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),
        _buildCompactHelpInfo(),
      ],
    );
  }

  /// 🎨 CONTENIDO DEL ÁREA DE DROP
  Widget _buildCompactDropContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ÍCONO PRINCIPAL CON ANIMACIÓN
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _isDragOver
                  ? kBrandPurple.withValues(alpha: 0.2)
                  : kBrandPurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              boxShadow: _isDragOver
                  ? [
                      BoxShadow(
                        color: kBrandPurple.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Icon(
              _isDragOver ? Icons.cloud_done : Icons.cloud_upload_outlined,
              size: 24,
              color: _isDragOver ? kBrandPurple : kTextSecondary,
            ),
          ),

          const SizedBox(height: 12),

          // TEXTO DINÁMICO
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _isDragOver ? kBrandPurple : Colors.black87,
              fontFamily: kFontFamily,
            ),
            child: Text(
              _isDragOver
                  ? '¡Seleccionar archivo!'
                  : kIsWeb
                      ? 'Haz clic para seleccionar archivo'
                      : 'Selecciona un archivo',
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'CSV, Excel (.xlsx) • Máx: ${ImportLimits.maxFileSizeMb}MB',
            style: TextStyle(
              fontSize: 12,
              color: _isDragOver ? kBrandPurple : kTextSecondary,
              fontFamily: kFontFamily,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // BOTÓN PRINCIPAL
          SizedBox(
            height: 36,
            child: ElevatedButton.icon(
              onPressed: _selectFile,
              icon: const Icon(Icons.folder_open, size: 16),
              label: const Text(
                'Explorar Archivos',
                style: TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isDragOver ? kAccentGreen : kBrandPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: _isDragOver ? 4 : 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ℹ️ INFORMACIÓN DE AYUDA COMPACTA
  Widget _buildCompactHelpInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kAccentBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kAccentBlue.withValues(alpha: 0.15)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: kAccentBlue, size: 14),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'Primera fila: nombres de columnas • Campos obligatorios: Nombre y Email',
              style: TextStyle(
                fontSize: 11,
                color: kAccentBlue,
                fontFamily: kFontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // 🌐 CONFIGURACIÓN SIMPLIFICADA
  // ========================================================================

  /// 🌐 CONFIGURAR DRAG & DROP USANDO FLUTTER
  void _setupFlutterDragAndDrop() {
    // Flutter DragTarget ya maneja el drag & drop básico
    // Para archivos reales del OS, FilePicker es la mejor opción
    debugPrint('✅ Drag Target configurado (FilePicker para archivos reales)');
  }

  /// 📁 SELECCIONAR ARCHIVO
  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // VALIDACIONES
        if (file.size > ImportLimits.maxFileSizeBytes) {
          _showError(
              'Archivo demasiado grande. Máximo ${ImportLimits.maxFileSizeMb}MB');
          return;
        }

        if (file.bytes == null) {
          _showError('No se pudo leer el archivo seleccionado');
          return;
        }

        final format = FileParserService.detectFormatByExtension(file.name);
        if (format == null) {
          _showError('Formato no soportado. Use CSV o Excel (.xlsx)');
          return;
        }

        widget.onFileSelected(file);

        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      }
    } catch (e) {
      _showError('Error seleccionando archivo: $e');
    }
  }

  // ========================================================================
  // 📄 ARCHIVO SELECCIONADO (COMPACTO)
  // ========================================================================

  Widget _buildCompactFileSelected() {
    return Column(
      children: [
        _buildCompactFileInfo(),
        const SizedBox(height: 8),
        Expanded(
          child: widget.parseResult != null
              ? _buildCompactDataContent()
              : _buildCompactParsingContent(),
        ),
      ],
    );
  }

  Widget _buildCompactFileInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kAccentGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kAccentGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kAccentGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(_getFileIcon(), color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedFile!.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: kFontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  '${widget.selectedFile!.sizeFormatted} • ${widget.selectedFile!.format.displayName}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: kTextSecondary,
                    fontFamily: kFontFamily,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onFileRemoved,
            icon: const Icon(Icons.close, size: 16),
            color: kTextSecondary,
            tooltip: 'Remover archivo',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDataContent() {
    final result = widget.parseResult!;
    if (!result.isSuccess) return _buildCompactParsingError();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUltraCompactStats(result),
        const SizedBox(height: 8),
        Expanded(child: _buildCompactScrollablePreview(result)),
      ],
    );
  }

  Widget _buildUltraCompactStats(ParseResult result) {
    return Row(
      children: [
        Expanded(
            child: _buildUltraMiniStatCard(
                '${result.totalRows}', 'Filas', Icons.table_rows, kAccentBlue)),
        const SizedBox(width: 6),
        Expanded(
            child: _buildUltraMiniStatCard('${result.totalColumns}', 'Columnas',
                Icons.view_column, kBrandPurple)),
        const SizedBox(width: 6),
        Expanded(
            child: _buildUltraMiniStatCard(
                'OK', 'Estado', Icons.check_circle, kAccentGreen)),
      ],
    );
  }

  Widget _buildUltraMiniStatCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: kFontFamily)),
          Text(label,
              style:
                  TextStyle(fontSize: 8, color: color, fontFamily: kFontFamily),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCompactScrollablePreview(ParseResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.preview, color: kBrandPurple, size: 14),
            SizedBox(width: 4),
            Text('Vista Previa',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kBrandPurple,
                    fontFamily: kFontFamily)),
          ],
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: kBorderSoft),
              borderRadius: BorderRadius.circular(6),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateColor.resolveWith(
                      (_) => kBrandPurple.withValues(alpha: 0.06)),
                  border: TableBorder.all(color: kBorderSoft, width: 0.5),
                  columnSpacing: 8,
                  dataRowMinHeight: 24,
                  dataRowMaxHeight: 28,
                  headingTextStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: kBrandPurple,
                      fontFamily: kFontFamily),
                  dataTextStyle:
                      const TextStyle(fontSize: 9, fontFamily: kFontFamily),
                  columns: result.headers
                      .map((header) => DataColumn(
                            label: Container(
                              constraints: const BoxConstraints(maxWidth: 80),
                              child: Text(
                                  header.length > 10
                                      ? '${header.substring(0, 10)}...'
                                      : header,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ))
                      .toList(),
                  rows: result.previewData
                      .take(8)
                      .map((row) => DataRow(
                            cells: row
                                .map((cell) => DataCell(
                                      Container(
                                        constraints:
                                            const BoxConstraints(maxWidth: 80),
                                        child: Text(
                                          cell.length > 12
                                              ? '${cell.substring(0, 12)}...'
                                              : cell.isEmpty
                                                  ? '(vacío)'
                                                  : cell,
                                          style: TextStyle(
                                            color: cell.isEmpty
                                                ? kTextMuted
                                                : Colors.black87,
                                            fontStyle: cell.isEmpty
                                                ? FontStyle.italic
                                                : FontStyle.normal,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactParsingContent() {
    return const SizedBox(
      height: 80,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kBrandPurple),
                    strokeWidth: 2)),
            SizedBox(height: 8),
            Text('Procesando archivo...',
                style: TextStyle(
                    fontSize: 12,
                    color: kTextSecondary,
                    fontFamily: kFontFamily)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactParsingError() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kErrorColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kErrorColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: kErrorColor, size: 24),
          const SizedBox(height: 8),
          const Text('Error al procesar archivo',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kErrorColor,
                  fontFamily: kFontFamily)),
          const SizedBox(height: 4),
          Text(
            widget.parseResult?.errorMessage ?? 'Error desconocido',
            style: const TextStyle(
                fontSize: 11, color: kErrorColor, fontFamily: kFontFamily),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: OutlinedButton.icon(
              onPressed: widget.onFileRemoved,
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('Seleccionar otro',
                  style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: kErrorColor,
                side: const BorderSide(color: kErrorColor),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(message, style: const TextStyle(fontSize: 13))),
            ],
          ),
          backgroundColor: kErrorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  IconData _getFileIcon() {
    if (widget.selectedFile == null) return Icons.insert_drive_file;
    switch (widget.selectedFile!.format) {
      case ImportFormat.csv:
        return Icons.table_chart;
      case ImportFormat.excel:
        return Icons.grid_on;
    }
  }
}
