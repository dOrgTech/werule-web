import 'package:Homebase/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web3/ethers.dart';
import 'package:intl/intl.dart'; // For formatting the date
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_circle_chart/flutter_circle_chart.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'dart:math' as math;
import '../entities/contractFunctions.dart';
import '../entities/human.dart';
import '../entities/proposal.dart';
import '../utils/reusable.dart';
import '../widgets/countdown.dart';
import '../widgets/footer.dart';
import '../widgets/menu.dart';
import '../widgets/propDetailsWidgets.dart';
import 'dao.dart';
import 'dart:async';

const Color supportColor = Color.fromARGB(255, 20, 78, 49);
const Color rejectColor = Color.fromARGB(255, 88, 20, 20);

class ProposalDetails extends StatefulWidget {
  // int id;
  ProposalDetails({super.key, required this.p});
  final Proposal p;
  bool enabled = false;
  // String? status;
  bool busy = false;
  bool showCountdown = false;
  late int remainingSeconds;
  BigInt votesFor = BigInt.zero;
  BigInt votesAgainst = BigInt.zero;

  @override
  State<ProposalDetails> createState() => ProposalDetailsState();
}

class ProposalDetailsState extends State<ProposalDetails> {
  Timer? _statusCheckTimer;
  late String stage;
  String support = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    stage = widget.p.stage.toString().split(".").last;
    if (stage == "noQuorum") {
      stage = "no quorum";
      widget.showCountdown = false;
    }
    print("stage: " + stage);

