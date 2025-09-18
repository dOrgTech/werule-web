// lib/src/features/dao_detail/tabs/proposals_tab.dart
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/dao_detail/widgets/proposal_list_item.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/providers/auth_provider.dart';
import 'package:werule/src/services/blockchain_service.dart';
import 'package:werule/src/services/calldata_service.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/utils/proposal_status_helper.dart';

class ProposalsTab extends StatefulWidget {
  final Org org;
  final String networkName;

  const ProposalsTab({
    super.key,
    required this.org,
    required this.networkName,
  });

  @override
  State<ProposalsTab> createState() => _ProposalsTabState();
}

class _ProposalsTabState extends State<ProposalsTab> {
  String _selectedType = 'All';
  String _selectedStatus = 'All';
  bool _isCreatingProposal = false;

  late Stream<List<Proposal>> _proposalsStream;

  final List<String> _typeOptions = const [
    'All', 'Registry', 'Transfer', 'Contract Call', 'Mint', 'Burn', 'Quorum', 'Voting Delay', 'Voting Period', 'Threshold'
  ];
  final List<String> _statusOptions = const [
    'All', "Active", "Succeeded", "Queued", "Executable", "Executed", "Expired", "No Quorum", "Pending", "Rejected", "Defeated"
  ];
  
  @override
  void initState() {
    super.initState();
    final firestoreService = context.read<FirestoreService>();
    final collectionName = 'idaos${widget.networkName}';
    _proposalsStream = firestoreService.getProposalsStream(collectionName, widget.org.address);
  }

  String _statusToString(ProposalStatus status) {
    switch (status) {
      case ProposalStatus.NoQuorum: return "No Quorum";
      default:
        final String name = status.toString().split('.').last;
        return name[0].toUpperCase() + name.substring(1);
    }
  }

  // --- Helper methods for proposal creation ---

  String _generateRandomString(int length) {
    final random = Random.secure();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }
  
  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(child: Text(message)),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ));
  }

  void _showAccountMismatchDialog(AccountMismatchException e) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xff2c2c2c),
        title: const Text("Account Mismatch"),
        content: Text(e.toString()),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateProposal() async {
    setState(() => _isCreatingProposal = true);

    final auth = context.read<AuthProvider>();
    final blockchain = context.read<BlockchainService>();
    final calldataService = context.read<CalldataService>(); // Use the service again

    final signerAddress = auth.selectedAccount;
    if (signerAddress == null || !auth.isConnected) {
      _showSnackbar("Please connect your wallet to create a proposal.", isError: true);
      setState(() => _isCreatingProposal = false);
      return;
    }

    // 1. Prepare Proposal Data
    final randomSuffix = _generateRandomString(6);
    final title = "Test Registry Proposal $randomSuffix";
    const type = "registry";
    const description = "This is a hardcoded test proposal created from the WeRule app.";
    const link = "(No Link Provided)";
    
    final packedDescription = "$title""0|||0""$type""0|||0""$description""0|||0""$link";

    final key = "testKey-$randomSuffix";
    const value = "testValue";
    
    final targets = [widget.org.registryAddress];
    final values = [BigInt.zero];
    
    // Use the corrected calldata service
    final List<Uint8List> calldatas = [calldataService.encodeRegistryCall(key, value)];

    // 2. Send Transaction
    try {
      final txHash = await blockchain.propose(
        widget.org.address,
        signerAddress,
        targets,
        values,
        calldatas,
        packedDescription,
      );
      _showSnackbar("Proposal submitted successfully! Tx: ${txHash.substring(0,10)}...");
    } on AccountMismatchException catch(e) {
      _showAccountMismatchDialog(e);
    } catch (e) {
      _showSnackbar(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isCreatingProposal = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildControls(),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;
            return Column(
              children: [
                if (!isMobile) _buildHeader(),
                if (!isMobile) const SizedBox(height: 8),
                StreamBuilder<List<Proposal>>(
                  stream: _proposalsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.only(top: 148.0),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                       return const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 148.0),
                            child: Text('No proposals created yet...', style: TextStyle(fontSize: 23, color: Colors.white24),),
                          ),
                        );
                    }
                    
                    final allProposals = snapshot.data!;
                    final filteredProposals = allProposals.where((p) {
                      final currentStatus = ProposalStatusHelper.calculateDisplayStatus(p, widget.org);
                      final typeMatch = _selectedType == 'All' ||
                          (p.type != null && p.type!.toLowerCase().contains(_selectedType.toLowerCase()));
                      final statusMatch = _selectedStatus == 'All' ||
                          _statusToString(currentStatus) == _selectedStatus;
                      return typeMatch && statusMatch;
                    }).toList();

                    return SizedBox(
                      height: MediaQuery.of(context).size.height - 250,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredProposals.length,
                        itemBuilder: (context, index) {
                           final proposal = filteredProposals[index];
                           if (isMobile) {
                              return MobileProposalListItem(
                                key: ValueKey(proposal.id),
                                proposal: proposal,
                                org: widget.org,
                                networkName: widget.networkName,
                              );
                           } else {
                              return DesktopProposalListItem(
                                key: ValueKey(proposal.id),
                                proposal: proposal,
                                org: widget.org,
                                networkName: widget.networkName,
                              );
                           }
                        },
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        final typeDropdown = _buildDropdown(
            _selectedType, _typeOptions, (val) => setState(() => _selectedType = val!));
        final statusDropdown = _buildDropdown(_selectedStatus, _statusOptions,
            (val) => setState(() => _selectedStatus = val!));
        
        final createButton = ElevatedButton(
          onPressed: _isCreatingProposal ? null : _handleCreateProposal,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffa1d0d0),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isCreatingProposal
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : const Text('Create Proposal',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        );

        if (isMobile) {
          return Column(
            children: [
              Row(
                children: [
                  const Text("Type: "), Expanded(child: typeDropdown),
                  const SizedBox(width: 16),
                  const Text("Status: "), Expanded(child: statusDropdown),
                ],
              ),
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerRight, child: createButton),
            ],
          );
        }

        return Row(
          children: [
            const Text("Type: "), const SizedBox(width: 8), typeDropdown,
            const SizedBox(width: 24),
            const Text("Status: "), const SizedBox(width: 8), statusDropdown,
            const Spacer(),
            createButton,
          ],
        );
      }),
    );
  }

  Widget _buildDropdown(
      String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: value,
      focusColor: Colors.transparent,
      underline: const SizedBox.shrink(),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildHeader() {
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
// lib/src/features/dao_detail/tabs/proposals_tab.dart