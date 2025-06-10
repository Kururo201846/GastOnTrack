import 'package:flutter/material.dart';
import 'package:gast_on_track/themes/app_theme.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class RouletteScreen extends StatefulWidget {
  const RouletteScreen({super.key});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> {
  final List<String> _options = ['SI', 'NO'];
  String _result = '';
  bool _isSpinning = false;
  late List<ScrollController> _rollers;
  final Random _random = Random();
  final List<int> _finalPositions = [0, 0, 0];
  Timer? _spinTimer;
  int _attemptsLeft = 3;
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _rollers = List.generate(3, (_) => ScrollController());
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('lastPlayDate');
    final savedAttempts = prefs.getInt('attemptsLeft') ?? 3;
    final savedHistory = prefs.getStringList('rouletteHistory') ?? [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastDate != null) {
      final lastPlayDate = DateTime.parse(lastDate);
      final lastPlayDay = DateTime(lastPlayDate.year, lastPlayDate.month, lastPlayDate.day);

      if (today.isAfter(lastPlayDay)) {
        _attemptsLeft = 3;
        _history.clear();
        await prefs.setInt('attemptsLeft', 3);
        await prefs.setStringList('rouletteHistory', []);
      } else {
        _attemptsLeft = savedAttempts;
        _history.clear();
        _history.addAll(savedHistory);
      }
    } else {
      _attemptsLeft = 3;
      _history.clear();
      await prefs.setInt('attemptsLeft', 3);
      await prefs.setStringList('rouletteHistory', []);
    }

    setState(() {});
  }

  Future<void> _saveAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('lastPlayDate', now.toIso8601String());
    await prefs.setInt('attemptsLeft', _attemptsLeft);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('rouletteHistory', _history);
  }

  @override
  void dispose() {
    _spinTimer?.cancel();
    for (var roller in _rollers) {
      roller.dispose();
    }
    super.dispose();
  }

  void _spin() async {
    if (_isSpinning || _attemptsLeft <= 0) return;

    setState(() {
      _isSpinning = true;
      _result = '';
      _attemptsLeft--;
    });

    await _saveAttempts();

    for (var controller in _rollers) {
      controller.jumpTo(0);
    }

    for (int i = 0; i < _rollers.length; i++) {
      _finalPositions[i] = _random.nextInt(_options.length);
    }

    final animations = <Future>[];
    for (var i = 0; i < _rollers.length; i++) {
      if (!mounted) return;
      animations.add(_animateRoller(i));
      await Future.delayed(Duration(milliseconds: 200 * i));
    }

    await Future.wait(animations);

    if (!mounted) return;

    _spinTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      final votes = {'SI': 0, 'NO': 0};
      for (var pos in _finalPositions) {
        votes[_options[pos]] = votes[_options[pos]]! + 1;
      }

      String result;
      if (votes['SI']! > votes['NO']!) {
        result = 'SI';
      } else if (votes['NO']! > votes['SI']!) {
        result = 'NO';
      } else {
        result = (_random.nextDouble() < 0.6) ? 'NO' : 'SI';
      }

      setState(() {
        _result = result;
        _isSpinning = false;
        _history.insert(0, "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} - $result");
      });
      _saveHistory();
    });
  }

  Future<void> _animateRoller(int index) async {
    const spinDuration = Duration(seconds: 1);
    const itemHeight = 80.0;
    const extraSpins = 5;
    
    final targetPosition = _finalPositions[index] + (_options.length * extraSpins);
    
    await _rollers[index].animateTo(
      targetPosition * itemHeight,
      duration: spinDuration,
      curve: Curves.decelerate,
    );
  }

  Widget _buildRoller(ScrollController controller, int rollerIndex) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.textSecondary),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListView.builder(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        itemExtent: 80,
        itemBuilder: (context, index) {
          final option = _options[index % _options.length];
          return Container(
            color: index % 2 == 0 ? AppTheme.cream : AppTheme.white,
            alignment: Alignment.center,
            child: Text(
              option,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _isSpinning && index % _options.length == _finalPositions[rollerIndex] 
                    ? Colors.black 
                    : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cómo funciona la ruleta?'),
        content: const Text(
          'La ruleta te ayuda a decidir si puedes gastar en un capricho hoy.\n\n'
          'Si sale "SI", ¡puedes darte un gusto!\n'
          'Si sale "NO", mejor espera para la próxima.\n\n'
          'Tienes 3 intentos diarios.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Intentos: $_attemptsLeft/3',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _showInfoDialog,
                  child: Tooltip(
                    message: '¿Cómo funciona?',
                    child: Icon(Icons.info_outline, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
                      width: 400,
                      height: 230,
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadows,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < _rollers.length; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: _buildRoller(_rollers[i], i),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: 100,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.cream,
                              border: Border.all(color: AppTheme.textSecondary),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              _result,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: (_isSpinning || _attemptsLeft <= 0) ? null : _spin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        backgroundColor: _attemptsLeft <= 0 ? AppTheme.white : Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        _attemptsLeft <= 0 ? 'INTENTOS AGOTADOS' : 'JUGAR',
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_attemptsLeft <= 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'Vuelve mañana',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadows.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.history, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Historial de decisiones',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _history.isEmpty
                      ? const Text(
                          'Aún no hay decisiones registradas.',
                          style: TextStyle(color: Colors.grey),
                        )
                      : SizedBox(
                          height: 100,
                          child: ListView.builder(
                            itemCount: _history.length,
                            itemBuilder: (context, index) {
                              final entry = _history[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      entry.contains('SI') ? Icons.check_circle : Icons.cancel,
                                      color: entry.contains('SI') ? Colors.green : Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      entry,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}