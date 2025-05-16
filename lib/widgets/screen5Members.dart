import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../entities/org.dart';
import '../screens/creator.dart';

class Screen5Members extends StatefulWidget {
  final DaoConfig daoConfig;
  final VoidCallback onBack;
  final VoidCallback onNext;

  Screen5Members({
    required this.daoConfig,
    required this.onBack,
    required this.onNext,
  });

  @override
  _Screen5MembersState createState() => _Screen5MembersState();
}

class _Screen5MembersState extends State<Screen5Members> {
  List<MemberEntry> _memberEntries = [];
  bool isManualEntry = false;
  bool isCsvUploaded = false;
  bool isParsingCsv = false;
  int _totalTokens = 0;

  // Pagination
  int _currentPage = 1;
  static const int _entriesPerPage = 50;

  int get _totalPages =>
      (_memberEntries.length / _entriesPerPage).ceil(); // Calculate total pages

  List<MemberEntry> get _paginatedEntries {
    int startIndex = (_currentPage - 1) * _entriesPerPage;
    int endIndex =
        (_currentPage * _entriesPerPage).clamp(0, _memberEntries.length);
    return _memberEntries.sublist(startIndex, endIndex);
  }

  @override
  void initState() {
    super.initState();
    if (widget.daoConfig.members.isNotEmpty) {
      _memberEntries = widget.daoConfig.members
          .map((member) => MemberEntry(
                addressController: TextEditingController(text: member.address),
                amountController: TextEditingController(
                    text: (member.amount ?? 0).toString()),
              ))
          .toList();
    }
    _calculateTotalTokens();
  }

  void _syncMembersToDaoConfig() {
    widget.daoConfig.members = _memberEntries.map((entry) {
      return Member(
        address: entry.addressController.text,
        amount: int.tryParse(entry.amountController.text) ?? 0,
        personalBalance: entry.amountController.text
            .padRight(widget.daoConfig.numberOfDecimals ?? 0, "0"),
        votingWeight: "0",
      );
    }).toList();
  }

  void _addMemberEntry() {
    setState(() {
      _memberEntries.add(MemberEntry(
        addressController: TextEditingController(),
        amountController: TextEditingController(),
      ));
      _syncMembersToDaoConfig();
    });
  }

  Future<List<MemberEntry>> _parseCsvInBackground(String fileContent) async {
    return compute(_processCsvData, fileContent);
  }

  void _loadCsvFile() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.csv';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.length == 1) {
        final file = files[0];
        final reader = html.FileReader();

        reader.onLoadEnd.listen((e) async {
          final contents = reader.result as String;
          setState(() => isParsingCsv = true);

          List<MemberEntry> entries = await _parseCsvInBackground(contents);

          setState(() {
            _memberEntries = entries;
            isCsvUploaded = true;
            isManualEntry = false;
            isParsingCsv = false;
            _currentPage = 1; // Reset pagination
            _calculateTotalTokens();
            _syncMembersToDaoConfig();
          });
        });

        reader.readAsText(file);
      }
    });
  }

  static List<MemberEntry> _processCsvData(String fileContent) {
    List<MemberEntry> entries = [];
    List<String> lines = fileContent
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.isNotEmpty) {
      lines.removeAt(0); // Remove header line

      for (var line in lines) {
        List<String> values = line.split(',');
        if (values.length >= 2) {
          String address = values[0].trim();
          String amount = values[1].trim();

          entries.add(MemberEntry(
            addressController: TextEditingController(text: address),
            amountController: TextEditingController(text: amount),
          ));
        }
      }
    }
    return entries;
  }

  void _calculateTotalTokens() {
    int total = 0;
    for (var entry in _memberEntries) {
      int amount = int.tryParse(entry.amountController.text) ?? 0;
      total += amount;
    }

    widget.daoConfig.totalSupply = total.toString().padRight(
        total.toString().length + (widget.daoConfig.numberOfDecimals ?? 0),
        '0');
    setState(() {
      _totalTokens = total;
    });
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

  Widget _buildInitialButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                isManualEntry = true;
                isCsvUploaded = false;

                // Ensure at least one empty member field is added
                if (_memberEntries.isEmpty) {
                  _addMemberEntry();
                }
              });
            },
            child: SizedBox(
              height: 130,
              width: 170,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.group_add, size: 35),
                  SizedBox(height: 25),
                  Text(
                    "Add members\nmanually",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          TextButton(
            onPressed: _loadCsvFile,
            child: SizedBox(
              height: 130,
              width: 170,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.upload_file,
                    size: 35,
                  ),
                  SizedBox(height: 25),
                  Text("Upload CSV"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntry() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _memberEntries.length,
          itemBuilder: (context, index) {
            return MemberEntryWidget(
              key: ValueKey(
                  index), // Assign a unique key for efficient rebuilding
              entry: _memberEntries[index],
              onRemove: () {
                setState(() {
                  _memberEntries.removeAt(index);
                  _calculateTotalTokens();
                  _syncMembersToDaoConfig();
                });
              },
              onChanged: () {
                _calculateTotalTokens();
                _syncMembersToDaoConfig();
              },
            );
          },
        ),
        const SizedBox(height: 40),
        TextButton.icon(
          onPressed: _addMemberEntry,
          icon: const Icon(Icons.add),
          label: const Text("Add Another Member"),
        ),
        const SizedBox(height: 30),
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Initial members',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 26),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 194, 194, 194),
                ),
                children: [
                  TextSpan(
                    text:
                        'Specify the address and the voting power of your associates.\nVoting power is represented by their amount of tokens.\n\nYou may add the members one by one or upload a CSV\nfile with the following format: ',
                  ),
                  TextSpan(
                    text: 'member',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 194, 194, 194),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  TextSpan(text: ', '),
                  TextSpan(
                    text: 'amount',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 194, 194, 194),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Total Tokens: ', style: TextStyle(fontSize: 19)),
                Text('$_totalTokens',
                    style: TextStyle(
                        fontSize: 19, color: Theme.of(context).indicatorColor)),
              ],
            ),
            const SizedBox(height: 20),
            if (isParsingCsv)
              const LinearProgressIndicator()
            else if (isManualEntry)
              _buildManualEntry()
            else if (isCsvUploaded)
              _buildMembersList()
            else
              _buildInitialButtons(),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: widget.onBack, child: const Text('< Back')),
                ElevatedButton(
                  onPressed: () {
                    _syncMembersToDaoConfig();
                    widget.onNext();
                  },
                  child: const Text('Save and Continue >'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
