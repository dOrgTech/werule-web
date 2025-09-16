// lib/src/features/proposal_detail/widgets/votes_modal.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/vote.dart';
import 'package:werule/src/services/firestore_service.dart';
import 'package:werule/src/utils/reusable.dart';

class VotesModal extends StatefulWidget {
  final String proposalId;
  final Org org;
  final Network network;

  const VotesModal({
    super.key,
    required this.proposalId,
    required this.org,
    required this.network,
  });

  @override
  State<VotesModal> createState() => _VotesModalState();
}

class _VotesModalState extends State<VotesModal> {
  late Future<List<Vote>> _votesFuture;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('[VOTES_MODAL] initState: Fetching votes with the following params:');
      print('  -> Network Collection: ${widget.network.daoCollectionName}');
      print('  -> DAO Address: ${widget.org.address}');
      print('  -> Proposal ID: ${widget.proposalId}');
    }
    final firestoreService = context.read<FirestoreService>();
    _votesFuture = firestoreService.getVotes(
      widget.network.daoCollectionName,
      widget.org.address,
      widget.proposalId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FutureBuilder<List<Vote>>(
        future: _votesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(heightFactor: 5, child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading votes: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(heightFactor: 5, child: Text("No votes have been cast yet."));
          }
          
          final votes = snapshot.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return _buildMobileLayout(votes);
              } else {
                return _buildDesktopLayout(votes);
              }
            },
          );
        },
      ),
    );
  }

  // --- Mobile Layout ---
  Widget _buildMobileLayout(List<Vote> votes) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: ListView.builder(
        itemCount: votes.length,
        itemBuilder: (context, index) {
          final vote = votes[index];
          return Card(
            color: const Color(0xff3a3a3a),
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            child: ListTile(
              leading: _buildOptionCell(vote.option),
              title: Text(
                shortenString(vote.voter),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              subtitle: Text(
                'Weight: ${formatTotalSupply(vote.weight, widget.org.decimals)}\n'
                '${DateFormat("yyyy-MM-dd – HH:mm").format(vote.castAt)}',
              ),
              trailing: _buildTxCell(vote.hash),
              onTap: () {
                Clipboard.setData(ClipboardData(text: vote.voter));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(duration: Duration(seconds: 1), content: Center(child: Text('Voter address copied to clipboard')))
                );
              },
            ),
          );
        },
      ),
    );
  }

  // --- Desktop Layout ---
  Widget _buildDesktopLayout(List<Vote> votes) {
    // THE FIX: The DataTable should scroll horizontally if needed.
    // The AlertDialog will handle vertical scrolling.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Voter')),
          DataColumn(label: Text('Option')),
          DataColumn(label: Text('Weight')),
          DataColumn(label: Text("Cast At")),
          DataColumn(label: Text('Tx')),
        ],
        rows: votes.map((vote) {
          return DataRow(cells: [
            DataCell(_buildVoterCell(context, vote.voter)),
            DataCell(_buildOptionCell(vote.option)),
            DataCell(Text(formatTotalSupply(vote.weight, widget.org.decimals))),
            DataCell(Text(DateFormat("yyyy-MM-dd – HH:mm").format(vote.castAt))),
            DataCell(_buildTxCell(vote.hash)),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildVoterCell(BuildContext context, String voterAddress) {
    return Row(
      children: [
        Text(shortenString(voterAddress)),
        const SizedBox(width: 4),
        IconButton(
          splashRadius: 20,
          icon: const Icon(Icons.copy, size: 16),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: voterAddress));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(duration: Duration(seconds: 1), content: Center(child: Text('Address copied to clipboard')))
            );
          },
        )
      ],
    );
  }

  Widget _buildOptionCell(int option) {
    return option == 1
        ? const Icon(Icons.thumb_up, color: Color.fromARGB(255, 93, 223, 162))
        : const Icon(Icons.thumb_down, color: Color.fromARGB(255, 238, 129, 121));
  }

  Widget _buildTxCell(String hash) {
    final explorerUrl = widget.network.blockExplorerUrl;
    if (hash.isEmpty || explorerUrl.isEmpty) return const SizedBox.shrink();
    
    final prefixedHash = hash.startsWith('0x') ? hash : '0x$hash';
    final txUrl = Uri.parse("$explorerUrl/tx/$prefixedHash");

    return IconButton(
      splashRadius: 20,
      icon: const Icon(Icons.open_in_new, size: 20),
      onPressed: () => launchUrl(txUrl),
    );
  }
}
// lib/src/features/proposal_detail/widgets/votes_modal.dart