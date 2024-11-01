import 'package:Homebase/main.dart';
import 'package:Homebase/utils/theme.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../entities/contractFunctions.dart';
import '../entities/human.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';
import '../entities/token.dart';
import '../widgets/screen5Members.dart';
import 'explorer.dart';
import "package:file_picker/file_picker.dart";
import 'package:csv/csv.dart';
import 'dart:convert';

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
        return Icon(
          Icons.security,
          size: 44,
          color: _colorAnimation.value,
        );
      },
    );
  }
}

TextStyle meniu =
    const TextStyle(fontSize: 24, color: Color.fromARGB(255, 178, 178, 178));

// Configuration classes to store user-provided values
class DaoConfig {
  String? daoType;
  String? daoName;
  String? daoDescription;
  String? tokenSymbol;
  String? totalSupply;
  int? numberOfDecimals;
  bool nonTransferrable = true;
  int quorumThreshold = 4;
  double supermajority = 75.0; // Added supermajority field
  Duration? votingDuration;
  Duration? votingDelay;
  Duration? executionAvailability; // Added execution availability duration
  List<Member> members = [];
  DaoConfig();
}

// Main wizard widget
class DaoSetupWizard extends StatefulWidget {
  @override
  _DaoSetupWizardState createState() => _DaoSetupWizardState();
}

class _DaoSetupWizardState extends State<DaoSetupWizard> {
  int currentStep = 0;
  int maxStepReached = 0; // Track the furthest step reached
  DaoConfig daoConfig = DaoConfig();

  void goToStep(int step) {
    if (step <= maxStepReached) {
      setState(() {
        currentStep = step;
      });
    }
  }

