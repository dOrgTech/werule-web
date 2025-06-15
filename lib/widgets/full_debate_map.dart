// lib/widgets/full_debate_map.dart

import 'package:flutter/material.dart';
import '../debates/models/argument.dart';
import '../debates/models/debate.dart';

class FullDebateMapPopup extends StatelessWidget {
  final Debate debate;
  // Optional tap handler if we want to navigate upon tapping a node.
  final Function(Argument)? onArgumentSelected;

  const FullDebateMapPopup({
    super.key,
    required this.debate,
    this.onArgumentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: _buildFullMap(debate.rootArgument),
      ),
    );
  }

  /// Recursively builds a Column:
  ///  [ Row( single box for this arg ) ]
  ///  [ Row( all children side by side ) ]
  /// For each child, we call _buildFullMap again, effectively nesting columns.
  Widget _buildFullMap(Argument arg) {
    // Build a box displaying the argument's weight; tap to select if callback is provided
    final box = GestureDetector(
      onTap: onArgumentSelected != null ? () => onArgumentSelected!(arg) : null,
      child: Container(
        width: 72,
        height: 32,
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: _getBoxColor(arg),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Center(
          child: Text(
            // Show weight in the box (not net score)
            _formatWeight(arg.weight),
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ),
      ),
    );

    // Gather all children (pro + con) in one horizontal row
    final children = [...arg.proArguments, ...arg.conArguments];
    if (children.isEmpty) {
      // No children => just return the single box
      return Column(
        children: [box],
      );
    }

    // If we have children => nest them below in a row
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        box,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children.map(_buildFullMap).toList(),
          ),
        ),
      ],
    );
  }

  /// If score <= 0 => grey, else:
  ///   root => green if >0 else red
  ///   non-root => green if parent's pro, else red
  Color _getBoxColor(Argument arg) {
    if (arg.parent == null) {
      // Root => green if net score > 0, else red
      return arg.score > 0 ? Colors.green : Colors.red;
    }
    // Non-root
    if (arg.score <= 0) {
      return Colors.grey.shade700;
    }
    if (arg.parent!.proArguments.contains(arg)) {
      return Colors.green;
    }
    return Colors.red;
  }

  String _formatWeight(double weight) {
    return weight.toStringAsFixed(1);
  }
}
