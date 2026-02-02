import 'package:flutter/material.dart';
import '../data/budget_dao.dart';
import '../domain/budget.dart';
import 'budget_details_screen.dart';
import 'forms/budget_form.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final _dao = BudgetDao();
  List<Budget> _budgets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _dao.getAll();
    if (!mounted) return;
    setState(() {
      _budgets = data;
      _loading = false;
    });
  }

  Future<void> _newBudget() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const BudgetForm()),
    );

    if (ok == true) {
      await _load();
    }
  }

  Future<void> _openBudget(Budget b) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BudgetDetailsScreen(budgetId: b.id!)),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newBudget,
        icon: const Icon(Icons.add),
        label: const Text('Novo orçamento'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _budgets.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum orçamento cadastrado.\nToque em "Novo orçamento".',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: _budgets.length,
                  itemBuilder: (_, i) {
                    final b = _budgets[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: Text('Orçamento #${b.id ?? ''}'),
                        subtitle: Text('Status: ${b.status}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openBudget(b),
                      ),
                    );
                  },
                ),
    );
  }
}
