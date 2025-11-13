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
import 'package:werule/src/features/dao_creator/screens/screen_economy_fees.dart';
import 'package:werule/src/features/dao_creator/screens/screen_project_durations.dart';
import 'package:werule/src/features/dao_creator/screens/screen_project_thresholds.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/features/dao_creator/utils/debug_deployment.dart';

class DaoCreatorScreen extends StatefulWidget {
  final String networkName;
  const DaoCreatorScreen({super.key, required this.networkName});

  @override
  State<DaoCreatorScreen> createState() => _DaoCreatorScreenState();
}

class _DaoCreatorScreenState extends State<DaoCreatorScreen> {
  late final DaoCreatorProvider _daoCreatorProvider;

  @override
  void initState() {
    super.initState();
    _daoCreatorProvider = DaoCreatorProvider(
      blockchainService: context.read<BlockchainService>(),
      authProvider: context.read<AuthProvider>(),
      networkProvider: context.read<NetworkProvider>(),
      firestoreService: context.read<FirestoreService>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _daoCreatorProvider,
      child: Scaffold(
        body: Stack(
          children: [
            Consumer<DaoCreatorProvider>(
              builder: (context, provider, child) {
                final List<Widget> screens = _getScreensForDaoType(provider);

                final currentScreen = AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: screens[provider.currentStep],
                );

                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 950) {
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
                      return Center(child: currentScreen);
                    }
                  },
                );
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go('/${widget.networkName}'),
                tooltip: 'Exit Creator',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getScreensForDaoType(DaoCreatorProvider provider) {
    List<Widget> screens = [
      Screen1DaoType(provider: provider),
      Screen2BasicSetup(provider: provider),
      Screen3Quorums(provider: provider),
      Screen4Durations(provider: provider),
    ];

    // Only include Members screen if not using wrapped token
    if (provider.shouldShowMembers) {
      screens.add(Screen5Members(provider: provider));
    }

    screens.add(Screen6Registry(provider: provider));

    if (provider.daoType == 'Economy DAO') {
      screens.addAll([
        ScreenEconomyFees(provider: provider),
        ScreenProjectThresholds(provider: provider),
        ScreenProjectDurations(provider: provider),
      ]);
    }

    screens.addAll([
      Screen7Review(provider: provider),
      Screen8Deploying(provider: provider),
      Screen9DeploymentComplete(
        provider: provider,
        onGoToDAO: () {
          if (provider.newDaoAddress != null) {
            context.go('/${widget.networkName}/${provider.newDaoAddress}');
          }
        },
      ),
    ]);

    return screens;
  }
}

class _CreatorStepper extends StatelessWidget {
  final DaoCreatorProvider provider;
  const _CreatorStepper({required this.provider});

  List<String> _getStepTitles(DaoCreatorProvider provider) {
    List<String> titles = [
      'DAO Type',
      'Basic Setup',
      'Quorums',
      'Durations',
    ];

    // Only include Members step if not using wrapped token
    if (provider.shouldShowMembers) {
      titles.add('Members');
    }

    titles.add('Registry');

    if (provider.daoType == 'Economy DAO') {
      titles.addAll([
        'Economy Fees',
        'Project Thresholds',
        'Project Durations',
      ]);
    }

    titles.addAll([
      'Review & Deploy',
      'Deploying',
      'Complete'
    ]);

    return titles;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> stepTitles = _getStepTitles(provider);
    final reviewStepIndex = provider.reviewStepIndex;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(stepTitles.length, (index) {
          final isCurrent = index == provider.currentStep;
          final isCompleted = index < provider.currentStep;
          final isEnabled = index <= provider.maxStepReached;

          // Hide deploying & complete steps from the stepper UI
          if (index > reviewStepIndex) return const SizedBox.shrink();

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