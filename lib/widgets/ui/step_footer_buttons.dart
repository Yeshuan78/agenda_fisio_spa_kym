import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class StepFooterButtons extends StatelessWidget {
  final bool mostrarAtras;
  final bool mostrarSiguiente;
  final bool mostrarGuardar;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onGuardar;
  final bool isSaving;

  const StepFooterButtons({
    super.key,
    this.mostrarAtras = false,
    this.mostrarSiguiente = false,
    this.mostrarGuardar = false,
    this.onBack,
    this.onNext,
    this.onGuardar,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.end, // ✅ Botones alineados a la derecha
        children: [
          if (mostrarAtras)
            TextButton(
              onPressed: onBack,
              style: TextButton.styleFrom(
                foregroundColor: kBrandPurple,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Atrás'),
            ),
          const SizedBox(width: 12),
          if (mostrarSiguiente)
            ElevatedButton(
              onPressed: onNext,
              child: const Text('Siguiente'),
            ),
          if (mostrarGuardar)
            ElevatedButton.icon(
              onPressed: isSaving ? null : onGuardar,
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(isSaving ? 'Guardando...' : 'Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPurple,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
