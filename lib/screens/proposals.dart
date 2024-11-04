import 'package:Homebase/widgets/tokenOps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import '../entities/human.dart';
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

  List<Widget> proposalCards = [];
  void populateProposals() {
    proposalTypes.addAll({
      '${widget.org.symbol} Operation':
          "Mint, burn, lock or unlock ${widget.org.symbol} tokens"
    });

    newProposalWidgets.addAll({
      '${widget.org.symbol} Operation': (Org org, Proposal p, State state) =>
          GovernanceTokenOperationsWidget(
            org: org,
            p: p,
            proposalsState: state,
          )
    });
    widget.org.proposals.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    for (Proposal p in widget.org.proposals) {
      proposalCards.add(ProposalCard(org: widget.org, proposal: p));
    }
    if (proposalCards.isEmpty) {
      proposalCards.add(SizedBox(height: 200));
      proposalCards
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
    proposalCards = [];
    populateProposals();
    return widget.proposalID == null
        ? Container(
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
                                  padding: const EdgeInsets.only(left: 18.0),
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
                              width: 90,
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
                            width: 230, child: Center(child: Text("Author"))),
                        SizedBox(
                            width: 150, child: Center(child: Text("Posted"))),
                        SizedBox(
                            width: 150, child: Center(child: Text("Type "))),
                        SizedBox(
                            width: 100, child: Center(child: Text("Status "))),
                      ],
                    ),
                  ),
                ),
                ...proposalCards
              ],
            ),
          )
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
  ProposalList({super.key, required this.org});

  @override
  State<ProposalList> createState() => ProposalListState();
}

class ProposalListState extends State<ProposalList> {
  @override
  Widget build(BuildContext context) {
    widget.p = Proposal(org: widget.org);
    widget.p.author =
        Human().address ?? "0xc5C77EC5A79340f0240D6eE8224099F664A08EEb";
    widget.p.callData = "0x";
    widget.p.status = "pending";
    List<Widget> propuneri = [];
    for (String item in proposalTypes.keys) {
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
                      proposalTypes[item]!,
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
                        "Learn about the different types of Homebase proposals ",
                        style: TextStyle(fontSize: 12),
                      ),
                      Text("here.",
                          style: TextStyle(
                              color: Theme.of(context).indicatorColor,
                              fontSize: 12)),
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
