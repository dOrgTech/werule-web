// lib/src/features/dao_detail/tabs/account_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/dao_detail/widgets/proposal_list_item.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/providers/member_provider.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/services/members_service.dart';
import 'package:werule/src/utils/reusable.dart';

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

    // THE FIX: Add a ValueKey to the provider. When the selectedAccount changes,
    // this key will change, forcing Flutter to create a new MemberProvider instance.
    return ChangeNotifierProvider(
      key: ValueKey(auth.selectedAccount),
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
          _ActivityHistoryCard(dao: dao, networkName: context.read<NetworkProvider>().selectedNetwork!.name),
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

  void _showSnackbar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(child: Text(message)),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ));
  }

  void _showSetDelegateDialog(BuildContext context) {
    final provider = context.read<MemberProvider>();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isSubmitting = false;

            return AlertDialog(
              backgroundColor: const Color(0xff2c2c2c),
              title: const Text("Set Delegate"),
              content: provider.isActionBusy || isSubmitting
                ? const Center(heightFactor: 2, child: CircularProgressIndicator())
                : Form(
                    key: formKey,
                    child: TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: "Delegate Address (0x...)"),
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.startsWith('0x') || value.length != 42) {
                          return 'Please enter a valid Ethereum address.';
                        }
                        return null;
                      },
                    ),
                  ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: provider.isActionBusy || isSubmitting ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setDialogState(() => isSubmitting = true);
                      final error = await provider.handleDelegate(addressController.text);
                      if (dialogContext.mounted) {
                        if (error == null) {
                          _showSnackbar(dialogContext, "Delegation successful!");
                          Navigator.of(dialogContext).pop();
                        } else {
                          _showSnackbar(dialogContext, error, isError: true);
                          setDialogState(() => isSubmitting = false);
                        }
                      }
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _claimVotingPower(BuildContext context) async {
    final provider = context.read<MemberProvider>();
    final userAddress = context.read<AuthProvider>().selectedAccount;
    if (userAddress == null) return;
    
    final error = await provider.handleDelegate(userAddress);
    if (context.mounted) {
      if (error == null) {
        _showSnackbar(context, "Voting power claimed successfully!");
      } else {
        _showSnackbar(context, error, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemberProvider>();
    final auth = context.watch<AuthProvider>();

    final userAddress = auth.selectedAccount?.toLowerCase();
    final delegateAddress = provider.delegateAddress?.toLowerCase();
    final hasBalance = provider.personalBalance > BigInt.zero;
    final zeroAddress = "0x0000000000000000000000000000000000000000";

    bool isUndelegated = delegateAddress == null || delegateAddress == zeroAddress;
    bool isSelfDelegated = !isUndelegated && delegateAddress == userAddress;
    
    Widget delegateBottomWidget;
    Widget voteDirectlyBottomWidget;

    if (!hasBalance) {
      delegateBottomWidget = const ElevatedButton(onPressed: null, child: Text('Delegate Vote'));
      voteDirectlyBottomWidget = const ElevatedButton(onPressed: null, child: Text('Claim Voting Power'));
    } else if (isUndelegated) {
      delegateBottomWidget = ElevatedButton(onPressed: () => _showSetDelegateDialog(context), child: const Text('Delegate Vote'));
      voteDirectlyBottomWidget = ElevatedButton(onPressed: () => _claimVotingPower(context), child: const Text('Claim Voting Power'));
    } else if (isSelfDelegated) {
      delegateBottomWidget = ElevatedButton(onPressed: () => _showSetDelegateDialog(context), child: const Text('Change Delegate'));
      voteDirectlyBottomWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text("You are voting directly.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400])),
      );
    } else { // Delegated to other
      delegateBottomWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(shortenString(provider.delegateAddress!), style: const TextStyle(fontFamily: 'monospace')),
          IconButton(onPressed: () => _showSetDelegateDialog(context), icon: const Icon(Icons.edit)),
        ],
      );
      voteDirectlyBottomWidget = ElevatedButton(onPressed: () => _claimVotingPower(context), child: const Text('Claim Voting Power'));
    }

    if (provider.isActionBusy) {
      delegateBottomWidget = voteDirectlyBottomWidget = const Center(child: CircularProgressIndicator());
    }

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
            Text("To participate in governance, you must claim your voting power for yourself or delegate it to another address.", style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 24),
            LayoutBuilder(builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 850;
              final children = [
                _DelegationOptionBox(
                  icon: Icons.handshake_outlined,
                  title: "DELEGATE\nYOUR VOTE",
                  description: "If you can't or don't want to take part in the governance process, your voting privilege may be forwarded to another member of your choosing.",
                  bottomWidget: delegateBottomWidget,
                ),
                if (isMobile) const SizedBox(height: 24),
                if (!isMobile) const SizedBox(width: 40),
                _DelegationOptionBox(
                  icon: Icons.how_to_vote_outlined,
                  title: "VOTE\nDIRECTLY",
                  description: "This also allows other members to delegate their vote to you, so that you may participate in the governance process on their behalf.",
                  bottomWidget: voteDirectlyBottomWidget,
                ),
              ];
              return isMobile 
                ? Column(children: children)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  );
            }),
          ],
        ),
      ),
    );
  }
}

class _DelegationOptionBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget bottomWidget;

  const _DelegationOptionBox({
    required this.icon,
    required this.title,
    required this.description,
    required this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          border: Border.all(width: 0.3, color: const Color.fromARGB(255, 105, 105, 105)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50),
                const SizedBox(width: 16),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
              ],
            ),
            const SizedBox(height: 25),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(description, style: TextStyle(color: Colors.grey[300], fontSize: 15, height: 1.4)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 40, child: Center(child: bottomWidget)),
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
  final Org dao;
  final String networkName;
  const _ActivityHistoryCard({required this.dao, required this.networkName});

  @override
  State<_ActivityHistoryCard> createState() => _ActivityHistoryCardState();
}

class _ActivityHistoryCardState extends State<_ActivityHistoryCard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();
    final votedProposals = memberProvider.votedProposalDetails;
    final createdProposals = memberProvider.createdProposalDetails;
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
                      ? MobileProposalListItem(proposal: proposal, org: widget.dao, networkName: widget.networkName)
                      : DesktopProposalListItem(proposal: proposal, org: widget.dao, networkName: widget.networkName);
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
            Expanded(flex: 3, child: Text("Title")),
            Expanded(flex: 2, child: Text("Author")),
            SizedBox(width: 140, child: Text("Posted")),
            Spacer(),
            SizedBox(width: 100, child: Text("Type")),
            SizedBox(width: 110, child: Text("Status", textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
// lib/src/features/dao_detail/tabs/account_tab.dart