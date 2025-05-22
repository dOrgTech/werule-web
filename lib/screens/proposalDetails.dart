import 'package:Homebase/utils/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// For formatting the date
import '../entities/contractFunctions.dart';
import '../entities/human.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';
import '../utils/reusable.dart';
import '../widgets/countdown.dart';
import '../widgets/propDetailsWidgets.dart';
import '../widgets/testwidget.dart';
import 'dart:async';

const Color supportColor = Color.fromARGB(255, 20, 78, 49);
const Color rejectColor = Color.fromARGB(255, 88, 20, 20);

class ProposalDetails extends StatefulWidget {
  // int id;
  ProposalDetails({super.key, required this.p});
  Proposal p;
  bool enabled = false;
  // String? status;
  bool busy = false;
  bool showCountdown = false;
  late int remainingSeconds;
  BigInt votesFor = BigInt.zero;
  BigInt votesAgainst = BigInt.zero;
  bool dontKnowWhenItWasQueued = false;
  Member? member;

  Stream<Map<String, dynamic>?> getProposalFromFirestore() async* {
    final snapshots = FirebaseFirestore.instance
        .collection("idaos${Human().chain.name}")
        .doc(p.org.address!)
        .collection('proposals')
        .doc(p.id.toString())
        .snapshots();

    await for (final snapshot in snapshots) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        String aidi = p.id!;
        p = Proposal(org: p.org, name: data['title']);
        p.id = aidi;
        p.type = data['type'];

        // BigInt number = BigInt.parse(data['inFavor']);
        // BigInt divisor = BigInt.from(pow(10, p.org.decimals!));
        // BigInt result = number ~/ divisor;
        // p.inFavor = result.toString();
        // number = BigInt.parse(data['against']);
        // BigInt againstResult = number ~/ divisor;
        // p.against = againstResult.toString();

        p.against = parseNumber(data['against'], p.org.decimals!);
        p.inFavor = parseNumber(data['inFavor'], p.org.decimals!);

        p.hash = p.id!;
        p.callData = data['calldata'];
        List<dynamic> blobArray = data['callDatas'] ?? [];

        for (var blob in blobArray) {
          if (blob is Blob) {
            // Prints the raw byte array
            String hexString = blob.bytes
                .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                .join();
            p.callDatas.add(hexString);
          }
        }
        List<String> amounts = await getProposalVotes(p);
        p.against = amounts[0];
        p.inFavor = amounts[1];

        var statusHistoryMap = data['statusHistory'] as Map<String, dynamic>;
        p.statusHistory = statusHistoryMap.map((key, value) {
          return MapEntry(key, (value as Timestamp).toDate());
        });
        p.createdAt = (data['createdAt'] as Timestamp).toDate();

        p.author = data['author'];
        p.votesFor = data['votesFor'];
        p.votesAgainst = data['votesAgainst'];
        BigInt totalVotes =
            BigInt.parse(data['inFavor']) + BigInt.parse(data['against']);
        BigInt numerator = totalVotes * BigInt.from(10).pow(18);
        BigInt turnoutbigInt = numerator ~/ BigInt.parse(p.org.totalSupply!);
        double ceva =
            turnoutbigInt.toDouble() / BigInt.from(10).pow(18).toDouble();
        p.turnout = ceva.toDouble();

        p.targets = List<String>.from(data['targets']);
        p.values = List<String>.from(data['values']);
        p.externalResource =
            data['externalResource'] ?? "(no external resource)";
        p.description = data['description'] ?? "no description";
        await p.anotherStageGetter();
        _setRemainingTime();
        if (p.status == "executed") {
          p.executionHash = "0x${parseTransactionHash(data['executionHash'])}";
        }

        yield snapshot.data();
      } else {
        yield null;
      }
    }
  }

  void _setRemainingTime() {
    DateTime now = DateTime.now().subtract(const Duration(seconds: 10));
    DateTime votingStarts =
        p.statusHistory["pending"]!.add(Duration(minutes: p.org.votingDelay));
    DateTime votingEnds =
        votingStarts.add(Duration(minutes: p.org.votingDuration));
    if (p.status == "pending") {
      remainingSeconds = ((now.difference(votingStarts).inSeconds) + 4).abs();

      showCountdown = true;
    } else if (p.status == "active") {
      remainingSeconds = (now.difference(votingEnds).inSeconds + 4).abs();

      showCountdown = true;
      enabled = true;
    } else if (p.status == "queued") {
      DateTime? executionAvailable;
      if (p.statusHistory["queued"] != null) {
        executionAvailable = p.statusHistory["queued"]!
            .add(Duration(seconds: p.org.executionDelay));
      } else {
        executionAvailable =
            votingEnds.add(Duration(seconds: p.org.executionDelay));
      }
      remainingSeconds =
          (executionAvailable.difference(now).inSeconds + 4).abs();

      showCountdown = true;
    } else {
      enabled = false;
      showCountdown = false;
    }
  }

  @override
  State<ProposalDetails> createState() => ProposalDetailsState();
}

