// lib/src/features/create_proposal/create_proposal_dialog.dart
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/models/token_asset.dart';
import 'package:werule/src/providers/create_proposal_provider.dart';
import 'package:werule/src/providers/network_provider.dart';
import 'package:werule/src/providers/treasury_provider.dart';
import 'package:werule/src/services/calldata_service.dart';
import 'package:werule/src/utils/reusable.dart';
import 'package:web3dart/web3dart.dart';

// THE FIX: Moved validator functions to the top level to be accessible by all classes in this file.
String? _validateAddress(String? value) {
  if (value == null || value.isEmpty) return 'Required';
  final regex = RegExp(r'^0x[a-fA-F0-9]{40}$');
  if (!regex.hasMatch(value)) return 'Invalid Ethereum address format';
  return null;
}

String? _validateLink(String? value) {
  if (value == null || value.isEmpty) return "This can't be empty.\n Just put anything if you don't have a link."; // Optional field

  // Basic XSS checks
  if (value.contains('<') || value.contains('>')) return 'Invalid characters detected';
  if (value.toLowerCase().trim().startsWith('javascript:')) return 'Scripts are not allowed';

  // final uri = Uri.tryParse(value);
  // if (uri == null || !uri.isAbsolute) {
  //     return 'Please enter a valid URL (e.g., https://example.com)';
  // }
  return null;
}


class CreateProposalDialog extends StatefulWidget {
  final Org org;
  const CreateProposalDialog({super.key, required this.org});

  @override
  State<CreateProposalDialog> createState() => _CreateProposalDialogState();
}

