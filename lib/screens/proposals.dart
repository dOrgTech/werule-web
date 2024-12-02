import 'package:Homebase/entities/proposal.dart';
import 'package:Homebase/entities/proposal.dart';
import 'package:Homebase/utils/reusable.dart';
import 'package:Homebase/widgets/tokenOps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import '../entities/human.dart';
import '../entities/proposal.dart';
import '../entities/proposal.dart';
import '../entities/proposal.dart';
import '../entities/proposal.dart';
import '../main.dart';
import '../screens/proposalDetails.dart';
import '../utils/theme.dart';
import '../widgets/proposalCard.dart';

import '../entities/org.dart';
import '../widgets/transfer.dart';

class Proposals extends StatefulWidget {
  Proposals(
      {super.key, required this.which, required this.org, this.proposalID});
  String? which = "all";
  int? proposalID;
  late var typesOfProposals;
  List<Widget> proposalCards = [];
  bool executable = false;
  Org org;
  @override
  State<Proposals> createState() => _ProposalsState();
}

class _ProposalsState extends State<Proposals> {
  Proposal p = Proposal(org: orgs[0]);
  String? selectedType = 'All';
  List<String> typesDropdown = [
    'All',
    'Off-Chain',
    'Gov Token Operation',
    'Registry',
    'Transfer',
    'Contract Call',
    'Change Config'
  ];
  String? selectedStatus = 'All';
  final List<String> statusDropdown = [
    'All',
    "active",
    "passed",
    "queued",
    "executable",
    "executed",
    "expired",
    "no quorum",
    "pending",
    "rejected"
  ];
  @override
  void initState() {
    typesDropdown = [
      'All',
      'Off-Chain',
      '${widget.org.symbol} Operation',
      'Registry',
      'Transfer',
      'Contract Call',
      'Change Config'
    ];
    // TODO: implement i
    super.initState();
    widget.which = "all";
  }

  void populateProposals() {
    widget.proposalCards = [];
    widget.org.proposals.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    for (Proposal p in widget.org.proposals) {
      widget.proposalCards.add(ProposalCard(org: widget.org, proposal: p));
    }
    if (widget.proposalCards.isEmpty) {
      widget.proposalCards.add(SizedBox(height: 200));
      widget.proposalCards
          .add(SizedBox(height: 400, child: Center(child: noProposals())));
    }
  }

  @override
  Widget build(BuildContext context) {
    for (Proposal p in widget.org.proposals) {
      if (p.status == "executable") {
        widget.executable = true;
      }
    }
    ;

    populateProposals();
    return widget.proposalID == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("idaos${Human().chain.name}")
                .doc(widget.org.address!)
                .collection("proposals")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Can't retrieve proposals"));
              }
              final docs = snapshot.data!.docs;
              for (var doc in docs) {
                Proposal p = Proposal(
                    org: widget.org, name: doc.data()['title'] ?? "No title");
                p.type = doc.data()['type'];
                p.id = doc.id.toString();
                p.against = doc.data()['against'];
                p.inFavor = doc.data()['inFavor'];
                p.hash = doc.id.toString();
                p.callData = doc.data()['calldata'];
                p.createdAt = (doc.data()['createdAt'] as Timestamp).toDate();
                p.turnoutPercent = doc.data()['turnoutPercent'];
                p.author = doc.data()['author'];
                p.votesFor = doc.data()['votesFor'];
                p.latestState = doc.data()['latestState'];
                p.targets = List<String>.from(doc.data()['targets']);
                p.values = List<String>.from(doc.data()['values']);
                p.votesAgainst = doc.data()['votesAgainst'];
                p.externalResource =
                    doc.data()['externalResource'] ?? "(no external resource)";
                p.description = doc.data()['description'] ?? "no description";
                widget.org.proposals.add(p);
                widget.org.proposalIDs!.add(doc.id);
                var statusHistoryMap =
                    doc['statusHistory'] as Map<String, dynamic>;
                print("before issue");
                p.statusHistory = statusHistoryMap.map((key, value) {
                  return MapEntry(key, (value as Timestamp).toDate());
                });
              }
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    SizedBox(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        const Text("Type:"),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedType,
                          focusColor: Colors.transparent,
                          items: typesDropdown.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedType = newValue;
                            });
                          },
                        ),
                        const SizedBox(width: 40),
                        const Text("Status:"),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedStatus,
                          focusColor: Colors.transparent,
                          items: statusDropdown.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Container(
                                  height: 29,
                                  padding: EdgeInsets.symmetric(vertical: 3),
                                  child: p.statusPill(value, context)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedStatus = newValue;
                            });
                          },
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 18.0),
                          child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                  onPressed: widget.executable
                                      ? () {
                                          //EXECUTE PROPOSAL HERE;
                                        }
                                      : null,
                                  child: const Text("Execute"))),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 50),
                          height: 40,
                          child: ElevatedButton(
                            child: Text(
                              "Create Proposal",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColorDark),
                            ),
                            style: ButtonStyle(
                                elevation: MaterialStatePropertyAll(0.0),
                                backgroundColor: MaterialStatePropertyAll(
                                    Theme.of(context).indicatorColor)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 18.0),
                                      child: Text("Select a proposal type"),
                                    ),
                                    content: ProposalList(org: widget.org),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    )),
                    SizedBox(height: 40),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Container(
                                  padding: EdgeInsets.only(left: 15),
                                  width: 60,
                                  child: Text("ID #")),
                            ),
                            Expanded(
                              child: Container(
                                  width: 230,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 48.0),
                                    child: Text("Title"),
                                  )),
                            ),
                            Container(
                                width: 230,
                                child: Center(child: Text("Author"))),
                            SizedBox(
                                width: 150,
                                child: Center(child: Text("▼ Posted"))),
                            SizedBox(
                                width: 150,
                                child: Center(child: Text("Type "))),
                            SizedBox(
                                width: 100,
                                child: Center(child: Text("Status "))),
                          ],
                        ),
                      ),
                    ),
                    ...widget.proposalCards
                  ],
                ),
              );
            })
        : ProposalDetails(
            p: widget.org.proposals.firstWhere(
            (proposal) => proposal.id == widget.proposalID,
            // Returns null if no matching proposal is found
          ));
  }

  Widget noProposals() {
    return Center(
      child: SizedBox(
          height: 400,
          child: Text("No proposals here",
              style: TextStyle(fontSize: 20, color: Colors.grey))),
    );
  }
}

