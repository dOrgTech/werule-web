import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../entities/org.dart';
import '../entities/proposal.dart';

/// CollapsibleRewardsDashboard is a widget that can be collapsed into a 60px header
/// showing a summary or expanded to show full details (Basics and Proposals).
/// Expanding/collapsing is animated over 700ms. The whole widget has a green outline.
class CollapsibleRewardsDashboard extends StatefulWidget {
  CollapsibleRewardsDashboard({Key? key, required this.org}) : super(key: key);
  Org org;
  List<AppleProposal> props = [];
  @override
  _CollapsibleRewardsDashboardState createState() =>
      _CollapsibleRewardsDashboardState();
}

class _CollapsibleRewardsDashboardState
    extends State<CollapsibleRewardsDashboard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  // Basics steps with mutable completion state.
  final List<_FunnelStep> _basicsSteps = [
    _FunnelStep(title: "Watch opening statement", isCompleted: false),
    _FunnelStep(title: "Join Discord server", isCompleted: false),
    _FunnelStep(title: "Take Quiz", isCompleted: false),
  ];

  // Proposals data (static for now)
  final List<AppleProposal> _proposals = [
    AppleProposal(
      title: "Should we switch on-chain countries?",
      voted: true,
      predictedCorrectly: true,
    ),
    AppleProposal(
      title: "Adopt quadratic voting for proposals",
      voted: true,
      predictedCorrectly: null,
    ),
  ];

  int get _basicsCompleted =>
      _basicsSteps.where((step) => step.isCompleted).length;

  int get _proposalsCompleted => _proposals
      .where(
          (proposal) => proposal.voted && (proposal.predictedCorrectly == true))
      .length;

  Future<void> _handleBasicsStepTap(int index) async {
    // Only allow tap if this is the first uncompleted step.
    int clickableIndex =
        _basicsSteps.indexWhere((step) => step.isCompleted == false);
    if (index != clickableIndex) return;

    if (index == 0) {
      // Step 1: Show AlertDialog with embedded YouTube video.
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            contentPadding: const EdgeInsets.all(8),
            content: AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayerIFrame(
                controller: YoutubePlayerController(
                  initialVideoId: 'Gqw0Q4j--FI',
                  params: const YoutubePlayerParams(
                    autoPlay: true,
                    showControls: true,
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else if (index == 1) {
      // Step 2: Launch Discord URL.
      final url = Uri.parse("https://discord.gg/2B3NAGUf");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } else if (index == 2) {
      // Step 3: Show AlertDialog with instructions (Lorem Ipsum placeholder).
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              "Take Quiz",
              style: TextStyle(color: Theme.of(context).indicatorColor),
            ),
            content: Padding(
              padding: const EdgeInsets.all(38.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Type *quiz start in the #apple-farm channel,\n"
                    "When prompted by the #K3v|n bot, provide this token:",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("X9H3DDF3P",
                          style: TextStyle(
                              backgroundColor: Colors.black,
                              fontSize: 32,
                              color: Colors.greenAccent)),
                      SizedBox(width: 10),
                      Icon(
                        Icons.copy,
                        color: Colors.greenAccent,
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      );
    }

    // Mark the tapped step as completed.
    setState(() {
      _basicsSteps[index].isCompleted = true;
    });
  }

  @override
  void initState() {
    print("INIT STATE IS RUNNING");
    for (Proposal p in widget.org.proposals) {
      print("loading a proposal ${p.name}");
      widget.props.add(AppleProposal(
        title: p.name!,
        voted: false,
        predictedCorrectly: null,
      ));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final indicatorColor = Theme.of(context).indicatorColor;
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).indicatorColor),
      ),
      child: Column(
        children: [
          // Header Bar: shows summary when collapsed and title when expanded.
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              height: 60,
              color: Colors.grey[850],
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _isExpanded
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Image.network(
                              "https://i.ibb.co/gLnhMw2b/aflogo.png",
                              height: 40,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.network(
                                "https://i.ibb.co/gLnhMw2b/aflogo.png",
                                height: 40,
                              ),
                              Spacer(),
                              Text(
                                "Basics (${_basicsCompleted}/${_basicsSteps.length})",
                                style: TextStyle(
                                    color: indicatorColor, fontSize: 16),
                              ),
                              SizedBox(width: 40),
                              Text(
                                "Proposals & Voting (${_proposalsCompleted}/${_proposals.length})",
                                style: TextStyle(
                                    color: indicatorColor, fontSize: 16),
                              ),
                              SizedBox(
                                width: 28,
                              )
                            ],
                          ),
                  ),
                  Tooltip(
                    message: "Tap to ${_isExpanded ? "collapse" : "expand"}",
                    child: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: indicatorColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Animated Expanded/Collapsed Content.
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basics Section.
                  Expanded(
                    child: _BasicsSection(
                      steps: _basicsSteps,
                      indicatorColor: indicatorColor,
                      onStepTap: _handleBasicsStepTap,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Proposals Section.
                  Expanded(
                    child: _ProposalsSection(
                      proposals: _proposals,
                      indicatorColor: indicatorColor,
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}

/// Data class for a Basics funnel step.
class _FunnelStep {
  final String title;
  bool isCompleted;
  _FunnelStep({required this.title, required this.isCompleted});
}

/// Basics section displays a list of steps. If all are completed, show a big Icons.apple.
class _BasicsSection extends StatelessWidget {
  final List<_FunnelStep> steps;
  final Color indicatorColor;
  final void Function(int index) onStepTap;
  const _BasicsSection({
    Key? key,
    required this.steps,
    required this.indicatorColor,
    required this.onStepTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int clickableIndex = steps.indexWhere((step) => step.isCompleted == false);
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shadowColor: indicatorColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Basics",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(color: indicatorColor)),
                  const SizedBox(height: 10),
                  ...steps.asMap().entries.map((entry) {
                    int index = entry.key;
                    _FunnelStep step = entry.value;
                    Widget tile = ListTile(
                      leading: Icon(
                        step.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: indicatorColor,
                      ),
                      title: Text(step.title,
                          style: const TextStyle(color: Colors.white)),
                    );
                    // Only wrap the next uncompleted step with a tap handler.
                    if (index == clickableIndex) {
                      return InkWell(
                        onTap: () => onStepTap(index),
                        child: tile,
                      );
                    } else {
                      return tile;
                    }
                  }).toList(),
                ],
              ),
            ),
            // If all steps are completed, show a big Icons.apple.
            if (steps.every((step) => step.isCompleted))
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 22),
                child:
                    Image.network("https://i.ibb.co/M5SpV9XR/lowresapple.png"),
              ),
          ],
        ),
      ),
    );
  }
}