  void nextStep() {
    if (currentStep < 6) {
      // Updated to 6 to account for all steps
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
    setState(() {
      currentStep = 6; // Move to the Deploying screen
    });

    // Start the deployment asynchronously
    Future.delayed(Duration.zero, () async {
      // Create Token and Org instances using collected data
      Token token = Token(
        name: daoConfig.daoName ?? '',
        symbol: daoConfig.tokenSymbol ?? '',
        decimals: daoConfig.numberOfDecimals ?? 0,
      );

      Org org = Org(
        name: daoConfig.daoName ?? '',
        govToken: token,
        description: daoConfig.daoDescription,
      );
      org.quorum = daoConfig.quorumThreshold ?? 0;
      org.supermajority = daoConfig.supermajority.toInt();
      org.votingDuration = daoConfig.votingDuration?.inMinutes ?? 0;
      org.votingDelay = daoConfig.votingDelay?.inMinutes ?? 0;
      org.executionAvailability =
          daoConfig.executionAvailability?.inMinutes ?? 0;
      org.holders = daoConfig.members.length;
      org.symbol = daoConfig.tokenSymbol;
      org.nonTransferrable = daoConfig.nonTransferrable;
      org.creationDate = DateTime.now();
      org.decimals = daoConfig.numberOfDecimals;
      org.totalSupply = daoConfig.totalSupply.toString();

      try {
        List<String> results = await createDAO(org, this);
        org.address = results[0];
        org.govTokenAddress = results[1];
        org.treasuryAddress = results[2];
        await daosCollection.doc(org.address).set(org.toJson());
        orgs.add(org);
        WriteBatch batch = FirebaseFirestore.instance.batch();
        var membersCollection =
            daosCollection.doc(org.address).collection("members");
        for (Member member in daoConfig.members) {
          batch.set(membersCollection.doc(member.address), member.toJson());
        }
        await batch.commit();

        setState(() {
          currentStep = 7; // Move to the Deployment Complete screen
        });
      } catch (e) {
        print("Error creating DAO: $e");
        // Optionally handle the error (e.g., show an error message)
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
          child: Screen1DaoType(
            daoConfig: daoConfig,
            onNext: nextStep,
          ),
        );
        break;
      case 1:
        content = Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen2BasicSetup(
            daoConfig: daoConfig,
            onNext: nextStep,
            onBack: previousStep,
          ),
        );
        break;
      case 2:
        content = Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen3Quorums(
            daoConfig: daoConfig,
            onNext: nextStep,
            onBack: previousStep,
          ),
        );
        break;
      case 3:
        content = Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen4Durations(
            daoConfig: daoConfig,
            onNext: nextStep,
            onBack: previousStep,
          ),
        );
        break;
      case 4:
        content = Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen5Members(
            daoConfig: daoConfig,
            onNext: nextStep,
            onBack: previousStep,
          ),
        );
        break;
      case 5:
        content = Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen6Review(
            daoConfig: daoConfig,
            onBack: previousStep,
            onFinish: finishWizard,
          ),
        );
        break;
      case 6:
        content = Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen7Deploying(
            daoName: daoConfig.daoName ?? 'DAO',
          ),
        );
        break;
      case 7:
        content = Padding(
          padding: const EdgeInsets.all(38.0),
          child: Screen8DeploymentComplete(
            daoName: daoConfig.daoName ?? 'DAO',
            onGoToDAO: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MyHomePage(title: "Homebase"),
                ),
              );
            },
          ),
        );
        break;
      default:
        content = Container();
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
                // Left side: Wizard steps overview
                Container(
                  padding: const EdgeInsets.only(left: 38.0),
                  width: 270,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wrap ListView in Material to provide Material context
                      Material(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            ListTile(
                              title: const Text('1. Org Type'),
                              onTap: () => goToStep(0),
                              selected: currentStep == 0,
                              enabled: true,
                              selectedColor: Colors.black,
                              selectedTileColor:
                                  const Color.fromARGB(255, 121, 133, 128),
                            ),
                            ListTile(
                              title: const Text('2. Org Identity'),
                              onTap: maxStepReached >= 1
                                  ? () => goToStep(1)
                                  : null,
                              selected: currentStep == 1,
                              enabled: maxStepReached >= 1,
                              selectedColor: Colors.black,
                              selectedTileColor:
                                  const Color.fromARGB(255, 121, 133, 128),
                            ),
                            ListTile(
                              title: const Text('3. Quorums'),
                              onTap: maxStepReached >= 2
                                  ? () => goToStep(2)
                                  : null,
                              selected: currentStep == 2,
                              enabled: maxStepReached >= 2,
                              selectedColor: Colors.black,
                              selectedTileColor:
                                  const Color.fromARGB(255, 121, 133, 128),
                            ),
                            ListTile(
                              title: const Text('4. Durations'),
                              onTap: maxStepReached >= 3
                                  ? () => goToStep(3)
                                  : null,
                              selected: currentStep == 3,
                              enabled: maxStepReached >= 3,
                              selectedColor: Colors.black,
                              selectedTileColor:
                                  const Color.fromARGB(255, 121, 133, 128),
                            ),
                            ListTile(
                              title: const Text('5. Members'),
                              onTap: maxStepReached >= 4
                                  ? () => goToStep(4)
                                  : null,
                              selected: currentStep == 4,
                              enabled: maxStepReached >= 4,
                              selectedColor: Colors.black,
                              selectedTileColor:
                                  const Color.fromARGB(255, 121, 133, 128),
                            ),
                            ListTile(
                              title: const Text('6. Review & Deploy'),
                              onTap: maxStepReached >= 5
                                  ? () => goToStep(5)
                                  : null,
                              selected: currentStep == 5,
                              enabled: maxStepReached >= 5,
                              selectedColor: Colors.black,
                              selectedTileColor:
                                  const Color.fromARGB(255, 121, 133, 128),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side: Current screen
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

// Screen 1: Select DAO type
class Screen1DaoType extends StatelessWidget {
  final DaoConfig daoConfig;
  final VoidCallback onNext;

  Screen1DaoType({required this.daoConfig, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Ensure content can scroll
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Make the votes binding?',
                style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: 16),
            const SizedBox(
                width: 400,
                child: Text(
                    "For distributed management of collective assets, you will need to deploy a contract on-chain.",
                    style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 194, 194, 194)))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Option 1: On-chain
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
                                // textScaleFactor: 1.2,
                              ),
                            ),
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
                        daoConfig.daoType = 'Off-chain';
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
                          children: const [
                            SizedBox(height: 38),
                            Icon(Icons.forum, size: 40),
                            SizedBox(height: 14),
                            Text('Off-chain', style: TextStyle(fontSize: 23.5)),
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
              ],
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 70),
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 500,
            child: Column(
              children: [
                Text("Create the identity of your company",
                    style: Theme.of(context).textTheme.headline5),
                const SizedBox(height: 120),
                SizedBox(
                  width: 500,
                  child: TextFormField(
                    controller: _daoNameController,
                    maxLength: 80,
                    decoration:
                        const InputDecoration(labelText: 'Company Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name for your company';
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
                        return 'What is this company about at a high level?';
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
                          controller: _tokenSymbolController,
                          decoration:
                              const InputDecoration(labelText: 'Token Symbol'),
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
                                decimals > 18) {
                              return 'Please enter a number between 0 and 18';
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
                  width: 300,
                  child: CheckboxListTile(
                    title: const Text('Non-transferrable'),
                    value: _nonTransferrable,
                    onChanged: (bool? value) {
                      setState(() {
                        _nonTransferrable = value ?? false;
                      });
                    },
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
  late double _supermajority; // Added supermajority variable

  @override
  void initState() {
    super.initState();
    _quorumThreshold = widget.daoConfig.quorumThreshold?.toDouble() ?? 0;
    _supermajority = widget.daoConfig.supermajority; // Default at 75%
  }

  void _saveAndNext() {
    // Save the values
    widget.daoConfig.quorumThreshold = _quorumThreshold.toInt();
    widget.daoConfig.supermajority = _supermajority;

    widget.onNext();
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
            Text('Set Quorum', style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: 86),
            Text('${_quorumThreshold.toStringAsFixed(0)} %',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 27,
                    color: Theme.of(context).indicatorColor)),
            const SizedBox(height: 86),
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
                  const SizedBox(height: 50),
                ],
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
  late TextEditingController
      _executionAvailabilityDaysController; // New controller
  late TextEditingController
      _executionAvailabilityHoursController; // New controller
  late TextEditingController
      _executionAvailabilityMinutesController; // New controller

  @override
  void initState() {
    super.initState();
    _votingDurationDaysController = TextEditingController();
    _votingDurationHoursController = TextEditingController();
    _votingDurationMinutesController = TextEditingController();
    _votingDelayDaysController = TextEditingController();
    _votingDelayHoursController = TextEditingController();
    _votingDelayMinutesController = TextEditingController();
    _executionAvailabilityDaysController =
        TextEditingController(); // Initialize
    _executionAvailabilityHoursController =
        TextEditingController(); // Initialize
    _executionAvailabilityMinutesController =
        TextEditingController(); // Initialize
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

    int executionAvailabilityDays =
        int.tryParse(_executionAvailabilityDaysController.text) ?? 0;
    int executionAvailabilityHours =
        int.tryParse(_executionAvailabilityHoursController.text) ?? 0;
    int executionAvailabilityMinutes =
        int.tryParse(_executionAvailabilityMinutesController.text) ?? 0;
    widget.daoConfig.executionAvailability = Duration(
        days: executionAvailabilityDays,
        hours: executionAvailabilityHours,
        minutes: executionAvailabilityMinutes);

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
    _executionAvailabilityDaysController.dispose();
    _executionAvailabilityHoursController.dispose();
    _executionAvailabilityMinutesController.dispose();
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
                title: 'Execution Availability',
                description:
                    'How long will a passed proposal be available for execution before it expires',
                daysController: _executionAvailabilityDaysController,
                hoursController: _executionAvailabilityHoursController,
                minutesController: _executionAvailabilityMinutesController,
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
  int _totalTokens = 0;

  @override
  void initState() {
    super.initState();
    if (widget.daoConfig.members.isNotEmpty) {
      _memberEntries = widget.daoConfig.members
          .map((member) => MemberEntry(
                addressController: TextEditingController(text: member.address),
                amountController:
                    TextEditingController(text: member.amount.toString()),
              ))
          .toList();
    } else {
      _addMemberEntry();
    }
    _calculateTotalTokens();
  }

  void _addMemberEntry() {
    setState(() {
      _memberEntries.add(MemberEntry(
        addressController: TextEditingController(),
        amountController: TextEditingController(),
      ));
    });
  }

  void _removeMemberEntry(int index) {
    setState(() {
      _memberEntries.removeAt(index);
      _calculateTotalTokens();
    });
  }

  void _calculateTotalTokens() {
    int total = 0;
    for (var entry in _memberEntries) {
      int amount = int.tryParse(entry.amountController.text) ?? 0;
      total += amount;
    }
    widget.daoConfig.totalSupply = total.toString().padRight(
        total.toString().length + widget.daoConfig.numberOfDecimals!, '0');
    setState(() {
      _totalTokens = total;
    });
  }

  void _saveAndNext() {
    widget.daoConfig.members = _memberEntries
        .map((entry) => Member(
              address: entry.addressController.text,
              personalBalance: entry.amountController.text
                  .padRight(widget.daoConfig.numberOfDecimals!, "0"),
              amount: int.tryParse(entry.amountController.text) ?? 0,
              votingWeight: "0",
            ))
        .toList();
    widget.onNext();
  }

  void _loadCsvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      // Read file content as string
      final input = utf8.decode(file.bytes!);
      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(input, eol: '\n');

      // The first row should be headers
      if (csvTable.isNotEmpty) {
        List<dynamic> headers = csvTable[0];
        if (headers.length >= 2 &&
            headers[0].toString().toLowerCase() == 'address' &&
            headers[1].toString().toLowerCase() == 'amount') {
          // Remove the header row
          csvTable.removeAt(0);

          List<MemberEntry> entries = [];

          for (var row in csvTable) {
            if (row.length >= 2) {
              String address = row[0].toString();
              String amount = row[1].toString();

              entries.add(MemberEntry(
                addressController: TextEditingController(text: address),
                amountController: TextEditingController(text: amount),
              ));
            }
          }

          setState(() {
            _memberEntries = entries;
            _calculateTotalTokens();
          });
        } else {
          // Show error: Invalid CSV headers
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Invalid CSV headers. Expected "address" and "amount".')),
          );
        }
      }
    } else {
      // User canceled the picker
    }
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
    return SingleChildScrollView(
      // Ensure content can scroll
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Initial members',
                style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: 26),
            const Text(
                'Specify the address and the voting power of your associates.\nVoting power is represented by their amount of tokens.',
                style: TextStyle(
                    fontSize: 14, color: Color.fromARGB(255, 194, 194, 194))),
            const SizedBox(height: 53),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Total Tokens: ', style: TextStyle(fontSize: 19)),
                Text('$_totalTokens',
                    style: TextStyle(
                        fontSize: 19, color: Theme.of(context).indicatorColor)),
              ],
            ),
            const SizedBox(height: 75),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _memberEntries.length,
              itemBuilder: (context, index) {
                return MemberEntryWidget(
                  entry: _memberEntries[index],
                  onRemove: () => _removeMemberEntry(index),
                  onChanged: _calculateTotalTokens,
                );
              },
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadCsvFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload CSV'),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: _addMemberEntry,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add),
                      Text(' Add Member'),
                    ],
                  ),
                ),
              ],
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

// Helper classes for member entries
class MemberEntry {
  TextEditingController addressController;
  TextEditingController amountController;

  MemberEntry(
      {required this.addressController, required this.amountController});
}

class MemberEntryWidget extends StatelessWidget {
  final MemberEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  MemberEntryWidget(
      {required this.entry, required this.onRemove, required this.onChanged});

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
                  'Execution Availability: ${formatDuration(daoConfig.executionAvailability)}'),
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
