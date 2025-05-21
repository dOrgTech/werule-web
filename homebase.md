# Folder Structure

- homebase/
  - lib/
    - screens/
      - creator.dart
      - creator/
        - creator_utils.dart
        - creator_widgets.dart
        - dao_config.dart
        - scereen5_members.dart
        - scree1_dao_type.dart
        - screen2_basic_setup.dart
        - screen3_quorums.dart
        - screen4_durations.dart
        - screen6_registry.dart
        - screen7_review.dart
        - screen8_deploying.dart
        - screen9_deployment_complete.dart

# File Contents

### `lib/screens/creator.dart`
```dart
// lib/screens/creator.dart
import 'package:Homebase/main.dart'; // For orgs list
import 'package:Homebase/screens/creator/scereen5_members.dart';
import 'package:Homebase/screens/creator/scree1_dao_type.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../entities/contractFunctions.dart'; // Imports createDAO and createDAOwithWrappedToken
import '../../entities/org.dart';
import '../../entities/proposal.dart'; // For Member
import '../../entities/token.dart';

import 'creator/dao_config.dart';
import 'creator/creator_utils.dart'; 
import 'creator/screen2_basic_setup.dart';
import 'creator/screen3_quorums.dart';
import 'creator/screen4_durations.dart';
import 'creator/screen6_registry.dart';
import 'creator/screen7_review.dart';
import 'creator/screen8_deploying.dart';
import 'creator/screen9_deployment_complete.dart';


// Main wizard widget
class DaoSetupWizard extends StatefulWidget {
  late Org org;
  DaoSetupWizard({super.key});

  @override
  _DaoSetupWizardState createState() => _DaoSetupWizardState();
}

class _DaoSetupWizardState extends State<DaoSetupWizard> {
  int currentStep = 0;
  int maxStepReached = 0;
  DaoConfig daoConfig = DaoConfig();

  void goToStep(int step) {
    // Prevent navigating to the "Members" screen (step 4) if it should be skipped
    if (step == 4 && daoConfig.tokenDeploymentMechanism == DaoTokenDeploymentMechanism.wrapExistingToken) {
      return; 
    }
    if (step <= maxStepReached) {
      setState(() {
        currentStep = step;
      });
    }
  }

  void nextStep() {
    // Max configurable step is 6 (Review). After that, it's deploying/complete.
    if (currentStep < 6) { 
      int potentialNextStep = currentStep + 1;
      
      // If currentStep is 3 (Durations) and next would be 4 (Members),
      // and we are using a wrapped token, skip Members.
      if (currentStep == 3 && potentialNextStep == 4 &&
          daoConfig.tokenDeploymentMechanism == DaoTokenDeploymentMechanism.wrapExistingToken) {
        potentialNextStep++; // Skip Members (4) -> go to Registry (5)
      }

      setState(() {
        currentStep = potentialNextStep;
        if (currentStep > maxStepReached) {
          maxStepReached = currentStep;
        }
      });
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      int potentialPrevStep = currentStep - 1;

      // If currentStep is 5 (Registry) and prev would be 4 (Members),
      // and we are using a wrapped token, skip Members.
      if (currentStep == 5 && potentialPrevStep == 4 &&
          daoConfig.tokenDeploymentMechanism == DaoTokenDeploymentMechanism.wrapExistingToken) {
        potentialPrevStep--; // Skip Members (4) -> go to Durations (3)
      }
      setState(() {
        currentStep = potentialPrevStep;
      });
    }
  }

  void finishWizard() {
    setState(() {
      currentStep = 7; // Show deploying screen
    });

    Future.delayed(Duration.zero, () async {
      // --- Initialize Org object ---
      widget.org = Org(
        name: daoConfig.daoName ?? "My DAO", // User-provided or default
        description: daoConfig.daoDescription ?? "A new DAO", // User-provided or default
        // govToken will be fully initialized below based on deployment type
      );

      // --- Populate common Org properties from DaoConfig ---
      widget.org.quorum = daoConfig.quorumThreshold; // From Screen3Quorums
      widget.org.votingDuration = daoConfig.votingDuration?.inMinutes ?? 0; // From Screen4Durations
      widget.org.votingDelay = daoConfig.votingDelay?.inMinutes ?? 0; // From Screen4Durations
      widget.org.executionDelay = daoConfig.executionDelay?.inSeconds ?? 0; // From Screen4Durations
      widget.org.registry = daoConfig.registry; // From Screen6Registry
      widget.org.proposalThreshold = (daoConfig.proposalThreshold ?? 1).toString(); // From Screen3Quorums
      widget.org.creationDate = DateTime.now();


      List<String> results = [];
      bool success = false;

      try {
        if (daoConfig.tokenDeploymentMechanism == DaoTokenDeploymentMechanism.deployNewStandardToken) {
          // --- Path for Deploying New Standard Token ---
          widget.org.symbol = daoConfig.tokenSymbol ?? "TOK"; // From Screen2BasicSetup
          widget.org.decimals = daoConfig.numberOfDecimals ?? 0; // From Screen2BasicSetup
          widget.org.nonTransferrable = daoConfig.nonTransferrable; // From Screen2BasicSetup
          widget.org.totalSupply = daoConfig.totalSupply ?? "0"; // From Screen5Members or Screen2
          widget.org.holders = daoConfig.members.length; // From Screen5Members

          widget.org.memberAddresses = {}; // Clear and re-populate
          for (Member member in daoConfig.members) { // Members from Screen5Members
            if (member.address.isNotEmpty) {
              widget.org.memberAddresses[member.address] = member;
            }
          }
          
          widget.org.govToken = Token(
            type: "erc20",
            name: widget.org.name, 
            symbol: widget.org.symbol!,
            decimals: widget.org.decimals!,
            // address will be set from results
          );

          results = await createDAO(widget.org);

        } else if (daoConfig.tokenDeploymentMechanism == DaoTokenDeploymentMechanism.wrapExistingToken) {
          // --- Path for Deploying DAO with Wrapped Token ---
          widget.org.symbol = daoConfig.wrappedTokenSymbol ?? "wTOK"; // From Screen2BasicSetup

          widget.org.decimals = daoConfig.numberOfDecimals ?? 18; // Default for Dart Token obj
          // Note: daoConfig.numberOfDecimals should be null for wrapped if Screen2 logic is correct.
          // This implies underlying token decimals will be used by contract, 18 is Dart obj placeholder.

          widget.org.nonTransferrable = false; // Wrapped tokens are generally transferable
          widget.org.totalSupply = "0"; // Wrapped tokens start with 0 supply (handled also in Screen2)
          widget.org.holders = 0; // No initial holders via this deployment method
          widget.org.memberAddresses = {}; // No members distributed at deployment for wrapped tokens (daoConfig.members should be empty)
          
          widget.org.govToken = Token(
            type: "wrappedErc20", // A type to distinguish it
            name: daoConfig.wrappedTokenName ?? "Wrapped ${daoConfig.wrappedTokenSymbol ?? "Token"}", // From Screen2
            symbol: widget.org.symbol!,
            decimals: widget.org.decimals!, // For the Dart object
            // address will be set from results
          );
          
          results = await createDAOwithWrappedToken(widget.org, daoConfig);
        }

        // Process results
        if (results.isNotEmpty && !results[0].startsWith("ERROR")) {
          widget.org.address = results[0];
          widget.org.govTokenAddress = results[1]; 
          widget.org.treasuryAddress = results[2];
          widget.org.registryAddress = results[3];

          widget.org.govToken = Token(
              type: widget.org.govToken!.type, 
              name: widget.org.govToken!.name, 
              symbol: widget.org.symbol!, 
              decimals: widget.org.decimals!, 
              address: results[1] 
          );

          orgs.add(widget.org);
          success = true;
          print("DAO Deployment successful: ${widget.org.name}, DAO Address: ${widget.org.address}, Token Address: ${widget.org.govTokenAddress}");
        } else {
          String errorMsg = results.isNotEmpty ? results[0] : "Unknown error during deployment.";
          print("DAO Deployment Failed: $errorMsg");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('DAO Deployment Failed: $errorMsg'), backgroundColor: Colors.red),
            );
          }
        }

      } catch (e) {
        print("Error in finishWizard during contract call: $e");
        String errorString = e.toString();
        if (errorString.length > 150) errorString = "${errorString.substring(0,150)}...";
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('DAO Deployment Exception: $errorString'), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
          );
        }
      }

      if (mounted) {
        setState(() {
          currentStep = success ? 8 : 6; // Go to complete or back to review
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (currentStep) {
      case 0:
        content = Padding(
            padding: const EdgeInsets.all(38.0),
            child: Screen1DaoType(daoConfig: daoConfig, onNext: nextStep));
        break;
      case 1:
        content = Padding(
            padding: const EdgeInsets.all(38.0),
            child: Screen2BasicSetup(
                daoConfig: daoConfig, onNext: nextStep, onBack: previousStep));
        break;
      case 2:
        content = Padding(
            padding: const EdgeInsets.all(38.0),
            child: Screen3Quorums(
                daoConfig: daoConfig, onNext: nextStep, onBack: previousStep));
        break;
      case 3:
        content = Padding(
            padding: const EdgeInsets.all(38.0),
            child: Screen4Durations(
                daoConfig: daoConfig, onNext: nextStep, onBack: previousStep));
        break;
      case 4:
        // Screen5Members handles its own padding or can be wrapped if needed
        // This case should ideally not be reached if it's a wrapped token type.
        // The navigation logic in nextStep/previousStep/goToStep should prevent this.
        content = Screen5Members( 
            daoConfig: daoConfig, onNext: nextStep, onBack: previousStep);
        break;
      case 5:
        content = Padding(
            padding: const EdgeInsets.all(38.0),
            child: Screen6Registry(
                daoConfig: daoConfig, onNext: nextStep, onBack: previousStep));
        break;
      case 6:
        content = Padding(
            padding: const EdgeInsets.all(38.0),
            child: Screen7Review(
                daoConfig: daoConfig,
                onBack: previousStep,
                onFinish: finishWizard));
        break;
      case 7:
        content = Padding(
            padding: const EdgeInsets.all(38.0),
            child: Screen8Deploying(daoName: daoConfig.daoName ?? 'DAO'));
        break;
      case 8:
        content = Padding(
            padding: const EdgeInsets.all(38.0),
            child: Screen9DeploymentComplete(
                daoName: daoConfig.daoName ?? 'DAO',
                onGoToDAO: () {
                  if (widget.org.address != null) {
                    String checksumaddress =
                        toChecksumAddress(widget.org.address!);
                    context.go("/$checksumaddress");
                  } else {
                     if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Error: DAO Address not available after deployment.'),
                              backgroundColor: Colors.red),
                        );
                     }
                  }
                }));
        break;
      default:
        content = Container(child: const Center(child: Text("Error: Unknown Step")));
    }

    bool isMembersStepEnabled = daoConfig.tokenDeploymentMechanism == DaoTokenDeploymentMechanism.deployNewStandardToken;

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
                Container(
                  padding: const EdgeInsets.only(left: 38.0),
                  width: 270,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            ListTile( // Step 0
                                title: const Text('1. Type'),
                                onTap: () => goToStep(0),
                                selected: currentStep == 0,
                                enabled: true, // Always enabled and tappable
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile( // Step 1
                                title: const Text('2. Identity'),
                                onTap: maxStepReached >= 1 ? () => goToStep(1) : null,
                                selected: currentStep == 1,
                                enabled: maxStepReached >= 1, 
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile( // Step 2
                                title: const Text('3. Thresholds'),
                                onTap: maxStepReached >= 2 ? () => goToStep(2) : null,
                                selected: currentStep == 2,
                                enabled: maxStepReached >= 2, 
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile( // Step 3
                                title: const Text('4. Durations'),
                                onTap: maxStepReached >= 3 ? () => goToStep(3) : null,
                                selected: currentStep == 3,
                                enabled: maxStepReached >= 3,
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile( // Step 4: Members
                                title: const Text('5. Members'),
                                onTap: (maxStepReached >= 4 && isMembersStepEnabled) ? () => goToStep(4) : null,
                                selected: currentStep == 4,
                                enabled: (maxStepReached >= 4 && isMembersStepEnabled), 
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile( // Step 5: Registry
                                title: const Text('6. Registry'),
                                onTap: maxStepReached >= 5 ? () => goToStep(5) : null,
                                selected: currentStep == 5,
                                enabled: maxStepReached >= 5,
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile( // Step 6: Review
                                title: const Text('7. Review & Deploy'),
                                onTap: maxStepReached >= 6 ? () => goToStep(6) : null,
                                selected: currentStep == 6,
                                enabled: maxStepReached >= 6,
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: content,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// lib/screens/creator.dart
```

