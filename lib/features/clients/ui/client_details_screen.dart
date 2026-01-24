import 'package:flutter/material.dart';

import '../../services/data/service_dao.dart';
import '../domain/client.dart';
import '../../services/domain/service.dart';
import '../../services/ui/forms/service_form.dart';

class ClientDetailsScreen extends StatefulWidget {
  final Client client;

  const ClientDetailsScreen({super.key, required this.client});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  final ServiceDao _serviceDao = ServiceDao();
  List<Service> _services = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _loadServices() async {
    setState(() => _loading = true);
    final data = await _serviceDao.getByClient(widget.client.id!);
    if (!mounted) return;
    setState(() {
      _services = data;
      _loading = false;
    });
  }

  void _openServiceForm({Service? service}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ServiceForm(
        clientId: widget.client.id!,
        service: service,
        onSave: (Service s) async {
          if (service == null) {
            await _serviceDao.insert(s);
          } else {
            await _serviceDao.update(s);
          }
          if (!mounted) return;
          Navigator.pop(context);
          await _loadServices();
        },
        onDelete: service == null
            ? null
            : () async {
                await _serviceDao.delete(service.id!);
                if (!mounted) return;
                Navigator.pop(context);
                await _loadServices();
              },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: cs.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  String _enderecoCompleto(Client c) {
    final parts = <String>[];

    final end = c.endereco.trim();
    final num = c.numero.trim();
    if (end.isNotEmpty) {
      parts.add(num.isNotEmpty ? '$end, $num' : end);
    }

    final cidade = c.cidade.trim();
    final estado = c.estado.trim();
    if (cidade.isNotEmpty || estado.isNotEmpty) {
      if (cidade.isNotEmpty && estado.isNotEmpty) {
        parts.add('$cidade - $estado');
      } else {
        parts.add(cidade.isNotEmpty ? cidade : estado);
      }
    }

    final bairro = c.bairro.trim();
    if (bairro.isNotEmpty) parts.add(bairro);

    final cep = c.cep.trim();
    if (cep.isNotEmpty) parts.add('CEP: $cep');

    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = widget.client;

    final endereco = _enderecoCompleto(c);

    return Scaffold(
      appBar: AppBar(title: Text(c.nomeFantasia)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openServiceForm(),
        icon: const Icon(Icons.add),
        label: const Text('Novo serviço'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.business, color: cs.onPrimaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.nomeFantasia,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          if (c.razaoSocial.trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                c.razaoSocial,
                                style:
                                    TextStyle(color: cs.onSurfaceVariant),
                              ),
                            ),
                          if (c.cnpj.trim().isNotEmpty)
                            _infoRow(
                                Icons.badge_outlined, 'CNPJ: ${c.cnpj}', cs),
                          if (c.responsavel.trim().isNotEmpty)
                            _infoRow(Icons.person_outline,
                                'Responsável: ${c.responsavel}', cs),
                          if (c.email.trim().isNotEmpty)
                            _infoRow(Icons.mail_outline, c.email, cs),
                          if (c.contato.trim().isNotEmpty)
                            _infoRow(Icons.phone_outlined, c.contato, cs),
                          if (endereco.isNotEmpty)
                            _infoRow(Icons.location_on_outlined, endereco, cs),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Text(
                  'Serviços',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Atualizar',
                  onPressed: _loadServices,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_services.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(Icons.inbox_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nenhum serviço cadastrado para este cliente.',
                          style:
                              TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ..._services.map((s) {
              final valueText = s.value == null
                  ? 'Sem valor'
                  : 'R\$ ${s.value!.toStringAsFixed(2)}';

              return Card(
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: s.remindDelivery
                          ? cs.tertiaryContainer
                          : cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      s.remindDelivery
                          ? Icons.notifications_active
                          : Icons.work_outline,
                      color: s.remindDelivery
                          ? cs.onTertiaryContainer
                          : cs.onSecondaryContainer,
                    ),
                  ),
                  title: Text(
                    s.title,
                    style:
                        const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '$valueText • Entrega: ${_fmtDate(s.deliveryDate)}'
                    '${s.details.trim().isEmpty ? '' : '\n${s.details}'}',
                  ),
                  isThreeLine: s.details.trim().isNotEmpty,
                  onTap: () => _openServiceForm(service: s),
                ),
              );
            }),
        ],
      ),
    );
  }
}
