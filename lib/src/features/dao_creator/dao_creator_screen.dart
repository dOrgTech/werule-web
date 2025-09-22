// lib/src/features/dao_creator/dao_creator_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/dao_creator/providers/dao_creator_provider.dart';
import 'package:werule/src/features/dao_creator/screens/screen1_dao_type.dart';
import 'package:werule/src/features/dao_creator/screens/screen2_basic_setup.dart';
import 'package:werule/src/features/dao_creator/screens/screen3_quorums.dart';
import 'package:werule/src/features/dao_creator/screens/screen4_durations.dart';
import 'package:werule/src/features/dao_creator/screens/screen5_members.dart';
import 'package:werule/src/features/dao_creator/screens/screen6_registry.dart';
import 'package:werule/src/features/dao_creator/screens/screen7_review.dart';
import 'package:werule/src/features/dao_creator/screens/screen8_deploying.dart';
import 'package:werule/src/features/dao_creator/screens/screen9_deployment_complete.dart';

class DaoCreatorScreen extends StatelessWidget {
  final String networkName;
  const DaoCreatorScreen({super.key, required this.networkName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DaoCreatorProvider(),
      child: Scaffold(
        // THE FIX: Removed the AppBar for a cleaner, modal-like feel.
        body: Stack(
          children: [
            Consumer<DaoCreatorProvider>(
              builder: (context, provider, child) {
                final List<Widget> screens = [
                  Screen1DaoType(provider: provider),
                  Screen2BasicSetup(provider: provider),
                  Screen3Quorums(provider: provider),
                  Screen4Durations(provider: provider),
                  Screen5Members(provider: provider),
                  Screen6Registry(provider: provider),
                  Screen7Review(provider: provider),
                  Screen8Deploying(provider: provider),
                  Screen9DeploymentComplete(
                    provider: provider,
                    onGoToDAO: () {
                      context.go('/$networkName');
                    },
                  ),
                ];

                final currentScreen = AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: screens[provider.currentStep],
                );

                // THE FIX: Use LayoutBuilder for a responsive UI with a stepper.
                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 950) {
                      // Wide screen: Show stepper on the left
                      return Row(
                        children: [
                          SizedBox(
                            width: 250,
                            child: _CreatorStepper(provider: provider),
                          ),
                          const VerticalDivider(width: 1),
                          Expanded(
                            child: Center(child: currentScreen),
                          ),
                        ],
                      );
                    } else {
                      // Narrow screen: Hide stepper
                      return Center(child: currentScreen);
                    }
                  },
                );
              },
            ),
            // THE FIX: Added a standalone close button.
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go('/$networkName'),
                tooltip: 'Exit Creator',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// THE FIX: A new widget for the stepper/overview panel.
class _CreatorStepper extends StatelessWidget {
  final DaoCreatorProvider provider;
  const _CreatorStepper({required this.provider});

  @override
  Widget build(BuildContext context) {
    const List<String> stepTitles = [
      'DAO Type',
      'Basic Setup',
      'Quorums',
      'Durations',
      'Members',
      'Registry',
      'Review & Deploy',
      'Deploying',
      'Complete'
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(stepTitles.length, (index) {
          final isCurrent = index == provider.currentStep;
          final isCompleted = index < provider.currentStep;
          final isEnabled = index <= provider.maxStepReached;

          // Don't show the deploying/complete steps in the main list
          if (index > 6) return const SizedBox.shrink();

          Color color;
          if (isCurrent) {
            color = Theme.of(context).indicatorColor;
          } else if (isCompleted || isEnabled) {
            color = Colors.white;
          } else {
            color = Colors.grey.shade600;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: InkWell(
              onTap: isEnabled ? () => provider.goToStep(index) : null,
              child: Text(
                '${index + 1}. ${stepTitles[index]}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: color,
                  decoration:
                      !isEnabled ? TextDecoration.none : TextDecoration.none,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
// lib/src/features/dao_creator/dao_creator_screen.dart