### lib\debates\models\argument.dart

```
// lib/debates/argument.dart

import 'dart:math';

// Generates a random 4-6 character username, e.g. "X9za0"
String randomUsername() {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final rand = Random();
  final length = 4 + rand.nextInt(3);
  return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
      .join();
}

class Argument {
  final String content;
  Argument? parent;

  final String author; // Either provided or auto-generated
  final double weight; // Raw voting power assigned at creation
  double score = 0; // Net effect after factoring children

  List<Argument> proArguments;
  List<Argument> conArguments;

  Argument({
    required this.content,
    this.parent,
    String? author, // If null, we generate a random username
    required this.weight,
    List<Argument>? proArguments,
    List<Argument>? conArguments,
  })  : proArguments = proArguments ?? [],
        conArguments = conArguments ?? [],
        author = author ?? randomUsername();

  int get proCount => proArguments.length;
  int get conCount => conArguments.length;

  /// Recompute net score of entire subtree:
  ///   score(arg) = arg.weight
  ///     + sum( score(pro child) if > 0 )
  ///     - sum( score(con child) if > 0 )
  static double computeScore(Argument arg) {
    double sum = arg.weight;
    for (var child in arg.proArguments) {
      final childScore = computeScore(child);
      if (childScore > 0) sum += childScore;
    }
    for (var child in arg.conArguments) {
      final childScore = computeScore(child);
      if (childScore > 0) sum -= childScore;
    }
    arg.score = sum;
    return sum;
  }
}

````

### lib\debates\models\debate.dart

```
// lib/debates/debate.dart

import 'dart:convert';
import 'package:Homebase/entities/org.dart';
import 'package:crypto/crypto.dart';
import 'argument.dart';

class Debate {
  Org org;
  String? hash;
  String title;
  Argument rootArgument;

  double sentiment = 0; // Single metric for the entire debate

  Debate({
    required this.org,
    required this.title,
    required this.rootArgument,
  }) {
    final input = title + rootArgument.content;
    final bytes = utf8.encode(input);
    hash = sha256.convert(bytes).toString();

    recalc();
  }

  void recalc() {
    sentiment = Argument.computeScore(rootArgument);
  }
}

````

### lib\debates\screens\debate_detail_screen.dart

```
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
      // We rely on our custom dark background from the dark theme
      body: SafeArea(
        child: Column(
          children: [
            // Debate title + vertical map
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
                      // You could further style the markdown if you wish
                      styleSheet: MarkdownStyleSheet.fromTheme(
                        Theme.of(context),
                      ),
                    ),
                  ),
                  Expanded(
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
        ),
      ),
    );
  }
}

````

### lib\widgets\add_argument_dialog.dart

```
// lib/widgets/add_argument_dialog.dart

import 'package:Homebase/widgets/newDebate.dart';
import 'package:flutter/material.dart';

class AddArgumentDialog extends StatefulWidget {
  final Function(String content, double weight) onAdd;

  const AddArgumentDialog({Key? key, required this.onAdd}) : super(key: key);

  @override
  _AddArgumentDialogState createState() => _AddArgumentDialogState();
}

class _AddArgumentDialogState extends State<AddArgumentDialog> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  void _submit() {
    final text = _contentController.text.trim();
    final weightStr = _weightController.text.trim();
    if (text.isEmpty || weightStr.isEmpty) return;

    final w = double.tryParse(weightStr);
    if (w == null) return;

