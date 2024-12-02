import 'dart:convert';

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
import '../entities/org.dart';
import '../entities/proposal.dart';
import '../main.dart';
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
  Proposal p;
  bool enabled = false;
  // String? status;
  bool busy = false;
  bool showCountdown = false;
  late int remainingSeconds;
  BigInt votesFor = BigInt.zero;
  BigInt votesAgainst = BigInt.zero;
  Member? member;
  @override
  State<ProposalDetails> createState() => ProposalDetailsState();
}

class ProposalDetailsState extends State<ProposalDetails> {
  Timer? _statusCheckTimer;
  // late String p.status;
  String support = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // p.status = widget.p.p.status.toString().split(".").last;
    // p.status = "pending";
    // if (p.status == "noQuorum") {
    //   p.status = "no quorum";
    //   widget.showCountdown = false;
    // }
    // print("p.status: " + p.status);

    // if (p.status == "active" || p.status == "pending" || p.status == "executable") {
    //   setState(() {
    //     widget.remainingSeconds = widget.p.getRemainingTime()!.inSeconds;
    //   });
    //   widget.showCountdown = true;
    //   _statusCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //     setState(() {
    //       p.status = widget.p.p.status.toString().split(".").last;
    //       if (p.status == "passed" || p.status == "executed" || p.status == "rejected") {
    //         widget.showCountdown = false;
    //         timer.cancel();
    //       }
    //       if (p.status == "noQuorum") {
    //         p.status = "no quorum";
    //         widget.showCountdown = false;
    //         timer.cancel();
    //       }

