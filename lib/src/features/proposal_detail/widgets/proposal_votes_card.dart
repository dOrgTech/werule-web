// lib/src/features/proposal_detail/widgets/proposal_votes_card.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/proposal_detail/widgets/votes_modal.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/proposal_detail_provider.dart';
import 'package:werule/src/utils/reusable.dart';

class ProposalVotesCard extends StatelessWidget {
  final Org org;
  const ProposalVotesCard({super.key, required this.org});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProposalDetailProvider>();
    final proposal = provider.proposal;

    final forVotes = proposal.inFavor;
    final againstVotes = proposal.against;
    final totalVotes = forVotes + againstVotes;
    final totalVoters = proposal.votesFor + proposal.votesAgainst;
    
    final double forPercentDouble = totalVotes > BigInt.zero ? (forVotes.toDouble() / totalVotes.toDouble()) * 100 : 0.0;
    final double againstPercentDouble = totalVotes > BigInt.zero ? (againstVotes.toDouble() / totalVotes.toDouble()) * 100 : 0.0;
    
    final totalSupply = BigInt.tryParse(proposal.totalSupply) ?? BigInt.zero;
    final double turnoutPercentDouble;
    if (totalSupply > BigInt.zero) {
      final turnoutBigInt = (totalVotes * BigInt.from(10000)) ~/ totalSupply;
      turnoutPercentDouble = turnoutBigInt.toInt() / 100.0;
    } else {
      turnoutPercentDouble = 0.0;
    }
    final bool quorumMet = turnoutPercentDouble >= org.quorum;

    String formatVotes(BigInt amount) {
      return formatTotalSupply(amount.toString(), org.decimals);
    }

