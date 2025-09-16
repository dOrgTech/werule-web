// lib/src/features/dao_detail/tabs/account_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/member_provider.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/services/members_service.dart';
import 'package:werule/src/utils/reusable.dart';

// A simple data class for our mock proposal list items
class _ProposalListItemData {
  final String id;
  final String title;
  _ProposalListItemData({required this.id, required this.title});
}

class AccountTab extends StatelessWidget {
  final Org dao;
  const AccountTab({super.key, required this.dao});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final network = context.watch<NetworkProvider>().selectedNetwork;

    if (!auth.isConnected || network == null) {
      return const _NotConnectedView();
    }

    // THE FIX: Use a provider to fetch and manage member-specific data.
    return ChangeNotifierProvider(
      create: (context) => MemberProvider(
        authProvider: context.read<AuthProvider>(),
        firestoreService: context.read<FirestoreService>(),
        blockchainService: context.read<BlockchainService>(),
        membersService: context.read<MembersService>(),
        org: dao,
        network: network,
      ),
      child: Consumer<MemberProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text("Error: ${provider.errorMessage}"));
          }
          
          final isMember = provider.personalBalance > BigInt.zero;
          final canShowBridge = dao.underlyingToken != null && dao.underlyingToken!.isNotEmpty;

          if (!isMember) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (canShowBridge) ...[
                    _TokenBridgeCard(dao: dao),
                    const SizedBox(height: 16),
                  ],
                  const _NotAMemberView(),
                ],
              ),
            );
          }

          return _AccountView(dao: dao, canShowBridge: canShowBridge);
        },
      ),
    );
  }
}

// --- Placeholder/Conditional Views ---

class _NotConnectedView extends StatelessWidget {
  const _NotConnectedView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Please connect your wallet to view your account details.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _NotAMemberView extends StatelessWidget {
  const _NotAMemberView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_accounts_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'You are not a member of this DAO.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// --- Main Account View ---

class _AccountView extends StatelessWidget {
  final Org dao;
  final bool canShowBridge;
  const _AccountView({required this.dao, required this.canShowBridge});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Column(
        children: [
          _AccountHeaderCard(dao: dao),
          const SizedBox(height: 16),
          const _DelegationCard(),
          if (canShowBridge) ...[
            const SizedBox(height: 16),
            _TokenBridgeCard(dao: dao),
          ],
          const SizedBox(height: 16),
          const _ActivityHistoryCard(),
        ],
      ),
    );
  }
}

// --- Individual Cards ---