class ProposalDetailsState extends State<ProposalDetails> {
  Timer? _statusCheckTimer;
  // late String p.status;
  String support = "";

  @override
  void initState() {
    super.initState();
  }

  void _updateStatus() {
    DateTime now = DateTime.now();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  Widget actions() {
    if (widget.p.status == "passed") {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: ElevatedButton(
              style: TextButton.styleFrom(
                side:
                    BorderSide(width: 0.2, color: Theme.of(context).hintColor),
              ),
              onPressed: () async {
                if (Human().address == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Center(
                          child: Text("Connect your wallet first.",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 70, 11, 7))))));
                  return;
                }
                setState(() {
                  widget.busy = true;
                });
                String cevine = await queueProposal(widget.p);
                print("queue");
                if (cevine.contains("not ok")) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Center(
                          child: Text("Error submitting transaction",
                              style: TextStyle(color: Colors.red)))));
                  setState(() {
                    widget.busy = false;
                  });
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Center(
                        child: Text("Proposal Queued",
                            style: TextStyle(
                                fontSize: 21,
                                color: Color.fromARGB(255, 19, 27, 16))))));
                setState(() {
                  widget.busy = false;
                });
              },
              child: const Text("Queue for execution",
                  style: TextStyle(fontSize: 12))),
        ),
      );
    } else if (widget.p.status == "executable") {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 48.0),
          child: ElevatedButton(
              style: TextButton.styleFrom(
                side:
                    BorderSide(width: 0.2, color: Theme.of(context).hintColor),
              ),
              onPressed: () async {
                String cevine = "";
                setState(() {
                  widget.busy = true;
                });
                try {
                  cevine = await execute(widget.p);
                  if (cevine.contains("not ok")) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Center(
                            child: Text("Error executing proposal",
                                style: TextStyle(color: Colors.red)))));
                  }
                  setState(() {
                    widget.busy = false;
                  });
                } catch (e) {
                  setState(() {
                    widget.busy = false;
                  });
                }
                if (!cevine.contains("not ok")) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Center(
                          child: Text("Proposal Executed!",
                              style: TextStyle(
                                  fontSize: 21,
                                  color: Color.fromARGB(255, 19, 27, 16))))));
                }
                setState(() {
                  widget.busy = false;
                });
              },
              child: const Text("EXECUTE", style: TextStyle(fontSize: 12))),
        ),
      );
    } else if (widget.p.status == "executed") {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: GestureDetector(
            onTap: () {},
            child: OldSchoolLink(
                text: 'View on Block Explorer',
                url:
                    "${Human().chain.blockExplorer}/tx/${widget.p.executionHash}"),
          ),
        ),
      );
    } else if (widget.p.status == "queued") {
      return const SizedBox();
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
                    elevation: const WidgetStatePropertyAll(0.0),
                    backgroundColor: WidgetStatePropertyAll(widget.enabled
                        ? const Color.fromARGB(255, 141, 255, 244)
                        : const Color.fromARGB(255, 77, 77, 77))),
                onPressed: widget.enabled
                    ? () async {
                        if (Human().address == null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Center(
                            child: Text(
                              "Connect your wallet first.",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 70, 11, 7)),
                            ),
                          )));
                          return;
                        }

                        if (!(widget.p.org.memberAddresses[
                                Human().address!.toLowerCase()] ==
                            null)) {
                          widget.member = widget.p.org
                              .memberAddresses[Human().address!.toLowerCase()];
                          if (BigInt.parse(widget.member!.votingWeight!) >
                              BigInt.zero) {
                            Vote v = Vote(
                                castAt: DateTime.now(),
                                option: 1,
                                votingPower: widget.member!.votingWeight!,
                                voter: Human().address!,
                                proposalID: widget.p.id!);
                            setState(() {
                              widget.busy = true;
                            });
                            try {
                              String cevine = await vote(v, widget.p.org);
                              if (cevine.contains("not ok")) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        content: Center(
                                  child: Text(
                                    "Error adding vote.",
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: Color.fromARGB(255, 61, 4, 4)),
                                  ),
                                )));
                                setState(() {
                                  widget.busy = false;
                                });
                                return;
                              }
                              v.hash = cevine;
                              setState(() {
                                widget.busy = false;
                              });
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                      content: Center(
                                child: Text(
                                  "Vote added successfully.",
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Color.fromARGB(255, 4, 61, 23)),
                                ),
                              )));
                              print("vote added");
                            } catch (e) {
                              print(e.toString());
                            }
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Center(
                              child: Text(
                                "Claim your voting power if you want to participate in governance (in the Account tab).",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 70, 11, 7)),
                              ),
                            )));
                          }
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Center(
                            child: Text(
                              "You are not a member of this organization.",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 70, 11, 7)),
                            ),
                          )));
                        }
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
                                : const Color.fromARGB(255, 160, 160, 160)
                                    .withOpacity(0.7)),
                        const SizedBox(width: 8),
                        Text(
                          "Support",
                          style: widget.enabled
                              ? const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: supportColor)
                              : const TextStyle(),
                        ),
                      ],
                    )))),
            const Spacer(),
            ElevatedButton(
                onPressed: widget.enabled
                    ? () async {
                        print("voting baby");
                        if (Human().address == null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Center(
                            child: Text(
                              "Connect your wallet first.",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 70, 11, 7)),
                            ),
                          )));
                          return;
                        }

                        if (!(widget.p.org.memberAddresses[
                                Human().address!.toLowerCase()] ==
                            null)) {
                          widget.member = widget.p.org
                              .memberAddresses[Human().address!.toLowerCase()];
                          if (BigInt.parse(widget.member!.votingWeight!) >
                              BigInt.zero) {
                            Vote v = Vote(
                                castAt: DateTime.now(),
                                option: 0,
                                votingPower: widget.member!.votingWeight!,
                                voter: Human().address!,
                                proposalID: widget.p.id!);
                            setState(() {
                              widget.busy = true;
                            });
                            try {
                              String cevine = await vote(v, widget.p.org);
                              if (cevine.contains("not ok")) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        content: Center(
                                  child: Text(
                                    "Error adding vote.",
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: Color.fromARGB(255, 61, 4, 4)),
                                  ),
                                )));
                                setState(() {
                                  widget.busy = false;
                                });
                                return;
                              }
                              v.hash = cevine;

                              setState(() {
                                widget.busy = false;
                              });
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                      content: Center(
                                child: Text(
                                  "Vote added successfully.",
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: Color.fromARGB(255, 4, 61, 23)),
                                ),
                              )));
                              print("vote added");
                            } catch (e) {
                              print("some error $e");
                            }
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Center(
                              child: Text(
                                "You have no voting power at the time when this proposal was created.",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 70, 11, 7)),
                              ),
                            )));
                          }
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Center(
                            child: Text(
                              "You are not a member of this organization.",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 70, 11, 7)),
                            ),
                          )));
                        }
                      }
                    : null,
                style: ButtonStyle(
                    elevation: const WidgetStatePropertyAll(0.0),
                    backgroundColor: WidgetStatePropertyAll(widget.enabled
                        ? const Color.fromARGB(255, 255, 135, 135)
                        : const Color.fromARGB(255, 77, 77, 77))),
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
                                : const Color.fromARGB(255, 160, 160, 160)
                                    .withOpacity(0.7)),
                        const SizedBox(width: 8),
                        Text(
                          "Reject",
                          style: widget.enabled
                              ? const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: rejectColor)
                              : const TextStyle(),
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
    return everything();
  }

  Widget everything() {
    BigInt totalVotes =
        BigInt.parse(widget.p.inFavor) + BigInt.parse(widget.p.against);
    double inFavorPercentage = BigInt.parse(widget.p.inFavor) / totalVotes;
    double againstPercentage = BigInt.parse(widget.p.against) / totalVotes;
    // double turnout = double.parse(totalVotes.toString());
    // double turnout = double.parse(widget.p.org.totalSupply!);
    return Container(
      alignment: Alignment.topCenter,
      child: StreamBuilder(
          stream: widget.getProposalFromFirestore(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child:
                      CircularProgressIndicator()); // Show a loading indicator
            }
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            return SingleChildScrollView(
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
                            // context.go("/" + widget.p.org.address!);
                            Navigator.of(context).pop();
                          },
                          child: const Text("< Back"))),
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
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    widget.p.name!,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  border: Border.all(
                                      width: 0.5, color: Colors.white12)),
                              child: Row(
                                children: [
                                  const SizedBox(width: 10),
                                  widget.p.statusPill(widget.p.status, context),
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
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 30,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text("Posted By: "),
                                          Text(
                                            getShortAddress(widget.p.author!),
                                            style:
                                                const TextStyle(fontSize: 11),
                                          ),
                                          const SizedBox(width: 2),
                                          TextButton(
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: widget.p.author!));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        duration: Duration(
                                                            seconds: 1),
                                                        content: Center(
                                                            child: Text(
                                                                'Address copied to clipboard'))));
                                              },
                                              child: const Icon(Icons.copy)),
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
                                        text:
                                            widget.p.externalResource!.length <
                                                    42
                                                ? widget.p.externalResource!
                                                : "${widget.p.externalResource!
                                                        .substring(0, 42)}...",
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
                                : Builder(builder: (context) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 3),
                                        ActionLabel(
                                          status: widget.p.status,
                                        ),
                                        widget.showCountdown
                                            ? Container(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: Transform.scale(
                                                    scale: 0.73,
                                                    child: CNTDN(
                                                      onCountdownComplete: () {
                                                        setState(() {});
                                                      },
                                                      remainingSeconds: widget
                                                          .remainingSeconds,
                                                      key: ValueKey(widget
                                                          .remainingSeconds),
                                                    )))
                                            : const Text(""),
                                        const SizedBox(height: 32),
                                        if (widget.p.status != "queued")
                                          actions(),
                                      ],
                                    );
                                  }),
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
                                  padding: const EdgeInsets.only(
                                      top: 19, left: 28.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "${widget.p.votesAgainst + widget.p.votesFor} Votes",
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Theme.of(context)
                                                  .indicatorColor,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                      const SizedBox(width: 32),
                                      ElevatedButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
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
                                      Text(parseNumber(widget.p.inFavor, 0),
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
                                      Text(parseNumber(widget.p.against, 0),
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 28.0),
                                    child: SizedBox(
                                        height: 12,
                                        width: double.infinity,
                                        child: ElectionResultBar(
                                            inFavor:
                                                BigInt.parse(widget.p.inFavor),
                                            against: BigInt.parse(
                                                widget.p.against)))),
                                const SizedBox(height: 43),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 34),
                                      const SizedBox(
                                          child: Text("Turnout:",
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.normal))),
                                      const SizedBox(width: 13),
                                      Text(
                                          "${parseNumber((BigInt.parse(widget.p.against) + BigInt.parse(widget.p.inFavor)).toString(), 0)} ",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          "(${(widget.p.turnout * 100).toStringAsFixed(2)} %)"),
                                      const Spacer(),
                                      SizedBox(
                                          child: Text(
                                              widget.p.turnout * 100 >=
                                                      widget.p.org.quorum
                                                  ? "Quorum met"
                                                  : "Quorum not met",
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w900))),
                                      const SizedBox(width: 73)
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 13),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 28.0),
                                    child: SizedBox(
                                        height: 12,
                                        width: double.infinity,
                                        child: ParticipationBar(
                                          quorum:
                                              widget.p.org.quorum.toDouble(),
                                          turnout: widget.p.turnout,
                                        ))),
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
                          child: ProposalLifeCycleWidget(p: widget.p),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 680,
                        ),
                        height: widget.p.type!.contains("transfer")
                            ? widget.p.callDatas.length * 70
                            : 270,
                        // Set a fixed width for the first container
                        padding: const EdgeInsets.all(4),

                        child: Align(
                          alignment: Alignment.center,
                          child: Center(
                              child: widget.p.type!.contains("transfer")
                                  ? TokenTransferListWidget(
                                      p: widget.p,
                                    )
                                  : widget.p.type == "registry"
                                      ? RegistryProposalDetails(p: widget.p)
                                      : widget.p.type == "contract call"
                                          ? ContractCall(p: widget.p)
                                          : widget.p.type!
                                                      .toLowerCase()
                                                      .contains("mint") ||
                                                  widget.p.type!
                                                      .toLowerCase()
                                                      .contains("burn")
                                              ? GovernanceTokenOperationDetails(
                                                  p: widget.p,
                                                )
                                              : widget.p.type!
                                                          .contains("quorum") ||
                                                      widget.p.type!.contains(
                                                          "voting delay") ||
                                                      widget.p.type!.contains(
                                                          "voting period") ||
                                                      widget.p.type!
                                                          .contains("threshold")
                                                  ? DaoConfigurationDetails(
                                                      p: widget.p)
                                                  : const Text("")),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80)
                ],
              ),
            );
          }),
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
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 238, 238, 238)),
              ),
              const SizedBox(height: 5),
              Text(
                _formatTime(entry.value),
                style:
                    const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
