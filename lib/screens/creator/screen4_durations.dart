// lib/screens/creator/screen4_durations.dart
import 'package:flutter/material.dart';
import 'creator_widgets.dart'; // For DurationInput
import 'dao_config.dart';

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
