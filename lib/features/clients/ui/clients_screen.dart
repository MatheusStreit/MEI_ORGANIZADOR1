import 'package:flutter/material.dart';
import '../data/client_dao.dart';
import '../domain/client.dart';
import '../../../screens/forms/client_form.dart';

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
      showDragHandle: true,
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

  String _cityUf(Client c) {
    final cidade = c.cidade.trim();
    final estado = c.estado.trim();
    if (cidade.isEmpty && estado.isEmpty) return '';
    if (cidade.isEmpty) return estado;
    if (estado.isEmpty) return cidade;
    return '$cidade - $estado';
  }

  String _initials(String text) {
    final t = text.trim();
    if (t.isEmpty) return '?';
    final parts = t.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first;
    return '${parts.first.characters.first}${parts.last.characters.first}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),
      body: _clients.isEmpty
          ? Center(
              child: Text(
                'Nenhum cliente cadastrado',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: _clients.length,
              itemBuilder: (_, i) {
                final c = _clients[i];

                final contato = c.contato.trim();
                final local = _cityUf(c);
                final subtitle = [
                  if (contato.isNotEmpty) contato,
                  if (local.isNotEmpty) local,
                ].join(' • ');

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  color: cs.surfaceContainerHighest.withOpacity(0.55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => openForm(client: c),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar com iniciais
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                _initials(c.nomeFantasia).toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Infos
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.nomeFantasia,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle.isEmpty ? c.razaoSocial : subtitle,
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                                if (c.cnpj.trim().isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Chip(
                                      visualDensity: VisualDensity.compact,
                                      label: Text(
                                        c.cnpj,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Ação excluir
                          IconButton(
                            tooltip: 'Excluir',
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => deleteClient(c),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