### `lib/screens/creator/creator_utils.dart`
```dart
// lib/screens/creator/creator_utils.dart
import 'dart:convert';

import 'package:flutter/services.dart';
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
  address = address.replaceFirst('0x', '').toLowerCase();
  var hashedAddress = keccak256(utf8.encode(address));
  var hashString = bytesToHex(hashedAddress);
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

enum DaoTokenDeploymentMechanism {
  deployNewStandardToken,
  wrapExistingToken,
}
// lib/screens/creator/creator_utils.dart

```

### `lib/screens/creator/creator_widgets.dart`
```dart
// lib/screens/creator/creator_widgets.dart
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

// FlashingIcon and meniu TextStyle
class FlashingIcon extends StatefulWidget {
  const FlashingIcon({super.key});

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
        vsync: this, duration: const Duration(milliseconds: 1200));
    _colorAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
            tween: ColorTween(
                begin: Colors.white,
                end: const Color.fromARGB(255, 255, 180, 110)),
            weight: 600),
        TweenSequenceItem(
            tween: ColorTween(begin: Colors.yellow, end: Colors.white),
            weight: 600),
      ],
    ).animate(_controller);
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
        return Icon(Icons.security, size: 44, color: _colorAnimation.value);
      },
    );
  }
}

TextStyle meniu =
    const TextStyle(fontSize: 24, color: Color.fromARGB(255, 178, 178, 178));

// Custom widget for duration input
class DurationInput extends StatelessWidget {
  final String title;
  final String description;
  final TextEditingController daysController;
  final TextEditingController hoursController;
  final TextEditingController minutesController;

  const DurationInput({super.key, 
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

  MemberEntryWidget({
    super.key,
    required this.entry,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 700,
          child: Row(
            children: [
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
              Expanded(
                flex: 3,
                child: TextField(
                  controller: entry.amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  onChanged: (value) => onChanged(),
                ),
              ),
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

  const RegistryEntryWidget({super.key, required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 700,
          child: Row(
            children: [
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
              Expanded(
                flex: 5,
                child: TextField(
                  controller: entry.valueController,
                  decoration: const InputDecoration(labelText: 'Value'),
                ),
              ),
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
// lib/screens/creator/creator_widgets.dart

```

