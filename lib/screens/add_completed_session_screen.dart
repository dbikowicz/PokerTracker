import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../services/database_service.dart';

class AddCompletedSessionScreen extends StatefulWidget {
  const AddCompletedSessionScreen({super.key});

  @override
  State<AddCompletedSessionScreen> createState() => _AddCompletedSessionScreenState();
}

class _AddCompletedSessionScreenState extends State<AddCompletedSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService.instance;

  // Form controllers
  final _buyInController = TextEditingController();
  final _cashOutController = TextEditingController();
  final _notesController = TextEditingController();
  final _stakesController = TextEditingController();
  final _tournamentBuyInController = TextEditingController();
  final _tournamentPositionController = TextEditingController();
  final _totalPlayersController = TextEditingController();

  // Form values
  String _selectedGameType = 'Cash Game';
  String _selectedGameVariant = 'No Limit Hold\'em';
  String _selectedLocation = '';
  DateTime _startDate = DateTime.now().subtract(const Duration(hours: 3));
  TimeOfDay _startTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour - 3);
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = TimeOfDay.now();
  final List<String> _tags = [];

  bool _isSaving = false;

  // Predefined options
  final List<String> _gameTypes = ['Cash Game', 'Tournament', 'Home Game'];
  final List<String> _gameVariants = [
    'No Limit Hold\'em',
    'Pot Limit Omaha',
    'Limit Hold\'em',
    'Mixed Games',
    'Other'
  ];
  final List<String> _commonLocations = [
    'MGM Grand',
    'Bellagio',
    'Aria',
    'Wynn',
    'Caesars Palace',
    'Online - PokerStars',
    'Online - GGPoker',
    'Home Game',
    'Other'
  ];
  final List<String> _availableTags = [
    'loose',
    'tight',
    'aggressive',
    'passive',
    'good-table',
    'tough-table',
    'ran-good',
    'ran-bad',
    'tilted',
    'focused',
  ];

  @override
  void dispose() {
    _buyInController.dispose();
    _cashOutController.dispose();
    _notesController.dispose();
    _stakesController.dispose();
    _tournamentBuyInController.dispose();
    _tournamentPositionController.dispose();
    _totalPlayersController.dispose();
    super.dispose();
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _selectStartDateTime() async {
    DateTime tempDateTime = _combineDateAndTime(_startDate, _startTime);
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              // Header with Cancel and Done
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Select Start Time',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton(
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _startDate = tempDateTime;
                        _startTime = TimeOfDay(hour: tempDateTime.hour, minute: tempDateTime.minute);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              // DateTime Picker
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Brightness.dark,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    use24hFormat: false, // 12-hour format with AM/PM
                    initialDateTime: tempDateTime,
                    minimumDate: DateTime(2020),
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (DateTime newDateTime) {
                      tempDateTime = newDateTime;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectEndDateTime() async {
    DateTime tempDateTime = _combineDateAndTime(_endDate, _endTime);
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              // Header with Cancel and Done
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Select End Time',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton(
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _endDate = tempDateTime;
                        _endTime = TimeOfDay(hour: tempDateTime.hour, minute: tempDateTime.minute);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              // DateTime Picker
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Brightness.dark,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    use24hFormat: false, // 12-hour format with AM/PM
                    initialDateTime: tempDateTime,
                    minimumDate: _combineDateAndTime(_startDate, _startTime),
                    maximumDate: DateTime.now().add(const Duration(hours: 1)),
                    onDateTimeChanged: (DateTime newDateTime) {
                      tempDateTime = newDateTime;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_tags.contains(tag)) {
        _tags.remove(tag);
      } else {
        _tags.add(tag);
      }
    });
  }

  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final startDateTime = _combineDateAndTime(_startDate, _startTime);
      final endDateTime = _combineDateAndTime(_endDate, _endTime);

      if (endDateTime.isBefore(startDateTime)) {
        throw Exception('End time must be after start time');
      }

      final session = Session.createCompleted(
        gameType: _selectedGameType,
        gameVariant: _selectedGameVariant,
        location: _selectedLocation,
        buyIn: double.parse(_buyInController.text),
        cashOut: double.parse(_cashOutController.text),
        startTime: startDateTime,
        endTime: endDateTime,
        stakes: _stakesController.text.isNotEmpty ? _stakesController.text : null,
        tournamentBuyIn: _tournamentBuyInController.text.isNotEmpty
            ? int.parse(_tournamentBuyInController.text)
            : null,
        tournamentPosition: _tournamentPositionController.text.isNotEmpty
            ? int.parse(_tournamentPositionController.text)
            : null,
        totalPlayers: _totalPlayersController.text.isNotEmpty
            ? int.parse(_totalPlayersController.text)
            : null,
        notes: _notesController.text,
        tags: _tags,
      );

      await _db.createSession(session);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session saved! Profit: \$${session.profit.toStringAsFixed(2)}'),
          backgroundColor: session.profit >= 0 ? Colors.green : Colors.red,
        ),
      );

      // Go back to previous screen
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profit = (_cashOutController.text.isNotEmpty && _buyInController.text.isNotEmpty)
        ? double.tryParse(_cashOutController.text)! - double.tryParse(_buyInController.text)!
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Completed Session'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveSession,
              tooltip: 'Save Session',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Game Type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Game Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGameType,
                      decoration: const InputDecoration(
                        labelText: 'Game Type',
                        prefixIcon: Icon(Icons.casino),
                      ),
                      items: _gameTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGameType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGameVariant,
                      decoration: const InputDecoration(
                        labelText: 'Game Variant',
                        prefixIcon: Icon(Icons.style),
                      ),
                      items: _gameVariants.map((variant) {
                        return DropdownMenuItem(value: variant, child: Text(variant));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGameVariant = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedLocation.isEmpty ? null : _selectedLocation,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      hint: const Text('Select location'),
                      items: _commonLocations.map((location) {
                        return DropdownMenuItem(value: location, child: Text(location));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLocation = value!;
                        });
                      },
                    ),
                    if (_selectedGameType == 'Cash Game') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _stakesController,
                        decoration: const InputDecoration(
                          labelText: 'Stakes (optional)',
                          hintText: 'e.g., 1/2, 2/5, 5/10',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Buy-in and Cash-out
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Money',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _buyInController,
                      decoration: const InputDecoration(
                        labelText: 'Buy-in',
                        prefixIcon: Icon(Icons.login),
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter buy-in amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cashOutController,
                      decoration: const InputDecoration(
                        labelText: 'Cash-out',
                        prefixIcon: Icon(Icons.logout),
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter cash-out amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: profit >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: profit >= 0 ? Colors.green : Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profit/Loss:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${profit.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: profit >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tournament Fields
            if (_selectedGameType == 'Tournament') ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tournament Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tournamentBuyInController,
                        decoration: const InputDecoration(
                          labelText: 'Tournament Buy-in',
                          prefixIcon: Icon(Icons.attach_money),
                          prefixText: '\$ ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tournamentPositionController,
                        decoration: const InputDecoration(
                          labelText: 'Finish Position',
                          hintText: 'e.g., 1, 2, 3',
                          prefixIcon: Icon(Icons.emoji_events),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _totalPlayersController,
                        decoration: const InputDecoration(
                          labelText: 'Total Players',
                          hintText: 'e.g., 120',
                          prefixIcon: Icon(Icons.people),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Date and Time
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session Time',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Start DateTime
                    OutlinedButton(
                      onPressed: _selectStartDateTime,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.play_arrow),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Start',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                '${DateFormat('MMM d, yyyy').format(_startDate)} at ${_startTime.format(context)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // End DateTime
                    OutlinedButton(
                      onPressed: _selectEndDateTime,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stop),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'End',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                '${DateFormat('MMM d, yyyy').format(_endDate)} at ${_endTime.format(context)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tags
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tags (optional)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTags.map((tag) {
                        final isSelected = _tags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (_) => _toggleTag(tag),
                          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes (optional)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Add notes about this session...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveSession,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Session', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}