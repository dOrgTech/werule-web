import 'dart:math';

import 'package:Homebase/entities/contractFunctions.dart';
import 'package:Homebase/screens/creator/creator_widgets.dart';
import 'package:Homebase/utils/functions.dart';
import 'package:Homebase/widgets/newProposal.dart';
import 'package:Homebase/widgets/registryPropo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../entities/definitions.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';
import '../screens/creator.dart';
import 'initiative.dart'; // Import for DurationInput widget

class DaoConfigurationWidget extends StatefulWidget {
  Proposal p;
  Org org;
  State proposalsState;
  InitiativeState initiativeState;
  bool isSetInfo = false;
  bool isWaiting = false;
  DaoConfigurationWidget(
      {super.key, required this.initiativeState,
      required this.p,
      required this.org,
      required this.proposalsState}) {
    // p.type = "quorum";
  }

  @override
  _DaoConfigurationWidgetState createState() => _DaoConfigurationWidgetState();
}

class _DaoConfigurationWidgetState extends State<DaoConfigurationWidget> {
  String? _selectedConfigType;
  bool _isFormValid = false;

  // Controllers for different configuration inputs
  final TextEditingController _proposalThresholdController =
      TextEditingController(text: "");
  final TextEditingController _votingDelayDaysController =
      TextEditingController(text: '0');
  final TextEditingController _votingDelayHoursController =
      TextEditingController(text: '0');
  final TextEditingController _votingDelayMinutesController =
      TextEditingController(text: '2');
  final TextEditingController _votingPeriodDaysController =
      TextEditingController(text: '0');
  final TextEditingController _votingPeriodHoursController =
      TextEditingController(text: '0');
  final TextEditingController _votingPeriodMinutesController =
      TextEditingController(text: '5');

  double? _quorumValue;
  Duration? votingDelay;
  Duration? votingPeriod;

  @override
  void initState() {
    _proposalThresholdController.text = widget.org.proposalThreshold.toString();

    super.initState();
    widget.p.values = ["0"];
    widget.initiativeState.widget.p.values = ["0"];
    widget.p.targets = [widget.org.address!];
    widget.initiativeState.widget.p.targets = [widget.org.address!];
    _quorumValue = widget.org.quorum.toDouble().round().toDouble();
    votingDelay = Duration(minutes: widget.org.votingDelay);
    votingPeriod = Duration(minutes: widget.org.votingDuration);
    _votingDelayDaysController.text = votingDelay!.inDays.toString();
    _votingDelayHoursController.text = votingDelay!.inHours.toString();
    _votingDelayMinutesController.text = votingDelay!.inMinutes.toString();
    _votingPeriodDaysController.text = votingPeriod!.inDays.toString();
    _votingPeriodHoursController.text = votingPeriod!.inHours.toString();
    _votingPeriodMinutesController.text = votingPeriod!.inMinutes.toString();
    _votingDelayDaysController.addListener(_validateForm);
    _votingDelayHoursController.addListener(_validateForm);
    _votingDelayMinutesController.addListener(_validateForm);
    _votingPeriodDaysController.addListener(_validateForm);
    _votingPeriodHoursController.addListener(_validateForm);
    _votingPeriodMinutesController.addListener(_validateForm);
    _proposalThresholdController.addListener(_validateForm);
  }

  void _selectConfigType(String configType) {
    setState(() {
      _selectedConfigType = configType;
      _isFormValid =
          configType == "Voting Delay" || configType == "Voting Period";
    });
  }

  void _validateForm() {
    bool isValid = false;
    if (_selectedConfigType == "Quorum") {
      isValid = _quorumValue != widget.org.quorum.toDouble();
    } else if (_selectedConfigType == "Voting Delay") {
      isValid = true; // Always enabled as requested
    } else if (_selectedConfigType == "Voting Period") {
      isValid = true; // Always enabled as requested
    } else if (_selectedConfigType == "Proposal Threshold") {
      isValid = _proposalThresholdController.text !=
          widget.org.proposalThreshold.toString();
    }
    setState(() {
      _isFormValid = isValid;
    });
    runLogic();
  }