### `lib/screens/creator/dao_config.dart`
```dart
// lib/screens/creator/dao_config.dart
import 'package:Homebase/entities/org.dart';

// Assuming Member is defined here
import 'creator_utils.dart'; // For DaoTokenDeploymentMechanism

class DaoConfig {
  String? daoType;
  String? daoName;
  String? daoDescription;

  DaoTokenDeploymentMechanism tokenDeploymentMechanism =
      DaoTokenDeploymentMechanism.deployNewStandardToken;

  // Original fields for "deploy new token" - RETAINED FOR EXISTING FUNCTIONALITY
  String? tokenSymbol;
  int? numberOfDecimals;
  bool nonTransferrable = true;

  // ADDED: New fields for "wrap existing token"
  String? underlyingTokenAddress;
  String? wrappedTokenName;
  String? wrappedTokenSymbol;

  String? totalSupply;
  Map<String, String> registry = {};
  int? proposalThreshold = 1;
  int quorumThreshold = 4;
  double supermajority = 75.0;
  Duration? votingDuration;
  Duration? votingDelay;
  Duration? executionDelay;
  List<Member> members = []; // Member type from proposal.dart
  DaoConfig();
}
// lib/screens/creator/dao_config.dart

```

### `lib/screens/creator/scereen5_members.dart`
```dart
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

  const Screen5Members({
    required this.daoConfig,
    required this.onBack,
    required this.onNext,
    super.key,
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
    if (_totalPages <= 1) return const SizedBox.shrink();
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
            child: const SizedBox(
              height: 130,
              width: 170,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
            child: const SizedBox(
              height: 130,
              width: 170,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
              ? const Center(
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
                          const SizedBox(
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
              text: const TextSpan(
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

```

