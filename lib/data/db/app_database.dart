import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'mei.db');

    return openDatabase(
      path,
      version: 6, // ✅ subiu para criar tabelas de orçamentos
      onConfigure: (db) async {
        // ✅ necessário para ON DELETE CASCADE funcionar
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _migrate(db, oldVersion, newVersion);
      },
    );
  }

  static Future<void> _migrate(Database db, int oldVersion, int newVersion) async {
    // Garante tabelas base (caso venha de versão muito antiga)
    if (oldVersion < 2) {
      await _createClientsTableIfNeeded(db);
      await _createServicesTableIfNeeded(db);
    }

    // Ajustes antigos em services (mantive)
    if (oldVersion < 3) {
      final columns = await _getTableColumns(db, 'services');
      if (!columns.contains('title')) {
        await db.execute("ALTER TABLE services ADD COLUMN title TEXT");
        await db.execute("UPDATE services SET title = 'Serviço' WHERE title IS NULL");
      }
    }

    // Migração clients antigo -> novo (mantive)
    if (oldVersion < 5) {
      final columns = await _getTableColumns(db, 'clients');

      Future<void> addCol(String name, String type) async {
        if (!columns.contains(name)) {
          await db.execute("ALTER TABLE clients ADD COLUMN $name $type");
        }
      }

      await addCol('nome_fantasia', 'TEXT');
      await addCol('razao_social', 'TEXT');
      await addCol('cnpj', 'TEXT');
      await addCol('responsavel', 'TEXT');
      await addCol('contato', 'TEXT');
      await addCol('estado', 'TEXT');
      await addCol('cidade', 'TEXT');
      await addCol('bairro', 'TEXT');
      await addCol('endereco', 'TEXT');
      await addCol('numero', 'TEXT');
      await addCol('cep', 'TEXT');

      final columnsAfter = await _getTableColumns(db, 'clients');
      final hasOldName = columnsAfter.contains('name');
      final hasOldPhone = columnsAfter.contains('phone');
      final hasNewNome = columnsAfter.contains('nome_fantasia');
      final hasNewContato = columnsAfter.contains('contato');

      if (hasOldName && hasNewNome) {
        await db.execute("""
          UPDATE clients
          SET nome_fantasia = COALESCE(NULLIF(nome_fantasia, ''), name)
          WHERE nome_fantasia IS NULL OR nome_fantasia = ''
        """);
      }

      if (hasOldPhone && hasNewContato) {
        await db.execute("""
          UPDATE clients
          SET contato = COALESCE(NULLIF(contato, ''), phone)
          WHERE contato IS NULL OR contato = ''
        """);
      }
    }

    // ✅ V6: criar tabelas de orçamentos
    if (oldVersion < 6) {
      await _createBudgetsTableIfNeeded(db);
      await _createBudgetItemsTableIfNeeded(db);
    }
  }

  static Future<List<String>> _getTableColumns(Database db, String table) async {
    final result = await db.rawQuery("PRAGMA table_info($table)");
    return result.map((row) => row['name'] as String).toList();
  }

  static Future<void> _createTables(Database db) async {
    await _createClientsTableIfNeeded(db);
    await _createServicesTableIfNeeded(db);
    await _createBudgetsTableIfNeeded(db);       // ✅
    await _createBudgetItemsTableIfNeeded(db);   // ✅
  }

  static Future<void> _createClientsTableIfNeeded(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome_fantasia TEXT NOT NULL,
        razao_social TEXT,
        cnpj TEXT,
        responsavel TEXT,
        email TEXT,
        contato TEXT,
        estado TEXT,
        cidade TEXT,
        bairro TEXT,
        endereco TEXT,
        numero TEXT,
        cep TEXT
      )
    ''');
  }

  static Future<void> _createServicesTableIfNeeded(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        details TEXT,
        value REAL,
        date INTEGER NOT NULL,
        delivery_date INTEGER NOT NULL,
        remind_delivery INTEGER NOT NULL DEFAULT 0,
        remind_days_before INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (client_id) REFERENCES clients (id)
      )
    ''');
  }

  // ✅ Tabela de orçamentos
  static Future<void> _createBudgetsTableIfNeeded(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        valid_until INTEGER,
        notes TEXT,
        discount REAL,
        status TEXT NOT NULL DEFAULT 'rascunho',
        FOREIGN KEY (client_id) REFERENCES clients (id)
      )
    ''');
  }

  // ✅ Tabela de itens do orçamento
  static Future<void> _createBudgetItemsTableIfNeeded(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS budget_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        budget_id INTEGER NOT NULL,
        description TEXT NOT NULL,
        quantity REAL NOT NULL DEFAULT 1,
        unit_price REAL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE
      )
    ''');
  }
}
