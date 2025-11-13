// lib/src/features/dao_creator/screens/screen_project_thresholds.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:werule/src/features/dao_creator/providers/dao_creator_provider.dart';

class ScreenProjectThresholds extends StatefulWidget {
  final DaoCreatorProvider provider;
  const ScreenProjectThresholds({super.key, required this.provider});

  @override
  State<ScreenProjectThresholds> createState() =>
      _ScreenProjectThresholdsState();
}

class _ScreenProjectThresholdsState extends State<ScreenProjectThresholds> {
  late double _backerQuorum;
  late TextEditingController _creationThresholdController;

  @override
  void initState() {
    super.initState();
    _backerQuorum = widget.provider.backerVotingQuorum.toDouble();
    _creationThresholdController = TextEditingController(
        text: widget.provider.projectCreationThreshold.toString());
  }

  @override
  void dispose() {
    _creationThresholdController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    widget.provider.updateProjectThresholds(
      backerQuorum: _backerQuorum.toInt(),
      creationThreshold: int.tryParse(_creationThresholdController.text) ?? 0,
    );
    widget.provider.nextStep();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(38.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Project Thresholds',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 50),
            _buildQuorumSlider(),
            const SizedBox(height: 60),
            _buildCreationThresholdInput(),
            const SizedBox(height: 86),
            SizedBox(
              width: 700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: widget.provider.previousStep,
                      child: const Text('< Back')),
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

  Widget _buildQuorumSlider() {
    return Container(
      decoration: BoxDecoration(
          border:
              Border.all(color: const Color.fromARGB(255, 78, 78, 78), width: 0.4)),
      padding: const EdgeInsets.all(35),
      child: SizedBox(
        width: 500,
        child: Column(
          children: [
            const Text('Backer Voting Quorum', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text(
              'The percentage of project funds that must vote to approve a payment or start a dispute.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            const SizedBox(height: 26),
            Text('${_backerQuorum.toStringAsFixed(0)} %',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 27,
                    color: Theme.of(context).indicatorColor)),
            const SizedBox(height: 20),
            Slider(
              min: 0,
              max: 100,
              divisions: 100,
              value: _backerQuorum,
              label: '${_backerQuorum.round()}%',
              onChanged: (value) {
                setState(() {
                  _backerQuorum = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreationThresholdInput() {
    return Container(
      decoration: BoxDecoration(
          border:
              Border.all(color: const Color.fromARGB(255, 78, 78, 78), width: 0.4)),
      padding: const EdgeInsets.all(35),
      child: SizedBox(
        width: 500,
        child: Column(
          children: [
            const Text('Project Creation Threshold',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text(
              'The minimum reputation tokens a user must hold to create a new project. Set to 0 to allow anyone.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: 250,
              child: TextFormField(
                controller: _creationThresholdController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Token Amount (${widget.provider.tokenSymbol})',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/src/features/dao_creator/screens/screen_project_thresholds.dart