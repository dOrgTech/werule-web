// lib/src/features/dao_creator/screens/screen4_durations.dart
import 'package:flutter/material.dart';
import 'package:werule/src/features/dao_creator/providers/dao_creator_provider.dart';
import 'package:werule/src/features/dao_creator/widgets/creator_widgets.dart';

class Screen4Durations extends StatefulWidget {
  final DaoCreatorProvider provider;

  const Screen4Durations({super.key, required this.provider});

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
    final votingDuration = widget.provider.votingDuration;
    _votingDurationDaysController =
        TextEditingController(text: votingDuration.inDays.toString());
    _votingDurationHoursController =
        TextEditingController(text: (votingDuration.inHours % 24).toString());
    _votingDurationMinutesController =
        TextEditingController(text: (votingDuration.inMinutes % 60).toString());

    final votingDelay = widget.provider.votingDelay;
    _votingDelayDaysController =
        TextEditingController(text: votingDelay.inDays.toString());
    _votingDelayHoursController =
        TextEditingController(text: (votingDelay.inHours % 24).toString());
    _votingDelayMinutesController =
        TextEditingController(text: (votingDelay.inMinutes % 60).toString());

    final executionDelay = widget.provider.executionDelay;
    _executionDelayDaysController =
        TextEditingController(text: executionDelay.inDays.toString());
    _executionDelayHoursController =
        TextEditingController(text: (executionDelay.inHours % 24).toString());
    _executionDelayMinutesController =
        TextEditingController(text: (executionDelay.inMinutes % 60).toString());
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
    final votingDuration = Duration(
        days: votingDurationDays,
        hours: votingDurationHours,
        minutes: votingDurationMinutes);

    int votingDelayDays = int.tryParse(_votingDelayDaysController.text) ?? 0;
    int votingDelayHours = int.tryParse(_votingDelayHoursController.text) ?? 0;
    int votingDelayMinutes =
        int.tryParse(_votingDelayMinutesController.text) ?? 0;
    final votingDelay = Duration(
        days: votingDelayDays,
        hours: votingDelayHours,
        minutes: votingDelayMinutes);

    int executionDelayDays =
        int.tryParse(_executionDelayDaysController.text) ?? 0;
    int executionDelayHours =
        int.tryParse(_executionDelayHoursController.text) ?? 0;
    int executionDelayMinutes =
        int.tryParse(_executionDelayMinutesController.text) ?? 0;
    final executionDelay = Duration(
        days: executionDelayDays,
        hours: executionDelayHours,
        minutes: executionDelayMinutes);

    widget.provider.updateDurations(votingDelay, votingDuration, executionDelay);
    widget.provider.nextStep();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(38.0),
        // THE FIX: Wrapped the main column in a Center widget for consistent alignment.
        child: Center(
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
      ),
    );
  }
}
// lib/src/features/dao_creator/screens/screen4_durations.dart