  Widget _buildConfigSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildConfigOptionButton("Quorum", Icons.group),
        _buildConfigOptionButton("Voting Delay", Icons.hourglass_empty),
        _buildConfigOptionButton("Voting Period", Icons.timer),
        _buildConfigOptionButton(
            "Proposal Threshold", Icons.account_balance_wallet)
      ],
    );
  }

  Widget _buildConfigOptionButton(String title, IconData icon) {
    return SizedBox(
      width: 250,
      height: 130,
      child: ElevatedButton(
        onPressed: () => _selectConfigType(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 78, 78, 78),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuorumConfig() {
    widget.initiativeState.widget.p.type = "quorum";
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Text(
          "Quorum",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          width: 400,
          child: Text(
            textAlign: TextAlign.center,
            "Change the minimum required participation for a proposal to pass",
            style: TextStyle(fontSize: 16),
          ),
        ),
        Slider(
          value: _quorumValue!,
          min: 1,
          max: 100,
          divisions: 99,
          label: _quorumValue!.round().toString(),
          onChanged: (value) {
            setState(() {
              _quorumValue = value.round().toDouble();
            });
            _validateForm();
          },
        ),
      ],
    );
  }

  Widget _buildVotingDelayConfig() {
    widget.initiativeState.widget.p.type = "voting delay";
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Text(
          "Voting Delay",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          width: 400,
          child: Text(
            textAlign: TextAlign.center,
            "Change the wait time between posting a proposal and the start of voting",
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(
          width: 400,
          child: DurationInput(
            title: "Voting Delay Duration",
            description: "",
            daysController: _votingDelayDaysController,
            hoursController: _votingDelayHoursController,
            minutesController: _votingDelayMinutesController,
          ),
        ),
      ],
    );
  }

  runLogic() {
    widget.p.targets = [widget.org.address!];
    widget.initiativeState.widget.p.targets = [widget.org.address!];
    switch (_selectedConfigType) {
      case "Quorum":
        widget.p.type = "quorum";
        widget.initiativeState.widget.p.type = "quorum";
        BigInt newQuorum = BigInt.from(_quorumValue!.round());
        List params = [newQuorum];
        String callData0 = getCalldata(changeQuorumDef, params);
        widget.initiativeState.widget.p.callDatas = [callData0];
        break;
      case "Voting Delay":
        widget.p.type = "voting delay";
        widget.initiativeState.widget.p.type = "voting delay";
        Duration newDelay = Duration(
          days: int.parse(_votingDelayDaysController.text),
          hours: int.parse(_votingDelayHoursController.text),
          minutes: int.parse(_votingDelayMinutesController.text),
        );
        List params = [BigInt.parse(newDelay.inSeconds.toString())];
        String callData1 = getCalldata(changeVotingDelayDef, params);
        widget.initiativeState.widget.p.callDatas = [callData1];
        break;
      case "Voting Period":
        widget.p.type = "voting period";
        widget.initiativeState.widget.p.type = "voting period";
        Duration newPeriod = Duration(
          days: int.parse(_votingPeriodDaysController.text),
          hours: int.parse(_votingPeriodHoursController.text),
          minutes: int.parse(_votingPeriodMinutesController.text),
        );
        BigInt newPeriodBigInt = BigInt.from(newPeriod.inSeconds);
        print("the new voting period is $newPeriodBigInt");
        // Ensure it fits within uint32
        if (newPeriodBigInt > BigInt.from(0xFFFFFFFF)) {
          throw Exception("Value exceeds uint32 limit");
        }
        List params = [BigInt.parse(newPeriod.inSeconds.toString())];
        String callData2 = getCalldata(changeVotingPeriodDef, params);
        print("the call data is $callData2");
        widget.initiativeState.widget.p.callDatas = [callData2];
        break;
      case "Proposal Threshold":
        double newThreshold = double.parse(_proposalThresholdController.text);
        widget.initiativeState.widget.p.type = "proposal threshold";
        BigInt ramane =
            BigInt.from(newThreshold * pow(10, widget.org.decimals!));
        List params = [ramane];
        String callData2 = getCalldata(changeProposalThresholdDef, params);
        widget.initiativeState.widget.p.callDatas = [callData2];
        break;
    }
  }

  Widget _buildVotingPeriodConfig() {
    widget.initiativeState.widget.p.type = "voting period";
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Text(
          "Voting Period",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Change how long voting lasts",
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(
          width: 400,
          child: DurationInput(
            title: "Voting Period Duration",
            description: "",
            daysController: _votingPeriodDaysController,
            hoursController: _votingPeriodHoursController,
            minutesController: _votingPeriodMinutesController,
          ),
        ),
      ],
    );
  }

  Widget _buildProposalFeeConfig() {
    widget.initiativeState.widget.p.type = "proposal threshold";
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Proposal Threshold",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 400,
          child: Text(
            "Change the minimum amount of ${widget.org.symbol} ownership required to submit a proposal",
            style: const TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(
          width: 200,
          child: TextField(
            controller: _proposalThresholdController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: const InputDecoration(
              // labelText: 'Treasury Contract Address',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _validateForm(),
          ),
        ),
      ],
    );
  }

  Widget _buildConfigView() {
    switch (_selectedConfigType) {
      case "Quorum":
        return _buildQuorumConfig();
      case "Voting Delay":
        return _buildVotingDelayConfig();
      case "Voting Period":
        return _buildVotingPeriodConfig();
      case "Proposal Threshold":
        return _buildProposalFeeConfig();
      default:
        return _buildConfigSelection();
    }
  }

  void _resetToInitialView() {
    setState(() {
      _selectedConfigType = null;
      _isFormValid = false;
      _quorumValue = widget.org.quorum.toDouble();
      _votingDelayDaysController.text = '0';
      _votingDelayHoursController.text = '0';
      _votingDelayMinutesController.text = '2';
      _votingPeriodDaysController.text = '0';
      _votingPeriodHoursController.text = '0';
      _votingPeriodMinutesController.text = '5';
      _proposalThresholdController.text =
          widget.org.proposalThreshold.toString();
    });
  }

  finishSettingInfo() {
    setState(() {
      widget.isSetInfo = false;
      widget.p.type = "quorum";
      widget.initiativeState.widget.p.type = "quorum";
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isSetInfo
        ? NewProposal(p: widget.p, next: finishSettingInfo)
        : widget.isWaiting
            ? const AwaitingConfirmation()
            : Container(
                // decoration: BoxDecoration(
                //     border: Border.all(color: Colors.grey, width: 0.3)),
                width: 600,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildConfigView(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
  }

  submit() async {
    switch (_selectedConfigType) {
      case "Quorum":
        widget.p.type = "quorum";
        BigInt newQuorum = BigInt.from(_quorumValue!.round());
        List params = [newQuorum];
        String callData0 = getCalldata(changeQuorumDef, params);
        widget.p.callDatas = [callData0];
        break;
      case "Voting Delay":
        widget.p.type = "voting delay";
        Duration newDelay = Duration(
          days: int.parse(_votingDelayDaysController.text),
          hours: int.parse(_votingDelayHoursController.text),
          minutes: int.parse(_votingDelayMinutesController.text),
        );
        List params = [BigInt.parse(newDelay.inSeconds.toString())];
        String callData1 = getCalldata(changeVotingDelayDef, params);
        widget.p.callDatas = [callData1];
        break;
      case "Voting Period":
        widget.p.type = "voting period";
        Duration newPeriod = Duration(
          days: int.parse(_votingPeriodDaysController.text),
          hours: int.parse(_votingPeriodHoursController.text),
          minutes: int.parse(_votingPeriodMinutesController.text),
        );
        List params = [BigInt.parse(newPeriod.inSeconds.toString())];
        String callData2 = getCalldata(changeVotingPeriodDef, params);
        widget.p.callDatas = [callData2];
        break;
      case "Proposal Threshold":
        widget.p.type = "proposal threshold";
        double newThreshold = double.parse(_proposalThresholdController.text);
        BigInt ramane =
            BigInt.from(newThreshold * pow(10, widget.org.decimals!));
        List params = [ramane];
        String callData2 = getCalldata(changeProposalThresholdDef, params);
        widget.p.callDatas = [callData2];
        break;
    }
    // setState(() {
    //   widget.isWaiting = true;
    // });
    try {
      String cevine = await propose(widget.p);
      if (cevine.contains("not ok")) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            duration: Duration(seconds: 1),
            content: Center(
                child: SizedBox(
                    height: 70,
                    child: Center(
                      child: Text(
                        "Error submitting proposal",
                        style: TextStyle(fontSize: 24, color: Colors.red),
                      ),
                    )))));
        Navigator.of(context).pop();
        return;
      }
      widget.p.status = "pending";
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 1),
          content: Center(
              child: SizedBox(
                  height: 70,
                  child: Center(
                    child: Text(
                      "Proposal submitted",
                      style: TextStyle(fontSize: 24),
                    ),
                  )))));
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 1),
          content: Center(
              child: SizedBox(
                  height: 70,
                  child: Center(
                    child: Text(
                      "Error submitting proposal",
                      style: TextStyle(fontSize: 24, color: Colors.red),
                    ),
                  )))));
    }
  }
}
