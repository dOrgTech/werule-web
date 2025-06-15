// lib/widgets/argument_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../debates/models/argument.dart';

class ArgumentCard extends StatelessWidget {
  final Argument argument;
  final Function(Argument) onTap;

  const ArgumentCard({
    super.key,
    required this.argument,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sumProWeights =
        argument.proArguments.fold<double>(0, (acc, a) => acc + a.weight);
    final sumConWeights =
        argument.conArguments.fold<double>(0, (acc, a) => acc + a.weight);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => onTap(argument),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // extra padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row with Author on left, Net & Weight on right
              Row(
                children: [
                  Text(
                    "by ${argument.author}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  // "Net: X | Weight: Y"
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'S: ',
                        ),
                        TextSpan(
                          text: argument.score.toStringAsFixed(0),
                          style: TextStyle(
                            color:
                                argument.score < 0 ? Colors.red : Colors.green,
                          ),
                        ),
                        TextSpan(
                          text: ' | W: ${argument.weight.toStringAsFixed(0)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // "Pro: X (sumProWeights), Con: Y (sumConWeights)"
              Text(
                'Pro: ${argument.proCount} (${sumProWeights.toStringAsFixed(0)})  '
                'Con: ${argument.conCount} (${sumConWeights.toStringAsFixed(0)})',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              // Markdown content with extra padding
              Container(
                constraints: const BoxConstraints(maxHeight: 600),
                child: SingleChildScrollView(
                  child: MarkdownBody(
                    data: argument.content,
                    styleSheet: MarkdownStyleSheet.fromTheme(
                      Theme.of(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
