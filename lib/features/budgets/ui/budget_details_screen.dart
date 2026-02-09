import 'dart:io';

import 'package:flutter/material.dart';

import '../../clients/data/client_dao.dart';
import '../../clients/domain/client.dart';
import '../data/budget_dao.dart';
import '../data/budget_item_dao.dart';
import '../domain/budget.dart';
import '../domain/budget_item.dart';
import 'forms/budget_form.dart';

// ✅ novos imports (crie esses arquivos na feature budgets)
import '../models/orcamento.dart';
import '../services/orcamento_pdf_service.dart';
import '../services/share_services.dart';

class BudgetDetailsScreen extends StatefulWidget {
  final int budgetId;

  const BudgetDetailsScreen({super.key, required this.budgetId});

  @override
  State<BudgetDetailsScreen> createState() => _BudgetDetailsScreenState();
}

class _BudgetDetailsScreenState extends State<BudgetDetailsScreen> {
  final _budgetDao = BudgetDao();
  final _itemDao = BudgetItemDao();
  final _clientDao = ClientDao();

  // ✅ services
  final _pdfService = OrcamentoPdfService();
  final _shareService = ShareService();

  Budget? _budget;
  Client? _client;
  List<BudgetItem> _items = [];
  bool _loading = true;

  bool _sharingPdf = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final b = await _budgetDao.getById(widget.budgetId);
    if (b == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    final items = await _itemDao.getByBudget(widget.budgetId);
    final clients = await _clientDao.getAll();
    final client = clients.firstWhere(
      (c) => c.id == b.clientId,
      orElse: () => clients.first,
    );

    if (!mounted) return;
    setState(() {
      _budget = b;
      _items = items;
      _client = client;
      _loading = false;
    });
  }

  double get _subtotal => _items.fold(0, (p, e) => p + e.total);
  double get _discount => _budget?.discount ?? 0;
  double get _total => (_subtotal - _discount).clamp(0, double.infinity);

  void _edit() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => BudgetForm(budgetId: widget.budgetId)),
    );
    if (ok == true) _load();
  }

  Future<void> _generateAndSharePdf() async {
    final budget = _budget;
    if (budget == null) return;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione itens no orçamento para gerar o PDF.')),
      );
      return;
    }

    setState(() => _sharingPdf = true);

    try {
      // Ajuda a UI a renderizar o loading antes do trabalho pesado
      await Future<void>.delayed(const Duration(milliseconds: 80));

      final clienteNome = _client?.nomeFantasia ?? 'Cliente';
      final clienteContato = (_client?.contato ?? '').trim();

      final orcItens = _items.map((it) {
        final qtd = it.quantity;

        // Se unitPrice for null, vai como 0 (ou você pode bloquear)
        final unit = (it.unitPrice ?? 0);

        return OrcamentoItem(
          descricao: it.description,
          qtd: qtd,
          valorUnit: unit,
        );
      }).toList();

      final orc = Orcamento(
        id: budget.id ?? widget.budgetId,
        clienteNome: clienteNome,
        clienteTelefone: clienteContato.isEmpty ? null : clienteContato,
        clienteDocumento: null, // se tiver CPF/CNPJ no Client depois você coloca aqui
        data: budget.createdAt,
        validade: budget.validUntil,
        itens: orcItens,
        desconto: budget.discount ?? 0,
        taxa: null,
      );

      final File pdfFile = await _pdfService.gerarPdf(
        orc: orc,
        nomeEmpresa: 'MEI Organizador', // depois você pode puxar de uma config do app
        observacoes: budget.notes.trim().isEmpty ? null : budget.notes.trim(),
      );

      final msg =
          'Olá! Segue o orçamento nº ${orc.id} em anexo.\n'
          'Total: R\$ ${orc.total.toStringAsFixed(2)}';

      await _shareService.compartilharPdf(
        pdfFile: pdfFile,
        mensagem: msg,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar/compartilhar PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => _sharingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_budget == null) return const Scaffold(body: Center(child: Text('Orçamento não encontrado.')));

    return Scaffold(
      appBar: AppBar(
        title: Text('Orçamento #${_budget!.id}'),
        actions: [
          IconButton(onPressed: _edit, icon: const Icon(Icons.edit), tooltip: 'Editar'),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh), tooltip: 'Atualizar'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (_client != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(_client!.nomeFantasia),
                subtitle: Text(_client!.contato),
              ),
            ),

          const SizedBox(height: 12),

          Text(
            'Itens',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),

          if (_items.isEmpty)
            Text('Nenhum item.', style: TextStyle(color: cs.onSurfaceVariant))
          else
            ..._items.map((it) {
              final unit = it.unitPrice == null ? '—' : 'R\$ ${it.unitPrice!.toStringAsFixed(2)}';
              return Card(
                child: ListTile(
                  title: Text(it.description, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('Qtd: ${it.quantity} • Unit: $unit'),
                  trailing: Text('R\$ ${it.total.toStringAsFixed(2)}'),
                ),
              );
            }),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Resumo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  _line('Subtotal', 'R\$ ${_subtotal.toStringAsFixed(2)}'),
                  _line('Desconto', 'R\$ ${_discount.toStringAsFixed(2)}'),
                  const Divider(),
                  _line('Total', 'R\$ ${_total.toStringAsFixed(2)}', strong: true),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          FilledButton.icon(
            onPressed: _sharingPdf ? null : _generateAndSharePdf,
            icon: _sharingPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf),
            label: Text(_sharingPdf ? 'Gerando...' : 'Gerar / Compartilhar PDF'),
          ),
        ],
      ),
    );
  }

  Widget _line(String left, String right, {bool strong = false}) {
    final style = strong ? const TextStyle(fontWeight: FontWeight.w800) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(left, style: style)),
          Text(right, style: style),
        ],
      ),
    );
  }
}
