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
  bool _editingMinutes = false;
  bool _editingSeconds = false;

  final _minutesController = TextEditingController();
  final _secondsController = TextEditingController();
  final _minutesFocus = FocusNode();
  final _secondsFocus = FocusNode();

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

  void _startEditingMinutes() {
    _minutesController.text = _minutes.toString();
    setState(() => _editingMinutes = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _minutesFocus.requestFocus());
  }

  void _finishEditingMinutes() {
    final value = int.tryParse(_minutesController.text);
    if (value != null && value >= 0 && value <= 10) {
      setState(() {
        _minutes = value;
        _editingMinutes = false;
      });
      _updateFromTime();
    } else {
      setState(() => _editingMinutes = false);
    }
  }

  void _startEditingSeconds() {
    _secondsController.text = _seconds.toString().padLeft(2, '0');
    setState(() => _editingSeconds = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _secondsFocus.requestFocus());
  }

  void _finishEditingSeconds() {
    final value = int.tryParse(_secondsController.text);
    if (value != null && value >= 0 && value <= 59) {
      setState(() {
        _seconds = value;
        _editingSeconds = false;
      });
      _updateFromTime();
    } else {
      setState(() => _editingSeconds = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _minutesFocus.addListener(() {
      if (!_minutesFocus.hasFocus && _editingMinutes) {
        _finishEditingMinutes();
      }
    });
    _secondsFocus.addListener(() {
      if (!_secondsFocus.hasFocus && _editingSeconds) {
        _finishEditingSeconds();
      }
    });
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    _minutesFocus.dispose();
    _secondsFocus.dispose();
    super.dispose();
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
            _editingMinutes,
            _minutesController,
            _minutesFocus,
            _startEditingMinutes,
            _finishEditingMinutes,
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
            _editingSeconds,
            _secondsController,
            _secondsFocus,
            _startEditingSeconds,
            _finishEditingSeconds,
          ),
        ],
      ),
    );
  }

  Widget _buildDigitColumn(
    String label,
    int value,
    VoidCallback onIncrement,
    VoidCallback onDecrement,
    bool isEditing,
    TextEditingController controller,
    FocusNode focusNode,
    VoidCallback onStartEdit,
    VoidCallback onFinishEdit,
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
          onTap: isEditing ? null : onStartEdit,
          child: SizedBox(
            height: 64,
            width: 80,
            child: Align(
              alignment: Alignment.center,
              child: isEditing
                  ? SizedBox(
                      width: 70,
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w200,
                          color: Color(0xFF42A5F5),
                        ),
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF42A5F5)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF42A5F5)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF42A5F5), width: 2),
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => onFinishEdit(),
                      ),
                    )
                  : Text(
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
            trackShape: const _LevelSliderTrackShape(),
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
                backgroundColor: const Color(0xFF42A5F5),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF42A5F5).withValues(alpha: 0.3),
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

class _LevelRange {
  final int min;
  final int max;
  const _LevelRange(this.min, this.max);
}

class _LevelSliderTrackShape extends SliderTrackShape {
  const _LevelSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool? isEnabled,
    bool? isDiscrete,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4;
    return Rect.fromLTWH(
      offset.dx,
      (parentBox.size.height - trackHeight) / 2,
      parentBox.size.width - 2 * offset.dx,
      trackHeight,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = true,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4;
    final trackRect = Rect.fromLTWH(
      offset.dx,
      (parentBox.size.height - trackHeight) / 2,
      parentBox.size.width - 2 * offset.dx,
      trackHeight,
    );

    if (trackRect.width <= 0 || trackRect.height <= 0) return;

    final canvas = context.canvas;
    const double min = 30;
    const double max = 300;
    const double range = max - min;

    double valueToX(double v) {
      return trackRect.left + ((v - min) / range) * trackRect.width;
    }

    const segments = <_LevelSegment>[
      _LevelSegment(30, 59, Color(0xFFFFD700)),
      _LevelSegment(60, 89, Color(0xFF00E676)),
      _LevelSegment(90, 119, Color(0xFF42A5F5)),
      _LevelSegment(120, 300, Colors.grey),
    ];

    for (final seg in segments) {
      final segMin = seg.start.clamp(min, max);
      final segMax = seg.end.clamp(min, max);
      if (segMin >= segMax) continue;

      final left = valueToX(segMin);
      final right = valueToX(segMax);

      if (left < thumbCenter.dx) {
        final activeLeft = left;
        final activeRight = right < thumbCenter.dx ? right : thumbCenter.dx;
        if (activeRight > activeLeft) {
          final rrect = RRect.fromRectAndRadius(
            Rect.fromLTRB(activeLeft, trackRect.top, activeRight, trackRect.bottom),
            const Radius.circular(4),
          );
          canvas.drawRRect(rrect, Paint()..color = seg.color);
        }
      }

      if (right > thumbCenter.dx) {
        final inactiveLeft = left > thumbCenter.dx ? left : thumbCenter.dx;
        final inactiveRight = right;
        if (inactiveRight > inactiveLeft) {
          final rrect = RRect.fromRectAndRadius(
            Rect.fromLTRB(inactiveLeft, trackRect.top, inactiveRight, trackRect.bottom),
            const Radius.circular(4),
          );
          canvas.drawRRect(rrect, Paint()..color = seg.color.withValues(alpha: 0.2));
        }
      }
    }
  }
}

class _LevelSegment {
  final double start;
  final double end;
  final Color color;
  const _LevelSegment(this.start, this.end, this.color);
}
