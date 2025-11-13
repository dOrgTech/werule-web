// lib/src/features/dao_creator/screens/screen_project_durations.dart
import 'package:flutter/material.dart';
import 'package:werule/src/features/dao_creator/providers/dao_creator_provider.dart';
import 'package:werule/src/features/dao_creator/widgets/creator_widgets.dart';

class ScreenProjectDurations extends StatefulWidget {
  final DaoCreatorProvider provider;
  const ScreenProjectDurations({super.key, required this.provider});

  @override
  State<ScreenProjectDurations> createState() => _ScreenProjectDurationsState();
}

class _ScreenProjectDurationsState extends State<ScreenProjectDurations> {
  late TextEditingController _coolingOffDaysController;
  late TextEditingController _coolingOffHoursController;
  late TextEditingController _coolingOffMinutesController;
  late TextEditingController _disputeDaysController;
  late TextEditingController _disputeHoursController;
  late TextEditingController _disputeMinutesController;

  @override
  void initState() {
    super.initState();
    final coolingOff = widget.provider.coolingOffPeriod;
    _coolingOffDaysController =
        TextEditingController(text: coolingOff.inDays.toString());
    _coolingOffHoursController =
        TextEditingController(text: (coolingOff.inHours % 24).toString());
    _coolingOffMinutesController =
        TextEditingController(text: (coolingOff.inMinutes % 60).toString());

    final disputePeriod = widget.provider.disputeAndAppealPeriod;
    _disputeDaysController =
        TextEditingController(text: disputePeriod.inDays.toString());
    _disputeHoursController =
        TextEditingController(text: (disputePeriod.inHours % 24).toString());
    _disputeMinutesController =
        TextEditingController(text: (disputePeriod.inMinutes % 60).toString());
  }

  @override
  void dispose() {
    _coolingOffDaysController.dispose();
    _coolingOffHoursController.dispose();
    _coolingOffMinutesController.dispose();
    _disputeDaysController.dispose();
    _disputeHoursController.dispose();
    _disputeMinutesController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    final coolingOff = Duration(
      days: int.tryParse(_coolingOffDaysController.text) ?? 0,
      hours: int.tryParse(_coolingOffHoursController.text) ?? 0,
      minutes: int.tryParse(_coolingOffMinutesController.text) ?? 0,
    );

    final disputePeriod = Duration(
      days: int.tryParse(_disputeDaysController.text) ?? 0,
      hours: int.tryParse(_disputeHoursController.text) ?? 0,
      minutes: int.tryParse(_disputeMinutesController.text) ?? 0,
    );

    widget.provider.updateProjectDurations(
      coolingOff: coolingOff,
      disputePeriod: disputePeriod,
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
            Text('Project Durations',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 86),
            SizedBox(
              width: 500,
              child: DurationInput(
                title: 'Cooling-Off Period',
                description:
                    'The mandatory wait time after a contractor is chosen before work can begin.',
                daysController: _coolingOffDaysController,
                hoursController: _coolingOffHoursController,
                minutesController: _coolingOffMinutesController,
              ),
            ),
            const SizedBox(height: 76),
            SizedBox(
              width: 500,
              child: DurationInput(
                title: 'Dispute & Appeal Period',
                description:
                    'The time window for an arbiter to rule on a dispute and for the DAO to appeal that ruling.',
                daysController: _disputeDaysController,
                hoursController: _disputeHoursController,
                minutesController: _disputeMinutesController,
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
    );
  }
}
// lib/src/features/dao_creator/screens/screen_project_durations.dart