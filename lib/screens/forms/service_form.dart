import 'package:flutter/material.dart';
import '../../models/service.dart';

class ServiceForm extends StatefulWidget {
  final int clientId;
  final Service? service;
  final Function(Service) onSave;
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
  final _descCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _descCtrl.text = widget.service!.description;
      _valueCtrl.text = widget.service!.value.toString();
    }
  }

  void _save() {
    final value = double.tryParse(_valueCtrl.text.replaceAll(',', '.'));

    if (_descCtrl.text.isEmpty || value == null) return;

    final service = Service(
      id: widget.service?.id,
      clientId: widget.clientId,
      description: _descCtrl.text,
      value: value,
      date: widget.service?.date ?? DateTime.now(),
    );

    widget.onSave(service);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
            widget.service == null ? 'Novo Serviço' : 'Editar Serviço',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Descrição'),
          ),
          TextField(
            controller: _valueCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Valor'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.onDelete != null)
                TextButton(
                  onPressed: () {
                    widget.onDelete!();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Excluir',
                    style: TextStyle(color: Colors.red),
                  ),
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
