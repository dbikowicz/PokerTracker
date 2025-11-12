import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/database_service.dart';

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<Session> _sessions = [];
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading sessions...';
    });

    try {
      final sessions = await _db.getAllSessions();
      setState(() {
        _sessions = sessions;
        _statusMessage = 'Loaded ${sessions.length} sessions';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading sessions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addTestSessions() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Adding test sessions...';
    });

    try {
      // Test Session 1: Completed Cash Game (Win)
      final session1 = Session.createCompleted(
        gameType: 'Cash Game',
        gameVariant: 'No Limit Hold\'em',
        location: 'MGM Grand',
        buyIn: 200.0,
        cashOut: 450.0,
        startTime: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        endTime: DateTime.now().subtract(const Duration(days: 2)),
        stakes: '1/2',
        notes: 'Great table! Very loose players.',
        tags: ['loose', 'profitable'],
      );
      await _db.createSession(session1);

      // Test Session 2: Completed Cash Game (Loss)
      final session2 = Session.createCompleted(
        gameType: 'Cash Game',
        gameVariant: 'No Limit Hold\'em',
        location: 'Bellagio',
        buyIn: 500.0,
        cashOut: 350.0,
        startTime: DateTime.now().subtract(const Duration(days: 5, hours: 4)),
        endTime: DateTime.now().subtract(const Duration(days: 5, hours: 1)),
        stakes: '2/5',
        notes: 'Tough table, ran bad.',
        tags: ['tough', 'bad-beats'],
      );
      await _db.createSession(session2);

      // Test Session 3: Live Session
      final session3 = Session.createLive(
        gameType: 'Cash Game',
        gameVariant: 'Pot Limit Omaha',
        location: 'Aria',
        buyIn: 300.0,
        stakes: '1/3',
        notes: 'Currently playing...',
        tags: ['live'],
      );
      await _db.createSession(session3);

      // Test Session 4: Completed Tournament
      final session4 = Session.createCompleted(
        gameType: 'Tournament',
        gameVariant: 'No Limit Hold\'em',
        location: 'Wynn',
        buyIn: 150.0,
        cashOut: 850.0,
        startTime: DateTime.now().subtract(const Duration(days: 7, hours: 6)),
        endTime: DateTime.now().subtract(const Duration(days: 7)),
        tournamentBuyIn: 150,
        tournamentPosition: 3,
        totalPlayers: 120,
        notes: 'Finished 3rd place!',
        tags: ['tournament', 'deep-run'],
      );
      await _db.createSession(session4);

      // Test Session 5: Home Game
      final session5 = Session.createCompleted(
        gameType: 'Home Game',
        gameVariant: 'No Limit Hold\'em',
        location: 'John\'s House',
        buyIn: 50.0,
        cashOut: 125.0,
        startTime: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        endTime: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
        stakes: '0.25/0.50',
        notes: 'Fun night with friends.',
        tags: ['home-game', 'social'],
      );
      await _db.createSession(session5);

      setState(() {
        _statusMessage = 'Added 5 test sessions successfully!';
      });

      await _loadSessions();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error adding test sessions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showStatistics() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Calculating statistics...';
    });

    try {
      final totalProfit = await _db.getTotalProfit();
      final totalSessions = await _db.getTotalSessionCount();
      final completedSessions = await _db.getCompletedSessionCount();
      final winRate = await _db.getWinRate();
      final avgProfit = await _db.getAverageProfitPerSession();
      final totalHours = await _db.getTotalHoursPlayed();
      final hourlyRate = await _db.getOverallHourlyRate();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Statistics'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Sessions: $totalSessions'),
                Text('Completed Sessions: $completedSessions'),
                const SizedBox(height: 8),
                Text('Total Profit: \$${totalProfit.toStringAsFixed(2)}'),
                Text('Average Profit: \$${avgProfit.toStringAsFixed(2)}'),
                Text('Win Rate: ${winRate.toStringAsFixed(1)}%'),
                const SizedBox(height: 8),
                Text('Total Hours: ${totalHours.toStringAsFixed(1)}h'),
                Text('Hourly Rate: \$${hourlyRate.toStringAsFixed(2)}/hr'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );

      setState(() {
        _statusMessage = 'Statistics calculated';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error calculating statistics: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAllSessions() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Sessions?'),
        content: const Text('This will permanently delete all sessions. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Deleting all sessions...';
      });

      try {
        await _db.deleteAllSessions();
        setState(() {
          _statusMessage = 'All sessions deleted';
        });
        await _loadSessions();
      } catch (e) {
        setState(() {
          _statusMessage = 'Error deleting sessions: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _addTestSessions,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Test Data'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _showStatistics,
                        icon: const Icon(Icons.analytics),
                        label: const Text('Show Stats'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _deleteAllSessions,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Delete All Sessions'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Sessions List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sessions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No sessions in database',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap "Add Test Data" to create test sessions',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _sessions.length,
                        itemBuilder: (context, index) {
                          final session = _sessions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: session.profit >= 0
                                    ? Colors.green
                                    : Colors.red,
                                child: Icon(
                                  session.isLive
                                      ? Icons.play_arrow
                                      : session.profit >= 0
                                          ? Icons.trending_up
                                          : Icons.trending_down,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                '${session.gameType} - ${session.gameVariant}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(session.location),
                                  Text(
                                    session.isLive
                                        ? 'LIVE - Buy-in: \$${session.buyIn.toStringAsFixed(2)}'
                                        : 'Profit: \$${session.profit.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: session.isLive
                                          ? Colors.orange
                                          : session.profit >= 0
                                              ? Colors.green
                                              : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: session.isLive
                                  ? const Chip(
                                      label: Text('LIVE'),
                                      backgroundColor: Colors.orange,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}