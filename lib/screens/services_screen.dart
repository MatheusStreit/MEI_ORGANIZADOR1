import 'package:flutter/material.dart';
import '../database/client_dao.dart';
import '../database/service_dao.dart';
import '../models/client.dart';
import '../models/service.dart';
import 'forms/service_form.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final ClientDao _clientDao = ClientDao();
  final ServiceDao _serviceDao = ServiceDao();

  List<Client> _clients = [];
  List<Service> _services = [];
  Client? _selectedClient;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  String _fmtDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  Future<void> _loadClients() async {
    final data = await _clientDao.getAll();
    setState(() => _clients = data);
  }

  Future<void> _loadServices() async {
    if (_selectedClient == null) return;
    final data = await _serviceDao.getByClient(_selectedClient!.id!);
    setState(() => _services = data);
  }

  void _openServiceForm({Service? service}) {
    if (_selectedClient == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ServiceForm(
        clientId: _selectedClient!.id!,
        service: service,
        onSave: (Service s) async {
          // ✅ se veio com id, é edição
          if (service == null) {
            await _serviceDao.insert(s);
          } else {
            await _serviceDao.update(s);
          }
          await _loadServices();
        },
        onDelete: service == null
            ? null
            : () async {
                await _serviceDao.delete(service.id!);
                await _loadServices();
              },
      ),
    );
  }

  Future<void> _confirmDelete(Service s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir serviço'),
        content: Text('Deseja excluir "${s.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _serviceDao.delete(s.id!);
      await _loadServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serviços')),
      floatingActionButton: _selectedClient == null
          ? null
          : FloatingActionButton(
              onPressed: () => _openServiceForm(),
              child: const Icon(Icons.add),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Client>(
              value: _selectedClient,
              hint: const Text('Selecione um cliente'),
              items: _clients
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.name),
                      ))
                  .toList(),
              onChanged: (client) async {
                setState(() {
                  _selectedClient = client;
                  _services = [];
                });
                await _loadServices();
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedClient == null
                  ? const Center(child: Text('Selecione um cliente para ver os serviços'))
                  : _services.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum serviço cadastrado',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _services.length,
                          itemBuilder: (_, index) {
                            final s = _services[index];

                            return Card(
                              child: ListTile(
                                leading: s.remindDelivery
                                    ? const Icon(Icons.notifications_active, color: Colors.orange)
                                    : const Icon(Icons.work),
                                title: Text(s.title),
                                subtitle: Text(
                                  'R\$ ${s.value.toStringAsFixed(2)} • Entrega: ${_fmtDate(s.deliveryDate)}'
                                  '${s.details.trim().isEmpty ? '' : '\n${s.details}'}',
                                ),
                                isThreeLine: s.details.trim().isNotEmpty,
                                onTap: () => _openServiceForm(service: s),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _openServiceForm(service: s),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmDelete(s),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
