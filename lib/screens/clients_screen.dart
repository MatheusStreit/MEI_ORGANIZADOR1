import 'package:flutter/material.dart';
import '../database/client_dao.dart';
import '../models/client.dart';
import 'forms/client_form.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _dao = ClientDao();
  List<Client> _clients = [];

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  Future<void> loadClients() async {
    _clients = await _dao.getAll();
    if (mounted) setState(() {});
  }

  void openForm({Client? client}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ClientForm(
        client: client,
        onSave: (c) async {
          if (client == null) {
            await _dao.insert(c);
          } else {
            await _dao.update(c);
          }
          if (!mounted) return;
          Navigator.pop(context);
          loadClients();
        },
      ),
    );
  }

  Future<void> deleteClient(Client client) async {
    await _dao.delete(client.id!);
    loadClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _clients.length,
        itemBuilder: (_, i) {
          final c = _clients[i];
          return ListTile(
            title: Text(c.name),
            subtitle: Text(c.phone),
            onTap: () => openForm(client: c),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteClient(c),
            ),
          );
        },
      ),
    );
  }
}