### `lib/screens/creator/scree1_dao_type.dart`
```dart
// lib/screens/creator/screen1_dao_type.dart
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'creator_widgets.dart'; // For FlashingIcon, meniu
import 'dao_config.dart';

// Screen 1: Select DAO type
class Screen1DaoType extends StatelessWidget {
  final DaoConfig daoConfig;
  final VoidCallback onNext;

  const Screen1DaoType({super.key, required this.daoConfig, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Will you be needing a treasury?',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 26),
            const SizedBox(
                width: 510,
                child: Text(
                    "For distributed management of collective assets, you will need to deploy a Full DAO. If you just want collective ideation and large-scale brainstorming, pick Debates.\n\nThe Full DAO includes the Tokenized Debates system.\n\nThe Debates instance can be upgraded to a Full DAO at a later time, should the fear subside.",
                    style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 194, 194, 194)))),
            const SizedBox(height: 21),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 340,
                  height: 310,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextButton(
                      onPressed: () {
                        daoConfig.daoType = 'On-chain';
                        onNext();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(255, 56, 56, 56)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            FlashingIcon(),
                            const SizedBox(height: 14),
                            SizedBox(
                                width: 150,
                                height: 30,
                                child: Center(
                                    child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 489),
                                        child: AnimatedTextKit(
                                          onTap: () {},
                                          isRepeatingAnimation: false,
                                          repeatForever: false,
                                          animatedTexts: [
                                            ColorizeAnimatedText('On-chain',
                                                textStyle: meniu,
                                                textDirection:
                                                    TextDirection.ltr,
                                                speed: const Duration(
                                                    milliseconds: 700),
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
                                        )))),
                            const SizedBox(height: 10),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'All important operations are secured by the will of the members through voting.\n\nExecutive and Declarative.',
                                style: TextStyle(height: 1.3),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 340,
                  height: 310,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextButton(
                      onPressed: null,
                      child: Tooltip(
                        decoration:
                            BoxDecoration(color: Theme.of(context).canvasColor),
                        message: "Soon...",
                        textStyle: const TextStyle(
                          fontSize: 30,
                          color: Color.fromARGB(255, 216, 216, 216),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color.fromARGB(255, 56, 56, 56)),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 38),
                              Icon(Icons.forum, size: 40),
                              SizedBox(height: 14),
                              Text('Debates', style: TextStyle(fontSize: 23.5)),
                              SizedBox(height: 14),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 13.0, right: 13, top: 10, bottom: 10),
                                child: Text(
                                  "Tokenized collective debates with fractal topology. \n\nDeclarative only.",
                                  style: TextStyle(height: 1.4),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// lib/screens/creator/screen1_dao_type.dart

```

