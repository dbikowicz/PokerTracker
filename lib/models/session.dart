import 'package:uuid/uuid.dart';

class Session {
  final String id;
  final String gameType; // 'Cash Game', 'Tournament', 'Home Game'
  final String gameVariant; // 'No Limit Hold\'em', 'Pot Limit Omaha', etc.
  final String location; // 'MGM Grand', 'Online - PokerStars', 'Home'
  final double buyIn;
  final double cashOut;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isLive; // true if session is currently active
  final String? stakes; // '1/2', '2/5', '5/10', etc. for cash games
  final int? tournamentBuyIn; // for tournaments
  final int? tournamentPosition; // finishing position in tournament
  final int? totalPlayers; // total players in tournament
  final String notes;
  final List<String> tags; // ['loose', 'aggressive', 'good table']

  Session({
    required this.id,
    required this.gameType,
    required this.gameVariant,
    required this.location,
    required this.buyIn,
    required this.cashOut,
    required this.startTime,
    this.endTime,
    required this.isLive,
    this.stakes,
    this.tournamentBuyIn,
    this.tournamentPosition,
    this.totalPlayers,
    this.notes = '',
    this.tags = const [],
  });

  // Computed property: profit/loss
  double get profit => cashOut - buyIn;

  // Computed property: duration (if session has ended)
  Duration? get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }

  // Computed property: current duration (for live sessions)
  Duration get currentDuration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  // Computed property: hourly rate (if session has ended)
  double? get hourlyRate {
    final dur = duration;
    if (dur != null && dur.inMinutes > 0) {
      return profit / (dur.inMinutes / 60.0);
    }
    return null;
  }

  // Computed property: ROI for tournaments
  double? get roi {
    if (tournamentBuyIn != null && tournamentBuyIn! > 0) {
      return ((cashOut - tournamentBuyIn!) / tournamentBuyIn!) * 100;
    }
    return null;
  }

  // Factory constructor for creating a new live session
  factory Session.createLive({
    required String gameType,
    required String gameVariant,
    required String location,
    required double buyIn,
    String? stakes,
    int? tournamentBuyIn,
    int? totalPlayers,
    String notes = '',
    List<String> tags = const [],
  }) {
    return Session(
      id: const Uuid().v4(),
      gameType: gameType,
      gameVariant: gameVariant,
      location: location,
      buyIn: buyIn,
      cashOut: 0.0, // Will be updated when session ends
      startTime: DateTime.now(),
      endTime: null,
      isLive: true,
      stakes: stakes,
      tournamentBuyIn: tournamentBuyIn,
      totalPlayers: totalPlayers,
      notes: notes,
      tags: tags,
    );
  }

  // Factory constructor for creating a completed session
  factory Session.createCompleted({
    required String gameType,
    required String gameVariant,
    required String location,
    required double buyIn,
    required double cashOut,
    required DateTime startTime,
    required DateTime endTime,
    String? stakes,
    int? tournamentBuyIn,
    int? tournamentPosition,
    int? totalPlayers,
    String notes = '',
    List<String> tags = const [],
  }) {
    return Session(
      id: const Uuid().v4(),
      gameType: gameType,
      gameVariant: gameVariant,
      location: location,
      buyIn: buyIn,
      cashOut: cashOut,
      startTime: startTime,
      endTime: endTime,
      isLive: false,
      stakes: stakes,
      tournamentBuyIn: tournamentBuyIn,
      tournamentPosition: tournamentPosition,
      totalPlayers: totalPlayers,
      notes: notes,
      tags: tags,
    );
  }

  // Copy with method for updating sessions
  Session copyWith({
    String? id,
    String? gameType,
    String? gameVariant,
    String? location,
    double? buyIn,
    double? cashOut,
    DateTime? startTime,
    DateTime? endTime,
    bool? isLive,
    String? stakes,
    int? tournamentBuyIn,
    int? tournamentPosition,
    int? totalPlayers,
    String? notes,
    List<String>? tags,
  }) {
    return Session(
      id: id ?? this.id,
      gameType: gameType ?? this.gameType,
      gameVariant: gameVariant ?? this.gameVariant,
      location: location ?? this.location,
      buyIn: buyIn ?? this.buyIn,
      cashOut: cashOut ?? this.cashOut,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isLive: isLive ?? this.isLive,
      stakes: stakes ?? this.stakes,
      tournamentBuyIn: tournamentBuyIn ?? this.tournamentBuyIn,
      tournamentPosition: tournamentPosition ?? this.tournamentPosition,
      totalPlayers: totalPlayers ?? this.totalPlayers,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameType': gameType,
      'gameVariant': gameVariant,
      'location': location,
      'buyIn': buyIn,
      'cashOut': cashOut,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isLive': isLive ? 1 : 0,
      'stakes': stakes,
      'tournamentBuyIn': tournamentBuyIn,
      'tournamentPosition': tournamentPosition,
      'totalPlayers': totalPlayers,
      'notes': notes,
      'tags': tags.join(','), // Store as comma-separated string
    };
  }

  // Create Session from Map (from database)
  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as String,
      gameType: map['gameType'] as String,
      gameVariant: map['gameVariant'] as String,
      location: map['location'] as String,
      buyIn: map['buyIn'] as double,
      cashOut: map['cashOut'] as double,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
      isLive: map['isLive'] == 1,
      stakes: map['stakes'] as String?,
      tournamentBuyIn: map['tournamentBuyIn'] as int?,
      tournamentPosition: map['tournamentPosition'] as int?,
      totalPlayers: map['totalPlayers'] as int?,
      notes: map['notes'] as String? ?? '',
      tags: map['tags'] != null && (map['tags'] as String).isNotEmpty
          ? (map['tags'] as String).split(',')
          : [],
    );
  }

  // Convert to JSON for API/backup
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameType': gameType,
      'gameVariant': gameVariant,
      'location': location,
      'buyIn': buyIn,
      'cashOut': cashOut,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isLive': isLive,
      'stakes': stakes,
      'tournamentBuyIn': tournamentBuyIn,
      'tournamentPosition': tournamentPosition,
      'totalPlayers': totalPlayers,
      'notes': notes,
      'tags': tags,
    };
  }

  // Create Session from JSON
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      gameType: json['gameType'] as String,
      gameVariant: json['gameVariant'] as String,
      location: json['location'] as String,
      buyIn: (json['buyIn'] as num).toDouble(),
      cashOut: (json['cashOut'] as num).toDouble(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      isLive: json['isLive'] as bool,
      stakes: json['stakes'] as String?,
      tournamentBuyIn: json['tournamentBuyIn'] as int?,
      tournamentPosition: json['tournamentPosition'] as int?,
      totalPlayers: json['totalPlayers'] as int?,
      notes: json['notes'] as String? ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
    );
  }

  @override
  String toString() {
    return 'Session(id: $id, gameType: $gameType, location: $location, profit: \$${profit.toStringAsFixed(2)}, isLive: $isLive)';
  }
}