    const animationDuration = Duration(milliseconds: 650);
    const turnoutAnimationDelay = Duration(milliseconds: 110);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff2c2c2c),
      ),
      height: 250,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical:14.0, horizontal: 34),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 450;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text("$totalVoters Voters", style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  SizedBox(
                    height: 27,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800),
                      onPressed: () {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final isDialogMobile = screenWidth < 700;
                        final dialogWidth = isDialogMobile ? screenWidth * 0.9 : 800.0;
                    
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xff222222),
                            // THE FIX: Title is now a Row with a close button, and the 'actions' property is removed.
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Votes:"),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                            content: SizedBox(
                              width: dialogWidth,
                              child: VotesModal(
                                proposalId: proposal.id,
                                org: provider.org,
                                network: provider.network,
                              ),
                            ),
                          ),
                        );
                      },
                      child:  Text("View votes", style: TextStyle(fontSize: 13, color: Theme.of(context).indicatorColor))),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _VoteStat(
                    isMobile: isMobile, 
                    isSupport: true, 
                    votes: formatVotes(forVotes), 
                    percentage: forPercentDouble,
                    animationDuration: animationDuration,
                  ),
                  _VoteStat(
                    isMobile: isMobile, 
                    isSupport: false, 
                    votes: formatVotes(againstVotes), 
                    percentage: againstPercentDouble,
                    animationDuration: animationDuration,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _ProgressBar(
                forPercent: forPercentDouble,
                againstPercent: againstPercentDouble,
                height: 10,
                animationDuration: animationDuration,
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  const Text("Turnout: ", style: TextStyle(fontSize: 15)),
                  Text("${formatVotes(totalVotes)} (", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  _AnimatedPercentage(
                    value: turnoutPercentDouble,
                    duration: animationDuration,
                    delay: turnoutAnimationDelay,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const Text(")", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const Spacer(),
                  Text(quorumMet ? "Quorum Met" : "Quorum Not Met", style: TextStyle(fontWeight: FontWeight.bold, color: quorumMet ? Colors.green : Colors.grey, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 10),
              _ProgressBar(
                forPercent: turnoutPercentDouble,
                againstPercent: 0,
                height: 10,
                quorumPercent: org.quorum.toDouble(),
                fillColor: Colors.grey.shade400,
                animationDuration: animationDuration,
                animationDelay: turnoutAnimationDelay,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VoteStat extends StatelessWidget {
  final bool isMobile;
  final bool isSupport;
  final String votes;
  final double percentage;
  final Duration animationDuration;

  const _VoteStat({
    required this.isMobile, 
    required this.isSupport, 
    required this.votes, 
    required this.percentage,
    required this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    const supportColor = Color(0xff00c489);
    const opposeColor = Color(0xff86251e);
    final color = isSupport ? supportColor : opposeColor;
    
    const double statFontSize = 14;

    if (isMobile) {
      return Row(
        children: [
          Icon(isSupport ? Icons.thumb_up : Icons.thumb_down, color: color, size: 18),
          const SizedBox(width: 8),
          Text(votes, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: statFontSize)),
          const SizedBox(width: 8),
          _AnimatedPercentage(value: percentage, duration: animationDuration, textStyle: TextStyle(color: Colors.grey[400], fontSize: statFontSize)),
        ],
      );
    }

    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 8),
        Text(isSupport ? "Support" : "Oppose", style: const TextStyle(fontSize: statFontSize)),
        const SizedBox(width: 12),
        Text(votes, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: statFontSize)),
        const SizedBox(width: 8),
        _AnimatedPercentage(value: percentage, duration: animationDuration, textStyle: TextStyle(color: Colors.grey[400], fontSize: statFontSize)),
      ],
    );
  }
}

class _AnimatedPercentage extends StatefulWidget {
  final double value;
  final Duration duration;
  final Duration delay;
  final TextStyle? textStyle;

  const _AnimatedPercentage({
    required this.value,
    required this.duration,
    this.delay = Duration.zero,
    this.textStyle,
  });

  @override
  _AnimatedPercentageState createState() => _AnimatedPercentageState();
}

class _AnimatedPercentageState extends State<_AnimatedPercentage> {
  double _animatedValue = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleAnimation();
  }

  @override
  void didUpdateWidget(covariant _AnimatedPercentage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _scheduleAnimation();
    }
  }

  void _scheduleAnimation() {
    _timer?.cancel();
    _timer = Timer(widget.delay, () {
      if (mounted) {
        setState(() {
          _animatedValue = widget.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: _animatedValue),
      duration: widget.duration,
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) {
        return Text(
          "${value.toStringAsFixed(2)}%",
          style: widget.textStyle,
        );
      },
    );
  }
}

class _ProgressBar extends StatefulWidget {
  final double forPercent;
  final double againstPercent;
  final double height;
  final double? quorumPercent;
  final Color? fillColor;
  final Duration animationDuration;
  final Duration animationDelay;

  const _ProgressBar({
    required this.forPercent,
    required this.againstPercent,
    this.height = 8.0,
    this.quorumPercent,
    this.fillColor,
    required this.animationDuration,
    this.animationDelay = Duration.zero,
  });

  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar> {
  double _forFraction = 0.0;
  double _againstFraction = 0.0;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _scheduleAnimation();
  }

  @override
  void didUpdateWidget(covariant _ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.forPercent != oldWidget.forPercent ||
        widget.againstPercent != oldWidget.againstPercent) {
      _scheduleAnimation();
    }
  }

  void _scheduleAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer(widget.animationDelay, () {
      if (mounted) {
        setState(() {
          _forFraction = widget.forPercent / 100.0;
          _againstFraction = widget.againstPercent / 100.0;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: widget.height,
            decoration: BoxDecoration(color: Colors.grey.shade800),
          ),
          if (widget.fillColor != null)
            AnimatedContainer(
              width: constraints.maxWidth * _forFraction,
              height: widget.height,
              color: widget.fillColor,
              duration: widget.animationDuration,
              curve: Curves.easeInOutCubic,
            )
          else
            Row(
              children: [
                AnimatedContainer(
                  width: constraints.maxWidth * _forFraction,
                  height: widget.height,
                  color: const Color(0xff00c489),
                  duration: widget.animationDuration,
                  curve: Curves.easeInOutCubic,
                ),
                AnimatedContainer(
                  width: constraints.maxWidth * _againstFraction,
                  height: widget.height,
                  color: const Color(0xff86251e),
                  duration: widget.animationDuration,
                  curve: Curves.easeInOutCubic,
                ),
              ],
            ),
          if (widget.quorumPercent != null)
            Positioned(
              left: (constraints.maxWidth * (widget.quorumPercent! / 100)) - 1,
              top: -4,
              bottom: -4,
              child: Container(width: 2, color: Colors.black),
            ),
        ],
      );
    });
  }
}
// lib/src/features/proposal_detail/widgets/proposal_votes_card.dart