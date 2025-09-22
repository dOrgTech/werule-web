// lib/src/features/create_proposal/create_proposal_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_execution_details_card.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/models/token_asset.dart';
import 'package:werule/src/providers/create_proposal_provider.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/providers/treasury_provider.dart';
import 'package:werule/src/utils/reusable.dart';

class CreateProposalDialog extends StatefulWidget {
  final Org org;
  const CreateProposalDialog({super.key, required this.org});

  @override
  State<CreateProposalDialog> createState() => _CreateProposalDialogState();
}

class _CreateProposalDialogState extends State<CreateProposalDialog> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  String? _step2Category; // Used for sub-selections like 'daoConfig' or 'govToken'

  final _stepSubtitles = const [
    'Step 1: Basic Information',
    'Step 2: Proposal Type',
    'Step 3: Parameters',
    'Step 4: Review',
  ];

  String _getDialogTitle() {
    if (_currentStep < 3) return 'Set';
    return 'Review & Submit';
  }

  void _handleSubmit() async {
    if (!mounted) return;
    
    final provider = context.read<CreateProposalProvider>();
    final error = await provider.submitProposal();

    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (error != null) {
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Center(child: Text(error)),
        backgroundColor: Colors.redAccent,
      ));
    } else {
      scaffoldMessenger.showSnackBar(const SnackBar(
        content: Center(child: Text("Proposal submitted successfully!")),
        backgroundColor: Colors.green,
      ));
      navigator.pop();
    }
  }

  void _nextStep() {
    // For steps with forms
    if (_currentStep == 0 || _currentStep == 2) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
    }
    
    // If moving to the review step, prepare the transaction data.
    if (_currentStep == 2) {
      final error = context.read<CreateProposalProvider>().prepareProposalDataForReview();
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Center(child: Text(error)),
          backgroundColor: Colors.redAccent,
        ));
        return; // Don't proceed if data preparation fails.
      }
    }
    
    if (_currentStep < _stepSubtitles.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      // If we are in a sub-category view in step 2, go back to the main categories first.
      if (_currentStep == 1 && _step2Category != null) {
        setState(() {
          _step2Category = null;
        });
      } else {
        setState(() => _currentStep--);
      }
    }
  }

  // --- VALIDATORS ---
  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final regex = RegExp(r'^0x[a-fA-F0-9]{40}$');
    if (!regex.hasMatch(value)) return 'Invalid Ethereum address format';
    return null;
  }

  String? _validateLink(String? value) {
    if (value == null || value.isEmpty) return null; // Optional field

    // Basic XSS checks
    if (value.contains('<') || value.contains('>')) return 'Invalid characters detected';
    if (value.toLowerCase().trim().startsWith('javascript:')) return 'Scripts are not allowed';

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.isAbsolute) {
        return 'Please enter a valid URL (e.g., https://example.com)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateProposalProvider>();
    
    return AlertDialog(
      backgroundColor: const Color(0xff2c2c2c),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_getDialogTitle()),
          Text(
            _stepSubtitles[_currentStep],
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: _buildStepContent(provider),
          ),
        ),
      ),
      actions: _buildActions(provider),
    );
  }

  Widget _buildStepContent(CreateProposalProvider provider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Container(
        // THE FIX: Enclosed `_currentStep` in curly braces for correct string interpolation.
        key: ValueKey<String>('step_${_currentStep}_$_step2Category'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_currentStep == 0) _buildCommonFields(provider),
            if (_currentStep == 1) _buildProposalTypeSelection(provider),
            if (_currentStep == 2) _buildParametersForm(provider),
            if (_currentStep == 3) _buildReviewStep(provider),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(CreateProposalProvider provider) {
    // Hide Next/Submit buttons during step 2, as selections auto-advance.
    final showPrimaryButton = _currentStep != 1;

    return [
      TextButton(
        onPressed: provider.isLoading ? null : (_currentStep > 0 ? _previousStep : () => Navigator.of(context).pop()),
        child: Text(_currentStep > 0 ? 'Back' : 'Cancel'),
      ),
      if (showPrimaryButton)
        ElevatedButton(
          onPressed: provider.isLoading 
            ? null 
            : (_currentStep < _stepSubtitles.length - 1 ? _nextStep : _handleSubmit),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffa1d0d0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: provider.isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
            : Text(
                _currentStep < _stepSubtitles.length - 1 ? 'Next' : 'Submit Proposal',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
        ),
    ];
  }

  Widget _buildCommonFields(CreateProposalProvider provider) {
    return Column(
      children: [
        TextFormField(
          initialValue: provider.title,
          decoration: const InputDecoration(labelText: 'Title'),
          onChanged: (value) => provider.title = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: provider.description,
          decoration: const InputDecoration(labelText: 'Description (Short)'),
          maxLines: 4,
          onChanged: (value) => provider.description = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: provider.link,
          decoration: const InputDecoration(labelText: 'Discussion Link (Optional)'),
          onChanged: (value) => provider.link = value,
          validator: _validateLink,
        ),
      ],
    );
  }

  Widget _buildProposalTypeSelection(CreateProposalProvider provider) {
    if (_step2Category == 'daoConfig') return _buildDaoConfigSubcategories(provider);
    if (_step2Category == 'govToken') return _buildGovTokenSubcategories(provider);
    return _buildMainCategories(provider);
  }
  
  Widget _buildMainCategories(CreateProposalProvider provider) {
    return Column(
      children: [
         _buildCategoryButton(
          icon: Icons.attach_money_outlined,
          title: "Transfer Assets",
          subtitle: "From the DAO Treasury to another account",
          onTap: () {
            provider.setProposalType(ProposalType.transfer);
            _nextStep();
          },
        ),
        _buildCategoryButton(
          icon: Icons.list_alt_outlined,
          title: "Edit Registry",
          subtitle: "Change an entry or add a new one",
          onTap: () {
            provider.setProposalType(ProposalType.registry);
            _nextStep();
          },
        ),
        _buildCategoryButton(
          icon: Icons.settings_outlined,
          title: "DAO Configuration",
          subtitle: "Change quorum, voting durations, or threshold",
          onTap: () => setState(() => _step2Category = 'daoConfig'),
        ),
        _buildCategoryButton(
          icon: Icons.generating_tokens_outlined,
          title: "Manage ${widget.org.symbol} Tokens",
          subtitle: "Mint new tokens or burn existing ones",
          onTap: () => setState(() => _step2Category = 'govToken'),
        ),
      ],
    );
  }

  Widget _buildDaoConfigSubcategories(CreateProposalProvider provider) {
    return Column(
      children: [
        _buildSubCategoryButton(
          icon: Icons.group_outlined, title: "Update Quorum",
          onTap: () { provider.setProposalType(ProposalType.updateQuorum); _nextStep(); }
        ),
        _buildSubCategoryButton(
          icon: Icons.hourglass_empty_outlined, title: "Update Voting Delay",
          onTap: () { provider.setProposalType(ProposalType.updateVotingDelay); _nextStep(); }
        ),
        _buildSubCategoryButton(
          icon: Icons.timer_outlined, title: "Update Voting Period",
          onTap: () { provider.setProposalType(ProposalType.updateVotingPeriod); _nextStep(); }
        ),
        _buildSubCategoryButton(
          icon: Icons.account_balance_wallet_outlined, title: "Update Proposal Threshold",
          onTap: () { provider.setProposalType(ProposalType.updateThreshold); _nextStep(); }
        ),
      ],
    );
  }

  Widget _buildGovTokenSubcategories(CreateProposalProvider provider) {
    return Column(
      children: [
        _buildSubCategoryButton(
          icon: Icons.add_circle_outline, title: "Mint Tokens",
          onTap: () { provider.setProposalType(ProposalType.mintTokens); _nextStep(); }
        ),
        _buildSubCategoryButton(
          icon: Icons.remove_circle_outline, title: "Burn Tokens",
          onTap: () { provider.setProposalType(ProposalType.burnTokens); _nextStep(); }
        ),
      ],
    );
  }

  Widget _buildCategoryButton({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, size: 32, color: const Color(0xffa1d0d0)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryButton({required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(icon, size: 24, color: const Color(0xffa1d0d0)),
                const SizedBox(width: 16),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParametersForm(CreateProposalProvider provider) {
    switch (provider.selectedType) {
      case ProposalType.registry: return _buildRegistryForm(provider);
      case ProposalType.transfer: return _buildTransferForm(provider);
      case ProposalType.mintTokens: return _buildMintForm(provider);
      case ProposalType.burnTokens: return _buildBurnForm(provider);
      case ProposalType.updateQuorum: return _buildSingleUintForm(provider, "New Quorum", (val) => provider.quorumValue = val);
      case ProposalType.updateVotingDelay: return _buildSingleUintForm(provider, "New Voting Delay", (val) => provider.votingDelayValue = val, hint: "Value in minutes");
      case ProposalType.updateVotingPeriod: return _buildSingleUintForm(provider, "New Voting Period", (val) => provider.votingPeriodValue = val, hint: "Value in minutes");
      case ProposalType.updateThreshold: return _buildSingleUintForm(provider, "New Proposal Threshold", (val) => provider.thresholdValue = val, hint: 'Amount in ${widget.org.symbol}');
    }
  }

  Widget _buildRegistryForm(CreateProposalProvider provider) {
    return Column(
      children: [
        TextFormField(
          initialValue: provider.registryKey,
          decoration: const InputDecoration(labelText: 'Key'),
          onChanged: (value) => provider.registryKey = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: provider.registryValue,
          decoration: const InputDecoration(labelText: 'Value'),
          onChanged: (value) => provider.registryValue = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildTransferForm(CreateProposalProvider provider) {
    final treasuryProvider = context.watch<TreasuryProvider>();
    final assets = treasuryProvider.tokenAssets;
    final symbol = provider.selectedAsset?.token.symbol ?? 'units';

    return Column(
      children: [
        DropdownButtonFormField<TokenAsset>(
          value: provider.selectedAsset,
          onChanged: (value) => provider.setSelectedAsset(value),
          decoration: const InputDecoration(labelText: 'Asset to Transfer'),
          validator: (value) => value == null ? 'Please select an asset' : null,
          items: assets.map((asset) {
            final decimals = asset.token.decimals ?? 18;
            final balance = formatTotalSupply(asset.balance, decimals);
            return DropdownMenuItem(
              value: asset,
              child: Text('${asset.token.name} ($balance ${asset.token.symbol})'),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: provider.transferRecipient,
          decoration: const InputDecoration(labelText: 'Recipient Address'),
          onChanged: (value) => provider.transferRecipient = value,
          validator: _validateAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: provider.transferAmount,
          decoration: InputDecoration(labelText: 'Amount', hintText: 'Amount in $symbol'),
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
          initialValue: provider.mintRecipient,
          decoration: const InputDecoration(labelText: 'Recipient Address'),
          onChanged: (value) => provider.mintRecipient = value,
          validator: _validateAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: provider.mintAmount,
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
          initialValue: provider.burnFromAddress,
          decoration: const InputDecoration(labelText: 'From Address'),
          onChanged: (value) => provider.burnFromAddress = value,
          validator: _validateAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: provider.burnAmount,
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
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (int.tryParse(value) == null) return 'Must be a valid integer';
        return null;
      },
    );
  }

  Widget _buildReviewStep(CreateProposalProvider provider) {
    final dummyProposal = Proposal(
      id: "PREVIEW",
      author: "You",
      title: provider.title,
      description: provider.description,
      inFavor: BigInt.zero,
      against: BigInt.zero,
      createdAt: DateTime.now(),
      statusHistory: {},
      type: provider.selectedType.typeString,
      targets: provider.preparedTargets,
      values: provider.preparedValues.map((v) => v.toString()).toList(),
      callDatas: provider.preparedCallDatasAsHex,
      externalResource: provider.link,
      totalSupply: '0',
      votesFor: 0,
      votesAgainst: 0,
    );

    final network = context.read<NetworkProvider>().selectedNetwork;
    if (network == null) {
      return const Center(child: Text("Error: Active network not found."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem("Title", provider.title),
        _buildReviewItem("Description", provider.description),
        if (provider.link.isNotEmpty) _buildReviewItem("Discussion Link", provider.link),
        const Divider(height: 32, color: Colors.white24),
        Text(
          "Execution Details",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ProposalExecutionDetailsCard(
            proposal: dummyProposal,
            org: widget.org,
            network: network,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
// lib/src/features/create_proposal/create_proposal_dialog.dart