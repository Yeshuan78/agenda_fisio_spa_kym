import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WhatsAppSenderWidget extends StatefulWidget {
  final String? defaultPhone;
  final String? defaultTemplate;
  final String? defaultLangCode;

  const WhatsAppSenderWidget({
    super.key,
    this.defaultPhone,
    this.defaultTemplate,
    this.defaultLangCode,
  });

  @override
  State<WhatsAppSenderWidget> createState() => _WhatsAppSenderWidgetState();
}

class _WhatsAppSenderWidgetState extends State<WhatsAppSenderWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneCtrl;
  late TextEditingController _templateCtrl;
  late TextEditingController _langCtrl;

  bool _isLoading = false;

  // ✅ Servicio interno
  final String _accessToken = 'AQUÍ_TU_TOKEN_DE_ACCESO';
  final String _businessPhoneId = 'TU_PHONE_ID';

  Future<bool> _sendTemplateMessage({
    required String toPhone,
    required String templateName,
    required String langCode,
  }) async {
    final url = Uri.parse(
      'https://graph.facebook.com/v19.0/$_businessPhoneId/messages',
    );

    final headers = {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      "messaging_product": "whatsapp",
      "to": toPhone,
      "type": "template",
      "template": {
        "name": templateName,
        "language": {"code": langCode}
      }
    });

    final response = await http.post(url, headers: headers, body: body);
    return response.statusCode == 200;
  }

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.defaultPhone ?? "");
    _templateCtrl = TextEditingController(
      text: widget.defaultTemplate ?? "hello_world",
    );
    _langCtrl = TextEditingController(text: widget.defaultLangCode ?? "en_US");
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _templateCtrl.dispose();
    _langCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await _sendTemplateMessage(
      toPhone: _phoneCtrl.text.trim(),
      templateName: _templateCtrl.text.trim(),
      langCode: _langCtrl.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(success ? "✅ Enviado" : "❌ Error"),
        content: Text(
          success
              ? "Mensaje enviado exitosamente por WhatsApp."
              : "No se pudo enviar el mensaje.\nRevisa tu token, número y template.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _phoneCtrl,
            decoration: const InputDecoration(
              labelText: "Teléfono con país (ej. 52155...)",
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return "Ingresa teléfono";
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _templateCtrl,
            decoration: const InputDecoration(
              labelText: "Nombre del template",
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return "Ingresa template";
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _langCtrl,
            decoration: const InputDecoration(
              labelText: "Código de idioma (ej. en_US)",
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return "Ingresa código de idioma";
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _sendMessage,
            icon: const FaIcon(FontAwesomeIcons.whatsapp),
            label: _isLoading
                ? const Text("Enviando...")
                : const Text("Enviar WhatsApp"),
          ),
        ],
      ),
    );
  }
}
