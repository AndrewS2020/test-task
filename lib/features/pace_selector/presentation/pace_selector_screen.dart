import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../domain/level_range.dart';
import 'widgets/level_slider_track_shape.dart';
import 'widgets/drum_wheel.dart';

enum _NumpadTarget { minutes, seconds }
enum _InputMethod { numpad, drum }

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
  _InputMethod _inputMethod = _InputMethod.drum;

  static const Map<String, LevelRange> _levelRanges = {
    'Elite': LevelRange(0, 59),
    'Advanced': LevelRange(60, 89),
    'Intermediate': LevelRange(90, 119),
    'Beginner': LevelRange(120, 600),
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
    });
  }

  void _updateFromTime() {
    setState(() {
      _sliderValue = ((_minutes * 60) + _seconds).toDouble();
    });
  }

  void _incrementMinutes() {
    if (_minutes < 60) {
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
    if (_seconds < 60) {
      setState(() => _seconds++);
      _updateFromTime();
    }
  }

  void _decrementSeconds() {
    if (_seconds > 0) {
      setState(() => _seconds--);
      _updateFromTime();
    }
  }

  void _onDigitTap(_NumpadTarget target) {
    if (_inputMethod == _InputMethod.numpad) {
      _showNumpad(target);
    }
  }

  void _showNumpad(_NumpadTarget target) {
    String buffer = '';
    int? initialValue = target == _NumpadTarget.minutes ? _minutes : _seconds;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    target == _NumpadTarget.minutes ? 'MINUTES' : 'SECONDS',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12, letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    buffer.isEmpty ? initialValue.toString().padLeft(2, '0') : buffer,
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildNumpadGrid(
                    buffer: buffer,
                    onDigit: (d) {
                      final maxLen = target == _NumpadTarget.minutes ? 2 : 2;
                      if (buffer.length < maxLen) {
                        buffer += d;
                        setSheetState(() {});
                      }
                    },
                    onBackspace: () {
                      if (buffer.isNotEmpty) {
                        buffer = buffer.substring(0, buffer.length - 1);
                        setSheetState(() {});
                      }
                    },
                    onOk: () {
                      int value;
                      if (buffer.isEmpty) {
                        value = initialValue;
                      } else {
                        value = int.tryParse(buffer) ?? initialValue;
                      }
                      if (value >= 0 && value <= 60) {
                        setState(() {
                          if (target == _NumpadTarget.minutes) {
                            _minutes = value;
                          } else {
                            _seconds = value;
                          }
                        });
                        _updateFromTime();
                      }
                      Navigator.pop(ctx);
                    },
                    onCancel: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNumpadGrid({
    required String buffer,
    required void Function(String) onDigit,
    required VoidCallback onBackspace,
    required VoidCallback onOk,
    required VoidCallback onCancel,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: row.map((d) => Expanded(child: _numpadButton(d, () => onDigit(d)))).toList(),
            ),
          ),
        Row(
          children: [
            Expanded(child: _numpadButton('⌫', onBackspace)),
            const SizedBox(width: 12),
            Expanded(child: _numpadButton('0', () => onDigit('0'))),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: onOk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: levelColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.check, size: 28),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(foregroundColor: Colors.grey[500]),
            child: const Text('Cancel', style: TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _numpadButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: SizedBox(
        height: 60,
        child: Material(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Center(
              child: label == '⌫'
                  ? const Icon(Icons.backspace_outlined, color: Colors.white70, size: 24)
                  : Text(
                      label,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Column(
      children: [
        if (_inputMethod == _InputMethod.drum)
          _buildDrumDisplay()
        else
          _buildNumpadDisplay(),
        const SizedBox(height: 12),
        _buildInputMethodToggle(),
      ],
    );
  }

  Widget _buildDrumDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DrumWheel(
            value: _minutes,
            min: 0,
            max: 60,
            onChanged: (v) {
              setState(() => _minutes = v);
              _updateFromTime();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w300,
                color: Colors.white54,
              ),
            ),
          ),
          DrumWheel(
            value: _seconds,
            min: 0,
            max: 60,
            onChanged: (v) {
              setState(() => _seconds = v);
              _updateFromTime();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumpadDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDigitColumn(
            'MIN',
            _minutes,
            _incrementMinutes,
            _decrementMinutes,
            () => _onDigitTap(_NumpadTarget.minutes),
          ),
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
          _buildDigitColumn(
            'SEC',
            _seconds,
            _incrementSeconds,
            _decrementSeconds,
            () => _onDigitTap(_NumpadTarget.seconds),
          ),
        ],
      ),
    );
  }

  Widget _buildInputMethodToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleChip(_InputMethod.drum, Icons.view_carousel_outlined, 'Drum'),
          const SizedBox(width: 4),
          _toggleChip(_InputMethod.numpad, Icons.grid_4x4_outlined, 'Numpad'),
        ],
      ),
    );
  }

  Widget _toggleChip(_InputMethod method, IconData icon, String label) {
    final selected = _inputMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _inputMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF42A5F5) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : Colors.grey[500]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: selected ? Colors.white : Colors.grey[500],
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitColumn(
    String label,
    int value,
    VoidCallback onIncrement,
    VoidCallback onDecrement,
    VoidCallback onTap,
  ) {
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
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            height: 64,
            width: 80,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                value.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                ),
              ),
            ),
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
            trackShape: const LevelSliderTrackShape(),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.transparent,
            thumbColor: levelColor,
            overlayColor: levelColor.withValues(alpha: 0.15),
            trackHeight: 8,
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
    final level = swimmerLevel;
    final color = levelColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1E2E),
            color.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Container(
                  key: ValueKey(level),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _levelIcon(level),
                    color: color,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SWIMMER LEVEL',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11, letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 400),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 3,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                        child: Text(
                          level.toUpperCase(),
                          key: ValueKey(level),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitPace,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                disabledBackgroundColor: color.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Continue', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
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
}
