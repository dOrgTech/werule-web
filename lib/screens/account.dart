import 'dart:typed_data';
// import 'package:Homebase/screens/bridge.dart'; // Comment out or remove old Bridge import
import 'package:Homebase/widgets/governance_token_bridge_widget.dart'; // Import the new widget
// import 'package:Homebase/screens/creator.dart';
import 'package:Homebase/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Removed import if no longer needed
import '../entities/human.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';
import '../utils/reusable.dart';
import '../widgets/dboxes.dart';
import '../widgets/proposalCard.dart';
// import 'applefarm.dart';
Color listTitleColor = const Color.fromARGB(255, 211, 211, 211);

class Account extends StatefulWidget {
  Account({super.key, this.member, required this.org});

  List<Widget> createdProposals = [];
  List<Widget> votedOnProposals = [];
  Member? member;
  Org org;
  @override
  State<Account> createState() => AccountState();
}

class AccountState extends State<Account> {
  Future<Member?>? _accountDataFuture;

  @override
  void initState() {
    super.initState();
    if (Human().address != null) {
      // Initial member setup, will be fully refreshed by _loadAccountAndMemberData
      widget.member = widget.org.memberAddresses[Human().address!.toLowerCase()] ??
          Member(address: Human().address!, personalBalance: "0");
      _accountDataFuture = _loadAccountAndMemberData();
    }
  }

  Future<Member?> _loadAccountAndMemberData() async {
    print("[AccountState] _loadAccountAndMemberData: Starting data load for user ${Human().address} in org ${widget.org.name}.");
    
    // Step 1: Ensure proposals for the organization are loaded.
    await widget.org.getProposals(); // This populates widget.org.proposals AND calls widget.org.getMembers()
    print("[AccountState] _loadAccountAndMemberData: widget.org.getProposals() completed. Found ${widget.org.proposals.length} org proposals. Found ${widget.org.memberAddresses.length} member addresses.");

    // Re-assign widget.member using the now-populated widget.org.memberAddresses.
    // This ensures we use the Member instance from the Org's list if available,
    // which might have been partially populated by getHolders (called within getMembers).
    if (Human().address != null) {
        String userAddressLower = Human().address!.toLowerCase();
        // Try to get the member from the org's list first
        Member? existingMemberFromOrg = widget.org.memberAddresses[userAddressLower];
        
        if (existingMemberFromOrg != null) {
            widget.member = existingMemberFromOrg;
            print("[AccountState] _loadAccountAndMemberData: Member $userAddressLower found in org.memberAddresses. Using this instance.");
        } else {
            // If not found in org.memberAddresses (e.g., new user or not yet a token holder),
            // ensure widget.member is a valid new instance if it was null, or keep existing if already initialized by initState.
            if (widget.member == null || widget.member!.address.toLowerCase() != userAddressLower) {
                 print("[AccountState] _loadAccountAndMemberData: Member $userAddressLower not found in org.memberAddresses. Creating/assigning new Member instance.");
                 widget.member = Member(address: Human().address!, personalBalance: "0");
            } else {
                 print("[AccountState] _loadAccountAndMemberData: Member $userAddressLower not in org.memberAddresses, but widget.member already initialized with this address. Proceeding.");
            }
        }
    } else {
        // Human().address is null, so no member can be determined.
        widget.member = null;
    }

    if (widget.member == null || widget.member!.address.isEmpty) {
        print("[AccountState] _loadAccountAndMemberData: Member object is null or has empty address after attempting to source/initialize. Cannot proceed.");
        return null;
    }
    
    // Step 2: Refresh the specific member's data using the (potentially) updated widget.member instance.
    Member refreshedMember = await widget.org.refreshMember(widget.member!);
    widget.member = refreshedMember;
    print("[AccountState] _loadAccountAndMemberData: widget.org.refreshMember() completed. Member has ${widget.member?.proposalsVoted.length ?? 0} voted proposals (from member object).");
    
    // Step 3: Populate createdProposals (must be after widget.org.getProposals())
    widget.createdProposals = [];
    if (Human().address != null) {
      for (Proposal p in widget.org.proposals) { // Uses the now-populated list
        if (p.author?.toLowerCase() == Human().address!.toLowerCase()) {
          widget.createdProposals.add(ProposalCard(
            proposal: p,
            org: widget.org,
          ));
        }
      }
    }
    print("[AccountState] _loadAccountAndMemberData: Populated ${widget.createdProposals.length} created proposal cards.");

    // Step 4: Populate votedOnProposals (must be after widget.org.refreshMember())
    widget.votedOnProposals = [];
    if (widget.member != null) {
        for (Proposal p in widget.member!.proposalsVoted) { // Uses the now-populated list from refreshed member
            widget.votedOnProposals.add(ProposalCard( // Reverted to simple instantiation
            proposal: p,
            org: widget.org,
            ));
        }
    }
    print("[AccountState] _loadAccountAndMemberData: Populated ${widget.votedOnProposals.length} voted on proposal cards.");

    if (mounted) {
      setState(() {}); // Trigger a rebuild if necessary, though FutureBuilder handles this.
    }
    return widget.member;
  }