class ProposalList extends StatefulWidget {
  final Org org;
  late Proposal p;
  late var typesOfProposals;
  late var nProposalWidgets;

  ProposalList({super.key, required this.org});

  @override
  State<ProposalList> createState() => ProposalListState();
}

class ProposalListState extends State<ProposalList> {
  @override
  Widget build(BuildContext context) {
    var pTypes = {
      "Off-Chain Debate":
          "Post a thesis and have tokenized arguments around it",
      "Transfer Assets": "from the DAO Treasury\nto another account",
      "Edit Registry": "Change an entry\nor add a new one",
      "Contract Call": "Call any function\non any contract",
      "DAO Configuration":
          "Change the quorum,\nthe proposal durations\nor the treasury address",
    };

    newProposalWidgets.addAll({
      '${widget.org.symbol} Operation': (Org org, Proposal p, State state) =>
          GovernanceTokenOperationsWidget(
            org: org,
            p: p,
            proposalsState: state,
          )
    });
    pTypes.addAll({
      '${widget.org.symbol} Operation':
          "Mint, burn, lock or unlock ${widget.org.symbol} tokens"
    });

    widget.p = Proposal(org: widget.org);
    widget.p.author =
        Human().address ?? "0xc5C77EC5A79340f0240D6eE8224099F664A08EEb";
    widget.p.callData = "0x";
    widget.p.status = "pending";
    List<Widget> propuneri = [];
    for (String item in pTypes.keys) {
      propuneri.add(Card(
        child: Container(
          color: Theme.of(context).hoverColor,
          padding: EdgeInsets.all(3),
          width: 300,
          height: 160,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Text(item.toString()),
                    ),
                    content:
                        newProposalWidgets[item]!(widget.org, widget.p, this),
                  );
                },
              );
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      item,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 19),
                    ),
                    Text(
                      pTypes[item]!,
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
    }

    var marime = MediaQuery.of(context).size;
    return SizedBox(
        width: MediaQuery.of(context).size.aspectRatio > 1
            ? marime.width / 2
            : marime.width * 0.9,
        height: MediaQuery.of(context).size.aspectRatio > 1
            ? marime.height / 1.4
            : marime.height * 0.9,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Learn about the different types of proposals ",
                        style: TextStyle(fontSize: 13),
                      ),
                      OldSchoolLink(
                          text: "here",
                          url: "https://example.com",
                          textStyle: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).indicatorColor)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 52,
                ),
                Center(
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    children: propuneri,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
