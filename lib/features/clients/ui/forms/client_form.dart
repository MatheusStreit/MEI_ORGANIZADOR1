import 'package:flutter/material.dart';
import '../../domain/client.dart';

class ClientForm extends StatefulWidget {
  final Client? client;
  final Function(Client) onSave;

  const ClientForm({
    super.key,
    this.client,
    required this.onSave,
  });

  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeFantasiaController;
  late final TextEditingController _razaoSocialController;
  late final TextEditingController _cnpjController;
  late final TextEditingController _responsavelController;
  late final TextEditingController _emailController;
  late final TextEditingController _contatoController;
  late final TextEditingController _estadoController;
  late final TextEditingController _cidadeController;
  late final TextEditingController _bairroController;
  late final TextEditingController _enderecoController;
  late final TextEditingController _numeroController;
  late final TextEditingController _cepController;

  @override
  void initState() {
    super.initState();
    _nomeFantasiaController =
        TextEditingController(text: widget.client?.nomeFantasia ?? '');
    _razaoSocialController =
        TextEditingController(text: widget.client?.razaoSocial ?? '');
    _cnpjController = TextEditingController(text: widget.client?.cnpj ?? '');
    _responsavelController =
        TextEditingController(text: widget.client?.responsavel ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _contatoController =
        TextEditingController(text: widget.client?.contato ?? '');
    _estadoController = TextEditingController(text: widget.client?.estado ?? '');
    _cidadeController = TextEditingController(text: widget.client?.cidade ?? '');
    _bairroController = TextEditingController(text: widget.client?.bairro ?? '');
    _enderecoController =
        TextEditingController(text: widget.client?.endereco ?? '');
    _numeroController = TextEditingController(text: widget.client?.numero ?? '');
    _cepController = TextEditingController(text: widget.client?.cep ?? '');
  }

  @override
  void dispose() {
    _nomeFantasiaController.dispose();
    _razaoSocialController.dispose();
    _cnpjController.dispose();
    _responsavelController.dispose();
    _emailController.dispose();
    _contatoController.dispose();
    _estadoController.dispose();
    _cidadeController.dispose();
    _bairroController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  String? _required(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label é obrigatório';
    return null;
  }

  String? _emailValidator(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return null;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    if (!ok) return 'Email inválido';
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final client = Client(
      id: widget.client?.id,
      nomeFantasia: _nomeFantasiaController.text.trim(),
      razaoSocial: _razaoSocialController.text.trim(),
      cnpj: _cnpjController.text.trim(),
      responsavel: _responsavelController.text.trim(),
      email: _emailController.text.trim(),
      contato: _contatoController.text.trim(),
      estado: _estadoController.text.trim(),
      cidade: _cidadeController.text.trim(),
      bairro: _bairroController.text.trim(),
      endereco: _enderecoController.text.trim(),
      numero: _numeroController.text.trim(),
      cep: _cepController.text.trim(),
    );

    widget.onSave(client);
  }

  InputDecoration _dec(String label, {IconData? icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest.withOpacity(0.55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: cs.onPrimaryContainer, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style:
                      const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final title = widget.client == null ? 'Novo Cliente' : 'Editar Cliente';

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        tooltip: 'Fechar',
                      ),
                    ],
                  ),
                ),

                // Body
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        _sectionCard(
                          title: 'Empresa',
                          icon: Icons.business_outlined,
                          children: [
                            TextFormField(
                              controller: _nomeFantasiaController,
                              decoration: _dec('Nome fantasia',
                                  icon: Icons.storefront_outlined),
                              textInputAction: TextInputAction.next,
                              validator: (v) => _required(v, 'Nome fantasia'),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _razaoSocialController,
                              decoration: _dec('Razão social',
                                  icon: Icons.apartment_outlined),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _cnpjController,
                              decoration:
                                  _dec('CNPJ', icon: Icons.badge_outlined),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        _sectionCard(
                          title: 'Contato',
                          icon: Icons.person_outline,
                          children: [
                            TextFormField(
                              controller: _responsavelController,
                              decoration: _dec('Responsável',
                                  icon: Icons.person_outline),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _emailController,
                              decoration:
                                  _dec('Email', icon: Icons.mail_outline),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: _emailValidator,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _contatoController,
                              decoration: _dec('Contato (tel/WhatsApp)',
                                  icon: Icons.phone_outlined),
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        _sectionCard(
                          title: 'Endereço',
                          icon: Icons.location_on_outlined,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _estadoController,
                                    decoration: _dec('UF',
                                        icon: Icons.map_outlined, hint: 'SP'),
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 5,
                                  child: TextFormField(
                                    controller: _cidadeController,
                                    decoration: _dec('Cidade',
                                        icon: Icons.location_city_outlined),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _bairroController,
                              decoration: _dec('Bairro',
                                  icon: Icons.place_outlined),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _enderecoController,
                              decoration: _dec('Endereço',
                                  icon: Icons.home_outlined),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: _numeroController,
                                    decoration: _dec('Número',
                                        icon: Icons.numbers_outlined),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 5,
                                  child: TextFormField(
                                    controller: _cepController,
                                    decoration: _dec('CEP',
                                        icon: Icons.local_post_office_outlined),
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 90), // espaço pro botão fixo
                      ],
                    ),
                  ),
                ),

                // Botão fixo embaixo
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 14,
                        offset: const Offset(0, -6),
                        color: Colors.black.withOpacity(0.08),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Salvar'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}