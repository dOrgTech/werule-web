// lib/src/features/proposal_detail/widgets/details/shared_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:werule/src/utils/reusable.dart';

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

Widget buildContractCallRow(BuildContext context, String label, String value) {
   return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
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
          child: Text(
            value,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 16),
          splashRadius: 20,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
            );
          },
        ),
      ],
    ),
  );
}
// lib/src/features/proposal_detail/widgets/details/shared_widgets.dart