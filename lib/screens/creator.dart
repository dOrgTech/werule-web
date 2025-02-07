import 'dart:typed_data';

import 'package:Homebase/main.dart';
import 'package:Homebase/utils/theme.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../entities/contractFunctions.dart';
import '../entities/human.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';
import '../entities/token.dart';
import '../widgets/pleadingForLessDecimals.dart';
import '../widgets/screen5Members.dart';
import 'dao.dart';
import 'explorer.dart';
import "package:file_picker/file_picker.dart";
import 'package:csv/csv.dart';
import 'dart:convert';
import '/utils/reusable.dart';
import 'package:pointycastle/digests/keccak.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

String toChecksumAddress(String address) {
  // Remove the 0x prefix if present
  address = address.replaceFirst('0x', '').toLowerCase();

  // Compute the keccak256 hash of the address
  var hashedAddress = keccak256(utf8.encode(address));
  var hashString = bytesToHex(hashedAddress);

  // Apply the checksum rule
  String checksummedAddress = '0x';
  for (int i = 0; i < address.length; i++) {
    if (int.parse(hashString[i], radix: 16) >= 8) {
      checksummedAddress += address[i].toUpperCase();
    } else {
      checksummedAddress += address[i];
    }
  }

  return checksummedAddress;
}

List<int> keccak256(List<int> input) {
  final keccak = KeccakDigest(256);
  return keccak.process(Uint8List.fromList(input));
}

String bytesToHex(List<int> bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
}

// Screen 1: Select DAO type
class Screen1DaoType extends StatelessWidget {
  final DaoConfig daoConfig;
  final VoidCallback onNext;
  _DaoSetupWizardState daoConfigState;

  Screen1DaoType(
      {required this.daoConfigState,
      required this.daoConfig,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    List<Widget> options = [
      SizedBox(
        width: 340,
        height: 310,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: TextButton(
            onPressed: () {
              daoConfig.daoType = 'debates';
              daoConfigState.setState(() {
                daoConfigState.widget.org.debatesOnly = false;
              });
              daoConfig.daoType = 'Full DAO';
              onNext();
            },
            child: Container(
              margin: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromARGB(255, 56, 56, 56)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 34),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 35),
                      FlashingIcon(),
                      SizedBox(width: 17),
                      SizedBox(
                          width: 150,
                          height: 30,
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 489),
                              child: AnimatedTextKit(
                                onTap: () {},
                                isRepeatingAnimation: false,
                                repeatForever: false,
                                animatedTexts: [
                                  ColorizeAnimatedText('Full DAO',
                                      textStyle: meniu,
                                      textDirection: TextDirection.ltr,
                                      speed: const Duration(milliseconds: 700),
                                      colors: [
                                        const Color.fromARGB(
                                            255, 219, 219, 219),
                                        const Color.fromARGB(
                                            255, 251, 251, 251),
                                        const Color.fromARGB(
                                            255, 255, 180, 110),
                                        Colors.yellow,
                                        const Color.fromARGB(
                                            255, 255, 169, 163),
                                        const Color.fromARGB(
                                            255, 255, 243, 139),
                                        Colors.amber,
                                        const Color(0xff343434)
                                      ]),
                                ],
                              ))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'All important operations are secured by the will of the members through voting.',
                      style: TextStyle(height: 1.3),
                      textAlign: TextAlign.center,
                      // textScaleFactor: 1.2,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 31),
                      child: Text(
                        "Executive and Declarative",
                        style:
                            TextStyle(color: Theme.of(context).indicatorColor),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
      // Option 2: Off-chain
      SizedBox(
        width: 340,
        height: 310,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: TextButton(
            onPressed: () {
              daoConfig.daoType = 'debates';
              daoConfigState.setState(() {
                daoConfigState.widget.org.debatesOnly = true;
              });
              onNext();
            },
            child: Container(
              margin: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromARGB(255, 56, 56, 56)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 33),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          child: Image.asset("assets/img/debate_tree_icon.png",
                              height: 65)),
                      const SizedBox(width: 9),
                      const Text('Tokenized\nDebates',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 21)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Padding(
                    padding: EdgeInsets.only(
                        left: 13.0, right: 13, top: 20, bottom: 1),
                    child: Text(
                      "Parse topics through binary trees of weighted arguments.",
                      style: TextStyle(height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 38),
                      child: Text(
                        "Declarative",
                        style:
                            TextStyle(color: Theme.of(context).indicatorColor),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    ];

    return SingleChildScrollView(
      // Ensure content can scroll
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Will you be needing a treasury?',
                style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: 26),
            const SizedBox(
                width: 510,
                child: Text(
                    "For distributed management of collective assets, you will need to deploy a Full DAO. If you just want collective ideation and large-scale brainstorming, pick Debates. Another valid reason to pick Debates is if you're too chickenshit to start a Full DAO.\n\nThe Full DAO includes the Tokenized Debates system.\n\nThe Debates instance can be upgraded to a Full DAO at a later time, should the fear subside.",
                    style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 194, 194, 194)))),
            const SizedBox(height: 21),
            MediaQuery.of(context).size.aspectRatio > 0.9
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: options,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: options,
                  ),
            const SizedBox(height: 130)
          ],
        ),
      ),
    );
  }
}