### `lib/screens/creator/screen2_basic_setup.dart`
```dart
// lib/screens/creator/screen2_basic_setup.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/pleadingForLessDecimals.dart'; // Imports AnimatedMemeWidget
import 'creator_utils.dart'; // For DaoTokenDeploymentMechanism, UpperCaseTextFormatter
import 'dao_config.dart';

// Screen 2: Basic Setup
class Screen2BasicSetup extends StatefulWidget {
  final DaoConfig daoConfig;
  final VoidCallback onNext;
  final VoidCallback onBack;
  bool memeNotShown = true;

  Screen2BasicSetup({
    super.key,
    required this.daoConfig,
    required this.onNext,
    required this.onBack,
  });

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

  late TextEditingController _underlyingTokenAddressController;
  late TextEditingController _wrappedTokenSymbolController;

  late DaoTokenDeploymentMechanism _selectedMechanism;

  @override
  void initState() {
    super.initState();
    _daoNameController = TextEditingController(text: widget.daoConfig.daoName);
    _daoDescriptionController =
        TextEditingController(text: widget.daoConfig.daoDescription);

    _selectedMechanism = widget.daoConfig.tokenDeploymentMechanism;

    _tokenSymbolController =
        TextEditingController(text: widget.daoConfig.tokenSymbol);
    _numberOfDecimalsController = TextEditingController(
        text: widget.daoConfig.numberOfDecimals?.toString());
    _nonTransferrable = widget.daoConfig.nonTransferrable;

    _underlyingTokenAddressController =
        TextEditingController(text: widget.daoConfig.underlyingTokenAddress);
    _wrappedTokenSymbolController =
        TextEditingController(text: widget.daoConfig.wrappedTokenSymbol);
  }

  @override
  void dispose() {
    _daoNameController.dispose();
    _daoDescriptionController.dispose();
    _tokenSymbolController.dispose();
    _numberOfDecimalsController.dispose();
    _underlyingTokenAddressController.dispose();
    _wrappedTokenSymbolController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      widget.daoConfig.daoName = _daoNameController.text;
      widget.daoConfig.daoDescription = _daoDescriptionController.text;
      widget.daoConfig.tokenDeploymentMechanism = _selectedMechanism;

      if (_selectedMechanism ==
          DaoTokenDeploymentMechanism.deployNewStandardToken) {
        widget.daoConfig.tokenSymbol = _tokenSymbolController.text.toUpperCase();
        widget.daoConfig.numberOfDecimals =
            int.tryParse(_numberOfDecimalsController.text);
        widget.daoConfig.nonTransferrable = _nonTransferrable;
        
        // Clear wrapped token fields if switching back to standard
        widget.daoConfig.underlyingTokenAddress = null;
        widget.daoConfig.wrappedTokenSymbol = null;
        widget.daoConfig.wrappedTokenName = null;
        // Note: totalSupply and members for standard token are handled in Screen5

      } else { // DaoTokenDeploymentMechanism.wrapExistingToken
        widget.daoConfig.underlyingTokenAddress =
            _underlyingTokenAddressController.text;
        widget.daoConfig.wrappedTokenSymbol =
            _wrappedTokenSymbolController.text.toUpperCase();
        widget.daoConfig.wrappedTokenName = "Wrapped ${widget.daoConfig.wrappedTokenSymbol ?? "Token"}";

        // Clear standard token specific fields
        widget.daoConfig.tokenSymbol = null;
        widget.daoConfig.numberOfDecimals = null; // For wrapped, decimals are from underlying.
                                                 // A default might be used for the Org's Token object display.

        // Crucially, clear members and set total supply for wrapped token type
        widget.daoConfig.members = []; 
        widget.daoConfig.totalSupply = "0"; // Wrapped tokens typically start with 0 supply.
                                           // The actual total supply depends on wrapped amounts.
      }
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70),
        child: Form(
          key: _formKey,
          child: Center( 
            child: SizedBox(
              width: 500, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  Text("Organization identity",
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 30),
                  TextFormField(
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _daoDescriptionController,
                    maxLength: 400,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        labelText: 'Description or Tagline (Optional)'),
                  ),
                  const SizedBox(height: 30),
                  Text("Governance Token",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  
                  SizedBox( 
                    width: 380, 
                    child: Column(
                      children: [
                        RadioListTile<DaoTokenDeploymentMechanism>(
                          title: const Text('Deploy new standard token'),
                          value:
                              DaoTokenDeploymentMechanism.deployNewStandardToken,
                          groupValue: _selectedMechanism,
                          onChanged: (DaoTokenDeploymentMechanism? value) {
                            if (value != null) {
                              setState(() { _selectedMechanism = value; });
                            }
                          },
                        ),
                        RadioListTile<DaoTokenDeploymentMechanism>(
                          title: const Text('Wrap existing ERC20 token'),
                          value: DaoTokenDeploymentMechanism.wrapExistingToken,
                          groupValue: _selectedMechanism,
                          onChanged: (DaoTokenDeploymentMechanism? value) {
                            if (value != null) {
                              setState(() { _selectedMechanism = value; });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_selectedMechanism ==
                      DaoTokenDeploymentMechanism.deployNewStandardToken) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, 
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox( 
                          width: 150, 
                          child: TextFormField( 
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                              UpperCaseTextFormatter(),
                            ],
                            maxLength: 5,
                            controller: _tokenSymbolController,
                            decoration: const InputDecoration(
                                counterText: "", labelText: 'Ticker Symbol'),
                            validator: (value) { 
                              if (_selectedMechanism == DaoTokenDeploymentMechanism.deployNewStandardToken &&
                                  (value == null || value.isEmpty)) {
                                return 'Ticker required'; 
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox( 
                          width: 150, 
                          child: TextFormField( 
                            onChanged: (value) {
                              int? decimals = int.tryParse(value);
                              if (decimals != null && decimals > 6 && widget.memeNotShown) {
                                widget.memeNotShown = false;
                                showDialog(context: context, builder: ((context) => AlertDialog(
                                  backgroundColor: Colors.transparent,
                                  contentPadding: EdgeInsets.zero,
                                  content: SizedBox(width: 500, height: 550, child: AnimatedMemeWidget()),
                                )));
                              }
                            },
                            controller: _numberOfDecimalsController, 
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Decimals'),
                            validator: (value) { 
                              if (_selectedMechanism == DaoTokenDeploymentMechanism.deployNewStandardToken) {
                                if (value == null || value.isEmpty) return 'Required';
                                int? decimals = int.tryParse(value);
                                if (decimals == null || decimals < 0 || decimals > 18) return '0-18'; 
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 40,
                      width: 300, 
                      child: CheckboxListTile(
                        title: const Text('Non-transferable Token'),
                        value: _nonTransferrable, 
                        activeColor: Theme.of(context).indicatorColor,
                        checkColor: Colors.black,
                        onChanged: (value) { 
                          if (_nonTransferrable == true && value == false) { 
                            showDialog(context: context, builder: (context) => AlertDialog(
                              title: const Text('Be advised:'),
                              content: Padding(
                                padding: const EdgeInsets.all(28.0),
                                child: SizedBox(width: 450, height: 270, child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Using a transferable governance token is not compatible with the reputation-based logical architecture of the On-Chain Jurisdiction.\n\nThis action is non-reversible.', style: TextStyle(height: 1.5)),
                                    const SizedBox(height: 64),
                                    RichText(text: TextSpan(
                                      style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 255, 255, 255)),
                                      children: [
                                        const TextSpan(text: "Learn more about the implications ", style: TextStyle(fontSize: 16)),
                                        TextSpan(
                                          text: "here",
                                          style: TextStyle(fontSize: 16, color: Theme.of(context).indicatorColor, decoration: TextDecoration.underline),
                                          recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse("https://docs.openzeppelin.com/contracts/5.x/api/governance")),
                                        ),
                                      ],
                                    )),
                                  ],
                                )),
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              actionsPadding: const EdgeInsets.all(40),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("< Back")),
                                const SizedBox(width: 180),
                                ElevatedButton(onPressed: () { setState(() { _nonTransferrable = value!; }); Navigator.of(context).pop(); }, child: const Text('I understand')),
                              ],
                            ));
                          } else {
                            setState(() { _nonTransferrable = value!; });
                          }
                        },
                      ),
                    ),
                  ] else if (_selectedMechanism == DaoTokenDeploymentMechanism.wrapExistingToken) ...[
                    SizedBox(
                      height: 115,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox( 
                            width: 380, 
                            child: TextFormField(
                              controller: _underlyingTokenAddressController,
                              maxLength: 42,
                              decoration: const InputDecoration(
                                  labelText: 'Underlying Token Address',
                                  counterText: ""),
                              validator: (value) {
                                if (_selectedMechanism == DaoTokenDeploymentMechanism.wrapExistingToken) {
                                  if (value == null || value.isEmpty) return 'Address required';
                                  if (!RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(value)) return 'Invalid Ethereum address';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          SizedBox( 
                            width: 100, 
                            child: TextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                                UpperCaseTextFormatter(),
                              ],
                              maxLength: 7,
                              controller: _wrappedTokenSymbolController,
                              decoration: const InputDecoration(
                                  counterText: "",
                                  labelText: 'Symbol'),
                              validator: (value) {
                                if (_selectedMechanism == DaoTokenDeploymentMechanism.wrapExistingToken &&
                                    (value == null || value.isEmpty)) {
                                  return 'Symbol required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                 
                  const SizedBox(height: 56),
                  Row( 
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
                  if (_selectedMechanism == DaoTokenDeploymentMechanism.wrapExistingToken && false) // This condition is always false, can be removed if not for future use
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        '"Wrap existing token" option is for UI demonstration. Full functionality will be enabled later.',
                        style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// lib/screens/creator/screen2_basic_setup.dart
```

