// 📁 screens/campanas/campanas_screen.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/campana_model.dart';
import 'package:agenda_fisio_spa_kym/services/campana_service.dart';
import 'campana_form.dart';

class CampanasScreen extends StatefulWidget {
  const CampanasScreen({super.key});

  @override
  State<CampanasScreen> createState() => _CampanasScreenState();
}

class _CampanasScreenState extends State<CampanasScreen> {
  final CampanaService _campanaService = CampanaService();
  late Future<List<CampanaModel>> _campanasFuture;

  @override
  void initState() {
    super.initState();
    _campanasFuture = _campanaService.getCampanas();
  }

  Future<void> _refresh() async {
    setState(() {
      _campanasFuture = _campanaService.getCampanas();
    });
  }

  void _abrirFormulario({CampanaModel? campana}) async {
    await showDialog(
      context: context,
      builder: (_) => CampanaForm(campanaExistente: campana),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campañas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _abrirFormulario(),
          ),
        ],
      ),
      body: FutureBuilder<List<CampanaModel>>(
        future: _campanasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final campanas = snapshot.data ?? [];
          if (campanas.isEmpty) {
            return const Center(child: Text('No hay campanas registradas.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: campanas.length,
              itemBuilder: (context, index) {
                final c = campanas[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(c.titulo),
                    subtitle: Text('Tipo: ${c.tipo} • Estado: ${c.estado}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _abrirFormulario(campana: c),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