// Screen 2: Basic Setup
class Screen2BasicSetup extends StatefulWidget {
  final DaoConfig daoConfig;
  final VoidCallback onNext;
  final VoidCallback onBack;
  bool memeNotShown = true;
  Screen2BasicSetup(
      {required this.daoConfig, required this.onNext, required this.onBack});

  @override
  _Screen2BasicSetupState createState() => _Screen2BasicSetupState();
}

class _Screen2BasicSetupState extends State<Screen2BasicSetup> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _daoNameController;
  late TextEditingController _daoDescriptionController;
  late TextEditingController _tokenSymbolController;
  late TextEditingController _numberOfDecimalsController;
  late bool _nonTransferrable;

  @override
  void initState() {
    super.initState();
    _daoNameController = TextEditingController(text: widget.daoConfig.daoName);
    _daoDescriptionController =
        TextEditingController(text: widget.daoConfig.daoDescription);
    _tokenSymbolController =
        TextEditingController(text: widget.daoConfig.tokenSymbol);
    _numberOfDecimalsController = TextEditingController(
        text: widget.daoConfig.numberOfDecimals?.toString());
    _nonTransferrable = widget.daoConfig.nonTransferrable;
  }

  @override
  void dispose() {
    _daoNameController.dispose();
    _daoDescriptionController.dispose();
    _tokenSymbolController.dispose();
    _numberOfDecimalsController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate()) {
      widget.daoConfig.daoName = _daoNameController.text;
      widget.daoConfig.daoDescription = _daoDescriptionController.text;
      widget.daoConfig.tokenSymbol = _tokenSymbolController.text;
      widget.daoConfig.numberOfDecimals =
          int.parse(_numberOfDecimalsController.text);
      widget.daoConfig.nonTransferrable = _nonTransferrable;
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Ensure content can scroll
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.aspectRatio > 0.9 ? 70 : 3),
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 500,
            child: Column(
              children: [
                Text("Organization identity",
                    style: Theme.of(context).textTheme.headline5),
                const SizedBox(height: 120),
                SizedBox(
                  width: 500,
                  child: TextFormField(
                    controller: _daoNameController,
                    maxLength: 38,
                    decoration: const InputDecoration(labelText: 'DAO Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name for your organization';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  width: 500,
                  child: TextFormField(
                    controller: _daoDescriptionController,
                    maxLength: 400,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        labelText: 'Description or Tagline'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'What is this community about at a high level?';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: 500,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 7,
                        child: TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9]')),
                            UpperCaseTextFormatter(),
                          ],
                          maxLength: 5,
                          controller: _tokenSymbolController,
                          decoration: const InputDecoration(
                              counterText: "", labelText: 'Ticker Symbol'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'The ticker symbol of the governance token';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          onChanged: (value) {
                            int? decimals = int.tryParse(value);
                            if (decimals != null &&
                                decimals > 6 &&
                                widget.memeNotShown) {
                              widget.memeNotShown = false;
                              showDialog(
                                context: context,
                                builder: ((context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.transparent,
                                    contentPadding: EdgeInsets.zero,
                                    content: SizedBox(
                                      width: 500, // Control width
                                      height: 550, // Control height
                                      child: AnimatedMemeWidget(),
                                    ),
                                  );
                                }),
                              );
                            }
                          },
                          controller: _numberOfDecimalsController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Decimals'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'How many decimal points do want for your governance token?';
                            }
                            int? decimals = int.tryParse(value);

                            if (decimals == null ||
                                decimals < 0 ||
                                decimals > 7) {
                              return 'between 0 and 6';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 300,
                  child: CheckboxListTile(
                    title: Text('Non-transferrable'),
                    value: true,
                    onChanged: null,
                  ),
                ),
                const SizedBox(height: 56),
                SizedBox(
                  width: 700,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: widget.onBack,
                        child: const Text('< Back'),
                      ),
                      ElevatedButton(
                        onPressed: _saveAndNext,
                        child: const Text('Save and Continue >'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Screen 3: Quorums
class Screen3Quorums extends StatefulWidget {
  final DaoConfig daoConfig;
  final VoidCallback onNext;
  final VoidCallback onBack;

  Screen3Quorums(
      {required this.daoConfig, required this.onNext, required this.onBack});

  @override
  _Screen3QuorumsState createState() => _Screen3QuorumsState();
}

class _Screen3QuorumsState extends State<Screen3Quorums> {
  double _quorumThreshold = 6.0;
  double _proposalThreshold = 1.0;
  late double _supermajority; // Added supermajority variable
  late TextEditingController thresholdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quorumThreshold = widget.daoConfig.quorumThreshold?.toDouble() ?? 0;
    _proposalThreshold = widget.daoConfig.proposalThreshold!.toDouble() ?? 1.0;
    _supermajority = widget.daoConfig.supermajority; // Default at 75%
    thresholdController.text = widget.daoConfig.proposalThreshold.toString();
  }

  void _saveAndNext() {
    // Save the values
    widget.daoConfig.quorumThreshold = _quorumThreshold.toInt();
    widget.daoConfig.supermajority = _supermajority;
    widget.daoConfig.proposalThreshold = int.parse(thresholdController.text);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Ensure content can scroll
      child: Padding(
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.aspectRatio > 0.9 ? 38.0 : 3,
            right: MediaQuery.of(context).size.aspectRatio > 0.9 ? 38.0 : 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 78, 78, 78),
                      width: 0.4)),
              padding: EdgeInsets.all(
                  MediaQuery.of(context).size.aspectRatio > 0.9 ? 35 : 3),
              child: Column(
                children: [
                  Text('Quorum', style: Theme.of(context).textTheme.headline5),
                  const SizedBox(height: 26),
                  Text('${_quorumThreshold.toStringAsFixed(0)} %',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 27,
                          color: Theme.of(context).indicatorColor)),
                  const SizedBox(height: 36),
                  SizedBox(
                      width: 500,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Slider(
                            min: 0,
                            max: 99,
                            divisions: 99,
                            value: _quorumThreshold,
                            label: _quorumThreshold.round().toString() + '%',
                            onChanged: (value) {
                              setState(() {
                                _quorumThreshold = value;
                              });
                            },
                          ),
                          const Text(
                              'Minimum participation required for a proposal to pass'),
                          const SizedBox(height: 5),
                        ],
                      )),
                ],
              ),
            ),
            const SizedBox(height: 36),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 78, 78, 78),
                      width: 0.4)),
              padding: const EdgeInsets.all(35),
              child: SizedBox(
                width: 500,
                child: Column(
                  children: [
                    Text('Proposal Threashold',
                        style: Theme.of(context).textTheme.headline5),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: thresholdController,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: widget.daoConfig.tokenSymbol == null
                              ? "SYM" + " amount"
                              : widget.daoConfig.tokenSymbol! + " amount",
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    const Text('Minimum voting power to submit a proposal'),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 56),
            SizedBox(
              width: 700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: widget.onBack,
                    child: const Text('< Back'),
                  ),
                  ElevatedButton(
                    onPressed: _saveAndNext,
                    child: const Text('Save and Continue >'),
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

// Screen 4: Durations
class Screen4Durations extends StatefulWidget {
  final DaoConfig daoConfig;
  final VoidCallback onNext;
  final VoidCallback onBack;

  Screen4Durations(
      {required this.daoConfig, required this.onNext, required this.onBack});

  @override
  _Screen4DurationsState createState() => _Screen4DurationsState();
}

class _Screen4DurationsState extends State<Screen4Durations> {
  late TextEditingController _votingDurationDaysController;
  late TextEditingController _votingDurationHoursController;
  late TextEditingController _votingDurationMinutesController;
  late TextEditingController _votingDelayDaysController;
  late TextEditingController _votingDelayHoursController;
  late TextEditingController _votingDelayMinutesController;
  late TextEditingController _executionDelayDaysController; // New controller
  late TextEditingController _executionDelayHoursController; // New controller
  late TextEditingController _executionDelayMinutesController; // New controller

  @override
  void initState() {
    super.initState();
    _votingDurationDaysController = TextEditingController();
    _votingDurationHoursController = TextEditingController();
    _votingDurationMinutesController = TextEditingController();
    _votingDelayDaysController = TextEditingController();
    _votingDelayHoursController = TextEditingController();
    _votingDelayMinutesController = TextEditingController();
    _executionDelayDaysController = TextEditingController(); // Initialize
    _executionDelayHoursController = TextEditingController(); // Initialize
    _executionDelayMinutesController = TextEditingController(); // Initialize
  }

  void _saveAndNext() {
    // Save the values
    int votingDurationDays =
        int.tryParse(_votingDurationDaysController.text) ?? 0;
    int votingDurationHours =
        int.tryParse(_votingDurationHoursController.text) ?? 0;
    int votingDurationMinutes =
        int.tryParse(_votingDurationMinutesController.text) ?? 0;
    widget.daoConfig.votingDuration = Duration(
        days: votingDurationDays,
        hours: votingDurationHours,
        minutes: votingDurationMinutes);

    int votingDelayDays = int.tryParse(_votingDelayDaysController.text) ?? 0;
    int votingDelayHours = int.tryParse(_votingDelayHoursController.text) ?? 0;
    int votingDelayMinutes =
        int.tryParse(_votingDelayMinutesController.text) ?? 0;
    widget.daoConfig.votingDelay = Duration(
        days: votingDelayDays,
        hours: votingDelayHours,
        minutes: votingDelayMinutes);

    int executionDelayDays =
        int.tryParse(_executionDelayDaysController.text) ?? 0;
    int executionDelayHours =
        int.tryParse(_executionDelayHoursController.text) ?? 0;
    int executionDelayMinutes =
        int.tryParse(_executionDelayMinutesController.text) ?? 0;
    widget.daoConfig.executionDelay = Duration(
        days: executionDelayDays,
        hours: executionDelayHours,
        minutes: executionDelayMinutes);

    widget.onNext();
  }

  @override
  void dispose() {
    _votingDurationDaysController.dispose();
    _votingDurationHoursController.dispose();
    _votingDurationMinutesController.dispose();
    _votingDelayDaysController.dispose();
    _votingDelayHoursController.dispose();
    _votingDelayMinutesController.dispose();
    _executionDelayDaysController.dispose();
    _executionDelayHoursController.dispose();
    _executionDelayMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Ensure content can scroll
      child: Padding(
        padding: const EdgeInsets.all(38.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Set the durations of proposal stages',
                style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: 86),

            // Voting Delay
            SizedBox(
              width: 500,
              child: DurationInput(
                title: 'Voting Delay',
                description:
                    'How much time between submitting a proposal and the start of the voting period',
                daysController: _votingDelayDaysController,
                hoursController: _votingDelayHoursController,
                minutesController: _votingDelayMinutesController,
              ),
            ),
            const SizedBox(height: 76),
            // Voting Duration
            SizedBox(
              width: 500,
              child: DurationInput(
                title: 'Voting Duration',
                description: 'How long a proposal will be open for voting',
                daysController: _votingDurationDaysController,
                hoursController: _votingDurationHoursController,
                minutesController: _votingDurationMinutesController,
              ),
            ),
            const SizedBox(height: 76),
            // Execution Availability
            SizedBox(
              width: 500,
              child: DurationInput(
                title: 'Execution Delay',
                description:
                    'After the proposal passes and before it can be executed.',
                daysController: _executionDelayDaysController,
                hoursController: _executionDelayHoursController,
                minutesController: _executionDelayMinutesController,
              ),
            ),
            const SizedBox(height: 86),
            SizedBox(
              width: 700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: widget.onBack,
                    child: const Text('< Back'),
                  ),
                  ElevatedButton(
                    onPressed: _saveAndNext,
                    child: const Text('Save and Continue >'),
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

// Custom widget for duration input
class DurationInput extends StatelessWidget {
  final String title;
  final String description;
  final TextEditingController daysController;
  final TextEditingController hoursController;
  final TextEditingController minutesController;

  DurationInput({
    required this.title,
    required this.description,
    required this.daysController,
    required this.hoursController,
    required this.minutesController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: daysController,
                maxLength: 2,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Days',
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: hoursController,
                maxLength: 2,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Hours',
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: minutesController,
                maxLength: 2,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minutes',
                  counterText: '',
                ),
              ),
            ),
          ],
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(description),
        ],
      ],
    );
  }
}

// Helper classes for member entries
class MemberEntry {
  TextEditingController addressController;
  TextEditingController amountController;
  ValueKey? key;
  MemberEntry(
      {this.key,
      required this.addressController,
      required this.amountController});
}

class MemberEntryWidget extends StatelessWidget {
  final MemberEntry entry;
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

// Screen 6: Review & Deploy
class Screen6Review extends StatelessWidget {
  final DaoConfig daoConfig;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  Screen6Review({
    required this.daoConfig,
    required this.onBack,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    // Helper function to format durations
    String formatDuration(Duration? duration) {
      if (duration == null) return 'Not set';
      int days = duration.inDays;
      int hours = duration.inHours % 24;
      int minutes = duration.inMinutes % 60;
      return '$days days, $hours hours, $minutes minutes';
    }

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(38.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Review & Deploy',
                  style: Theme.of(context).textTheme.headline5),
              const SizedBox(height: 30),
              Text('${daoConfig.daoType} Organization'),
              const SizedBox(height: 10),
              Text('${daoConfig.daoName}'),
              const SizedBox(height: 10),
              Container(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Text('${daoConfig.daoDescription}')),
              const SizedBox(height: 10),
              Text('Ticker Symbol: ${daoConfig.tokenSymbol}'),
              const SizedBox(height: 10),
              Text('Number of Decimals: ${daoConfig.numberOfDecimals}'),
              const SizedBox(height: 10),
              Text(
                  'Non-Transferrable: ${daoConfig.nonTransferrable ? 'Yes' : 'No'}'),
              const SizedBox(height: 30),
              Text('Quorum Threshold: ${daoConfig.quorumThreshold}%'),
              const SizedBox(height: 30),
              Text(
                  'Voting Duration: ${formatDuration(daoConfig.votingDuration)}'),
              const SizedBox(height: 10),
              Text('Voting Delay: ${formatDuration(daoConfig.votingDelay)}'),
              const SizedBox(height: 10),
              Text(
                  'Execution Availability: ${formatDuration(daoConfig.executionDelay)}'),
              const SizedBox(height: 30),
              const Text('Members:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DataTable(
                columns: const [
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: daoConfig.members.map((member) {
                  return DataRow(cells: [
                    DataCell(Text(member.address)),
                    DataCell(Text(member.amount.toString())),
                  ]);
                }).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 700,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: onBack,
                      child: const Text('< Back'),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              createMaterialColor(
                                  Theme.of(context).indicatorColor))),
                      onPressed: onFinish,
                      child: const SizedBox(
                          width: 120,
                          height: 45,
                          child: Center(
                              child: Text('Deploy',
                                  style: TextStyle(fontSize: 19)))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Screen 7: Deploying
class Screen7Deploying extends StatelessWidget {
  final String daoName;

  Screen7Deploying({required this.daoName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        // Center the content vertically and horizontally
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
              height: 100, width: 100, child: CircularProgressIndicator()),
          const SizedBox(height: 50),
          Text('Deploying $daoName to the ${Human().chain.name} blockchain...'),
        ],
      ),
    );
  }
}

// Screen 8: Deployment Complete
class Screen8DeploymentComplete extends StatelessWidget {
  final String daoName;
  final VoidCallback onGoToDAO;

  Screen8DeploymentComplete({required this.daoName, required this.onGoToDAO});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        // Center the content vertically and horizontally
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Deployment Complete!',
              style: Theme.of(context).textTheme.headline5),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: onGoToDAO,
            child: const Text('Go to DAO'),
          ),
        ],
      ),
    );
  }
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

