// lib/src/features/debate_detail/widgets/add_argument_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/models/debate.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/providers/debates_provider.dart';
import 'package:werule/src/utils/reusable.dart';

/// Dialog for adding a new argument to a debate
class AddArgumentDialog extends StatefulWidget {
  final Debate debate;
  final DebateArgument parentArgument;
  final ArgumentType argType;
  final Org org;
  final VoidCallback onSuccess;

  const AddArgumentDialog({
    super.key,
    required this.debate,
    required this.parentArgument,
    required this.argType,
    required this.org,
    required this.onSuccess,
  });

  @override
  State<AddArgumentDialog> createState() => _AddArgumentDialogState();
}

class _AddArgumentDialogState extends State<AddArgumentDialog> {
  final _formKey = GlobalKey<FormState>();
  String _content = '';
  String _weight = '';

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<DebatesProvider>();

    // Parse weight to BigInt (18 decimals)
    final weightDouble = double.tryParse(_weight) ?? 0;
    final weightBigInt = BigInt.from(weightDouble * 1e18);

    final error = await provider.addArgument(
      parentId: widget.parentArgument.id,
      argType: widget.argType,
      weight: weightBigInt,
      content: _content,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Center(child: Text(error)),
        backgroundColor: Colors.redAccent,
      ));
    } else {
      Navigator.of(context).pop();
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Center(child: Text(
          widget.argType == ArgumentType.pro
              ? 'Supporting argument added!'
              : 'Opposing argument added!',
        )),
        backgroundColor: Colors.green,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DebatesProvider>();
    final remainingPower = provider.userRemainingVotingPower;
    final remainingFormatted = formatTotalSupply(remainingPower.toString(), 18);

    final isPro = widget.argType == ArgumentType.pro;
    final color = isPro ? Colors.green : Colors.red;

    return AlertDialog(
      backgroundColor: const Color(0xff2c2c2c),
      title: Row(
        children: [
          Icon(
            isPro ? Icons.thumb_up : Icons.thumb_down,
            color: color,
          ),
          const SizedBox(width: 12),
          Text(
            isPro ? 'Add Supporting Argument' : 'Add Opposing Argument',
            style: const TextStyle(color: Color.fromARGB(255, 219, 219, 219)),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Parent context
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Responding to:',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.parentArgument.content.length > 200
                            ? '${widget.parentArgument.content.substring(0, 200)}...'
                            : widget.parentArgument.content,
                        style: TextStyle(color: Colors.grey[300], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Content field
                Text(
                  isPro
                      ? 'Why do you support this argument?'
                      : 'Why do you oppose this argument?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'State your position clearly...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 6,
                  maxLength: 500,
                  onChanged: (value) => _content = value,
                  validator: (value) => (value?.isEmpty ?? true) ? 'Content is required' : null,
                ),
                const SizedBox(height: 16),

                // Weight field
                const Text(
                  'Voting Power to Stake',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Amount in ${widget.org.symbol}',
                    helperText: 'Remaining voting power: $remainingFormatted ${widget.org.symbol}',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => _weight = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Weight is required';
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) return 'Must be a positive number';
                    final weightBigInt = BigInt.from(parsed * 1e18);
                    if (weightBigInt > remainingPower) return 'Exceeds your remaining voting power';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Info box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isPro
                              ? 'Your supporting argument will add weight to the parent argument if valid (positive net score).'
                              : 'Your opposing argument will subtract weight from the parent argument if valid (positive net score).',
                          style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: provider.isActionBusy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: provider.isActionBusy ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: provider.isActionBusy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  isPro ? 'Add Support' : 'Add Opposition',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
