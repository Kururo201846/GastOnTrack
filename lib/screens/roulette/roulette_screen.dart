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
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (lastDate != null) {
      final lastPlayDate = DateTime.parse(lastDate);
      final lastPlayDay = DateTime(lastPlayDate.year, lastPlayDate.month, lastPlayDate.day);
      
      if (today.isAfter(lastPlayDay)) {
        _attemptsLeft = 3;
        await prefs.setInt('attemptsLeft', 3);
      } else {
        _attemptsLeft = savedAttempts;
      }
    }
    
    setState(() {});
  }

  Future<void> _saveAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('lastPlayDate', now.toIso8601String());
    await prefs.setInt('attemptsLeft', _attemptsLeft);
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
      
      final votes = {'SÍ': 0, 'NO': 0};
      for (var pos in _finalPositions) {
        votes[_options[pos]] = votes[_options[pos]]! + 1;
      }
      
      setState(() {
        if (votes['SÍ']! > votes['NO']!) {
          _result = 'SÍ';
        } else if (votes['NO']! > votes['SÍ']!) {
          _result = 'NO';
        } else {
          _result = _options[_random.nextInt(2)];
        }
        _isSpinning = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: Center(
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
    );
  }
}