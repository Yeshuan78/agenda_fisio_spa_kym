import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/empresa_model.dart';
import 'package:agenda_fisio_spa_kym/services/empresa_service.dart';
import 'package:agenda_fisio_spa_kym/widgets/empresas/empresa_card.dart';
import 'package:agenda_fisio_spa_kym/screens/empresas/empresa_form.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class EmpresasScreen extends StatefulWidget {
  const EmpresasScreen({super.key});

  @override
  State<EmpresasScreen> createState() => _EmpresasScreenState();
}

class _EmpresasScreenState extends State<EmpresasScreen> {
  final _empresaService = EmpresaService();
  List<EmpresaModel> _empresas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarEmpresas();
  }

  Future<void> _cargarEmpresas() async {
    final empresas = await _empresaService.getEmpresas();
    if (mounted) {
      setState(() {
        _empresas = empresas;
        _loading = false;
      });
    }
  }

  Future<void> _abrirFormulario({EmpresaModel? empresa}) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (_) => EmpresaForm(
        empresa: empresa,
        onSaved: () => _cargarEmpresas(),
      ),
    );

    if (resultado == true) {
      _cargarEmpresas();
    }
  }

  Future<void> _eliminarEmpresa(String empresaId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar empresa?'),
        content:
            const Text('Esta acción no se puede deshacer. ¿Deseas continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _empresaService.deleteEmpresa(empresaId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Empresa eliminada')),
        );
        _cargarEmpresas();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Container(
                  width: 800,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Empresas registradas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kBrandPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : _empresas.isEmpty
                                ? const Center(
                                    child: Text('No hay empresas registradas'),
                                  )
                                : ListView.builder(
                                    itemCount: _empresas.length,
                                    itemBuilder: (context, index) {
                                      final empresa = _empresas[index];
                                      return EmpresaCard(
                                        empresa: empresa,
                                        onEditar: () =>
                                            _abrirFormulario(empresa: empresa),
                                        onEliminar: () =>
                                            _eliminarEmpresa(empresa.empresaId),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            onPressed: () => _abrirFormulario(),
            icon: const Icon(Icons.add_business),
            label: const Text('Nueva empresa'),
            backgroundColor: kBrandPurple,
          ),
        ),
      ],
    );
  }
}
