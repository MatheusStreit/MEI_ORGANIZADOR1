import 'package:flutter/material.dart';
import '../../../clients/data/client_dao.dart';
import '../../../clients/domain/client.dart';
import '../../data/budget_dao.dart';
import '../../data/budget_item_dao.dart';
import '../../domain/budget.dart';
import '../../domain/budget_item.dart';
import 'budget_item_form.dart';

class BudgetForm extends StatefulWidget {
  final int? budgetId; // null = novo

  const BudgetForm({super.key, this.budgetId});

  @override
  State<BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final _budgetDao = BudgetDao();
  final _itemDao = BudgetItemDao();
  final _clientDao = ClientDao();

  final _notesCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  List<Client> _clients = [];
  Client? _selectedClient;

  List<BudgetItem> _items = [];
  DateTime? _validUntil;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  double? _parseMoney(String raw) {
    final t = raw.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(t);
  }

  double get _subtotal => _items.fold(0, (p, e) => p + e.total);
  double get _discount => _discountCtrl.text.trim().isEmpty ? 0 : (_parseMoney(_discountCtrl.text) ?? 0);
  double get _total => (_subtotal - _discount).clamp(0, double.infinity);

  Future<void> _init() async {
    final clients = await _clientDao.getAll();

    if (!mounted) return;
    setState(() {
      _clients = clients;
      _loading = false;
    });

    if (widget.budgetId != null) {
      final b = await _budgetDao.getById(widget.budgetId!);
      final items = await _itemDao.getByBudget(widget.budgetId!);

      if (!mounted) return;
      setState(() {
        _notesCtrl.text = b?.notes ?? '';
        _discountCtrl.text = (b?.discount == null) ? '' : b!.discount!.toStringAsFixed(2);
        _validUntil = b?.validUntil;
        _items = items;
        _selectedClient = _clients.firstWhere((c) => c.id == b?.clientId, orElse: () => _clients.first);
      });
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickValidUntil() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _validUntil ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _validUntil = picked);
  }

  void _addItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BudgetItemForm(
        onSave: (desc, qty, unitPrice) {
          setState(() {
            _items.add(BudgetItem(
              budgetId: widget.budgetId ?? 0,
              description: desc,
              quantity: qty,
              unitPrice: unitPrice,
              sortOrder: _items.length,
            ));
          });
        },
      ),
    );
  }

  void _editItem(int index) {
    final it = _items[index];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BudgetItemForm(
        item: it,
        onSave: (desc, qty, unitPrice) {
          setState(() {
            _items[index] = BudgetItem(
              id: it.id,
              budgetId: it.budgetId,
              description: desc,
              quantity: qty,
              unitPrice: unitPrice,
              sortOrder: it.sortOrder,
            );
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _save() async {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente.')),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos 1 item.')),
      );
      return;
    }

    final discount = _discountCtrl.text.trim().isEmpty ? null : _parseMoney(_discountCtrl.text);

    // Novo
    if (widget.budgetId == null) {
      final id = await _budgetDao.insert(Budget(
        clientId: _selectedClient!.id!,
        createdAt: DateTime.now(),
        validUntil: _validUntil,
        notes: _notesCtrl.text.trim(),
        discount: discount,
        status: 'rascunho',
      ));

      // salva itens
      for (var i = 0; i < _items.length; i++) {
        final it = _items[i];
        await _itemDao.insert(BudgetItem(
          budgetId: id,
          description: it.description,
          quantity: it.quantity,
          unitPrice: it.unitPrice,
          sortOrder: i,
        ));
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    }

    // Editar
    await _budgetDao.update(Budget(
      id: widget.budgetId,
      clientId: _selectedClient!.id!,
      createdAt: DateTime.now(), // opcional: manter original (se quiser eu ajusto)
      validUntil: _validUntil,
      notes: _notesCtrl.text.trim(),
      discount: discount,
      status: 'rascunho',
    ));

    // simples: apaga e recria itens
    await _itemDao.deleteByBudget(widget.budgetId!);
    for (var i = 0; i < _items.length; i++) {
      final it = _items[i];
      await _itemDao.insert(BudgetItem(
        budgetId: widget.budgetId!,
        description: it.description,
        quantity: it.quantity,
        unitPrice: it.unitPrice,
        sortOrder: i,
      ));
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.budgetId == null ? 'Novo Orçamento' : 'Editar Orçamento')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          DropdownButtonFormField<Client>(
            value: _selectedClient,
            hint: const Text('Selecione um cliente'),
            items: _clients
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.nomeFantasia),
                    ))
                .toList(),
            onChanged: (c) => setState(() => _selectedClient = c),
          ),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Validade'),
              subtitle: Text(_validUntil == null ? 'Opcional' : _fmtDate(_validUntil!)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickValidUntil,
            ),
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _discountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Desconto (opcional)',
              prefixIcon: Icon(Icons.percent),
              hintText: 'Ex: 50,00',
            ),
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _notesCtrl,
            decoration: const InputDecoration(
              labelText: 'Observações',
              prefixIcon: Icon(Icons.notes_outlined),
              hintText: 'Prazo, forma de pagamento, etc.',
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Text('Itens', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
              ),
            ],
          ),

          if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Nenhum item adicionado.', style: TextStyle(color: cs.onSurfaceVariant)),
            )
          else
            ..._items.asMap().entries.map((e) {
              final idx = e.key;
              final it = e.value;

              final unit = it.unitPrice == null ? '—' : 'R\$ ${it.unitPrice!.toStringAsFixed(2)}';
              final total = 'R\$ ${it.total.toStringAsFixed(2)}';

              return Card(
                child: ListTile(
                  title: Text(it.description, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('Qtd: ${it.quantity} • Unit: $unit • Total: $total'),
                  onTap: () => _editItem(idx),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeItem(idx),
                  ),
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
                  Text('Resumo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  _line('Subtotal', 'R\$ ${_subtotal.toStringAsFixed(2)}'),
                  _line('Desconto', 'R\$ ${_discount.toStringAsFixed(2)}'),
                  const Divider(),
                  _line('Total', 'R\$ ${_total.toStringAsFixed(2)}', strong: true),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Salvar Orçamento'),
            ),
          ),
        ),
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