/// Data class for proposals. Using the name AppleProposal to avoid conflicts.
class AppleProposal {
  final String title;
  final bool voted;
  // predictedCorrectly:
  //   true => predicted correctly (checkmark)
  //   false => predicted incorrectly (X)
  //   null => debate still ongoing (hourglass)
  final bool? predictedCorrectly;
  AppleProposal({
    required this.title,
    required this.voted,
    required this.predictedCorrectly,
  });
}

/// Proposals section displays a list of proposals, each with two checkpoints:
/// - Voted
/// - Predicted Correctly (icon reflects status)
/// If both are met, a big Icons.apple is shown on the right.
class _ProposalsSection extends StatelessWidget {
  final List<AppleProposal> proposals;
  final Color indicatorColor;
  const _ProposalsSection({
    Key? key,
    required this.proposals,
    required this.indicatorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shadowColor: indicatorColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Proposals & Voting",
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(color: indicatorColor)),
            const SizedBox(height: 10),
            ...proposals.map((proposal) => _AppleProposalWidget(
                  proposal: proposal,
                  indicatorColor: indicatorColor,
                )),
          ],
        ),
      ),
    );
  }
}

class _AppleProposalWidget extends StatelessWidget {
  final AppleProposal proposal;
  final Color indicatorColor;
  const _AppleProposalWidget({
    Key? key,
    required this.proposal,
    required this.indicatorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Icon for the "Voted" checkpoint.
    final votedIcon = proposal.voted
        ? Icon(Icons.check, color: indicatorColor)
        : Icon(Icons.radio_button_unchecked, color: indicatorColor);

    // Icon for the "Predicted Correctly" checkpoint.
    Widget predictedIcon;
    if (proposal.predictedCorrectly == null) {
      predictedIcon = Icon(Icons.hourglass_empty, color: indicatorColor);
    } else if (proposal.predictedCorrectly == true) {
      predictedIcon = Icon(Icons.check, color: indicatorColor);
    } else {
      predictedIcon = Icon(Icons.close, color: Colors.redAccent);
    }

    // Check if both checkpoints are achieved.
    final bool unlocked =
        proposal.voted && (proposal.predictedCorrectly == true);

    return Card(
      color: Colors.grey[850],
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Left: Proposal details with checkpoints.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(proposal.title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      votedIcon,
                      const SizedBox(width: 8),
                      const Text("Voted",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      predictedIcon,
                      const SizedBox(width: 8),
                      const Text("Predicted debate result",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            // Right: Big Icons.apple if unlocked.
            if (unlocked)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 22),
                child: Image.network(
                  "https://i.ibb.co/M5SpV9XR/lowresapple.png",
                  height: 38,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
