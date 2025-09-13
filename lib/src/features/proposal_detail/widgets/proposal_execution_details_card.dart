// lib/src/features/proposal_detail/widgets/proposal_execution_details_card.dart
import 'package:flutter/material.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/contract_call_details.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/dao_configuration_details.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/governance_token_op_details.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/registry_details.dart';
import 'package:werule/src/features/proposal_detail/widgets/details/token_transfer_details.dart';
import 'package:werule/src/models/network.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';

class ProposalExecutionDetailsCard extends StatelessWidget {
  final Proposal proposal;
  final Org org;
  final Network network;
  const ProposalExecutionDetailsCard({super.key, required this.proposal, required this.org, required this.network});

  @override
  Widget build(BuildContext context) {
    Widget detailsContent;
    final type = proposal.type?.toLowerCase() ?? "unknown";

    if (type.contains("transfer")) {
      detailsContent = TokenTransferDetails(proposal: proposal, network: network);
    } else if (type.contains("registry")) {
      detailsContent = RegistryDetails(proposal: proposal);
    } else if (type.contains("contract call")) {
      detailsContent = ContractCallDetails(proposal: proposal);
    } else if (type.contains("mint") || type.contains("burn")) {
      detailsContent = GovernanceTokenOpDetails(proposal: proposal, org: org);
    } else if (type.contains("quorum") || type.contains("voting delay") || type.contains("voting period") || type.contains("threshold")) {
      detailsContent = DaoConfigurationDetails(proposal: proposal);
    } else {
      detailsContent = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.code, size: 48, color: Colors.grey),
             SizedBox(height: 16),
             Text(
              'Execution Details Not Available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
             SizedBox(height: 8),
            Text(
              'Proposal type not recognized.',
               style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }


    return Card(
      color: const Color(0xff2c2c2c),
      child: Container(
         width: double.infinity,
         padding: const EdgeInsets.all(24.0),
         child: detailsContent,
      ),
    );
  }
}
// lib/src/features/proposal_detail/widgets/proposal_execution_details_card.dart