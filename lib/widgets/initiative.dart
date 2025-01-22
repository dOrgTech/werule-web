import "package:Homebase/debates/models/argument.dart";
import "package:Homebase/screens/proposals.dart";
import "package:flutter/material.dart";
import "package:toggle_switch/toggle_switch.dart";
import "../debates/models/debate.dart";
import "../entities/org.dart";
import "../entities/proposal.dart";

class Initiative extends StatefulWidget {
  Initiative({
    required this.org,
    super.key,
  });
  Org org;
  late Debate d;
  late Proposal p;
  late Object thing;
  Widget? proposalType;
  int phase = 0;
  @override
  State<Initiative> createState() => InitiativeState();
}

class InitiativeState extends State<Initiative> {
  List<TxEntry> txEntries = [];
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  int _currentPage = 1;
  bool isProposalSelected = true; // Default selection
  bool _isSubmitEnabled = false;
  static const int _entriesPerPage = 50;

  int get _totalPages =>
      (txEntries.length / _entriesPerPage).ceil(); // Calculate total pages

  List<TxEntry> get _paginatedEntries {
    int startIndex = (_currentPage - 1) * _entriesPerPage;
    int endIndex = (_currentPage * _entriesPerPage).clamp(0, txEntries.length);
    return txEntries.sublist(startIndex, endIndex);
  }

