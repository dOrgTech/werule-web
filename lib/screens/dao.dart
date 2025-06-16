import 'package:Homebase/screens/bridge.dart';
import 'package:Homebase/screens/uni_bridge.dart';
import 'package:Homebase/widgets/footer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../entities/human.dart';
import '../entities/token.dart';
import '../screens/account.dart';
import '../screens/proposalDetails.dart';
import '../screens/proposals.dart';
import '../screens/registry.dart';
import '../widgets/menu.dart';
import '../entities/org.dart';
import 'debateDetails.dart';
import 'home.dart';
import 'members.dart';
import 'bridge_screen_placeholder.dart'; // Import the placeholder

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

class _DAOState extends State<DAO> with TickerProviderStateMixin { // Add TickerProviderStateMixin
  TabController? _tabController;
  List<Widget> _tabs = [];
  List<Widget> _tabViews = [];
  bool _showBridgeTab = false;

  @override
  void initState() {
    super.initState();
    print("DAO initState: proposalHash: ${widget.proposalHash}");
    // Initial setup of tabs will be done in the StreamBuilder's builder,
    // as we need the 'dao' object from the stream to check 'wrapped'.
    // However, we can check widget.org.wrapped here if it's reliably populated
    // by the time DAO widget is constructed.
    // For safety, let's defer tab setup to where 'dao' from stream is available.
  }

