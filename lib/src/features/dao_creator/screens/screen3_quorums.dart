// lib/src/features/dao_creator/screens/screen3_quorums.dart
import 'package:flutter/material.dart';
import 'package:werule/src/features/dao_creator/providers/dao_creator_provider.dart';
import 'package:werule/src/features/dao_creator/utils/creator_utils.dart';

class Screen3Quorums extends StatefulWidget {
  final DaoCreatorProvider provider;

  const Screen3Quorums({super.key, required this.provider});

  @override
  _Screen3QuorumsState createState() => _Screen3QuorumsState();
}

class _Screen3QuorumsState extends State<Screen3Quorums> {
  late double _quorumThreshold;
  late TextEditingController _thresholdController;

  @override
  void initState() {
    super.initState();
    _quorumThreshold = widget.provider.quorumThreshold.toDouble();
    _thresholdController =
        TextEditingController(text: widget.provider.proposalThreshold.toString());
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    widget.provider.updateQuorums(
      _quorumThreshold.toInt(),
      int.tryParse(_thresholdController.text) ?? 1,
    );
    widget.provider.nextStep();
  }

  String get _effectiveTokenSymbolForProposalThreshold {
    if (widget.provider.tokenDeploymentMechanism ==
        DaoTokenDeploymentMechanism.wrapExistingToken) {
      return widget.provider.wrappedTokenSymbol?.isNotEmpty == true
          ? widget.provider.wrappedTokenSymbol!
          : "WRAPPED";
    }
    return widget.provider.tokenSymbol?.isNotEmpty == true
        ? widget.provider.tokenSymbol!
        : "SYM";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 38.0, right: 38.0),
        // THE FIX: Wrapped the main column in a Center widget for consistent alignment.
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 78, 78, 78),
                        width: 0.4)),
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
                        color: const Color.fromARGB(255, 78, 78, 78),
                        width: 0.4)),
                padding: const EdgeInsets.all(35),
                child: SizedBox(
                  width: 500,
                  child: Column(
                    children: [
                      Text('Proposal Threshold',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _thresholdController,
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
                      onPressed: widget.provider.previousStep,
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
    );
  }
}
// lib/src/features/dao_creator/screens/screen3_quorums.dart