### `lib/screens/creator/screen3_quorums.dart`
```dart
// lib/screens/creator/screen3_quorums.dart
import 'package:flutter/material.dart';
import 'creator_utils.dart'; // For DaoTokenDeploymentMechanism
import 'dao_config.dart';

// Screen 3: Quorums
class Screen3Quorums extends StatefulWidget {
  final DaoConfig daoConfig;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Screen3Quorums(
      {super.key, required this.daoConfig, required this.onNext, required this.onBack});

  @override
  _Screen3QuorumsState createState() => _Screen3QuorumsState();
}

class _Screen3QuorumsState extends State<Screen3Quorums> {
  double _quorumThreshold = 6.0;
  late double _supermajority;
  late TextEditingController thresholdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quorumThreshold = widget.daoConfig.quorumThreshold.toDouble();
    _supermajority = widget.daoConfig.supermajority;
    thresholdController.text = widget.daoConfig.proposalThreshold.toString();
  }

  void _saveAndNext() {
    widget.daoConfig.quorumThreshold = _quorumThreshold.toInt();
    widget.daoConfig.supermajority = _supermajority;
    widget.daoConfig.proposalThreshold = int.tryParse(thresholdController.text);
    widget.onNext();
  }

  String get _effectiveTokenSymbolForProposalThreshold {
    if (widget.daoConfig.tokenDeploymentMechanism ==
        DaoTokenDeploymentMechanism.wrapExistingToken) {
      return widget.daoConfig.wrappedTokenSymbol?.isNotEmpty == true
          ? widget.daoConfig.wrappedTokenSymbol!
          : "WRAPPED";
    }
    return widget.daoConfig.tokenSymbol?.isNotEmpty == true
        ? widget.daoConfig.tokenSymbol!
        : "SYM";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 38.0, right: 38.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 78, 78, 78), width: 0.4)),
              padding: const EdgeInsets.all(35),
              child: Column(
                children: [
                  Text('Quorum',
                      style: Theme.of(context).textTheme.headlineMedium),
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
                            label: '${_quorumThreshold.round()}%',
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
                      color: const Color.fromARGB(255, 78, 78, 78), width: 0.4)),
              padding: const EdgeInsets.all(35),
              child: SizedBox(
                width: 500,
                child: Column(
                  children: [
                    Text('Proposal Threashold',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: thresholdController,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              '$_effectiveTokenSymbolForProposalThreshold amount',
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
// lib/screens/creator/screen3_quorums.dart

```

