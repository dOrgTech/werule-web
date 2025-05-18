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
          widget.org.totalSupply = daoConfig.totalSupply ?? "0"; // From Screen5Members
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

          // For the org.govToken Dart object representing the wrapped token:
          // The actual on-chain wrapped token inherits decimals from its underlying token.
          // Your Token class constructor requires 'decimals'. We'll use a common default (e.g., 18)
          // or what might have been in daoConfig.numberOfDecimals (though it's usually nulled for wrapped path).
          // This is for the Dart object only; the contract handles actual decimals.
          widget.org.decimals = daoConfig.numberOfDecimals ?? 18; // Default for Dart Token obj

          widget.org.nonTransferrable = false; // Wrapped tokens are generally transferable
          widget.org.totalSupply = "0"; // Wrapped tokens start with 0 supply
          widget.org.holders = 0; // No initial holders via this deployment method
          widget.org.memberAddresses = {}; // No members distributed at deployment for wrapped tokens

          widget.org.govToken = Token(
            type: "wrappedErc20", // A type to distinguish it
            name: daoConfig.wrappedTokenName ?? "Wrapped ${daoConfig.wrappedTokenSymbol ?? "Token"}", // From Screen2
            symbol: widget.org.symbol!,
            decimals: widget.org.decimals!, // For the Dart object
            // address will be set from results
          );
          
          // Call the function to deploy DAO with a wrapped token
          results = await createDAOwithWrappedToken(widget.org, daoConfig);
        }

        // Process results
        if (results.isNotEmpty && !results[0].startsWith("ERROR")) {
          widget.org.address = results[0];
          widget.org.govTokenAddress = results[1]; 
          widget.org.treasuryAddress = results[2];
          widget.org.registryAddress = results[3];

          // Update the govToken in widget.org with the deployed address
          // and other details if they were placeholders
          widget.org.govToken = Token(
              type: widget.org.govToken!.type, // Retain type
              name: widget.org.govToken!.name, // Retain name
              symbol: widget.org.symbol!, // Use symbol from Org as it's definitive
              decimals: widget.org.decimals!, // Use decimals from Org
              address: results[1] // Set deployed address
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
        if (errorString.length > 150) errorString = errorString.substring(0,150) + "...";
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('DAO Deployment Exception: $errorString'), backgroundColor: Colors.red, duration: Duration(seconds: 5)),
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
                                enabled: true, // Always enabled
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile(
                                title: const Text('2. Identity'),
                                onTap: maxStepReached >= 1 ? () => goToStep(1) : null,
                                selected: currentStep == 1,
                                enabled: maxStepReached >= 0, // Step 1 should always be accessible from step 0
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile(
                                title: const Text('3. Thresholds'),
                                onTap: maxStepReached >= 2 ? () => goToStep(2) : null,
                                selected: currentStep == 2,
                                enabled: maxStepReached >= 1, // Enable if prev step (Identity) is reached/done
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile(
                                title: const Text('4. Durations'),
                                onTap: maxStepReached >= 3 ? () => goToStep(3) : null,
                                selected: currentStep == 3,
                                enabled: maxStepReached >= 2,
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile(
                                title: const Text('5. Members'),
                                onTap: maxStepReached >= 4 ? () => goToStep(4) : null,
                                selected: currentStep == 4,
                                // Members screen might be disabled for wrapped tokens if not applicable.
                                // This depends on UI flow decisions. For now, enabled by maxStepReached.
                                enabled: maxStepReached >= 3 && 
                                         (daoConfig.tokenDeploymentMechanism == DaoTokenDeploymentMechanism.deployNewStandardToken ||
                                          /* allow access for wrapped if UI shows it, even if non-functional */ true), 
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile(
                                title: const Text('6. Registry'),
                                onTap: maxStepReached >= 5 ? () => goToStep(5) : null,
                                selected: currentStep == 5,
                                enabled: maxStepReached >= 4,
                                selectedColor: Colors.black,
                                selectedTileColor:
                                    const Color.fromARGB(255, 121, 133, 128)),
                            ListTile(
                                title: const Text('7. Review & Deploy'),
                                onTap: maxStepReached >= 6 ? () => goToStep(6) : null,
                                selected: currentStep == 6,
                                enabled: maxStepReached >= 5,
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