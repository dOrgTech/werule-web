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
