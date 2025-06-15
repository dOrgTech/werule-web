import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../entities/proposal.dart';

class NewProposal extends StatefulWidget {
  NewProposal({super.key, required this.p, required this.next});
  Proposal p;
  int stage = 0;
  var next;
  @override
  State<NewProposal> createState() => _NewProposalState();
}

class _NewProposalState extends State<NewProposal> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  final _numberController = TextEditingController();
  bool isProposalSelected = true; // Default selection
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return setInfo();
  }

  void _handleToggle(int index) {
    setState(() {
      isProposalSelected = index == 0; // Set true if "Proposal" is selected
    });
  }

  List<Widget> proposal() {
    return [
      SizedBox(
        width: 460, // Ensure consistent width
        child: TextField(
          onChanged: (value) {
            widget.p.name = value;
          },
          maxLength: 42,
          style: const TextStyle(fontSize: 16),
          decoration: const InputDecoration(
            labelText: "Proposal Title",
          ),
        ),
      ),
      const SizedBox(height: 30),
      SizedBox(
        width: 460, // Ensure consistent width
        child: TextField(
          onChanged: (value) {
            widget.p.description = value;
          },
          maxLength: 200,
          maxLines: 5,
          style: const TextStyle(fontSize: 16),
          decoration: const InputDecoration(
            labelText: "Proposal Description",
          ),
        ),
      ),
      const SizedBox(height: 30),
      SizedBox(
        width: 460, // Ensure consistent width
        child: TextField(
          onChanged: (value) {
            widget.p.externalResource = value;
          },
          maxLength: 42,
          style: const TextStyle(fontSize: 16),
          decoration: const InputDecoration(
            labelText: "Discussion URL",
          ),
        ),
      ),
      const SizedBox(height: 130)
    ];
  }

  bool isBinary = true; // Default selection
  List<Widget> debate() {
    return [
      Row(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: TextField(
              onChanged: (value) {
                widget.p.name = value;
              },
              maxLength: 62,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: "Debate Title",
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isBinary = true; // Switch to Binary mode
                    });
                  },
                  child: Tooltip(
                    message:
                        "A debate with only Pro and Con arguments at the top level.",
                    textStyle: const TextStyle(color: Colors.black87, fontSize: 18),
                    child: Text(
                      "Binary",
                      style: TextStyle(
                        color: isBinary
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : const Color.fromARGB(
                                255, 138, 138, 138), // Active = white
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Switch(
                  value: !isBinary,
                  onChanged: (value) {
                    setState(() {
                      isBinary = !value;
                    });
                  },
                  activeColor: Colors.grey,
                  inactiveThumbColor: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isBinary = false; // Switch to Exploratory mode
                    });
                  },
                  child: Tooltip(
                    message:
                        "A debate with multiple proposals at the top level, each with Pro and Con arguments.",
                    textStyle: const TextStyle(color: Colors.black87, fontSize: 18),
                    child: Text(
                      "Exploratory",
                      style: TextStyle(
                        color: isBinary
                            ? const Color.fromARGB(255, 138, 138, 138)
                            : const Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      const SizedBox(height: 30),
      SizedBox(
        width: 780, // Ensure consistent width
        child: TextFormField(
          maxLines: 19,
          controller: _valueController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText:
                'Write or paste your main thesis here (markdown supported)',
          ),
          validator: (value) => value == null || value.isEmpty
              ? 'Support your position with one or more arguments.'
              : null,
        ),
      ),
      const SizedBox(height: 30),
    ];
  }

  Widget setInfo() {
    return Container(
        constraints: BoxConstraints(
            minWidth: 600,
            minHeight: 500,
            maxWidth: 1000,
            maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.all(10),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(height: 56),
          ToggleSwitch(
            initialLabelIndex: isProposalSelected ? 0 : 1,
            totalSwitches: 2,
            labels: const ['Proposal', 'Debate'],
            activeBgColor: [
              const Color.fromARGB(255, 43, 43, 43).withOpacity(0.3)
            ], // Light blue for active state
            inactiveBgColor:
                Theme.of(context).cardColor, // Light grey for inactive state
            activeFgColor: Colors.white,
            inactiveFgColor: const Color.fromARGB(255, 105, 105, 105),
            borderColor: const [
              Colors.transparent
            ], // Add white border for better visibility
            borderWidth: 1.0, // Border width
            minWidth: 120.0, // Prevent truncation
            cornerRadius: 20.0, // Rounded corners
            onToggle: (index) {
              _handleToggle(index!);
            },
            customTextStyles: const [
              TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ],
          ),
          const Spacer(),
          isProposalSelected
              ? Column(children: proposal())
              : Column(children: debate()),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),
              isProposalSelected == false && isBinary == true
                  ? Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: SizedBox(
                        width: 180,
                        height: 44,
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
                    )
                  : const Text(""),
              ElevatedButton(
                  onPressed: widget.next,
                  child: const SizedBox(
                      width: 68,
                      height: 45,
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Next"),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward)
                        ],
                      )))),
              const SizedBox(width: 20),
            ],
          )
        ]));
  }
}