### `lib/screens/creator/screen4_durations.dart`
```dart
// lib/screens/creator/screen4_durations.dart
import 'package:flutter/material.dart';
import 'creator_widgets.dart'; // For DurationInput
import 'dao_config.dart';

// Screen 4: Durations
class Screen4Durations extends StatefulWidget {
  final DaoConfig daoConfig;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Screen4Durations(
      {super.key, required this.daoConfig, required this.onNext, required this.onBack});

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
  late TextEditingController _executionDelayDaysController;
  late TextEditingController _executionDelayHoursController;
  late TextEditingController _executionDelayMinutesController;

  @override
  void initState() {
    super.initState();
    _votingDurationDaysController = TextEditingController(
        text: widget.daoConfig.votingDuration?.inDays.toString() ?? '');
    _votingDurationHoursController = TextEditingController(
        text: widget.daoConfig.votingDuration != null
            ? (widget.daoConfig.votingDuration!.inHours % 24).toString()
            : '');
    _votingDurationMinutesController = TextEditingController(
        text: widget.daoConfig.votingDuration != null
            ? (widget.daoConfig.votingDuration!.inMinutes % 60).toString()
            : '');
    _votingDelayDaysController = TextEditingController(
        text: widget.daoConfig.votingDelay?.inDays.toString() ?? '');
    _votingDelayHoursController = TextEditingController(
        text: widget.daoConfig.votingDelay != null
            ? (widget.daoConfig.votingDelay!.inHours % 24).toString()
            : '');
    _votingDelayMinutesController = TextEditingController(
        text: widget.daoConfig.votingDelay != null
            ? (widget.daoConfig.votingDelay!.inMinutes % 60).toString()
            : '');
    _executionDelayDaysController = TextEditingController(
        text: widget.daoConfig.executionDelay?.inDays.toString() ?? '');
    _executionDelayHoursController = TextEditingController(
        text: widget.daoConfig.executionDelay != null
            ? (widget.daoConfig.executionDelay!.inHours % 24).toString()
            : '');
    _executionDelayMinutesController = TextEditingController(
        text: widget.daoConfig.executionDelay != null
            ? (widget.daoConfig.executionDelay!.inMinutes % 60).toString()
            : '');
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

  void _saveAndNext() {
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(38.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Set the durations of proposal stages',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 86),
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
                      onPressed: widget.onBack, child: const Text('< Back')),
                  ElevatedButton(
                      onPressed: _saveAndNext,
                      child: const Text('Save and Continue >')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/screens/creator/screen4_durations.dart

```

### `lib/screens/creator/screen6_registry.dart`
```dart
// lib/screens/creator/screen6_registry.dart
import 'package:flutter/material.dart';
import 'creator_widgets.dart'; // For RegistryEntry, RegistryEntryWidget
import 'dao_config.dart';

// Screen 6: Registry
class Screen6Registry extends StatefulWidget {
  final DaoConfig daoConfig;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Screen6Registry({super.key, 
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
      _addRegistryEntry(); // Add one entry by default if empty
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
      // Make sure to dispose controllers of the removed entry
      _registryEntries[index].keyController.dispose();
      _registryEntries[index].valueController.dispose();
      _registryEntries.removeAt(index);
    });
  }

  void _saveAndNext() {
    widget.daoConfig.registry = Map.fromEntries(_registryEntries
        .where((entry) =>
            entry.keyController.text.isNotEmpty ||
            entry
                .valueController.text.isNotEmpty) // Save only non-empty entries
        .map(
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Registry Entries',
                style: Theme.of(context).textTheme.headlineMedium),
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.add), Text(' Add Entry')],
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
                      onPressed: widget.onBack, child: const Text('< Back')),
                  ElevatedButton(
                      onPressed: _saveAndNext,
                      child: const Text('Save and Continue >')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/screens/creator/screen6_registry.dart

```

