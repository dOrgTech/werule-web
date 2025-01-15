// lib/widgets/debate_header.dart

import 'package:flutter/material.dart';
import '../debates/models/argument.dart';
import '../debates/models/debate.dart';
import 'debate_map_widget.dart';
import 'full_debate_map.dart';

class DebateHeader extends StatelessWidget {
  final Debate debate;
  final Argument currentArgument;
  final Function(Argument) onArgumentSelected;

  const DebateHeader({
    Key? key,
    required this.debate,
    required this.currentArgument,
    required this.onArgumentSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background.withOpacity(0.05),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Debate Title + single "sentiment"
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                debate.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Sentiment: ${debate.sentiment.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          // The 3-layer map
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: DebateMapWidget(
              debate: debate,
              currentArgument: currentArgument,
              onArgumentSelected: onArgumentSelected,
            ),
          ),
          // Button to show full map
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => FullDebateMapPopup(debate: debate),
              );
            },
            child: const Icon(Icons.map),
          ),
        ],
      ),
    );
  }
}