    //       widget.remainingSeconds--;
    //     });
    //   });
    // } else {
    //   widget.showCountdown = false;
    // }
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
                widget.p.statusHistory.addAll({"executable": DateTime.now()});
                await widget.p.store();
                setState(() {
                  widget.p.status = widget.p.status.toString().split(".").last;
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
    } else if (widget.p.status == "executable") {
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
                await queueProposal(widget.p);
                print("execute");
                widget.p.statusHistory.addAll({"executed": DateTime.now()});

                await widget.p.store();
                await daosCollection
                    .doc(widget.p.org.address)
                    .set(widget.p.org.toJson());
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
                    elevation: const MaterialStatePropertyAll(0.0),
                    backgroundColor: MaterialStatePropertyAll(widget.enabled
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
                              await widget.p.castVote(v);
                              setState(() {
                                widget.busy = false;
                                widget.votesFor =
                                    BigInt.parse(widget.p.inFavor);
                                widget.votesAgainst =
                                    BigInt.parse(widget.p.against);
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
                            } catch (e) {}
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
                              await widget.p.castVote(v);
                              setState(() {
                                widget.busy = false;
                                widget.votesFor =
                                    BigInt.parse(widget.p.inFavor);
                                widget.votesAgainst =
                                    BigInt.parse(widget.p.against);
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
                              print("some error " + e.toString());
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
                style: ButtonStyle(
                    elevation: const MaterialStatePropertyAll(0.0),
                    backgroundColor: MaterialStatePropertyAll(widget.enabled
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
    bool expired = false;
    // p.status == "active" ? widget.enabled = true : widget.enabled = false;
    // p.status == "expired" ? widget.showCountdown = false : expired = true;

    BigInt totalVotes =
        BigInt.parse(widget.p.inFavor) + BigInt.parse(widget.p.against);
    double inFavorPercentage = BigInt.parse(widget.p.inFavor) / totalVotes;
    double againstPercentage = BigInt.parse(widget.p.against) / totalVotes;
    double turnout = (totalVotes *
            BigInt.parse(pow(10, widget.p.org.decimals!).toString())) /
        BigInt.parse(widget.p.org.totalSupply!);

    // return Text("hello");

    return Container(
      alignment: Alignment.topCenter,
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("idaos${Human().chain.name}")
              .doc(widget.p.org.address!)
              .collection('proposals')
              .doc(widget.p.id.toString())
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child:
                      CircularProgressIndicator()); // Show a loading indicator
            }
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            var data = snapshot.data!.data() as Map<String, dynamic>;
            String aidi = widget.p.id!;
            widget.p = Proposal(org: widget.p.org, name: data['title']);
            widget.p.id = aidi;
            widget.p.type = data['type'];
            widget.p.against = data['against'];
            widget.p.inFavor = data['inFavor'];
            widget.p.hash = widget.p.id!;
            widget.p.callData = data['calldata'];
            // widget.p.callDatas = data['callDatas'];
            print("lengthof calldadas ${widget.p.callDatas.length}");
            List<dynamic> blobArray = data['callDatas'] ?? [];

            for (var blob in blobArray) {
              if (blob is Blob) {
                print(blob.bytes); // Prints the raw byte array
                String hexString = blob.bytes
                    .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                    .join();
                widget.p.callDatas.add(hexString);
              }
            }

            print("Decoded callDatas: $blobArray");
            print("these are the calldatas" + widget.p.callDatas.toString());
            widget.p.createdAt = (data['createdAt'] as Timestamp).toDate();
            widget.p.turnoutPercent = data['turnoutPercent'];
            widget.p.author = data['author'];
            widget.p.votesFor = data['votesFor'];
            widget.p.targets = List<String>.from(data['targets']);
            widget.p.values = List<String>.from(data['values']);
            widget.p.votesAgainst = data['votesAgainst'];
            widget.p.externalResource =
                data['externalResource'] ?? "(no external resource)";
            widget.p.description = data['description'] ?? "no description";
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
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  border: Border.all(
                                      width: 0.5, color: Colors.white12)),
                              child: Row(
                                children: [
                                  const SizedBox(width: 10),
                                  FutureBuilder(
                                    future: widget.p.anotherStageGetter(),
                                    builder: (context, asyncSnapshot) {
                                      if (asyncSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return SizedBox(
                                            width: 80,
                                            child: LinearProgressIndicator(
                                              color: Theme.of(context)
                                                  .indicatorColor,
                                            ));
                                      }

                                      if (asyncSnapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (asyncSnapshot.hasData) {
                                        } else if (asyncSnapshot.hasError) {
                                          return Text('${asyncSnapshot.error}');
                                        }
                                      } else {
                                        // Show a loading indicator
                                      }
                                      return widget.p
                                          .statusPill(widget.p.status, context);
                                    },
                                  ),
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
                                                    text: widget.p.author));
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
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 30,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text("Created At: "),
                                          Text(
                                            widget.p.createdAt!
                                                .toLocal()
                                                .toString(),
                                            style:
                                                const TextStyle(fontSize: 11),
                                          ),
                                          const SizedBox(
                                            width: 14,
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                launchUrl(widget.p
                                                    .externalResource! as Uri);
                                              },
                                              child: const Icon(
                                                  Icons.open_in_new)),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 9),
                                      ActionLabel(
                                        status: widget.p.status,
                                      ),
                                      widget.showCountdown
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                  top: 22),
                                              child: Transform.scale(
                                                  scale: 0.8,
                                                  child:
                                                      _buildCountdownDisplay()))
                                          : const Text(""),
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
                                      Text(
                                          (BigInt.parse(widget.p.inFavor)
                                              .toString()),
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
                                          (BigInt.parse(widget.p.against)
                                              .toString()),
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
                                          "${(BigInt.parse(widget.p.against) + BigInt.parse(widget.p.inFavor))} (${(turnout * 100).toStringAsFixed(2)}%)",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const Spacer(),
                                      SizedBox(
                                          child: Text(
                                              (turnout * 100) >=
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
                                            decimals: widget.p.org.decimals!,
                                            totalVoters: BigInt.parse(
                                                (BigInt.parse(widget.p.org.totalSupply!) /
                                                        BigInt.parse(
                                                            pow(10, widget.p.org.decimals!)
                                                                .toString()))
                                                    .toString()),
                                            turnout: (BigInt.parse(
                                                        widget.p.against) +
                                                    BigInt.parse(widget.p.inFavor)) *
                                                BigInt.parse(pow(10, widget.p.org.decimals!).toString()),
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
                                                  widget.p.type!
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
                                                          .contains("treasury")
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
              color: const Color.fromARGB(255, 0, 196, 137),
              duration: Duration(milliseconds: durationInMillis),
              curve: Curves.easeInOut,
            ),
            AnimatedContainer(
              width: barWidth * _againstWidth, // Use the actual widget width
              height: 20,
              color: const Color.fromARGB(255, 134, 37, 30),
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
  final int quorum;
  final int decimals;
  const ParticipationBar(
      {required this.totalVoters,
      required this.turnout,
      required this.quorum,
      required this.decimals});

  @override
  _ParticipationBarState createState() => _ParticipationBarState();
}

class _ParticipationBarState extends State<ParticipationBar> {
  double _turnoutWidth = 0;
  @override
  void initState() {
    print('initState called');
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
      if (widget.totalVoters > BigInt.zero) {
        double turnout = widget.turnout.toDouble();
        double totalVoters = widget.totalVoters.toDouble();
        _turnoutWidth = (turnout / totalVoters) / pow(10, widget.decimals);

        // Debug statements
        print('Turnout: $turnout');
        print('Total Voters: $totalVoters');
        print('Calculated Turnout Width: $_turnoutWidth');
      } else {
        _turnoutWidth = 0;
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
        .collection("idaos${Human().chain.name}")
        .doc(widget.p.org.address)
        .collection("proposals")
        .doc(widget.p.id.toString())
        .collection("votes");
    print("creating the collection");
    var votesSnapshot = await votesCollection.get();
    print("length of votesSnapshot.docs ${votesSnapshot.docs.length}");
    widget.p.votes.clear();
    for (var doc in votesSnapshot.docs) {
      print("adding a vote");
      widget.p.votes.add(Vote(
        votingPower: doc.data()['weight'],
        voter: doc.data()['voter'],
        hash: "0x" +
            doc
                .data()['hash']
                .bytes
                .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                .join(),
        proposalID: widget.p.id!,
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
                    DataColumn(label: Text("Cast At")),
                    DataColumn(label: Text('Details')),
                  ],
                  rows: widget.p.votes.map((vote) {
                    return DataRow(cells: [
                      DataCell(Row(
                        children: [
                          Text(getShortAddress(vote.voter!)),
                          const SizedBox(width: 8),
                          TextButton(
                              child: Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: vote.voter!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Center(
                                            child: Text(
                                                'Address copied to clipboard'))));
                              })
                        ],
                      )),
                      DataCell(Container(
                          child: vote.option == 0
                              ? const Icon(Icons.thumb_down,
                                  color: Color.fromARGB(255, 238, 129, 121))
                              : const Icon(Icons.thumb_up_sharp,
                                  color: Color.fromARGB(255, 93, 223, 162)))),
                      DataCell(Text(vote.votingPower.toString())),
                      DataCell(Text(DateFormat("yyyy-MM-dd – HH:mm")
                          .format(vote.castAt!))),
                      DataCell(
                        TextButton(
                            onPressed: () => launch(
                                "${Human().chain.blockExplorer}/tx/${vote.hash}"),
                            child: Icon(Icons
                                .open_in_new)), // You can add onTap functionality here later
                      )
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
              padding: const EdgeInsets.all(43),
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
