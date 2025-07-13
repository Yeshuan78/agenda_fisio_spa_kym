// [clients_dialogs_mixin.dart] - MIXIN DE DIÁLOGOS Y MODALES
// 📁 Ubicación: /lib/screens/clients/mixins/clients_dialogs_mixin.dart
// 🎯 OBJETIVO: Extraer todos los diálogos y modales del screen principal

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/services/client_service.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/wizard/client_wizard_modal.dart';
import 'package:agenda_fisio_spa_kym/services/user_preferences_service.dart';

/// 💬 MIXIN DE DIÁLOGOS - EXTRAÍDO DEL SCREEN PRINCIPAL
mixin ClientsDialogsMixin<T extends StatefulWidget> on State<T> {
  
  // ====================================================================
  // 🆕 GESTIÓN DE CLIENTES (COPIADO EXACTO)
  // ====================================================================

  Future<void> createNewClient(VoidCallback onSuccess) async {
    HapticFeedback.mediumImpact();

    // Usar el nuevo modal wizard
    final result = await showClientWizardModal(
      context,
      onClientSaved: () {
        debugPrint('✅ Cliente guardado desde wizard');
      },
      onCancelled: () {
        debugPrint('❌ Wizard cancelado');
      },
    );

    // Si el resultado es exitoso, actualizar la lista
    if (result == true) {
      onSuccess();
    }
  }

  Future<void> editClient(ClientModel client, VoidCallback onSuccess) async {
    // Usar el nuevo modal wizard para edición
    final result = await showClientWizardModal(
      context,
      existingClient: client,
      onClientSaved: () {
        debugPrint('✅ Cliente actualizado desde wizard');
      },
      onCancelled: () {
        debugPrint('❌ Edición cancelada');
      },
    );

    if (result == true) {
      onSuccess();
    }
  }

  Future<void> deleteClient(
    String clientId,
    List<ClientModel> allClients,
    ClientService clientService,
    VoidCallback onSuccess,
    Function(String) onError,
  ) async {
    final client = allClients.firstWhere((c) => c.clientId == clientId);

    final confirmed = await showConfirmDialog(
      'Eliminar cliente',
      '¿Está seguro de que desea eliminar a ${client.fullName}? Esta acción no se puede deshacer.',
    );

    if (!confirmed) return;

    try {
      await clientService.deleteClient(clientId);
      onSuccess();
      _showSuccessMessage('Cliente eliminado exitosamente');
    } catch (e) {
      onError('Error eliminando cliente: $e');
    }
  }

  // ====================================================================
  // 👁️ PREVIEW Y VISUALIZACIÓN (COPIADO EXACTO)
  // ====================================================================

  void showClientPreview(ClientModel client, String currentViewMode) {
    // Registrar evento de preview para analytics
    UserPreferencesService.instance.recordUsageEvent('client_preview', {
      'clientId': client.clientId,
      'viewMode': currentViewMode,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Vista previa modal del cliente
    _showInfoMessage('Preview de ${client.fullName} - Función en desarrollo');
  }

  // ====================================================================
  // ✅ DIÁLOGOS DE CONFIRMACIÓN (COPIADO EXACTO)
  // ====================================================================

  Future<bool> showConfirmDialog(String title, String message) async {
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ====================================================================
  // 📊 DIÁLOGOS DE INFORMACIÓN (COPIADO EXACTO)
  // ====================================================================

  void showErrorDialog(String title, String message) {
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

  void showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // ⚠️ DIÁLOGOS ESPECIALIZADOS (COPIADO EXACTO)
  // ====================================================================

  void showCostLimitDialog() {
    showErrorDialog(
      'Límite de costos alcanzado',
      'Ha alcanzado el límite diario de consultas. Intente más tarde o aumente su plan.',
    );
  }

  void showBulkOperationLimitDialog(int maxOperations) {
    showErrorDialog(
      'Límite de operaciones masivas',
      'Solo puede realizar operaciones en lotes de máximo $maxOperations elementos.',
    );
  }

  void showExportLimitDialog(int maxExports) {
    showErrorDialog(
      'Límite de exportación',
      'Solo puede exportar hasta $maxExports registros a la vez.',
    );
  }

  // ====================================================================
  // 🎯 DIÁLOGOS DE SELECCIÓN (COPIADO EXACTO)
  // ====================================================================

  Future<String?> showSortOptionsDialog(List<String> sortOptions, String currentOption) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ordenar por'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sortOptions.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: currentOption,
              onChanged: (value) => Navigator.of(context).pop(value),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // 🔧 HELPERS DE MENSAJES (COPIADO EXACTO)
  // ====================================================================

  void _showSuccessMessage(String message) {
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
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
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
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showInfoMessage(String message) {
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
          backgroundColor: const Color(0xFF9920A7), // kBrandPurple
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}