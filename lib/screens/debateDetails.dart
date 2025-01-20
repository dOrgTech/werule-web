// lib/screens/debate_details.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../widgets/debate_header.dart';
import '../../widgets/pro_con_section.dart';
import '../debates/models/argument.dart';
import '../debates/models/debate.dart';
import '../entities/org.dart';

class DebateDetails extends StatefulWidget {
  final Debate debate;
  DebateDetails({super.key, required this.debate});

  bool enabled = false;
  bool busy = false;
  BigInt votesFor = BigInt.zero;
  BigInt votesAgainst = BigInt.zero;
  Member? member;

  @override
  State<DebateDetails> createState() => DebateDetailsState();
}

class DebateDetailsState extends State<DebateDetails> {
  late Argument currentArgument;

  @override
  void initState() {
    super.initState();
    currentArgument = widget.debate.rootArgument;
  }

  void _navigateToArgument(Argument arg) {
    setState(() {
      currentArgument = arg;
    });
  }

  /// Called by the "Navigate Up" button in the DebateHeader
  void _navigateUpOneLevel() {
    if (currentArgument.parent != null) {
      setState(() {
        currentArgument = currentArgument.parent!;
      });
    }
    // If there's no parent, do nothing (already at the root).
  }

  void _refreshDebate() {
    setState(() {
      // Rebuild to refresh map, etc.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("< Back"),
                  ),
                ),
                const SizedBox(height: 10),
                // Debate header with 3-layer map, Full Map button, etc.
                DebateHeader(
                  debate: widget.debate,
                  currentArgument: currentArgument,
                  onArgumentSelected: _navigateToArgument,
                ),
                const Divider(thickness: 1),
                // A small argument-specific header with author, weight, net
                _argumentHeader(currentArgument),
                // The argument's content
                Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(34.0),
                  child: MarkdownBody(
                    data: currentArgument.content,
                    shrinkWrap: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(
                      Theme.of(context),
                    ),
                  ),
                ),
                // The Pro/Con Section
                Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: ProConSection(
                    debate: widget.debate,
                    key: ValueKey(currentArgument),
                    currentArgument: currentArgument,
                    onArgumentSelected: _navigateToArgument,
                    onDebateChanged: _refreshDebate,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _argumentHeader(Argument arg) {
    // Show the stats & author in a nice header
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Text(
            'Argument by ${arg.author}',
            style: const TextStyle(fontSize: 3, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Weight: ${arg.weight.toStringAsFixed(0)}'),
              const SizedBox(width: 20),
              Text('Sentiment: ${arg.score.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }
}
