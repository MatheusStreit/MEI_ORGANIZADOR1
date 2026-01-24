import 'package:flutter/material.dart';
import '../../domain/service.dart';

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
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();

  DateTime? _deliveryDate;
  bool _remindDelivery = false;
  int _remindDaysBefore = 1;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final s = widget.service;
    if (s != null) {
      _titleCtrl.text = s.title;
      _detailsCtrl.text = s.details;

      // ✅ valor agora é opcional
      _valueCtrl.text = (s.value == null) ? '' : s.value!.toStringAsFixed(2);

      _deliveryDate = s.deliveryDate;
      _remindDelivery = s.remindDelivery;
      _remindDaysBefore = s.remindDaysBefore;
    } else {
      _deliveryDate = DateTime.now().add(const Duration(days: 1));
      _remindDelivery = false;
      _remindDaysBefore = 1;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _detailsCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

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

  double? _parseValue(String raw) {
    final cleaned = raw
        .trim()
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '') // ✅ remove separador de milhar
        .replaceAll(',', '.'); // ✅ decimal
    return double.tryParse(cleaned);
  }

  Future<void> _save() async {
    if (_saving) return;

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_deliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de entrega.')),
      );
      return;
    }

    // ✅ Valor opcional
    final rawValue = _valueCtrl.text.trim();
    final double? value = rawValue.isEmpty ? null : _parseValue(rawValue);

    // se usuário digitou algo e ficou inválido, bloqueia
    if (rawValue.isNotEmpty && value == null) return;

    setState(() => _saving = true);

    final s = Service(
      id: widget.service?.id,
      clientId: widget.clientId,
      title: _titleCtrl.text.trim(),
      details: _detailsCtrl.text.trim(),
      value: value, // ✅ pode ser null
      date: widget.service?.date ?? DateTime.now(),
      deliveryDate: _deliveryDate!,
      remindDelivery: _remindDelivery,
      remindDaysBefore: _remindDaysBefore,
    );

    // ✅ Não fecha o modal aqui
    widget.onSave(s);

    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.service != null;
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isEdit ? Icons.edit : Icons.add,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEdit ? 'Editar Serviço' : 'Novo Serviço',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fechar',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Título
                TextFormField(
                  controller: _titleCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Ex: Logo, Site, Cartão de visita…',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe um título.';
                    if (v.trim().length < 3) return 'Título muito curto.';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Detalhes
                TextFormField(
                  controller: _detailsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descrição / Detalhes',
                    hintText: 'Opcional',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 12),

                // Valor (opcional)
                TextFormField(
                  controller: _valueCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Valor (R\$) (opcional)',
                    hintText: 'Ex: 150,00',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (v) {
                    final raw = (v ?? '').trim();
                    if (raw.isEmpty) return null; // ✅ não obrigatório

                    final value = _parseValue(raw);
                    if (value == null) return 'Informe um valor válido.';
                    if (value <= 0) return 'O valor deve ser maior que zero.';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Data entrega
                Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _pickDeliveryDate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_month),
                        title: const Text('Data de entrega'),
                        subtitle: Text(
                          _deliveryDate == null ? 'Selecione...' : _fmtDate(_deliveryDate!),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Lembrete
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _remindDelivery,
                          onChanged: (v) => setState(() => _remindDelivery = v),
                          title: const Text('Receber lembrete antes da entrega'),
                          subtitle: const Text('Ative para não esquecer prazos'),
                        ),
                        if (_remindDelivery) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.alarm),
                              const SizedBox(width: 12),
                              const Text('Lembrar:'),
                              const SizedBox(width: 12),
                              DropdownButton<int>(
                                value: _remindDaysBefore,
                                items: const [1, 2, 3, 5, 7]
                                    .map((d) => DropdownMenuItem(
                                          value: d,
                                          child: Text('$d dia(s) antes'),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => _remindDaysBefore = v ?? 1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Actions
                Row(
                  children: [
                    if (isEdit && widget.onDelete != null)
                      TextButton.icon(
                        onPressed: _saving
                            ? null
                            : () {
                                widget.onDelete!();
                              },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Excluir'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(_saving ? 'Salvando...' : 'Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