class _AccountHeaderCard extends StatelessWidget {
  final Org dao;
  const _AccountHeaderCard({required this.dao});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    // THE FIX: Get real data from the MemberProvider
    final memberProvider = context.watch<MemberProvider>();
    final address = auth.selectedAccount ?? '0x...';
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Card(
      color: const Color(0xff2c2c2c),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
        child: Column(
          children: [
            Row(
              children: [
                generateAvatar(hashString(address), size: 50, pixelSize: 5),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isMobile ? shortenString(address) : address,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 550;

                final stats = [
                  _buildStatColumn("Voting Weight", formatTotalSupply(memberProvider.votingWeight.toString(), dao.decimals)),
                  _buildStatColumn("Personal ${dao.symbol} Balance", formatTotalSupply(memberProvider.personalBalance.toString(), dao.decimals)),
                  _buildStatColumn("Proposals Created", memberProvider.proposalsCreatedCount.toString()),
                  _buildStatColumn("Votes Cast", memberProvider.votesCastCount.toString()),
                ];

                if (isNarrow) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [stats[0], stats[1]],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [stats[2], stats[3]],
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: stats,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _DelegationCard extends StatelessWidget {
  const _DelegationCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff2c2c2c),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Delegation Settings", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text("You can either delegate your vote or accept delegations, but not both at the same time.", style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text("Delegation UI Coming Soon", style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenBridgeCard extends StatelessWidget {
  final Org dao;
  const _TokenBridgeCard({required this.dao});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff2c2c2c),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Token Bridge (${dao.symbol} <-> Underlying)", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text("Use this bridge to wrap your underlying tokens into governance tokens, or unwrap them back.", style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text("Token Bridge UI Coming Soon", style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityHistoryCard extends StatefulWidget {
  const _ActivityHistoryCard();

  @override
  State<_ActivityHistoryCard> createState() => _ActivityHistoryCardState();
}

class _ActivityHistoryCardState extends State<_ActivityHistoryCard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Mock data for display
    final votedProposals = List.generate(3, (i) => _ProposalListItemData(id: '${10 - i}', title: 'Proposal Voted On #${10 - i}'));
    final createdProposals = List.generate(5, (i) => _ProposalListItemData(id: '${5 - i}', title: 'My Awesome Proposal #${5 - i}'));
    final isMobile = MediaQuery.of(context).size.width < 700;

    final toggleButtons = ToggleButtons(
      isSelected: [_selectedIndex == 0, _selectedIndex == 1],
      onPressed: (index) => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(8),
      selectedColor: Theme.of(context).indicatorColor,
      color: Colors.grey[400],
      fillColor: Colors.grey.withOpacity(0.2),
      children: isMobile 
        ? const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 24.0), child: Icon(Icons.front_hand)),
            Padding(padding: EdgeInsets.symmetric(horizontal: 24.0), child: Icon(Icons.how_to_vote)),
          ]
        : const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('PROPOSALS CREATED')),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('VOTING RECORD')),
          ],
    );

    return Card(
      color: const Color(0xff2c2c2c),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isMobile)
                  const Text("Activity History", style: TextStyle(fontSize: 20)),
                if (isMobile) const Spacer(),
                toggleButtons,
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            if (!isMobile) _buildDesktopHeader(),
            if (!isMobile) const SizedBox(height: 8),
            if (_selectedIndex == 0 && createdProposals.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text("No proposals created yet.")))
            else if (_selectedIndex == 1 && votedProposals.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text("No voting history found.")))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedIndex == 0 ? createdProposals.length : votedProposals.length,
                itemBuilder: (context, index) {
                  final proposal = _selectedIndex == 0 ? createdProposals[index] : votedProposals[index];
                  return isMobile
                      ? _MobileProposalListItem(proposal: proposal)
                      : _DesktopProposalListItem(proposal: proposal);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
        child: const Row(
          children: [
            SizedBox(width: 60, child: Text("ID #")),
            Expanded(flex: 4, child: Text("Title")),
            Expanded(flex: 2, child: Text("Posted")),
            Expanded(flex: 1, child: Text("Type")),
            SizedBox(width: 110, child: Text("Status", textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}

// --- List Item Widgets ---

class _DesktopProposalListItem extends StatelessWidget {
  final _ProposalListItemData proposal;
  const _DesktopProposalListItem({required this.proposal});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff3a3a3a),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            SizedBox(width: 60, child: Text(proposal.id)),
            Expanded(flex: 4, child: Text(proposal.title, overflow: TextOverflow.ellipsis)),
            const Expanded(flex: 2, child: Text("09/15/2025")),
            const Expanded(flex: 1, child: Text("Transfer")),
            const SizedBox(
              width: 110,
              child: Center(child: Text("Executed", style: TextStyle(color: Colors.green))),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileProposalListItem extends StatelessWidget {
  final _ProposalListItemData proposal;
  const _MobileProposalListItem({required this.proposal});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff3a3a3a),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    proposal.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Text("Executed", style: TextStyle(color: Colors.green)),
              ],
            ),
            const Divider(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildMobileDetailColumn("ID", shortenString(proposal.id), context)),
                const SizedBox(width: 16),
                Expanded(child: _buildMobileDetailColumn("Type", "Transfer", context)),
              ],
            ),
            const SizedBox(height: 12),
            _buildMobileDetailColumn("Posted", "09/15/2025", context),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDetailColumn(String label, String value, BuildContext context, {bool isMono = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: isMono ? const TextStyle(fontFamily: 'monospace') : const TextStyle(fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
// lib/src/features/dao_detail/tabs/account_tab.dart