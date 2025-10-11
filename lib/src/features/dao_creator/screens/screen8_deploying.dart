// lib/src/features/dao_creator/screens/screen8_deploying.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/dao_creator/providers/dao_creator_provider.dart';

class Screen8Deploying extends StatelessWidget {
  final DaoCreatorProvider provider;
  const Screen8Deploying({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // If there's an error, show the error icon and message.
            if (provider.deploymentError != null) ...[
              const Icon(Icons.error_outline, color: Colors.red, size: 100),
              const SizedBox(height: 50),
              const Text("Deployment Failed", style: TextStyle(color: Colors.red, fontSize: 18)),
              const SizedBox(height: 16),
              Text(provider.deploymentError!, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton(
                // Go back to the Review screen (index 6) to allow changes.
                onPressed: () => provider.goToStep(6),
                child: const Text('Back to Review'),
              )
            ] 
            // Otherwise, show the progress indicator and status message.
            else ...[
              const SizedBox(
                  height: 100, width: 100, child: CircularProgressIndicator()),
              const SizedBox(height: 50),
              Text(
                provider.deploymentStatusMessage,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}