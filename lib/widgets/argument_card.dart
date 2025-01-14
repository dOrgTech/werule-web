// lib/widgets/argument_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../debates/models/argument.dart';

class ArgumentCard extends StatelessWidget {
  final Argument argument;
  final Function(Argument) onTap;

  const ArgumentCard({
    Key? key,
    required this.argument,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We'll compute how many direct children are pro vs. con,
    // and how many *valid tokens* each side contributes (children whose score > 0).
    final proInfo = _getChildCountAndTokens(argument.proArguments);
    final conInfo = _getChildCountAndTokens(argument.conArguments);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => onTap(argument),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row with the argument's author, raw weight, net score
              Row(
                children: [
                  Text(
                    argument.author,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text('W: ${argument.weight.toStringAsFixed(0)} '),
                  const SizedBox(width: 8),
                  Text('Net: ${argument.score.toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: 6),
              // Show direct children stats: "Pro: X (Y tokens) | Con: A (B tokens)"
              Text(
                'Pro: ${proInfo.count} (${proInfo.tokens.toStringAsFixed(0)}) | '
                'Con: ${conInfo.count} (${conInfo.tokens.toStringAsFixed(0)})',
                style: Theme.of(context).textTheme.caption,
              ),
              const SizedBox(height: 8),
              // The markdown content
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

  /// For the direct children in [children], return:
  /// - count of those children
  /// - sum of their `score` if > 0 (rounded, or as double)
  _ChildInfo _getChildCountAndTokens(List<Argument> children) {
    int c = 0;
    double sum = 0;
    for (var child in children) {
      // child's score must be > 0 to be "valid"
      if (child.score > 0) {
        c++;
        sum += child.score;
      }
    }
    return _ChildInfo(count: c, tokens: sum);
  }
}

class _ChildInfo {
  final int count;
  final double tokens;
  _ChildInfo({required this.count, required this.tokens});
}
