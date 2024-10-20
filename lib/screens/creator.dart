import 'package:Homebase/main.dart';
import 'package:flutter/material.dart';
import '../entities/contractFunctions.dart';
import '../entities/human.dart';
import '../entities/org.dart';
import '../entities/token.dart';
import 'explorer.dart';

// Configuration classes to store user-provided values
class DaoConfig {
  String? daoType;
  String? daoName;
  String? daoDescription;
  String? tokenSymbol;
  int? numberOfDecimals;
  bool nonTransferrable = false;
  int? quorumThreshold;
  double supermajority = 75.0; // Added supermajority field
  Duration? votingDuration;
  Duration? votingDelay;
  Duration? executionAvailability; // Added execution availability duration
  List<Member> members = [];
  DaoConfig();
}

class Member {
  String address;
  int amount;
  Member({required this.address, required this.amount});
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
    if (currentStep < 6) { // Updated to 6 to account for all steps
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
      org.executionAvailability = daoConfig.executionAvailability?.inMinutes ?? 0;
      org.holders = daoConfig.members.length;
      org.symbol=daoConfig.tokenSymbol;

      try {
        List<String> results = await createDAO(org, this);
        org.address = results[0];
        org.govTokenAddress = results[1];
        org.treasuryAddress = results[2];
        await daosCollection.doc(org.address).set(org.toJson());
        orgs.add(org);

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
            onNext: nextStep, // Changed from onFinish to onNext
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
                  child: Icon(Icons.close),
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
                  padding: EdgeInsets.only(left: 38.0),
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
                              title: Text('1. DAO Type'),
                              onTap: () => goToStep(0),
                              selected: currentStep == 0,
                              enabled: true,
                              selectedColor: Colors.black,
                              selectedTileColor: Color.fromARGB(255, 121, 133, 128),
                            ),
                            ListTile(
                              title: Text('2. Basic Setup'),
                              onTap: maxStepReached >= 1 ? () => goToStep(1) : null,
                              selected: currentStep == 1,
                              enabled: maxStepReached >= 1,
                              selectedColor: Colors.black,
                              selectedTileColor: Color.fromARGB(255, 121, 133, 128),
                            ),
                            ListTile(
                              title: Text('3. Quorums'),
                              onTap: maxStepReached >= 2 ? () => goToStep(2) : null,
                              selected: currentStep == 2,
                              enabled: maxStepReached >= 2,
                              selectedColor: Colors.black,
                              selectedTileColor: Color.fromARGB(255, 121, 133, 128),
                            ),
                            ListTile(
                              title: Text('4. Durations'),
                              onTap: maxStepReached >= 3 ? () => goToStep(3) : null,
                              selected: currentStep == 3,
                              enabled: maxStepReached >= 3,
                              selectedColor: Colors.black,
                              selectedTileColor: Color.fromARGB(255, 121, 133, 128),
                            ),
                            ListTile(
                              title: Text('5. Members'),
                              onTap: maxStepReached >= 4 ? () => goToStep(4) : null,
                              selected: currentStep == 4,
                              enabled: maxStepReached >= 4,
                              selectedColor: Colors.black,
                              selectedTileColor: Color.fromARGB(255, 121, 133, 128),
                            ),
                            ListTile(
                              title: Text('6. Review & Deploy'),
                              onTap: maxStepReached >= 5 ? () => goToStep(5) : null,
                              selected: currentStep == 5,
                              enabled: maxStepReached >= 5,
                              selectedColor: Colors.black,
                              selectedTileColor: Color.fromARGB(255, 121, 133, 128),
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
    return SingleChildScrollView( // Ensure content can scroll
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Select DAO Type', style: Theme.of(context).textTheme.headline5),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Option 1: On-chain
                SizedBox(
                  width: 450,
                  height: 450,
                  child: Padding(
                    padding: const EdgeInsets.all(38.0),
                    child: TextButton(
                      onPressed: () {
                        daoConfig.daoType = 'On-chain';
                        onNext();
                      },
                      child: Container(
                        margin: EdgeInsets.all(38.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Placeholder(
                              fallbackHeight: 150,
                              fallbackWidth: double.infinity,
                            ),
                            SizedBox(height: 16),
                            Text('On-chain', style: TextStyle(fontSize: 24)),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla accumsan.',
                                textAlign: TextAlign.center,
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
                  width: 450,
                  height: 450,
                  child: Padding(
                    padding: const EdgeInsets.all(38.0),
                    child: TextButton(
                      onPressed: () {
                        daoConfig.daoType = 'Off-chain';
                        onNext();
                      },
                      child: Container(
                        margin: EdgeInsets.all(38.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Placeholder(
                              fallbackHeight: 150,
                              fallbackWidth: double.infinity,
                            ),
                            SizedBox(height: 16),
                            Text('Off-chain', style: TextStyle(fontSize: 24)),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla accumsan.',
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

  Screen2BasicSetup({required this.daoConfig, required this.onNext, required this.onBack});

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
    _daoDescriptionController = TextEditingController(text: widget.daoConfig.daoDescription);
    _tokenSymbolController = TextEditingController(text: widget.daoConfig.tokenSymbol);
    _numberOfDecimalsController =
        TextEditingController(text: widget.daoConfig.numberOfDecimals?.toString());
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
      widget.daoConfig.numberOfDecimals = int.parse(_numberOfDecimalsController.text);
      widget.daoConfig.nonTransferrable = _nonTransferrable;
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Ensure content can scroll
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70),
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 500,
            child: Column(
              children: [
                Text("Create the identity of your DAO", style: Theme.of(context).textTheme.headline5),
                SizedBox(height: 120),
                SizedBox(
                  width: 500,
                  child: TextFormField(
                    controller: _daoNameController,
                    maxLength: 80,
                    decoration: InputDecoration(labelText: 'DAO Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the DAO Name';
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
                    decoration: InputDecoration(labelText: 'DAO Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the DAO Description';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 36),
                SizedBox(
                  width: 500,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 7,
                        child: TextFormField(
                          controller: _tokenSymbolController,
                          decoration: InputDecoration(labelText: 'Token Symbol'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Token Symbol';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _numberOfDecimalsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Decimals'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the number of decimals';
                            }
                            int? decimals = int.tryParse(value);
                            if (decimals == null || decimals < 0 || decimals > 18) {
                              return 'Please enter a number between 0 and 18';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: 300,
                  child: CheckboxListTile(
                    title: Text('Non-transferrable'),
                    value: _nonTransferrable,
                    onChanged: (bool? value) {
                      setState(() {
                        _nonTransferrable = value ?? false;
                      });
                    },
                  ),
                ),
                SizedBox(height: 56),
                SizedBox(
                  width: 700,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: widget.onBack,
                        child: Text('Back'),
                      ),
                      ElevatedButton(
                        onPressed: _saveAndNext,
                        child: Text('Next'),
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

  Screen3Quorums({required this.daoConfig, required this.onNext, required this.onBack});

  @override
  _Screen3QuorumsState createState() => _Screen3QuorumsState();
}

class _Screen3QuorumsState extends State<Screen3Quorums> {
  late double _quorumThreshold;
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
    return SingleChildScrollView( // Ensure content can scroll
      child: Padding(
        padding: const EdgeInsets.all(38.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Quorums', style: Theme.of(context).textTheme.headline5),
            SizedBox(height: 86),
            SizedBox(
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Quorum Threshold', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  Text('Minimum participation required for a proposal to pass'),
                  SizedBox(height: 50),
                  Text('Supermajority', style: TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    min: 50,
                    max: 100,
                    divisions: 50,
                    value: _supermajority,
                    label: _supermajority.round().toString() + '%',
                    onChanged: (value) {
                      setState(() {
                        _supermajority = value;
                      });
                    },
                  ),
                  Text('Minimum percentage required to change the DAO configuration'),
                ],
              ),
            ),
            SizedBox(height: 86),
            SizedBox(
              width: 700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: widget.onBack,
                    child: Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: _saveAndNext,
                    child: Text('Next'),
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

  Screen4Durations({required this.daoConfig, required this.onNext, required this.onBack});

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
  late TextEditingController _executionAvailabilityDaysController; // New controller
  late TextEditingController _executionAvailabilityHoursController; // New controller
  late TextEditingController _executionAvailabilityMinutesController; // New controller

  @override
  void initState() {
    super.initState();
    _votingDurationDaysController = TextEditingController();
    _votingDurationHoursController = TextEditingController();
    _votingDurationMinutesController = TextEditingController();
    _votingDelayDaysController = TextEditingController();
    _votingDelayHoursController = TextEditingController();
    _votingDelayMinutesController = TextEditingController();
    _executionAvailabilityDaysController = TextEditingController(); // Initialize
    _executionAvailabilityHoursController = TextEditingController(); // Initialize
    _executionAvailabilityMinutesController = TextEditingController(); // Initialize
  }

  void _saveAndNext() {
    // Save the values
    int votingDurationDays = int.tryParse(_votingDurationDaysController.text) ?? 0;
    int votingDurationHours = int.tryParse(_votingDurationHoursController.text) ?? 0;
    int votingDurationMinutes = int.tryParse(_votingDurationMinutesController.text) ?? 0;
    widget.daoConfig.votingDuration = Duration(
        days: votingDurationDays, hours: votingDurationHours, minutes: votingDurationMinutes);

    int votingDelayDays = int.tryParse(_votingDelayDaysController.text) ?? 0;
    int votingDelayHours = int.tryParse(_votingDelayHoursController.text) ?? 0;
    int votingDelayMinutes = int.tryParse(_votingDelayMinutesController.text) ?? 0;
    widget.daoConfig.votingDelay = Duration(
        days: votingDelayDays, hours: votingDelayHours, minutes: votingDelayMinutes);

    int executionAvailabilityDays = int.tryParse(_executionAvailabilityDaysController.text) ?? 0;
    int executionAvailabilityHours = int.tryParse(_executionAvailabilityHoursController.text) ?? 0;
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
    return SingleChildScrollView( // Ensure content can scroll
      child: Padding(
        padding: const EdgeInsets.all(38.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Durations', style: Theme.of(context).textTheme.headline5),
            SizedBox(height: 86),
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
            SizedBox(height: 76),
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
            SizedBox(height: 76),
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
            SizedBox(height: 86),
            SizedBox(
              width: 700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: widget.onBack,
                    child: Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: _saveAndNext,
                    child: Text('Next'),
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
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: daysController,
                maxLength: 2,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Days',
                  counterText: '',
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: hoursController,
                maxLength: 2,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Hours',
                  counterText: '',
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: minutesController,
                maxLength: 2,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Minutes',
                  counterText: '',
                ),
              ),
            ),
          ],
        ),
        if (description.isNotEmpty) ...[
          SizedBox(height: 8),
          Text(description),
        ],
      ],
    );
  }
}

// Screen 5: Members
class Screen5Members extends StatefulWidget {
  final DaoConfig daoConfig;
  final VoidCallback onBack;
  final VoidCallback onNext; // Changed from onFinish to onNext

  Screen5Members({
    required this.daoConfig,
    required this.onBack,
    required this.onNext, // Updated parameter
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
                amountController: TextEditingController(text: member.amount.toString()),
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
    setState(() {
      _totalTokens = total;
    });
  }

  void _saveAndNext() {
    widget.daoConfig.members = _memberEntries
        .map((entry) => Member(
              address: entry.addressController.text,
              amount: int.tryParse(entry.amountController.text) ?? 0,
            ))
        .toList();

    widget.onNext(); // Changed from widget.onFinish() to widget.onNext()
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
    return SingleChildScrollView( // Ensure content can scroll
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Members', style: Theme.of(context).textTheme.headline5),
            SizedBox(height: 26),
            Text('Total Tokens: $_totalTokens'),
            SizedBox(height: 75),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _memberEntries.length,
              itemBuilder: (context, index) {
                return MemberEntryWidget(
                  entry: _memberEntries[index],
                  onRemove: () => _removeMemberEntry(index),
                  onChanged: _calculateTotalTokens,
                );
              },
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: _addMemberEntry,
              child: Text('Add Member'),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: 700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: widget.onBack,
                    child: Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: _saveAndNext,
                    child: Text('Next'), // Changed label from 'Finish' to 'Next'
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

  MemberEntry({required this.addressController, required this.amountController});
}

class MemberEntryWidget extends StatelessWidget {
  final MemberEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  MemberEntryWidget({required this.entry, required this.onRemove, required this.onChanged});

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
                  decoration: InputDecoration(
                    labelText: 'Member Address',
                    counterText: '',
                  ),
                  onChanged: (value) => onChanged(),
                ),
              ),
              SizedBox(width: 16),
              // Amount
              Expanded(
                flex: 3,
                child: TextField(
                  controller: entry.amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount'),
                  onChanged: (value) => onChanged(),
                ),
              ),
              // Remove Button
              IconButton(
                icon: Icon(Icons.remove_circle),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
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
              Text('Review & Deploy', style: Theme.of(context).textTheme.headline5),
              SizedBox(height: 30),
              Text('DAO Type: ${daoConfig.daoType}'),
              SizedBox(height: 10),
              Text('DAO Name: ${daoConfig.daoName}'),
              SizedBox(height: 10),
              Text('DAO Description: ${daoConfig.daoDescription}'),
              SizedBox(height: 10),
              Text('Token Symbol: ${daoConfig.tokenSymbol}'),
              SizedBox(height: 10),
              Text('Number of Decimals: ${daoConfig.numberOfDecimals}'),
              SizedBox(height: 10),
              Text('Non-Transferrable: ${daoConfig.nonTransferrable ? 'Yes' : 'No'}'),
              SizedBox(height: 20),
              Text('Quorum Threshold: ${daoConfig.quorumThreshold}%'),
              SizedBox(height: 10),
              Text('Supermajority: ${daoConfig.supermajority}%'),
              SizedBox(height: 20),
              Text('Voting Duration: ${formatDuration(daoConfig.votingDuration)}'),
              SizedBox(height: 10),
              Text('Voting Delay: ${formatDuration(daoConfig.votingDelay)}'),
              SizedBox(height: 10),
              Text('Execution Availability: ${formatDuration(daoConfig.executionAvailability)}'),
              SizedBox(height: 20),
              Text('Members:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              DataTable(
                columns: [
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
              SizedBox(height: 30),
              SizedBox(
                width: 700,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: onBack,
                      child: Text('Back'),
                    ),
                    ElevatedButton(
                      onPressed: onFinish,
                      child: Text('Deploy'),
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
          SizedBox(height: 100, width: 100, child: CircularProgressIndicator()),
          SizedBox(height: 50),
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
          Text('Deployment Complete!', style: Theme.of(context).textTheme.headline5),
          SizedBox(height: 60),
          ElevatedButton(
            onPressed: onGoToDAO,
            child: Text('Go to DAO'),
          ),
        ],
      ),
    );
  }
}