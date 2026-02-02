import '../../../data/db/app_database.dart';
import '../domain/budget.dart';

class BudgetDao {
  Future<List<Budget>> getAll({int? clientId}) async {
    final db = await AppDatabase.database;

    final maps = await db.query(
      'budgets',
      where: clientId == null ? null : 'client_id = ?',
      whereArgs: clientId == null ? null : [clientId],
      orderBy: 'created_at DESC',
    );

    return maps.map(Budget.fromMap).toList();
  }

  Future<Budget?> getById(int id) async {
    final db = await AppDatabase.database;
    final maps = await db.query('budgets', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Budget.fromMap(maps.first);
  }

  Future<int> insert(Budget budget) async {
    final db = await AppDatabase.database;
    return db.insert('budgets', budget.toMap());
  }

  Future<void> update(Budget budget) async {
    final db = await AppDatabase.database;
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}
