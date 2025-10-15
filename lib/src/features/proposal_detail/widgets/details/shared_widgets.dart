// lib/src/features/proposal_detail/widgets/details/shared_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildDetailRow(String label, String value, {bool isCode = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(label),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.2),
              color: Colors.black.withOpacity(0.2),
            ),
            child: Text(
              value,
              style: isCode ? const TextStyle(fontFamily: 'monospace', color: Colors.white) : null,
            ),
          ),
        ),
      ],
    ),
  );
}

// THE FIX: Modified to match the visual style of `buildDetailRow` with a box, while retaining the copy button.
Widget buildContractCallRow(BuildContext context, String label, String value, {String? fullValueToCopy}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(label),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 8.0), // Padding for the text, button has its own
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 0.2),
              color: Colors.black.withOpacity(0.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      value,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  splashRadius: 20,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(10.0), // Make the tap area reasonable
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: fullValueToCopy ?? value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
// lib/src/features/proposal_detail/widgets/details/shared_widgets.dart