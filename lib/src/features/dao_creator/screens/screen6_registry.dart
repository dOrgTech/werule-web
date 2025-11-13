// lib/src/features/dao_creator/screens/screen6_registry.dart
import 'package:flutter/material.dart';
import 'package:werule/src/features/dao_creator/providers/dao_creator_provider.dart';
import 'package:werule/src/features/dao_creator/widgets/creator_widgets.dart';

class Screen6Registry extends StatefulWidget {
  final DaoCreatorProvider provider;

  const Screen6Registry({
    super.key,
    required this.provider,
  });

  @override
  _Screen6RegistryState createState() => _Screen6RegistryState();
}

class _Screen6RegistryState extends State<Screen6Registry> {
  List<RegistryEntry> _registryEntries = [];

  @override
  void initState() {
    super.initState();
    if (widget.provider.registry.isNotEmpty) {
      _registryEntries = widget.provider.registry.entries
          .map((entry) => RegistryEntry(
                keyController: TextEditingController(text: entry.key),
                valueController: TextEditingController(text: entry.value),
              ))
          .toList();
    } else {
      // Add default entries for USDC and the native token
      const usdcAddress = '0x796Ea11Fa2dD751eD01b53C372fFDB4AAa8f00F9';
      final usdcKey = 'jurisdiction.parity.${usdcAddress.toLowerCase()}';
      const usdcValue = '1000000000000000000'; // 1 reputation point

      const nativeTokenAddress = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';
      final nativeTokenKey =
          'jurisdiction.parity.${nativeTokenAddress.toLowerCase()}';
      const nativeTokenValue = '500000000000000000'; // 0.5 reputation points

      _registryEntries.addAll([
        RegistryEntry(
          keyController: TextEditingController(text: usdcKey),
          valueController: TextEditingController(text: usdcValue),
        ),
        RegistryEntry(
          keyController: TextEditingController(text: nativeTokenKey),
          valueController: TextEditingController(text: nativeTokenValue),
        ),
      ]);
    }
  }

  void _addRegistryEntry() {
    setState(() {
      _registryEntries.add(RegistryEntry(
        keyController: TextEditingController(),
        valueController: TextEditingController(),
      ));
    });
  }

  void _removeRegistryEntry(int index) {
    setState(() {
      _registryEntries[index].keyController.dispose();
      _registryEntries[index].valueController.dispose();
      _registryEntries.removeAt(index);
    });
  }

  void _saveAndNext() {
    final newRegistry = Map.fromEntries(_registryEntries
        .where((entry) =>
            entry.keyController.text.isNotEmpty ||
            entry.valueController.text.isNotEmpty)
        .map(
          (entry) => MapEntry(
            entry.keyController.text,
            entry.valueController.text,
          ),
        ));
    widget.provider.updateRegistry(newRegistry);
    widget.provider.nextStep();
  }

  @override
  void dispose() {
    for (var entry in _registryEntries) {
      entry.keyController.dispose();
      entry.valueController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Text('DAO Registry',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 26),
              SizedBox(
                width: 600,
                child: Text(
                  'The Registry is an on-chain key-value store for your DAO\'s rules and configurations, like a constitution link or on-chain parameters.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 194, 194, 194),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                width: 600,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade700, width: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primary Use: The Value Index',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Theme.of(context).indicatorColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A key function is setting token parities to calculate member reputation from economic activity. The format is crucial:',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade300),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'jurisdiction.parity.<token_address>',
                      style:
                          TextStyle(fontFamily: 'monospace', color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We\'ve added defaults for USDC and the native token (e.g., ETH) based on an example exchange rate. You can edit these values or add more tokens.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade300),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _registryEntries.length,
                itemBuilder: (context, index) {
                  return RegistryEntryWidget(
                    entry: _registryEntries[index],
                    onRemove: () => _removeRegistryEntry(index),
                  );
                },
              ),
              const SizedBox(height: 50),
              Center(
                child: SizedBox(
                  width: 160,
                  child: TextButton(
                    onPressed: _addRegistryEntry,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.add), Text(' Add Entry')],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 126),
              SizedBox(
                width: 700,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: widget.provider.previousStep,
                        child: const Text('< Back')),
                    ElevatedButton(
                        onPressed: _saveAndNext,
                        child: const Text('Save and Continue >')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// lib/src/features/dao_creator/screens/screen6_registry.dart