### `lib/screens/creator/screen7_review.dart`
```dart
// lib/screens/creator/screen7_review.dart
import 'package:Homebase/utils/theme.dart'; // For createMaterialColor
import 'package:flutter/material.dart';
import 'creator_utils.dart'; // For DaoTokenDeploymentMechanism
import 'dao_config.dart';

// Screen 7: Review & Deploy
class Screen7Review extends StatelessWidget {
  final DaoConfig daoConfig;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  const Screen7Review({super.key, 
    required this.daoConfig,
    required this.onBack,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
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
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              const Text('On-Chain Organization'),
              const SizedBox(height: 20),
              Container(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Text('${daoConfig.daoDescription}')),
              const SizedBox(height: 10),
              if (daoConfig.tokenDeploymentMechanism ==
                  DaoTokenDeploymentMechanism.deployNewStandardToken) ...[
                Text('Ticker Symbol: ${daoConfig.tokenSymbol ?? "N/A"}'),
                Text(
                    'Number of Decimals: ${daoConfig.numberOfDecimals?.toString() ?? "N/A"}'),
                Text(
                    'Non-Transferable: ${daoConfig.nonTransferrable ? 'Yes' : 'No'}'),
              ] else ...[
                const Text('Deployment Type: Wrap Existing Token'),
                Text(
                    'Underlying Token Address: ${daoConfig.underlyingTokenAddress ?? "N/A"}'),
                Text(
                    'Wrapped Token Name: ${daoConfig.wrappedTokenName ?? "N/A"}'),
                Text(
                    'Wrapped Token Symbol: ${daoConfig.wrappedTokenSymbol ?? "N/A"}'),
                const Text('(Decimals will match underlying token)'),
              ],
              const SizedBox(height: 30),
              Text('Quorum Threshold: ${daoConfig.quorumThreshold}%'),
              const SizedBox(height: 30),
              Text(
                  'Voting Duration: ${formatDuration(daoConfig.votingDuration)}'),
              const SizedBox(height: 10),
              Text('Voting Delay: ${formatDuration(daoConfig.votingDelay)}'),
              const SizedBox(height: 10),
              Text(
                  'Execution Delay: ${formatDuration(daoConfig.executionDelay)}'),
              const SizedBox(height: 30),
              if (daoConfig.tokenDeploymentMechanism ==
                      DaoTokenDeploymentMechanism.deployNewStandardToken &&
                  daoConfig.members.isNotEmpty) ...[
                Text('${daoConfig.members.length} Members',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      return List<DataRow>.generate(rowCount, (index) {
                        final member = members[index];
                        return DataRow(cells: [
                          DataCell(Text((index + 1).toString())),
                          DataCell(Text(member.address)),
                          DataCell(Text(member.amount.toString())),
                        ]);
                      });
                    } else {
                      final List<DataRow> displayedRows = [];
                      for (int i = 0; i < 3; i++) {
                        final member = members[i];
                        displayedRows.add(DataRow(cells: [
                          DataCell(Text((i + 1).toString())),
                          DataCell(Text(member.address)),
                          DataCell(Text(member.amount.toString())),
                        ]));
                      }
                      displayedRows.add(const DataRow(cells: [
                        DataCell(Text('...')),
                        DataCell(Text('...')),
                        DataCell(Text('...')),
                      ]));
                      for (int i = rowCount - 3; i < rowCount; i++) {
                        final member = members[i];
                        displayedRows.add(DataRow(cells: [
                          DataCell(Text((i + 1).toString())),
                          DataCell(Text(member.address)),
                          DataCell(Text(member.amount.toString())),
                        ]));
                      }
                      return displayedRows;
                    }
                  })(),
                ),
                const SizedBox(height: 30),
              ],
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
              const SizedBox(height: 30),
              SizedBox(
                width: 700,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: onBack, child: const Text('< Back')),
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
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
// lib/screens/creator/screen7_review.dart

```

### `lib/screens/creator/screen8_deploying.dart`
```dart
// lib/screens/creator/screen8_deploying.dart
import 'package:flutter/material.dart';
import '../../entities/human.dart'; // For Human().chain.name

// Screen 8: Deploying
class Screen8Deploying extends StatelessWidget {
  final String daoName;
  const Screen8Deploying({super.key, required this.daoName});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
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
// lib/screens/creator/screen8_deploying.dart

```

### `lib/screens/creator/screen9_deployment_complete.dart`
```dart
// lib/screens/creator/screen9_deployment_complete.dart
import 'package:flutter/material.dart';

// Screen 9: Deployment Complete
class Screen9DeploymentComplete extends StatelessWidget {
  final String daoName;
  final VoidCallback onGoToDAO;
  const Screen9DeploymentComplete({super.key, required this.daoName, required this.onGoToDAO});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Deployment Complete!',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 60),
          ElevatedButton(onPressed: onGoToDAO, child: const Text('Go to DAO')),
        ],
      ),
    );
  }
}
// lib/screens/creator/screen9_deployment_complete.dart

```
