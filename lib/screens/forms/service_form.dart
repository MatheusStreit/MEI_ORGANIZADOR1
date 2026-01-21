import 'package:flutter/material.dart';
import '../../models/service.dart';

class ServiceForm extends StatefulWidget {
  final int clientId;
  final Service? service;
  final void Function(Service) onSave;
  final VoidCallback? onDelete;

  const ServiceForm({
    super.key,
    required this.clientId,
    required this.onSave,
    this.service,
    this.onDelete,
  });

  @override
  State<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  final _titleCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();

  DateTime? _deliveryDate;
  bool _remindDelivery = false;
  int _remindDaysBefore = 1;

  @override
  void initState() {
    super.initState();

    final s = widget.service;
    if (s != null) {
      _titleCtrl.text = s.title;
      _detailsCtrl.text = s.details;
      _valueCtrl.text = s.value.toStringAsFixed(2);
      _deliveryDate = s.deliveryDate;
      _remindDelivery = s.remindDelivery;
      _remindDaysBefore = s.remindDaysBefore;
    } else {
      _deliveryDate = DateTime.now().add(const Duration(days: 1));
      _remindDelivery = false;
      _remindDaysBefore = 1;
    }
  }

  Future<void> _pickDeliveryDate() async {
    final now = DateTime.now();
    final initial = _deliveryDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() => _deliveryDate = picked);
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _save() {
    final value = double.tryParse(_valueCtrl.text.replaceAll(',', '.'));

    if (_titleCtrl.text.trim().isEmpty) return;
    if (value == null) return;
    if (_deliveryDate == null) return;

    final s = Service(
      id: widget.service?.id,
      clientId: widget.clientId,
      title: _titleCtrl.text.trim(),
      details: _detailsCtrl.text.trim(),
      value: value,
      date: widget.service?.date ?? DateTime.now(),
      deliveryDate: _deliveryDate!,
      remindDelivery: _remindDelivery,
      remindDaysBefore: _remindDaysBefore,
    );

    widget.onSave(s);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.service != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEdit ? 'Editar Serviço' : 'Novo Serviço',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Título'),
          ),

          TextField(
            controller: _detailsCtrl,
            decoration: const InputDecoration(labelText: 'Descrição / Detalhes'),
            maxLines: 3,
          ),

          TextField(
            controller: _valueCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Valor (R\$)'),
          ),

          const SizedBox(height: 12),

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Data de entrega'),
            subtitle: Text(_deliveryDate == null ? 'Selecione...' : _fmtDate(_deliveryDate!)),
            trailing: const Icon(Icons.calendar_month),
            onTap: _pickDeliveryDate,
          ),

          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _remindDelivery,
            onChanged: (v) => setState(() => _remindDelivery = v ?? false),
            title: const Text('Receber lembrete antes da entrega'),
          ),

          if (_remindDelivery)
            Row(
              children: [
                const Text('Lembrar'),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _remindDaysBefore,
                  items: const [1, 2, 3, 5, 7]
                      .map((d) => DropdownMenuItem(value: d, child: Text('$d dia(s) antes')))
                      .toList(),
                  onChanged: (v) => setState(() => _remindDaysBefore = v ?? 1),
                ),
              ],
            ),

          const SizedBox(height: 16),

          Row(
            children: [
              if (isEdit && widget.onDelete != null)
                TextButton(
                  onPressed: () {
                    widget.onDelete!();
                    Navigator.pop(context);
                  },
                  child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
