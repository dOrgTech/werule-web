import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../widgets/debate_header.dart';
import '../../widgets/pro_con_section.dart';
import '../models/debate.dart';
import '../models/argument.dart';

class DebateDetailScreen extends StatefulWidget {
  final Debate debate;

  const DebateDetailScreen({Key? key, required this.debate}) : super(key: key);

  @override
  _DebateDetailScreenState createState() => _DebateDetailScreenState();
}

class _DebateDetailScreenState extends State<DebateDetailScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// DebateHeader with new layout
            DebateHeader(
              debate: widget.debate,
              currentArgument: currentArgument,
              onArgumentSelected: _navigateToArgument,
            ),
            const Divider(thickness: 1),
            // Show the current argument's content with Markdown
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    child: MarkdownBody(
                      data: currentArgument.content,
                      shrinkWrap: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(
                        Theme.of(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ProConSection(
                      debate: widget.debate,
                      key: ValueKey(currentArgument), // re-init if arg changes
                      currentArgument: currentArgument,
                      onArgumentSelected: _navigateToArgument,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
