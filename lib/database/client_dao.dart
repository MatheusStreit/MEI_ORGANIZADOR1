import 'app_database.dart';
import '../models/client.dart';

class ClientDao {
  Future<List<Client>> getAll() async {
    final db = await AppDatabase.database;

    final maps = await db.query(
      'clients',
      orderBy: 'name',
    );

    return maps.map((e) => Client(
      id: e['id'] as int?,
      name: e['name'] as String,
      phone: e['phone'] as String,
    )).toList();
  }

  Future<void> insert(Client client) async {
    final db = await AppDatabase.database;
    await db.insert('clients', client.toMap());
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
    await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }
}
