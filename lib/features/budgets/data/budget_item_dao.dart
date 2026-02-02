import '../../../data/db/app_database.dart';
import '../domain/budget_item.dart';
import 'package:mei_organizador1/features/budgets/models/orcamento.dart';


class BudgetItemDao {
  Future<List<BudgetItem>> getByBudget(int budgetId) async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      'budget_items',
      where: 'budget_id = ?',
      whereArgs: [budgetId],
      orderBy: 'sort_order ASC, id ASC',
    );
    return maps.map(BudgetItem.fromMap).toList();
  }

  Future<int> insert(BudgetItem item) async {
    final db = await AppDatabase.database;
    return db.insert('budget_items', item.toMap());
  }

  Future<void> update(BudgetItem item) async {
    final db = await AppDatabase.database;
    await db.update(
      'budget_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.database;
    await db.delete('budget_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByBudget(int budgetId) async {
    final db = await AppDatabase.database;
    await db.delete('budget_items', where: 'budget_id = ?', whereArgs: [budgetId]);
  }
}
