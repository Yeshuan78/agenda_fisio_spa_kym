import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/contrato_model.dart';
import 'package:agenda_fisio_spa_kym/services/contrato_service.dart';
import 'package:agenda_fisio_spa_kym/screens/contratos/contrato_form.dart';

class ContratosScreen extends StatefulWidget {
  const ContratosScreen({super.key});

  @override
  State<ContratosScreen> createState() => _ContratosScreenState();
}

class _ContratosScreenState extends State<ContratosScreen> {
  final ContratoService _contratoService = ContratoService();
  late Future<List<ContratoModel>> _contratosFuture;

  @override
  void initState() {
    super.initState();
    _contratosFuture = _contratoService.getContratos();
  }

  Future<void> _refreshContratos() async {
    setState(() {
      _contratosFuture = _contratoService.getContratos();
    });
  }

  void _abrirFormulario({ContratoModel? contrato}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContratoForm(contratoExistente: contrato),
      ),
    );
    _refreshContratos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contratos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshContratos,
          ),
          IconButton(
            icon: const Icon(Icons.note_add),
            onPressed: () => _abrirFormulario(),
          ),
        ],
      ),
      body: FutureBuilder<List<ContratoModel>>(
        future: _contratosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final contratos = snapshot.data ?? [];

          if (contratos.isEmpty) {
            return const Center(child: Text('No hay contratos registrados.'));
          }

          return ListView.builder(
            itemCount: contratos.length,
            itemBuilder: (context, index) {
              final contrato = contratos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Contrato ${contrato.id.substring(0, 6)}'),
                  subtitle: Text(
                      'Monto: \$${contrato.montoTotal.toStringAsFixed(2)}'),
                  trailing: Text(contrato.estado),
                  onTap: () => _abrirFormulario(contrato: contrato),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
