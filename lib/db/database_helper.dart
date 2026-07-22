import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/investment.dart';
import '../models/loan.dart';
import '../models/savings_goal.dart';
import '../models/invoice.dart';
import '../models/ledger_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'elice.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _createAllTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS investments(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              type TEXT NOT NULL,
              quantity REAL NOT NULL,
              purchasePrice REAL NOT NULL,
              currentPrice REAL NOT NULL,
              currency TEXT NOT NULL,
              purchaseDate TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS loans(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              principal REAL NOT NULL,
              interestRate REAL NOT NULL,
              emiAmount REAL NOT NULL,
              totalMonths INTEGER NOT NULL,
              monthsPaid INTEGER NOT NULL,
              currency TEXT NOT NULL,
              startDate TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS savings_goals(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              targetAmount REAL NOT NULL,
              currentAmount REAL NOT NULL,
              currency TEXT NOT NULL,
              targetDate TEXT
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS invoices(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              clientName TEXT NOT NULL,
              description TEXT NOT NULL,
              amount REAL NOT NULL,
              currency TEXT NOT NULL,
              issueDate TEXT NOT NULL,
              dueDate TEXT NOT NULL,
              status TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ledger_entries(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              description TEXT NOT NULL,
              amount REAL NOT NULL,
              type TEXT NOT NULL,
              category TEXT NOT NULL,
              currency TEXT NOT NULL,
              date TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  Future<void> _createAllTables(Database db) async {
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        currency TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE investments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        quantity REAL NOT NULL,
        purchasePrice REAL NOT NULL,
        currentPrice REAL NOT NULL,
        currency TEXT NOT NULL,
        purchaseDate TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE loans(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        principal REAL NOT NULL,
        interestRate REAL NOT NULL,
        emiAmount REAL NOT NULL,
        totalMonths INTEGER NOT NULL,
        monthsPaid INTEGER NOT NULL,
        currency TEXT NOT NULL,
        startDate TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE savings_goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL NOT NULL,
        currency TEXT NOT NULL,
        targetDate TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE invoices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientName TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        issueDate TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE ledger_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        currency TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // ---------- Expenses ----------
  Future<int> insertExpense(Expense e) async {
    final db = await database;
    return db.insert('expenses', e.toMap());
  }

  Future<int> insertExpenses(List<Expense> expenses) async {
    final db = await database;
    final batch = db.batch();
    for (final e in expenses) {
      batch.insert('expenses', e.toMap());
    }
    final results = await batch.commit(noResult: false);
    return results.length;
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, double>> getTotalsByCategory() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM expenses GROUP BY category',
    );
    final Map<String, double> totals = {};
    for (var row in result) {
      totals[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return totals;
  }

  // ---------- Investments ----------
  Future<int> insertInvestment(Investment i) async {
    final db = await database;
    return db.insert('investments', i.toMap());
  }

  Future<List<Investment>> getAllInvestments() async {
    final db = await database;
    final maps = await db.query('investments', orderBy: 'purchaseDate DESC');
    return maps.map((m) => Investment.fromMap(m)).toList();
  }

  Future<int> deleteInvestment(int id) async {
    final db = await database;
    return db.delete('investments', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Loans ----------
  Future<int> insertLoan(Loan l) async {
    final db = await database;
    return db.insert('loans', l.toMap());
  }

  Future<List<Loan>> getAllLoans() async {
    final db = await database;
    final maps = await db.query('loans', orderBy: 'startDate DESC');
    return maps.map((m) => Loan.fromMap(m)).toList();
  }

  Future<int> deleteLoan(int id) async {
    final db = await database;
    return db.delete('loans', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Savings Goals ----------
  Future<int> insertSavingsGoal(SavingsGoal s) async {
    final db = await database;
    return db.insert('savings_goals', s.toMap());
  }

  Future<List<SavingsGoal>> getAllSavingsGoals() async {
    final db = await database;
    final maps = await db.query('savings_goals', orderBy: 'id DESC');
    return maps.map((m) => SavingsGoal.fromMap(m)).toList();
  }

  Future<int> deleteSavingsGoal(int id) async {
    final db = await database;
    return db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Invoices ----------
  Future<int> insertInvoice(Invoice i) async {
    final db = await database;
    return db.insert('invoices', i.toMap());
  }

  Future<List<Invoice>> getAllInvoices() async {
    final db = await database;
    final maps = await db.query('invoices', orderBy: 'issueDate DESC');
    return maps.map((m) => Invoice.fromMap(m)).toList();
  }

  Future<int> updateInvoiceStatus(int id, String status) async {
    final db = await database;
    return db.update('invoices', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteInvoice(int id) async {
    final db = await database;
    return db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Ledger Entries ----------
  Future<int> insertLedgerEntry(LedgerEntry e) async {
    final db = await database;
    return db.insert('ledger_entries', e.toMap());
  }

  Future<List<LedgerEntry>> getAllLedgerEntries() async {
    final db = await database;
    final maps = await db.query('ledger_entries', orderBy: 'date DESC');
    return maps.map((m) => LedgerEntry.fromMap(m)).toList();
  }

  Future<int> deleteLedgerEntry(int id) async {
    final db = await database;
    return db.delete('ledger_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getNetIncome() async {
    final db = await database;
    final income = await db.rawQuery(
      "SELECT SUM(amount) as total FROM ledger_entries WHERE type = 'Income'",
    );
    final expense = await db.rawQuery(
      "SELECT SUM(amount) as total FROM ledger_entries WHERE type = 'Expense'",
    );
    final incomeTotal = (income.first['total'] as num?)?.toDouble() ?? 0;
    final expenseTotal = (expense.first['total'] as num?)?.toDouble() ?? 0;
    return incomeTotal - expenseTotal;
  }
}