class FlashingIcon extends StatefulWidget {
  @override
  _FlashingIconState createState() => _FlashingIconState();
}

class _FlashingIconState extends State<FlashingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 1200), // Total duration of one cycle
    );

    // Define a Tween sequence to control the timing for each part of the animation
    _colorAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          tween: ColorTween(
              begin: Colors.white,
              end: const Color.fromARGB(255, 255, 180, 110)),
          weight: 600, // First phase: 300 ms for white to bright gold
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.yellow, end: Colors.white),
          weight: 600, // Second phase: 1000 ms for bright gold back to white
        ),
      ],
    ).animate(_controller);

    // Loop the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Image.asset("assets/img/daomic.png", height: 60);
      },
    );
  }
}

TextStyle meniu =
    const TextStyle(fontSize: 24, color: Color.fromARGB(255, 178, 178, 178));

class DaoConfig {
  String? daoType;
  String? daoName;
  String? daoDescription;
  String? tokenSymbol;
  String? totalSupply;
  Map<String, String> registry = {};
  int? numberOfDecimals;
  int? proposalThreshold = 1;
  bool nonTransferrable = true;
  int quorumThreshold = 4;
  double supermajority = 75.0;
  Duration? votingDuration;
  Duration? votingDelay;
  Duration? executionDelay;
  List<Member> members = [];
  DaoConfig();
}