  void _setupTabs(Org dao) {
    _showBridgeTab = (dao.wrapped != null && dao.wrapped!.isNotEmpty);
    print("[DAO _setupTabs] Org '${dao.name}', wrapped: '${dao.wrapped}', _showBridgeTab: $_showBridgeTab");

    _tabs = [
      menuItem(MenuItem("Overview", const Icon(Icons.dashboard))),
      menuItem(MenuItem("Proposals", const Icon(Icons.front_hand))),
      menuItem(MenuItem("Registry", const Icon(Icons.list))),
      menuItem(MenuItem("Members", const Icon(Icons.people))),
      menuItem(MenuItem("Account", const Icon(Icons.person))),
    ];

    _tabViews = [
      Home(org: dao),
      widget.proposalHash == null
          ? Center(child: Proposals(which: "all", org: dao))
          : Center(child: _buildProposalOrDebateDetailsView(dao)),
      Center(child: Registry(org: dao)),
      Center(child: Members(org: dao)),
      Center(child: Account(org: dao)),
    ];

    if (_showBridgeTab) {
      _tabs.add(menuItem(MenuItem("Bridge", const Icon(Icons.swap_horiz))));
      _tabViews.add( Bridge(org: widget.org));
    }

    // Dispose existing controller if it exists and length changes
    if (_tabController != null && _tabController!.length != _tabs.length) {
      _tabController!.dispose();
      _tabController = null;
    }

    if (_tabController == null) {
      _tabController = TabController(
        length: _tabs.length,
        vsync: this,
        initialIndex: widget.InitialTabIndex < _tabs.length ? widget.InitialTabIndex : 0,
      );
    } else {
      // If controller exists and length is same, just ensure index is valid
      if (widget.InitialTabIndex >= _tabs.length && _tabController!.index >= _tabs.length) {
         _tabController!.index = 0;
      } else if (widget.InitialTabIndex < _tabs.length) {
        _tabController!.index = widget.InitialTabIndex;
      }
    }
     // Add listener to handle tab changes if needed, e.g., for deep linking updates
    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        // Handle tab change, e.g., update URL or state
        print("Switched to tab: ${_tabController!.index}");
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Widget _buildProposalOrDebateDetailsView(Org dao) {
    // This logic was previously directly in the TabBarView.
    // It's extracted for clarity.
    return FutureBuilder(
        future: dao.getProposals(), // Assuming getProposals populates dao.proposals and dao.debates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SizedBox(width: 100, height: 100, child: CircularProgressIndicator()));
          }
          // After future completes, check proposals and debates
          if (dao.proposals.any((proposal) => proposal.id == widget.proposalHash)) {
            return ProposalDetails(
              p: dao.proposals.firstWhere((proposal) => proposal.id == widget.proposalHash),
            );
          } else if (dao.debates.any((debate) => debate.hash == widget.proposalHash)) {
            return DebateDetails(
              debate: dao.debates.firstWhere((debate) => debate.hash == widget.proposalHash),
            );
          }
          return Proposals(which: "all", org: dao); // Fallback if no specific hash or match
        });
  }


  @override
  Widget build(BuildContext context) {
    widget.org.proposals = [];
    final stream = FirebaseFirestore.instance
        .collection("idaos${Human().chain.name}")
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

      // Populate the 'wrapped' field from 'underlying'
      var wrappedValue = data['underlying']; // CHANGED 'wrapped' to 'underlying'
      if (wrappedValue is String) {
        dao.wrapped = wrappedValue;
        print("[DAO StreamBuilder] Org '${dao.name}' - FOUND A WRAPPED TOKEN string from 'underlying': ${dao.wrapped}");
      } else {
        dao.wrapped = null;
        if (wrappedValue != null) {
          print("[DAO StreamBuilder] Org '${dao.name}' - Firestore field 'underlying' was not null but was not a String. Type: ${wrappedValue.runtimeType}, Value: $wrappedValue");
        }
      }
      // It's important that widget.org is also updated if the streamed 'dao' is what drives the UI.
      // Or, ensure that 'dao' from the stream is consistently used.
      // For now, _setupTabs will use the 'dao' from the stream.

      // Perform the async task before yielding

      dao.getMembers();
      dao.debatesOnly = false;
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
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, size: 48),
                    SizedBox(height: 16),
                    Text("No data received from the stream"),
                  ],
                ),
              );
            }
            if (snapshot.data == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 48),
                    SizedBox(height: 16),
                    Text("DAO not found or connection error"),
                  ],
                ),
              );
            }

            final dao = snapshot.data!; // This is the Org object from the stream
            dao.debatesOnly ??= dao.name.contains("dOrg"); // Corrected from "Org" to "dOrg" as in main.dart

            // Setup tabs based on the freshly streamed 'dao' object
            // This ensures _tabController is initialized/updated when data changes
            _setupTabs(dao);


            if (_tabController == null) {
              // This case should ideally not happen if _setupTabs is called correctly.
              return const Center(child: Text("TabController not initialized."));
            }

            return dao.debatesOnly! ? debatesWide(dao, _tabController!) : fullWide(dao, _tabController!);
          }),
    );
  }

  debatesWide(Org dao, TabController tabController) { // Pass TabController
    // For debatesWide, we are not adding the Bridge tab for now.
    // If needed, similar logic to fullWide would be applied.
    // Ensure the length of DefaultTabController matches the actual tabs for debates.
    // Current tabs: Overview, Debates, Members, Account (length 4)
    return Container(
      alignment: Alignment.topCenter,
      child: DefaultTabController( // This DefaultTabController might conflict if _tabController is also used.
                                  // It's better to use the _tabController passed from the state.
        initialIndex: widget.InitialTabIndex < 4 ? widget.InitialTabIndex : 0,
        length: 4, // Fixed length for debates view
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 2),
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
                    controller: tabController, // Use the passed controller
                    tabs: [ // Tabs for debates view
                      menuItem(MenuItem("Overview", const Icon(Icons.dashboard))),
                      menuItem(MenuItem("Debates", const Icon(Icons.forum))),
                      menuItem(MenuItem("Members", const Icon(Icons.people))),
                      menuItem(MenuItem("Account", const Icon(Icons.person))),
                    ],
                  ),
                ),
                Container(
                  height: 1000, // Consider making this more dynamic or using Expanded
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: TabBarView(
                    controller: tabController, // Use the passed controller
                    children: [ // Views for debates view
                      Home(org: dao),
                      widget.proposalHash == null
                          ? Center(child: Proposals(which: "all", org: dao))
                          : Center(child: _buildProposalOrDebateDetailsView(dao)), // Use helper
                      Center(child: Members(org: dao)),
                      Center(child: Account(org: dao)),
                    ],
                  ),
                ),
              ],
            ), // End of Column

            const Footer()
          ],
        ),
      ), // End of ListView
    );
  }

  fullWide(Org dao, TabController tabController) { // Pass TabController
    // _setupTabs(dao) should have already been called by the StreamBuilder
    // and _tabController (which is passed as tabController here) should be initialized.

    return Container(
      alignment: Alignment.topCenter,
      // No DefaultTabController needed here, as we are using the state's _tabController
      child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 2),
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
                    controller: tabController, // Use the state's TabController
                    tabs: _tabs, // Use the dynamically built _tabs list
                    // isScrollable: _tabs.length > 5, // Make scrollable if many tabs
                  ),
                ),
                Container(
                  height: 1000, // Consider making this more dynamic
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: TabBarView(
                    controller: tabController, // Use the state's TabController
                    children: _tabViews, // Use the dynamically built _tabViews list
                  ),
                ),
              ],
            ), // End of Column

            const Footer()
          ],
        ), // End of ListView
    // Removed extra parenthesis and semicolon that might have been here.
    // The Container for fullWide ends here.
    );
  } // This closes fullWide method

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
