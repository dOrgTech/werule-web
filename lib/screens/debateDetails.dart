import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../widgets/debate_header.dart';
import '../../widgets/pro_con_section.dart';
import '../debates/models/debate.dart';
import '../debates/models/argument.dart';
import '../entities/org.dart';

const Color supportColor = Color.fromARGB(255, 20, 78, 49);
const Color rejectColor = Color.fromARGB(255, 88, 20, 20);

class DebateDetails extends StatefulWidget {
  // int id;
  DebateDetails({super.key, required this.debate});
  Debate debate;
  bool enabled = false;
  // String? status;
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(Object context) {
    return wide();
  }

  Widget wide() {
    return Container(
        // child: Center(child: Text("hello from the fucking debate page"))
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .center, // Set this property to center the items horizontally
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("< Back"))),
            const SizedBox(height: 10),
            DebateHeader(
              debate: widget.debate,
              currentArgument: currentArgument,
              onArgumentSelected: _navigateToArgument,
            ),
            const Divider(thickness: 1),
            // Show the current argument's content with Markdown
            Container(
              constraints: BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    child: MarkdownBody(
                      data: currentArgument.content,
                      shrinkWrap: true,
                      // You could further style the markdown if you wish
                      styleSheet: MarkdownStyleSheet.fromTheme(
                        Theme.of(context),
                      ),
                    ),
                  ),
                  Container(
                    height: 1000,
                    child: ProConSection(
                      debate: widget.debate,
                      key: ValueKey(
                          currentArgument), // re-init if argument changes
                      currentArgument: currentArgument,
                      onArgumentSelected: _navigateToArgument,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )));
  }
}
