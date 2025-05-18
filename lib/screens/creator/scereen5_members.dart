// lib/screens/creator/screen5_members.dart
import 'dart:async';
// import 'dart:convert'; // Not directly used, can be removed if not needed elsewhere by CSV logic
import 'dart:html' as html; // Specific to web for file picking

import 'package:Homebase/entities/org.dart';
import 'package:flutter/foundation.dart'; // For compute
import 'package:flutter/material.dart';

import '../../entities/proposal.dart'; // For Member class
import 'creator_widgets.dart'; // For MemberEntry class and MemberEntryWidget
import 'dao_config.dart'; // For DaoConfig class

class Screen5Members extends StatefulWidget {
  final DaoConfig daoConfig;
  final VoidCallback onBack;
  final VoidCallback onNext;

  Screen5Members({
    required this.daoConfig,
    required this.onBack,
    required this.onNext,
    Key? key,
  }) : super(key: key);

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

  int get _totalPages => _memberEntries.isEmpty
      ? 1
      : (_memberEntries.length / _entriesPerPage).ceil();

  List<MemberEntry> get _paginatedEntries {
    if (_memberEntries.isEmpty) return [];
    int startIndex = (_currentPage - 1) * _entriesPerPage;
    int endIndex =
        (_currentPage * _entriesPerPage).clamp(0, _memberEntries.length);
    return _memberEntries.sublist(startIndex, endIndex);
  }

  @override
  void initState() {
    super.initState();
    if (widget.daoConfig.members.isNotEmpty) {
      _memberEntries = widget.daoConfig.members.map((member) {
        // Assuming member.amount is the value without extra decimals
        // and personalBalance is the string with decimals
        String amountString = member.amount.toString();
        if (member.personalBalance != null &&
            (widget.daoConfig.numberOfDecimals ?? 0) > 0) {
          // Try to infer amount before decimals if personalBalance is set
          if (member.personalBalance!.length >
              (widget.daoConfig.numberOfDecimals ?? 0)) {
            amountString = member.personalBalance!.substring(
                0,
                member.personalBalance!.length -
                    (widget.daoConfig.numberOfDecimals ?? 0));
          }
        }
        return MemberEntry(
          addressController: TextEditingController(text: member.address),
          amountController: TextEditingController(text: amountString),
        );
      }).toList();
    }
    _calculateTotalTokens();
  }

  void _syncMembersToDaoConfig() {
    widget.daoConfig.members = _memberEntries.map((entry) {
      String amountText = entry.amountController.text;
      return Member(
        address: entry.addressController.text,
        amount: int.tryParse(amountText) ?? 0,
        personalBalance:
            amountText + "0" * (widget.daoConfig.numberOfDecimals ?? 0),
        votingWeight: "0", // Default or to be calculated later
      );
    }).toList();
    _calculateTotalTokens(); // Ensure total supply is also updated in DaoConfig
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
            _syncMembersToDaoConfig(); // This will also call _calculateTotalTokens
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
      // Optional: Smart header detection or allow user to specify if header exists
      // For now, assuming first line could be a header if it doesn't look like data
      if (lines.first.toLowerCase().contains('address') ||
          lines.first.toLowerCase().contains('member')) {
        lines.removeAt(0); // Remove header line
      }

      for (var line in lines) {
        List<String> values = line.split(',');
        if (values.length >= 2) {
          String address = values[0].trim();
          String amount = values[1].trim();

          // Basic validation (optional, can be expanded)
          if (address.isNotEmpty &&
              amount.isNotEmpty &&
              int.tryParse(amount) != null) {
            entries.add(MemberEntry(
              addressController: TextEditingController(text: address),
              amountController: TextEditingController(text: amount),
            ));
          }
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
    // Update total tokens for display
    setState(() {
      _totalTokens = total;
    });
    // Update DaoConfig's total supply with decimals
    widget.daoConfig.totalSupply =
        total.toString() + "0" * (widget.daoConfig.numberOfDecimals ?? 0);
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page.clamp(1, _totalPages);
    });
  }

  Widget _buildPaginationControls() {
    if (_totalPages <= 1) return SizedBox.shrink();
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
                if (_memberEntries.isEmpty) {
                  _addMemberEntry();
                } else {
                  _syncMembersToDaoConfig(); // ensure current state is synced before potential changes
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
              key: _memberEntries[index].key ?? ValueKey("member_$index"),
              entry: _memberEntries[index],
              onRemove: () {
                setState(() {
                  _memberEntries[index].addressController.dispose();
                  _memberEntries[index].amountController.dispose();
                  _memberEntries.removeAt(index);
                  _syncMembersToDaoConfig();
                });
              },
              onChanged: () {
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

  Widget _buildMembersListFromCsv() {
    // Renamed for clarity
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            border: Border.all(color: Colors.grey.shade700),
          ),
          height: 300, // Restrict height for scrollable area
          child: _paginatedEntries.isEmpty
              ? Center(
                  child: Text("No members found in CSV or CSV not loaded."))
              : ListView.builder(
                  itemCount: _paginatedEntries.length,
                  itemBuilder: (context, index) {
                    final memberEntry = _paginatedEntries[index];
                    // For CSV display, fields are typically read-only in this view
                    // So, we can use simple TextFields or disabled TextFields
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: TextFormField(
                              controller: memberEntry.addressController,
                              decoration: const InputDecoration(
                                  labelText: 'Member Address'),
                              readOnly: true, // CSV data is read-only here
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: memberEntry.amountController,
                              decoration:
                                  const InputDecoration(labelText: 'Amount'),
                              readOnly: true, // CSV data is read-only here
                            ),
                          ),
                          SizedBox(
                              width: 48), // Placeholder for remove button space
                        ],
                      ),
                    );
                  },
                ),
        ),
        _buildPaginationControls(),
      ],
    );
  }

  @override
  void dispose() {
    for (var entry in _memberEntries) {
      entry.addressController.dispose();
      entry.amountController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Initial members',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 26),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 194, 194, 194),
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text:
                        'Specify the address and the voting power (token amount) for initial members.\nAdd manually or upload a CSV with columns: ',
                  ),
                  TextSpan(
                    text: 'address,amount',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  TextSpan(text: '. (No header row needed)'),
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: LinearProgressIndicator(),
              )
            else if (isManualEntry)
              _buildManualEntry()
            else if (isCsvUploaded)
              _buildMembersListFromCsv()
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
// lib/screens/creator/screen5_members.dart
