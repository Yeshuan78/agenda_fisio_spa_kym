// [file_download_helper.dart] - HELPER DE DESCARGA MULTIPLATAFORMA - VERSIÓN FINAL
// 📁 Ubicación: /lib/widgets/clients/export/file_download_helper.dart
// 🎯 OBJETIVO: Manejo unificado de descarga de archivos web/móvil SIN ERRORES

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

// ✅ IMPORTS CONDICIONALES CORRECTOS
import 'dart:html' as html show AnchorElement, Blob, Url, document;
import 'dart:io' as io;

/// 📁 HELPER MULTIPLATAFORMA PARA DESCARGA DE ARCHIVOS - FINAL
class FileDownloadHelper {
  /// 🚀 MÉTODO PRINCIPAL DE DESCARGA
  Future<void> downloadFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    try {
      if (kIsWeb) {
        await _downloadFileWeb(fileName, bytes, mimeType);
      } else {
        await _downloadFileMobile(fileName, bytes, mimeType);
      }

      debugPrint('✅ Archivo descargado exitosamente: $fileName');
    } catch (e) {
      debugPrint('❌ Error descargando archivo: $e');
      rethrow;
    }
  }

  /// 🌐 DESCARGA PARA WEB
  Future<void> _downloadFileWeb(
      String fileName, Uint8List bytes, String mimeType) async {
    if (!kIsWeb) {
      throw UnsupportedError('Este método solo funciona en web');
    }

    try {
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none';

      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);

      html.Url.revokeObjectUrl(url);

      debugPrint('🌐 Descarga web completada: $fileName');
    } catch (e) {
      debugPrint('❌ Error en descarga web: $e');
      throw Exception('Error descargando archivo en web: $e');
    }
  }

  /// 📱 DESCARGA PARA MÓVIL - SIN PERMISSION_HANDLER
  Future<void> _downloadFileMobile(
      String fileName, Uint8List bytes, String mimeType) async {
    if (kIsWeb) {
      throw UnsupportedError('Este método solo funciona en móvil');
    }

    try {
      // ✅ SIN VERIFICACIÓN DE PERMISOS - USAR DIRECTORIOS SEGUROS
      final directory = await _getDownloadDirectory();
      final file = io.File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      debugPrint('📱 Archivo guardado en: ${file.path}');
    } catch (e) {
      debugPrint('❌ Error en descarga móvil: $e');
      throw Exception('Error guardando archivo en móvil: $e');
    }
  }

  /// 📁 OBTENER DIRECTORIO DE DESCARGA - SIMPLIFICADO SIN PERMISOS
  Future<io.Directory> _getDownloadDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('No aplica para web');
    }

    try {
      // ✅ ESTRATEGIA SIMPLIFICADA - SOLO DIRECTORIOS SEGUROS
      if (io.Platform.isAndroid) {
        // Usar directorio externo de la app (no requiere permisos)
        try {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            final downloadDir = io.Directory('${externalDir.path}/Exports');
            if (!await downloadDir.exists()) {
              await downloadDir.create(recursive: true);
            }
            return downloadDir;
          }
        } catch (e) {
          debugPrint('⚠️ No se pudo crear directorio externo: $e');
        }
      }

      // ✅ FALLBACK UNIVERSAL - SIEMPRE FUNCIONA
      final appDocDir = await getApplicationDocumentsDirectory();
      final downloadDir = io.Directory('${appDocDir.path}/Exports');

      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      return downloadDir;
    } catch (e) {
      debugPrint('❌ Error obteniendo directorio: $e');
      // ✅ ÚLTIMO FALLBACK
      final appDocDir = await getApplicationDocumentsDirectory();
      return appDocDir;
    }
  }

  /// 📊 OBTENER INFORMACIÓN DE DESCARGA
  Future<Map<String, dynamic>> getDownloadInfo() async {
    if (kIsWeb) {
      return {
        'platform': 'web',
        'downloadMethod': 'browser_download',
        'location': 'Downloads del navegador',
        'supportsDirectSave': true,
      };
    }

    try {
      final directory = await _getDownloadDirectory();
      return {
        'platform': io.Platform.operatingSystem,
        'downloadMethod': 'file_system',
        'location': directory.path,
        'supportsDirectSave': true,
      };
    } catch (e) {
      return {
        'platform': 'unknown',
        'downloadMethod': 'fallback',
        'location': 'Error obteniendo directorio',
        'supportsDirectSave': false,
        'error': e.toString(),
      };
    }
  }

  /// 🧹 LIMPIAR ARCHIVOS TEMPORALES
  Future<void> cleanupTempFiles() async {
    if (kIsWeb) return;

    try {
      final directory = await _getDownloadDirectory();

      final files = await directory.list().toList();
      final tempFiles = files.whereType<io.File>().where((file) {
        try {
          final name = file.path.split(io.Platform.pathSeparator).last;
          final stats = file.statSync();
          final age = DateTime.now().difference(stats.modified);

          return age.inDays > 7 &&
              (name.startsWith('clientes_') || name.contains('export_'));
        } catch (e) {
          return false;
        }
      });

      for (final file in tempFiles) {
        try {
          await file.delete();
          debugPrint('🧹 Archivo temporal eliminado: ${file.path}');
        } catch (e) {
          debugPrint('⚠️ No se pudo eliminar: ${file.path} - $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error limpiando archivos temporales: $e');
    }
  }

  /// 🔍 VERIFICAR SI ARCHIVO EXISTE
  Future<bool> fileExists(String fileName) async {
    if (kIsWeb) return false;

    try {
      final directory = await _getDownloadDirectory();
      final file = io.File('${directory.path}/$fileName');
      return await file.exists();
    } catch (e) {
      debugPrint('⚠️ Error verificando archivo: $e');
      return false;
    }
  }

  /// 📏 OBTENER TAMAÑO DE ARCHIVO
  Future<int> getFileSize(String fileName) async {
    if (kIsWeb) return 0;

    try {
      final directory = await _getDownloadDirectory();
      final file = io.File('${directory.path}/$fileName');

      if (await file.exists()) {
        final stat = await file.stat();
        return stat.size;
      }
      return 0;
    } catch (e) {
      debugPrint('⚠️ Error obteniendo tamaño: $e');
      return 0;
    }
  }

  /// 📋 LISTAR ARCHIVOS EXPORTADOS
  Future<List<Map<String, dynamic>>> listExportedFiles() async {
    if (kIsWeb) return [];

    try {
      final directory = await _getDownloadDirectory();
      final files = await directory.list().toList();

      final exportFiles = <Map<String, dynamic>>[];

      for (final entity in files) {
        if (entity is io.File) {
          try {
            final name = entity.path.split(io.Platform.pathSeparator).last;
            if (name.startsWith('clientes_') || name.contains('export_')) {
              final stat = await entity.stat();
              exportFiles.add({
                'name': name,
                'path': entity.path,
                'size': stat.size,
                'modified': stat.modified,
                'formattedSize': _formatBytes(stat.size),
              });
            }
          } catch (e) {
            debugPrint('⚠️ Error procesando archivo: $e');
          }
        }
      }

      // Ordenar por fecha (más reciente primero)
      exportFiles.sort((a, b) =>
          (b['modified'] as DateTime).compareTo(a['modified'] as DateTime));

      return exportFiles;
    } catch (e) {
      debugPrint('⚠️ Error listando archivos: $e');
      return [];
    }
  }

  /// 📊 FORMATEAR BYTES
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// 🗂️ ABRIR DIRECTORIO DE EXPORTACIONES (MÓVIL)
  Future<String> getExportsDirectoryPath() async {
    if (kIsWeb) return 'Downloads del navegador';

    try {
      final directory = await _getDownloadDirectory();
      return directory.path;
    } catch (e) {
      return 'Error obteniendo directorio';
    }
  }
}
