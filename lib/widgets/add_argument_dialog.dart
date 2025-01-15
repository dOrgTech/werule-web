// lib/widgets/add_argument_dialog.dart

import 'package:Homebase/widgets/newDebate.dart';
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
    if (text.isEmpty || weightStr.isEmpty) return;

    final w = double.tryParse(weightStr);
    if (w == null) return;

    widget.onAdd(text, w);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Argument'),
      content: SingleChildScrollView(
        child: Container(
          width: 600,
          child: Column(
            children: [
              TextFormField(
                maxLines: 26,
                controller: _contentController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Write your argument (Markdown supported)',
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    hintText: 'max: 3950',
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: SubmitButton(
                  isSubmitEnabled: true,
                  submit: _submit,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
