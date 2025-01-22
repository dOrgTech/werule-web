import 'package:Homebase/entities/proposal.dart';
import 'package:Homebase/utils/reusable.dart';
import 'package:Homebase/widgets/debate_card.dart';
import 'package:Homebase/widgets/initiative.dart';
import 'package:Homebase/widgets/tokenOps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import '../debates/models/debate.dart';
import '../entities/human.dart';
import '../entities/proposal.dart';
import '../main.dart';
import '../screens/proposalDetails.dart';
import '../utils/theme.dart';
import '../widgets/proposalCard.dart';
import '../entities/org.dart';
import '../widgets/transfer.dart';
import 'dart:html' as html;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

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
    'Debate',
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
      'Debate',
      '${widget.org.symbol} Operation',
      'Registry',
      'Transfer',
      'Contract Call',
      'Change Config'
    ];

    super.initState();
    widget.which = "all";
  }

  void populateProposals() {
    widget.proposalCards = [];
    widget.org.proposals.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    for (Proposal p in widget.org.proposals) {
      widget.proposalCards.add(ProposalCard(org: widget.org, proposal: p));
    }
    for (Debate d in widget.org.debates) {
      print("adding a debate to the list of proposals");
      widget.proposalCards.add(DebateCard(org: widget.org, debate: d));
    }
    if (widget.proposalCards.isEmpty) {
      widget.proposalCards.add(const SizedBox(height: 200));
      widget.proposalCards
          .add(SizedBox(height: 400, child: Center(child: noProposals())));
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.proposalCards = [];
    for (Proposal p in widget.org.proposals) {
      if (p.status == "executable") {
        widget.executable = true;
      }
    }
    ;

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
              widget.org.proposals
                  .clear(); // Clear existing proposals to avoid duplication
              widget.org.proposalIDs!
                  .clear(); // Clear existing IDs if necessary
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
                p.status = doc.data()['latestStage'];
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
              populateProposals();
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  child: p.statusPill(value, context)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedStatus = newValue;
                              widget.proposalCards = [];
                            });
                          },
                        ),
                        const Spacer(),
                        Container(
                            padding: const EdgeInsets.only(right: 50),
                            height: 40,
                            child: ElevatedButton(
                              child: Text(
                                "Create Proposal",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColorDark),
                              ),
                              style: ButtonStyle(
                                elevation: const MaterialStatePropertyAll(0.0),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return Colors.grey;
                                  }
                                  return Theme.of(context).indicatorColor;
                                }),
                              ),
                              onPressed: false
                                  // Human().address == null
                                  ? null
                                  : () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                              content:
                                                  Initiative(org: widget.org));
                                        },
                                      );
                                    },
                            )),
                      ],
                    )),
                    const SizedBox(height: 40),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Container(
                                  padding: const EdgeInsets.only(left: 15),
                                  width: 60,
                                  child: const Text("ID #")),
                            ),
                            Expanded(
                              child: Container(
                                  width: 230,
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 48.0),
                                    child: Text("Title"),
                                  )),
                            ),
                            Container(
                                width: 230,
                                child: const Center(child: Text("Author"))),
                            const SizedBox(
                                width: 150,
                                child: Center(child: Text("▼ Posted"))),
                            const SizedBox(
                                width: 150,
                                child: Center(child: Text("Type "))),
                            const SizedBox(
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
    return const Center(
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
  InitiativeState initiativeState;
  bool showingCsv = false;
  late var typesOfProposals;
  late var nProposalWidgets;

  ProposalList({super.key, required this.org, required this.initiativeState});

  @override
  State<ProposalList> createState() => ProposalListState();
}

class ProposalListState extends State<ProposalList> {
  bool isCsvUploaded = false;
  bool isParsingCsv = false;
  callParent(element) {
    widget.initiativeState.setState(() {
      widget.initiativeState.widget.proposalType = element;
    });
  }

  Future<void> _loadCsvFile() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.csv';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.length == 1) {
        final file = files[0];
        final reader = html.FileReader();

        reader.onLoadEnd.listen((e) async {
          final contents = reader.result as String;
          setState(() => isParsingCsv = true);

          List<Txaction> entries = await _parseCsvInBackground(contents);

          setState(() {
            //DO SOMETHING WITH THE entries
            isCsvUploaded = true;
            isParsingCsv = false;
          });
        });

        reader.readAsText(file);
      }
    });
  }

  Future<List<Txaction>> _parseCsvInBackground(String fileContent) async {
    return compute(_processCsvData, fileContent);
  }

  static List<Txaction> _processCsvData(String fileContent) {
    List<Txaction> entries = [];
    List<String> lines = fileContent
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.isNotEmpty) {
      lines.removeAt(0); // Remove header line

      for (var line in lines) {
        List<String> values = line.split(',');
        if (values.length >= 2) {
          String asset = values[0].trim();
          String amount = values[1].trim();
          String recipient = values[2].trim();

          entries.add(Txaction(
            calldata: asset,
            target: asset,
            value: amount,
          ));
        }
      }
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    var pTypes = {
      "Transfer Assets": "from the DAO Treasury\nto another account",
      "Edit Registry": "Change an entry\nor add a new one",
      "Contract Call": "Call any function\non any contract",
      "DAO Configuration":
          "Change the quorum,\nthe proposal durations\nor the treasury address",
    };
    var proposalIcons = {
      "Debate": Icons.forum_outlined, // Represents discussion or debate
      "Transfer Assets":
          Icons.attach_money_outlined, // Symbolizes monetary transactions
      "Edit Registry":
          Icons.list_alt_outlined, // Clearly indicates editing functionality
      "Contract Call": Icons.link_outlined, // Represents linking or connecting
      "DAO Configuration":
          Icons.settings_outlined, // Suits configuration and settings
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
        elevation: 2.4,
        child: Tooltip(
          decoration: BoxDecoration(color: Theme.of(context).canvasColor),
          message: "",
          textStyle: const TextStyle(
            fontSize: 30,
            color: Color.fromARGB(255, 216, 216, 216),
          ),
          child: Container(
            color: Theme.of(context).hoverColor,
            padding: const EdgeInsets.all(3),
            width: 300,
            height: 160,
            child: TextButton(
              onPressed: () {
                callParent(
                    newProposalWidgets[item]!(widget.org, widget.p, this));
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(proposalIcons[item] ?? Icons.transform,
                              size: 30,
                              color: Theme.of(context).indicatorColor),
                          const SizedBox(width: 10),
                          Text(
                            item,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 19,
                                color: Theme.of(context).indicatorColor),
                          ),
                        ],
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
        ),
      ));
    }
    propuneri.add(OrContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 220,
            child: ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStatePropertyAll(12),
                  backgroundColor:
                      MaterialStateProperty.all(createMaterialColor(
                    Color.fromARGB(255, 175, 215, 218),
                  )),
                ),
                onPressed: () async {
                  await _loadCsvFile();
                  setState(() {
                    widget.showingCsv = true;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload,
                        color: Color.fromARGB(255, 37, 37, 37)),
                    const Text(
                      " Upload Executions",
                      style: TextStyle(
                          fontSize: 15, color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ],
                )),
          ),
          const SizedBox(height: 38),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Download ",
                style: TextStyle(fontSize: 13),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "example CSV",
                    style: TextStyle(
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      color: Color.fromARGB(235, 168, 216, 255),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    ));

    var marime = MediaQuery.of(context).size;
    return widget.showingCsv
        ? SizedBox(child: Container())
        : SizedBox(
            width: MediaQuery.of(context).size.aspectRatio > 1
                ? marime.width / 2
                : marime.width * 0.9,
            height: MediaQuery.of(context).size.height - 230,
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
                          const Text(
                            "Implementing OpenZeppelin's Governor framework. Learn more about it ",
                            style: TextStyle(fontSize: 13),
                          ),
                          OldSchoolLink(
                              text: "here",
                              url:
                                  "https://docs.openzeppelin.com/contracts/5.x/api/governance",
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

class OrContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final double interruptionWidth;
  final double interruptionHeight;

  const OrContainer({
    Key? key,
    required this.child,
    this.margin = const EdgeInsets.all(16.0),
    this.interruptionWidth = 50.0,
    this.interruptionHeight = 80.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main container with fading background
        Container(
          height: 158,
          margin: const EdgeInsets.only(left: 12, right: 12, top: 6),
          width: 280,
          decoration: BoxDecoration(
            border: Border.fromBorderSide(
              BorderSide(color: Color.fromARGB(183, 104, 104, 104), width: 0.5),
            ),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color.fromARGB(80, 70, 67, 67)],
                )),
            child: child,
          ),
        ),
        // "OR" interruption
        // Positioned(
        //   top: margin.top - 14,
        //   left: 3,
        //   child: Container(
        //     width: interruptionWidth,
        //     height: 24,
        //     alignment: Alignment.center,
        //     color: Theme.of(context).canvasColor,
        //     child: const Text(
        //       "OR",
        //       style: TextStyle(
        //         color: Color.fromARGB(255, 255, 255, 255),
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
