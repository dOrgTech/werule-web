// lib/src/features/create_debate/create_debate_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/debates_provider.dart';
import 'package:werule/src/utils/reusable.dart';

/// Dialog for creating a new tokenized debate
class CreateDebateDialog extends StatefulWidget {
  final Org org;
  const CreateDebateDialog({super.key, required this.org});

  @override
  State<CreateDebateDialog> createState() => _CreateDebateDialogState();
}

class _CreateDebateDialogState extends State<CreateDebateDialog> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  String _title = '';
  String _rootArgument = '';
  String _initialWeight = '';

  final _stepSubtitles = const [
    'Step 1: Debate Title',
    'Step 2: Initial Thesis',
    'Step 3: Review & Submit',
  ];

  void _nextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentStep < _stepSubtitles.length - 1) {
        setState(() => _currentStep++);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _handleSubmit() async {
    if (!mounted) return;

    final provider = context.read<DebatesProvider>();

    // Parse weight to BigInt (18 decimals)
    final weightDouble = double.tryParse(_initialWeight) ?? 0;
    final weightBigInt = BigInt.from(weightDouble * 1e18);

    final error = await provider.createDebate(
      title: _title,
      rootArgument: _rootArgument,
      rootWeight: weightBigInt,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Center(child: Text(error)),
        backgroundColor: Colors.redAccent,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Center(child: Text("Debate created successfully!")),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pop(true); // Return true to indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DebatesProvider>();

    return AlertDialog(
      backgroundColor: const Color(0xff2c2c2c),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.forum, color: Color(0xffa1d0d0)),
              const SizedBox(width: 12),
              const Text('Create Debate', style: TextStyle(color: Color.fromARGB(255, 219, 219, 219))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              _stepSubtitles[_currentStep],
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color.fromARGB(179, 255, 255, 255),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: _buildStepContent(),
          ),
        ),
      ),
      actions: _buildActions(provider),
    );
  }

  Widget _buildStepContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Container(
        key: ValueKey<int>(_currentStep),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_currentStep == 0) _buildTitleStep(),
            if (_currentStep == 1) _buildThesisStep(),
            if (_currentStep == 2) _buildReviewStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What topic do you want to debate?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a clear, focused topic that community members can take positions on.',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 24),
        TextFormField(
          initialValue: _title,
          decoration: const InputDecoration(
            labelText: 'Debate Title',
            hintText: 'e.g., Should we increase the treasury allocation for marketing?',
          ),
          maxLength: 500,
          onChanged: (value) => _title = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Title is required' : null,
        ),
      ],
    );
  }

  Widget _buildThesisStep() {
    final provider = context.watch<DebatesProvider>();
    final votes = provider.userTotalVotingPower;
    final maxWeight = formatTotalSupply(votes.toString(), 18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'State Your Position',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Write the initial thesis or claim that will be debated. This becomes the root argument.',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 24),
        TextFormField(
          initialValue: _rootArgument,
          decoration: const InputDecoration(
            labelText: 'Initial Thesis / Claim',
            hintText: 'State your position clearly and concisely...',
            alignLabelWithHint: true,
          ),
          maxLines: 6,
          maxLength: 500,
          onChanged: (value) => _rootArgument = value,
          validator: (value) => (value?.isEmpty ?? true) ? 'Thesis is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _initialWeight,
          decoration: InputDecoration(
            labelText: 'Initial Weight (Voting Power)',
            hintText: 'Amount in ${widget.org.symbol}',
            helperText: 'Your available voting power: $maxWeight ${widget.org.symbol}',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
          ],
          onChanged: (value) => _initialWeight = value,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Weight is required';
            final parsed = double.tryParse(value);
            if (parsed == null) return 'Must be a valid number';
            if (parsed <= 0) return 'Must be greater than 0';
            final weightBigInt = BigInt.from(parsed * 1e18);
            if (weightBigInt > votes) return 'Exceeds your voting power ($maxWeight ${widget.org.symbol})';
            return null;
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: Colors.blue[300]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'The initial weight represents your stake in this position. Others can add supporting or opposing arguments with their own weight.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Your Debate',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _buildReviewItem('Title', _title),
        const SizedBox(height: 16),
        _buildReviewItem('Initial Thesis', _rootArgument),
        const SizedBox(height: 16),
        _buildReviewItem('Initial Weight', '$_initialWeight ${widget.org.symbol}'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Once created, debates cannot be deleted. Your voting power will be locked for this debate.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[300]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(value, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  List<Widget> _buildActions(DebatesProvider provider) {
    return [
      TextButton(
        onPressed: provider.isActionBusy ? null : (_currentStep > 0 ? _previousStep : () => Navigator.of(context).pop()),
        child: Text(_currentStep > 0 ? 'Back' : 'Cancel'),
      ),
      ElevatedButton(
        onPressed: provider.isActionBusy
            ? null
            : (_currentStep < _stepSubtitles.length - 1 ? _nextStep : _handleSubmit),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffa1d0d0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: provider.isActionBusy
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
            : Text(
                _currentStep < _stepSubtitles.length - 1 ? 'Next' : 'Create Debate',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
      ),
    ];
  }
}
