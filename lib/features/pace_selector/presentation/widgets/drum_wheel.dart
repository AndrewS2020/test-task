import 'package:flutter/material.dart';

class DrumWheel extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const DrumWheel({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<DrumWheel> createState() => _DrumWheelState();
}

class _DrumWheelState extends State<DrumWheel> {
  late FixedExtentScrollController _controller;
  late List<int> _items;
  bool _internalChange = false;

  @override
  void initState() {
    super.initState();
    _items = List.generate(widget.max - widget.min + 1, (i) => widget.min + i);
    _controller = FixedExtentScrollController(initialItem: widget.value - widget.min);
  }

  @override
  void didUpdateWidget(DrumWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_internalChange) {
      final targetIndex = widget.value - widget.min;
      if (targetIndex >= 0 && targetIndex < _items.length) {
        _controller.animateToItem(
          targetIndex,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        );
      }
    }
    _internalChange = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 168,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ListWheelScrollView.useDelegate(
              itemExtent: 56,
              diameterRatio: 2.8,
              squeeze: 1.0,
              offAxisFraction: 0,
              useMagnifier: false,
              perspective: 0.005,
              controller: _controller,
              onSelectedItemChanged: (i) {
                if (i >= 0 && i < _items.length) {
                  _internalChange = true;
                  widget.onChanged(_items[i]);
                }
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: _items.length,
                builder: (context, index) {
                  final item = _items[index];
                  final isSelected = item == widget.value;
                  return Container(
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        fontSize: isSelected ? 38 : 22,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w300,
                        color: isSelected ? Colors.white : Colors.white38,
                      ),
                      child: Text(item.toString().padLeft(2, '0')),
                    ),
                  );
                },
              ),
            ),
          ),
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1),
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1),
                ),
              ),
              margin: EdgeInsets.only(top: 55, bottom: 55),
            ),
          ),
        ],
      ),
    );
  }
}
