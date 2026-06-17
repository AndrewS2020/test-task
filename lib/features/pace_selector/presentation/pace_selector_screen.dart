import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaceSelectorScreen extends StatefulWidget {
  const PaceSelectorScreen({super.key});

  @override
  State<PaceSelectorScreen> createState() => _PaceSelectorScreenState();
}

class _PaceSelectorScreenState extends State<PaceSelectorScreen> {
  int _minutes = 1;
  int _seconds = 30;
  double _sliderValue = 90.0;
  bool _isLoading = false;

  static const Map<String, _LevelRange> _levelRanges = {
    'Elite': _LevelRange(0, 59),
    'Advanced': _LevelRange(60, 89),
    'Intermediate': _LevelRange(90, 119),
    'Beginner': _LevelRange(120, 600),
  };

  String get swimmerLevel {
    final totalSeconds = (_minutes * 60) + _seconds;
    for (final entry in _levelRanges.entries) {
      if (totalSeconds >= entry.value.min && totalSeconds <= entry.value.max) {
        return entry.key;
      }
    }
    return 'Beginner';
  }

  Color get levelColor {
    switch (swimmerLevel) {
      case 'Elite':
        return const Color(0xFFFFD700);
      case 'Advanced':
        return const Color(0xFF00E676);
      case 'Intermediate':
        return const Color(0xFF42A5F5);
      default:
        return Colors.grey;
    }
  }

  void _updateFromSlider(double value) {
    setState(() {
      _sliderValue = value;
      _minutes = (value / 60).floor();
      _seconds = (value % 60).round();
      if (_seconds > 59) {
        _seconds = 59;
      }
    });
  }

  void _updateFromTime() {
    setState(() {
      _sliderValue = ((_minutes * 60) + _seconds).toDouble();
    });
  }

  void _incrementMinutes() {
    if (_minutes < 10) {
      setState(() => _minutes++);
      _updateFromTime();
    }
  }

  void _decrementMinutes() {
    if (_minutes > 0) {
      setState(() => _minutes--);
      _updateFromTime();
    }
  }

  void _incrementSeconds() {
    if (_minutes < 10 || _seconds < 59) {
      setState(() {
        _seconds++;
        if (_seconds == 60) {
          _seconds = 0;
          _minutes++;
        }
      });
      _updateFromTime();
    }
  }

  void _decrementSeconds() {
    if (_seconds > 0) {
      setState(() => _seconds--);
      _updateFromTime();
    } else if (_minutes > 0) {
      setState(() {
        _minutes--;
        _seconds = 59;
      });
      _updateFromTime();
    }
  }

  Future<void> _showTimePicker() async {
    final minutesController = TextEditingController(text: _minutes.toString());
    final secondsController = TextEditingController(text: _seconds.toString().padLeft(2, '0'));

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter time'),
        backgroundColor: const Color(0xFF1E1E2E),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80,
              child: TextField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Min'),
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                controller: secondsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sec'),
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final m = int.tryParse(minutesController.text) ?? 0;
              final s = int.tryParse(secondsController.text) ?? 0;
              if (s >= 0 && s <= 59 && m >= 0 && m <= 10) {
                setState(() {
                  _minutes = m;
                  _seconds = s;
                });
                _updateFromTime();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid time. Seconds must be 0-59.')),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPace() async {
    final totalSeconds = (_minutes * 60) + _seconds;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pace_seconds': totalSeconds}),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Success! Pace submitted.')),
        );
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121220),
      appBar: AppBar(
        title: const Text('Pace Selector'),
        backgroundColor: const Color(0xFF1E1E2E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Text(
              'Best 100m Freestyle',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            _buildTimeDisplay(),
            const SizedBox(height: 40),
            _buildSlider(),
            const SizedBox(height: 40),
            _buildLevelCard(),
            const SizedBox(height: 48),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return GestureDetector(
      onTap: _showTimePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDigitColumn('MIN', _minutes, _incrementMinutes, _decrementMinutes),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                ':',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w300,
                  color: Colors.white54,
                ),
              ),
            ),
            _buildDigitColumn('SEC', _seconds, _incrementSeconds, _decrementSeconds),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitColumn(String label, int value, VoidCallback onIncrement, VoidCallback onDecrement) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 12, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white70),
          onPressed: onIncrement,
          iconSize: 32,
          splashRadius: 20,
        ),
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w200,
            color: Colors.white,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          onPressed: onDecrement,
          iconSize: 32,
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget _buildSlider() {
    const tickLabels = [70.0, 90.0, 120.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PACE TIME',
          style: TextStyle(color: Colors.grey[500], fontSize: 12, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF42A5F5),
            inactiveTrackColor: Colors.white12,
            thumbColor: const Color(0xFF42A5F5),
            overlayColor: const Color(0x2942A5F5),
            trackHeight: 4,
          ),
          child: Slider(
            value: _sliderValue.clamp(30, 300),
            min: 30,
            max: 300,
            divisions: 270,
            label: '$_minutes:${_seconds.toString().padLeft(2, '0')}',
            onChanged: _updateFromSlider,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('0:30', style: TextStyle(color: Colors.white38, fontSize: 12)),
              for (final tick in tickLabels)
                GestureDetector(
                  onTap: () => _updateFromSlider(tick),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (_minutes * 60 + _seconds).abs() == tick.toInt()
                          ? const Color(0xFF42A5F5)
                          : Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${tick ~/ 60}:${(tick % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: (_minutes * 60 + _seconds).abs() == tick.toInt()
                            ? Colors.white
                            : Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              const Text('5:00', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1E2E),
            levelColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: levelColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _levelIcon(swimmerLevel),
              color: levelColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SWIMMER LEVEL',
                style: TextStyle(color: Colors.grey[500], fontSize: 11, letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              Text(
                swimmerLevel.toUpperCase(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: levelColor,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _levelIcon(String level) {
    switch (level) {
      case 'Elite':
        return Icons.emoji_events;
      case 'Advanced':
        return Icons.trending_up;
      case 'Intermediate':
        return Icons.trending_flat;
      default:
        return Icons.trending_down;
    }
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitPace,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF42A5F5),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF42A5F5).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _LevelRange {
  final int min;
  final int max;
  const _LevelRange(this.min, this.max);
}
