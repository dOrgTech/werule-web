import 'package:Homebase/entities/definitions.dart';
import 'package:Homebase/widgets/newProposal.dart';
import 'package:flutter/material.dart';
import '../debates/models/argument.dart';
import '../debates/models/debate.dart';
import '../entities/contractFunctions.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';
import '../screens/dao.dart';
import 'package:lottie/lottie.dart';

class NewDebate extends StatefulWidget {
  late Debate p;
  Member? member;
  Org org;
  int stage = 0;
  State proposalsState;
  bool isSetInfo = true;
  NewDebate({Key? key, required this.proposalsState, required this.org})
      : super(key: key);

  @override
  State<NewDebate> createState() => _DebateState();
}

class _DebateState extends State<NewDebate> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  final _numberController = TextEditingController();

  bool _isSubmitEnabled = false;

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _keyController.addListener(_updateSubmitButtonState);
    _valueController.addListener(_updateSubmitButtonState);
    _numberController.addListener(_updateSubmitButtonState);
  }

  void _updateSubmitButtonState() {
    setState(() {
      _isSubmitEnabled = _keyController.text.isNotEmpty &&
          _valueController.text.length >= 2 &&
          _numberController.text.isNotEmpty &&
          int.tryParse(_numberController.text) != null &&
          int.parse(_numberController.text) > 0;
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {}
  }

  finishSettingInfo() {
    setState(() {
      widget.isSetInfo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.stage == -1
        ? const AwaitingConfirmation()
        : Form(
            key: _formKey,
            child: Container(
              width: 650,
              padding: const EdgeInsets.all(26.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 52.0),
                    child: TextFormField(
                      onChanged: (value) {},
                      controller: _keyController,
                      decoration:
                          const InputDecoration(labelText: 'Debate Title'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Debate Title'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    maxLines: 26,
                    controller: _valueController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText:
                          'Write your main thesis here (markdown supported)',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Support your position with one or more arguments.'
                        : null,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 180,
                        child: TextFormField(
                          controller: _numberController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Weight',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Invalid weight';
                            }
                            final n = int.tryParse(value);
                            if (n == null || n <= 0) {
                              return 'Enter a positive number';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 40),
                      SubmitButton(
                        submit: () async {
                          Argument root = Argument(
                              content: _valueController.text,
                              author: '0xsoaidsjoaijdoie23',
                              weight: double.parse(_numberController.text));
                          int.parse(_numberController.text);
                          setState(() {
                            widget.stage = -1;
                          });
                          try {
                            // String cevine = await propose(widget.p);
                            widget.p = Debate(
                                org: widget.org,
                                title: _keyController.text,
                                rootArgument: root);
                            String cevine = await widget.org.createDebate(
                              widget.p,
                            );
                            if (cevine.contains("not ok")) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                      duration: Duration(seconds: 1),
                                      content: Center(
                                          child: SizedBox(
                                              height: 70,
                                              child: Center(
                                                child: Text(
                                                  "Error submitting debate",
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      color: Colors.red),
                                                ),
                                              )))));
                              Navigator.of(context).pop();
                              return;
                            }
                            widget.org.debates.add(widget.p);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Center(
                                        child: SizedBox(
                                            height: 70,
                                            child: Center(
                                              child: Text(
                                                "Debate submitted",
                                                style: TextStyle(fontSize: 24),
                                              ),
                                            )))));
                          } catch (e) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Center(
                                        child: SizedBox(
                                            height: 70,
                                            child: Center(
                                              child: Text(
                                                "Error submitting debate",
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    color: Colors.red),
                                              ),
                                            )))));
                          }
                          Navigator.of(context).pop();
                        },
                        isSubmitEnabled: _isSubmitEnabled,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
  }
}

class SubmitButton extends StatefulWidget {
  SubmitButton(
      {super.key, required this.submit, required this.isSubmitEnabled});
  bool isSubmitEnabled;
  var submit;
  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 160, // Ensure consistent width
      child: TextButton(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all<Color>(
              Theme.of(context).indicatorColor),
          backgroundColor: widget.isSubmitEnabled
              ? MaterialStateProperty.all<Color>(
                  Theme.of(context).indicatorColor)
              : MaterialStateProperty.all<Color>(Colors.grey), // Disabled color
          elevation: MaterialStateProperty.all(1.0),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.0),
            ),
          ),
        ),
        onPressed: widget.isSubmitEnabled
            ? widget.submit
            : null, // Enable/disable based on validation
        child: const Center(
          child: Text(
            "SUBMIT",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class AwaitingConfirmation extends StatelessWidget {
  const AwaitingConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 500,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Transaction pending...",
              style: TextStyle(fontSize: 26),
            ),
            SizedBox(height: 20),
            SizedBox(height: 50),
            SizedBox(
              height: 250,
              width: 250,
              child: Lottie.asset("assets/d4.json"),
            )
          ],
        ),
      ),
    );
  }
}
