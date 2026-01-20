import 'package:flutter/material.dart';
import '../../../models/client.dart';

class ClientForm extends StatefulWidget {
  final Client? client;
  final Function(Client) onSave;

  const ClientForm({
    super.key,
    this.client,
    required this.onSave,
  });

  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.client?.name ?? '');
    _phoneController =
        TextEditingController(text: widget.client?.phone ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.client == null ? 'Novo Cliente' : 'Editar Cliente',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Telefone'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final client = Client(
                id: widget.client?.id,
                name: _nameController.text.trim(),
                phone: _phoneController.text.trim(),
              );
              widget.onSave(client);
            },
            child: const Text('Salvar'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
