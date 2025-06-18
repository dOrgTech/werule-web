import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../entities/human.dart';

class UnsupportedChainWidget extends StatelessWidget {
  const UnsupportedChainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final human = Provider.of<Human>(context, listen: false);
    // Etherlink Mainnet details for the button
    const String etherlinkMainnetName = "Etherlink"; // As per your chains map

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.orangeAccent,
              size: 70,
            ),
            const SizedBox(height: 20),
            const Text(
              'Unsupported Network',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              'Please switch to a supported network in your wallet, or add the ${human.chain.name} network.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_link),
              label: Text('Add/Switch to $etherlinkMainnetName'),
              onPressed: () {
                // Call the method in Human to attempt switching to Etherlink Mainnet
                human.attemptSwitchToEtherlinkMainnet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).indicatorColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '(Currently connected to: ${human.chain.name})', // Shows what Human thinks current chain is
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            )
          ],
        ),
      ),
    );
  }
}