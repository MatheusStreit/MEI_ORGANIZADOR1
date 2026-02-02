import 'package:flutter/material.dart';
import '../../domain/budget_item.dart';

class BudgetItemForm extends StatefulWidget {
  final BudgetItem? item;
  final void Function(String description, double qty, double? unitPrice) onSave;

  const BudgetItemForm({super.key, this.item, required this.onSave});

  @override
  State<BudgetItemForm> createState() => _BudgetItemFormState();
}

class _BudgetItemFormState extends State<BudgetItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final it = widget.item;
    if (it != null) {
      _descCtrl.text = it.description;
      _qtyCtrl.text = it.quantity.toString();
      _priceCtrl.text = it.unitPrice?.toStringAsFixed(2) ?? '';
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  double? _parseNum(String s) {
    final t = s.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(t);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final qty = _parseNum(_qtyCtrl.text) ?? 1;
    final rawPrice = _priceCtrl.text.trim();
    final price = rawPrice.isEmpty ? null : _parseNum(rawPrice);

    widget.onSave(_descCtrl.text.trim(), qty, price);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEdit ? 'Editar item' : 'Novo item',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                prefixIcon: Icon(Icons.text_fields),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a descrição' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Qtd',
                      prefixIcon: Icon(Icons.exposure_plus_1),
                    ),
                    validator: (v) {
                      final n = _parseNum(v ?? '');
                      if (n == null || n <= 0) return 'Qtd inválida';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Valor unit (opcional)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (v) {
                      final raw = (v ?? '').trim();
                      if (raw.isEmpty) return null;
                      final n = _parseNum(raw);
                      if (n == null || n < 0) return 'Valor inválido';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
