// lib/widgets/full_debate_map.dart

import 'package:flutter/material.dart';
import '../debates/models/argument.dart';
import '../debates/models/debate.dart';

class FullDebateMapPopup extends StatelessWidget {
  final Debate debate;

  const FullDebateMapPopup({Key? key, required this.debate}) : super(key: key);

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
    // The box for this argument
    final box = Container(
      width: 72,
      height: 32,
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: _getBoxColor(arg),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Center(
        child: Text(
          _formatScore(arg.score),
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ),
    );

    // Gather all children (pro + con) in one row
    final children = [...arg.proArguments, ...arg.conArguments];
    if (children.isEmpty) {
      // No children => just return the single box
      return Column(
        children: [box],
      );
    }

    // If we have children => nest them below
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // The parent box
        box,
        // A row of children, each child is a recursive "full map" call
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

  /// Same color logic:
  /// Root: if > 0 => green, else => red
  /// Non-root: if <=0 => grey, else if parent's pro => green, else => red
  Color _getBoxColor(Argument arg) {
    if (arg.parent == null) {
      // Root
      return arg.score > 0 ? Colors.green : Colors.red;
    }
    if (arg.score <= 0) {
      return Colors.grey.shade700;
    }
    if (arg.parent!.proArguments.contains(arg)) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String _formatScore(double score) {
    if (score > 0) {
      return '+${score.toStringAsFixed(0)}';
    }
    return score.toStringAsFixed(0);
  }
}