    if (stage == "active" || stage == "pending" || stage == "executable") {
      setState(() {
        widget.remainingSeconds = widget.p.getRemainingTime()!.inSeconds;
      });
      widget.showCountdown = true;
      _statusCheckTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          stage = widget.p.stage.toString().split(".").last;
          if (stage == "passed" || stage == "executed" || stage == "rejected") {
            widget.showCountdown = false;
            timer.cancel();
          }
          if (stage == "noQuorum") {
            stage = "no quorum";
            widget.showCountdown = false;
            timer.cancel();
          }

          widget.remainingSeconds--;
        });
      });
    } else {
      widget.showCountdown = false;
    }
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  Widget actions() {
    if (stage == "passed") {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: ElevatedButton(
              style: TextButton.styleFrom(
                side:
                    BorderSide(width: 0.2, color: Theme.of(context).hintColor),
              ),
              onPressed: () async {
                setState(() {
                  widget.busy = true;
                });
                await queueProposal();
                print("queue");
                widget.p.statusHistory.addAll({"executable": DateTime.now()});
                await widget.p.store();
                setState(() {
                  stage = widget.p.stage.toString().split(".").last;
                  widget.remainingSeconds =
                      widget.p.getRemainingTime()!.inSeconds;
                  widget.showCountdown = true;
                  widget.busy = false;
                });
              },
              child: const Text("Queue for execution",
                  style: TextStyle(fontSize: 12))),
        ),
      );
    } else if (stage == "executable") {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: ElevatedButton(
              style: TextButton.styleFrom(
                side:
                    BorderSide(width: 0.2, color: Theme.of(context).hintColor),
              ),
              onPressed: () async {
                setState(() {
                  widget.busy = true;
                });
                // await execute(widget.p.transactions[0].recipient,
                //     widget.p.transactions[0].value.toString());
                await execute("ceva", "altceva");
                print("execute");
                widget.p.statusHistory.addAll({"executed": DateTime.now()});

                await widget.p.store();
                setState(() {
                  widget.busy = false;
                });
              },
              child: const Text("EXECUTE", style: TextStyle(fontSize: 12))),
        ),
      );
    } else if (stage == "executed") {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: GestureDetector(
            onTap: () {},
            child: const Text(
              'View on Block Explorer',
              style: TextStyle(
                color: Colors.green,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 48.0),
      child: SizedBox(
        width: 360,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                style: ButtonStyle(
                    elevation: MaterialStatePropertyAll(0.0),
                    backgroundColor: MaterialStatePropertyAll(widget.enabled
                        ? Color.fromARGB(255, 141, 255, 244)
                        : Color.fromARGB(255, 77, 77, 77))),
                onPressed: widget.enabled
                    ? () async {
                        Vote v = Vote(
                            castAt: DateTime.now(),
                            option: 1,
                            votingPower: "12000",
                            voter: generateWalletAddress(),
                            proposalHash: widget.p.hash);
                        setState(() {
                          widget.busy = true;
                        });
                        await vote();
                        await widget.p.castVote(v);
                        setState(() {
                          widget.busy = false;
                          widget.votesFor = BigInt.parse(widget.p.inFavor);
                          widget.votesAgainst = BigInt.parse(widget.p.against);
                        });

                        // Navigator.of(context).pushReplacement(MaterialPageRoute(
                        //     builder: (context) => DAO(
                        //         org: widget.p.org,
                        //         InitialTabIndex: 1,
                        //         proposalId: widget.p.id)));
                        print("vote added");
                      }
                    : null,
                child: SizedBox(
                    width: 120,
                    height: 40,
                    child: Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.thumb_up,
                            color: widget.enabled
                                ? supportColor
                                : Color.fromARGB(255, 160, 160, 160)
                                    .withOpacity(0.7)),
                        SizedBox(width: 8),
                        Text(
                          "Support",
                          style: widget.enabled
                              ? TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: supportColor)
                              : TextStyle(),
                        ),
                      ],
                    )))),
            const Spacer(),
            ElevatedButton(
                onPressed: widget.enabled
                    ? () async {
                        Vote v = Vote(
                            castAt: DateTime.now(),
                            option: 0,
                            votingPower: "14200",
                            voter: generateWalletAddress(),
                            proposalHash: widget.p.hash);
                        try {
                          await widget.p.castVote(v);
                          widget.p.votes.add(v);
                          print("vote added");
                        } on Exception catch (e) {
                          print("error adding vote" + e.toString());
                        }
                      }
                    : null,
                style: ButtonStyle(
                    elevation: MaterialStatePropertyAll(0.0),
                    backgroundColor: MaterialStatePropertyAll(widget.enabled
                        ? Color.fromARGB(255, 255, 135, 135)
                        : Color.fromARGB(255, 77, 77, 77))),
                child: SizedBox(
                    width: 120,
                    height: 40,
                    child: Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.thumb_down,
                            color: widget.enabled
                                ? rejectColor
                                : Color.fromARGB(255, 160, 160, 160)
                                    .withOpacity(0.7)),
                        SizedBox(width: 8),
                        Text(
                          "Reject",
                          style: widget.enabled
                              ? TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: rejectColor)
                              : TextStyle(),
                        ),
                      ],
                    ))))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool expired = false;
    stage == "active" ? widget.enabled = true : widget.enabled = false;
    stage == "expired" ? widget.showCountdown = false : expired = true;

    BigInt totalVotes =
        BigInt.parse(widget.p.inFavor) + BigInt.parse(widget.p.against);
    double inFavorPercentage = BigInt.parse(widget.p.inFavor) / totalVotes;
    double againstPercentage = BigInt.parse(widget.p.against) / totalVotes;
    double turnout = totalVotes / BigInt.parse(widget.p.org.totalSupply!);

    return Container(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Column(
          // Start of Column
          crossAxisAlignment: CrossAxisAlignment
              .center, // Set this property to center the items horizontally
          mainAxisSize: MainAxisSize
              .min, // Set this property to make the column fit its children's size vertically
          children: [
            const SizedBox(height: 10),
            Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DAO(
                                    InitialTabIndex: 1,
                                    org: widget.p.org,
                                  )));
                    },
                    child: const Text("< Back to all proposals"))),
            const SizedBox(height: 10),
            Container(
              height: 240,
              color: Theme.of(context).cardColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              widget.p.name!,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            border:
                                Border.all(width: 0.5, color: Colors.white12)),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            widget.p.statusPill(stage, context),
                            const SizedBox(width: 20),
                            Text("${widget.p.type!} proposal"),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                      const SizedBox(width: 129),
                      //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                      Padding(
                        padding: const EdgeInsets.only(top: 14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 30,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Posted By: "),
                                    Text(
                                      getShortAddress(widget.p.author!),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    const SizedBox(width: 2),
                                    TextButton(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text: widget.p.author));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  duration:
                                                      Duration(seconds: 1),
                                                  content: Center(
                                                      child: Text(
                                                          'Address copied to clipboard'))));
                                        },
                                        child: const Icon(Icons.copy)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 30,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Created At: "),
                                    Text(
                                      widget.p.createdAt!.toLocal().toString(),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    const SizedBox(
                                      width: 14,
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          launchUrl(widget.p.externalResource!
                                              as Uri);
                                        },
                                        child: const Icon(Icons.open_in_new)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 45),
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 450,
                        ),
                        padding: const EdgeInsets.all(18.0),
                        child: Text(
                          widget.p.description!,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 30,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Discussion: "),
                              OldSchoolLink(
                                  text: widget.p.externalResource!,
                                  url: widget.p.externalResource!)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  height: 280,
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: widget.busy
                          ? const Center(
                              child: SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: CircularProgressIndicator()))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 9),
                                ActionLabel(
                                  status: stage,
                                ),
                                widget.showCountdown
                                    ? Container(
                                        padding: EdgeInsets.only(top: 22),
                                        child: Transform.scale(
                                            scale: 0.8,
                                            child: _buildCountdownDisplay()))
                                    : Text(""),
                                const SizedBox(height: 32),
                                actions()
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  height: 280,
                  constraints: const BoxConstraints(
                    maxWidth: 680,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 19, left: 28.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "${widget.p.votesAgainst + widget.p.votesFor} Votes",
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: Theme.of(context).indicatorColor,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                                const SizedBox(width: 32),
                                ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                content: VotesModal(
                                                  p: widget.p,
                                                ),
                                              ));
                                    },
                                    child: const Text("View"))
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 34),
                                const Icon(
                                  Icons.circle,
                                  color: Color.fromARGB(255, 0, 196, 137),
                                ),
                                const SizedBox(width: 10),
                                const SizedBox(
                                    child: Text(
                                  "Support",
                                )),
                                const SizedBox(width: 13),
                                Text(
                                    (BigInt.parse(widget.p.inFavor) /
                                            BigInt.parse(
                                                pow(10, widget.p.org.decimals!)
                                                    .toString()))
                                        .toStringAsFixed(2),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    " (${(inFavorPercentage * 100).toStringAsFixed(2)}%)"),
                                const Spacer(),
                                const Icon(
                                  Icons.circle,
                                  color: Color.fromARGB(255, 134, 37, 30),
                                ),
                                const SizedBox(width: 10),
                                const SizedBox(
                                    child: Text(
                                  "Oppose",
                                )),
                                const SizedBox(width: 13),
                                Text(
                                    (BigInt.parse(widget.p.against) /
                                            BigInt.parse(
                                                pow(10, widget.p.org.decimals!)
                                                    .toString()))
                                        .toStringAsFixed(2),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    " (${(againstPercentage * 100).toStringAsFixed(2)}%)"),
                                const SizedBox(width: 73)
                              ],
                            ),
                          ),
                          const SizedBox(height: 13),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 28.0),
                              child: SizedBox(
                                  height: 12,
                                  width: double.infinity,
                                  child: ElectionResultBar(
                                      inFavor: BigInt.parse(widget.p.inFavor),
                                      against:
                                          BigInt.parse(widget.p.against)))),
                          const SizedBox(height: 43),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 34),
                                const SizedBox(
                                    child: Text("Turnout:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal))),
                                const SizedBox(width: 13),
                                Text(
                                    "${(BigInt.parse(widget.p.against) + BigInt.parse(widget.p.inFavor)) / BigInt.from(pow(10, widget.p.org.decimals!))} (${(turnout * 100).toStringAsFixed(2)}%)",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
                                SizedBox(
                                    child: Text(
                                        (turnout * 100) >= widget.p.org.quorum
                                            ? "Quorum met"
                                            : "Quorum not met",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900))),
                                const SizedBox(width: 73)
                              ],
                            ),
                          ),
                          const SizedBox(height: 13),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 28.0),
                              child: SizedBox(
                                  height: 12,
                                  width: double.infinity,
                                  child: ParticipationBar(
                                      totalVoters: BigInt.parse(
                                          widget.p.org.totalSupply!),
                                      turnout: BigInt.parse(widget.p.against) +
                                          BigInt.parse(widget.p.inFavor),
                                      quorum: widget.p.org.quorum))),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            // const Align(
            //     alignment: Alignment.topLeft,
            //     child: Padding(
            //       padding: EdgeInsets.only(left: 18.0),
            //       child: Text("Execution details:"),
            //     )),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align children at the top
              children: [
                Expanded(
                  // Ensure the ProposalLifeCycleWidget can expand to fill available space
                  child: Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).cardColor),
                    child: ProposalLifeCycleWidget(
                        statusHistory: widget.p.statusHistory),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 680,
                  ),
                  height: widget.p.type == "transfer"
                      ? widget.p.transactions.length * 70
                      : 270,
                  // Set a fixed width for the first container
                  padding: const EdgeInsets.all(4),

                  child: Align(
                    alignment: Alignment.center,
                    child: Center(
                        child: widget.p.type == "transfer"
                            ? TokenTransferListWidget(
                                p: widget.p,
                              )
                            : widget.p.type == "registry"
                                ? RegistryProposalDetails(p: widget.p)
                                : widget.p.type == "contract call"
                                    ? ContractCall(p: widget.p)
                                    : widget.p.type!.contains("mint") ||
                                            widget.p.type!.contains("burn")
                                        ? GovernanceTokenOperationDetails(
                                            p: widget.p,
                                          )
                                        : Text("")),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80)
          ],
        ),
      ),
    );
  }

  String _formatTime(int value) => value.toString().padLeft(2, '0');

  // Helper method to format the countdown as days, hours, minutes, and seconds
  Widget _buildCountdownDisplay() {
    final days = widget.remainingSeconds ~/ (24 * 3600);
    final hours = (widget.remainingSeconds % (24 * 3600)) ~/ 3600;
    final minutes = (widget.remainingSeconds % 3600) ~/ 60;
    final seconds = widget.remainingSeconds % 60;

    // Determine which units to display based on the remaining time
    final timeUnits = <MapEntry<String, int>>[];

    if (days > 0) {
      timeUnits.add(MapEntry("Days", days));
      timeUnits.add(MapEntry("Hours", hours));
      timeUnits.add(MapEntry("Minutes", minutes));
    } else if (hours > 0) {
      timeUnits.add(MapEntry("Hours", hours));
      timeUnits.add(MapEntry("Minutes", minutes));
    } else if (minutes > 0) {
      timeUnits.add(MapEntry("Minutes", minutes));
    }

    // Always show seconds as the smallest unit
    timeUnits.add(MapEntry("Seconds", seconds));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: timeUnits.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Text(
                entry.key,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 238, 238, 238)),
              ),
              SizedBox(height: 5),
              Text(
                _formatTime(entry.value),
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class ElectionResultBar extends StatefulWidget {
  final BigInt inFavor;
  final BigInt against;

  const ElectionResultBar({
    required this.inFavor,
    required this.against,
  });

  @override
  _ElectionResultBarState createState() => _ElectionResultBarState();
}

class _ElectionResultBarState extends State<ElectionResultBar> {
  double _inFavorWidth = 0;
  double _againstWidth = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateBar();
    });
  }

  @override
  void didUpdateWidget(covariant ElectionResultBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger re-animation if inFavor or against values change
    if (widget.inFavor != oldWidget.inFavor ||
        widget.against != oldWidget.against) {
      _animateBar();
    }
  }

  void _animateBar() {
    setState(() {
      BigInt totalVotes = widget.inFavor + widget.against;
      if (totalVotes > BigInt.zero) {
        _inFavorWidth = widget.inFavor.toDouble() / totalVotes.toDouble();
        _againstWidth = widget.against.toDouble() / totalVotes.toDouble();
      } else {
        // No votes case: both widths should be zero
        _inFavorWidth = 0;
        _againstWidth = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    BigInt totalVotes = widget.inFavor + widget.against;

    // Handle case with no votes
    if (totalVotes == BigInt.zero) {
      return Container(
        height: 20,
        width: double.infinity, // Use full width available
        color: Colors.grey[700], // Grey color to represent no votes
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double barWidth = constraints.maxWidth;
        double maxDuration = 800; // Maximum total duration in milliseconds

        // The larger portion determines the animation duration
        double maxPercentage = max(_inFavorWidth, _againstWidth);
        int durationInMillis = (maxDuration * maxPercentage).toInt();

        return Row(
          children: [
            AnimatedContainer(
              width: barWidth * _inFavorWidth, // Use the actual widget width
              height: 20, // Height of the bar
              color: Color.fromARGB(255, 0, 196, 137),
              duration: Duration(milliseconds: durationInMillis),
              curve: Curves.easeInOut,
            ),
            AnimatedContainer(
              width: barWidth * _againstWidth, // Use the actual widget width
              height: 20,
              color: Color.fromARGB(255, 134, 37, 30),
              duration: Duration(milliseconds: durationInMillis),
              curve: Curves.easeInOut,
            ),
          ],
        );
      },
    );
  }
}

class ParticipationBar extends StatefulWidget {
  final BigInt totalVoters;
  final BigInt turnout;
  final int quorum; // Provided as a percentage, e.g., 50 for 50%

  const ParticipationBar({
    required this.totalVoters,
    required this.turnout,
    required this.quorum,
  });

  @override
  _ParticipationBarState createState() => _ParticipationBarState();
}

class _ParticipationBarState extends State<ParticipationBar> {
  double _turnoutWidth = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateTurnout();
    });
  }

  @override
  void didUpdateWidget(covariant ParticipationBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recalculate turnout width if turnout or totalVoters change
    if (widget.turnout != oldWidget.turnout ||
        widget.totalVoters != oldWidget.totalVoters) {
      _animateTurnout();
    }
  }

  void _animateTurnout() {
    setState(() {
      // Convert BigInt to double for correct calculation
      if (widget.totalVoters > BigInt.zero) {
        _turnoutWidth =
            widget.turnout.toDouble() / widget.totalVoters.toDouble();
      } else {
        _turnoutWidth = 0; // No voters case
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate turnout and quorum positions for display
    double turnoutPercentage =
        (widget.turnout.toDouble() / widget.totalVoters.toDouble()) * 100;
    double quorumPosition = widget.quorum / 100; // Convert quorum to a fraction

    return LayoutBuilder(
      builder: (context, constraints) {
        double barWidth =
            constraints.maxWidth; // Get the actual width of the widget

        return Stack(
          children: [
            // Background for total possible votes
            Container(
              height: 20,
              width: barWidth,
              color: Colors.grey[700], // Dark grey
            ),
            // Animated container for turnout portion
            AnimatedContainer(
              width: barWidth * _turnoutWidth, // Width proportional to turnout
              height: 20,
              color: Colors.grey[400], // Light grey for turnout
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            ),
            // Quorum marker
            Positioned(
              left: quorumPosition *
                  barWidth, // Position based on quorum percentage
              child: Container(
                height: 15,
                width: 6, // Small vertical line for quorum marker
                color: Colors.black, // Marker color
              ),
            ),
          ],
        );
      },
    );
  }
}

class VotesModal extends StatefulWidget {
  final Proposal p;
  VotesModal({required this.p, super.key});

  @override
  State<VotesModal> createState() => _VotesModalState();
}

class _VotesModalState extends State<VotesModal> {
  late Future<void> _votesFuture;

  Future<void> getVotes() async {
    var votesCollection = FirebaseFirestore.instance
        .collection("daos${Human().chain.name}")
        .doc(widget.p.org.address)
        .collection("proposals")
        .doc(widget.p.hash.toString())
        .collection("votes");

    var votesSnapshot = await votesCollection.get();
    widget.p.votes.clear();
    for (var doc in votesSnapshot.docs) {
      widget.p.votes.add(Vote(
        votingPower: doc.data()['weight'],
        voter: doc.id,
        proposalHash: widget.p.hash,
        option: doc.data()['option'],
        castAt: (doc.data()['cast'] != null)
            ? (doc.data()['cast'] as Timestamp).toDate()
            : null,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _votesFuture = getVotes(); // Initialize the Future in initState
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "Unknown";
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: FutureBuilder<void>(
        future: _votesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading spinner while fetching data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle any errors
            return Center(
                child: Text("Error loading votes: ${snapshot.error}"));
          } else {
            // Data is ready, display the votes in a table
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Voter')),
                    DataColumn(label: Text('Option')),
                    DataColumn(label: Text('Weight')),
                    DataColumn(label: Text('Cast At')),
                    DataColumn(label: Text('Details')),
                  ],
                  rows: widget.p.votes.map((vote) {
                    return DataRow(cells: [
                      DataCell(Text(vote.voter!)),
                      DataCell(Container(
                          child: vote.option == 0
                              ? Icon(Icons.thumb_down,
                                  color: Color.fromARGB(255, 238, 129, 121))
                              : Icon(Icons.thumb_up_sharp,
                                  color: Color.fromARGB(255, 93, 223, 162)))),
                      DataCell(Text(vote.votingPower.toString())),
                      DataCell(Text(formatDateTime(vote.castAt))),
                      const DataCell(Icon(Icons
                          .open_in_new)), // You can add onTap functionality here later
                    ]);
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class ProposalLifeCycleWidget extends StatelessWidget {
  final Map<String, DateTime> statusHistory;
  Proposal p = Proposal(org: orgs[0]);
  ProposalLifeCycleWidget({required this.statusHistory});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (100 + 40 * statusHistory.keys.length)
          .toDouble(), // Adjust the height as needed
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(43),
              itemCount: statusHistory.length,
              itemBuilder: (context, index) {
                final sortedKeys = statusHistory.keys.toList()
                  ..sort(
                      (a, b) => statusHistory[a]!.compareTo(statusHistory[b]!));
                final status = sortedKeys[index];
                final date = statusHistory[status]!;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28.0, vertical: 9.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      p.statusPill(status, context),
                      Text(DateFormat.yMMMd().add_jm().format(date)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
