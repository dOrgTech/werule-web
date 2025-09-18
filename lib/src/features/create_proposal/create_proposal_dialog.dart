// lib/src/features/create_proposal/create_proposal_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/create_proposal_provider.dart';

class CreateProposalDialog extends StatefulWidget {
  final Org org;
  const CreateProposalDialog({super.key, required this.org});

  @override
  State<CreateProposalDialog> createState() => _CreateProposalDialogState();
}

class _CreateProposalDialogState extends State<CreateProposalDialog> {
  final _formKey = GlobalKey<FormState>();

  void _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = context.read<CreateProposalProvider>();
    final error = await provider.submitProposal();

    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Center(child: Text(error)),
          backgroundColor: Colors.redAccent,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Center(child: Text("Proposal submitted successfully!")),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateProposalProvider>();
    
    return AlertDialog(
      backgroundColor: const Color(0xff2c2c2c),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create New Proposal'),
          Text(
            'For DAO: ${widget.org.name}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCommonFields(provider),
                const SizedBox(height: 24),
                _buildProposalTypeDropdown(provider),
                const SizedBox(height: 24),
                
                if (provider.selectedType == ProposalType.registry) _buildRegistryForm(provider),
                if (provider.selectedType == ProposalType.transfer) _buildTransferForm(provider),
                if (provider.selectedType == ProposalType.mintTokens) _buildMintForm(provider),
                if (provider.selectedType == ProposalType.burnTokens) _buildBurnForm(provider),
                if (provider.selectedType == ProposalType.updateQuorum) _buildSingleUintForm(provider, "New Quorum", (val) => provider.quorumValue = val),
                // THE FIX: Add hint text to clarify the expected unit is minutes.
                if (provider.selectedType == ProposalType.updateVotingDelay) _buildSingleUintForm(provider, "New Voting Delay", (val) => provider.votingDelayValue = val, hint: "Value in minutes"),
                if (provider.selectedType == ProposalType.updateVotingPeriod) _buildSingleUintForm(provider, "New Voting Period", (val) => provider.votingPeriodValue = val, hint: "Value in minutes"),
                if (provider.selectedType == ProposalType.updateThreshold) _buildSingleUintForm(provider, "New Proposal Threshold", (val) => provider.thresholdValue = val, hint: 'Amount in ${widget.org.symbol}'),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: provider.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: provider.isLoading ? null : () => _handleSubmit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffa1d0d0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: provider.isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
            : const Text(
              'Submit Proposal',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
        ),
      ],
    );
  }

  Widget _buildCommonFields(CreateProposalProvider provider) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Title'),
          onChanged: (value) => provider.title = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Description (Short)'),
          maxLines: 4,
          onChanged: (value) => provider.description = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Discussion Link (Optional)'),
          onChanged: (value) => provider.link = value,
        ),
      ],
    );
  }

  Widget _buildProposalTypeDropdown(CreateProposalProvider provider) {
    return DropdownButtonFormField<ProposalType>(
      value: provider.selectedType,
      onChanged: (value) => provider.setProposalType(value),
      decoration: const InputDecoration(labelText: 'Proposal Type'),
      items: const [
        DropdownMenuItem(value: ProposalType.registry, child: Text('Edit Registry')),
        DropdownMenuItem(value: ProposalType.transfer, child: Text('Transfer from Treasury')),
        DropdownMenuItem(value: ProposalType.mintTokens, child: Text('Mint Governance Tokens')),
        DropdownMenuItem(value: ProposalType.burnTokens, child: Text('Burn Governance Tokens')),
        DropdownMenuItem(value: ProposalType.updateQuorum, child: Text('Update Quorum')),
        DropdownMenuItem(value: ProposalType.updateVotingDelay, child: Text('Update Voting Delay')),
        DropdownMenuItem(value: ProposalType.updateVotingPeriod, child: Text('Update Voting Period')),
        DropdownMenuItem(value: ProposalType.updateThreshold, child: Text('Update Proposal Threshold')),
      ],
    );
  }

  Widget _buildRegistryForm(CreateProposalProvider provider) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Key'),
          onChanged: (value) => provider.registryKey = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Value'),
          onChanged: (value) => provider.registryValue = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildTransferForm(CreateProposalProvider provider) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Recipient Address'),
          onChanged: (value) => provider.transferRecipient = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Amount', hintText: 'Amount in ETH'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => provider.transferAmount = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildMintForm(CreateProposalProvider provider) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Recipient Address'),
          onChanged: (value) => provider.mintRecipient = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(labelText: 'Amount', hintText: 'Amount in ${widget.org.symbol}'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => provider.mintAmount = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildBurnForm(CreateProposalProvider provider) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'From Address'),
          onChanged: (value) => provider.burnFromAddress = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(labelText: 'Amount', hintText: 'Amount in ${widget.org.symbol}'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => provider.burnAmount = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildSingleUintForm(CreateProposalProvider provider, String label, Function(String) onChanged, {String? hint}) {
     return TextFormField(
      decoration: InputDecoration(labelText: label, hintText: hint),
      // THE FIX: Allow only integer input for these fields.
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (int.tryParse(value) == null) return 'Must be a valid integer';
        return null;
      },
    );
  }
}
// lib/src/features/create_proposal/create_proposal_dialog.dart