    widget.onAdd(text, w);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Argument'),
      content: SingleChildScrollView(
        child: Container(
          width: 600,
          child: Column(
            children: [
              TextFormField(
                maxLines: 26,
                controller: _contentController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Write your argument (Markdown supported)',
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    hintText: 'max: 3950',
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: SubmitButton(
                  isSubmitEnabled: true,
                  submit: _submit,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

````

### lib\widgets\arbitrate.dart

```
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../entities/project.dart';

import '../entities/token.dart';

const String escape = '\uE00C';

class Arbitrate extends StatefulWidget {
  final Project project;

  // ignore: use_key_in_widget_constructors
  Arbitrate({required this.project});

  @override
  _ArbitrateState createState() => _ArbitrateState();
}

class _ArbitrateState extends State<Arbitrate> {
  bool _useSlider = true;
  double _sliderValue = 0;
  TextEditingController _awardToContractorController = TextEditingController();
  bool _canSubmit = false;

  @override
  void dispose() {
    _awardToContractorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double awardToBackers = _useSlider ? widget.project.amountInEscrow! - _sliderValue : widget.project.amountInEscrow! - (double.tryParse(_awardToContractorController.text) ?? 0);
    double awardToContractor = _useSlider ? _sliderValue : (double.tryParse(_awardToContractorController.text) ?? 0);
    bool isNegative = awardToBackers < 0 || awardToContractor < 0;
    return Container(
      width: 650,
      padding: const EdgeInsets.symmetric(horizontal: 60),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).highlightColor,
          width: 0.3,
        ),
      ),
      height: 650,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Arbitrate",
            style: Theme.of(context).textTheme.headlineMedium!,
          ),
          SizedBox(height: 20),
          Text(
            "Amount in Escrow: ${widget.project.amountInEscrow!}",
            style: Theme.of(context).textTheme.bodySmall!,
          ),
          SizedBox(height: 20),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Input Field"),
                  Switch(
                    value: _useSlider,
                    onChanged: (value) {
                      setState(() {
                        _useSlider = value;
                        _canSubmit = false;
                      });
                    },
                    activeColor: Colors.grey[300],
                    inactiveTrackColor: Theme.of(context).disabledColor,
                    inactiveThumbColor: Colors.grey[300],
                  ),
                  Text("Slider"),
                ],
              ),
              SizedBox(height: 20),
              _useSlider
                  ? Slider(
                      value: _sliderValue,
                      min: 0,
                      max: widget.project.amountInEscrow!,
                      onChanged: (value) {
                        setState(() {
                          _sliderValue = value;
                          _canSubmit = true;
                        });
                      },
                    )
                  : TextFormField(
                      controller: _awardToContractorController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      decoration: InputDecoration(
                        labelText: "Award to Contractor",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _canSubmit = double.tryParse(value) != null && double.parse(value) <= widget.project.amountInEscrow!;
                        });
                      },
                    ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    "Award to Backers",
                    style: Theme.of(context).textTheme.bodySmall!,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${awardToBackers.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: isNegative ? Colors.red : null),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "Award to Contractor",
                    style: Theme.of(context).textTheme.bodySmall!,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${awardToContractor.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: isNegative ? Colors.red : null),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _canSubmit
                ? () {
                    // Add your code here
                  }
                : null,
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 20,
              ),
            ),
            child: Text(
              "Submit",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
````

### lib\widgets\debate_map_widget.dart

```
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

    // We'll allow horizontal scrolling for the entire widget
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text('Depth: $depth'),
          ),
          const SizedBox(width: 36),
          // The vertical columns
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (levels.above.isNotEmpty)
                _buildRow(levels.above, isAbove: true),
              _buildRow(levels.current, isCurrentLevel: true),
              if (levels.below.isNotEmpty)
                _buildRow(levels.below, isBelow: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<Argument> args,
      {bool isAbove = false,
      bool isBelow = false,
      bool isCurrentLevel = false}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Row(
        key: ValueKey(args),
        mainAxisAlignment: MainAxisAlignment.center,
        children: args.map((arg) {
          final isSelected = (arg == currentArgument) && isCurrentLevel;
          return GestureDetector(
            onTap: () => onArgumentSelected(arg),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48, // smaller
              height: 24, // smaller
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: _getBoxColor(arg),
                border: isSelected
                    ? Border.all(color: Colors.black, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Center(
                child: Text(
                  _formatScore(arg.score),
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getBoxColor(Argument arg) {
    if (arg.parent == null) {
      // Root => green if >0 else red
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

  int _calculateDepth(Argument current) {
    int depth = 0;
    Argument? node = current;
    while (node?.parent != null) {
      depth++;
      node = node?.parent;
    }
    return depth;
  }

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
}

class ThreeLevels {
  final List<Argument> above;
  final List<Argument> current;
  final List<Argument> below;
  ThreeLevels(this.above, this.current, this.below);
}

````

### lib\widgets\full_debate_map.dart

```
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

````

### lib\widgets\pro_con_section.dart

```
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
    Key? key,
    required this.debate,
    required this.currentArgument,
    required this.onArgumentSelected,
    this.onDebateChanged,
  }) : super(key: key);

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

````

