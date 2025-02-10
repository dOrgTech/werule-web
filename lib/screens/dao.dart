import 'package:Homebase/widgets/footer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import '../entities/human.dart';
import '../entities/token.dart';
import '../screens/account.dart';
import '../screens/proposalDetails.dart';
import '../screens/proposals.dart';
import '../screens/registry.dart';
import '../screens/treasury.dart';
import '../widgets/footer.dart';
import '../widgets/membersList.dart';
import '../widgets/menu.dart';
import '../entities/org.dart';
import 'debateDetails.dart';
import 'home.dart';
import 'members.dart';

class DAO extends StatefulWidget {
  DAO(
      {super.key,
      this.InitialTabIndex = 0,
      required this.org,
      this.proposalHash});
  int InitialTabIndex;
  String? proposalHash;
  Org org;
  @override
  State<DAO> createState() => _DAOState();
}

class _DAOState extends State<DAO> {
  @override
  void initState() {
    super.initState();
    print(widget.proposalHash);
  }

  @override
  Widget build(BuildContext context) {
    widget.org.proposals = [];
    final stream = FirebaseFirestore.instance
        .collection("idaosEtherlink-Testnet")
        .doc(widget.org.address!)
        .snapshots()
        .asyncMap((snapshot) async {
      if (!snapshot.exists) return null;
      final data = snapshot.data() as Map<String, dynamic>;
      Org dao = Org(
        name: data['name'],
        description: data['description'],
        govTokenAddress: data['govTokenAddress'],
      );
      dao.address = data['address'];
      dao.symbol = data['symbol'];
      dao.creationDate = (data['creationDate'] as Timestamp).toDate();
      dao.govToken = Token(
          type: "erc20",
          symbol: dao.symbol!,
          decimals: data['decimals'],
          name: dao.name);
      dao.govTokenAddress = data['token'];
      dao.proposalThreshold = data['proposalThreshold'];
      dao.votingDelay = data['votingDelay'];
      dao.registryAddress = data['registryAddress'];
      dao.treasuryAddress = dao.registryAddress;
      dao.votingDuration = data['votingDuration'];
      dao.executionDelay = data['executionDelay'];
      dao.quorum = data['quorum'];
      dao.decimals = data['decimals'];
      dao.holders = data['holders'];
      // dao.treasuryMap = Map<String, String>.from(data['treasury']);
      dao.registry = Map<String, String>.from(data['registry']);
      dao.totalSupply = data['totalSupply'];
      // Perform the async task before yielding

      dao.getMembers();
      if (dao.name.contains("Org")) {
        dao.debatesOnly = true;
      } else {
        dao.debatesOnly = false;
      }
      // await dao.getProposals();
      return dao;
    });

    return Scaffold(
      appBar: const TopMenu(),
      body: StreamBuilder<Org?>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            if (!snapshot.hasData) {
              return Center(child: const Text("No internet connection..."));
            }

            final dao = snapshot.data!;
            return dao.debatesOnly! ? debatesWide(dao) : fullWide(dao);
          }),
    );
  }

  debatesWide(dao) {
    return Container(
      alignment: Alignment.topCenter,
      child: DefaultTabController(
        initialIndex: widget.InitialTabIndex,
        length: 4,
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize
                  .min, // Set this property to make the column fit its children's size vertically
              children: [
                // LinearProgressIndicator(
                //   color: Theme.of(context).indicatorColor.withOpacity(0.3),
                //   minHeight: 7,
                // ),
                Container(
                  alignment: Alignment.topCenter,
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 1200),
                  height: 50,
                  color: Theme.of(context).cardColor,
                  child: TabBar(
                    tabs: [
                      menuItem(MenuItem("Overview", Icon(Icons.dashboard))),
                      menuItem(MenuItem("Debates", const Icon(Icons.forum))),
                      // menuItem(MenuItem("Treasury",const Icon(Icons.money))),
                      menuItem(MenuItem("Members", const Icon(Icons.people))),
                      menuItem(MenuItem("Account", const Icon(Icons.person))),
                    ],
                  ),
                ),
                Container(
                  height: 1000,
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 1200),
                  // Expanded start
                  child: TabBarView(
                    // TabBarView start
                    children: [
                      Home(org: dao),
                      widget.proposalHash == null
                          ? Center(child: Proposals(which: "all", org: dao))
                          : Center(
                              child: FutureBuilder(
                                  future: widget.org.getProposals(),
                                  builder: (context, snapshot) {
                                    return snapshot.connectionState ==
                                            ConnectionState.waiting
                                        ? Center(
                                            child: SizedBox(
                                                width: 100,
                                                height: 100,
                                                child:
                                                    CircularProgressIndicator()))
                                        : widget.org.proposals.any((proposal) =>
                                                proposal.id ==
                                                widget.proposalHash)
                                            ? ProposalDetails(
                                                p: widget.org.proposals
                                                    .firstWhere(
                                                  (proposal) =>
                                                      proposal.id ==
                                                      widget.proposalHash,
                                                ),
                                              )
                                            : widget.org.debates.any((debate) =>
                                                    debate.hash ==
                                                    widget.proposalHash)
                                                ? DebateDetails(
                                                    debate: widget.org.debates
                                                        .firstWhere(
                                                      (debate) =>
                                                          debate.hash ==
                                                          widget.proposalHash,
                                                    ),
                                                  )
                                                : Center(
                                                    child: Text(
                                                        'No matching Proposal or Debate found'),
                                                  );
                                  }),
                            ),
                      Center(child: Members(org: dao)),
                      Center(child: Account(org: dao)),
                    ],
                  ), // TabBarView end
                ),
              ],
            ), // End of Column

            Footer()
          ],
        ),
      ), // End of ListView
    );
  }

  fullWide(dao) {
    return Container(
      alignment: Alignment.topCenter,
      child: DefaultTabController(
        initialIndex: widget.InitialTabIndex,
        length: 5,
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize
                  .min, // Set this property to make the column fit its children's size vertically
              children: [
                // LinearProgressIndicator(
                //   color: Theme.of(context).indicatorColor.withOpacity(0.3),
                //   minHeight: 7,
                // ),
                Container(
                  alignment: Alignment.topCenter,
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 1200),
                  height: 50,
                  color: Theme.of(context).cardColor,
                  child: TabBar(
                    tabs: [
                      menuItem(MenuItem(
                          "Overview",
                          Icon(
                            Icons.dashboard,
                          ))),

                      menuItem(
                          MenuItem("Proposals", const Icon(Icons.front_hand))),
                      // menuItem(MenuItem("Treasury",const Icon(Icons.money))),
                      menuItem(MenuItem("Registry", const Icon(Icons.list))),
                      menuItem(MenuItem("Members", const Icon(Icons.people))),
                      menuItem(MenuItem("Account", const Icon(Icons.person))),
                    ],
                  ),
                ),
                Container(
                  height: 1000,
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 1200),
                  // Expanded start
                  child: TabBarView(
                    // TabBarView start
                    children: [
                      Home(org: dao),
                      widget.proposalHash == null
                          ? Center(child: Proposals(which: "all", org: dao))
                          : Center(
                              child: FutureBuilder(
                                  future: widget.org.getProposals(),
                                  builder: (context, snapshot) {
                                    return snapshot.connectionState ==
                                            ConnectionState.waiting
                                        ? Center(
                                            child: SizedBox(
                                                width: 100,
                                                height: 100,
                                                child:
                                                    CircularProgressIndicator()))
                                        : widget.org.proposals.any((proposal) =>
                                                proposal.id ==
                                                widget.proposalHash)
                                            ? ProposalDetails(
                                                p: widget.org.proposals
                                                    .firstWhere(
                                                  (proposal) =>
                                                      proposal.id ==
                                                      widget.proposalHash,
                                                ),
                                              )
                                            : widget.org.debates.any((debate) =>
                                                    debate.hash ==
                                                    widget.proposalHash)
                                                ? DebateDetails(
                                                    debate: widget.org.debates
                                                        .firstWhere(
                                                      (debate) =>
                                                          debate.hash ==
                                                          widget.proposalHash,
                                                    ),
                                                  )
                                                : Center(
                                                    child: Text(
                                                        'No matching Proposal or Debate found'),
                                                  );
                                  }),
                            ),
                      // Center(child: Treasury()),
                      Center(child: Registry(org: dao)),
                      Center(child: Members(org: dao)),
                      Center(child: Account(org: dao)),
                    ],
                  ), // TabBarView end
                ),
              ],
            ), // End of Column

            Footer()
          ],
        ),
      ), // End of ListView
    );
  }

  menuItem(MenuItem id) {
    return Tab(
        child: Center(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        id.icon,
        const SizedBox(width: 8),
        Text(
          id.name,
          style: const TextStyle(fontSize: 18),
        ),
      ]),
    ));
  }
}

class MenuItem {
  String name;
  Widget icon;
  Widget? content;
  MenuItem(this.name, this.icon);
}
