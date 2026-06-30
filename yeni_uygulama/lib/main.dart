import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'gen_l10n/app_localizations.dart';
import 'screens/ai_chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lunora',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? _selectedDate;
  int _cycleLength = 28;
  DateTime? _nextCycle;
  List<DateTime> _cycleDates = [];
  final Map<String, String> _cycleNotes = {}; // dateStr -> notes
  final Map<String, String> _cycleMood = {}; // dateStr -> mood
  int _selectedTabIndex = 0;
  int _waterCount = 0;
  int _waterGoal = 8;
  String? _waterDateKey;
  Timer? _breathingTimer;
  bool _breathingActive = false;
  int _breathingPhaseIndex = 0;
  int _breathingSecond = 0;
  late final TextEditingController _cycleLengthController;

  @override
  void initState() {
    _cycleLengthController = TextEditingController(text: '28');
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _breathingTimer?.cancel();
    _cycleLengthController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final millis = prefs.getInt('selectedDate');
      final cycle = prefs.getInt('cycleLength');
      final cycleDatesStr = prefs.getStringList('cycleDates') ?? [];
      final waterCount = prefs.getInt('waterCount') ?? 0;
      final waterGoal = prefs.getInt('waterGoal') ?? 8;
      final waterDateKey = prefs.getString('waterDateKey');
      final todayKey = _todayKey();

      if (millis != null) {
        setState(() {
          _selectedDate = DateTime.fromMillisecondsSinceEpoch(millis);
        });
      }
      if (cycle != null) {
        setState(() {
          _cycleLength = cycle;
          _cycleLengthController.text = '$_cycleLength';
        });
      }
      if (cycleDatesStr.isNotEmpty) {
        setState(() {
          _cycleDates = cycleDatesStr
              .map((s) => DateTime.fromMillisecondsSinceEpoch(int.parse(s)))
              .toList();
        });
      }
      final notesMap = prefs.getStringList('cycleNotesKeys') ?? [];
      if (notesMap.isNotEmpty) {
        setState(() {
          for (var key in notesMap) {
            _cycleNotes[key] = prefs.getString('cycleNote_$key') ?? '';
          }
        });
      }
      final moodKeys = prefs.getStringList('cycleMoodKeys') ?? [];
      if (moodKeys.isNotEmpty) {
        setState(() {
          for (var key in moodKeys) {
            _cycleMood[key] = prefs.getString('cycleMood_$key') ?? '😐';
          }
        });
      }
      if (_selectedDate != null) {
        setState(() {
          _nextCycle = _selectedDate!.add(Duration(days: _cycleLength));
        });
      }
      setState(() {
        _waterGoal = waterGoal;
        if (waterDateKey != todayKey) {
          _waterDateKey = todayKey;
          _waterCount = 0;
        } else {
          _waterDateKey = waterDateKey;
          _waterCount = waterCount;
        }
      });
    } catch (e) {
      // ignore errors silently
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedDate != null) {
      await prefs.setInt('selectedDate', _selectedDate!.millisecondsSinceEpoch);
    }
    await prefs.setInt('cycleLength', _cycleLength);
    await prefs.setStringList(
      'cycleDates',
      _cycleDates.map((d) => d.millisecondsSinceEpoch.toString()).toList(),
    );
    // Save notes
    await prefs.setStringList('cycleNotesKeys', _cycleNotes.keys.toList());
    for (var key in _cycleNotes.keys) {
      await prefs.setString('cycleNote_$key', _cycleNotes[key] ?? '');
    }
    // Save mood
    await prefs.setStringList('cycleMoodKeys', _cycleMood.keys.toList());
    for (var key in _cycleMood.keys) {
      await prefs.setString('cycleMood_$key', _cycleMood[key] ?? '😐');
    }
    // Save water reminder
    await prefs.setInt('waterCount', _waterCount);
    await prefs.setInt('waterGoal', _waterGoal);
    await prefs.setString('waterDateKey', _waterDateKey ?? _todayKey());
  }

  // Helpers
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
  String _todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _nextCycle = _selectedDate!.add(Duration(days: _cycleLength));
      });
      await _savePreferences();
    }
  }

  void _calculateNextCycle() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectDate)));
      return;
    }

    try {
      _cycleLength = int.parse(_cycleLengthController.text);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterValidNumber)));
      return;
    }

    setState(() {
      _nextCycle = _selectedDate!.add(Duration(days: _cycleLength));
      // Add to history if not already present
      if (!_cycleDates.any(
        (d) => _normalize(d) == _normalize(_selectedDate!),
      )) {
        _cycleDates.add(_selectedDate!);
        _cycleDates.sort();
      }
    });
    await _savePreferences();
  }

  // Statistics
  double _getAverageCycleLength() {
    if (_cycleDates.length < 2) return _cycleLength.toDouble();
    List<int> lengths = [];
    for (int i = 0; i < _cycleDates.length - 1; i++) {
      lengths.add(_cycleDates[i + 1].difference(_cycleDates[i]).inDays);
    }
    return lengths.isEmpty
        ? _cycleLength.toDouble()
        : lengths.reduce((a, b) => a + b) / lengths.length;
  }

  int _getCycleVariation() {
    if (_cycleDates.length < 2) return 0;
    List<int> lengths = [];
    for (int i = 0; i < _cycleDates.length - 1; i++) {
      lengths.add(_cycleDates[i + 1].difference(_cycleDates[i]).inDays);
    }
    if (lengths.isEmpty) return 0;
    int maxLen = lengths.reduce((a, b) => a > b ? a : b);
    int minLen = lengths.reduce((a, b) => a < b ? a : b);
    return maxLen - minLen;
  }

  int _getCurrentCycleDay() {
    if (_selectedDate == null || _cycleLength <= 0) return 0;
    final normalizedNow = _normalize(DateTime.now());
    final normalizedStart = _normalize(_selectedDate!);
    final diff = normalizedNow.difference(normalizedStart).inDays;
    if (diff < 0) return 1;
    return (diff % _cycleLength) + 1;
  }

  double _getCycleProgress() {
    if (_selectedDate == null || _cycleLength <= 0) return 0;
    return _getCurrentCycleDay() / _cycleLength;
  }

  void _incrementWater() {
    setState(() {
      if (_waterDateKey != _todayKey()) {
        _waterDateKey = _todayKey();
        _waterCount = 0;
      }
      if (_waterCount < _waterGoal) {
        _waterCount += 1;
      }
    });
    _savePreferences();
  }

  void _resetWater() {
    setState(() {
      _waterDateKey = _todayKey();
      _waterCount = 0;
    });
    _savePreferences();
  }

  void _startBreathing() {
    _breathingTimer?.cancel();
    setState(() {
      _breathingActive = true;
      _breathingPhaseIndex = 0;
      _breathingSecond = 0;
    });
    _breathingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _breathingSecond += 1;
        if (_breathingSecond >=
            _breathingPhaseDurations[_breathingPhaseIndex]) {
          _breathingSecond = 0;
          _breathingPhaseIndex =
              (_breathingPhaseIndex + 1) % _breathingPhaseDurations.length;
        }
      });
    });
  }

  void _stopBreathing() {
    _breathingTimer?.cancel();
    setState(() {
      _breathingActive = false;
      _breathingPhaseIndex = 0;
      _breathingSecond = 0;
    });
  }

  static const List<int> _breathingPhaseDurations = [4, 4, 4];

  String _breathingPhaseLabel(AppLocalizations l10n) {
    switch (_breathingPhaseIndex) {
      case 0:
        return l10n.breatheIn;
      case 1:
        return l10n.breatheHold;
      default:
        return l10n.breatheOut;
    }
  }

  int _breathingPhaseRemaining() {
    return _breathingPhaseDurations[_breathingPhaseIndex] - _breathingSecond;
  }

  String _buildAiContext(AppLocalizations l10n) {
    final parts = <String>[];
    final localeName = l10n.localeName;
    if (_selectedDate != null) {
      final ovulationStart = DateFormat.yMMMd(
        localeName,
      ).format(_selectedDate!.add(Duration(days: _cycleLength - 14)));
      parts.add('Ovulasyon Tahmini Başlangıcı: $ovulationStart');
    }
    if (_nextCycle != null) {
      final next = DateFormat.yMMMd(localeName).format(_nextCycle!);
      parts.add('${l10n.nextCycle}: $next');
    }
    parts.add('${l10n.cycleDays}: $_cycleLength');
    parts.add(
      '${l10n.averageLength}: ${_getAverageCycleLength().toStringAsFixed(1)}',
    );
    if (_selectedDate != null) {
      final key = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final mood = _cycleMood[key];
      final note = _cycleNotes[key];
      if (mood != null && mood.isNotEmpty) {
        parts.add('${l10n.mood}: $mood');
      }
      if (note != null && note.isNotEmpty) {
        parts.add('${l10n.symptoms}: $note');
      }
    }
    return parts.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final Widget overviewTab = ListView(
      children: [
        Card(
          color: Colors.pink.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Regl Günü Sayacı',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 170,
                  height: 170,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(170, 170),
                        painter: _DashedCirclePainter(
                          color: Colors.black,
                          strokeWidth: 1.8,
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: _getCycleProgress(),
                          strokeWidth: 8,
                          backgroundColor: Colors.white,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.pink,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.pink.shade50,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                                width: 1.8,
                              ),
                            ),
                            child: const Icon(
                              Icons.water_drop_outlined,
                              color: Colors.pinkAccent,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gün ${_getCurrentCycleDay()}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedDate != null)
                            Text(
                              '/$_cycleLength',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _selectDate,
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Colors.pink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedDate != null
                            ? '${l10n.selected}: ${DateFormat.yMMMd('tr').format(_selectedDate!)}'
                            : l10n.tapToSelect,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                if (_selectedDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '🌸 Ovulasyon Dönemi: ${DateFormat('d/M/y').format(_selectedDate!.add(Duration(days: _cycleLength - 14)))}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '💚 Doğurganlık Dönemi: ${DateFormat('d/M/y').format(_selectedDate!.add(Duration(days: _cycleLength - 14)).subtract(const Duration(days: 5)))} - ${DateFormat('d/M/y').format(_selectedDate!.add(Duration(days: _cycleLength - 14)).add(const Duration(days: 1)))}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          color: Colors.pink.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📊 ${l10n.statistics}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.registeredCycles}:',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${_cycleDates.length}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.averageLength}:',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${_getAverageCycleLength().toStringAsFixed(1)} ${l10n.cycleDays}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _cycleLength,
                            isDense: true,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _cycleLength = value;
                                _cycleLengthController.text = '$_cycleLength';
                                if (_selectedDate != null) {
                                  _nextCycle = _selectedDate!.add(
                                    Duration(days: _cycleLength),
                                  );
                                }
                              });
                              _savePreferences();
                            },
                            items: List.generate(30, (index) => index + 1)
                                .map(
                                  (day) => DropdownMenuItem<int>(
                                    value: day,
                                    child: Text('Regl: $day'),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.regularity}:',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '±${_getCycleVariation()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _calculateNextCycle,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.pink,
          ),
          child: Text(
            '✅ ${l10n.calculate}',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 24),
        if (_nextCycle != null)
          Card(
            color: Colors.pink.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '📊 ${l10n.result}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ovulasyon Tahmini Başlangıcı${l10n.cycleSeparator}\n${DateFormat('d/M/y').format(_selectedDate!.add(Duration(days: _cycleLength - 14)))}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${l10n.nextCycle}${l10n.cycleSeparator}\n${_nextCycle!.day}/${_nextCycle!.month}/${_nextCycle!.year}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Regl Uzunluğu${l10n.cycleSeparator} $_cycleLength ${l10n.cycleDays}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '💚 Doğurganlık Dönemi\n${DateFormat('d/M/y').format(_selectedDate!.add(Duration(days: _cycleLength - 14)).subtract(const Duration(days: 5)))} - ${DateFormat('d/M/y').format(_selectedDate!.add(Duration(days: _cycleLength - 14)).add(const Duration(days: 1)))}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        Card(
          color: Colors.pink.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎭 ${l10n.mood}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [
                              l10n.happy,
                              l10n.energetic,
                              l10n.normal,
                              l10n.sad,
                              l10n.stressed,
                              l10n.tired,
                            ]
                            .map(
                              (mood) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (_selectedDate != null) {
                                        final key = DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(_selectedDate!);
                                        _cycleMood[key] = mood.split(' ')[1];
                                      }
                                    });
                                    _savePreferences();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _selectedDate != null &&
                                            _cycleMood[DateFormat(
                                                  'yyyy-MM-dd',
                                                ).format(_selectedDate!)] ==
                                                mood.split(' ')[1]
                                        ? Colors.orange
                                        : Colors.grey[300],
                                  ),
                                  child: Text(
                                    mood,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final Widget exercisesTab = ListView(
      children: [
        Card(
          color: Colors.pink.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📝 ${l10n.symptoms}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: l10n.typeSymptoms,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 6,
                  onChanged: (val) {
                    if (_selectedDate != null) {
                      final key = DateFormat(
                        'yyyy-MM-dd',
                      ).format(_selectedDate!);
                      _cycleNotes[key] = val;
                    }
                  },
                  controller: TextEditingController(
                    text: _selectedDate != null
                        ? (_cycleNotes[DateFormat(
                                'yyyy-MM-dd',
                              ).format(_selectedDate!)] ??
                              '')
                        : '',
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (_selectedDate != null) {
                      await _savePreferences();
                      if (!mounted) return;
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(l10n.saved)));
                    }
                  },
                  child: Text('💾 ${l10n.save}'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          color: Colors.pink.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💧 ${l10n.waterReminder}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${l10n.waterGoal}: $_waterGoal ${l10n.glasses}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_waterCount/$_waterGoal ${l10n.glasses}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _incrementWater,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                      ),
                      child: Text(
                        l10n.addGlass,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _resetWater,
                      child: Text(l10n.reset),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          color: Colors.pink.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🫁 ${l10n.breathingTitle}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.breathingSubtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Text(
                  _breathingActive
                      ? '${_breathingPhaseLabel(l10n)} • ${_breathingPhaseRemaining()} ${l10n.seconds}'
                      : l10n.breathingReady,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _breathingActive
                          ? _stopBreathing
                          : _startBreathing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                      ),
                      child: Text(
                        _breathingActive ? l10n.stop : l10n.start,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _breathingActive ? null : _startBreathing,
                      child: Text(l10n.restart),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final Widget body = _selectedTabIndex == 2
        ? AiChatScreen(contextSummary: _buildAiContext(l10n), showAppBar: false)
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: _selectedTabIndex == 0 ? overviewTab : exercisesTab,
          );

    return Scaffold(
      appBar: AppBar(title: const SizedBox.shrink(), centerTitle: true),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            label: l10n.overviewTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.note_alt_outlined),
            label: l10n.notesTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            label: l10n.horuTab,
          ),
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - strokeWidth;
    const dashCount = 48;
    const gapFactor = 0.45;
    final full = 2 * math.pi;
    final dashSweep = (full / dashCount) * (1 - gapFactor);

    for (int i = 0; i < dashCount; i++) {
      final start = (full / dashCount) * i;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        dashSweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