class DaoSetupWizard extends StatefulWidget {
  late Org org;

  @override
  _DaoSetupWizardState createState() => _DaoSetupWizardState();
}

class _DaoSetupWizardState extends State<DaoSetupWizard> {
  int currentStep = 0;
  int maxStepReached = 0; // Track the furthest step reached

  DaoConfig daoConfig = DaoConfig();

  // Instead of a switch, define two lists of screens. The “debates” version
  // omits threshold/duration/registry steps.
  List<Widget> get standardScreens => [
        // 0
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen1DaoType(
            daoConfigState: this,
            daoConfig: daoConfig,
            onNext: nextStep,
          ),
        ),
        // 1
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen2BasicSetup(
            daoConfig: daoConfig,
            onNext: nextStep,
            onBack: previousStep,
          ),
        ),
        // 2
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen3Quorums(
            daoConfig: daoConfig,
            onNext: nextStep,
            onBack: previousStep,
          ),
        ),
        // 3
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen4Durations(
            daoConfig: daoConfig,
            onNext: nextStep,
            onBack: previousStep,
          ),
        ),
        // 4
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen5Members(
            daoConfig: daoConfig,
            onNext: nextStep,
            onBack: previousStep,
          ),
        ),
        // 5
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen6Registry(
            daoConfig: daoConfig,
            onNext: nextStep,
            onBack: previousStep,
          ),
        ),
        // 6
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen7Review(
            daoConfig: daoConfig,
            onBack: previousStep,
            onFinish: finishWizard,
          ),
        ),
        // 7: Deploying
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen8Deploying(
            daoName: daoConfig.daoName ?? 'DAO',
          ),
        ),
        // 8: Deployment Complete
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen9DeploymentComplete(
            daoName: daoConfig.daoName ?? 'DAO',
            onGoToDAO: () {
              String checksumaddress = toChecksumAddress(widget.org.address!);
              context.go("/$checksumaddress");
            },
          ),
        ),
      ];

  // Debates version only has 4 user steps before Deploying:
  // 0: Type
  // 1: Basic Setup
  // 2: Members
  // 3: Review
  // Then 4: Deploying, 5: Done
  List<Widget> get debateScreens => [
        // 0
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen1DaoType(
            daoConfigState: this,
            daoConfig: daoConfig,
            onNext: nextStep,
          ),
        ),
        // 1
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen2BasicSetup(
            daoConfig: daoConfig,
            onNext: nextStep,
            onBack: previousStep,
          ),
        ),
        // 2
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen5Members(
            daoConfig: daoConfig,
            onNext: nextStep,
            onBack: previousStep,
          ),
        ),
        // 3
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen7Review(
            daoConfig: daoConfig,
            onBack: previousStep,
            onFinish: finishWizard,
          ),
        ),
        // 4: Deploying
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen8Deploying(
            daoName: daoConfig.daoName ?? 'DAO',
          ),
        ),
        // 5: Done
        Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen9DeploymentComplete(
            daoName: daoConfig.daoName ?? 'DAO',
            onGoToDAO: () {
              String checksumaddress = toChecksumAddress(widget.org.address!);
              context.go("/$checksumaddress");
            },
          ),
        ),
      ];

  // Helper that picks the right screen list
  List<Widget> get currentScreens =>
      widget.org.debatesOnly! ? debateScreens : standardScreens;

  @override
  void initState() {
    super.initState();
    widget.org = Org(
      name: daoConfig.daoName ?? '',
      govToken: null,
      description: daoConfig.daoDescription,
    );
    // By default, we might set debatesOnly = false, but
    // it will be switched to true in Screen1DaoType if user chooses Debates DAO
    widget.org.debatesOnly = false;
  }

  void goToStep(int step) {
    if (step <= maxStepReached) {
      setState(() {
        currentStep = step;
      });
    }
  }

  void nextStep() {
    final screens = currentScreens;
    // Only advance if we aren't already on the last screen
    if (currentStep < screens.length - 1) {
      setState(() {
        currentStep++;
        if (currentStep > maxStepReached) {
          maxStepReached = currentStep;
        }
      });
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  // “Finish” means jump to the Deploying screen, then eventually to the “complete” screen
  void finishWizard() {
    final screens = currentScreens;
    // The second‐to‐last screen is “Deploying”
    // The last screen is “Complete”
    setState(() {
      currentStep = screens.length - 2; // Jump to Deploying
    });

    // Start deployment asynchronously
    Future.delayed(Duration.zero, () async {
      try {
        // Create token, populate org, etc. (unchanged)
        Token token = Token(
          type: "erc20",
          name: daoConfig.daoName ?? '',
          symbol: daoConfig.tokenSymbol ?? '',
          decimals: daoConfig.numberOfDecimals ?? 0,
        );
        widget.org = Org(
          name: daoConfig.daoName ?? '',
          govToken: token,
          description: daoConfig.daoDescription,
        );
        widget.org.quorum =
            !widget.org.debatesOnly! ? daoConfig.quorumThreshold : 4;
        widget.org.votingDuration = daoConfig.votingDuration?.inMinutes ?? 5760;
        widget.org.votingDelay = daoConfig.votingDelay?.inMinutes ?? 60;
        widget.org.executionDelay = daoConfig.executionDelay?.inSeconds ?? 3600;
        widget.org.holders = daoConfig.members.length;
        widget.org.symbol = daoConfig.tokenSymbol;
        widget.org.registry = daoConfig.registry;
        widget.org.proposalThreshold = !widget.org.debatesOnly!
            ? daoConfig.proposalThreshold!.toStringAsFixed(0)
            : "1";
        widget.org.nonTransferrable = true;
        widget.org.creationDate = DateTime.now();
        widget.org.decimals = daoConfig.numberOfDecimals;
        widget.org.totalSupply = daoConfig.totalSupply.toString();
        if (widget.org.debatesOnly ?? false) {
          widget.org.registry = {"isDebatesOnly": "True"};
        }
        for (Member member in daoConfig.members) {
          member.personalBalance =
              member.personalBalance.toString() + "0" * widget.org.decimals!;
          widget.org.memberAddresses[member.address] = member;
        }

        List<String> results = await createDAO(widget.org);
        widget.org.address = results[0];
        widget.org.govTokenAddress = results[1];
        widget.org.treasuryAddress = results[2];
        widget.org.registryAddress = results[3];
        widget.org.govToken = Token(
          type: "erc20",
          symbol: widget.org.symbol!,
          decimals: widget.org.decimals,
          name: widget.org.name,
        );
        orgs.add(widget.org);

        // Once DAO is created, we go to “Complete”
        setState(() {
          currentStep = screens.length - 1; // Move to the Deployment Complete
        });
      } catch (e) {
        print("Error creating DAO: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pick whichever screen is appropriate for the currentStep
    final screenList = currentScreens;
    Widget content = screenList[currentStep];

    return Container(
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 28.0, right: 50),
                child: TextButton(
                  child: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                // Left side: Wizard steps overview
                Container(
                  width:
                      MediaQuery.of(context).size.aspectRatio > 0.9 ? 300 : 60,
                  height: 500,
                  child: ResponsiveDrawer(
                    org: widget.org,
                    currentStep: currentStep,
                    maxStepReached: maxStepReached,
                    goToStep: goToStep,
                  ),
                ),
                // Right side: Current screen
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResponsiveDrawer extends StatefulWidget {
  Org org;
  final int currentStep;
  final int maxStepReached;
  final Function(int) goToStep;

  ResponsiveDrawer({
    required this.org,
    required this.currentStep,
    required this.maxStepReached,
    required this.goToStep,
  });

  @override
  _ResponsiveDrawerState createState() => _ResponsiveDrawerState();
}

class _ResponsiveDrawerState extends State<ResponsiveDrawer> {
  @override
  Widget build(BuildContext context) {
    final aspectRatio = MediaQuery.of(context).size.aspectRatio;

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: aspectRatio > 0.9 ? 300 : 60,
            padding: EdgeInsets.only(left: aspectRatio > 0.9 ? 38.0 : 3.0),
            child: aspectRatio < 0.9
                ? ListView(
                    padding: EdgeInsets.zero,
                    children: _buildStepIconList(),
                  )
                : ListView(
                    padding: EdgeInsets.zero,
                    children: _buildStepList(),
                  ),
          ),
        ],
      ),
    );
  }

  // We only show the “active” user steps in the side drawer.
  // (We skip “Deploying” and “Complete” so they don’t appear clickable.)
  List<Widget> _buildStepList() {
    if (widget.org.debatesOnly!) {
      // Steps 0..3 for Debates
      return [
        _buildStepTile('Type', 0),
        _buildStepTile('Identity', 1),
        _buildStepTile('Members', 2),
        _buildStepTile('Review & Deploy', 3),
      ];
    } else {
      // Steps 0..6 for Standard
      return [
        _buildStepTile('Type', 0),
        _buildStepTile('Identity', 1),
        _buildStepTile('Thresholds', 2),
        _buildStepTile('Durations', 3),
        _buildStepTile('Members', 4),
        _buildStepTile('Registry', 5),
        _buildStepTile('Review & Deploy', 6),
      ];
    }
  }

  List<Widget> _buildStepIconList() {
    if (widget.org.debatesOnly!) {
      // 0..3
      return [
        _buildStepIconTile(Icons.label, 0),
        _buildStepIconTile(Icons.person, 1),
        _buildStepIconTile(Icons.group, 2),
        _buildStepIconTile(Icons.upload, 3),
      ];
    } else {
      // 0..6
      return [
        _buildStepIconTile(Icons.label, 0),
        _buildStepIconTile(Icons.person, 1),
        _buildStepIconTile(Icons.adjust, 2),
        _buildStepIconTile(Icons.timer, 3),
        _buildStepIconTile(Icons.group, 4),
        _buildStepIconTile(Icons.list, 5),
        _buildStepIconTile(Icons.upload, 6),
      ];
    }
  }

  ListTile _buildStepTile(String title, int step) {
    return ListTile(
      title: Text(title),
      onTap: widget.maxStepReached >= step ? () => widget.goToStep(step) : null,
      selected: widget.currentStep == step,
      enabled: widget.maxStepReached >= step,
      selectedColor: Colors.black,
      selectedTileColor: const Color.fromARGB(255, 121, 133, 128),
    );
  }

  ListTile _buildStepIconTile(IconData icon, int step) {
    return ListTile(
      leading: Icon(icon),
      onTap: widget.maxStepReached >= step ? () => widget.goToStep(step) : null,
      selected: widget.currentStep == step,
      enabled: widget.maxStepReached >= step,
      selectedColor: Colors.black,
      selectedTileColor: const Color.fromARGB(255, 121, 133, 128),
    );
  }
}

// [Previous screens code remains the same up to Screen5Members]

// Screen 6: Registry
class Screen6Registry extends StatefulWidget {
  final DaoConfig daoConfig;
  final VoidCallback onNext;
  final VoidCallback onBack;

  Screen6Registry({
    required this.daoConfig,
    required this.onNext,
    required this.onBack,
  });

  @override
  _Screen6RegistryState createState() => _Screen6RegistryState();
}

class _Screen6RegistryState extends State<Screen6Registry> {
  List<RegistryEntry> _registryEntries = [];

  @override
  void initState() {
    super.initState();
    if (widget.daoConfig.registry.isNotEmpty) {
      _registryEntries = widget.daoConfig.registry.entries
          .map((entry) => RegistryEntry(
                keyController: TextEditingController(text: entry.key),
                valueController: TextEditingController(text: entry.value),
              ))
          .toList();
    } else {
      _addRegistryEntry();
    }
  }

  void _addRegistryEntry() {
    setState(() {
      _registryEntries.add(RegistryEntry(
        keyController: TextEditingController(),
        valueController: TextEditingController(),
      ));
    });
  }

  void _removeRegistryEntry(int index) {
    setState(() {
      _registryEntries.removeAt(index);
    });
  }

  void _saveAndNext() {
    widget.daoConfig.registry = Map.fromEntries(_registryEntries.map(
      (entry) => MapEntry(
        entry.keyController.text,
        entry.valueController.text,
      ),
    ));
    widget.onNext();
  }

  @override
  void dispose() {
    for (var entry in _registryEntries) {
      entry.keyController.dispose();
      entry.valueController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Ensure content can scroll
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Registry Entries',
                style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: 26),
            const Text('Add key-value pairs to initialize the DAO\'s registry.',
                style: TextStyle(
                    fontSize: 14, color: Color.fromARGB(255, 194, 194, 194))),
            const SizedBox(height: 53),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _registryEntries.length,
              itemBuilder: (context, index) {
                return RegistryEntryWidget(
                  entry: _registryEntries[index],
                  onRemove: () => _removeRegistryEntry(index),
                );
              },
            ),
            const SizedBox(height: 50),
            Center(
              child: SizedBox(
                width: 160,
                child: TextButton(
                  onPressed: _addRegistryEntry,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add),
                      Text(' Add Entry'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 126),
            SizedBox(
              width: 700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: widget.onBack,
                    child: const Text('< Back'),
                  ),
                  ElevatedButton(
                    onPressed: _saveAndNext,
                    child: const Text('Save and Continue >'),
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

// Helper classes for registry entries
class RegistryEntry {
  TextEditingController keyController;
  TextEditingController valueController;

  RegistryEntry({
    required this.keyController,
    required this.valueController,
  });
}

class RegistryEntryWidget extends StatelessWidget {
  final RegistryEntry entry;
  final VoidCallback onRemove;

  RegistryEntryWidget({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 700,
          child: Row(
            children: [
              // Key Field
              Expanded(
                flex: 5,
                child: TextField(
                  controller: entry.keyController,
                  decoration: const InputDecoration(
                    labelText: 'Key',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Value Field
              Expanded(
                flex: 5,
                child: TextField(
                  controller: entry.valueController,
                  decoration: const InputDecoration(labelText: 'Value'),
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

// Screen 7: Review & Deploy
class Screen7Review extends StatelessWidget {
  final DaoConfig daoConfig;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  Screen7Review({
    required this.daoConfig,
    required this.onBack,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    // Helper function to format durations
    String formatDuration(Duration? duration) {
      if (duration == null) return 'Not set';
      int days = duration.inDays;
      int hours = duration.inHours % 24;
      int minutes = duration.inMinutes % 60;
      return '$days days, $hours hours, $minutes minutes';
    }

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(38.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${daoConfig.daoName}',
                  style: Theme.of(context).textTheme.headline5),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                constraints: const BoxConstraints(maxWidth: 430),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 56, 56, 56),
                  border: Border.all(
                    color: Color.fromARGB(255, 136, 136, 136),
                    width: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${daoConfig.daoType.toString()} instance',
                  style: TextStyle(
                    color: Color.fromARGB(255, 202, 186, 186),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Text('${daoConfig.daoDescription}')),
              const SizedBox(height: 10),
              daoConfig.daoType == 'Debates'
                  ? const SizedBox()
                  : Column(
                      children: [
                        Text('Ticker Symbol: ${daoConfig.tokenSymbol}'),
                        const SizedBox(height: 30),
                        Text('Quorum Threshold: ${daoConfig.quorumThreshold}%'),
                        const SizedBox(height: 30),
                        Text(
                            'Voting Duration: ${formatDuration(daoConfig.votingDuration)}'),
                        const SizedBox(height: 10),
                        Text(
                            'Voting Delay: ${formatDuration(daoConfig.votingDelay)}'),
                        const SizedBox(height: 10),
                        Text(
                            'Execution Delay: ${formatDuration(daoConfig.executionDelay)}'),
                        const SizedBox(height: 30),
                        Text('${daoConfig.members.length} Members',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
              const SizedBox(height: 10),
              DataTable(
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: (() {
                  final members = daoConfig.members;
                  final rowCount = members.length;

                  if (rowCount <= 10) {
                    // If 10 or fewer rows, display all with numbering
                    return List<DataRow>.generate(rowCount, (index) {
                      final member = members[index];
                      return DataRow(cells: [
                        DataCell(Text((index + 1).toString())), // Row number
                        DataCell(Text(member.address)),
                        DataCell(Text(member.amount.toString())),
                      ]);
                    });
                  } else {
                    // More than 10 rows, display first 3, dots, and last 3
                    final List<DataRow> displayedRows = [];

                    // Add first 3 rows
                    for (int i = 0; i < 3; i++) {
                      final member = members[i];
                      displayedRows.add(DataRow(cells: [
                        DataCell(Text((i + 1).toString())), // Row number
                        DataCell(Text(member.address)),
                        DataCell(Text(member.amount.toString())),
                      ]));
                    }

                    // Add dots row
                    displayedRows.add(const DataRow(cells: [
                      DataCell(Text('...')),
                      DataCell(Text('...')),
                      DataCell(Text('...')),
                    ]));

                    // Add last 3 rows
                    for (int i = rowCount - 3; i < rowCount; i++) {
                      final member = members[i];
                      displayedRows.add(DataRow(cells: [
                        DataCell(Text((i + 1).toString())), // Correct number
                        DataCell(Text(member.address)),
                        DataCell(Text(member.amount.toString())),
                      ]));
                    }

                    return displayedRows;
                  }
                })(),
              ),
              const SizedBox(height: 30),
              daoConfig.daoType == 'Debates'
                  ? const SizedBox()
                  : Column(children: [
                      const Text('Registry Entries:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Key')),
                          DataColumn(label: Text('Value')),
                        ],
                        rows: daoConfig.registry.entries.map((entry) {
                          return DataRow(cells: [
                            DataCell(Text(entry.key)),
                            DataCell(Text(entry.value)),
                          ]);
                        }).toList(),
                      ),
                    ]),
              const SizedBox(height: 30),
              SizedBox(
                width: 700,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: onBack,
                      child: const Text('< Back'),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              createMaterialColor(
                                  Theme.of(context).indicatorColor))),
                      onPressed: onFinish,
                      child: const SizedBox(
                          width: 120,
                          height: 45,
                          child: Center(
                              child: Text('Deploy',
                                  style: TextStyle(fontSize: 19)))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Screen 8: Deploying
class Screen8Deploying extends StatelessWidget {
  final String daoName;

  Screen8Deploying({required this.daoName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        // Center the content vertically and horizontally
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
              height: 100, width: 100, child: CircularProgressIndicator()),
          const SizedBox(height: 50),
          Text('Deploying $daoName to the ${Human().chain.name} blockchain...'),
        ],
      ),
    );
  }
}

// Screen 9: Deployment Complete
class Screen9DeploymentComplete extends StatelessWidget {
  final String daoName;
  final VoidCallback onGoToDAO;

  Screen9DeploymentComplete({required this.daoName, required this.onGoToDAO});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        // Center the content vertically and horizontally
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Deployment Complete!',
              style: Theme.of(context).textTheme.headline5),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: onGoToDAO,
            child: const Text('Go to DAO'),
          ),
        ],
      ),
    );
  }
}
