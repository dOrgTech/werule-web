// lib/widgets/debate_map_widget.dart

import 'package:flutter/material.dart';
import '../debates/models/argument.dart';
import '../debates/models/debate.dart';

class DebateMapWidget extends StatelessWidget {
  final Debate debate;
  final Argument currentArgument;
  final Function(Argument) onArgumentSelected;

  const DebateMapWidget({
    super.key,
    required this.debate,
    required this.currentArgument,
    required this.onArgumentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final levels = _computeThreeLevels(currentArgument);
    final depth = _calculateDepth(currentArgument);

    // We'll allow horizontal scrolling for the entire widget
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text('Depth: $depth'),
          ),
          const SizedBox(width: 36),
          // The vertical columns
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (levels.above.isNotEmpty)
                _buildRow(levels.above, isAbove: true),
              _buildRow(levels.current, isCurrentLevel: true),
              if (levels.below.isNotEmpty)
                _buildRow(levels.below, isBelow: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    List<Argument> args, {
    bool isAbove = false,
    bool isBelow = false,
    bool isCurrentLevel = false,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Row(
        key: ValueKey(args),
        mainAxisAlignment: MainAxisAlignment.center,
        children: args.map((arg) {
          final isSelected = (arg == currentArgument) && isCurrentLevel;
          return GestureDetector(
            onTap: () => onArgumentSelected(arg),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 24,
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: _getBoxColor(arg),
                border: isSelected
                    ? Border.all(color: Colors.black, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Center(
                // Display the argument's weight (not net score) in the map
                child: Text(
                  _formatWeight(arg.weight),
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Box color logic:
  ///  - Root argument: green if score > 0, otherwise red
  ///  - Non-root argument:
  ///       if score <= 0 => grey
  ///       else if parent's pro => green
  ///       else => red
  Color _getBoxColor(Argument arg) {
    if (arg.parent == null) {
      // Root => green if net score > 0 else red
      return arg.score > 0 ? Colors.green : Colors.red;
    }

    // Non-root
    if (arg.score <= 0) {
      return Colors.grey.shade700;
    }
    if (arg.parent!.proArguments.contains(arg)) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String _formatWeight(double weight) {
    return weight.toStringAsFixed(1);
  }

  /// Count how many ancestors the current argument has.
  int _calculateDepth(Argument current) {
    int depth = 0;
    Argument? node = current;
    while (node?.parent != null) {
      depth++;
      node = node?.parent;
    }
    return depth;
  }

  /// We compute "above", "current", and "below" rows for a 3-layer view.
  ThreeLevels _computeThreeLevels(Argument current) {
    final above = <Argument>[];
    final currentRow = <Argument>[];
    final below = <Argument>[];

    final parent = current.parent;
    if (parent != null) {
      final grandparent = parent.parent;
      if (grandparent != null) {
        above.addAll(grandparent.proArguments);
        above.addAll(grandparent.conArguments);
      } else {
        above.add(parent);
      }
    }

    if (parent == null) {
      currentRow.add(current);
    } else {
      currentRow.addAll(parent.proArguments);
      currentRow.addAll(parent.conArguments);
    }

    below.addAll(current.proArguments);
    below.addAll(current.conArguments);

    return ThreeLevels(above, currentRow, below);
  }
}

class ThreeLevels {
  final List<Argument> above;
  final List<Argument> current;
  final List<Argument> below;

  ThreeLevels(this.above, this.current, this.below);
}
