// lib/widgets/debate_map_widget.dart

import 'package:flutter/material.dart';
import '../debates/models/argument.dart';
import '../debates/models/debate.dart';

class DebateMapWidget extends StatelessWidget {
  final Debate debate;
  final Argument currentArgument;
  final Function(Argument) onArgumentSelected;

  const DebateMapWidget({
    Key? key,
    required this.debate,
    required this.currentArgument,
    required this.onArgumentSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final levels = _computeThreeLevels(currentArgument);
    final depth = _calculateDepth(currentArgument);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Depth indicator
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text('Depth: $depth'),
        ),
        const SizedBox(width: 36),
        // The vertical map columns
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (levels.above.isNotEmpty)
              _buildRow(context, levels.above, isAbove: true),
            _buildRow(context, levels.current, isCurrentLevel: true),
            if (levels.below.isNotEmpty)
              _buildRow(context, levels.below, isBelow: true),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    List<Argument> args, {
    bool isAbove = false,
    bool isBelow = false,
    bool isCurrentLevel = false,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: Row(
        key: ValueKey(args),
        mainAxisAlignment: MainAxisAlignment.center,
        children: args.map((arg) {
          final isSelected = (arg == currentArgument) && isCurrentLevel;

          return GestureDetector(
            onTap: () => onArgumentSelected(arg),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 72,
              height: 32,
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: _getBoxColor(arg),
                border: isSelected
                    ? Border.all(color: Colors.black, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(4.0),
              ),
              // Show the argument's raw weight, abbreviated
              child: Center(
                child: Text(
                  _abbreviateNumber(arg.weight),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// If arg == rootArgument => grey
  /// If arg.parent == rootArgument => green if pro, red if con
  /// else white
  Color _getBoxColor(Argument arg) {
    if (arg == debate.rootArgument) {
      return Colors.grey;
    }
    final root = debate.rootArgument;
    if (arg.parent == root) {
      if (root.proArguments.contains(arg)) {
        return Colors.green;
      } else if (root.conArguments.contains(arg)) {
        return Colors.red;
      }
    }
    return Colors.white;
  }

  /// e.g. 999 => '999'
  /// 1,200 => '1.2K'
  /// 1,000,000 => '1.0M'
  String _abbreviateNumber(double value) {
    // We'll produce up to 4 chars, e.g. 999, 1.2K, 12K, 999K, 1.0M, 999M, 1.0B...
    // you can refine as desired
    if (value < 1000) {
      // up to 3 digits
      return value.toStringAsFixed(0);
    } else if (value < 1000000) {
      // 1K ~ 999K
      double result = value / 1000.0;
      return _format4Chars(result, 'K');
    } else if (value < 1000000000) {
      // up to 999M
      double result = value / 1000000.0;
      return _format4Chars(result, 'M');
    } else if (value < 1000000000000) {
      double result = value / 1000000000.0;
      return _format4Chars(result, 'B');
    } else {
      double result = value / 1000000000000.0;
      return _format4Chars(result, 'T');
    }
  }

  /// Turn e.g. 1.234 into '1.2K' or '1K' if it’s an integer
  String _format4Chars(double val, String suffix) {
    // val might be e.g. 1.234, 999.99, etc.
    // We have up to 2 digits before decimal if we want up to 4 total chars.
    // e.g. "12.3K" is 5 chars => might do "12K" if it's 12.3
    // We'll do a quick approach: if floor == val => no decimal, else 1 decimal.
    if (val == val.floor()) {
      return '${val.toStringAsFixed(0)}$suffix'; // e.g. 12K
    } else {
      // e.g. 1.2K
      String withDecimal = val.toStringAsFixed(1);
      // but if that yields 5 chars, we might revert to no decimal
      // Example: 12.3 => "12.3K" is 5 chars
      if (withDecimal.length + 1 > 4) {
        // e.g. "12.3K" => length 5
        return '${val.floor()}$suffix';
      }
      return '$withDecimal$suffix';
    }
  }

  /// Standard logic from your existing code:
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

  int _calculateDepth(Argument current) {
    int depth = 0;
    Argument? node = current;
    while (node?.parent != null) {
      depth++;
      node = node?.parent;
    }
    return depth;
  }
}

class ThreeLevels {
  final List<Argument> above;
  final List<Argument> current;
  final List<Argument> below;

  ThreeLevels(this.above, this.current, this.below);
}