  @override
  void initState() {
    super.initState();
    widget.d = Debate(
        org: widget.org,
        rootArgument: Argument(content: _descriptionController.text, weight: 0),
        title: _nameController.text);
    widget.p = Proposal(
      org: widget.org,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.phase) {
      case 0:
        return enterInfo();
      case 1:
        return selectProposalType();
      case 2:
        return review();
      default:
        return enterInfo();
    }
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
          controller: _nameController,
          onChanged: (value) {
            widget.p.name = value;
          },
          maxLength: 42,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: "Proposal Title",
          ),
        ),
      ),
      const SizedBox(height: 30),
      SizedBox(
        width: 460, // Ensure consistent width
        child: TextField(
          controller: _descriptionController,
          onChanged: (value) {
            widget.p.description = value;
          },
          maxLength: 200,
          maxLines: 5,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: "Proposal Description",
          ),
        ),
      ),
      const SizedBox(height: 30),
      SizedBox(
        width: 460, // Ensure consistent width
        child: TextField(
          controller: _urlController,
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
              controller: _nameController,
              onChanged: (value) {
                widget.p.name = value;
              },
              maxLength: 62,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
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
                    message: "Yields a \"Yes\" or \"No\" answer.",
                    textStyle: TextStyle(color: Colors.black87, fontSize: 18),
                    child: Text(
                      "Binary",
                      style: TextStyle(
                        color: isBinary
                            ? Color.fromARGB(255, 255, 255, 255)
                            : Color.fromARGB(
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
                      // widget.p
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
                    message: "Great for answering \"How?\" questions.",
                    textStyle: TextStyle(color: Colors.black87, fontSize: 18),
                    child: Text(
                      "Exploratory",
                      style: TextStyle(
                        color: isBinary
                            ? Color.fromARGB(255, 138, 138, 138)
                            : Color.fromARGB(255, 255, 255, 255),
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
      SizedBox(height: 30),
      SizedBox(
        width: 780, // Ensure consistent width
        child: TextFormField(
          maxLines: 19,
          controller: _descriptionController,
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

  Widget enterInfo() {
    return Container(
        constraints: BoxConstraints(
            minWidth: 600,
            minHeight: 500,
            maxWidth: 1000,
            maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: EdgeInsets.all(10),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(height: 56),
          ToggleSwitch(
            initialLabelIndex: isProposalSelected ? 0 : 1,
            totalSwitches: 2,
            labels: ['Proposal', 'Debate'],
            activeBgColor: [
              Color.fromARGB(255, 43, 43, 43).withOpacity(0.3)
            ], // Light blue for active state
            inactiveBgColor:
                Theme.of(context).cardColor, // Light grey for inactive state
            activeFgColor: Colors.white,
            inactiveFgColor: Color.fromARGB(255, 105, 105, 105),
            borderColor: [
              Colors.transparent
            ], // Add white border for better visibility
            borderWidth: 1.0, // Border width
            minWidth: 120.0, // Prevent truncation
            cornerRadius: 20.0, // Rounded corners
            onToggle: (index) {
              _handleToggle(index!);
            },
            customTextStyles: [
              TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ],
          ),
          Spacer(),
          isProposalSelected
              ? Column(children: proposal())
              : Column(children: debate()),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Spacer(),
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
                  : Text(""),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      widget.phase = 1;
                    });
                  },
                  child: SizedBox(
                      width: 68,
                      height: 45,
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Next"),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward)
                        ],
                      )))),
              SizedBox(width: 20),
            ],
          )
        ]));
  }

  Widget _buildMembersList() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            border: Border.all(color: Colors.grey.shade700),
          ),
          height: 500, // Restrict height for scrollable area
          child: ListView.builder(
            itemCount: _paginatedEntries.length,
            itemBuilder: (context, index) {
              final memberEntry = _paginatedEntries[index];
              return MemberEntryWidget(
                key: ValueKey(index + ((_currentPage - 1) * _entriesPerPage)),
                entry: memberEntry,
                onRemove: () {}, // CSV mode has no remove functionality
                onChanged: () {}, // CSV mode is read-only
              );
            },
          ),
        ),
        _buildPaginationControls(),
      ],
    );
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page.clamp(1, _totalPages);
    });
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: _currentPage > 1 ? () => _changePage(1) : null,
        ),
        IconButton(
          icon: const Icon(Icons.navigate_before),
          onPressed:
              _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
        ),
        Text('Page $_currentPage of $_totalPages'),
        IconButton(
          icon: const Icon(Icons.navigate_next),
          onPressed: _currentPage < _totalPages
              ? () => _changePage(_currentPage + 1)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: _currentPage < _totalPages
              ? () => _changePage(_totalPages)
              : null,
        ),
      ],
    );
  }

  selectProposalType() {
    return !(widget.proposalType == null)
        ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 560, child: widget.proposalType!),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          widget.proposalType = null;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back),
                          const SizedBox(width: 8),
                          Text("Back"),
                        ],
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Next"),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward)
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        : Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProposalList(org: widget.org, initiativeState: this),
              TextButton(
                  onPressed: () {
                    setState(() {
                      widget.phase = 0;
                    });
                  },
                  child: SizedBox(
                      width: 68,
                      height: 45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.arrow_back),
                          const SizedBox(width: 8),
                          Text("Back"),
                          Spacer()
                        ],
                      ))),
            ],
          ));
  }

  review() {
    return const Center(
      child: Text(
        "review",
        style: TextStyle(fontSize: 30),
      ),
    );
  }
}

class TxEntry {
  TextEditingController addressController;
  TextEditingController amountController;
  ValueKey? key;
  TxEntry(
      {this.key,
      required this.addressController,
      required this.amountController});
}

class MemberEntryWidget extends StatelessWidget {
  final TxEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  ValueKey? key;
  MemberEntryWidget(
      {this.key,
      required this.entry,
      required this.onRemove,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 700,
          child: Row(
            children: [
              // Member Address
              Expanded(
                flex: 7,
                child: TextField(
                  controller: entry.addressController,
                  maxLength: 42,
                  decoration: const InputDecoration(
                    labelText: 'Member Address',
                    counterText: '',
                  ),
                  onChanged: (value) => onChanged(),
                ),
              ),
              const SizedBox(width: 16),
              // Amount
              Expanded(
                flex: 3,
                child: TextField(
                  controller: entry.amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  onChanged: (value) => onChanged(),
                ),
              ),
              // Remove Button
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
