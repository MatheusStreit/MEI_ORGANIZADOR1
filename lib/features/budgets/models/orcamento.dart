class Orcamento {
  final int id;
  final String clienteNome;
  final String? clienteTelefone;
  final String? clienteDocumento; // CPF/CNPJ
  final DateTime data;
  final DateTime? validade;
  final List<OrcamentoItem> itens;
  final double desconto;
  final double? taxa;

  const Orcamento({
    required this.id,
    required this.clienteNome,
    this.clienteTelefone,
    this.clienteDocumento,
    required this.data,
    this.validade,
    required this.itens,
    this.desconto = 0,
    this.taxa,
  });

  double get subtotal => itens.fold(0, (a, b) => a + (b.qtd * b.valorUnit));
  double get total => subtotal - desconto + (taxa ?? 0);
}

class OrcamentoItem {
  final String descricao;
  final double qtd;
  final double valorUnit;

  const OrcamentoItem({
    required this.descricao,
    required this.qtd,
    required this.valorUnit,
  });
}
