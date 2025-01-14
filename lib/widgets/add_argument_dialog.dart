// lib/widgets/add_argument_dialog.dart

import 'package:flutter/material.dart';

class AddArgumentDialog extends StatefulWidget {
  final Function(String content, double weight) onAdd;

  const AddArgumentDialog({Key? key, required this.onAdd}) : super(key: key);

  @override
  _AddArgumentDialogState createState() => _AddArgumentDialogState();
}

class _AddArgumentDialogState extends State<AddArgumentDialog> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  void _submit() {
    final text = _contentController.text.trim();
    final weightStr = _weightController.text.trim();

    if (text.isEmpty || weightStr.isEmpty) {
      return;
    }
    double? w = double.tryParse(weightStr);
    if (w == null) {
      return;
    }

    widget.onAdd(text, w);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Argument'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Write your argument (Markdown supported)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Voting Weight',
                hintText: 'e.g. 50',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
