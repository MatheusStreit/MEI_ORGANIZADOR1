import '../../../data/db/app_database.dart';
import '../domain/client.dart';
import 'package:sqflite/sqflite.dart';

class ClientDao {
  Future<List<Client>> getAll() async {
    final db = await AppDatabase.database;

    final maps = await db.query(
      'clients',
      orderBy: 'nome_fantasia',
    );

    return maps.map((e) {
      return Client(
        id: e['id'] as int?,
        nomeFantasia: e['nome_fantasia'] as String,
        razaoSocial: e['razao_social'] as String,
        cnpj: e['cnpj'] as String,
        responsavel: e['responsavel'] as String,
        email: e['email'] as String,
        contato: e['contato'] as String,
        estado: e['estado'] as String,
        cidade: e['cidade'] as String,
        bairro: e['bairro'] as String,
        endereco: e['endereco'] as String,
        numero: e['numero'] as String,
        cep: e['cep'] as String,
      );
    }).toList();
  }

  Future<void> insert(Client client) async {
    final db = await AppDatabase.database;

    await db.insert(
      'clients',
      client.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Client client) async {
    final db = await AppDatabase.database;

    await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.database;

    await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
