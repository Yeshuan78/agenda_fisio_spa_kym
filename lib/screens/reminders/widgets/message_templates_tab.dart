// lib/widgets/reminders/message_templates_tab.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

import 'package:agenda_fisio_spa_kym/screens/reminders/widgets/firestore_message_templates_editor.dart';
import 'package:agenda_fisio_spa_kym/screens/reminders/widgets/firestore_email_templates_editor.dart';
import 'package:agenda_fisio_spa_kym/screens/reminders/widgets/firestore_professional_templates_editor.dart';
import 'package:agenda_fisio_spa_kym/widgets/dev_tools/regenerar_plantillas_base_button.dart';
// NUEVO BOTÓN

class MessageTemplatesTab extends StatefulWidget {
  const MessageTemplatesTab({super.key});

  @override
  State<MessageTemplatesTab> createState() => _MessageTemplatesTabState();
}

class _MessageTemplatesTabState extends State<MessageTemplatesTab>
    with TickerProviderStateMixin {
  late TabController _tabUsuarioController;
  late TabController _tabCanalController;

  bool modoDevActivo = true;

  @override
  void initState() {
    super.initState();
    _tabUsuarioController = TabController(length: 4, vsync: this);
    _tabCanalController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabUsuarioController.dispose();
    _tabCanalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔧 Switch desarrollador
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.developer_mode, size: 18, color: kBrandPurple),
              const SizedBox(width: 8),
              const Text(
                'Modo desarrollador',
                style: TextStyle(fontSize: 14),
              ),
              const Spacer(),
              Switch(
                value: modoDevActivo,
                activeColor: kBrandPurple,
                onChanged: (v) {
                  setState(() {
                    modoDevActivo = v;
                  });
                },
              ),
            ],
          ),
        ),

        // ✅ Botón único para regenerar todas las plantillas base
        if (modoDevActivo)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: RegenerarPlantillasBaseButton(),
          ),

        const SizedBox(height: 8),

        // Tabs de canal
        TabBar(
          controller: _tabCanalController,
          labelColor: kBrandPurple,
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(text: 'WhatsApp'),
            Tab(text: 'Correo electrónico'),
          ],
        ),

        // Tab de contenido por canal
        Expanded(
          child: TabBarView(
            controller: _tabCanalController,
            children: [
              _buildTabsPorTipoUsuario(canal: 'whatsapp'),
              _buildTabsPorTipoUsuario(canal: 'email'),
            ],
          ),
        ),
      ],
    );
  }

  // Tabs por tipo de usuario para cada canal
  Widget _buildTabsPorTipoUsuario({required String canal}) {
    return Column(
      children: [
        TabBar(
          controller: _tabUsuarioController,
          labelColor: kBrandPurple,
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(text: 'Cliente'),
            Tab(text: 'Profesional'),
            Tab(text: 'Admin'),
            Tab(text: 'Corporativo'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabUsuarioController,
            children: [
              canal == 'whatsapp'
                  ? const FirestoreMessageTemplatesEditor(
                      tipoUsuario: 'cliente')
                  : const FirestoreEmailTemplatesEditor(tipoUsuario: 'cliente'),
              canal == 'whatsapp'
                  ? const FirestoreProfessionalTemplatesEditor()
                  : const FirestoreEmailTemplatesEditor(
                      tipoUsuario: 'profesional'),
              canal == 'whatsapp'
                  ? const FirestoreMessageTemplatesEditor(tipoUsuario: 'admin')
                  : const FirestoreEmailTemplatesEditor(tipoUsuario: 'admin'),
              canal == 'whatsapp'
                  ? const FirestoreMessageTemplatesEditor(
                      tipoUsuario: 'corporativo')
                  : const FirestoreEmailTemplatesEditor(
                      tipoUsuario: 'corporativo'),
            ],
          ),
        ),
      ],
    );
  }
}
