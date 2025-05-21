// lib/widgets/pro_con_section.dart

import 'package:flutter/material.dart';
import '../debates/models/argument.dart';
import '../debates/models/debate.dart';
import 'argument_card.dart';
import 'add_argument_dialog.dart';

class ProConSection extends StatefulWidget {
  final Debate debate;
  final Argument currentArgument;
  final Function(Argument) onArgumentSelected;
  final VoidCallback? onDebateChanged;

  const ProConSection({
    super.key,
    required this.debate,
    required this.currentArgument,
    required this.onArgumentSelected,
    this.onDebateChanged,
  });

  @override
  _ProConSectionState createState() => _ProConSectionState();
}

class _ProConSectionState extends State<ProConSection> {
  void _showAddArgumentDialog(String argType) {
    showDialog(
      context: context,
      builder: (ctx) => AddArgumentDialog(
        onAdd: (content, weight) {
          // New child with random author
          final newArg = Argument(
            content: content,
            weight: weight,
            parent: widget.currentArgument,
          );

          setState(() {
            if (argType == 'Pro') {
              widget.currentArgument.proArguments.add(newArg);
            } else {
              widget.currentArgument.conArguments.add(newArg);
            }
            widget.debate.recalc();
          });

          widget.onDebateChanged?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proArgs = widget.currentArgument.proArguments;
    final conArgs = widget.currentArgument.conArguments;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pro column
        Expanded(
          child: Container(
            color: const Color.fromARGB(255, 41, 49, 42),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'Pro Arguments (${proArgs.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add),
                        color: Colors.white,
                        onPressed: () => _showAddArgumentDialog('Pro'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Non-scrollable ListView, shrinkWrap
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: proArgs.length,
                  itemBuilder: (ctx, i) {
                    return ArgumentCard(
                      argument: proArgs[i],
                      onTap: widget.onArgumentSelected,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        // Con column
        Expanded(
          child: Container(
            color: const Color.fromARGB(255, 46, 34, 36),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'Con Arguments (${conArgs.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add),
                        color: Colors.white,
                        onPressed: () => _showAddArgumentDialog('Con'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: conArgs.length,
                  itemBuilder: (ctx, i) {
                    return ArgumentCard(
                      argument: conArgs[i],
                      onTap: widget.onArgumentSelected,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
