import 'package:flutter/material.dart';

class DrumWheel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final items = List.generate(max - min + 1, (i) => min + i);

    return SizedBox(
      width: 80,
      height: 168,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 56,
        diameterRatio: 3.5,
        squeeze: 1.0,
        offAxisFraction: 0,
        useMagnifier: false,
        perspective: 0.006,
        controller: FixedExtentScrollController(initialItem: value - min),
        onSelectedItemChanged: (i) => onChanged(items[i]),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final item = items[index];
            final isSelected = item == value;
            return Center(
              child: Text(
                item.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: isSelected ? 36 : 20,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                  color: isSelected ? Colors.white : Colors.white30,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
