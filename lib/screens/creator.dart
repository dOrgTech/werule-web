// creator.dart
import 'dart:typed_data';

import 'package:Homebase/main.dart';
import 'package:Homebase/utils/theme.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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

// ADDED: Enum for token deployment mechanism
enum DaoTokenDeploymentMechanism {
  deployNewStandardToken,
  wrapExistingToken,
}

// Configuration classes to store user-provided values
class DaoConfig {
  String? daoType;
  String? daoName;
  String? daoDescription;

  // --- Token Configuration ---
  // ADDED: Mechanism selector
  DaoTokenDeploymentMechanism tokenDeploymentMechanism =
      DaoTokenDeploymentMechanism.deployNewStandardToken; // Default

  // Original fields for "deploy new token" - RETAINED FOR EXISTING FUNCTIONALITY
  String? tokenSymbol;
  int? numberOfDecimals; // Used by Screen5Members and others
  bool nonTransferrable = true;

  // ADDED: New fields for "wrap existing token" - these will be populated but not used by existing save/deploy logic yet
  String? underlyingTokenAddress;
  String? wrappedTokenName;
  String? wrappedTokenSymbol;

  // --- Original common fields below ---
  String? totalSupply;
  Map<String, String> registry = {};
  int? proposalThreshold = 1;
  int quorumThreshold = 4;
  double supermajority = 75.0;
  Duration? votingDuration;
  Duration? votingDelay;
  Duration? executionDelay;
  List<Member> members = [];
  DaoConfig();
}

// Screen 1: Select DAO type (Identical to original)
class Screen1DaoType extends StatelessWidget {
  final DaoConfig daoConfig;
  final VoidCallback onNext;

  Screen1DaoType({required this.daoConfig, required this.onNext});

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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
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

// Screen 2: Basic Setup (MODIFIED)
class Screen2BasicSetup extends StatefulWidget {
  final DaoConfig daoConfig;
  final VoidCallback onNext;
  final VoidCallback onBack;
  bool memeNotShown = true;
  Screen2BasicSetup(
      {Key? key,
      required this.daoConfig,
      required this.onNext,
      required this.onBack})
      : super(key: key);

  @override
  _Screen2BasicSetupState createState() => _Screen2BasicSetupState();
}

class _Screen2BasicSetupState extends State<Screen2BasicSetup> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _daoNameController;
  late TextEditingController _daoDescriptionController;
  
  // Original controllers for "deploy new token"
  late TextEditingController
      _tokenSymbolController; // Original: used for daoConfig.tokenSymbol
  late TextEditingController
      _numberOfDecimalsController; // Original: used for daoConfig.numberOfDecimals
  late bool _nonTransferrable; // Original: used for daoConfig.nonTransferrable

  // ADDED: New controllers for "wrap existing token" UI
  late TextEditingController _underlyingTokenAddressController;
  late TextEditingController _wrappedTokenNameController;
  late TextEditingController _wrappedTokenSymbolController;

  // ADDED: State variable for the radio button selection
  late DaoTokenDeploymentMechanism _selectedMechanism;

