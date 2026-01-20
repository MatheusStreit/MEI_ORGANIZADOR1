import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import '../models/service.dart';

class ServiceDao {
  Future<List<Service>> getByClient(int clientId) async {
  final db = await AppDatabase.database;

  final maps = await db.query(
    'services',
    where: 'client_id = ?',
    whereArgs: [clientId],
    orderBy: 'date DESC',
  );

  return maps.map((e) => Service.fromMap(e)).toList();
}

  Future<void> insert(Service service) async {
    final db = await AppDatabase.database;
    await db.insert('services', service.toMap());
  }

  Future<void> update(Service service) async {
    final db = await AppDatabase.database;
    await db.update(
      'services',
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.database;
    await db.delete(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
