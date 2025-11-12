import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/session.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  // Get database instance (singleton pattern)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('poker_tracker.db');
    return _database!;
  }

  // Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create database tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        gameType TEXT NOT NULL,
        gameVariant TEXT NOT NULL,
        location TEXT NOT NULL,
        buyIn REAL NOT NULL,
        cashOut REAL NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        isLive INTEGER NOT NULL,
        stakes TEXT,
        tournamentBuyIn INTEGER,
        tournamentPosition INTEGER,
        totalPlayers INTEGER,
        notes TEXT,
        tags TEXT
      )
    ''');
  }

  // Close database
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  // ==================== CRUD OPERATIONS ====================

  // Create: Insert a new session
  Future<Session> createSession(Session session) async {
    final db = await instance.database;
    await db.insert(
      'sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return session;
  }

  // Read: Get session by ID
  Future<Session?> getSession(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Session.fromMap(maps.first);
    }
    return null;
  }

  // Read: Get all sessions
  Future<List<Session>> getAllSessions() async {
    final db = await instance.database;
    final result = await db.query(
      'sessions',
      orderBy: 'startTime DESC', // Most recent first
    );
    return result.map((map) => Session.fromMap(map)).toList();
  }

  // Read: Get live sessions
  Future<List<Session>> getLiveSessions() async {
    final db = await instance.database;
    final result = await db.query(
      'sessions',
      where: 'isLive = ?',
      whereArgs: [1],
      orderBy: 'startTime DESC',
    );
    return result.map((map) => Session.fromMap(map)).toList();
  }

  // Read: Get completed sessions
  Future<List<Session>> getCompletedSessions() async {
    final db = await instance.database;
    final result = await db.query(
      'sessions',
      where: 'isLive = ?',
      whereArgs: [0],
      orderBy: 'startTime DESC',
    );
    return result.map((map) => Session.fromMap(map)).toList();
  }

  // Read: Get sessions by date range
  Future<List<Session>> getSessionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'sessions',
      where: 'startTime BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'startTime DESC',
    );
    return result.map((map) => Session.fromMap(map)).toList();
  }

  // Read: Get sessions by game type
  Future<List<Session>> getSessionsByGameType(String gameType) async {
    final db = await instance.database;
    final result = await db.query(
      'sessions',
      where: 'gameType = ?',
      whereArgs: [gameType],
      orderBy: 'startTime DESC',
    );
    return result.map((map) => Session.fromMap(map)).toList();
  }

  // Read: Get sessions by location
  Future<List<Session>> getSessionsByLocation(String location) async {
    final db = await instance.database;
    final result = await db.query(
      'sessions',
      where: 'location = ?',
      whereArgs: [location],
      orderBy: 'startTime DESC',
    );
    return result.map((map) => Session.fromMap(map)).toList();
  }

  // Update: Update an existing session
  Future<int> updateSession(Session session) async {
    final db = await instance.database;
    return db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  // Delete: Delete a session
  Future<int> deleteSession(String id) async {
    final db = await instance.database;
    return await db.delete(
      'sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete: Delete all sessions (use with caution!)
  Future<int> deleteAllSessions() async {
    final db = await instance.database;
    return await db.delete('sessions');
  }

  // ==================== STATISTICS & ANALYTICS ====================

  // Get total profit/loss across all sessions
  Future<double> getTotalProfit() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT SUM(cashOut - buyIn) as totalProfit
      FROM sessions
      WHERE isLive = 0
    ''');
    
    if (result.isNotEmpty && result.first['totalProfit'] != null) {
      return result.first['totalProfit'] as double;
    }
    return 0.0;
  }

  // Get total number of sessions
  Future<int> getTotalSessionCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sessions');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get total number of completed sessions
  Future<int> getCompletedSessionCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM sessions WHERE isLive = 0
    ''');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get win rate (percentage of profitable sessions)
  Future<double> getWinRate() async {
    final db = await instance.database;
    final totalResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM sessions WHERE isLive = 0
    ''');
    final winResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM sessions 
      WHERE isLive = 0 AND (cashOut - buyIn) > 0
    ''');

    final total = Sqflite.firstIntValue(totalResult) ?? 0;
    final wins = Sqflite.firstIntValue(winResult) ?? 0;

    if (total > 0) {
      return (wins / total) * 100;
    }
    return 0.0;
  }

  // Get average profit per session
  Future<double> getAverageProfitPerSession() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT AVG(cashOut - buyIn) as avgProfit
      FROM sessions
      WHERE isLive = 0
    ''');

    if (result.isNotEmpty && result.first['avgProfit'] != null) {
      return result.first['avgProfit'] as double;
    }
    return 0.0;
  }

  // Get best session (highest profit)
  Future<Session?> getBestSession() async {
    final db = await instance.database;
    final result = await db.query(
      'sessions',
      where: 'isLive = ?',
      whereArgs: [0],
      orderBy: '(cashOut - buyIn) DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Session.fromMap(result.first);
    }
    return null;
  }

  // Get worst session (biggest loss)
  Future<Session?> getWorstSession() async {
    final db = await instance.database;
    final result = await db.query(
      'sessions',
      where: 'isLive = ?',
      whereArgs: [0],
      orderBy: '(cashOut - buyIn) ASC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Session.fromMap(result.first);
    }
    return null;
  }

  // Get total hours played (completed sessions only)
  Future<double> getTotalHoursPlayed() async {
    final sessions = await getCompletedSessions();
    double totalHours = 0.0;

    for (var session in sessions) {
      if (session.duration != null) {
        totalHours += session.duration!.inMinutes / 60.0;
      }
    }

    return totalHours;
  }

  // Get overall hourly rate
  Future<double> getOverallHourlyRate() async {
    final totalProfit = await getTotalProfit();
    final totalHours = await getTotalHoursPlayed();

    if (totalHours > 0) {
      return totalProfit / totalHours;
    }
    return 0.0;
  }

  // Get profit by month (for charts)
  Future<Map<String, double>> getProfitByMonth() async {
    final sessions = await getCompletedSessions();
    final Map<String, double> profitByMonth = {};

    for (var session in sessions) {
      final monthKey = '${session.startTime.year}-${session.startTime.month.toString().padLeft(2, '0')}';
      profitByMonth[monthKey] = (profitByMonth[monthKey] ?? 0.0) + session.profit;
    }

    return profitByMonth;
  }

  // Get all unique locations (for filtering)
  Future<List<String>> getAllLocations() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT DISTINCT location FROM sessions ORDER BY location ASC
    ''');
    return result.map((row) => row['location'] as String).toList();
  }

  // Get all unique game types (for filtering)
  Future<List<String>> getAllGameTypes() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT DISTINCT gameType FROM sessions ORDER BY gameType ASC
    ''');
    return result.map((row) => row['gameType'] as String).toList();
  }
}