  @override
  void initState() {
    super.initState();
    _daoNameController = TextEditingController(text: widget.daoConfig.daoName);
    _daoDescriptionController =
        TextEditingController(text: widget.daoConfig.daoDescription);

    _selectedMechanism =
        widget.daoConfig.tokenDeploymentMechanism; // Initialize from DaoConfig

    // Initialize original controllers for "deploy new token" path
    _tokenSymbolController =
        TextEditingController(text: widget.daoConfig.tokenSymbol);
    _numberOfDecimalsController = TextEditingController(
        text: widget.daoConfig.numberOfDecimals?.toString());
    _nonTransferrable = widget.daoConfig.nonTransferrable;

    // Initialize new controllers for "wrap existing token" path
    _underlyingTokenAddressController =
        TextEditingController(text: widget.daoConfig.underlyingTokenAddress);
    _wrappedTokenNameController =
        TextEditingController(text: widget.daoConfig.wrappedTokenName);
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
    _wrappedTokenNameController.dispose();
    _wrappedTokenSymbolController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate()) {
      widget.daoConfig.daoName = _daoNameController.text;
      widget.daoConfig.daoDescription = _daoDescriptionController.text;
      widget.daoConfig.tokenDeploymentMechanism =
          _selectedMechanism; // Save selected mechanism

      if (_selectedMechanism ==
          DaoTokenDeploymentMechanism.deployNewStandardToken) {
        // Save to original DaoConfig fields for existing functionality
        widget.daoConfig.tokenSymbol = _tokenSymbolController.text;
        widget.daoConfig.numberOfDecimals =
            int.tryParse(_numberOfDecimalsController.text);
        widget.daoConfig.nonTransferrable = _nonTransferrable;
        
        // Optionally clear the new fields in DaoConfig if they were populated from a previous selection
        widget.daoConfig.underlyingTokenAddress = null;
        widget.daoConfig.wrappedTokenName = null;
        widget.daoConfig.wrappedTokenSymbol = null;
      } else {
        // DaoTokenDeploymentMechanism.wrapExistingToken
        // Save to new DaoConfig fields. Existing logic in finishWizard will not use these yet.
        widget.daoConfig.underlyingTokenAddress =
            _underlyingTokenAddressController.text;
        widget.daoConfig.wrappedTokenName = _wrappedTokenNameController.text;
        widget.daoConfig.wrappedTokenSymbol =
            _wrappedTokenSymbolController.text;

        // Optionally clear original fields in DaoConfig
        widget.daoConfig.tokenSymbol = null;
        widget.daoConfig.numberOfDecimals = null;
        // widget.daoConfig.nonTransferrable = true; // Or some default
      }
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    // "Save and Continue" button is enabled only if "deploy new standard token" is selected.
    bool canProceed = _selectedMechanism ==
        DaoTokenDeploymentMechanism.deployNewStandardToken;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70),
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 500,
            child: Column(
              children: [
                Text("Organization identity",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 30), // Consistent spacing
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
                  // Consistent spacing
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
                const SizedBox(height: 30),
                Text("Governance Token",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),

                // ADDED: Radio buttons for token deployment mechanism
                Center(
                  child: SizedBox(
                    width: 500,
                    child: RadioListTile<DaoTokenDeploymentMechanism>(
                      title: const Text('Deploy new standard token'),
                      value: DaoTokenDeploymentMechanism.deployNewStandardToken,
                      groupValue: _selectedMechanism,
                      onChanged: (DaoTokenDeploymentMechanism? value) {
                        if (value != null) {
                          setState(() {
                            _selectedMechanism = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 500,
                    child: RadioListTile<DaoTokenDeploymentMechanism>(
                      title: const Text('Wrap existing ERC20 token'),
                      value: DaoTokenDeploymentMechanism.wrapExistingToken,
                      groupValue: _selectedMechanism,
                      onChanged: (DaoTokenDeploymentMechanism? value) {
                        if (value != null) {
                          setState(() {
                            _selectedMechanism = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Conditional fields based on selection
                if (_selectedMechanism ==
                    DaoTokenDeploymentMechanism.deployNewStandardToken) ...[
                  // This is the ORIGINAL UI for new token, using original controllers and DaoConfig fields
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
                            controller:
                                _tokenSymbolController, // Original controller
                            decoration: const InputDecoration(
                                counterText: "", labelText: 'Ticker Symbol'),
                            validator: (value) {
                              // Original validator
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
                                        width: 500,
                                        height: 550,
                                        child: AnimatedMemeWidget(),
                                      ),
                                    );
                                  }),
                                );
                              }
                            },
                            controller:
                                _numberOfDecimalsController, // Original controller
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Decimals'),
                            validator: (value) {
                              // Original validator
                              if (value == null || value.isEmpty) {
                                return 'How many decimal points do want for your governance token?';
                              }
                              int? decimals = int.tryParse(value);
                              if (decimals == null ||
                                  decimals < 0 ||
                                  decimals > 7) {
                                // Original max was 7
                                return 'between 0 and 6'; // Original message
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 300, // Original width
                    child: CheckboxListTile(
                      title: const Text('Non-transferable'),
                      value: _nonTransferrable, // Original state variable
                      activeColor: Theme.of(context).indicatorColor,
                      checkColor: Colors.black,
                      onChanged: (value) {
                        // Original onChanged logic
                        if (_nonTransferrable == true && value == false) {
                          // Only show dialog if unchecking from true
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Be advised:'),
                                content: Padding(
                                  padding: const EdgeInsets.all(28.0),
                                  child: SizedBox(
                                    width: 450,
                                    height: 270,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                            'Using a transferable governance token is not compatible with the reputation-based logical architecture of the On-Chain Jurisdiction.\n\nThis action is non-reversible.',
                                            style: TextStyle(height: 1.5)),
                                        SizedBox(height: 64),
                                        RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255)),
                                            children: [
                                              const TextSpan(
                                                  text:
                                                      "Learn more about the implications ",
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                              TextSpan(
                                                text: "here",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .indicatorColor,
                                                    decoration: TextDecoration
                                                        .underline),
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () => launchUrl(
                                                      Uri.parse(
                                                          "https://docs.openzeppelin.com/contracts/5.x/api/governance")),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actionsAlignment: MainAxisAlignment.center,
                                actionsPadding: EdgeInsets.all(40),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text("< Back")),
                                  SizedBox(width: 180),
                                  ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _nonTransferrable = value!;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('I understand')),
                                ],
                              );
                            },
                          );
                        } else {
                          setState(() {
                            _nonTransferrable = value!;
                          });
                        }
                      },
                    ),
                  ),
                ] else if (_selectedMechanism ==
                    DaoTokenDeploymentMechanism.wrapExistingToken) ...[
                  // ADDED: UI for "wrap existing token"
                  SizedBox(
                    width: 500,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _underlyingTokenAddressController,
                          maxLength: 42,
                          decoration: const InputDecoration(
                              labelText: 'Underlying ERC20 Token Address',
                              counterText: ""),
                          validator: (value) {
                            if (_selectedMechanism ==
                                DaoTokenDeploymentMechanism.wrapExistingToken) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the address of the token to wrap';
                              }
                              if (!RegExp(r'^0x[a-fA-F0-9]{40}$')
                                  .hasMatch(value)) {
                                // Basic address validation
                                return 'Please enter a valid Ethereum address';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _wrappedTokenNameController,
                          maxLength: 38,
                          decoration: const InputDecoration(
                              labelText:
                                  'Wrapped Token Name (e.g., Wrapped MyToken)'),
                          validator: (value) {
                            if (_selectedMechanism ==
                                    DaoTokenDeploymentMechanism
                                        .wrapExistingToken &&
                                (value == null || value.isEmpty)) {
                              return 'Please enter a name for your new wrapped token';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9]')),
                            UpperCaseTextFormatter(),
                          ],
                          maxLength: 7, // e.g. wXYZT
                          controller: _wrappedTokenSymbolController,
                          decoration: const InputDecoration(
                              counterText: "",
                              labelText: 'Wrapped Token Symbol (e.g., wXYZ)'),
                          validator: (value) {
                            if (_selectedMechanism ==
                                    DaoTokenDeploymentMechanism
                                        .wrapExistingToken &&
                                (value == null || value.isEmpty)) {
                              return 'Please enter a symbol for your new wrapped token';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
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
                        onPressed: canProceed
                            ? _saveAndNext
                            : null, // Button disabled if "wrap existing" is selected
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

// Screen 3: Quorums (Small modification to use effective token symbol for label)
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
  double _quorumThreshold = 6.0; // Default from original
  // double _proposalThreshold = 1.0; // From original, value now comes from controller
  late double _supermajority; 
  late TextEditingController thresholdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Using original logic for setting initial values
    _quorumThreshold = widget.daoConfig.quorumThreshold
        .toDouble(); // Was daoConfig.quorumThreshold?.toDouble() ?? 0;
    _supermajority = widget.daoConfig.supermajority; 
    thresholdController.text = widget.daoConfig.proposalThreshold.toString();
  }

  void _saveAndNext() {
    // Using original logic for saving values
    widget.daoConfig.quorumThreshold = _quorumThreshold.toInt();
    widget.daoConfig.supermajority = _supermajority; 
    widget.daoConfig.proposalThreshold =
        int.tryParse(thresholdController.text); // Original just did tryParse
    widget.onNext();
  }

  // Helper to get the correct token symbol for the proposal threshold label
  String get _effectiveTokenSymbolForProposalThreshold {
    if (widget.daoConfig.tokenDeploymentMechanism ==
        DaoTokenDeploymentMechanism.wrapExistingToken) {
      return widget.daoConfig.wrappedTokenSymbol?.isNotEmpty == true
          ? widget.daoConfig.wrappedTokenSymbol!
          : "WRAPPED"; // Placeholder
    }
    // Default to original tokenSymbol for existing "deploy new token" path
    return widget.daoConfig.tokenSymbol?.isNotEmpty == true
        ? widget.daoConfig.tokenSymbol!
        : "SYM"; // Original placeholder was "SYM" or daoConfig.tokenSymbol!
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
                      color: Color.fromARGB(255, 78, 78, 78), width: 0.4)),
              padding: EdgeInsets.all(35),
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
                      color: Color.fromARGB(255, 78, 78, 78), width: 0.4)),
              padding: EdgeInsets.all(35),
              child: SizedBox(
                width: 500,
                child: Column(
                  children: [
                    Text('Proposal Threashold', // Original spelling
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        // Original was TextField
                        controller: thresholdController,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          // Dynamically update label based on selected token
                          labelText:
                              '${_effectiveTokenSymbolForProposalThreshold} amount',
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

// Screen 4: Durations (Identical to original, assuming DurationInput is defined elsewhere)
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

// Custom widget for duration input (Copied from original)
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

// Helper classes for member entries (Copied from original)
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

// Screen 6: Registry (Copied from original)
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Icon(Icons.add), Text(' Add Entry')],
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

// Helper classes for registry entries (Copied from original)
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

// Screen 7: Review & Deploy (MODIFIED to show token info conditionally)
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
              Text('${daoConfig.daoName ?? "Untitled DAO"}',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text('On-Chain Organization'), // As per original Screen7Review
              const SizedBox(height: 20),
              Container(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Text(
                      daoConfig.daoDescription ?? 'No description provided.')),
              const SizedBox(height: 10), // As per original Screen7Review

              // Token Details - Conditional Display
              if (daoConfig.tokenDeploymentMechanism ==
                  DaoTokenDeploymentMechanism.deployNewStandardToken) ...[
                Text(
                    'Ticker Symbol: ${daoConfig.tokenSymbol ?? "N/A"}'), // Uses original field
                Text(
                    'Number of Decimals: ${daoConfig.numberOfDecimals?.toString() ?? "N/A"}'), // Uses original
                Text(
                    'Non-Transferable: ${daoConfig.nonTransferrable ? 'Yes' : 'No'}'), // Uses original
              ] else ...[
                Text('Deployment Type: Wrap Existing Token'),
                Text(
                    'Underlying Token Address: ${daoConfig.underlyingTokenAddress ?? "N/A"}'),
                Text(
                    'Wrapped Token Name: ${daoConfig.wrappedTokenName ?? "N/A"}'),
                Text(
                    'Wrapped Token Symbol: ${daoConfig.wrappedTokenSymbol ?? "N/A"}'),
                Text('(Decimals will match underlying token)'),
              ],
              const SizedBox(height: 30),

              Text('Quorum Threshold: ${daoConfig.quorumThreshold}%'),
              const SizedBox(height: 30), // Original spacing
              Text(
                  'Voting Duration: ${formatDuration(daoConfig.votingDuration)}'),
              const SizedBox(height: 10),
              Text('Voting Delay: ${formatDuration(daoConfig.votingDelay)}'),
              const SizedBox(height: 10),
              Text(
                  'Execution Delay: ${formatDuration(daoConfig.executionDelay)}'), // Original was 'Execution Availability'
              const SizedBox(height: 30),

              // Members list (Only for new token deployment, as per original logic in Screen7Review)
              if (daoConfig.tokenDeploymentMechanism ==
                      DaoTokenDeploymentMechanism.deployNewStandardToken &&
                  daoConfig.members.isNotEmpty) ...[
                Text('${daoConfig.members.length} Members',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
                      displayedRows.add(DataRow(cells: [
                        const DataCell(Text('...')),
                        const DataCell(Text('...')),
                        const DataCell(Text('...')),
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

              Text('Registry Entries:',
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


// Screen 8: Deploying (Identical to original)
class Screen8Deploying extends StatelessWidget {
  final String daoName;
  Screen8Deploying({required this.daoName});
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

// Screen 9: Deployment Complete (Identical to original)
class Screen9DeploymentComplete extends StatelessWidget {
  final String daoName;
  final VoidCallback onGoToDAO;
  Screen9DeploymentComplete({required this.daoName, required this.onGoToDAO});
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

// FlashingIcon and meniu TextStyle (Identical to original)
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

// Main wizard widget (finishWizard remains IDENTICAL to original for "deploy new token" path)
class DaoSetupWizard extends StatefulWidget {
  late Org org;
  DaoSetupWizard({Key? key}) : super(key: key);

  @override
  _DaoSetupWizardState createState() => _DaoSetupWizardState();
}

class _DaoSetupWizardState extends State<DaoSetupWizard> {
  int currentStep = 0;
  int maxStepReached = 0;
  DaoConfig daoConfig = DaoConfig();

  void goToStep(int step) {
    if (step <= maxStepReached) {
      setState(() {
        currentStep = step;
      });
    }
  }

  void nextStep() {
    if (currentStep < 8) {
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

  void finishWizard() {
    // This function is called from Screen7Review (step 6)
    setState(() {
      currentStep = 7; // Move to the Deploying screen
    });

    Future.delayed(Duration.zero, () async {
      // Logic here is for the "deployNewStandardToken" path, as "wrapExistingToken" path is disabled from proceeding.
      // It uses the original DaoConfig fields (tokenSymbol, numberOfDecimals, etc.)
      // to populate `widget.org` EXACTLY AS BEFORE.

      Token token = Token(
        // Original Token creation
        type: "erc20",
        name: daoConfig.daoName ??
            '', // Original: daoConfig.daoName used for token name
        symbol: daoConfig.tokenSymbol ?? '', // Original field
        decimals: daoConfig.numberOfDecimals, // Original field
      );

      widget.org = Org(
        // Original Org creation
        name: daoConfig.daoName ?? '',
        govToken: token,
        description: daoConfig.daoDescription,
      );
      // All original Org population logic from your creator.txt
      widget.org.quorum = daoConfig.quorumThreshold;
      widget.org.votingDuration = daoConfig.votingDuration?.inMinutes ?? 0;
      widget.org.votingDelay = daoConfig.votingDelay?.inMinutes ?? 0;
      widget.org.executionDelay = daoConfig.executionDelay?.inSeconds ?? 0;
      widget.org.holders = daoConfig.members.length;
      widget.org.symbol = daoConfig.tokenSymbol; // Original field used here
      widget.org.registry = daoConfig.registry;
      widget.org.proposalThreshold = daoConfig.proposalThreshold.toString();
      widget.org.nonTransferrable =
          daoConfig.nonTransferrable; // Original field
      widget.org.creationDate = DateTime.now();
      widget.org.decimals = daoConfig.numberOfDecimals; // Original field
      widget.org.totalSupply = daoConfig.totalSupply.toString();

      try {
        for (Member member in daoConfig.members) {
          // Original member processing
          if (widget.org.decimals != null) {
            // Original null check for decimals
            member.personalBalance =
                member.personalBalance.toString() + "0" * widget.org.decimals!;
          } else {
            member.personalBalance = member.personalBalance.toString();
          }
          widget.org.memberAddresses[member.address] = member;
        }

        // Call createDAO with only widget.org, AS PER ORIGINAL
        List<String> results = await createDAO(widget.org);

        widget.org.address = results[0];
        widget.org.govTokenAddress = results[1];
        widget.org.treasuryAddress = results[2];
        widget.org.registryAddress = results[3];
        widget.org.govToken = Token(
            type: "erc20",
            symbol: widget.org.symbol!, // From original org population
            decimals: widget.org.decimals, // From original org population
            name: widget.org.name, // From original org population
            address: results[1]);
        orgs.add(widget.org);
        print("we caught this back" + results.toString());
        setState(() {
          currentStep = 8; // Move to the Deployment Complete screen
        });
      } catch (e) {
        print("Error creating DAO: $e");
        setState(() {
          currentStep = 6;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('DAO Deployment Failed: ${e.toString()}',
                    overflow: TextOverflow.ellipsis),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5)),
          );
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
        content = Padding(
            padding: const EdgeInsets.all(38.0),
            child: Screen5Members(
                daoConfig: daoConfig, onNext: nextStep, onBack: previousStep));
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Error: DAO Address not available after deployment.'),
                          backgroundColor: Colors.red),
                    );
                  }
                }));
        break;
      default:
        content = Container(child: Center(child: Text("Error: Unknown Step")));
    }

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
                            ListTile(
                                title: const Text('1. Type'),
                                onTap: () => goToStep(0),
                                selected: currentStep == 0,
                                enabled: true,
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile(
                                title: const Text('2. Identity'),
                                onTap: maxStepReached >= 1
                                    ? () => goToStep(1)
                                    : null,
                                selected: currentStep == 1,
                                enabled: maxStepReached >= 1,
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile(
                                title: const Text('3. Thresholds'),
                                onTap: maxStepReached >= 2
                                    ? () => goToStep(2)
                                    : null,
                                selected: currentStep == 2,
                                enabled: maxStepReached >= 2,
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile(
                                title: const Text('4. Durations'),
                                onTap: maxStepReached >= 3
                                    ? () => goToStep(3)
                                    : null,
                                selected: currentStep == 3,
                                enabled: maxStepReached >= 3,
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile(
                                title: const Text('5. Members'),
                                onTap: maxStepReached >= 4
                                    ? () => goToStep(4)
                                    : null,
                                selected: currentStep == 4,
                                enabled: maxStepReached >= 4,
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile(
                                title: const Text('6. Registry'),
                                onTap: maxStepReached >= 5
                                    ? () => goToStep(5)
                                    : null,
                                selected: currentStep == 5,
                                enabled: maxStepReached >= 5,
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile(
                                title: const Text('7. Review & Deploy'),
                                onTap: maxStepReached >= 6
                                    ? () => goToStep(6)
                                    : null,
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
