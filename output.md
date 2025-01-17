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
            style: Theme.of(context).textTheme.headline5!,
          ),
          SizedBox(height: 20),
          Text(
            "Amount in Escrow: ${widget.project.amountInEscrow!}",
            style: Theme.of(context).textTheme.subtitle1!,
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
                    style: Theme.of(context).textTheme.subtitle1!,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${awardToBackers.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(color: isNegative ? Colors.red : null),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "Award to Contractor",
                    style: Theme.of(context).textTheme.subtitle1!,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${awardToContractor.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(color: isNegative ? Colors.red : null),
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

