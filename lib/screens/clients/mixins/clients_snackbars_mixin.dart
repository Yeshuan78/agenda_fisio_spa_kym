// [clients_snackbars_mixin.dart] - MIXIN DE SNACKBARS
// 📁 Ubicación: /lib/screens/clients/mixins/clients_snackbars_mixin.dart
// 🎯 OBJETIVO: Extraer todas las notificaciones del screen principal

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/utils/client_constants.dart';

/// 🔔 MIXIN DE SNACKBARS - EXTRAÍDO DEL SCREEN PRINCIPAL
mixin ClientsSnackbarsMixin<T extends StatefulWidget> on State<T> {
  
  // ====================================================================
  // ✅ SNACKBARS DE ÉXITO (COPIADO EXACTO)
  // ====================================================================

  void showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(
              seconds: ClientConstants.SUCCESS_SNACKBAR_DURATION_SECONDS),
        ),
      );
    }
  }

  // ====================================================================
  // ❌ SNACKBARS DE ERROR (COPIADO EXACTO)
  // ====================================================================

  void showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(
              seconds: ClientConstants.ERROR_SNACKBAR_DURATION_SECONDS),
        ),
      );
    }
  }

  // ====================================================================
  // ℹ️ SNACKBARS DE INFORMACIÓN (COPIADO EXACTO)
  // ====================================================================

  void showInfoSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: kBrandPurple,
          duration: const Duration(
              seconds: ClientConstants.SNACKBAR_DURATION_SECONDS),
        ),
      );
    }
  }

  // ====================================================================
  // ⚠️ SNACKBARS DE ADVERTENCIA (COPIADO EXACTO)
  // ====================================================================

  void showWarningSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(
              seconds: ClientConstants.SNACKBAR_DURATION_SECONDS),
        ),
      );
    }
  }

  // ====================================================================
  // 💰 SNACKBARS ESPECÍFICOS DE COSTOS (COPIADO EXACTO)
  // ====================================================================

  void showCostLimitSnackBar() {
    showErrorSnackBar('Límite de costos alcanzado. Intente más tarde.');
  }

  void showBulkOperationLimitSnackBar(int maxOperations) {
    showWarningSnackBar(
        'Solo puede realizar operaciones en lotes de máximo $maxOperations elementos.');
  }

  void showExportLimitSnackBar(int maxExports) {
    showWarningSnackBar(
        'Solo puede exportar hasta $maxExports registros a la vez.');
  }

  // ====================================================================
  // 🎯 SNACKBARS ESPECÍFICOS DE ACCIONES (COPIADO EXACTO)
  // ====================================================================

  void showClientCreatedSnackBar(String clientName) {
    showSuccessSnackBar('Cliente $clientName creado exitosamente');
  }

  void showClientUpdatedSnackBar(String clientName) {
    showSuccessSnackBar('Cliente $clientName actualizado exitosamente');
  }

  void showClientDeletedSnackBar(String clientName) {
    showSuccessSnackBar('Cliente $clientName eliminado exitosamente');
  }

  void showBulkDeleteSnackBar(int count) {
    showSuccessSnackBar('$count clientes eliminados exitosamente');
  }

  void showBulkTagsAddedSnackBar(int count) {
    showSuccessSnackBar('Etiquetas agregadas a $count clientes');
  }

  void showDataRefreshedSnackBar() {
    showSuccessSnackBar('Datos actualizados exitosamente');
  }

  void showAnalyticsRefreshedSnackBar() {
    showSuccessSnackBar('Analytics actualizados');
  }

  // ====================================================================
  // 🚧 SNACKBARS DE DESARROLLO (COPIADO EXACTO)
  // ====================================================================

  void showDevelopmentFeatureSnackBar(String featureName) {
    showInfoSnackBar('$featureName - Función en desarrollo');
  }

  void showExportDevelopmentSnackBar(int count) {
    showDevelopmentFeatureSnackBar('Exportar $count clientes');
  }

  void showImportDevelopmentSnackBar() {
    showDevelopmentFeatureSnackBar('Importación de clientes');
  }

  void showPreviewDevelopmentSnackBar(String clientName) {
    showDevelopmentFeatureSnackBar('Preview de $clientName');
  }
}