// lib/screens/creator.dart
import 'package:Homebase/main.dart'; // For orgs list
import 'package:Homebase/screens/creator/scereen5_members.dart';
import 'package:Homebase/screens/creator/scree1_dao_type.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../entities/contractFunctions.dart'; // Imports createDAO and createDAOwithWrappedToken
import '../../entities/org.dart';
// For Member
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