class _CreateProposalDialogState extends State<CreateProposalDialog> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  String? _step2Category; 

  final _stepSubtitles = const [
    'Step 1: Basic Information',
    'Step 2: First Action Type',
    'Step 3: Parameters',
    'Step 4: Review Actions',
  ];

  String getDialogTitle() {
    if (_currentStep < 3) return 'Create Proposal';
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
    if (_currentStep == 0 || _currentStep == 2) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
    }
    
    if (_currentStep == 2) {
      final error = context.read<CreateProposalProvider>().prepareProposalDataForReview();
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Center(child: Text(error)),
          backgroundColor: Colors.redAccent,
        ));
        return; 
      }
    }
    
    if (_currentStep < _stepSubtitles.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      if (_currentStep == 1 && _step2Category != null) {
        setState(() => _step2Category = null);
      } else {
        setState(() => _currentStep--);
      }
    }
  }

  void _handleCsvUpload() async {
    try {
      // 1. Pick the file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true, // Important to get file bytes
      );

      if (result == null || result.files.first.bytes == null) {
        return; // User canceled the picker
      }
      
      // 2. Read file content
      final fileBytes = result.files.first.bytes!;
      final String csvContent = utf8.decode(fileBytes);

      // 3. Process with the provider
      if (!mounted) return;
      final provider = context.read<CreateProposalProvider>();
      final treasuryProvider = context.read<TreasuryProvider>();

      final error = await provider.processCsvAndPopulateActions(csvContent, treasuryProvider.tokenAssets);
      
      // 4. Handle result
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Center(child: Text("CSV Error: $error")),
          backgroundColor: Colors.redAccent,
        ));
      } else {
        // Success! Jump to the review step.
        // First, ensure proposal data is prepared with the new actions.
        final prepError = provider.prepareProposalDataForReview();
        if (prepError != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Center(child: Text("Error preparing proposal: $prepError")),
            backgroundColor: Colors.redAccent,
          ));
          return;
        }
        setState(() {
          // This skips Step 2 (type) and 3 (params) as they're defined by the CSV
          _currentStep = 3;
        });
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Center(child: Text("An unexpected error occurred: ${e.toString()}")),
        backgroundColor: Colors.redAccent,
      ));
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
          Text(getDialogTitle(), style:TextStyle(color: const Color.fromARGB(255, 219, 219, 219))),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              _stepSubtitles[_currentStep],
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color.fromARGB(179, 255, 255, 255), fontSize: 14),
            ),
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
        key: ValueKey<String>('step_${_currentStep}_$_step2Category'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_currentStep == 0) _buildCommonFields(provider),
            if (_currentStep == 1) _buildProposalTypeSelection(provider, isInitial: true),
            if (_currentStep == 2) _buildParametersForm(provider, provider.actions.first),
            if (_currentStep == 3) _buildReviewStep(provider),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(CreateProposalProvider provider) {
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
          decoration: const InputDecoration(labelText: 'Discussion Link'),
          onChanged: (value) => provider.link = value,
          validator: _validateLink,
        ),
      ],
    );
  }

  Widget _buildProposalTypeSelection(CreateProposalProvider provider, {bool isInitial = false, Function(ProposalType)? onSelect}) {
    if (_step2Category == 'daoConfig') return _buildDaoConfigSubcategories(provider, isInitial: isInitial, onSelect: onSelect);
    if (_step2Category == 'govToken') return _buildGovTokenSubcategories(provider, isInitial: isInitial, onSelect: onSelect);
    // THE FIX: Added a new state for showing CSV upload instructions.
    if (_step2Category == 'uploadCsv') return _buildCsvUploadStep();
    return _buildMainCategories(provider, isInitial: isInitial, onSelect: onSelect);
  }
  
  Widget _buildMainCategories(CreateProposalProvider provider, {bool isInitial = false, Function(ProposalType)? onSelect}) {
    // THE FIX: Watch the treasury provider to disable the upload button while assets are loading.
    final treasuryProvider = context.watch<TreasuryProvider>();
    final isTreasuryLoading = treasuryProvider.tokenAssets.isEmpty;
    
    handleSelect(ProposalType type) {
      if (onSelect != null) {
        onSelect(type);
      } else if (isInitial) {
        provider.setInitialProposalType(type);
        _nextStep();
      }
    }
    return Column(
      children: [
        // THE FIX: Reordered proposal types as requested.
        _buildCategoryButton(
          icon: Icons.attach_money_outlined,
          title: "Transfer Assets",
          subtitle: "From the DAO Treasury to another account",
          onTap: () => handleSelect(ProposalType.transfer),
        ),
        _buildCategoryButton(
          icon: Icons.list_alt_outlined,
          title: "Edit Registry",
          subtitle: "Change an entry or add a new one",
          onTap: () => handleSelect(ProposalType.registry),
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
        _buildCategoryButton(
          icon: Icons.code,
          title: "Custom Contract Call",
          subtitle: "Interact with any contract on the network",
          onTap: () => handleSelect(ProposalType.contractCall),
        ),
        _buildCategoryButton(
          icon: Icons.upload_file,
          title: "Upload Executions CSV",
          subtitle: "Batch create transfers, mints, and burns",
          // THE FIX: Show an intermediary step instead of directly opening file picker.
          onTap: isTreasuryLoading ? null : () => setState(() => _step2Category = 'uploadCsv'),
        ),
      ],
    );
  }

  // THE FIX: New widget to show CSV format instructions before upload.
  Widget _buildCsvUploadStep() {
    final textTheme = Theme.of(context).textTheme;
    const monoStyle = TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white);
    const exampleCsv = '''type,asset,to,amount
transfer,0x615954Ada818a757030c57217B6395847eF1172d,0x6E147e1D239bF49c88d64505e746e8522845D8D3,0.5
transfer,native,0x6E147e1D239bF49c88d64505e746e8522845D8D3,13
mint,,0x6A9Cbf5d01B9760CA99c3C27db0B23e3b8Bd454b,44
burn,,0x06E5b15Bc39f921e1503073dBb8A5dA2Fc6220E9,3''';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CSV File Format Instructions', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Your CSV file must have a header row with the following four columns in this exact order:'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black.withOpacity(0.3),
            child: const SelectableText('type,asset,to,amount', style: monoStyle),
          ),
          const SizedBox(height: 24),
          const Text('Column Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const ListTile( dense: true, contentPadding: EdgeInsets.zero, leading: Icon(Icons.arrow_right, size: 18), title: Text('type'), subtitle: Text("Can be 'transfer', 'mint', or 'burn'."), ),
          const ListTile( dense: true, contentPadding: EdgeInsets.zero, leading: Icon(Icons.arrow_right, size: 18), title: Text('asset'), subtitle: Text("For 'transfer', use the ERC20 token address or the word 'native' for the chain's native currency. For 'mint' and 'burn', this column can be left empty."),),
          const ListTile( dense: true, contentPadding: EdgeInsets.zero, leading: Icon(Icons.arrow_right, size: 18), title: Text('to'), subtitle: Text("The recipient address for 'transfer' and 'mint', or the address to burn from for 'burn'."), ),
          const ListTile( dense: true, contentPadding: EdgeInsets.zero, leading: Icon(Icons.arrow_right, size: 18), title: Text('amount'), subtitle: Text("The amount of tokens to be transferred, minted, or burned."), ),
          const SizedBox(height: 24),
          const Text('Example:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Card(
            color: Colors.black.withOpacity(0.2),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: SelectableText(exampleCsv, style: monoStyle),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Select CSV File'),
              onPressed: _handleCsvUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffa1d0d0),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaoConfigSubcategories(CreateProposalProvider provider, {bool isInitial = false, Function(ProposalType)? onSelect}) {
    handleSelect(ProposalType type) {
      if (onSelect != null) {
        onSelect(type);
      } else if (isInitial) {
        provider.setInitialProposalType(type);
        _nextStep();
      }
    }
    return Column(
      children: [
        _buildSubCategoryButton(icon: Icons.group_outlined, title: "Update Quorum", onTap: () => handleSelect(ProposalType.updateQuorum)),
        _buildSubCategoryButton(icon: Icons.hourglass_empty_outlined, title: "Update Voting Delay", onTap: () => handleSelect(ProposalType.updateVotingDelay)),
        _buildSubCategoryButton(icon: Icons.timer_outlined, title: "Update Voting Period", onTap: () => handleSelect(ProposalType.updateVotingPeriod)),
        _buildSubCategoryButton(icon: Icons.account_balance_wallet_outlined, title: "Update Proposal Threshold", onTap: () => handleSelect(ProposalType.updateThreshold)),
      ],
    );
  }

  Widget _buildGovTokenSubcategories(CreateProposalProvider provider, {bool isInitial = false, Function(ProposalType)? onSelect}) {
    handleSelect(ProposalType type) {
      if (onSelect != null) {
        onSelect(type);
      } else if (isInitial) {
        provider.setInitialProposalType(type);
        _nextStep();
      }
    }
    return Column(
      children: [
        _buildSubCategoryButton(icon: Icons.add_circle_outline, title: "Mint Tokens", onTap: () => handleSelect(ProposalType.mintTokens)),
        _buildSubCategoryButton(icon: Icons.remove_circle_outline, title: "Burn Tokens", onTap: () => handleSelect(ProposalType.burnTokens)),
      ],
    );
  }

  Widget _buildCategoryButton({required IconData icon, required String title, required String subtitle, required VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material( color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
        child: InkWell( onTap: onTap, borderRadius: BorderRadius.circular(8),
          child: Opacity(
            opacity: onTap == null ? 0.5 : 1.0,
            child: Padding( padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(icon, size: 32, color: const Color(0xffa1d0d0)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }

  Widget _buildSubCategoryButton({required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding( padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material( color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
        child: InkWell( onTap: onTap, borderRadius: BorderRadius.circular(8),
          child: Padding( padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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

  // --- PARAMETER FORMS ---
  Widget _buildParametersForm(CreateProposalProvider provider, ProposalAction action) {
    switch (action.type) {
      case ProposalType.registry: return _buildRegistryForm(action as RegistryAction);
      case ProposalType.transfer: return _buildTransferForm(action as TransferAction);
      case ProposalType.mintTokens: return _buildMintForm(action as MintTokensAction);
      case ProposalType.burnTokens: return _buildBurnForm(action as BurnTokensAction);
      case ProposalType.updateQuorum: return _buildSingleUintForm("New Quorum", (val) => (action as UpdateQuorumAction).value = val);
      case ProposalType.updateVotingDelay: return _buildSingleUintForm("New Voting Delay", (val) => (action as UpdateVotingDelayAction).value = val, hint: "Value in minutes");
      case ProposalType.updateVotingPeriod: return _buildSingleUintForm("New Voting Period", (val) => (action as UpdateVotingPeriodAction).value = val, hint: "Value in minutes");
      case ProposalType.updateThreshold: return _buildSingleUintForm("New Proposal Threshold", (val) => (action as UpdateThresholdAction).value = val, hint: 'Amount in ${widget.org.symbol}');
      case ProposalType.contractCall: return _ContractCallForm(action: action as ContractCallAction);
    }
  }

  Widget _buildRegistryForm(RegistryAction action) {
    return Column(
      children: [
        TextFormField(
          initialValue: action.key,
          decoration: const InputDecoration(labelText: 'Key'),
          onChanged: (value) => action.key = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: action.value,
          decoration: const InputDecoration(labelText: 'Value'),
          onChanged: (value) => action.value = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildTransferForm(TransferAction action) {
    final treasuryProvider = context.watch<TreasuryProvider>();
    final assets = treasuryProvider.tokenAssets;
    final symbol = action.asset?.token.symbol ?? 'units';

    return Column(
      children: [
        DropdownButtonFormField<TokenAsset>(
          value: action.asset,
          onChanged: (value) => setState(() => action.asset = value),
          decoration: const InputDecoration(labelText: 'Asset to Transfer'),
          validator: (value) => value == null ? 'Please select an asset' : null,
          items: assets.map((asset) {
            final decimals = asset.token.decimals ?? 18;
            // THE FIX: Pass the String 'asset.balance' directly to formatTotalSupply.
            final balance = formatTotalSupply(asset.balance, decimals);
            return DropdownMenuItem( value: asset, child: Text('${asset.token.name} ($balance ${asset.token.symbol})'));
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: action.recipient,
          decoration: const InputDecoration(labelText: 'Recipient Address'),
          onChanged: (value) => action.recipient = value,
          validator: _validateAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: action.amount,
          decoration: InputDecoration(labelText: 'Amount', hintText: 'Amount in $symbol'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => action.amount = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildMintForm(MintTokensAction action) {
    return Column(
      children: [
        TextFormField(
          initialValue: action.recipient,
          decoration: const InputDecoration(labelText: 'Recipient Address'),
          onChanged: (value) => action.recipient = value,
          validator: _validateAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: action.amount,
          decoration: InputDecoration(labelText: 'Amount', hintText: 'Amount in ${widget.org.symbol}'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => action.amount = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildBurnForm(BurnTokensAction action) {
    return Column(
      children: [
        TextFormField(
          initialValue: action.fromAddress,
          decoration: const InputDecoration(labelText: 'From Address'),
          onChanged: (value) => action.fromAddress = value,
          validator: _validateAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: action.amount,
          decoration: InputDecoration(labelText: 'Amount', hintText: 'Amount in ${widget.org.symbol}'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => action.amount = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildSingleUintForm(String label, Function(String) onChanged, {String? hint}) {
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
  
  // --- REVIEW STEP ---

  void _showAddActionDialog() async {
    final provider = context.read<CreateProposalProvider>();
    // Pass the existing providers to the new dialog's context.
    final treasuryProvider = context.read<TreasuryProvider>();
    final networkProvider = context.read<NetworkProvider>();
    final calldataService = context.read<CalldataService>();

    final newAction = await showDialog<ProposalAction>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: treasuryProvider),
            ChangeNotifierProvider.value(value: networkProvider),
            Provider.value(value: calldataService),
          ],
          child: _AddActionDialog(org: widget.org),
        );
      },
    );

    if (newAction != null) {
      provider.addAction(newAction);
    }
  }

  Widget _buildActionReviewItem(ProposalAction action, int index) {
    final provider = context.read<CreateProposalProvider>();
    String title = "Unknown Action";
    String subtitle = "";

    switch (action.type) {
      case ProposalType.transfer:
        final act = action as TransferAction;
        title = "Transfer ${act.amount} ${act.asset?.token.symbol ?? ''}";
        final recipient = act.recipient;
        subtitle = "To: ${recipient.length > 10 ? '${recipient.substring(0, 6)}...${recipient.substring(recipient.length - 4)}' : recipient}";
        break;
      case ProposalType.registry:
        final act = action as RegistryAction;
        title = "Set Registry Key: ${act.key}";
        subtitle = "Value: ${act.value}";
        break;
      // ... Add more cases for human-readable summaries of other action types
      default:
        title = "Action: ${action.type.name}";
        subtitle = "Parameters configured";
        break;
    }
    
    return Card(
      color: Colors.grey.withOpacity(0.15),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.grey.shade700, child: Text('${index + 1}')),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: provider.actions.length > 1
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                tooltip: "Remove Action",
                onPressed: () => provider.removeActionAt(index),
              )
            : null,
      ),
    );
  }

  Widget _buildReviewStep(CreateProposalProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem("Title", provider.title),
        _buildReviewItem("Description", provider.description),
        if (provider.link.isNotEmpty) _buildReviewItem("Discussion Link", provider.link),
        const Divider(height: 32, color: Colors.white24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Actions (${provider.actions.length})",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Add Action"),
              onPressed: _showAddActionDialog,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffa1d0d0),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.actions.length,
          itemBuilder: (context, index) => _buildActionReviewItem(provider.actions[index], index),
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

class _ContractCallForm extends StatefulWidget {
  final ContractCallAction action;
  const _ContractCallForm({required this.action});

  @override
  State<_ContractCallForm> createState() => _ContractCallFormState();
}

class _ContractCallFormState extends State<_ContractCallForm> {
  final _targetController = TextEditingController();
  final _signatureController = TextEditingController();
  final _calldataController = TextEditingController();
  
  List<MapEntry<FunctionParameter, TextEditingController>> _paramControllers = [];

  @override
  void initState() {
    super.initState();
    _targetController.text = widget.action.targetAddress;
    _signatureController.text = widget.action.functionSignature;
    _calldataController.text = widget.action.rawCalldata;

    _targetController.addListener(() => widget.action.targetAddress = _targetController.text);
    _calldataController.addListener(() => widget.action.rawCalldata = _calldataController.text);
  }

  @override
  void dispose() {
    _targetController.dispose();
    _signatureController.dispose();
    _calldataController.dispose();
    for (var entry in _paramControllers) { entry.value.dispose(); }
    super.dispose();
  }

  void _parseSignature() {
    final signature = _signatureController.text;
    final calldataService = context.read<CalldataService>();
    for (var entry in _paramControllers) { entry.value.dispose(); }
    setState(() => _paramControllers = []);

    try {
      final params = calldataService.getParametersFromSignature(signature);
      final newControllers = params.map((p) => MapEntry(p, TextEditingController())).toList();

      for (int i = 0; i < newControllers.length; i++) {
        final index = i;
        newControllers[i].value.addListener(() {
          widget.action.paramValues[index] = newControllers[index].value.text;
        });
      }
      
      setState(() {
        _paramControllers = newControllers;
        widget.action.functionSignature = signature;
        widget.action.paramValues = List.filled(newControllers.length, '');
      });

    } on FormatException catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error parsing signature: ${e.message}"), backgroundColor: Colors.redAccent));
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An unexpected error occurred: ${e.toString()}"), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField( controller: _targetController, decoration: const InputDecoration(labelText: 'Target Contract Address'), validator: _validateAddress),
        const SizedBox(height: 16),
        ToggleButtons(
          isSelected: [!widget.action.isRawMode, widget.action.isRawMode],
          onPressed: (index) => setState(() => widget.action.isRawMode = index == 1),
          borderRadius: BorderRadius.circular(8),
          children: const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Manual Definition')),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Raw Calldata')),
          ],
        ),
        const SizedBox(height: 16),

        if (widget.action.isRawMode)
          TextFormField(
            controller: _calldataController,
            decoration: const InputDecoration(labelText: 'Raw Calldata (0x...)'),
            maxLines: 4,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (!v.startsWith('0x')) return 'Calldata must start with 0x';
              if (RegExp(r'[^0-9a-fA-Fx]').hasMatch(v)) return 'Invalid hexadecimal characters';
              return null;
            },
          )
        else
          Column(
            children: [
              Row( crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _signatureController,
                      decoration: const InputDecoration(labelText: 'Function Signature', hintText: 'e.g., transfer(address,uint256)'),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding( padding: const EdgeInsets.only(top: 8.0), child: ElevatedButton(onPressed: _parseSignature, child: const Text('Parse'))),
                ],
              ),
              const SizedBox(height: 16),
              if (_paramControllers.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _paramControllers.length,
                  itemBuilder: (context, index) {
                    final entry = _paramControllers[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextFormField(
                        controller: entry.value,
                        decoration: InputDecoration(labelText: 'Parameter ${index + 1} (${entry.key.type.name})'),
                        validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                      ),
                    );
                  },
                ),
            ],
          ),
      ],
    );
  }
}

// A self-contained dialog for adding a new action to a proposal.
class _AddActionDialog extends StatefulWidget {
  final Org org;
  const _AddActionDialog({required this.org});

  @override
  State<_AddActionDialog> createState() => _AddActionDialogState();
}

class _AddActionDialogState extends State<_AddActionDialog> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0; // 0 for type selection, 1 for parameters
  String? _category;
  ProposalAction? _action;

  void _selectActionType(ProposalType type) {
    setState(() {
      switch (type) {
        case ProposalType.registry: _action = RegistryAction(); break;
        case ProposalType.transfer: _action = TransferAction(); break;
        case ProposalType.mintTokens: _action = MintTokensAction(); break;
        case ProposalType.burnTokens: _action = BurnTokensAction(); break;
        case ProposalType.updateQuorum: _action = UpdateQuorumAction(); break;
        case ProposalType.updateVotingDelay: _action = UpdateVotingDelayAction(); break;
        case ProposalType.updateVotingPeriod: _action = UpdateVotingPeriodAction(); break;
        case ProposalType.updateThreshold: _action = UpdateThresholdAction(); break;
        case ProposalType.contractCall: _action = ContractCallAction(); break;
      }
      _step = 1;
    });
  }

  void _handleAdd() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_action);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff2c2c2c),
      title: Text(_step == 0 ? 'Select Action Type' : 'Set Parameters'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: _step == 0 
              ? _buildTypeSelection()
              : _buildParametersForm(_action!),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_step == 1) {
              setState(() => _step = 0);
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Text(_step == 1 ? 'Back' : 'Cancel'),
        ),
        if (_step == 1)
          ElevatedButton(
            onPressed: _handleAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffa1d0d0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Add Action', style: TextStyle(color: Colors.black)),
          ),
      ],
    );
  }

  Widget _buildTypeSelection() {
    if (_category == 'daoConfig') return _buildDaoConfigSubcategories();
    if (_category == 'govToken') return _buildGovTokenSubcategories();
    return _buildMainCategories();
  }

  Widget _buildMainCategories() {
    return Column(
      children: [
         _buildCategoryButton(icon: Icons.attach_money_outlined, title: "Transfer Assets", subtitle: "From the DAO Treasury to another account", onTap: () => _selectActionType(ProposalType.transfer)),
        _buildCategoryButton(icon: Icons.list_alt_outlined, title: "Edit Registry", subtitle: "Change an entry or add a new one", onTap: () => _selectActionType(ProposalType.registry)),
        _buildCategoryButton(icon: Icons.code, title: "Custom Contract Call", subtitle: "Interact with any contract on the network", onTap: () => _selectActionType(ProposalType.contractCall)),
        _buildCategoryButton(icon: Icons.settings_outlined, title: "DAO Configuration", subtitle: "Change quorum, voting durations, or threshold", onTap: () => setState(() => _category = 'daoConfig')),
        _buildCategoryButton(icon: Icons.generating_tokens_outlined, title: "Manage ${widget.org.symbol} Tokens", subtitle: "Mint new tokens or burn existing ones", onTap: () => setState(() => _category = 'govToken')),
      ],
    );
  }

  Widget _buildDaoConfigSubcategories() {
    return Column(
      children: [
        _buildSubCategoryButton(icon: Icons.group_outlined, title: "Update Quorum", onTap: () => _selectActionType(ProposalType.updateQuorum)),
        _buildSubCategoryButton(icon: Icons.hourglass_empty_outlined, title: "Update Voting Delay", onTap: () => _selectActionType(ProposalType.updateVotingDelay)),
        _buildSubCategoryButton(icon: Icons.timer_outlined, title: "Update Voting Period", onTap: () => _selectActionType(ProposalType.updateVotingPeriod)),
        _buildSubCategoryButton(icon: Icons.account_balance_wallet_outlined, title: "Update Proposal Threshold", onTap: () => _selectActionType(ProposalType.updateThreshold)),
      ],
    );
  }

  Widget _buildGovTokenSubcategories() {
    return Column(
      children: [
        _buildSubCategoryButton(icon: Icons.add_circle_outline, title: "Mint Tokens", onTap: () => _selectActionType(ProposalType.mintTokens)),
        _buildSubCategoryButton(icon: Icons.remove_circle_outline, title: "Burn Tokens", onTap: () => _selectActionType(ProposalType.burnTokens)),
      ],
    );
  }

  Widget _buildParametersForm(ProposalAction action) {
    // This is now self-contained within the dialog state.
    switch (action.type) {
      case ProposalType.registry: return _buildRegistryForm(action as RegistryAction);
      case ProposalType.transfer: return _buildTransferForm(action as TransferAction);
      case ProposalType.mintTokens: return _buildMintForm(action as MintTokensAction);
      case ProposalType.burnTokens: return _buildBurnForm(action as BurnTokensAction);
      case ProposalType.updateQuorum: return _buildSingleUintForm("New Quorum", (val) => (action as UpdateQuorumAction).value = val);
      case ProposalType.updateVotingDelay: return _buildSingleUintForm("New Voting Delay", (val) => (action as UpdateVotingDelayAction).value = val, hint: "Value in minutes");
      case ProposalType.updateVotingPeriod: return _buildSingleUintForm("New Voting Period", (val) => (action as UpdateVotingPeriodAction).value = val, hint: "Value in minutes");
      case ProposalType.updateThreshold: return _buildSingleUintForm("New Proposal Threshold", (val) => (action as UpdateThresholdAction).value = val, hint: 'Amount in ${widget.org.symbol}');
      case ProposalType.contractCall: return _ContractCallForm(action: action as ContractCallAction);
    }
  }

  Widget _buildRegistryForm(RegistryAction action) {
    return Column(
      children: [
        TextFormField(
          initialValue: action.key,
          decoration: const InputDecoration(labelText: 'Key'),
          onChanged: (value) => action.key = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: action.value,
          decoration: const InputDecoration(labelText: 'Value'),
          onChanged: (value) => action.value = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildTransferForm(TransferAction action) {
    final treasuryProvider = context.watch<TreasuryProvider>();
    final assets = treasuryProvider.tokenAssets;
    final symbol = action.asset?.token.symbol ?? 'units';

    return Column(
      children: [
        DropdownButtonFormField<TokenAsset>(
          value: action.asset,
          onChanged: (value) => setState(() => action.asset = value),
          decoration: const InputDecoration(labelText: 'Asset to Transfer'),
          validator: (value) => value == null ? 'Please select an asset' : null,
          items: assets.map((asset) {
            final decimals = asset.token.decimals ?? 18;
            // THE FIX: Pass the String 'asset.balance' directly to formatTotalSupply.
            final balance = formatTotalSupply(asset.balance, decimals);
            return DropdownMenuItem( value: asset, child: Text('${asset.token.name} ($balance ${asset.token.symbol})'));
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: action.recipient,
          decoration: const InputDecoration(labelText: 'Recipient Address'),
          onChanged: (value) => action.recipient = value,
          validator: _validateAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: action.amount,
          decoration: InputDecoration(labelText: 'Amount', hintText: 'Amount in $symbol'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => action.amount = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildMintForm(MintTokensAction action) {
    return Column(
      children: [
        TextFormField(
          initialValue: action.recipient,
          decoration: const InputDecoration(labelText: 'Recipient Address'),
          onChanged: (value) => action.recipient = value,
          validator: _validateAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: action.amount,
          decoration: InputDecoration(labelText: 'Amount', hintText: 'Amount in ${widget.org.symbol}'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => action.amount = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildBurnForm(BurnTokensAction action) {
    return Column(
      children: [
        TextFormField(
          initialValue: action.fromAddress,
          decoration: const InputDecoration(labelText: 'From Address'),
          onChanged: (value) => action.fromAddress = value,
          validator: _validateAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: action.amount,
          decoration: InputDecoration(labelText: 'Amount', hintText: 'Amount in ${widget.org.symbol}'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => action.amount = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildSingleUintForm(String label, Function(String) onChanged, {String? hint}) {
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

  Widget _buildCategoryButton({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material( color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
        child: InkWell( onTap: onTap, borderRadius: BorderRadius.circular(8),
          child: Padding( padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, size: 32, color: const Color(0xffa1d0d0)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column( crossAxisAlignment: CrossAxisAlignment.start,
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
    return Padding( padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material( color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
        child: InkWell( onTap: onTap, borderRadius: BorderRadius.circular(8),
          child: Padding( padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
}
// lib/src/features/create_proposal/create_proposal_dialog.dart```