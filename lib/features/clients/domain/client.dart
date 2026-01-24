class Client {
  final int? id;

  final String nomeFantasia;
  final String razaoSocial;
  final String cnpj;
  final String responsavel;
  final String email;
  final String contato;
  final String estado;
  final String cidade;
  final String bairro;
  final String endereco;
  final String numero;
  final String cep;

  Client({
    this.id,
    required this.nomeFantasia,
    required this.razaoSocial,
    required this.cnpj,
    required this.responsavel,
    required this.email,
    required this.contato,
    required this.estado,
    required this.cidade,
    required this.bairro,
    required this.endereco,
    required this.numero,
    required this.cep,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome_fantasia': nomeFantasia,
      'razao_social': razaoSocial,
      'cnpj': cnpj,
      'responsavel': responsavel,
      'email': email,
      'contato': contato,
      'estado': estado,
      'cidade': cidade,
      'bairro': bairro,
      'endereco': endereco,
      'numero': numero,
      'cep': cep,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      nomeFantasia: map['nome_fantasia'],
      razaoSocial: map['razao_social'],
      cnpj: map['cnpj'],
      responsavel: map['responsavel'],
      email: map['email'],
      contato: map['contato'],
      estado: map['estado'],
      cidade: map['cidade'],
      bairro: map['bairro'],
      endereco: map['endereco'],
      numero: map['numero'],
      cep: map['cep'],
    );
  }
}
