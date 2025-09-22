// lib/src/features/dao_creator/widgets/pleading_for_less_decimals.dart
import 'package:flutter/material.dart';

class AnimatedMemeWidget extends StatelessWidget {
  const AnimatedMemeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 60, color: Colors.amber),
            SizedBox(height: 20),
            Text(
              'A high number of decimals can be confusing for users and may not be supported by all interfaces.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),
            Text(
              '(Imagine an animated meme here pleading with you to use fewer decimals)',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/src/features/dao_creator/widgets/pleading_for_less_decimals.dart