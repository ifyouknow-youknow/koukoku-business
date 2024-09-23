import 'package:flutter/material.dart';
import 'package:koukoku_business/COMPONENTS/text_view.dart';

class BarGraphView extends StatefulWidget {
  final List<Map<String, dynamic>> values;
  final double barHeight;
  final double radius;

  const BarGraphView({
    Key? key,
    required this.values,
    this.barHeight = 28.0,
    this.radius = 4.0,
  }) : super(key: key);

  @override
  State<BarGraphView> createState() => _BarGraphViewState();
}

class _BarGraphViewState extends State<BarGraphView> {
  @override
  Widget build(BuildContext context) {
    // Calculate the maximum value to determine bar widths.
    double maxValue = widget.values.isNotEmpty
        ? widget.values
            .map((e) => (e['value'] as num).toDouble()) // Convert to double
            .reduce((a, b) => a > b ? a : b)
        : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.values.map((map) {
        double barWidth = ((map['value'] as num).toDouble() / maxValue) *
            0.8 *
            MediaQuery.of(context).size.width;

        // Ensure color is provided, defaulting to a shade of grey if not.
        Color barColor =
            map.containsKey('color') ? map['color'] as Color : Colors.grey;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                text: map['text'] ?? '',
                weight: FontWeight.w500,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Bar with color from data
                  Container(
                    width: barWidth,
                    height: widget.barHeight,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(widget.radius),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Value text on the right side of the bar
                  TextView(
                    text: (map['value'] as num).toDouble().toStringAsFixed(1),
                    weight: FontWeight.w600,
                  )
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