  @override
  Widget build(BuildContext context) {
    if (Human().address == null) {
      return notSignedin();
    }

    // If _accountDataFuture wasn't set in initState (e.g. user signed in after), set it now.
    if (_accountDataFuture == null) {
        widget.member = widget.org.memberAddresses[Human().address!.toLowerCase()] ??
             Member(address: Human().address!, personalBalance: "0");
        _accountDataFuture = _loadAccountAndMemberData();
    }

    return FutureBuilder<Member?>(
      future: _accountDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
                width: 140.0,
                height: 140.0,
                child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          print("[AccountScreen] FutureBuilder error: ${snapshot.error}\nStackTrace: ${snapshot.stackTrace}");
          return Center(child: Text("Error loading account data: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          print("[AccountScreen] FutureBuilder: No data or null member. Human address: ${Human().address}. Snapshot data: ${snapshot.data}");
          return notSignedin(); // Or a more specific "member data not available"
        }
        
        // widget.member is now snapshot.data, which is refreshed.
        // widget.createdProposals and widget.votedOnProposals are populated by _loadAccountAndMemberData.
        
        print("[AccountScreen Build Inner] Using createdProposals count: ${widget.createdProposals.length}");
        print("[AccountScreen Build Inner] Using votedOnProposals count: ${widget.votedOnProposals.length}");
        print("[AccountScreen Build Inner] Member balance: ${widget.member?.personalBalance}");

        final bool isMember = (BigInt.tryParse(widget.member!.personalBalance ?? "0") ?? BigInt.zero) >= BigInt.one;
        final bool canShowBridge = widget.org.wrapped != null;

        if (isMember) {
          return accountScreenContent(context);
        } else {
          // Not a member
          if (canShowBridge) {
            // Not a member, but DAO is wrapped, so show bridge and "not a member" message
            return ListView(
              children: [
                const SizedBox(height: 16), // Consistent padding
                Card( // Bridge Card structure
                  child: Padding(
                    padding: const EdgeInsets.all(38.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Token Bridge (${widget.org.symbol} <-> Underlying)",
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 9),
                        const Text(
                            "Use this bridge to wrap your underlying tokens into governance tokens, or unwrap them back."),
                        const SizedBox(height: 9),
                        const Divider(),
                        const SizedBox(height: 20),
                        GovernanceTokenBridgeWidget(org: widget.org),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                notAMember(),
                const SizedBox(height: 140), // Consistent bottom padding
              ],
            );
          } else {
            // Not a member and DAO is not wrapped
            return notAMember();
          }
        }
      },
    );
  }

  Widget notSignedin() {
    return const SizedBox(
        height: 20,
        child: Center(
            child: Text("You are not signed in.",
                style: TextStyle(fontSize: 20, color: Colors.grey))));
  }

  Widget notAMember() {
    return const SizedBox(
        height: 20,
        child: Center(
            child: Text("You are not a member.",
                style: TextStyle(fontSize: 20, color: Colors.grey))));
  }

  Widget accountScreenContent(BuildContext context) { // Renamed from accountWide
    // Assumes widget.member, widget.createdProposals, and widget.votedOnProposals are populated
    // by the main FutureBuilder calling _loadAccountAndMemberData.

    return ListView(
      children: [
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 29),
                SizedBox(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 35.0),
                      child: FutureBuilder<Uint8List>(
                        future: generateAvatarAsync(hashString(Human().address!)),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                color: Theme.of(context).canvasColor,
                              ),
                              width: 50.0,
                              height: 50.0,
                            );
                          } else if (snapshot.hasData) {
                            return Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0)),
                                child: Image.memory(snapshot.data!));
                          } else {
                            return Container(
                              width: 50.0,
                              height: 50.0,
                              color: Theme.of(context).canvasColor,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      Human().address!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                  ],
                )),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 40, right: 40, top: 25, bottom: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Voting Weight", style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          Text(
                            parseNumber(widget.member?.votingWeight ?? "0", widget.org.decimals ?? 18),
                            style: const TextStyle(
                                fontSize: 27, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Personal ${widget.org.symbol} Balance", style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          Text(
                            parseNumber(widget.member?.personalBalance ?? "0", widget.org.decimals ?? 18),
                            style: const TextStyle(
                                fontSize: 27, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Proposals Created", style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          Text(
                            widget.createdProposals.length.toString(), // Uses correctly populated list
                            style: const TextStyle(
                                fontSize: 27, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Votes Cast", style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          Text(
                            widget.votedOnProposals.length.toString(), // Uses correctly populated list
                            style: const TextStyle(
                                fontSize: 27, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(38.0),
            child: Column(
              children: [
                const SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Delegation settings", style: TextStyle(fontSize: 20)),
                      SizedBox(height: 9),
                      Text("You can either delegate your vote or accept delegations, but not both at the same time."),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                const Divider(),
                const SizedBox(height: 35),
                DelegationBoxes(
                  accountState: this,
                  org: widget.org,
                  m: widget.member!, // widget.member is guaranteed to be non-null here by FutureBuilder
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (widget.org.wrapped != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(38.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Token Bridge (${widget.org.symbol} <-> Underlying)",
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                      "Use this bridge to wrap your underlying tokens into governance tokens, or unwrap them back."),
                  const SizedBox(height: 9),
                  const Divider(),
                  const SizedBox(height: 20),
                  GovernanceTokenBridgeWidget(org: widget.org), // Use the new GovernanceTokenBridgeWidget here
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        ActivityHistory(
            votedProposals: widget.votedOnProposals, // Pass the populated lists
            createdProposals: widget.createdProposals),
        const SizedBox(height: 140),
      ],
    );
  }
}

class ActivityHistory extends StatefulWidget {
  int status = 1;
  List<Widget> createdProposals;
  List<Widget> votedProposals;
  ActivityHistory({
    required this.createdProposals,
    required this.votedProposals,
    super.key,
  });

  @override
  State<ActivityHistory> createState() => _ActivityHistoryState();
}

class _ActivityHistoryState extends State<ActivityHistory> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(38.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Activity history",
                        style: TextStyle(fontSize: 20),
                      ),
                      Container(
                          padding: const EdgeInsets.only(right: 50),
                          height: 40,
                          child: ToggleSwitch(
                            initialLabelIndex: widget.status,
                            totalSwitches: 2,
                            minWidth: 186,
                            borderWidth: 1.5,
                            activeFgColor: Theme.of(context).indicatorColor,
                            inactiveFgColor:
                                const Color.fromARGB(255, 189, 189, 189),
                            activeBgColor: const [
                              Color.fromARGB(255, 77, 77, 77)
                            ],
                            inactiveBgColor: Theme.of(context).cardColor,
                            borderColor: [Theme.of(context).cardColor],
                            labels: const ['VOTING RECORD', 'PROPOSALS CREATED'],
                            customTextStyles: const [TextStyle(fontSize: 14)],
                            onToggle: (index) {
                              print('switched to: $index');
                              setState(() {
                                widget.status = index!;
                              });
                            },
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            const Divider(),
            const SizedBox(height: 30),
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Container(
                          padding: const EdgeInsets.only(left: 15),
                          width: 90,
                          child: Text(
                            "ID #",
                            style: TextStyle(color: listTitleColor),
                          )),
                    ),
                    Expanded(
                      child: SizedBox(
                          width: 230,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 48.0),
                            child: Text(
                              "Title",
                              style: TextStyle(color: listTitleColor),
                            ),
                          )),
                     ),
                    // SizedBox( // "Voted" column removed
                    //     width: 180,
                    //     child: Center(
                    //         child: Text(
                    //       "Voted    ",
                    //       style: TextStyle(color: listTitleColor),
                    //     ))),
                    SizedBox( // Adjusted width, or use Expanded for more flexible layout
                        width: 200, // Example: Increased width for "Posted"
                        child: Center(
                            child: Text(
                          "Posted",
                          style: TextStyle(color: listTitleColor),
                        ))),
                    SizedBox(
                        width: 150,
                        child: Center(
                            child: Text(
                          "Type ",
                          style: TextStyle(color: listTitleColor),
                        ))),
                    SizedBox(
                        width: 100,
                        child: Center(
                            child: Text(
                          "Status ",
                          style: TextStyle(color: listTitleColor),
                        ))),
                  ],
                ),
              ),
            ),
            ListView(
              shrinkWrap: true,
              children: widget.status == 0
                  ? widget.votedProposals
                  : widget.createdProposals,
            ),
          ],
        ),
      ),
    );
  }
}
